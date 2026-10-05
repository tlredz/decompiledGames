local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
local WorldBosses = require(ReplicatedStorage.CAM.Client.Modules.WorldBosses)
require(script.Parent.Types)
local Plate = require(script.Parent.Plate)
local color = Color3.new(0.2, 0.2, 0.2)
local color2 = Color3.new(1, 1, 1)
local sourceSansBold = Enum.Font.SourceSansBold
local info = faye.Info(0.3)
return function(maid, data, data2)
	local value = maid:Value(Archives.IsUnlocked("Bosses", data2.Code))
	maid:Add(Archives.Connect("Bosses", function(list)
		if table.find(list, data2.Code) ~= nil then
			value:Set(true)
		end
	end))
	local icon = maid:Value(data2.Icon or "")
	maid:Add(WorldBosses.Updated:Connect(function()
		icon:Set(data2.Icon or "")
	end))
	local point = data.Point(data2.Position)
	return maid:Create("Frame")({
		Name = data2.Code,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(point.X, point.Y),
		Size = UDim2.fromOffset(data.Side, data.Side),
		Rotation = -data.Rotation,
		BackgroundTransparency = 1,
		Plate(maid, {
			Icon = icon,
			Visible = MapSettings.Watch(maid, "BossIcons"),
			IconColor = maid:Do(function(callback)
				local v2

				if callback(value) then
					v2 = color2
				else
					v2 = color
				end

				return maid:Animation(v2, info)
			end)
		}),
		maid:Create("TextLabel")({
			Name = "Label",
			Visible = MapSettings.Watch(maid, "BossNames"),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.2),
			Size = UDim2.fromScale(4, 0.5),
			BackgroundTransparency = 1,
			Text = maid:Do(function(callback)
				if callback(value) then
					return data2.Name
				end

				return "???"
			end),
			TextScaled = true,
			Font = sourceSansBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextStrokeTransparency = 0.5
		})
	})
end