local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
require(script.Parent.Types)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(nil)
	return createElement(parentModule, {
		IsOpen = state,
		SetIsOpen = setState,
		IsReforging = false,
		Item1 = state2,
		Item2 = state3,
		Item3 = state4,
		SetItemInSlot = React.useCallback(function(p: number, p2)
			if p == 1 then
				setState2(p2)
			elseif p == 2 then
				setState3(p2)
			elseif p == 3 then
				setState4(p2)
			end
		end)
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