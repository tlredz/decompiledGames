local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local parentModule = require(script.Parent)
local v = { "None" }

for _, v2 in RarityUtil.VALUE_TO_TYPE do
	table.insert(v, v2)
end

table.freeze(v)
local v2 = {}

for k, _ in Spritesheets.MAP do
	table.insert(v2, k)
end

table.sort(v2)
table.insert(v2, 1, "None")
table.freeze(v2)
local v3 = {}

for _, v4 in AccessoriesShared.MODIFIER_LIST do
	table.insert(v3, v4)
end

table.sort(v3)
table.insert(v3, 1, "None")
table.freeze(v3)
local v4 = { "None" }

for _, v5 in PseudoEnum.InventoryTileOverlay do
	table.insert(v4, v5)
end

table.freeze(v4)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SizePx = UILabs.Slider(300, 50, math.round(workspace.CurrentCamera.ViewportSize.X), 10),
		Variant = UILabs.Choose({ "Fade", "Elevated", "Display" }, 2),
		TileAppearance = UILabs.Choose(PseudoEnum.getEnumItems("InventoryTileAppearance"), 1),
		OutlineAppearance = UILabs.Choose(PseudoEnum.getEnumItems("InventoryOutlineAppearance"), 1),
		RibbonText = "",
		Icon = UILabs.Choose(v2, 1),
		IconBorder = UILabs.Slider(0, 0, 75, 1),
		IconOutline = UILabs.Choose(v2, 1),
		IconCorner = UILabs.Choose(v2, 1),
		IconCategory = UILabs.Choose(v2, 1),
		Overlay1 = UILabs.Choose(v4, 1),
		Overlay2 = UILabs.Choose(v4, 1),
		Modifier1 = UILabs.Choose(v3, 1),
		Modifier2 = UILabs.Choose(v3, 1),
		UpgradeCount = UILabs.Slider(0, 0, 5, 1),
		Rarity = UILabs.Choose(v, 1),
		Quantity = UILabs.Slider(1, 1, 64, 1),
		CornerRadiusScale = UILabs.Slider(0, 0, 50, 1),
		IsEquipped = false,
		IsSelected = false,
		IsFavorited = false,
		WasRecentlyReceived = false,
		IsPurchase = false,
		IsPermanent = false,
		IsTrinket = false,
		Title = "Example Item",
		Category = "Example Category"
	}
}, function(p)
	local sizePx = p.controls.SizePx
	local sizePx2 = p.controls.SizePx
	local quantity = p.controls.Quantity
	local upgradeCount

	if p.controls.UpgradeCount ~= 0 then
		upgradeCount = p.controls.UpgradeCount
	end

	local isEquipped = p.controls.IsEquipped
	local variant = p.controls.Variant
	local isSelected = p.controls.IsSelected
	local rarity = p.controls.Rarity
	local wasRecentlyReceived = p.controls.WasRecentlyReceived
	local title = p.controls.Title
	local category = p.controls.Category
	local icon

	if p.controls.Icon ~= "None" then
		icon = p.controls.Icon
	end

	local iconBorder

	if p.controls.IconBorder ~= 0 then
		iconBorder = p.controls.IconBorder
	end

	local iconOutline

	if p.controls.IconOutline ~= "None" then
		iconOutline = p.controls.IconOutline
	end

	local iconCorner

	if p.controls.IconCorner ~= "None" then
		iconCorner = p.controls.IconCorner
	end

	local iconCategory

	if p.controls.IconCategory ~= "None" then
		iconCategory = p.controls.IconCategory
	end

	local isTrinket = p.controls.IsTrinket
	local isPermanent = p.controls.IsPermanent
	local isPurchase = p.controls.IsPurchase
	local cornerRadiusScale = p.controls.CornerRadiusScale
	local overlay1

	if p.controls.Overlay1 ~= "None" then
		overlay1 = p.controls.Overlay1
	end

	local overlay2

	if p.controls.Overlay2 ~= "None" then
		overlay2 = p.controls.Overlay2
	end

	local overlays = {}

	if overlay1 then
		table.insert(overlays, overlay1)
	end

	if overlay2 then
		table.insert(overlays, overlay2)
	end

	local modifier1

	if p.controls.Modifier1 ~= "None" then
		modifier1 = p.controls.Modifier1
	end

	local modifier2

	if p.controls.Modifier2 ~= "None" then
		modifier2 = p.controls.Modifier2
	end

	local modifiers = {}

	if modifier1 then
		table.insert(modifiers, modifier1)
	end

	if modifier2 then
		table.insert(modifiers, modifier2)
	end

	local fragment = React.Fragment
	local v13 = {
		Title = title,
		Category = category,
		IsEquipped = isEquipped,
		Quantity = quantity,
		CornerRadius = UDim.new(cornerRadiusScale / 100, 0),
		Icon = icon and Spritesheets.MAP[icon],
		CornerIcon = iconCorner and Spritesheets.MAP[iconCorner],
		IconBorderThickness = iconBorder,
		IsPermanent = isPermanent,
		OutlineIcon = iconOutline and Spritesheets.MAP[iconOutline],
		Overlays = overlays
	}

	if rarity == "None" then
		rarity = nil
	end

	v13.Rarity = rarity
	v13.IsTrinket = isTrinket

	if not (#modifiers > 0) then
		modifiers = nil
	end

	v13.Modifiers = modifiers
	v13.Upgrades = upgradeCount
	v13.Variant = variant
	v13.IsSelected = isSelected
	v13.IsPurchase = isPurchase
	v13.IsFavorited = p.controls.IsFavorited
	local ribbonText

	if p.controls.RibbonText:len() > 0 then
		ribbonText = p.controls.RibbonText
	end

	v13.RibbonText = ribbonText
	v13.OutlineAppearance = p.controls.OutlineAppearance
	v13.TileAppearance = p.controls.TileAppearance
	v13.WasRecentlyReceived = wasRecentlyReceived
	v13.CategoryIcon = iconCategory and Spritesheets.MAP[iconCategory]
	v13.Position = UDim2.fromScale(0.5, 0.5)
	v13.DrawContext = "Default"
	v13.AnchorPoint = Vector2.new(0.5, 0.5)
	v13.AutomaticSize = Enum.AutomaticSize.None
	v13.Size = UDim2.fromOffset(sizePx2, sizePx)

	v13[React.Event.Activated] = function()
		print("click")
	end

	return createElement(fragment, {}, {
		{
			Tile = createElement(parentModule, v13)
		}
	})
end)