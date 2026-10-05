local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.React.Components.PlayerProfile.Types)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(script.Parent.CONSTANTS)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState(CONSTANTS2.DEFAULT_LOADED_PLAYER)
	local state3, setState3 = React.useState("Profile")
	local state4, setState4 = React.useState(false)
	local state5, setState5 = React.useState(false)
	local state6, setState6 = React.useState(false)
	local state7, _ = React.useState({
		{
			DisplayName = "Test Stat 1",
			StatId = 1,
			Progression = 5,
			MaxProgression = 10,
			LoadedPlayer = state2,
			SelectedStatSlotId = 1,
			SetSelectedStatSlotId = function(_: number) end,
			SetStatSelectionVisible = function(_: boolean) end,
			SetLoadedPlayer = function(_: number?) end,
			PatchProfileData = function(_) end
		},
		{
			DisplayName = "Test Stat 2",
			StatId = 2,
			Progression = 3,
			MaxProgression = 15,
			LoadedPlayer = state2,
			SelectedStatSlotId = 1,
			SetSelectedStatSlotId = function(_: number) end,
			SetStatSelectionVisible = function(_: boolean) end,
			SetLoadedPlayer = function(_: number?) end,
			PatchProfileData = function(_) end
		}
	})
	local state8, setState7 = React.useState(TableUtil.deepCopy(CONSTANTS2.DEFAULT_PROFILE_DATA))
	local v = { (React.useMemo(function()
			return {}
		end)) }
	local inventoryItems = React.useMemo(function()
		return {}
	end, v)
	local callback = React.useCallback(function(_: number?)
		local random = Types.LoadedPlayer.random(tick() % 100000)
		setState2(random)
		setState7(random.ProfileData)
	end, { state8 })
	React.useEffect(function()
		callback()
	end, {})
	return createElement(React.Fragment, {}, {
		frame = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}),
		playerProfile = createElement(parentModule, {
			IsOpen = state,
			SetIsOpen = setState,
			Category = state3,
			SetCategory = setState3,
			StatSelectionVisible = state6,
			Stats = state7,
			SetStatSelectionVisible = setState6,
			StatusSelectionVisible = state5,
			SetStatusSelectionVisible = setState5,
			SettingsVisible = state4,
			SetSettingsVisible = setState4,
			LoadedPlayer = state2,
			SetLoadedPlayer = callback,
			PatchProfileData = function(_) end,
			ClearNewBackground = function(_: string) end,
			OnExit = function() end,
			IsLoading = false,
			InventoryItems = inventoryItems
		})
	})
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(component, {}), p)))
	end)
	return function()
		root:unmount()
	end
end