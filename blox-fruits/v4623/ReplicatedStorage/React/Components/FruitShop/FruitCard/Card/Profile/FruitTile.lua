local React = require(game.ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local RaritySprites = require(game.ReplicatedStorage.Modules.Create.AssetComponent.RaritySprites)
local DragonAnimation = require(game.ReplicatedStorage.React.Components.FruitShop.FruitCard.Card.Profile.FruitTile.DragonAnimation)
local useOscillation = require(game.ReplicatedStorage.React.Hooks.Animation.useOscillation)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useSelectOne = require(game.ReplicatedStorage.React.Hooks.Item.Config.useSelectOne)
local useJoin = require(game.ReplicatedStorage.React.Hooks.Item.Config.useJoin)
local useKeyInfo = require(game.ReplicatedStorage.React.Hooks.Fruit.useKeyInfo)
local useRotationLock = require(game.ReplicatedStorage.React.Hooks.Animation.useRotationLock)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local broken_image = MaterialIconsHD.broken_image
local createElement = React.createElement

function getWiggle(p: number)
	return p * 1.5
end

return function(props)
	local v = useKeyInfo(props.FruitStorageKey)
	assert(v, (`bad fruit key: "{props.FruitStorageKey}"`))
	local physical = v.Physical
	local permanent = v.Permanent
	local isPermanent = v.IsPermanent
	local v2 = useSelectOne(React.useMemo(function()
		return {
			Index = {
				StorageKey = physical,
				IdType = "Moveset"
			}
		}
	end, { physical }))
	local formatted = `bad config: {physical}`
	assert(v2, formatted)
	local v3 = useJoin(React.useMemo(function()
		if v2.Moveset and v2.Moveset.Physical then
			return nil
		end

		return {
			Index = {
				IdType = "Moveset"
			},
			Moveset = {
				SkillRedirect = v2.Index.ItemId,
				Physical = {
					Operation = "NEQ",
					Value = nil
				}
			}
		}
	end, { v2 }))
	local v4 = React.useMemo(function()
		local clone = table.clone(v3)
		table.sort(clone, function(a, b)
			return (a.Index.StorageKey:find("East") and 2 or a.Index.StorageKey:find("West") and 1 or 0) > (b.Index.StorageKey:find("East") and 2 or b.Index.StorageKey:find("West") and 1 or 0)
		end)
		return clone
	end, { v3 })

	if #v4 > 0 then
		v2 = v4[#v4]
	end

	local v5 = useMatch(v2.Moveset and v2.Moveset.Physical)
	local v6 = useMatch(permanent, "Redeemable")
	assert(v6, (`bad config: "{permanent}"`))
	local sprite = v6.Display.Sprite
	local sprite2 = v5 and v5.Display.Sprite or broken_image
	local isFocused = props.IsFocused
	local isEquipped = props.IsEquipped
	local isSelected = props.IsSelected
	local v7 = props.Active == nil or props.Active
	local v8 = React.useMemo(function()
		local rarity = v2.Quality.Rarity or "Common"
		local unwrapped = RarityUtil.matchRarity(rarity):unwrap()
		local v9 = nil

		for k, background in pairs(RaritySprites.Backgrounds) do
			if unwrapped.Value ~= k then
				continue
			end

			v9 = background
			break
		end

		assert(v9, (`bad spriteInfo for rarity "{rarity}"`))
		return v9
	end, { v2.Quality.Rarity })
	local ref = React.useRef(nil)
	useRotationLock(ref.current, not props.IsFocused)
	local ref2 = React.useRef(nil)
	useRotationLock(ref2.current, not props.IsFocused)
	local frozen = table.freeze({
		Image = "rbxassetid://120434692968914",
		ImageRectOffset = v8.idle,
		ImageRectSize = RaritySprites.BACKGROUND_RECT_SIZE
	})
	local frozen2 = table.freeze({
		Image = "rbxassetid://120434692968914",
		ImageRectOffset = v8.hover,
		ImageRectSize = RaritySprites.BACKGROUND_RECT_SIZE
	})
	local v9 = isEquipped and 1 or 0
	local v11 = isSelected and 1 or 0
	local v12 = useOscillation(isFocused and not isSelected and v7, 0.25)
	local wiggle = getWiggle(v12)
	local v13 = physical == "Dragon-Dragon"
	local v14 = physical == "Control-Control"
	local v15 = (v13 or v14 or isPermanent) and true or false

	if isFocused then
		frozen = frozen2
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ZIndex = CONSTANTS.LAYER.RAISED
	}, props)
	local v20 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = (v15 or typeof(frozen.Image) ~= "string") and "rbxassetid://120434692968914" or frozen.Image,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		ScaleType = 0,
		SliceCenter = 0,
		SliceScale = 1,
		Size = 0,
		ZIndex = 0
	}
	local imageRectOffset

	if v15 then
		imageRectOffset = Vector2.new(0, 225)
	else
		imageRectOffset = frozen.ImageRectOffset
	end

	v20.ImageRectOffset = imageRectOffset
	local imageRectSize

	if v15 then
		imageRectSize = Vector2.new(218, 225)
	else
		imageRectSize = frozen.ImageRectSize
	end

	v20.ImageRectSize = imageRectSize
	v20.ScaleType = Enum.ScaleType.Slice
	v20.SliceCenter = Rect.new(109, 112, 109, 113)
	v20.Size = UDim2.fromScale(1, 1)
	v20.ZIndex = CONSTANTS.LAYER.CONTENT
	local children = {
		Background = createElement("ImageLabel", v20),
		GodRays = createElement("ImageLabel", {
			Rotation = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = 1 - (isFocused and 1 or 0) * (1 - v11),
			Image = "rbxassetid://125611520908369",
			ImageColor3 = Color3.fromRGB(255, 220, 130),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.05, 1.05),
			ZIndex = 4
		}),
		OutlineGlow = 0,
		ItemInformation = 0,
		Shine = 0,
		CornerGlow = 0,
		FruitTile = 0,
		IconEffectContainer = 0
	}
	local outlineGlow

	if isFocused or isSelected then
		local rotation

		if v7 and wiggle then
			rotation = -wiggle
		end

		outlineGlow = createElement("ImageLabel", {
			ref = ref2,
			Rotation = rotation,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://139486962053154",
			ImageColor3 = Color3.fromRGB(221, 188, 0),
			ImageTransparency = 0.4,
			Position = UDim2.fromScale(0.5, 0.517),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.27, 1.26),
			SliceCenter = Rect.new(58, 62, 213, 230),
			ZIndex = CONSTANTS.LAYER.BASE
		})
	end

	children.OutlineGlow = outlineGlow
	local v26 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 30
	}
	local redBanner

	if isPermanent then
		redBanner = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Image = "http://www.roblox.com/asset/?id=97739665531219",
			Position = UDim2.fromScale(-0.025, 0.033),
			Size = UDim2.fromScale(0.593, 0.147),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Visible = true
		}, {
			BannerText = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.825),
				Text = "Permanent",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = CONSTANTS.ALPHA.MID,
				TextWrapped = true
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.995, 0.925),
					Size = UDim2.fromScale(1, 1),
					Text = "Permanent",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextSize = 14,
					TextStrokeTransparency = CONSTANTS.ALPHA.MID,
					TextWrapped = true,
					ZIndex = CONSTANTS.LAYER.OVERLAY
				})
			})
		})
	end

	local equippedTag

	if v9 > 0 then
		equippedTag = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ImageTransparency = 1 - v9,
			Image = "rbxassetid://139971361540768",
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(v9 * 0.27, v9 * 0.27),
			Visible = true
		})
	end

	children.ItemInformation = createElement("Frame", v26, {
		RedBanner = redBanner,
		EquippedTag = equippedTag
	})
	children.Shine = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.965, 0.965),
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}, {
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PALETTE.WHITE),
				ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.PALETTE.WHITE),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PALETTE.WHITE)
			}),
			Offset = Vector2.new(0, -1.2),
			Rotation = 45,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.352, 1),
				NumberSequenceKeypoint.new(0.502, 0),
				NumberSequenceKeypoint.new(0.614, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		UICorner = createElement("UICorner")
	})
	local cornerGlow

	if sprite then
		cornerGlow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Image = "rbxassetid://111285502935012",
			ImageColor3 = Color3.fromRGB(255, 246, 115),
			ImageTransparency = (1 - v11) * 0.2,
			Position = UDim2.fromScale(-0.417, 1.35),
			Size = UDim2.fromScale(v11 * 1.19, v11 * 0.997),
			ZIndex = 11
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			})
		})
	end

	children.CornerGlow = cornerGlow
	local v33 = {
		ref = ref,
		Rotation = not v7 and 0 or wiggle,
		AnchorPoint = Vector2.new(0.5, 0.5):Lerp(Vector2.new(0, 1), not sprite and 0 or v11),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}
	local image

	if typeof(sprite2.Image) == "string" then
		image = sprite2.Image
	end

	v33.Image = image
	v33.ImageRectOffset = sprite2.ImageRectOffset
	v33.ImageRectSize = sprite2.ImageRectSize
	v33.ScaleType = Enum.ScaleType.Fit
	v33.Position = UDim2.fromScale(0.5, 0.5):Lerp(UDim2.new(0, 2, 1, 0), not sprite and 0 or v11)
	local uDim = UDim2.fromScale(0.9456521739130435, 0.9456521739130435)
	local v35

	if v13 then
		v35 = UDim2.fromScale(0.456, 0.456)
	else
		v35 = UDim2.fromScale(0.457, 0.457)
	end

	v33.Size = uDim:Lerp(v35, not sprite and 0 or v11)
	v33.ZIndex = 25
	v33[React.Tag] = props.IsFocused and "Focused" or "Unfocused"
	children.FruitTile = createElement("ImageLabel", v33)
	local v38 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.92),
		ZIndex = 10
	}
	local animatedArtIcon

	if v13 and isSelected then
		animatedArtIcon = createElement(DragonAnimation, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageTransparency = 1 - v11,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(v11 * 1.07, v11 * 1.07),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		})
	end

	local artIcon

	if sprite and not v13 then
		local v44 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = 1 - v11,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			Size = 0,
			Visible = true,
			ZIndex = 0
		}
		local image2

		if typeof(sprite.Image) == "string" then
			image2 = sprite.Image
		end

		v44.Image = image2
		v44.ImageRectOffset = sprite.ImageRectOffset
		v44.ImageRectSize = sprite.ImageRectSize
		v44.Position = UDim2.fromScale(0.5, 0.5)
		v44.Size = UDim2.fromScale(v11 * 1.07, v11 * 1.07)
		v44.ZIndex = CONSTANTS.LAYER.OVERLAY
		artIcon = createElement("ImageLabel", v44)
	end

	children.IconEffectContainer = createElement("Frame", v38, {
		AnimatedArtIcon = animatedArtIcon,
		ArtIcon = artIcon
	})
	return createElement("Frame", mergeFrame, children)
end