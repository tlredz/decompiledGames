local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local RarityTheme = require(script.Parent.RarityTheme)
require(script.Parent.Types)
local RowTheme = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.RowTheme)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local rbxassetfontsfamiliesFredokaOnejson = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Regular
)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

local function textStroke(color, thickness: number)
	return create("UIStroke")({
		Color = color,
		Thickness = thickness,
		StrokeSizingMode = 1
	})
end

local function actionButton(data, i: number, notOwned, style)
	local color = data.Color or Color3.fromRGB(70, 120, 200)
	local widthRatio = data.WidthRatio or 3.2
	local uDim

	if data.Text == nil then
		uDim = UDim2.fromScale(0.85, 0.85)
	else
		uDim = UDim2.fromScale(0.3, 0.9)
	end

	local uDim2 = UDim2.fromScale(0.5 / widthRatio, 0.5)
	return create("ImageButton")({
		Name = data.Id,
		LayoutOrder = i,
		Size = UDim2.fromScale(widthRatio, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = color,
		Image = "rbxassetid://106467099323886",
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = uDim2,
		ZIndex = 10,
		Visible = function()
			local visible = data.Visible
			return notOwned() and (visible == nil or read(visible))
		end,
		MouseButton1Click = data.OnActivated,
		create("UICorner")({
			CornerRadius = function()
				return style().ButtonCorner
			end
		}),
		create("UIStroke")({
			Color = data.StrokeColor or Color3.fromRGB(255, 243, 211),
			Thickness = 0.08,
			StrokeSizingMode = 1
		}),
		create("UIListLayout")({
			Padding = UDim.new(0.05, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		create("ImageLabel")({
			Name = "Icon",
			LayoutOrder = 1,
			Size = uDim,
			BackgroundTransparency = 1,
			Image = defaulted(data.Icon, ""),
			ScaleType = Enum.ScaleType.Fit,
			Visible = function()
				local icon = data.Icon
				return icon ~= nil and read(icon) ~= ""
			end,
			create("UIAspectRatioConstraint")({
				AspectRatio = 1
			})
		}),
		create("TextLabel")({
			Name = "Title",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.45, 0.7),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = defaulted(data.Text, ""),
			TextColor3 = data.TextColor or Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			ZIndex = 2,
			Visible = function()
				local text = data.Text
				return text ~= nil and read(text) ~= ""
			end,
			textStroke(function()
				return style().AmountStrokeColor
			end, 0.07)
		})
	})
end

local function ownedPill(data, owned, style)
	return create("Frame")({
		Name = "Owned",
		LayoutOrder = 0,
		Size = UDim2.fromScale(4, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = function()
			return style().OwnedColor
		end,
		ZIndex = 10,
		Visible = owned,
		create("UICorner")({
			CornerRadius = function()
				return style().ButtonCorner
			end
		}),
		create("UIStroke")({
			Color = function()
				return style().OwnedStrokeColor
			end,
			Thickness = 0.08,
			StrokeSizingMode = 1
		}),
		create("TextLabel")({
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.7),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = defaulted(data.OwnedText, "OWNED"),
			TextColor3 = function()
				return style().OwnedTextColor
			end,
			TextScaled = true,
			ZIndex = 2,
			textStroke(function()
				return style().AmountStrokeColor
			end, 0.07)
		})
	})
end

local function tierStars(data, style)
	local v = {}

	for i = 1, 5 do
		local v2 = i
		v[i] = create("TextLabel")({
			Name = "Star" .. i,
			LayoutOrder = i,
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesFredokaOnejson,
			Text = "★",
			TextColor3 = function()
				return style().StarColor
			end,
			TextScaled = true,
			ZIndex = 6,
			Visible = function()
				local tier = data.Tier
				return v2 <= (tier == nil and 0 or read(tier))
			end,
			textStroke(function()
				return style().StarStrokeColor
			end, 0.06)
		})
	end

	return create("Frame")({
		Name = "TierFrame",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.99),
		Size = UDim2.fromScale(1, 0.26),
		BackgroundTransparency = 1,
		ZIndex = 5,
		create("Frame")({
			Name = "LayoutContainer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 6,
			create("UIListLayout")({
				Padding = UDim.new(-0.06, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			v
		})
	})
end

local function amountPart(name: string, udim: UDim2, text, callback)
	return create("TextLabel")({
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = udim,
		Size = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson2,
		Text = text,
		TextColor3 = function()
			return callback().AmountColor
		end,
		TextScaled = true,
		ZIndex = 2,
		textStroke(function()
			return callback().AmountStrokeColor
		end, 0.03)
	})
end

local function amountText(data, style)
	local function currentText()
		local current = data.Current
		return (tostring(current == nil and 0 or read(current)))
	end

	local function maxText()
		local max = data.Max
		return (tostring(max == nil and 0 or read(max)))
	end

	return create("Frame")({
		Name = "Amount",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.8, 0.5),
		Size = UDim2.fromScale(0.3, 0.8),
		BackgroundTransparency = 1,
		Visible = function()
			local max = data.Max
			return max ~= nil and read(max) > 0
		end,
		amountPart("Current", UDim2.fromScale(0.26, 0.36), currentText, style),
		amountPart("Slash", UDim2.fromScale(0.5, 0.5), "/", style),
		amountPart("Max", UDim2.fromScale(0.74, 0.64), maxText, style)
	})
end

local function ItemRow(data)
	local function style()
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v

		if variant ~= nil then
			v = read(variant)
		end

		return styleFor(v)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function owned()
		local owned2 = data.Owned
		return owned2 ~= nil and read(owned2)
	end

	local function notOwned()
		local v = owned() -- equivalent call inferred; original call site unknown
		return not v
	end

	local function rarity()
		return read(data.Rarity)
	end

	local function titleStrokeColor()
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v

		if variant ~= nil then
			v = read(variant)
		end

		return styleFor(v).TitleStrokeColor
	end

	local function rarityColor()
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v

		if variant ~= nil then
			v = read(variant)
		end

		return styleFor(v).RarityColor or RarityTheme.textColorFor(rarity())
	end

	local v = {}

	for i, v2 in ipairs(data.Actions or {}) do
		v[i] = actionButton(v2, i, notOwned, style)
	end

	return create("TextButton")({
		Name = data.Name or "ItemRow",
		LayoutOrder = data.LayoutOrder or 0,
		Size = defaulted(data.Size, UDim2.fromScale(1, 0.48)),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Active = data.OnActivated ~= nil,
		MouseButton1Click = data.OnActivated,
		create("Frame")({
			Name = "Container",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.4),
			Size = UDim2.fromScale(0.98, 0.75),
			BackgroundTransparency = 1,
			create("Frame")({
				Name = "Background",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.95, 1),
				BackgroundColor3 = function()
					local cardColor = data.CardColor

					if cardColor ~= nil then
						return (read(cardColor))
					end

					local variant = data.Variant
					local styleFor = RowTheme.styleFor
					local v2

					if variant ~= nil then
						v2 = read(variant)
					end

					return styleFor(v2).CardColor
				end,
				create("UICorner")({
					CornerRadius = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).CardCorner
					end
				}),
				create("UIGradient")({
					Color = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).CardGradient
					end,
					Rotation = 0
				})
			}),
			create("Frame")({
				Name = "SpotFrame",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.02, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 3,
				create("UICorner")({
					CornerRadius = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).PlateCorner
					end
				}),
				create("UIGradient")({
					Color = function()
						return RarityTheme.gradientFor(rarity())
					end,
					Rotation = 60
				}),
				create("UIStroke")({
					Color = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).PlateStrokeColor
					end,
					Thickness = 0.03,
					StrokeSizingMode = 1
				}),
				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.45, 1.45),
					BackgroundTransparency = 1,
					Image = data.Icon,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 4
				}),
				tierStars(data, style)
			}),
			create("Frame")({
				Name = "Info",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.2, 0.5),
				Size = UDim2.fromScale(0.7, 1),
				BackgroundTransparency = 1,
				create("UIPadding")({
					PaddingTop = UDim.new(0.05, 0),
					PaddingBottom = UDim.new(0.05, 0)
				}),
				create("Frame")({
					Name = "Bar",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0.01, 0.5),
					Size = UDim2.fromScale(0.008, 1),
					BackgroundColor3 = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).SeparatorColor
					end,
					create("UIGradient")({
						Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
						Rotation = -90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.3, 0),
							NumberSequenceKeypoint.new(0.7, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				}),
				create("TextLabel")({
					Name = "NameLabel",
					Position = UDim2.fromScale(0.05, 0),
					Size = UDim2.fromScale(0.6, 0.3),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesFredokaOnejson,
					Text = data.Label,
					TextColor3 = function()
						local titleColor = data.TitleColor

						if titleColor ~= nil then
							return (read(titleColor))
						end

						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).TitleColor
					end,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				}),
				create("TextLabel")({
					Name = "Rarity",
					Position = UDim2.fromScale(0.05, 0.3),
					Size = UDim2.fromScale(0.28, 0.2),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					Text = function()
						return RarityTheme.labelFor(rarity())
					end,
					TextColor3 = rarityColor,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				}),
				create("TextLabel")({
					Name = "Bonus",
					Position = UDim2.fromScale(0.05, 0.5),
					Size = UDim2.fromScale(0.22, 0.35),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					Text = defaulted(data.Bonus, ""),
					TextColor3 = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).BonusColor
					end,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				}),
				create("TextLabel")({
					Name = "StatLabel",
					Position = UDim2.fromScale(0.28, 0.6),
					Size = UDim2.fromScale(0.4, 0.23),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson2,
					Text = defaulted(data.StatLabel, ""),
					TextColor3 = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v2

						if variant ~= nil then
							v2 = read(variant)
						end

						return styleFor(v2).SubTextColor
					end,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.06)
				}),
				amountText(data, style)
			}),
			create("Frame")({
				Name = "Buttons",
				Position = UDim2.fromScale(0.2206, 0.85),
				Size = UDim2.fromScale(0.7794, 0.3),
				BackgroundTransparency = 1,
				ZIndex = 2,
				create("UIListLayout")({
					Padding = UDim.new(0.02, 0),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				ownedPill(data, owned, style),
				v
			})
		})
	})
end

return ItemRow