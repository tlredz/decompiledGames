local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0, 0)
local training = ReplicatedStorage.Assets.Sounds.Training

local function PlayTrainingSound(childName: string)
	local child = training:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone.Parent = script
	clone:Play()
	clone.Ended:Once(function()
		clone:Destroy()
	end)
end

return function(parent, options)
	local v = options or {}
	local maid = v.Thread and v.Thread:Extend() or faye.new()
	local stop = v.Stop
	local counterStart = v.CounterStart or 50
	local counterWin = v.CounterWin or 100
	local counterLose = v.CounterLose or 0
	local counterGain = v.CounterGain or 8
	local counterLoss = v.CounterLoss or 10
	local counterDrain = v.CounterDrain or 0.7
	local v2 = (v.CounterTick or 0.1) * PlatformLeniency()
	local counterColorStart = v.CounterColorStart or color
	local counterColorEnd = v.CounterColorEnd or color2
	local counterShakeThreshold = v.CounterShakeThreshold or 30
	local counterShakeAmplitude = v.CounterShakeAmplitude or 8
	local counterShakeFrequency = v.CounterShakeFrequency or 25
	local v3 = counterStart
	local value = maid:Value(math.floor(v3) .. "%")
	local textColor = maid:Value(counterColorStart)
	local position = maid:Value(UDim2.fromScale(0.5, 0.5))
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish(flag2: boolean)
		if flag then
			return
		end

		flag = true

		if stop then
			stop(flag2)
		end

		maid:Destroy()
	end

	local function adjustCounter(p2: number)
		if flag then
			return
		end

		v3 = math.clamp(v3 + p2, counterLose, counterWin)
		value:Set(math.floor(v3) .. "%")
		textColor:Set(Utility.Lerp_Color2(
			counterColorEnd,
			counterColorStart,
			(v3 - counterLose) / (counterWin - counterLose)
		))

		if counterWin <= v3 then
			finish(true) -- equivalent call inferred; original call site unknown
		elseif v3 <= counterLose then
			finish(false) -- equivalent call inferred; original call site unknown
		end
	end

	maid:Create("Frame")({
		Parent = parent,
		Name = "Progressholder",
		Size = TrainingUiScale.Size(UDim2.fromScale(0.2, 0.3)),
		Position = UDim2.fromScale(0.5, TrainingUiScale.Factor() > 1 and 0.95 or 0.98),
		AnchorPoint = Vector2.new(0.5, 1),
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = 3
		}),
		BackgroundTransparency = 1,
		maid:Create("TextLabel")({
			Size = UDim2.fromScale(1, 0.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansSemibold,
			Text = value,
			ZIndex = 2,
			TextColor3 = textColor,
			TextScaled = true
		}),
		maid:Create("ImageLabel")({
			Name = "Bg",
			Image = "rbxassetid://134657809787110",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ImageColor3 = Color3.new(0.05, 0.05, 0.05)
		}),
		maid:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			maid:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1.05),
			GradientButton(maid, {
				Text = "Exit",
				TextXAlignment = Enum.TextXAlignment.Center,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(1, 0.3)
				}),
				Clicked = function()
					PlayTrainingSound("TrainingExit")
					finish(false) -- equivalent call inferred; original call site unknown
				end,
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0)
				}
			})
		})
	})
	local total = 0
	maid:Add(RunService.RenderStepped:Connect(function(dt)
		if v3 < counterShakeThreshold then
			total += dt
			local v4 = (counterShakeThreshold - v3) / counterShakeThreshold
			local v5 = total * counterShakeFrequency
			local v6 = math.noise(v5, 0, 0) * counterShakeAmplitude * v4
			local v7 = math.noise(0, v5, 7.3) * counterShakeAmplitude * v4
			position:Set(UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(v6, v7))
		else
			total = 0
			position:Reset()
		end
	end))
	task.spawn(function()
		while maid.IsActive and task.wait(v2) do
			adjustCounter(-counterDrain)
		end
	end)
	return {
		Hit = function()
			adjustCounter(counterGain)
		end,
		Miss = function()
			adjustCounter(-counterLoss)
		end,
		Destroy = function()
			maid:Destroy()
		end,
		Counter = value
	}
end