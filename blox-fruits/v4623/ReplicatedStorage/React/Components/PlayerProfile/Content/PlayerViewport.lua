local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local ProfileBackgrounds = require(ReplicatedStorage.Modules.ProfileBackgrounds)
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
local NewBadge = require(ReplicatedStorage.React.Components.NewBadge)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local ImageUtil

if GlobalUtil.FFlags.IsUnitTest then
	ImageUtil = nil
else
	ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
end

local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO)
local v = {
	Common = Vector2.new(0, 0),
	Uncommon = Vector2.new(163, 0),
	Rare = Vector2.new(326, 0),
	Legendary = Vector2.new(489, 0),
	Mythical = Vector2.new(652, 0)
}
local createElement = React.createElement
return function(p)
	React.useEffect(function()
		if RunService:IsStudio() then
			print("PLR DATA", p.LoadedPlayer.ProfileData)
		end
	end, { p.LoadedPlayer })
	local image = React.useMemo(function()
		local v3 = ProfileBackgrounds.IdToNameMap[p.LoadedPlayer.ProfileData.BackgroundIndex]

		if v3 then
			return ProfileBackgrounds.List[v3].Image
		end

		return ProfileBackgrounds.List.Default.Image
	end, { p.LoadedPlayer })
	local v3 = React.useMemo(function()
		local frozen = nil
		local unwrapOr = ItemId.getDataFromId(p.LoadedPlayer.ProfileData.EquippedAccessory):unwrapOr({})

		if not (unwrapOr and unwrapOr.StorageKey) then
			return frozen
		end

		local v4

		if ImageUtil then
			v4 = ImageUtil.getImageFromItemId(unwrapOr.ItemId)
		end

		if v4 then
			local icon = v4.Icon

			if icon and icon.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" then
				frozen = table.freeze({
					Image = icon.Image,
					ImageRectOffset = icon.ImageRectOffset,
					ImageRectSize = icon.ImageRectSize
				})
			end
		end

		if frozen == nil then
			frozen = Spritesheets.MAP[unwrapOr.StorageKey]
		end

		return frozen
	end, { p.LoadedPlayer })
	local v4 = React.useMemo(function()
		local v5 = nil
		local equippedTrinket1 = p.LoadedPlayer.ProfileData.EquippedTrinket1

		if not equippedTrinket1 or equippedTrinket1 == 0 then
			return v5
		end

		local v6 = ItemConfig.tryGet(equippedTrinket1)

		if v6 ~= nil then
			local rarity = v6.Quality.Rarity
			local sprite = v6.Display.Sprite
			return rarity and sprite and {
				Rarity = rarity,
				Sprite = sprite
			} or v5
		end

		return v5
	end, { p.LoadedPlayer })
	local v5 = React.useMemo(function()
		local v6 = nil
		local equippedTrinket2 = p.LoadedPlayer.ProfileData.EquippedTrinket2

		if not equippedTrinket2 or equippedTrinket2 == 0 then
			return v6
		end

		local v7 = ItemConfig.tryGet(equippedTrinket2)

		if v7 ~= nil then
			local rarity = v7.Quality.Rarity
			local sprite = v7.Display.Sprite
			return rarity and sprite and {
				Rarity = rarity,
				Sprite = sprite
			} or v6
		end

		return v6
	end, { p.LoadedPlayer })
	local v6 = React.useMemo(function()
		local frozen = nil
		local unwrapOr = ItemId.getDataFromId(p.LoadedPlayer.ProfileData.EquippedSword):unwrapOr({})

		if not (unwrapOr and unwrapOr.StorageKey) then
			return frozen
		end

		local v7

		if ImageUtil then
			v7 = ImageUtil.getImageFromItemId(unwrapOr.ItemId)
		end

		if v7 then
			local icon = v7.Icon

			if icon and icon.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" then
				frozen = table.freeze({
					Image = icon.Image,
					ImageRectOffset = icon.ImageRectOffset,
					ImageRectSize = icon.ImageRectSize
				})
			end
		end

		return frozen
	end, { p.LoadedPlayer })
	local v7 = React.useMemo(function()
		local frozen = nil
		local unwrapOr = ItemId.getDataFromId(p.LoadedPlayer.ProfileData.EquippedGun):unwrapOr({})

		if not (unwrapOr and unwrapOr.StorageKey) then
			return frozen
		end

		local v8

		if ImageUtil then
			v8 = ImageUtil.getImageFromItemId(unwrapOr.ItemId)
		end

		if v8 then
			local icon = v8.Icon

			if icon and icon.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" then
				frozen = table.freeze({
					Image = icon.Image,
					ImageRectOffset = icon.ImageRectOffset,
					ImageRectSize = icon.ImageRectSize
				})
			end
		end

		return frozen
	end, { p.LoadedPlayer })
	local v8 = React.useMemo(function()
		local frozen = nil
		local unwrapOr = ItemId.getDataFromId(p.LoadedPlayer.ProfileData.EquippedFruit):unwrapOr({})

		if not (unwrapOr and unwrapOr.StorageKey) then
			return frozen
		end

		local v9

		if ImageUtil then
			v9 = ImageUtil.getImageFromItemId(unwrapOr.ItemId)
		end

		if v9 then
			local icon = v9.Icon

			if icon and icon.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" then
				frozen = table.freeze({
					Image = icon.Image,
					ImageRectOffset = icon.ImageRectOffset,
					ImageRectSize = icon.ImageRectSize
				})
			end
		end

		return frozen
	end, { p.LoadedPlayer })
	local v9 = React.useMemo(function()
		local frozen = nil
		local unwrapOr = ItemId.getDataFromId(p.LoadedPlayer.ProfileData.EquippedFightingStyle):unwrapOr({})

		if unwrapOr and unwrapOr.StorageKey then
			local v10 = ItemConfig.tryGet(unwrapOr.ItemId)
			local sprite

			if v10 then
				sprite = v10.Display.Sprite
			end

			if sprite and sprite.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" and sprite.Image ~= "" then
				frozen = table.freeze({
					Image = sprite.Image,
					ImageRectOffset = sprite.ImageRectOffset,
					ImageRectSize = sprite.ImageRectSize
				})
			end
		end

		return frozen
	end, { p.LoadedPlayer })
	local v10 = React.useMemo(function()
		return CONSTANTS.RACE_SPRITES[p.LoadedPlayer.ProfileData.Race]
	end, { p.LoadedPlayer })
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	React.useEffect(function()
		if ref2.current then
			local success, humanoidDescriptionFromUserId = pcall(
				Players.GetHumanoidDescriptionFromUserId,
				Players,
				p.LoadedPlayer.UserId
			)

			if success then
				humanoidDescriptionFromUserId.WidthScale = 1
				humanoidDescriptionFromUserId.HeightScale = 1.01
				humanoidDescriptionFromUserId.DepthScale = 1
				humanoidDescriptionFromUserId.HeadScale = 1
				humanoidDescriptionFromUserId.BodyTypeScale = 1
				humanoidDescriptionFromUserId.ProportionScale = 1
				humanoidDescriptionFromUserId.LeftArm = 0
				humanoidDescriptionFromUserId.RightArm = 0
				humanoidDescriptionFromUserId.LeftLeg = 0
				humanoidDescriptionFromUserId.RightLeg = 0
				humanoidDescriptionFromUserId.Torso = 0
				local success2, result = pcall(
					Players.CreateHumanoidModelFromDescription,
					Players,
					humanoidDescriptionFromUserId,
					Enum.HumanoidRigType.R15
				)

				if success2 then
					local model = ref2.current:FindFirstChildOfClass("Model")

					if model then
						model:Destroy()
					end

					for _, script in result:GetChildren() do
						if script:IsA("Script") or script:IsA("LocalScript") then
							script:Destroy()
						end
					end

					task.spawn(function()
						repeat
							task.wait()
						until result.Parent and result:IsDescendantOf(game)

						if result:FindFirstChild("Animation") then
							return
						end

						local stanceOverrideId = p.LoadedPlayer.ProfileData.StanceOverrideId
						local v11 = stanceOverrideId == 0 and 507766388 or stanceOverrideId
						local animation = Instance.new("Animation")
						animation.AnimationId = `rbxassetid://{v11}`
						animation.Parent = result
						local track = result.Humanoid:LoadAnimation(animation)
						track.Priority = Enum.AnimationPriority.Action
						track:Play(0, 1, 1)
					end)
					result.HumanoidRootPart.Anchored = true
					result:PivotTo(CFrame.identity)
					result.Parent = ref2.current
				end
			end
		end
	end, { p.LoadedPlayer, ref2.current })
	local fragment = React.Fragment
	local v13 = {
		mainViewport = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = image,
			Position = UDim2.fromScale(0.021, 0.856),
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(0.265, 0.741),
			ZIndex = -1
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XS
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			})
		}),
		profileContent = 0
	}
	local v16 = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.021, 0.856),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(0.265, 0.741),
		ZIndex = 1
	}
	local v17 = {
		vp = createElement("ViewportFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("00aaf5"),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			CurrentCamera = ref.current
		}, {
			wm = createElement("WorldModel", {
				ref = ref2
			}),
			cam = createElement("Camera", {
				CFrame = CFrame.new(0, 0, -45) * CFrame.Angles(0, 3.141592653589793, 0),
				FieldOfView = 10,
				ref = ref
			})
		}),
		profileContent = 0
	}
	local v20 = {
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1)
	}
	local v21 = {
		level = createElement("Frame", {
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.327, 0),
			Size = UDim2.fromScale(0.673, 0.0825),
			ZIndex = CONSTANTS2.LAYER.BASE,
			Visible = CONSTANTS.isPermissionLevelMet(
				p.LoadedPlayer.UserId,
				p.LoadedPlayer.ProfileData.Settings.LevelVisible
			)
		}, {
			uIGradient = createElement("UIGradient", {
				Rotation = 180,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XS
			}),
			level = createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.95, 0.525),
				RichText = true,
				Size = UDim2.fromScale(0.787, 0.75),
				Text = `Lv. <font color="#ffd631">{p.LoadedPlayer.ProfileData.Level // 1}</font>`,
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		fade = 0,
		editBackground = 0,
		equippedItems = 0,
		build = 0
	}
	local v24 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = CONSTANTS2.LAYER.BASE
	}
	local v25 = {
		uIGradient = createElement("UIGradient", {
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.132005, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		race = 0
	}
	local v28 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(63, 110, 44),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Image = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		Position = 0,
		Size = 0,
		Visible = 0
	}
	local image2

	if v10 then
		image2 = v10.Image
	end

	v28.Image = image2
	local imageRectOffset

	if v10 then
		imageRectOffset = v10.ImageRectOffset
	end

	v28.ImageRectOffset = imageRectOffset
	local imageRectSize

	if v10 then
		imageRectSize = v10.ImageRectSize
	end

	v28.ImageRectSize = imageRectSize
	v28.Position = UDim2.fromScale(0.964633, 0.0981666)
	v28.Size = UDim2.fromOffset(39, 39)
	v28.Visible = CONSTANTS.isPermissionLevelMet(p.LoadedPlayer.UserId, p.LoadedPlayer.ProfileData.Settings.RaceVisible)
	v25.race = createElement("ImageLabel", v28, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		level = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(1.1, 0.988),
			RichText = true,
			Size = UDim2.fromScale(0.787, 0.552266),
			Text = `V{(p.LoadedPlayer.ProfileData.RaceLevel or 0) + 1}`,
			TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			})
		})
	})
	v21.fade = createElement("Frame", v24, v25)
	local v34 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
		BorderColor3 = CONSTANTS2.COLOR.SECONDARY.BORDER,
		FontFace = CONSTANTS2.FONT.FACE.BODY_LIGHT,
		Position = UDim2.fromScale(0.5, 0.77),
		Size = UDim2.fromScale(0.758631, 0.0923608),
		Text = "",
		TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
		Visible = p.LoadedPlayer.IsLocalPlayer and not p.LoadedPlayer.IsPreviewMode,
		[React.Event.MouseButton1Click] = function()
			p.SetBackgroundSelectionVisible(true)
		end
	}
	local newBadge

	if next(p.LoadedPlayer.NewBackgrounds) ~= nil then
		newBadge = createElement(NewBadge, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = CONSTANTS2.LAYER.OVERLAY
		})
	end

	v21.editBackground = createElement("TextButton", v34, {
		newBadge = newBadge,
		trans = createElement("Frame", {
			BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0)
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.95, 0.75),
			Text = "Edit Background",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = "Edit Background",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		})
	})
	local v38 = {
		BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
		BackgroundTransparency = 0.999,
		BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(-0.0694217, -0.0303786),
		SelectionGroup = true,
		Size = UDim2.fromScale(0.324965, 0.891887),
		Visible = CONSTANTS.isPermissionLevelMet(
			p.LoadedPlayer.UserId,
			p.LoadedPlayer.ProfileData.Settings.AccessoriesVisible
		)
	}
	local children2 = {
		uIListLayout = createElement("UIListLayout", {
			Padding = CONSTANTS2.SPACING.PADDING.SCALE.XS,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		superItem = createElement("ImageButton", {
			Active = false,
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://97622910555082",
			ImageRectOffset = Vector2.new(0, 653),
			ImageRectSize = Vector2.new(202, 205),
			LayoutOrder = -999,
			ScaleType = Enum.ScaleType.Fit,
			Selectable = false,
			Size = UDim2.fromScale(1, 1),
			Visible = v3 ~= nil
		}, {
			itemImage = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = not v3 and "" or v3.Image or "",
				ImageRectOffset = v3 and v3.ImageRectOffset or Vector2.zero,
				ImageRectSize = v3 and v3.ImageRectSize or Vector2.zero,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8)
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		}),
		trinket1 = 0,
		trinket2 = 0,
		miniItemSuperItemLocked = 0,
		miniItem = 0,
		miniItem2 = 0
	}
	local trinket

	if v4 ~= nil then
		trinket = createElement("ImageButton", {
			Active = false,
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://97622910555082",
			ImageRectOffset = v[v4.Rarity] or v.Common,
			ImageRectSize = Vector2.new(163, 163),
			Position = UDim2.fromOffset(0, 71),
			Selectable = false,
			Size = UDim2.fromScale(0.8, 0.8),
			LayoutOrder = -998
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = v4.Sprite.Image,
				ImageRectSize = v4.Sprite.ImageRectSize,
				ImageRectOffset = v4.Sprite.ImageRectOffset,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8)
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	children2.trinket1 = trinket
	local trinket2

	if v5 ~= nil then
		trinket2 = createElement("ImageButton", {
			Active = false,
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://97622910555082",
			ImageRectOffset = v[v5.Rarity] or v.Common,
			ImageRectSize = Vector2.new(163, 163),
			Position = UDim2.fromOffset(0, 71),
			Selectable = false,
			Size = UDim2.fromScale(0.8, 0.8),
			LayoutOrder = -997
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = v5.Sprite.Image,
				ImageRectSize = v5.Sprite.ImageRectSize,
				ImageRectOffset = v5.Sprite.ImageRectOffset,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8)
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	children2.trinket2 = trinket2
	children2.miniItemSuperItemLocked = createElement("ImageButton", {
		Active = false,
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Image = "rbxassetid://112043753479709",
		ImageColor3 = Color3.fromRGB(159, 159, 159),
		ImageRectOffset = Vector2.new(0, 163),
		ImageRectSize = Vector2.new(163, 163),
		LayoutOrder = 1,
		Position = UDim2.fromOffset(0, -1),
		Selectable = false,
		Size = UDim2.fromScale(0.85, 0.85),
		Visible = false
	}, {
		lockIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://13632157987",
			ImageTransparency = CONSTANTS2.ALPHA.HALF,
			Position = UDim2.fromScale(0.52, 0.51),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.3, 0.3),
			Visible = false
		}, {
			lockOn = createElement("Decal", {
				Texture = "http://www.roblox.com/asset/?id=1703949580"
			})
		}),
		itemImage = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://97622910555082",
			ImageRectOffset = Vector2.new(271, 921),
			ImageRectSize = Vector2.new(94, 77),
			ImageTransparency = CONSTANTS2.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.74342, 0.74342)
		}),
		addTextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = font,
			Position = UDim2.fromScale(0.515, 0.514),
			Size = UDim2.fromScale(1, 0.814093),
			Text = "+",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTransparency = CONSTANTS2.ALPHA.HALF,
			Visible = false,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			})
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
	children2.miniItem = createElement("ImageButton", {
		Active = false,
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Image = "rbxassetid://97622910555082",
		ImageRectOffset = Vector2.new(163, 0),
		ImageRectSize = Vector2.new(163, 163),
		Position = UDim2.fromOffset(0, 71),
		Selectable = false,
		Size = UDim2.fromScale(0.8, 0.8),
		Visible = false
	}, {
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://13521218893",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8)
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
	children2.miniItem2 = createElement("ImageButton", {
		Active = false,
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Image = "rbxassetid://97622910555082",
		ImageRectOffset = Vector2.new(163, 0),
		ImageRectSize = Vector2.new(163, 163),
		Position = UDim2.fromOffset(0, 71),
		Selectable = false,
		Size = UDim2.fromScale(0.8, 0.8),
		Visible = false
	}, {
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://13521218893",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8)
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
	v21.equippedItems = createElement("Frame", v38, children2)
	v21.build = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		LayoutOrder = 7,
		Position = UDim2.fromScale(0.5, 0.98),
		SelectionGroup = true,
		Size = UDim2.fromScale(0.956, 0.137907),
		Visible = CONSTANTS.isPermissionLevelMet(
			p.LoadedPlayer.UserId,
			p.LoadedPlayer.ProfileData.Settings.CombatToolsVisible
		)
	}, {
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS2.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		fruit = createElement("ImageButton", {
			Active = false,
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = -1,
			Position = UDim2.fromScale(-4.87058e-8, -0.00655503),
			Selectable = false,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.08, 0)
			}),
			uIStroke = createElement("UIStroke", {
				Color = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Enabled = v8 == nil
			}),
			image = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = not v8 and "" or v8.Image or "",
				ImageRectSize = v8 and v8.ImageRectSize or Vector2.zero,
				ImageRectOffset = v8 and v8.ImageRectOffset or Vector2.zero,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Visible = v8 ~= nil
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
				})
			}),
			emptyStateIcon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://12391098247",
				ImageColor3 = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Position = UDim2.fromScale(0.5, 0.509),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.5, 0.5),
				Visible = v8 == nil
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.96
				})
			})
		}),
		sword = createElement("ImageButton", {
			Active = false,
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = 3,
			Position = UDim2.fromScale(-4.87058e-8, -0.00655503),
			Selectable = false,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.08, 0)
			}),
			altIcon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://12391181354",
				ImageColor3 = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.351, 0.45),
				Visible = v6 == nil
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.78
				})
			}),
			uIStroke = createElement("UIStroke", {
				Color = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Enabled = v6 == nil
			}),
			image = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = not v6 and "" or v6.Image or "",
				ImageRectSize = v6 and v6.ImageRectSize or Vector2.zero,
				ImageRectOffset = v6 and v6.ImageRectOffset or Vector2.zero,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Visible = v6 ~= nil
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
				})
			})
		}),
		gun = createElement("ImageButton", {
			Active = false,
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = 2,
			Position = UDim2.fromScale(-4.87058e-8, -0.00655503),
			Selectable = false,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			image = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = not v7 and "" or v7.Image or "",
				ImageRectSize = v7 and v7.ImageRectSize or Vector2.zero,
				ImageRectOffset = v7 and v7.ImageRectOffset or Vector2.zero,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Visible = v7 ~= nil
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
				})
			}),
			altIcon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://12391771916",
				ImageColor3 = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Position = UDim2.fromScale(0.5, 0.509),
				Size = UDim2.fromScale(0.336, 0.35),
				Visible = v7 == nil
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.96
				})
			}),
			uIStroke = createElement("UIStroke", {
				Color = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Enabled = v7 == nil
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.08, 0)
			})
		}),
		uIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS2.SPACING.PADDING.SCALE.SM,
			PaddingLeft = UDim.new(0.002, 0),
			PaddingRight = UDim.new(0.002, 0),
			PaddingTop = CONSTANTS2.SPACING.PADDING.SCALE.MD
		}),
		melee = createElement("ImageButton", {
			Active = false,
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = -2,
			Position = UDim2.fromScale(-4.87058e-8, -0.00655503),
			Selectable = false,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
			}),
			uIStroke = createElement("UIStroke", {
				Color = CONSTANTS2.COLOR.DIVIDER.BORDER,
				Enabled = v9 == nil
			}),
			emptyStateIcon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://12391155850",
				ImageColor3 = Color3.fromRGB(121, 121, 121),
				Position = UDim2.fromScale(0.52, 0.509),
				Size = UDim2.fromScale(0.384, 0.4),
				Visible = v9 == nil
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.96
				})
			}),
			image = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = not v9 and "" or v9.Image or "",
				ImageRectSize = v9 and v9.ImageRectSize or Vector2.zero,
				ImageRectOffset = v9 and v9.ImageRectOffset or Vector2.zero,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Visible = v9 ~= nil
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
				})
			})
		})
	})
	v17.profileContent = createElement("Frame", v20, v21)
	v13.profileContent = createElement("ImageLabel", v16, v17)
	return createElement(fragment, nil, v13)
end