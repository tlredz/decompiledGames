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
	local stats = React.useMemo(function()
		local random = Random.new(state.UserId)
		local result = {}

		for _ = 1, random:NextInteger(3, 5) do
			local random2 = Types.PlayerStatOptionProperties.random(random:NextInteger(1000, 100000))
			random2.LoadedPlayer = state
			table.insert(result, random2)
		end

		return result
	end, { state })
	return createElement(React.Fragment, {}, {
		parent = createElement(parentModule, {
			SelectedStatSlotId = 0,
			SetLoadedPlayer = function()
				print("SetLoadedPlayer")
			end,
			PatchProfileData = function(_) end,
			SetStatSelectionVisible = function(flag: boolean)
				print("SetStatSelectionVisible", flag)
			end,
			LoadedPlayer = state,
			Stats = stats
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