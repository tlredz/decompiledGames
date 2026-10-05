local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Character_info_provider)
local faye = require(ReplicatedStorage.Packages.faye)
local localPlayer = game.Players.LocalPlayer
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local info = faye.Info(0.2)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
Utility.GetData(localPlayer, true)
require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.SlotDragger)
return function(object, p, object2, _, object3, object4, callback)
	local image = object:Value("")
	local v = {
		LastState = nil,
		Key = p.Name
	}
	local value2 = object:Value(0.95)
	local textTransparency = object:Value(0.5)
	local imageTransparency = object:Value(0.35)
	local backgroundTransparency = object:Value(0.25)
	local backgroundColor = object:Value(Color3.new(0.15, 0.15, 0.15))
	local visible = object:Value(false)
	object3:Add({
		v,
		p,
		visible,
		image,
		value2,
		textTransparency,
		imageTransparency,
		backgroundColor,
		backgroundTransparency
	}, object):Call():SetId(p.Name)
	return object:Create("Frame")({
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			AutoButtonColor = false,
			MouseButton1Down = function(p2)
				object4:Begin(p2, p.Name)
			end,
			function(p2)
				object4:Attach(p.Name, p2, function()
					if p.Value == 0 then
						return nil
					end

					return image:Get()
				end)
			end,
			MouseButton1Up = function()
				if object4.Dragging:Compare(nil) then
					ScreenEffects.CircleClick()
				end

				object2:Set(p.Name)

				if callback ~= nil and object4.Dragging:Compare(nil) then
					callback(p.Name)
				end
			end,
			MouseEnter = function()
				object4:SetHover(p.Name)
			end,
			MouseLeave = function()
				object4:ClearHover(p.Name)
			end
		}),
		Size = UDim2.fromScale(0.1595, 1),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			Transparency = object:Animation(value2, info)
		}),
		object:Create("ImageLabel")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = imageTransparency,
			ScaleType = Enum.ScaleType.Crop
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(1, 0.65),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			Text = p.Name,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = textTransparency
		}),
		object:Create("Frame")({
			ZIndex = -1,
			Visible = visible,
			Size = UDim2.new(1, -5, 1, -5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.9,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.25)
			}),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = -90
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Transparency = 0.7,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				})
			})
		})
	})
end