local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState({})
	React.useMemo(function()
		local v = {}

		for _, v2 in ItemConfig.Query.select({
			Index = {
				IdType = "Fish"
			}
		}) do
			local lowestWeight = math.random(1, 50)
			v[v2.Index.ItemId] = {
				CaughtCount = math.random(1, 100),
				LowestWeight = lowestWeight,
				HighestWeight = lowestWeight + math.random(1, 100)
			}
		end

		setState2(v)
	end, {})
	local state3, setState3 = React.useState(0)
	return createElement(parentModule, {
		IsOpen = state,
		SetIsOpen = setState,
		Fish = state2,
		CurrentFishIndex = state3,
		SetCurrentFish = setState3
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