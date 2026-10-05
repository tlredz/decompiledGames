local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local faye = require(ReplicatedStorage.Packages.faye)
local random = Random.new()
local TweenService = game:GetService("TweenService")
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

local inOut = Enum.EasingDirection.InOut
local sine = Enum.EasingStyle.Sine
local v = { 0.025, 0.125 }
local color = Color3.new(0.14902, 0.894118, 0.14902)
local color2 = Color3.new(1, 0, 0)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 0, 0)
local info = faye.Info(0.1)
local info2 = faye.Info(0.3)
return function(parent, options)
	local v2 = options or {}
	local v3 = v2.Thread and v2.Thread:Extend() or faye.new()
	local stop = v2.Stop
	local platformLeniency = PlatformLeniency()
	local v5 = (v2.SlideCycle or 2) * platformLeniency
	local size = v2.Size or v
	local graceHitbox = v2.GraceHitbox or 0.025
	local easingStyle = v2.EasingStyle or sine
	local easingDirection = v2.EasingDirection or inOut
	local successColor = v2.SuccessColor or color
	local failColor = v2.FailColor or color2
	local bubbleTransitionInfo = v2.BubbleTransitionInfo or info
	local transitionInfo = v2.TransitionInfo or info2
	local counterStart = v2.CounterStart or 50
	local counterWin = v2.CounterWin or 100
	local counterLose = v2.CounterLose or 0
	local counterGain = v2.CounterGain or 12
	local counterLoss = v2.CounterLoss or 5
	local counterDrain = v2.CounterDrain or 1
	local v6 = (v2.CounterTick or 0.2) * platformLeniency
	local counterColorStart = v2.CounterColorStart or color3
	local counterColorEnd = v2.CounterColorEnd or color4
	local counterShakeThreshold = v2.CounterShakeThreshold or 30
	local counterShakeAmplitude = v2.CounterShakeAmplitude or 8
	local counterShakeFrequency = v2.CounterShakeFrequency or 25
	local v7 = nil
	local v8 = nil
	local v9 = nil
	local v10 = nil
	local v11 = false
	local fn
	local slider = nil
	local v12 = counterStart
	local text = v3:Value(math.floor(v12) .. "%")
	local textColor = v3:Value(counterColorStart)
	local position = v3:Value(UDim2.fromScale(0.5, 0.5))
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

		v3:Destroy()
	end

	local function adjustCounter(p2: number)
		if flag then
			return
		end

		v12 = math.clamp(v12 + p2, counterLose, counterWin)
		text:Set(math.floor(v12) .. "%")
		textColor:Set(Utility.Lerp_Color2(
			counterColorEnd,
			counterColorStart,
			(v12 - counterLose) / (counterWin - counterLose)
		))

		if counterWin <= v12 then
			finish(true) -- equivalent call inferred; original call site unknown
		elseif v12 <= counterLose then
			finish(false) -- equivalent call inferred; original call site unknown
		end
	end

	local guiInset = GuiService:GetGuiInset()
	local instance = v3:Create("CanvasGroup")({
		Name = "Hitbox",
		Parent = parent,
		Size = UDim2.new(1, 0, 1, guiInset.Y),
		Position = UDim2.new(0, 0, 0, -guiInset.Y),
		BackgroundTransparency = 1,
		GroupTransparency = v3:Animation(0, transitionInfo, {
			From = 1
		}),
		CleanDelay = transitionInfo.Time,
		OnClean = function(object)
			return {
				GroupTransparency = object:Animation(1, transitionInfo)
			}
		end,
		InputBegan = function(_, p2)
			if p2.UserInputType ~= Enum.UserInputType.MouseButton1 and p2.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local instance2 = v7 and v7.Instance

			if slider == nil or instance2 == nil or v9 == nil then
				return
			end

			local v13 = math.abs(slider.Position.X.Scale - v9) <= v10 + graceHitbox
			v11 = v13
			PlayTrainingSound(v13 and "TrainingCompleteTRUE" or "TrainingCompleteFALSE")
			adjustCounter(v13 and counterGain or -counterLoss)

			if not flag then
				fn()
			end
		end
	}).Instance
	local instance2 = v3:Create("Frame")({
		Name = "Bg",
		Parent = instance,
		Size = UDim2.fromScale(1, TrainingUiScale.Of(0.15)),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(),
		CleanDelay = transitionInfo.Time,
		v3:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.75, 0.925),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Rotation = -90
		}),
		v3:Create("Frame")({
			Name = "BarHolder",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(0.15, 0.15),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			v3:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(1, 0.8)
				}),
				Rotation = 170
			}),
			v3:Create("UIStroke")({
				BorderOffset = UDim.new(0, 2),
				Thickness = 1,
				Color = Color3.new(1, 1, 1),
				v3:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.75),
						NumberSequenceKeypoint.new(1, 0.9)
					}),
					Rotation = 10
				})
			}),
			v3:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			v3:Create("Frame")({
				Name = "Slider",
				Size = UDim2.new(0, 2, 1, 0),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 0.901961, 0),
				BorderSizePixel = 1
			})
		}),
		v3:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			v3:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.925),
			GradientButton(v3, {
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
		}),
		v3:Create("Frame")({
			Name = "Progressholder",
			ZIndex = -1,
			Size = UDim2.fromScale(0.2, 1),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			v3:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			v3:Create("TextLabel")({
				Size = UDim2.fromScale(1, 0.2),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = position,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSansSemibold,
				Text = text,
				ZIndex = 2,
				TextColor3 = textColor,
				TextScaled = true
			}),
			v3:Create("ImageLabel")({
				Name = "Bg",
				Image = "rbxassetid://134657809787110",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ImageColor3 = Color3.new(0.05, 0.05, 0.05)
			})
		})
	}).Instance
	slider = instance2.BarHolder.Slider
	local total = 0
	local total2 = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if v3.IsActive then
			total += dt
			local value4 = TweenService:GetValue(1 - math.abs(1 - total % (v5 * 2) / v5), easingStyle, easingDirection)
			slider.Position = UDim2.fromScale(value4, 0)

			if v12 < counterShakeThreshold then
				total2 += dt
				local v14 = (counterShakeThreshold - v12) / counterShakeThreshold
				local v15 = total2 * counterShakeFrequency
				local v16 = math.noise(v15, 0, 0) * counterShakeAmplitude * v14
				local v17 = math.noise(0, v15, 7.3) * counterShakeAmplitude * v14
				position:Set(UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(v16, v17))
			else
				total2 = 0
				position:Reset()
			end
		else
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end)
	task.spawn(function()
		while v3.IsActive and task.wait(v6) do
			adjustCounter(-counterDrain)
		end
	end)

	fn = function()
		if v8 then
			v8:Destroy()
		end

		local v13 = random:NextNumber() * (size[2] - size[1]) + size[1]
		local v14 = v13 / 2 + random:NextNumber() * (1 - v13)
		v9 = v14
		v10 = v13 / 2
		v8 = v3:Extend()
		v7 = v8:Create("Frame")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = v8:Animation(UDim2.fromScale(v13, 1), bubbleTransitionInfo, {
				From = UDim2.fromScale(0, 1)
			}),
			Position = UDim2.fromScale(v14, 0.5),
			Parent = instance2.BarHolder,
			BackgroundColor3 = Color3.new(0.729412, 0.839216, 1),
			CleanDelay = transitionInfo.Time,
			v8:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			OnClean = function(object)
				return {
					BackgroundColor3 = object:Animation(v11 and successColor or failColor, transitionInfo),
					BackgroundTransparency = object:Animation(1, transitionInfo)
				}
			end
		})
	end

	fn()
	return function()
		v3:Destroy()
	end, text
end