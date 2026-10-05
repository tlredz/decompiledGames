local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local mapIds = ItemConfig.mapIds(ItemConfig.Query.select({
	Index = {
		IdType = "Skin"
	},
	Skin = {
		IsDefault = false
	}
}))
local v = {}

for _, v2 in ItemConfig.Query.select({
	Index = {
		IdType = "Skin"
	}
}) do
	local nullable = Skin.Definition.Recipe.match(v2.Index.ItemId):asNullable()

	if not nullable then
		continue
	end

	for k, _ in nullable.Ingredients do
		table.insert(v, k)
	end
end

TableUtil.deduplicate(v)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SelectedIndex = UILabs.Slider(1, 1, #mapIds, 1),
		Owned = UILabs.Slider(3, 0, #mapIds, 1),
		Unlocked = UILabs.Slider(5, 0, #mapIds, 1),
		Ingredients = UILabs.Slider(5, 0, #v * 10, 1)
	}
}, function(p)
	local owned = React.useMemo(function()
		local clone = table.clone(mapIds)
		TableUtil.randomize(clone, 123)
		local result = {}

		for i = 1, math.min(#clone, p.controls.Owned) do
			table.insert(result, clone[i])
		end

		return result
	end, { p.controls.Owned })
	local unlocked = React.useMemo(function()
		local clone = table.clone(mapIds)
		TableUtil.randomize(clone, 123)
		local result = {}

		for k, _ in clone do
			if k < #owned then
				continue
			end

			if #result > p.controls.Unlocked then
				break
			else
				table.insert(result, clone[k])
			end
		end

		return result
	end, { p.controls.Unlocked, owned })
	local craftingInventory = React.useMemo(function()
		local random = Random.new(123)
		local result = {}
		local count = 0

		while true do
			local v5 = v[random:NextInteger(1, #v)]
			local unwrapped = ItemConfig.match(v5):unwrap()
			local v6 = result[v5]

			if v6 then
				if not (unwrapped.Inventory.MaxStack and v6 + 1 > unwrapped.Inventory.MaxStack) then
					result[v5] += 1
					count += 1
				end
			else
				result[v5] = 1
				count += 1
			end

			if p.controls.Ingredients < count then
				return result
			end
		end
	end, { p.controls.Ingredients })
	local mapId = mapIds[p.controls.SelectedIndex]
	local selection = React.useMemo(function()
		if mapId then
			return {
				ItemId = mapId
			}
		end

		return nil
	end, { mapId })
	local setSelection = React.useCallback(function(_: number?, _: string?) end, {})
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(74, 74, 74),
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.5, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		ItemSelectionContext = createElement(ItemSelection.Provider, {
			value = {
				Selection = selection,
				SetSelection = setSelection
			}
		}, {
			Menu = createElement(parentModule, {
				Unlocked = unlocked,
				Owned = owned,
				CraftingInventory = craftingInventory,
				OnAction = function(p2)
					print("action", p2)
				end
			})
		})
	})
end)