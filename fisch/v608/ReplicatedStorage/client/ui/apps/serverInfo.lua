local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
local module = require("../state")
local module2 = require("../components/gui")

local function formatSeconds(serverUptime: number)
	local v = serverUptime // 86400
	local v2 = serverUptime // 3600 % 24
	local v3 = serverUptime // 60 % 60
	return string.format("Uptime: %dD %0dH %0dM", v, v2, v3)
end

return function()
	return module2({
		core = false,
		name = "serverInfo",
		vide.create("Frame")({
			Name = "serverInfo",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Interactable = false,
			Visible = function()
				return module.serverInfoEnabled()
			end,
			Position = UDim2.new(0.007, 0, 0.9304, -64),
			Size = UDim2.fromScale(0.125, 0.025),
			AnchorPoint = Vector2.new(0, 1),
			vide.create("UIAspectRatioConstraint")({
				Name = "UIAspectRatioConstraint",
				AspectRatio = 10
			}),
			vide.create("TextLabel")({
				Name = "uptime",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Size = UDim2.fromScale(0.919, 1),
				Text = function()
					return formatSeconds(module.serverUptime())
				end,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextTransparency = 0.82,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				vide.create("UIStroke")({
					Name = "UIStroke",
					Color = Color3.fromRGB(172, 172, 172),
					Transparency = 0.9
				})
			}),
			vide.create("UIListLayout")({
				Name = "UIListLayout",
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),
			vide.create("TextLabel")({
				Name = "region",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(2.12, 1),
				Text = function()
					local serverCity = module.serverCity()
					local serverRegion = module.serverRegion()
					return (`Location: [{module.serverCountryCode()}] {serverRegion}, {serverCity}`)
				end,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextTransparency = 0.82,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				vide.create("UIStroke")({
					Name = "UIStroke",
					Color = Color3.fromRGB(172, 172, 172),
					Transparency = 0.9
				})
			}),
			vide.create("TextLabel")({
				Name = "version",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Size = UDim2.fromScale(0.919, 1),
				Text = function()
					return (`Version {module.serverVersion()}`)
				end,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextTransparency = 0.82,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				vide.create("UIStroke")({
					Name = "UIStroke",
					Color = Color3.fromRGB(172, 172, 172),
					Transparency = 0.9
				})
			})
		})
	})
end