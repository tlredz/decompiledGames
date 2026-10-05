local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local parentModule = require(script.Parent)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local itemIdsByStorageKey = {}
local storageKeys = {}

for _, v in ItemConfig.Query.select({
	Index = {
		IdType = "Moveset"
	}
}) do
	local itemId = v.Index.ItemId
	local dataFromId = ItemId.getDataFromId(itemId)

	if dataFromId:isErr() then
		continue
	end

	local storageKey = dataFromId:unwrap().StorageKey

	if itemIdsByStorageKey[storageKey] then
		continue
	end

	itemIdsByStorageKey[storageKey] = itemId
	table.insert(storageKeys, storageKey)
end

table.sort(storageKeys)
table.freeze(storageKeys)
table.freeze(itemIdsByStorageKey)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Item = UILabs.Choose(storageKeys, 1),
		Variant = UILabs.Choose({ "Fade", "Elevated", "Display" }, 2),
		IsSelected = false,
		SizePx = UILabs.Slider(140, 40, 400, 1)
	}
}, function(p)
	local sizePx = p.controls.SizePx
	local itemId = itemIdsByStorageKey[p.controls.Item]
	local v8 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(sizePx * 1.5), (math.round(sizePx * 1.5)))
	}
	local buildTile

	if itemId ~= nil then
		buildTile = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(sizePx, sizePx),
			DrawContext = "Default",
			Variant = p.controls.Variant,
			IsSelected = p.controls.IsSelected,
			Selectable = true,
			Info = {
				ItemId = itemId
			},
			[React.Event.Activated] = function()
				print("activated", itemId)
			end
		})
	end

	return createElement(DrawContextProvider, {
		Context = "Default"
	}, {
		Panel = createElement("Frame", v8, {
			BuildTile = buildTile
		})
	})
end)