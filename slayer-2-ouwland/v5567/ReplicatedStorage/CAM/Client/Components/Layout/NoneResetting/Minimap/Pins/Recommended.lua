local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local RecommendedQuest = require(ReplicatedStorage.CAM.Client.Modules.RecommendedQuest)
require(script.Parent.Types)
local Plate = require(script.Parent.Plate)
local Ping = require(script.Parent.Ping)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
local color = Color3.fromRGB(255, 176, 46)
local sourceSansBold = Enum.Font.SourceSansBold
return function(maid, data)
	local value = maid:Value(RecommendedQuest.Get())
	maid:Add(RecommendedQuest.Changed:Connect(function(p)
		value:Set(p)
	end))
	return maid:Create("Frame")({
		Name = "Recommended",
		Visible = MapSettings.Watch(maid, "RecommendedQuest"),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		maid:State(function(callback, object)
			local v = callback(value)

			if v == nil or v.Position == nil then
				return
			end

			local point = data.Point(v.Position)
			return object:Create("Frame")({
				Name = v.Npc,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(point.X, point.Y),
				Size = UDim2.fromOffset(data.Side, data.Side),
				Rotation = -data.Rotation,
				BackgroundTransparency = 1,
				Ping(object, {
					Color = color,
					ZIndex = 1
				}),
				Plate(object, {
					Icon = v.Icon or "",
					ZIndex = 2
				}),
				object:Create("TextLabel")({
					Name = "Label",
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 0.2),
					Size = UDim2.fromScale(4, 0.5),
					BackgroundTransparency = 1,
					Text = v.Npc,
					TextScaled = true,
					Font = sourceSansBold,
					TextColor3 = Color3.new(1, 1, 1),
					TextStrokeTransparency = 0.5
				})
			})
		end)
	})
end