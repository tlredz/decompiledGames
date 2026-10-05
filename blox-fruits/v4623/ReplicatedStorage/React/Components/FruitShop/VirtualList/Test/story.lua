local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(parentModule, {
			Size = UDim2.fromScale(0.7, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.fromOffset(0, 3000),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			ItemProperties = {},
			ItemConstructor = function(p2)
				local windowRegionPx = p2.WindowRegionPx
				local v = windowRegionPx.Min.Y - windowRegionPx.Min.Y % 150
				local children = {}

				repeat
					children[`card-{math.round(v)}`] = createElement("Frame", {
						Size = UDim2.fromOffset(windowRegionPx.Max.X - windowRegionPx.Min.X, 150),
						Position = UDim2.fromOffset(windowRegionPx.Min.X, v),
						BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						LayoutOrder = 0,
						Active = false
					})
					v += 155
				until windowRegionPx.Max.Y < v

				return createElement(React.Fragment, {}, children)
			end
		}), p)))
	end)
	return function()
		root:unmount()
	end
end