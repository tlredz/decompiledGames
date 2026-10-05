local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Button = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.Button)
local PanelModal = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.PanelModal)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local RewardLine = require(script.Parent.RewardLine)
local Theme = require(script.Parent.Theme)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local uDim = UDim2.fromScale(0.5, 0.5)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
local v = {
	idle = Color3.fromRGB(180, 180, 190),
	sending = Color3.fromRGB(180, 180, 190),
	success = Color3.fromRGB(120, 220, 140),
	error = Color3.fromRGB(255, 120, 120)
}

local function sanitize(value: string)
	return (string.sub(string.gsub(string.upper(value), "[^A-Z0-9]", ""), 1, 32))
end

local function ownerStrip(data, fn)
	local v2 = defaulted(data.OwnerName, "")
	return create("Frame")({
		Name = "OwnerStrip",
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0.18),
		BackgroundTransparency = 1,
		Visible = function()
			return read(v2) ~= ""
		end,
		create("ImageLabel")({
			Name = "OwnerAvatar",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.02, 0.5),
			Size = UDim2.fromScale(0.16, 0.9),
			BackgroundTransparency = 1,
			Image = function()
				local v3 = read(defaulted(data.OwnerUserId, 0))

				if v3 > 0 then
					return (string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", v3))
				end

				return ""
			end,
			create("UIAspectRatioConstraint")({
				AspectRatio = 1
			}),
			create("UICorner")({
				CornerRadius = UDim.new(0.5, 0)
			})
		}),
		create("TextLabel")({
			Name = "OwnerLabel",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0.2, 0.05),
			Size = UDim2.fromScale(0.78, 0.45),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = function()
				return (`A gift from {read(v2)}`)
			end,
			TextColor3 = function()
				return fn().OwnerTextColor
			end,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			create("UIStroke")({
				Color = function()
					return fn().OwnerStrokeColor
				end,
				Thickness = 0.1,
				StrokeSizingMode = 1
			})
		}),
		create("TextLabel")({
			Name = "CodeLabel",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0.2, 0.95),
			Size = UDim2.fromScale(0.78, 0.4),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson2,
			Text = defaulted(data.Label, ""),
			TextColor3 = function()
				return fn().LabelTextColor
			end,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	})
end

local function header(data, text, fn)
	return create("Frame")({
		Name = "CodeHeader",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		create("TextBox")({
			Name = "CodeInput",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.68, 0.8),
			BackgroundColor3 = function()
				return fn().InputColor
			end,
			BackgroundTransparency = 0.15,
			ClearTextOnFocus = false,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			PlaceholderText = "ENTER CODE",
			PlaceholderColor3 = function()
				return fn().InputPlaceholderColor
			end,
			Text = text,
			TextColor3 = function()
				return fn().InputTextColor
			end,
			TextScaled = true,
			FocusLost = function(flag: boolean)
				local onSubmit = flag and data.OnSubmit

				if onSubmit then
					onSubmit(text())
				end
			end,
			Vide.changed("Text", function(value: string)
				text((string.sub(string.gsub(string.upper(value), "[^A-Z0-9]", ""), 1, 32)))
			end),
			create("UICorner")({
				CornerRadius = UDim.new(0.25, 0)
			}),
			create("UIStroke")({
				Color = function()
					return fn().InputStrokeColor
				end,
				Thickness = 0.03,
				StrokeSizingMode = 1
			}),
			create("UIPadding")({
				PaddingLeft = UDim.new(0.04, 0),
				PaddingRight = UDim.new(0.04, 0)
			})
		}),
		Button({
			Name = "SubmitButton",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(0.29, 0.8),
			Text = "REDEEM",
			Gradient = function()
				return fn().SubmitGradient
			end,
			StrokeColor = function()
				return fn().SubmitStrokeColor
			end,
			OnActivated = function()
				local onSubmit = data.OnSubmit

				if onSubmit then
					onSubmit(text())
				end
			end
		})
	})
end

local function CodeModal(data)
	local source = Vide.source("")
	local v2 = defaulted(data.Rewards, {})
	local v3 = defaulted(data.Theme, Theme.defaultName())

	local function fn()
		return Theme.styleFor(read(v3))
	end

	return PanelModal({
		Name = data.Name or "CodeModal",
		Visible = data.Visible,
		BannerText = "REDEEM CODE",
		StatusText = defaulted(data.Message, ""),
		StatusColor = function()
			return v[read(defaulted(data.Status, "idle"))]
		end,
		BackgroundColor = function()
			return Theme.styleFor(read(v3)).BackgroundColor
		end,
		GradientColor = function()
			return Theme.styleFor(read(v3)).BodyGradient
		end,
		GradientRotation = function()
			return Theme.styleFor(read(v3)).BodyGradientRotation
		end,
		OuterStrokeColor = function()
			return Theme.styleFor(read(v3)).OuterStrokeColor
		end,
		InnerStrokeColor = function()
			return Theme.styleFor(read(v3)).InnerStrokeColor
		end,
		PanelColor = function()
			return Theme.styleFor(read(v3)).PanelColor
		end,
		PanelTransparency = function()
			return Theme.styleFor(read(v3)).PanelTransparency
		end,
		PanelGradient = function()
			return Theme.styleFor(read(v3)).PanelGradient
		end,
		PanelStrokeColor = function()
			return Theme.styleFor(read(v3)).PanelStrokeColor
		end,
		BannerColor = function()
			return Theme.styleFor(read(v3)).BannerColor
		end,
		BannerTextColor = function()
			return Theme.styleFor(read(v3)).BannerTextColor
		end,
		BannerStrokeColor = function()
			return Theme.styleFor(read(v3)).BannerStrokeColor
		end,
		StatusGradient = function()
			return Theme.styleFor(read(v3)).StatusGradient
		end,
		StatusTextColor = function()
			return Theme.styleFor(read(v3)).StatusTextColor
		end,
		StatusStrokeColor = function()
			return Theme.styleFor(read(v3)).StatusStrokeColor
		end,
		CloseColor = function()
			return Theme.styleFor(read(v3)).CloseColor
		end,
		CloseGradient = function()
			return Theme.styleFor(read(v3)).CloseGradient
		end,
		CloseOuterStrokeColor = function()
			return Theme.styleFor(read(v3)).CloseOuterStrokeColor
		end,
		CloseInnerStrokeColor = function()
			return Theme.styleFor(read(v3)).CloseInnerStrokeColor
		end,
		CloseIconGradient = function()
			return Theme.styleFor(read(v3)).CloseIconGradient
		end,
		Header = header(data, source, fn),
		HeaderHeight = 0.2,
		ListPadding = UDim.new(0.02, 0),
		Size = defaulted(data.Size, uDim),
		AspectRatio = defaulted(data.AspectRatio, 1.4),
		OnClose = data.OnClose
	}, { ownerStrip(data, fn), Vide.indexes(function()
			return read(v2)
		end, function(callback, layoutOrder: number)
			return RewardLine({
				Name = `Reward{layoutOrder}`,
				LayoutOrder = layoutOrder,
				CardColor = function()
					return Theme.styleFor(read(v3)).RowCardColor
				end,
				CardGradient = function()
					return Theme.styleFor(read(v3)).RowCardGradient
				end,
				StrokeColor = function()
					return Theme.styleFor(read(v3)).RowStrokeColor
				end,
				TitleColor = function()
					return Theme.styleFor(read(v3)).RowTitleColor
				end,
				TitleStrokeColor = function()
					return Theme.styleFor(read(v3)).RowTitleStrokeColor
				end,
				DetailColor = function()
					return Theme.styleFor(read(v3)).RowDetailColor
				end,
				AmountColor = function()
					return Theme.styleFor(read(v3)).RowAmountColor
				end,
				AmountStrokeColor = function()
					return Theme.styleFor(read(v3)).RowAmountStrokeColor
				end,
				Icon = function()
					return callback().icon or ""
				end,
				Title = function()
					return callback().title
				end,
				Detail = function()
					return callback().detail or ""
				end,
				Amount = function()
					return callback().amount or ""
				end
			})
		end) })
end

return CodeModal