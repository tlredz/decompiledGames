local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
require(script.Parent.Types)
local Ping = require(script.Parent.Ping)
local MapSettings = require(ReplicatedStorage.CAM.Client.Modules.MapSettings)
local color = Color3.new()
local uDim = UDim.new(1, 0)
local info = faye.Info(0.25, Enum.EasingStyle.Back)
local info2 = faye.Info(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color2 = Color3.new(0.443, 0.746, 1)
return function(object, p, data)
	local v = p.Side * 0.675
	return object:Create("Frame")({
		Name = "Placed",
		ZIndex = 5,
		Visible = MapSettings.Watch(object, "PlacedMarker"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(data.Spot.X, data.Spot.Y),
		Size = object:Animation(UDim2.fromOffset(v, v), info, {
			From = UDim2.new()
		}),
		Rotation = -p.Rotation,
		BackgroundTransparency = 1,
		CleanDelay = info.Time,
		OnClean = {
			Size = UDim2.new()
		},
		Ping(object, {
			Color = color2,
			ZIndex = 0
		}),
		function()
			if data.Preview then
				return nil
			end

			return { object:Create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = object:Animation(UDim2.fromScale(0.5, 0.25), info2, {
						From = UDim2.fromScale(0.5, 0.5)
					}),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://140481492902657",
					object:Create("UIShadow")({
						Color = color,
						Transparency = 0.5,
						BlurRadius = uDim
					})
				}), object:Create("TextButton")({
					Name = "Hitbox",
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(3, 3),
					BackgroundTransparency = 1,
					Visible = data.Clickable,
					function(parent)
						local frame = Instance.new("Frame")
						frame.Name = "NoSelection"
						frame.BackgroundTransparency = 1
						frame.Size = UDim2.new()
						frame.Parent = parent
						parent.SelectionImageObject = frame
					end,
					MouseButton1Click = function()
						data.Clicked()
					end
				}) }
		end
	})
end