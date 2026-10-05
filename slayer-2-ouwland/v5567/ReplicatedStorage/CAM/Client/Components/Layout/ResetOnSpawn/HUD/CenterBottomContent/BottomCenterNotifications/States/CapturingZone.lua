local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(255, 160, 50)
return function(object)
	local value = object:Value(localPlayer:GetAttribute("RescueZoneProgress") or 0)
	object:Connect(localPlayer:GetAttributeChangedSignal("RescueZoneProgress"), function()
		local rescueZoneProgress = localPlayer:GetAttribute("RescueZoneProgress")
		value:Set(typeof(rescueZoneProgress) ~= "number" and 0 or rescueZoneProgress)
	end)
	return object:Create("Frame")({
		Name = "CaptureBar",
		Size = UDim2.fromScale(0.55, 0.5),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.95),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Name = "Percent",
			Size = UDim2.fromScale(1, 0.7),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.fromRGB(255, 220, 175),
			TextStrokeTransparency = 0.6,
			Text = object:Do(function(callback)
				return (`{math.floor(math.clamp(callback(value) or 0, 0, 1) * 100)}%`)
			end)
		}),
		object:Create("Frame")({
			Name = "Track",
			Size = UDim2.fromScale(1, 0.24),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundColor3 = Color3.new(0.12, 0.12, 0.12),
			BackgroundTransparency = 0.35,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("Frame")({
				Name = "Bar",
				BackgroundColor3 = color,
				Size = object:Do(function(callback)
					return UDim2.fromScale(math.clamp(callback(value) or 0, 0, 1), 1)
				end),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			})
		})
	})
end