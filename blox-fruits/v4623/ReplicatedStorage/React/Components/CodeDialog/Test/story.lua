local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
GlobalUtil.FFlags.__REACT_MICROPROFILER_LEVEL = 10
GlobalUtil.FFlags.__DEV__ = false
GlobalUtil.FFlags.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState(nil)
	return createElement(parentModule, {
		OnSubmitCode = function(p: string)
			setState2((`Code "{p}" is not valid.`))
		end,
		ErrorMessage = state2,
		IsOpen = state,
		OnCloseClick = function()
			setState(false)
		end
	}, {})
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