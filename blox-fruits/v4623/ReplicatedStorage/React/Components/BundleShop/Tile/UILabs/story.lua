local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Tile = require(game.ReplicatedStorage.React.Components.BundleShop.Tile)
local names = { "None" }

for _, child in script.Parent:GetChildren() do
	if child ~= script then
		table.insert(names, child.Name)
	end
end

table.freeze(names)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Tile1 = UILabs.Choose(names, 1),
		Tile2 = UILabs.Choose(names, 1),
		Tile3 = UILabs.Choose(names, 1),
		Tile4 = UILabs.Choose(names, 1)
	}
}, function(p)
	local tile1 = p.controls.Tile1
	local tile2 = p.controls.Tile2
	local tile3 = p.controls.Tile3
	local tile4 = p.controls.Tile4
	local v3 = {
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(600, 150)
	}
	local v4 = {
		UIFlexibleLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		}),
		Tile1 = 0,
		Tile2 = 0,
		Tile3 = 0,
		Tile4 = 0
	}
	local tile

	if tile1 ~= "None" then
		tile = createElement(Tile, {
			Type = tile1,
			LayoutOrder = 1,
			OnClick = function(p2: number)
				print("Clicked tile with redeemableId:", p2)
			end
		}, {})
	end

	v4.Tile1 = tile
	local tile5

	if tile2 ~= "None" then
		tile5 = createElement(Tile, {
			Type = tile2,
			LayoutOrder = 2,
			OnClick = function(p2: number)
				print("Clicked tile with redeemableId:", p2)
			end
		}, {})
	end

	v4.Tile2 = tile5
	local tile6

	if tile3 ~= "None" then
		tile6 = createElement(Tile, {
			Type = tile3,
			LayoutOrder = 3,
			OnClick = function(p2: number)
				print("Clicked tile with redeemableId:", p2)
			end
		}, {})
	end

	v4.Tile3 = tile6
	local tile7

	if tile4 ~= "None" then
		tile7 = createElement(Tile, {
			Type = tile4,
			LayoutOrder = 4,
			OnClick = function(p2: number)
				print("Clicked tile with redeemableId:", p2)
			end
		}, {})
	end

	v4.Tile4 = tile7
	return createElement("Frame", v3, v4)
end)