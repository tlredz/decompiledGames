local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = {
	One = "Toolbar_1st",
	Two = "Toolbar_2nd",
	Three = "Toolbar_3rd",
	Four = "Toolbar_4th",
	Five = "Toolbar_5th"
}
local ToolbarItemRestrictions = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ToolbarItemRestrictions)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.SlotDragger)
local v2 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five"
}
local data = Utility.GetData(localPlayer, true)
local info = faye.Info(0.2)
return function(object, p: number, data2, p2, object2, object3, callback)
	local function dragRefused()
		return callback ~= nil and callback() == false
	end

	local image = object:Value("")
	local value2 = object:Value(Color3.new())
	local value3 = object:Value(0.8)
	local value4 = object:Value(UDim2.fromScale(1, 1))
	local value5 = object:Value(1)
	local imageTransparency = object:Value(0)
	local value7 = object:Value(0.4)
	local imageTransparency2 = object:Value(1)
	local image2 = object:Value(ToolbarItemRestrictions.Inventory.Locked.Icon)
	local v3 = object2:Add({
		{
			Index = p,
			Key = v2[p]
		},
		data2,
		value2,
		value3,
		value4,
		value5,
		image,
		imageTransparency,
		value7,
		imageTransparency2,
		image2
	}):Call()
	v3:Connect(data2.Id.Changed)
	v3:Connect(data2.Restrictions.Changed)
	return object:Create("TextButton")({
		Name = p .. "_ToolPosition",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		MouseEnter = function()
			object3:SetHover(v2[p])
		end,
		MouseLeave = function()
			object3:ClearHover(v2[p])
		end,
		MouseButton1Down = function(p3)
			local v4

			if callback == nil then
				v4 = false
			else
				v4 = callback() == false
			end

			if v4 then
				return
			end

			object3:Begin(p3, v2[p])
		end,
		function(p3)
			object3:Attach(v2[p], p3, function()
				local v4

				if callback == nil then
					v4 = false
				else
					v4 = callback() == false
				end

				if v4 then
					return nil
				end

				local v5 = data2.Restrictions:Get()

				if data.Inventory.Toolbar[v2[p]].Value == 0 or v5.ActionsDisabled then
					return nil
				end

				return image:Get()
			end)
		end,
		MouseButton1Up = function()
			local v4 = data2.Restrictions:Get()

			if object3.Dragging:Compare(nil) and not (v4.Locked or v4.ActionsDisabled) then
				if p2.Value == p then
					p2.Value = 0
				else
					p2.Value = p
				end
			end
		end,
		object:Create("ImageLabel")({
			Name = "Bg",
			ZIndex = -1,
			Image = "http://www.roblox.com/asset/?id=134657809787110",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(2.15, 2.15),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.new(0.15, 0.15, 0.15),
			ImageTransparency = object:Animation(value7, info)
		}),
		object:Create("ImageLabel")({
			Name = "CircleSelect",
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = object:Animation(value3, info),
			ImageColor3 = object:Animation(value2, info),
			Image = "http://www.roblox.com/asset/?id=119489413451678",
			object:Create("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = object:Animation(value4, info),
				Position = UDim2.fromScale(0.5, 0.5),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),
				BackgroundTransparency = 1,
				object:Create("UIStroke")({
					Thickness = 2,
					Transparency = object:Animation(value5, info),
					Color = Color3.new(1, 1, 1)
				})
			})
		}),
		object:Create("ImageLabel")({
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 10,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = image2,
			ImageTransparency = imageTransparency2,
			object:Create("UIShadow")({
				Color = gameSettings.noSaveOverlayShadowColor,
				Transparency = object:Do(function(callback2)
					local v4 = callback2(imageTransparency2)
					return 1 - (1 - gameSettings.noSaveOverlayShadowTransparency) * (1 - v4)
				end),
				BlurRadius = gameSettings.noSaveOverlayShadowBlur
			})
		}),
		object:Create("ImageLabel")({
			ZIndex = 2,
			Name = "Image",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = imageTransparency
		}),
		Utility.AddTag(object:Create("Frame")({
			Name = v[data2.Key] or data2.Key,
			BackgroundTransparency = gameSettings.KeybindTextTransparency,
			AnchorPoint = Vector2.new(0.5, 1),
			Size = gameSettings.KeybindTextSize,
			Position = UDim2.new(0.5, 0, 1, gameSettings.KeybindTextOffset),
			ZIndex = -1
		}), "UIkey")
	})
end