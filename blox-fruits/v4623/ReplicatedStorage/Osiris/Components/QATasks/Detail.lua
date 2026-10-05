local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)

local function drawSteps(p, driver)
	local steps = p.Steps

	if steps == nil or #steps == 0 then
		return
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Steps"
		}
	})

	for k, step in steps do
		Osiris.PushId((`step-{k}`))
		local v = k
		local v2 = step
		Osiris.Widget.SameLine({}, function()
			Osiris.Widget.Text({
				Arguments = {
					Text = `{v}.`,
					Color = Present.MUTED
				}
			})
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.stepLabel(v2),
					Wrapped = true
				}
			})
			local command = v2.Command

			if command ~= nil and driver.runCommand ~= nil and Osiris.Widget.SmallButton({
				Arguments = {
					Text = "run"
				}
			}).clicked() then
				driver.runCommand(command)
			end
		end)
		local command = step.Command

		if command ~= nil then
			local command2 = command
			Osiris.Widget.Indent({}, function()
				Present.command(command2, "command")
			end)
		end

		Osiris.PopId()
	end
end

local function drawExpectations(p)
	local expectations = p.Expectations

	if expectations == nil or #expectations == 0 then
		return
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Expectations"
		}
	})

	for k, expectation in expectations do
		Osiris.PushId((`expectation-{k}`))
		Osiris.Widget.Text({
			Arguments = {
				Text = Present.expectationLabel(expectation),
				Color = Present.expectationColor(expectation),
				Wrapped = true
			}
		})
		Osiris.PopId()
	end
end

local function drawChildren(store, driver, p)
	local children = Loader.getChildren(store, p.Path)

	if children == nil then
		Present.note("loading subtasks...")
		return
	end

	if #children == 0 then
		return
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = `Subtasks ({#children})`
		}
	})

	for _, v in children do
		Osiris.PushId(v.Path)
		local v2 = v
		Osiris.Widget.SameLine({}, function()
			local progress, v3 = Loader.getProgress(store, driver, v2.Path)
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.progressText(progress, v3),
					Color = Present.progressColor(progress, v3)
				}
			})

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = v2.Title
				}
			}).clicked() then
				Loader.navigate(store, driver, p.Path)
				Loader.select(store, driver, v2.Path)
			end
		end)
		Osiris.PopId()
	end
end

local function drawAssignment(store, driver, p, canWrite: boolean)
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Assignment"
		}
	})
	local assignment = Loader.getAssignment(store, p.Path)

	if assignment then
		Osiris.Widget.Text({
			Arguments = {
				Text = Present.assignmentLabel(assignment),
				Color = Present.WARN
			}
		})
		Present.note((`set on {Present.formatTimestamp(assignment.Timestamp)}`))
	else
		Present.note("not assigned to anyone")
	end

	if not canWrite then
		return
	end

	local v = store.testers:get()
	local values = { "(nobody)" }
	local userIds = {}

	for _, v2 in v do
		local formatted = `{v2.Name} ({v2.Rank})`
		table.insert(values, formatted)
		userIds[formatted] = v2.UserId
	end

	if store.testerChoice:get() == "" or store.testerChoice:get() ~= "(nobody)" and userIds[store.testerChoice:get()] == nil then
		store.testerChoice:set("(nobody)")
	end

	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.ComboArray({
			Arguments = {
				Text = "tester"
			},
			States = {
				index = store.testerChoice
			},
			Extra = {
				selectionArray = values
			}
		})

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "online testers"
			}
		}).clicked() then
			Loader.loadTesters(store, driver)
		end
	end)
	Osiris.Widget.SameLine({}, function()
		local v2 = userIds[store.testerChoice:get()]

		if v2 ~= nil and Osiris.Widget.SmallButton({
			Arguments = {
				Text = "assign task + subtasks"
			}
		}).clicked() then
			Loader.assign(store, driver, p.Path, v2)
		end

		if assignment and Osiris.Widget.SmallButton({
			Arguments = {
				Text = "unassign"
			}
		}).clicked() then
			Loader.assign(store, driver, p.Path, nil)
		end
	end)

	if #v == 0 then
		Present.note("press 'online testers' to list players with a QA rank in this server")
	end
end

return function(p)
	local store = p.Store
	local driver = p.Driver
	local v = store.permissions:get()
	local canWrite

	if v == nil then
		canWrite = false
	else
		canWrite = v.CanWrite
	end

	local v2 = store.selectedPath:get()

	if v2 == nil then
		Present.note("select a task to see its details")
		return
	end

	Loader.ensureTask(store, driver, v2)
	Loader.ensureChildren(store, driver, v2)
	local v3 = store.tasks:get()[v2]

	if v3 == nil then
		Present.note(Loader.isPending(store, (`task:{v2}`)) and "loading..." or "task not found")
		return
	end

	Osiris.PushId(v3.Path)
	Osiris.Widget.SameLine({}, function()
		Present.icon(v3)
		Osiris.Widget.Text({
			Arguments = {
				Text = v3.Title,
				Wrapped = true
			}
		})
		Osiris.Widget.Text({
			Arguments = {
				Text = Present.sourceLabel(v3),
				Color = Present.MUTED
			}
		})
	end)
	Osiris.Widget.Text({
		Arguments = {
			Text = v3.Path,
			Color = Present.MUTED,
			Wrapped = true
		}
	})
	Present.tags(v3.Tags)
	local progress, v4 = Loader.getProgress(store, driver, v3.Path)
	Present.stat("status", Present.statusLabel(progress, v4), Present.progressColor(progress, v4))
	Present.stat("progress", Present.progressText(progress, v4), Present.progressColor(progress, v4))

	if canWrite then
		Osiris.Widget.SameLine({}, function()
			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "+ subtask"
				}
			}).clicked() then
				Loader.openCreate(store, v3.Path)
			end

			if v3.Source == "Custom" then
				if Osiris.Widget.SmallButton({
					Arguments = {
						Text = "edit"
					}
				}).clicked() then
					Loader.openEdit(store, v3)
				end

				local state = Osiris.State(false)

				if state:get() then
					Osiris.Widget.Text({
						Arguments = {
							Text = "delete this task and its subtasks?",
							Color = Present.BAD
						}
					})

					if Osiris.Widget.SmallButton({
						Arguments = {
							Text = "yes, delete"
						}
					}).clicked() then
						state:set(false)
						Loader.deleteTask(store, driver, v3.Path)
					end

					if Osiris.Widget.SmallButton({
						Arguments = {
							Text = "cancel"
						}
					}).clicked() then
						state:set(false)
					end
				elseif Osiris.Widget.SmallButton({
					Arguments = {
						Text = "delete"
					}
				}).clicked() then
					state:set(true)
				end
			end
		end)
	end

	if v3.Description then
		Osiris.Widget.SeparatorText({
			Arguments = {
				Text = "Description"
			}
		})
		Osiris.Widget.Text({
			Arguments = {
				Text = v3.Description,
				Wrapped = true
			}
		})
	end

	drawSteps(v3, driver)
	drawExpectations(v3)
	drawAssignment(store, driver, v3, canWrite)
	drawChildren(store, driver, v3)
	Osiris.PopId()
end