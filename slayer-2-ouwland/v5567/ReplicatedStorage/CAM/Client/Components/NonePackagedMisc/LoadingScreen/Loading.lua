local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.Config)
local faye = require(ReplicatedStorage.Packages.faye)
return function(object)
	return object:Create("ImageLabel")({
		Image = "rbxassetid://16708634837",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Name = "LoadingBg",
		ImageTransparency = object:Animation(0.85, Config.InInfo, {
			From = 1
		}),
		OnClean = function()
			return {
				ImageTransparency = object:Animation(1, Config.TransitionInfo)
			}
		end,
		object:Create("ImageLabel")({
			Image = "rbxassetid://16708879099",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Name = "LoadingFg",
			Rotation = object:Animation(360, faye.Info(2.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, -1)),
			ImageTransparency = object:Animation(0, Config.InInfo, {
				From = 1
			}),
			OnClean = function()
				return {
					ImageTransparency = object:Animation(1, Config.TransitionInfo)
				}
			end
		})
	})
end