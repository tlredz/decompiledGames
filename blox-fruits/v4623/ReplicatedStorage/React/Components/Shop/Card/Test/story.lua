local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	local tigerTiger1 = Spritesheets.MAP["Tiger-Tiger1"]
	assert(tigerTiger1, "bad sprite")
	return createElement(parentModule, {
		Title = "Title",
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#0054ff")),
			ColorSequenceKeypoint.new(0.2, Color3.fromHex("#00c6ff")),
			ColorSequenceKeypoint.new(0.6, Color3.fromHex("#00c6ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#0054ff"))
		}),
		Price = 123,
		ProductImage = tigerTiger1.Image,
		ProductImageOffset = tigerTiger1.ImageRectOffset,
		ProductImageSize = tigerTiger1.ImageRectSize,
		ProductGlow = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#FB6902")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#FFD50B"))
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 500, 0, 350),
		OnClick = function()
			print("ShopCard clicked")
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