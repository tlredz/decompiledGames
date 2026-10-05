local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local springInfo = faye.SpringInfo(0.5, 1, 0.5)
local info = faye.Info(1)
local bottomCenterNotifications = game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD.BottomCenterNotifications
local v = 0
return function(object, _, p)
	local now = os.clock()

	if now - v < 5 then
		return
	end

	v = now
	return object:SpecialThread(function(object2, _)
		bottomCenterNotifications.Value += 1
		return object2:Create("Frame")({
			Size = object2:Animation(UDim2.fromScale(0.295, 0.6), springInfo, {
				From = UDim2.fromScale(0.177, 0.36)
			}),
			BackgroundTransparency = 1,
			object2:Create("ImageLabel")({
				Size = UDim2.fromScale(1, 3),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Image = "rbxassetid://73937036803127",
				ImageColor3 = Color3.new(0.1, 0.1, 0.1),
				ImageTransparency = 0.4,
				Name = "Bg",
				CleanFunction = function(object3, _)
					return {
						ImageTransparency = object3:Animation(1, info)
					}
				end
			}),
			object2:Create("ImageLabel")({
				Size = UDim2.fromScale(0.9, 2.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://71833493215551",
				ImageColor3 = Color3.new(0.1, 0.1, 0.1),
				ImageTransparency = 0.4,
				Name = "Fg",
				CleanFunction = function(object3, _)
					return {
						ImageTransparency = object3:Animation(1, info)
					}
				end
			}),
			object2:Create("TextLabel")({
				Size = UDim2.fromScale(1, 0.4),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.15),
				BackgroundTransparency = 1,
				Text = p.Text,
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold,
				Name = "Text",
				CleanFunction = function(object3, _)
					return {
						TextTransparency = object3:Animation(1, info)
					}
				end
			}),
			object2:Create("TextLabel")({
				Size = UDim2.fromScale(1, 0.25),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.55),
				BackgroundTransparency = 1,
				Text = p.SubText,
				TextScaled = true,
				TextTransparency = 0.2,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = Color3.new(1, 1, 1),
				Name = "SubText",
				CleanFunction = function(object3, _)
					return {
						TextTransparency = object3:Animation(1, info)
					}
				end
			}),
			CleanFunction = function()
				bottomCenterNotifications.Value -= 1
			end,
			CleanDelay = 1
		})
	end, {
		Lifetime = 5
	})
end