local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local color = Color3.new(0.05, 0.05, 0.05)
local uDim = UDim.new(0.8, 0)
local uDim2 = UDim2.fromScale(-0.35, -0.35)
local info = faye.Info(0.15, Enum.EasingStyle.Back)

local function Arrow(object, flag: boolean, name: string, flag2: boolean, fn)
	local value = object:Value(0.25)
	local v = flag2 and 1.2 or 1
	return object:Create("TextButton")({
		Name = flag and "CNext" or "APrev",
		AnchorPoint = Vector2.new(flag and 1 or 0, 0.5),
		Position = UDim2.fromScale(flag and 0.94 or 0.06, 0.5),
		Size = UDim2.fromScale(v * 0.62, v * 0.62),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		object:Create("UIAspectRatioConstraint")({}),
		object:Create("ImageLabel")({
			Name = "Glyph",
			Image = BunchaIcons.ServerBrowser.Arrow,
			Rotation = flag and 0 or 180,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1 / v, 1 / v),
			BackgroundTransparency = 1,
			ImageTransparency = object:Animation(value, info)
		}),
		Utility.AddTag(object:Create("Frame")({
			Name = name,
			AnchorPoint = Vector2.new(flag and 0 or 1, 0.5),
			Position = UDim2.new(flag and 1.25 or -0.25, 0, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = gameSettings.KeybindTextTransparency,
			object:Create("UIAspectRatioConstraint")({})
		}), "UIkey"),
		MouseEnter = function()
			value:Set(0)
		end,
		MouseLeave = function()
			value:Reset()
		end,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()
			fn()
		end
	})
end

return function(object, p, flag: boolean, callback)
	return object:Create("Frame")({
		Name = "Browser",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, -0.2),
		Size = UDim2.fromScale(0.75, 0.16),
		BackgroundTransparency = 1,
		ZIndex = 5,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIShadow")({
			Color = color,
			BlurRadius = uDim,
			Spread = uDim2,
			Transparency = 0.25
		}),
		Arrow(object, false, "Emotes_Prev", flag, function()
			callback(-1)
		end),
		Arrow(object, true, "Emotes_Next", flag, function()
			callback(1)
		end),
		object:Create("TextLabel")({
			Name = "BPage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.6),
			BackgroundTransparency = 1,
			Text = object:Do(function(callback2)
				return (`Page {callback2(p)}`)
			end),
			TextScaled = true,
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.SemiBold,
				Enum.FontStyle.Normal
			),
			TextColor3 = Color3.new(1, 1, 1)
		})
	})
end