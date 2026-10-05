local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Types = require(game.ReplicatedStorage.React.Components.Inventory.Types)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local storageKeys = {}

for _, v in ItemConfig.Query.select({
	Index = {
		IdType = "Moveset"
	}
}) do
	local itemId = v.Index.ItemId

	if ItemId.getDataFromId(itemId):isErr() or ItemConfig.match(itemId):isErr() then
		continue
	end

	table.insert(storageKeys, ItemId.getDataFromId(itemId):unwrap().StorageKey)
end

table.sort(storageKeys)
table.freeze(storageKeys)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SizeXPx = UILabs.Slider(300, 1, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		SizeYPx = UILabs.Slider(400, 1, math.round(workspace.CurrentCamera.ViewportSize.Y), 1),
		Variant = UILabs.Choose({ "Fade", "Elevated", "Display" }, 2),
		UpgradeCount = UILabs.Slider(0, 0, 5, 1),
		StorageKey = UILabs.Choose(storageKeys, math.random(1, #storageKeys)),
		Quantity = UILabs.Slider(1, 1, 64, 1),
		QuantityIsNull = false,
		IsEquipped = false,
		IsLocked = false,
		IsSelected = false
	}
}, function(p)
	local sizeXPx = p.controls.SizeXPx
	local sizeYPx = p.controls.SizeYPx
	local storageKey = p.controls.StorageKey
	local quantity

	if not p.controls.QuantityIsNull then
		quantity = p.controls.Quantity
	end

	local upgradeCount

	if p.controls.UpgradeCount ~= 0 then
		upgradeCount = p.controls.UpgradeCount
	end

	local isEquipped = p.controls.IsEquipped
	local isLocked = p.controls.IsLocked
	local variant = p.controls.Variant
	local isSelected = p.controls.IsSelected
	local info = React.useMemo(function()
		local v2 = {
			ItemId = ItemId.getId(storageKey, "Moveset"):unwrap()
		}
		TableUtil.deepFreeze(v2)
		assert(Types.Types.Tile.check(v2))
		return v2
	end, {
		storageKey,
		quantity,
		isEquipped,
		isLocked,
		upgradeCount
	})
	return createElement(React.Fragment, {}, {
		{
			Tile = createElement(parentModule, {
				Info = info,
				Variant = variant,
				IsSelected = isSelected,
				Position = UDim2.fromScale(0.5, 0.5),
				DrawContext = "Default",
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.fromOffset(sizeYPx, sizeXPx),
				[React.Event.Activated] = function()
					print("click")
				end
			})
		}
	})
end)