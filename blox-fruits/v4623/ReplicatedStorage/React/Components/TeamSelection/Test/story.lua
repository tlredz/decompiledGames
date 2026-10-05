local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
GlobalUtil.FFlags.__DEV__ = false
GlobalUtil.FFlags.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	return createElement(parentModule, {})
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