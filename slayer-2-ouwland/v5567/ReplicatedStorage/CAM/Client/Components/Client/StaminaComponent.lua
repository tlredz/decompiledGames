local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local faye = require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local info = faye.Info
local v = info(0.3)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local stamina = Utility.getvaluesfolder(localPlayer, true):WaitForChild("Stamina")
local max = math.max
local min = math.min
local numberSequence = NumberSequence
local numberSequenceKeypoint = NumberSequenceKeypoint
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.1)
local tweenInfo2 = TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v2 = info(0.75)

function actuateProg(object, value: number)
	if object == nil then
		return
	end

	local v3 = value or 1
	local new = numberSequence.new
	local v4

	if v3 == 0 then
		v4 = 1
	else
		v4 = {
			numberSequenceKeypoint.new(0, 1),
			numberSequenceKeypoint.new(max(0.5 - v3 * 0.5 - 0.0002 - 0.0002, 0.0002), 1),
			numberSequenceKeypoint.new(max(0.5 - v3 * 0.5 - 0.0002, 0.0004), 0),
			numberSequenceKeypoint.new(0.5, 0),
			numberSequenceKeypoint.new(min(v3 * 0.5 + 0.5 + 0.0002, 0.9996), 0),
			numberSequenceKeypoint.new(min(v3 * 0.5 + 0.5 + 0.0002 + 0.0002, 0.9998), 1),
			numberSequenceKeypoint.new(1, 1)
		}
	end

	object:Set(new(v4))
	return object
end

return function(parent)
	local v3 = nil
	local v4 = faye.new()
	local value = v4:Value(1)
	local value2 = v4:Value(1)
	local value3 = v4:Value(1)
	local transparency = actuateProg(v4:Value(), 0)
	local value4 = v4:Value(1)
	v4:Connect(game.ReplicatedStorage.Communication.CnC.NotEnoughStamina.Event, function(p2)
		actuateProg(transparency, p2)
		value4:Refresh()
	end)
	local transparency2 = v4:Value()
	local v6 = v4:Create("NumberValue")({
		Value = stamina.Value / stamina.MaxValue
	})
	local transparency3 = v4:Value()
	local v7 = v4:Create("NumberValue")({
		Value = stamina.Value / stamina.MaxValue
	})

	local function updateTransparent(flag: boolean)
		if flag == false then
			value:Reset()
			value2:Reset()
			value3:Reset()
		else
			value:Set(0.5)
			value2:Set(0.75)
			value3:Set(0)
		end
	end

	local v8 = false

	local function setProg()
		local v9 = math.random(1, 999)
		local v10 = stamina.Value / stamina.MaxValue
		TweenService:Create(v6, tweenInfo, {
			Value = v10
		}):Play()
		TweenService:Create(v7, tweenInfo2, {
			Value = v10
		}):Play()
		local v11 = true

		if v3 == nil then
			v11 = v10 ~= 1
		elseif v10 == 1 then
			task.delay(1, function()
				if v3 == v9 and v4.IsActive then
					value:Reset()
					value2:Reset()
					value3:Reset()
					v8 = false
				end
			end)
		else
			v11 = true
		end

		if v11 ~= v8 then
			updateTransparent(v11)
			v8 = v11
		end

		v3 = v9
	end

	local v9 = nil
	local v10 = nil
	v4:Reactive(function(callback)
		local v11 = callback(v6)
		local v12 = callback(v7)

		if v9 ~= v11 then
			actuateProg(transparency2, v11)
			v9 = v11
		end

		if v10 ~= v12 then
			actuateProg(transparency3, v12)
			v10 = v12
		end
	end)
	setProg()
	v4:Connect(stamina.Changed, setProg)
	v4:Create("Frame")({
		Size = isRunning and UDim2.fromScale(1, 1) or UDim2.fromScale(0.95, 0.65),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = parent,
		BackgroundTransparency = 1,
		v4:Create("ImageLabel")({
			Name = "Bg'sBg",
			ImageColor3 = Color3.new(),
			ImageTransparency = v4:Animation(value, v),
			ZIndex = -1,
			Image = "rbxassetid://110106230312715",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.065, 1.3)
		}),
		v4:Create("ImageLabel")({
			Name = "Bg",
			ImageColor3 = Color3.new(),
			ImageTransparency = v4:Animation(value2, v),
			Image = "rbxassetid://89528550122959",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1)
		}),
		v4:Create("ImageLabel")({
			Name = "Fg",
			ImageColor3 = gameSettings.staminaColor,
			ImageTransparency = v4:Animation(value3, v),
			ZIndex = 3,
			Image = "rbxassetid://89528550122959",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			v4:Create("UIGradient")({
				Transparency = transparency2
			})
		}),
		v4:Create("ImageLabel")({
			Name = "RedStaminaMissingBar",
			ImageColor3 = Color3.new(1, 0, 0),
			ImageTransparency = v4:Animation(value4, v2, {
				AlwaysFrom = 0
			}),
			ZIndex = 1,
			Image = "rbxassetid://89528550122959",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			v4:Create("UIGradient")({
				Transparency = transparency
			})
		}),
		v4:Create("ImageLabel")({
			Name = "Fg",
			ImageColor3 = Color3.new(1, 1, 1),
			ImageTransparency = v4:Animation(value3, v),
			ZIndex = 2,
			Image = "rbxassetid://89528550122959",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			v4:Create("UIGradient")({
				Transparency = transparency3
			})
		})
	})
	return function()
		v4:Destroy()
	end
end