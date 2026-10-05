local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.React.Util)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Parent.Types)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Profile = require(script.Profile)
local SkillField = require(script.SkillField)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local useDiscountedDragonPrice = require(game.ReplicatedStorage.React.Hooks.Fruit.useDiscountedDragonPrice)
local useHasDragonDiscount = require(game.ReplicatedStorage.React.Hooks.Player.useHasDragonDiscount)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local useSelectionTime = require(script.Parent.Parent.useSelectionTime)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(0, 25, 15)
local v = {
	Enum.KeyCode.Z,
	Enum.KeyCode.X,
	Enum.KeyCode.C,
	Enum.KeyCode.V,
	Enum.KeyCode.F
}
local vector = Vector2.new(930, 212)
local random = Random.new()
local v2 = {}

for i = 1, 5 do
	local number = random:NextNumber(0, 15)
	local total = 0

	repeat
		local number2 = random:NextNumber(5, 15)
		table.insert(v2, {
			Delay = number + total,
			Duration = number2,
			Scale = random:NextNumber(0.5, 1.2),
			YOffset = (i - 0.5) / 5 - 0.5,
			RotationPeriod = random:NextNumber(10, 30)
		})
		total += number2
	until total >= 15
end

TableUtil.deepFreeze(v2)
local createElement = React.createElement

function cube(p)
	local v3 = 15 * usePeriod(true, 15)
	local delay = p.LifeCycle.Delay
	local v4 = p.LifeCycle.Delay + p.LifeCycle.Duration
	local v5

	if v4 > 15 then
		if delay <= v3 or v3 <= v4 - 15 then
			if delay <= v3 then
				v5 = (v3 - delay) / p.LifeCycle.Duration
			else
				v5 = (v3 + 15 - delay) / p.LifeCycle.Duration
			end
		else
			return nil
		end
	elseif delay <= v3 and v3 <= v4 then
		v5 = (v3 - delay) / p.LifeCycle.Duration
	else
		return nil
	end

	local rotation = p.LifeCycle.Duration * v5 / p.LifeCycle.RotationPeriod * 360
	local v7 = 1 - v5 * (1 - v5) * 4

	if v5 <= 0 or v5 >= 1 then
		return nil
	end

	return createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(v5, p.LifeCycle.YOffset + 0.5),
		Rotation = rotation,
		Image = "rbxassetid://136241754742847",
		ImageTransparency = math.clamp(v7 + (p.LifeCycle.Scale * 0.1) ^ 1.5, 0, 1),
		ZIndex = -p.LifeCycle.Scale * 10,
		Size = UDim2.fromScale(p.LifeCycle.Scale * 0.2, p.LifeCycle.Scale * 0.2)
	}, {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
end

function controlBackground(_)
	local v3 = usePeriod(true, 1)
	local v4 = math.sin(2 * useTime(true) / 1.5707963267948966) * 0.5 + 0.5
	local children = {}

	for i, lifeCycle in ipairs(v2) do
		children[`Cube{i}`] = createElement(cube, {
			LifeCycle = lifeCycle
		})
	end

	return createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		ImageTransparency = 0.19,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = -998
	}, {
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 63, 206)),
				ColorSequenceKeypoint.new(v4 * 0.3 + 0.15, Color3.fromRGB(1, 16, 102)),
				ColorSequenceKeypoint.new(0.85 - v4 * 0.3, Color3.fromRGB(1, 14, 99)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 63, 206))
			})
		}),
		HexagonLeft = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ScaleType = Enum.ScaleType.Crop,
			ImageRectOffset = Vector2.new((1 - v3) * 44, 0),
			ImageRectSize = Vector2.new(vector.X - 44, vector.Y),
			Image = "rbxassetid://136398626109718",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2625),
					NumberSequenceKeypoint.new(v4 * 0.074346 + 0.11, 0.4375),
					NumberSequenceKeypoint.new(v4 * 0.246202 + 0.22, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		HexagonRight = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://136398626109718",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Crop,
			ImageRectOffset = Vector2.new((1 - v3) * 44, 0),
			ImageRectSize = Vector2.new(vector.X - 44, vector.Y),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 180,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2625),
					NumberSequenceKeypoint.new(v4 * 0.074346 + 0.11, 0.4375),
					NumberSequenceKeypoint.new(v4 * 0.246202 + 0.22, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		Cubes = createElement(React.Fragment, {}, children),
		Lines = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://93447703880320",
			ImageTransparency = v4 * 0.7 + 0.1,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.858364, 0.858364)
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0),
					NumberSequenceKeypoint.new(0.8, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	})
end

return function(props)
	local isOwned = props.IsOwned
	local isLocked = props.IsLocked
	local isSelected = props.IsSelected
	local isTemporary = props.IsTemporary
	local displayName = props.DisplayName
	local description = props.Description
	local robuxPrice = props.RobuxPrice
	local robuxPrice2 = useRobuxPrice(props.Item.ItemId) or robuxPrice
	local beliPrice = props.BeliPrice
	local isDragon = props.IsDragon
	local v4 = useHasDragonDiscount()
	local v5 = useDiscountedDragonPrice()

	if isDragon and v5 and v4 then
		robuxPrice2 = v5
	end

	local v6 = displayName == "Control"
	local hoverIconBackground = props.HoverIconBackground
	local idleIconBackground = props.IdleIconBackground
	local fruitTile = props.FruitTile
	local artworkIcon = props.ArtworkIcon
	local isEquipped = props.IsEquipped
	local isWiggleEnabled = props.IsWiggleEnabled
	local facts = props.Facts
	local skills = props.Skills
	local cardHeightRatio = props.CardHeightRatio
	local onCardClick = props.OnCardClick
	local onCardSelectionGained = props.OnCardSelectionGained
	local buildQuality = props.BuildQuality
	local isComingSoon = props.IsComingSoon
	local item = props.Item
	local state, setState = React.useState(0)
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(false)
	local state5, setState5 = React.useState(0)
	local hoverAlpha = useSpring(state4 and 1 or 0, state4 and 1 or 0, 3, 5)
	local selectionAlpha = useSpring(isSelected and 1 or 0, isSelected and 1 or 0, 1.85, 4)
	local v9 = useLastInput()
	local v10 = useSelectionTime(isSelected, 1.4)
	local v11 = {}

	for i, skill in ipairs(skills) do
		local index = table.find(v, skill.Key)
		local formatted = `Mastery{i}`
		local v12

		if buildQuality ~= "Minimal" then
			local starBackgroundColor

			if isDragon then
				starBackgroundColor = CONSTANTS.COLOR.PRIMARY.BACKGROUND:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.1)
			else
				starBackgroundColor = Color3.fromHSV(0, 0, 0.8)
			end

			local v15 = {
				StarBackgroundColor3 = starBackgroundColor,
				ChipTransparency = isDragon and 0.25 or nil,
				ChipBackgroundColor3 = 0,
				SelectionAlpha = 0,
				HoverAlpha = 0,
				Skill = 0,
				LayoutOrder = 0
			}
			local chipBackgroundColor

			if isDragon then
				chipBackgroundColor = color
			end

			v15.ChipBackgroundColor3 = chipBackgroundColor
			v15.SelectionAlpha = selectionAlpha
			v15.HoverAlpha = hoverAlpha
			v15.Skill = skill
			v15.LayoutOrder = index
			v12 = createElement(SkillField, v15)
		end

		v11[formatted] = v12
	end

	if state2 and state3 then
		local v12 = state3 - state2

		if v12 > 0.05 and v12 < 0.5 then
			onCardClick(not isSelected)
		end

		setState3(nil)
		setState2(nil)
	end

	local skillWeight = React.useMemo(function()
		return state / math.max(1, state5)
	end, { state5, state })
	local v13

	if v10 > 0 then
		v13 = math.min(v10 * 2, 1)
	end

	local v14

	if v13 then
		v14 = 1 - math.abs(0.5 - v13) * 2
	end

	local value

	if v10 > 0 then
		value = TweenService:GetValue(math.min(v10 * 0.75, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end

	local value2

	if v10 > 0 then
		value2 = TweenService:GetValue(
			math.clamp(2.5 * v10 - 2.5, 0, 1),
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
	end

	local v15 = 60 * (1 - 0.5 * selectionAlpha)
	local v16 = 120 * (1 - 0.5 * selectionAlpha)
	local v17 = math.sin(6.283185307179586 * usePeriod(isDragon, 5)) * 0.5 + 0.5
	local v18 = usePeriod(isDragon, v15)
	local v19 = usePeriod(isDragon, v16)
	local v20 = state5 >= 460
	local mergeImageButton = RobloxTypes.mergeImageButton
	local v23 = {
		BackgroundColor3 = Color3.fromRGB(124, 124, 124):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * hoverAlpha),
		[React.Change.AbsoluteSize] = buildQuality == "Full" and function(p)
			local X = math.round(p.AbsoluteSize.X)

			if X ~= state5 then
				setState5(X)
			end
		end or nil
	}
	local inputBegan = React.Event.InputBegan
	local v24

	if buildQuality == "Full" then
		v24 = v9 == "Touch" and function(_, p)
			if p.UserInputType == Enum.UserInputType.Touch then
				setState2(tick())
				setState3(nil)
			end
		end or nil
	end

	v23[inputBegan] = v24
	local inputEnded = React.Event.InputEnded
	local v25

	if buildQuality == "Full" then
		if v9 == "Touch" and state2 then
			v25 = function(_, p)
				if p.UserInputType == Enum.UserInputType.Touch then
					setState3(tick())
				end
			end
		elseif v9 == "Gamepad" then
			v25 = function(_, p)
				if p.KeyCode == Enum.KeyCode.ButtonA then
					onCardClick(not isSelected)
				end
			end
		elseif v9 == "MouseKeyboard" then
			v25 = function(_, p)
				if p.UserInputType == Enum.UserInputType.MouseButton1 then
					onCardClick(not isSelected)
				end
			end
		else
			v25 = nil
		end
	end

	v23[inputEnded] = v25
	v23[React.Event.MouseEnter] = buildQuality == "Full" and function()
		if not state4 then
			setState4(true)
		end
	end or nil
	v23[React.Event.MouseLeave] = buildQuality == "Full" and function()
		if state4 then
			setState4(false)
		end
	end or nil
	v23[React.Event.SelectionGained] = buildQuality == "Full" and function()
		if not state4 then
			setState4(true)
		end

		if onCardSelectionGained then
			onCardSelectionGained()
		end
	end or nil
	v23[React.Event.SelectionLost] = buildQuality == "Full" and function()
		if state4 then
			setState4(false)
		end
	end or nil
	local v26 = mergeImageButton(v23, props)
	local v27 = {
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(240, 215, 4),
			LineJoinMode = Enum.LineJoinMode.Miter,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Profile = 0,
		IconGleam = 0,
		Glow = 0,
		Holographic = 0,
		Wallpaper = 0,
		ShineEffect = 0,
		Skills = 0
	}
	local v30 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		BuildQuality = buildQuality,
		Position = UDim2.fromScale(0.015, 0.5),
		Size = UDim2.fromScale(0.442, 1),
		ZIndex = CONSTANTS.LAYER.RAISED,
		IsComingSoon = isComingSoon,
		HoverIconBackground = hoverIconBackground,
		IdleIconBackground = idleIconBackground,
		Item = item,
		FruitTile = fruitTile,
		ArtworkIcon = artworkIcon,
		IsTemporary = isTemporary,
		IsSelected = isSelected,
		IsDragon = isDragon,
		IsHovering = state4,
		OnEggSelect = props.OnEggSelect,
		IsWiggleEnabled = isWiggleEnabled,
		IsEquipped = isEquipped,
		IsOwned = isOwned,
		IsLocked = isLocked,
		DisplayName = displayName,
		Description = 0,
		RobuxPrice = 0,
		BeliPrice = 0,
		SkillWeight = 0,
		Facts = 0
	}

	if not v20 then
		description = nil
	end

	v30.Description = description
	v30.RobuxPrice = robuxPrice2
	v30.BeliPrice = beliPrice
	v30.SkillWeight = skillWeight
	v30.Facts = facts
	v27.Profile = createElement(Profile, v30)
	local iconGleam

	if not (buildQuality == "Minimal" or not (value and value2 and value > 0 and value2 < 1)) then
		iconGleam = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Position = UDim2.fromScale(0.008, 0.495),
			Size = UDim2.fromScale(0.905, 0.905)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.11, 0)
			}),
			UIAspectRatioConstraint11 = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.969
			}),
			UIGradient = createElement("UIGradient", {
				Rotation = (180 + 360 * value) % 360,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.298 + 0.19 * value2, 1),
					NumberSequenceKeypoint.new(0.3 + 0.19 * value2, 0),
					NumberSequenceKeypoint.new(0.699 - 0.19 * value2, 0),
					NumberSequenceKeypoint.new(0.701 - 0.19 * value2, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	end

	v27.IconGleam = iconGleam
	local glow

	if not (buildQuality == "Minimal" or not (isDragon and selectionAlpha > 0)) then
		glow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://123995060736710",
			ImageColor3 = Color3.fromRGB(255, 228, 72),
			ImageTransparency = 1 - selectionAlpha * (v17 * 0.4 + 0.4),
			Position = UDim2.fromScale(0.5, 0.5),
			SliceCenter = Rect.new(19, 19, 676, 151),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(1, 19, 1, 19),
			Visible = true
		})
	end

	v27.Glow = glow
	local holographic

	if not (buildQuality == "Minimal" or not (isDragon and v13 and v14 and v14 > 0)) then
		holographic = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = 1 - v14,
			Image = "rbxassetid://124192895864199",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = true,
			Visible = true,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 38)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 38))
				}),
				Offset = Vector2.new(-0.55, 0),
				Rotation = 30,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.0984, 1),
					NumberSequenceKeypoint.new(0.299, 0),
					NumberSequenceKeypoint.new(0.4, 0),
					NumberSequenceKeypoint.new(0.599, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			ShineBar = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1 - v13, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				ImageTransparency = 1 - v14,
				Image = "rbxassetid://74870188979719",
				Position = UDim2.fromScale(v13, 0.5),
				Size = UDim2.fromScale(0.234, 1)
			})
		})
	end

	v27.Holographic = holographic
	local wallpaper

	if isDragon then
		wallpaper = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(2, 48, 32),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ClipsDescendants = true,
			ImageTransparency = 0.19,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -998
		}, {
			Gradient = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 74, 43)),
						ColorSequenceKeypoint.new(0.0794, Color3.fromRGB(0, 131, 77)),
						ColorSequenceKeypoint.new(0.13, Color3.fromRGB(0, 126, 74)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 36, 21))
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.337),
						NumberSequenceKeypoint.new(0.377, 0.269),
						NumberSequenceKeypoint.new(0.492, 0.75),
						NumberSequenceKeypoint.new(0.661, 0.887),
						NumberSequenceKeypoint.new(0.806, 0.262),
						NumberSequenceKeypoint.new(1, 0.15)
					})
				})
			}),
			FilledClouds1 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://108435042914226",
				ImageTransparency = 0.56,
				Position = UDim2.fromScale(v19 * 1.2, 0.5),
				Size = UDim2.fromScale(1.2, 1),
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			FilledClouds2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://108435042914226",
				ImageTransparency = 0.56,
				Position = UDim2.fromScale(v19 * 1.2 - 1.2, 0.5),
				Size = UDim2.fromScale(1.2, 1),
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			OutlineClouds1 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://75663110216661",
				ImageColor3 = Color3.fromRGB(166, 166, 38),
				Position = UDim2.fromScale(v18 * 1.2, 0.5),
				Size = UDim2.fromScale(1.2, 1)
			}),
			OutlineClouds2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://75663110216661",
				ImageColor3 = Color3.fromRGB(166, 166, 38),
				Position = UDim2.fromScale(v18 * 1.2 - 1.2, 0.5),
				Size = UDim2.fromScale(1.2, 1)
			})
		})
	elseif v6 then
		wallpaper = createElement(controlBackground, {})
	else
		wallpaper = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(167, 142, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			ImageTransparency = not (hoverAlpha > 0) and 0 or hoverAlpha * 0.2,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -998
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.709, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	end

	v27.Wallpaper = wallpaper
	local shineEffect

	if v13 and v14 then
		shineEffect = createElement("Frame", {
			AnchorPoint = Vector2.new(1 - v13, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(v13 or 0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.991, 1),
			ZIndex = -998
		}, {
			UIGradient12 = createElement("UIGradient", {
				Rotation = 20,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.35 - 0.15 * v13, 1),
					NumberSequenceKeypoint.new(0.45 - 0.15 * v13, 1 - 0.5 * v14 ^ 2),
					NumberSequenceKeypoint.new(0.55 + 0.15 * v13, 1 - 0.5 * v14 ^ 2),
					NumberSequenceKeypoint.new(0.65 + 0.15 * v13, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	end

	v27.ShineEffect = shineEffect
	local skills2

	if buildQuality ~= "Minimal" then
		skills2 = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.new(1 - 0.07 * cardHeightRatio, 0, 0.5, 0),
			Size = UDim2.fromScale(1.25, 0.725),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Change.AbsoluteSize] = function(p)
				local X = math.round(p.AbsoluteSize.X)

				if X ~= state then
					setState(X)
				end
			end
		}, {
			UIListLayout = createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.XL,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Skills = createElement(React.Fragment, {}, v11)
		})
	end

	v27.Skills = skills2
	return createElement("ImageButton", v26, v27)
end