local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local parentModule = require(script.Parent)
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
		WidthPx = UILabs.Slider(270, 40, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(270, 40, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local itemId = itemIds[p.controls.Item]
	local selection = React.useMemo(function()
		if itemId == nil then
			return nil
		end

		return table.freeze({
			ItemId = itemId
		})
	end, { itemId })
	return createElement(ItemSelection.Provider, {
		value = {
			Selection = selection,
			SetSelection = function(p2: number?, p3: string?)
				print("select", p2, p3)
			end
		}
	}, {
		Display = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(widthPx, heightPx)
		})
	})
end)