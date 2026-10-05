local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
require("../state")
local module = require("../components/window")
local module2 = require("../components/div")
require("../components/buttonHover")
local module3 = require("../actions/buttonSounds")
local ui = ReplicatedStorage.resources.sounds.sfx.ui

local function tabButton(data)
	return vide.create("ImageButton")({
		Name = data.text,
		Image = data.image,
		ScaleType = Enum.ScaleType.Crop,
		ImageRectSize = data.rectSize,
		ImageRectOffset = data.rectOffset,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 0.35,
		ImageTransparency = 0.3,
		Activated = data.onClick,
		vide.create("UIStroke")({
			Transparency = 0.6,
			Color = Color3.fromRGB(255, 255, 255)
		}),
		vide.create("TextLabel")({
			Text = data.text,
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextScaled = true,
			BackgroundTransparency = 1,
			FontFace = Font.fromName("SourceSans", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			vide.create("UIStroke")({
				Transparency = 0.35
			})
		}),
		module3({
			click = ui.click1,
			hover = ui.itemhover
		})
	})
end

return function()
	local source = vide.source("settings")
	return module({
		name = "menu",
		size = UDim2.fromScale(0.5, 0.55),
		aspectRatio = 0.8,
		module2({
			Position = UDim2.fromScale(0.5, 1.02),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(1, 0.1),
			vide.create("UIListLayout")({
				Wraps = false,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.05, 0)
			}),
			tabButton({
				image = "rbxassetid://17849811557",
				text = "Settings",
				onClick = function()
					source("settings")
				end
			}),
			tabButton({
				image = "rbxassetid://84913846294018",
				rectOffset = Vector2.new(400, 350),
				rectSize = Vector2.new(200, 50),
				text = "Stats",
				onClick = function()
					source("stats")
				end
			})
		})
	})
end