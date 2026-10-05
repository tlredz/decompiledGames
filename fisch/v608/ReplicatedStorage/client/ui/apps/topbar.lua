local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local vide = require(ReplicatedStorage.packages.vide)
local module = require("../state")
local module2 = require("../components/gui")

local function topbarButton(data)
	return vide.create("TextButton")({
		Text = data.text,
		Visible = data.visible,
		Activated = data.onClick,
		Size = UDim2.fromScale(1, 1),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.fromEnum(Enum.Font.SourceSansItalic),
		TextScaled = true,
		AutoButtonColor = true,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		vide.create("UIStroke")({
			Transparency = 0.35
		})
	})
end

return function()
	return module2({
		core = false,
		name = "topbar",
		ignoreGuiInset = true,
		vide.create("Frame")({
			Name = "topbar",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 23),
			Size = UDim2.fromOffset(100, 17),
			BackgroundTransparency = 1,
			vide.create("UIListLayout")({
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			topbarButton({
				text = "Menu",
				onClick = function()
					if module.windowRoute() == "menu" then
						module.windowRoute(false)
					else
						module.windowRoute("menu")
					end
				end
			}),
			topbarButton({
				text = "Shop",
				onClick = function()
					if module.windowRoute() == "shop" then
						module.windowRoute(false)
					else
						module.windowRoute("shop")
					end
				end
			}),
			vide.action(function(p)
				task.spawn(function()
					local backpack = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
					p.Interactable = backpack.Visible
					backpack:GetPropertyChangedSignal("Visible"):Connect(function()
						p.Interactable = backpack.Visible
					end)
				end)
			end)
		})
	})
end