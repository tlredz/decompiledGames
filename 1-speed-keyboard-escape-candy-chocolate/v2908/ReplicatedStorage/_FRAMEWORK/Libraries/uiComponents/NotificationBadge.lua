local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)

local function NotificationBadge(data)
	local zIndex = data.ZIndex or 13
	return create("Frame")({
		Name = data.Name or "NotificationBadge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = data.Position or UDim2.fromScale(0.92, 0.08),
		Size = data.Size or UDim2.fromScale(0.42, 0.42),
		BackgroundColor3 = data.Color or Color3.fromRGB(220, 50, 50),
		ZIndex = zIndex,
		Visible = function()
			return read(data.Count) > 0
		end,
		create("UICorner")({
			CornerRadius = UDim.new(0.5, 0)
		}),
		create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		create("UIStroke")({
			Color = data.StrokeColor or Color3.fromRGB(90, 10, 10),
			Thickness = 0.08,
			StrokeSizingMode = 1
		}),
		create("TextLabel")({
			Name = "Count",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = function()
				return (tostring(read(data.Count)))
			end,
			TextColor3 = defaulted(data.TextColor, Color3.fromRGB(255, 255, 255)),
			TextScaled = true,
			ZIndex = zIndex
		})
	})
end

return NotificationBadge