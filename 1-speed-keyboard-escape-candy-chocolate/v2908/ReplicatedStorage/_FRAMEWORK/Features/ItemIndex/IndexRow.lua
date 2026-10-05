local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local RarityTheme = require(script.Parent.RarityTheme)
require(script.Parent.Types)
local Richtext = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Richtext)
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

local function textStroke(color, thickness: number)
	return create("UIStroke")({
		Color = color,
		Thickness = thickness,
		StrokeSizingMode = 1
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
		create("UIListLayout")({
			Padding = UDim.new(-0.06, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		v
	})
end

local function ownedPill(data, owned, style)
	return create("Frame")({
		Name = "OwnedPill",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(0.98, 0.5),
		Size = UDim2.fromScale(0.22, 0.38),
		BackgroundColor3 = function()
			return style().OwnedColor
		end,
		ZIndex = 4,
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
			Size = UDim2.fromScale(0.9, 0.66),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = defaulted(data.OwnedText, "OWNED"),
			TextColor3 = function()
				return style().OwnedTextColor
			end,
			TextScaled = true,
			ZIndex = 5,
			textStroke(function()
				return style().AmountStrokeColor
			end, 0.07)
		})
	})
end

local function IndexRow(data)
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

	local function rarity()
		return read(data.Rarity)
	end

	local function dimmed()
		-- equivalent call inferred; original call site unknown
		if owned() then
			return 0
		end

		return 0.45
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

	local function bonusText()
		local bonus = data.Bonus
		local nextBonus = data.NextBonus
		local statLabel = data.StatLabel
		local v = bonus == nil and "" or read(bonus)
		local v2 = nextBonus == nil and "" or read(nextBonus)
		local v3 = statLabel == nil and "" or read(statLabel)
		local v4 = {}

		if v ~= "" then
			local color = Richtext.color
			local variant = data.Variant
			local styleFor = RowTheme.styleFor
			local v5

			if variant ~= nil then
				v5 = read(variant)
			end

			table.insert(v4, color(styleFor(v5).BonusColor, v))
		end

		if v2 ~= "" and v2 ~= v then
			local color = Richtext.color
			local variant = data.Variant
			local styleFor = RowTheme.styleFor
			local v5

			if variant ~= nil then
				v5 = read(variant)
			end

			table.insert(v4, color(styleFor(v5).SubTextColor, "→ " .. v2))
		end

		if v3 == "" then
			return table.concat(v4, " ")
		end

		local color = Richtext.color
		local variant = data.Variant
		local styleFor = RowTheme.styleFor
		local v5

		if variant ~= nil then
			v5 = read(variant)
		end

		table.insert(v4, color(styleFor(v5).SubTextColor, v3))
		return table.concat(v4, " ")
	end

	return create("TextButton")({
		Name = data.Name or "IndexRow",
		LayoutOrder = data.LayoutOrder or 0,
		Size = defaulted(data.Size, UDim2.fromScale(1, 0.33)),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Active = data.OnActivated ~= nil,
		MouseButton1Click = data.OnActivated,
		create("Frame")({
			Name = "Container",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.98, 0.86),
			BackgroundTransparency = 1,
			create("Frame")({
				Name = "Background",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = function()
					local variant = data.Variant
					local styleFor = RowTheme.styleFor
					local v

					if variant ~= nil then
						v = read(variant)
					end

					return styleFor(v).CardColor
				end,
				BackgroundTransparency = dimmed,
				create("UICorner")({
					CornerRadius = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).CardCorner
					end
				}),
				create("UIGradient")({
					Color = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).CardGradient
					end,
					Rotation = 0
				})
			}),
			create("Frame")({
				Name = "SpotFrame",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.015, 0.5),
				Size = UDim2.fromScale(0.86, 0.86),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 3,
				create("UICorner")({
					CornerRadius = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).PlateCorner
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
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).PlateStrokeColor
					end,
					Thickness = 0.03,
					StrokeSizingMode = 1
				}),
				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.35, 1.35),
					BackgroundTransparency = 1,
					Image = data.Icon,
					ImageTransparency = dimmed,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 4
				}),
				tierStars(data, style)
			}),
			create("Frame")({
				Name = "Info",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.17, 0.5),
				Size = UDim2.fromScale(0.55, 0.88),
				BackgroundTransparency = 1,
				create("TextLabel")({
					Name = "NameLabel",
					Position = UDim2.fromScale(0, 0.04),
					Size = UDim2.fromScale(1, 0.38),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesFredokaOnejson,
					Text = data.Label,
					TextColor3 = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).TitleColor
					end,
					TextTransparency = dimmed,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				}),
				create("TextLabel")({
					Name = "Rarity",
					Position = UDim2.fromScale(0, 0.46),
					Size = UDim2.fromScale(0.45, 0.24),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					Text = function()
						return RarityTheme.labelFor(rarity())
					end,
					TextColor3 = function()
						local variant = data.Variant
						local styleFor = RowTheme.styleFor
						local v

						if variant ~= nil then
							v = read(variant)
						end

						return styleFor(v).RarityColor or RarityTheme.textColorFor(rarity())
					end,
					TextTransparency = dimmed,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				}),
				create("TextLabel")({
					Name = "Bonus",
					Position = UDim2.fromScale(0, 0.72),
					Size = UDim2.fromScale(1, 0.28),
					BackgroundTransparency = 1,
					FontFace = rbxassetfontsfamiliesGothamSSmjson,
					RichText = true,
					Text = bonusText,
					TextTransparency = dimmed,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					textStroke(titleStrokeColor, 0.08)
				})
			}),
			ownedPill(data, owned, style)
		})
	})
end

return IndexRow