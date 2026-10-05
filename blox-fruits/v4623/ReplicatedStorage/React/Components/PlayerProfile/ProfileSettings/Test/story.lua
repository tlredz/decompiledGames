local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
GlobalUtil.FFlags.__DEV__ = false
GlobalUtil.FFlags.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Types = require(game.ReplicatedStorage.React.Components.PlayerProfile.Types)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	local state, _ = React.useState(Types.LoadedPlayer.random(tick() % 100000))
	return createElement(React.Fragment, {}, {
		parent = createElement(parentModule, {
			SetLoadedPlayer = function()
				print("SetLoadedPlayer")
			end,
			PatchProfileData = function(_) end,
			SetSettingsVisible = function(flag: boolean)
				print("SetStatSelectionVisible", flag)
			end,
			LoadedPlayer = state
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