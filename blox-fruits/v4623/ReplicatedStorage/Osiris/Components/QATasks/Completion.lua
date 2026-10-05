local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)

local function drawCheckbox(p, p2, p3, flag: boolean)
	local completed = Loader.isCompleted(p, p3.Path)
	local state = Osiris.State(completed)
	local checkbox = Osiris.Widget.Checkbox({
		Arguments = {
			Text = p3.Title
		},
		States = {
			isChecked = state
		}
	})

	if checkbox.checked() or checkbox.unchecked() then
		if flag then
			Loader.setCompletion(p, p2, p3.Path, state:get())
		else
			state:set(completed)
		end
	elseif state:get() ~= completed then
		state:set(completed)
	end
end

local function drawChildren(store, driver, p, canComplete: boolean)
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
			Text = "Subtasks"
		}
	})

	for _, v in children do
		Osiris.PushId(v.Path)
		local progress, v2 = Loader.getProgress(store, driver, v.Path)
		local v3

		if v.Children == nil then
			v3 = false
		else
			v3 = #v.Children > 0
		end

		local v4 = v
		Osiris.Widget.SameLine({}, function()
			drawCheckbox(store, driver, v4, canComplete)

			if v3 then
				Osiris.Widget.Text({
					Arguments = {
						Text = Present.progressText(progress, v2),
						Color = Present.progressColor(progress, v2)
					}
				})
			end
		end)
		Osiris.PopId()
	end
end

return function(p)
	local store = p.Store
	local driver = p.Driver
	local v = store.permissions:get()
	local canComplete

	if v == nil then
		canComplete = false
	else
		canComplete = v.CanComplete
	end

	local v2 = store.build:get()

	if v2 then
		Present.note((`branch {v2.Branch} @ {v2.Sha}`))
	end

	local v3 = store.selectedPath:get()

	if v3 == nil then
		Present.note("select a task in the navigator to mark it complete")
		return
	end

	local v4 = store.tasks:get()[v3]

	if v4 == nil then
		Present.note("loading...")
		return
	end

	Osiris.PushId(v4.Path)
	local progress, v5 = Loader.getProgress(store, driver, v4.Path)
	local completion = Loader.getCompletion(store, v4.Path)
	local v6 = completion ~= nil
	local v7

	if v4.Children == nil then
		v7 = false
	else
		v7 = #v4.Children > 0
	end

	Osiris.Widget.Text({
		Arguments = {
			Text = v4.Title,
			Wrapped = true
		}
	})
	Osiris.Widget.Text({
		Arguments = {
			Text = v4.Path,
			Color = Present.MUTED,
			Wrapped = true
		}
	})
	local assignment = Loader.getAssignment(store, v4.Path)

	if assignment then
		local v8 = assignment.UserId == driver.LocalUserId
		Osiris.Widget.Text({
			Arguments = {
				Text = v8 and "assigned to you" or Present.assignmentLabel(assignment),
				Color = Present.WARN
			}
		})
	end

	Osiris.Widget.Separator({})
	Osiris.Widget.Text({
		Arguments = {
			Text = Present.statusLabel(progress, v5),
			Color = Present.progressColor(progress, v5)
		}
	})

	if completion then
		Present.note(Present.completionLabel(completion))
	end

	if v7 then
		local state = Osiris.State(0)
		state:set(not (v5 > 0) and 0 or progress / v5)
		Osiris.Widget.ProgressBar({
			Arguments = {
				Text = "subtasks",
				Format = Present.progressText(progress, v5)
			},
			States = {
				progress = state
			}
		})
	end

	if canComplete then
		Osiris.Widget.SameLine({}, function()
			if v7 then
				if Osiris.Widget.Button({
					Arguments = {
						Text = "mark all complete"
					}
				}).clicked() then
					Loader.setCompletion(store, driver, v4.Path, true)
				end

				if Osiris.Widget.Button({
					Arguments = {
						Text = "mark all incomplete"
					}
				}).clicked() then
					Loader.setCompletion(store, driver, v4.Path, false)
				end
			elseif Osiris.Widget.Button({
				Arguments = {
					Text = v6 and "mark incomplete" or "mark complete"
				}
			}).clicked() then
				Loader.setCompletion(store, driver, v4.Path, not v6)
			end
		end)
	else
		Present.note("you can view tasks but not complete them")
	end

	drawChildren(store, driver, v4, canComplete)
	Osiris.PopId()
end