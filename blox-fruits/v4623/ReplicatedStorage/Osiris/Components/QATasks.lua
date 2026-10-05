local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Admin = require(game.ReplicatedStorage.Osiris.Components.QATasks.Admin)
local Browser = require(game.ReplicatedStorage.Osiris.Components.QATasks.Browser)
local Completion = require(game.ReplicatedStorage.Osiris.Components.QATasks.Completion)
local Detail = require(game.ReplicatedStorage.Osiris.Components.QATasks.Detail)
local Editor = require(game.ReplicatedStorage.Osiris.Components.QATasks.Editor)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
local Store = require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)

local function drawMessage(p)
	local text2 = p.message:get()

	if text2 == nil then
		return
	end

	Osiris.Widget.SameLine({}, function()
		local text = Osiris.Widget.Text
		local arguments = {
			Text = text2,
			Color = 0,
			Wrapped = true
		}
		local color

		if p.messageIsError:get() then
			color = Present.BAD
		else
			color = Present.GOOD
		end

		arguments.Color = color
		text({
			Arguments = arguments
		})

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "x"
			}
		}).clicked() then
			Store.setMessage(p, nil)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drawAccessGate(p)
	local v = p.permissions:get()

	if v == nil then
		Present.note("checking access...")
		return false
	end

	if v.CanRead then
		return true
	end

	Present.error("you do not have QA access")
	return false
end

return {
	Loader = Loader,
	Store = Store,
	Component = function(data)
		local driver = data.Driver
		local store = Store.use(data.Arguments, data.States)
		Loader.loadPermissions(store, driver)
		local isOpen = store.isOpen

		if not isOpen:get() then
			return store
		end

		local title = store.Arguments.Title or "QA Tasks"
		Loader.loadState(store, driver)
		Osiris.Widget.Window({
			Arguments = {
				Title = title
			},
			States = {
				position = store.navigatorPosition,
				size = store.navigatorSize,
				isOpened = isOpen
			}
		}, function()
			-- equivalent call inferred; original call site unknown
			if not drawAccessGate(store) then
				return
			end

			drawMessage(store)
			Browser({
				Store = store,
				Driver = driver
			})
		end)
		Osiris.Widget.Window({
			Arguments = {
				Title = `{title} - details`,
				NoClose = true
			},
			States = {
				position = store.detailPosition,
				size = store.detailSize
			}
		}, function()
			-- equivalent call inferred; original call site unknown
			if not drawAccessGate(store) then
				return
			end

			Detail({
				Store = store,
				Driver = driver
			})
		end)
		Osiris.Widget.Window({
			Arguments = {
				Title = `{title} - completion`,
				NoClose = true
			},
			States = {
				position = store.completionPosition,
				size = store.completionSize
			}
		}, function()
			-- equivalent call inferred; original call site unknown
			if not drawAccessGate(store) then
				return
			end

			Completion({
				Store = store,
				Driver = driver
			})
		end)
		local v2 = store.permissions:get()

		if v2 ~= nil and v2.CanWrite then
			Osiris.Widget.Window({
				Arguments = {
					Title = `{title} - admin`,
					NoClose = true
				},
				States = {
					position = store.adminPosition,
					size = store.adminSize
				}
			}, function()
				Admin({
					Store = store,
					Driver = driver
				})
			end)
		end

		local v3 = store.editor:get()

		if v3 == nil or v3.Mode == "None" then
			return store
		end

		local state = Osiris.State(true)

		if state:get() then
			local window = Osiris.Widget.Window
			local title2

			if v3.Mode == "Edit" then
				title2 = `{title} - edit task`
			else
				title2 = `{title} - new task`
			end

			window({
				Arguments = {
					Title = title2
				},
				States = {
					position = store.editorPosition,
					size = store.editorSize,
					isOpened = state
				}
			}, function()
				Editor({
					Store = store,
					Driver = driver
				})
			end)
		else
			state:set(true)
			Loader.closeEditor(store)
			return store
		end

		return store
	end
}