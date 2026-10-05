local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Styles)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function loadingComponent(_)
	return createElement(React.Fragment, {}, {
		LoadingIcon = createElement(parentModule, {
			Size = UDim2.fromOffset(300, 300),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Speed = 1,
			Scale = 1,
			IsAnimated = true,
			IsOpen = true,
			OnCloseComplete = function()
				print("closed")
			end,
			ImageTransparency = CONSTANTS.ALPHA.OPAQUE
		})
	})
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(loadingComponent, {}), p)))
	end)
	return function()
		root:unmount()
	end
end