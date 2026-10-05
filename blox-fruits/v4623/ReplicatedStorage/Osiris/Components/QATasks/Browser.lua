local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local QATask = require(game.ReplicatedStorage.Definitions.QATask)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
local Store = require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local pathUtil = QATask.PathUtil
local selectionArray = { Store.ANY_TAG }

for _, v2 in QATask.Types.TAGS do
	table.insert(selectionArray, v2)
end

table.freeze(selectionArray)

local function drawBreadcrumb(store, driver)
	local v2 = store.currentPath:get()
	Osiris.Widget.SameLine({}, function()
		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "all"
			}
		}).clicked() then
			Loader.navigate(store, driver, nil)
		end

		if v2 == nil then
			return
		end

		local parts = pathUtil.split(v2)
		local joined = nil

		for k, title in parts do
			joined = pathUtil.join(joined, title)
			local v3 = store.tasks:get()[joined]

			if v3 then
				title = v3.Title
			end

			Osiris.Widget.Text({
				Arguments = {
					Text = ">",
					Color = Present.MUTED
				}
			})
			Osiris.PushId((`crumb-{k}`))

			if k == #parts then
				Osiris.Widget.Text({
					Arguments = {
						Text = title
					}
				})
			elseif Osiris.Widget.SmallButton({
				Arguments = {
					Text = title
				}
			}).clicked() then
				Loader.navigate(store, driver, joined)
			end

			Osiris.PopId()
		end
	end)
end

local function drawRow(p, p2, data)
	local v2 = p.selectedPath:get() == data.Path
	local progress, v3, v4 = Loader.getProgress(p, p2, data.Path)
	local v5

	if data.Children == nil then
		v5 = false
	else
		v5 = #data.Children > 0
	end

	local assignment = Loader.getAssignment(p, data.Path)
	Osiris.PushId(data.Path)
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.Text({
			Arguments = {
				Text = Present.statusGlyph(progress, v3),
				Color = Present.progressColor(progress, v3)
			}
		})
		Present.icon(data)
		local smallButton = Osiris.Widget.SmallButton
		local text

		if v2 then
			text = `> {data.Title}`
		else
			text = data.Title
		end

		local v9 = smallButton({
			Arguments = {
				Text = text
			}
		})

		if v9.clicked() then
			Loader.select(p, p2, data.Path)
		end

		if v9.doubleClicked() and v5 then
			Loader.navigate(p, p2, data.Path)
		end

		if v5 then
			Osiris.Widget.Text({
				Arguments = {
					Text = not v4 and "…" or Present.progressText(progress, v3),
					Color = Present.progressColor(progress, v3)
				}
			})

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "open"
				}
			}).clicked() then
				Loader.navigate(p, p2, data.Path)
			end
		end

		if assignment then
			Osiris.Widget.Text({
				Arguments = {
					Text = `@{assignment.UserName}`,
					Color = Present.WARN
				}
			})
		end

		if data.Source == "Custom" then
			Osiris.Widget.Text({
				Arguments = {
					Text = "custom",
					Color = Present.ACCENT
				}
			})
		end
	end)
	Osiris.PopId()
end

local function drawLevel(store, driver, p)
	Loader.ensureChildren(store, driver, p)
	local children = Loader.getChildren(store, p)

	if children == nil then
		Present.note("loading...")
	elseif #children == 0 then
		if Loader.isFiltered(store) then
			Present.note("nothing under this level matches the filter")
		else
			Present.note("no tasks at this level")
		end
	else
		for _, v2 in children do
			drawRow(store, driver, v2)
		end
	end
end

return function(p)
	local store = p.Store
	local driver = p.Driver
	local v2 = store.permissions:get()
	local canWrite

	if v2 == nil then
		canWrite = false
	else
		canWrite = v2.CanWrite
	end

	local v3 = store.currentPath:get()
	Loader.syncFilter(store, driver)
	drawBreadcrumb(store, driver)
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.InputText({
			Arguments = {
				Text = "",
				TextHint = "filter by title, tag or description"
			},
			States = {
				text = store.filter
			}
		})

		if canWrite and Osiris.Widget.SmallButton({
			Arguments = {
				Text = "+ task"
			}
		}).clicked() then
			Loader.openCreate(store, v3)
		end

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "refresh"
			}
		}).clicked() then
			Loader.refreshAll(store, driver)
		end
	end)
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.ComboArray({
			Arguments = {
				Text = "tag"
			},
			States = {
				index = store.tagFilter
			},
			Extra = {
				selectionArray = selectionArray
			}
		})
		Osiris.Widget.Checkbox({
			Arguments = {
				Text = "assigned to me"
			},
			States = {
				isChecked = store.onlyMine
			}
		})

		if Loader.isFiltered(store) and Osiris.Widget.SmallButton({
			Arguments = {
				Text = "clear filter"
			}
		}).clicked() then
			Loader.clearFilter(store)
		end
	end)
	Osiris.Widget.Separator({})

	if Loader.isFiltered(store) then
		Osiris.Widget.Text({
			Arguments = {
				Text = "filter active: the tree, progress and every reset / assign action are scoped to matching tasks",
				Color = Present.WARN,
				Wrapped = true
			}
		})
	else
		Present.note("select a task to see its details, use the completion panel to mark it done")
	end

	drawLevel(store, driver, v3)
end