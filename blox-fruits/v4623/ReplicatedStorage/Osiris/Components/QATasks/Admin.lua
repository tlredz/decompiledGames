local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)

local function confirmButton(text: string, text2: string, fn)
	Osiris.PushId(text)
	local state = Osiris.State(false)

	if state:get() then
		Osiris.Widget.SameLine({}, function()
			Osiris.Widget.Text({
				Arguments = {
					Text = text2,
					Color = Present.BAD
				}
			})

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "yes"
				}
			}).clicked() then
				state:set(false)
				fn()
			end

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "cancel"
				}
			}).clicked() then
				state:set(false)
			end
		end)
	elseif Osiris.Widget.Button({
		Arguments = {
			Text = text
		}
	}).clicked() then
		state:set(true)
	end

	Osiris.PopId()
end

return function(p)
	local store = p.Store
	local driver = p.Driver
	local v = store.build:get()

	if v then
		Present.stat("branch", v.Branch)
		Present.stat("build", v.Sha)
	end

	Present.note("completion state is stored per branch; resets only affect this branch")
	local filtered = Loader.isFiltered(store)

	if filtered then
		Osiris.Widget.Text({
			Arguments = {
				Text = "a filter is active: every action below only touches tasks that match it",
				Color = Present.WARN,
				Wrapped = true
			}
		})
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Reset"
		}
	})
	confirmButton(
		filtered and "reset every matching task" or "reset every task",
		filtered and "clear completions of every task matching the filter?" or "clear all completions on this branch?",
		function()
			Loader.resetAll(store, driver)
		end
	)
	local v2 = store.selectedPath:get()

	if v2 == nil then
		Present.note("select a task to reset it and its subtasks")
	else
		local v3 = store.tasks:get()[v2]
		local v4

		if v3 then
			v4 = v3.Title
		else
			v4 = v2
		end

		confirmButton(`reset "{v4}" + subtasks`, `clear completions under {v2}?`, function()
			Loader.resetSubtree(store, driver, v2)
		end)
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = filtered and "Completions by build (filtered)" or "Completions by build"
		}
	})
	Loader.loadShaSummary(store, driver)
	local v3 = store.shaSummary:get()

	if Osiris.Widget.SmallButton({
		Arguments = {
			Text = "refresh"
		}
	}).clicked() then
		store.shaSummary:set(nil)
	end

	if v3 == nil then
		Present.note("loading...")
	elseif #v3 == 0 then
		Present.note("nothing has been completed on this branch yet")
	else
		Osiris.Widget.Table({
			Arguments = {
				NumColumns = 4,
				Header = true,
				RowBackground = true,
				InnerBorders = false,
				OuterBorders = false
			}
		}, function(data)
			data.NextHeaderColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = "sha"
				}
			})
			data.NextHeaderColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = "done"
				}
			})
			data.NextHeaderColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = "first completed"
				}
			})
			data.NextHeaderColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = ""
				}
			})

			for _, v4 in v3 do
				Osiris.PushId((`sha-{v4.Sha}`))
				data.NextRow()
				data.NextColumn()
				local text = Osiris.Widget.Text
				local arguments = {
					Text = v4.Sha,
					Color = 0
				}
				local color

				if v and v.Sha == v4.Sha then
					color = Present.GOOD
				end

				arguments.Color = color
				text({
					Arguments = arguments
				})
				data.NextColumn()
				Osiris.Widget.Text({
					Arguments = {
						Text = tostring(v4.Count)
					}
				})
				data.NextColumn()
				Osiris.Widget.Text({
					Arguments = {
						Text = Present.formatTimestamp(v4.EarliestTimestamp)
					}
				})
				data.NextColumn()

				if Osiris.Widget.SmallButton({
					Arguments = {
						Text = "reset"
					}
				}).clicked() then
					Loader.resetSha(store, driver, v4.Sha)
				end

				Osiris.PopId()
			end
		end)
	end
end