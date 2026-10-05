local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {}

for _, v2 in ItemConfig.Query.select({
	Index = {
		IdType = "Skin"
	}
}) do
	local nullable = Skin.Definition.Recipe.match(v2.Index.ItemId):asNullable()

	if nullable then
		table.insert(v, {
			ItemId = v2.Index.ItemId,
			Definition = nullable
		})
	end
end

local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		RecipeIndex = UILabs.Slider(1, 1, math.max(1, #v), 1),
		OwnedFraction = UILabs.Slider(0.5, 0, 1, 0.1)
	}
}, function(p)
	local v2 = v[p.controls.RecipeIndex]
	local craftingInventory = React.useMemo(function()
		local result = {}

		if not v2 then
			return result
		end

		for k, ingredient in v2.Definition.Ingredients do
			result[k] = math.floor(ingredient * p.controls.OwnedFraction)
		end

		return result
	end, { v2, p.controls.OwnedFraction })
	local v6 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(74, 74, 74),
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.5, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}
	local recipe

	if v2 then
		recipe = createElement(parentModule, {
			Definition = v2.Definition,
			CraftingInventory = craftingInventory
		})
	end

	return createElement("Frame", v6, {
		Recipe = recipe
	})
end)