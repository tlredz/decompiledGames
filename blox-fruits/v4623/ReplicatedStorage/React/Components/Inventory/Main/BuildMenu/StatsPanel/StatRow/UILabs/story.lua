local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local parentModule = require(script.Parent)
local useStats = require(game.ReplicatedStorage.React.Hooks.Item.useStats)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local itemIds = {}
local values = {}

for _, idType in ItemId.getTypes():unwrap() do
	for _, v2 in ItemConfig.Query.select({
		Index = {
			IdType = idType
		}
	}) do
		local itemId = v2.Index.ItemId
		local dataFromId = ItemId.getDataFromId(itemId)

		if dataFromId:isErr() then
			continue
		end

		local formatted = `{idType}: {dataFromId:unwrap().StorageKey}`

		if itemIds[formatted] then
			continue
		end

		itemIds[formatted] = itemId
		table.insert(values, formatted)
	end
end

table.sort(values)
table.freeze(values)
table.freeze(itemIds)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Item = UILabs.Choose(values, 1),
		StatIndex = UILabs.Slider(1, 1, 12, 1),
		WidthPx = UILabs.Slider(280, 80, 640, 1),
		HeightPx = UILabs.Slider(32, 12, 120, 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local statIndex = p.controls.StatIndex
	local v2 = useStats(itemIds[p.controls.Item], nil)
	local statValue

	if v2 then
		statValue = v2[math.min(statIndex, #v2)]
	end

	local v6 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(widthPx * 1.3), (math.round(heightPx * 4)))
	}
	local statRow

	if statValue ~= nil then
		statRow = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(widthPx, heightPx),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			StatValue = statValue
		})
	end

	local empty

	if statValue == nil then
		empty = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.2),
			Text = "No Stats",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		})
	end

	return createElement("Frame", v6, {
		StatRow = statRow,
		Empty = empty
	})
end)