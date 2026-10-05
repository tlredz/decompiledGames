local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
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

local random = Random.new()
local TweenService = game:GetService("TweenService")
local out = Enum.EasingDirection.Out
local linear = Enum.EasingStyle.Linear
local color = Color3.new(0.14902, 0.894118, 0.14902)
local color2 = Color3.new(1, 0, 0)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 0, 0)
local info = faye.Info(0.3)
return function(parent, options)
	local v = options or {}
	local maid = v.Thread and v.Thread:Extend() or faye.new()
	local stop = v.Stop
	local platformLeniency = PlatformLeniency()
	local v3 = (v.AppearTime or 1.5) * platformLeniency
	local v4 = (v.LifeTime or 3) * platformLeniency
	local easingDirection = v.EasingDirection or out
	local easingStyle = v.EasingStyle or linear
	local startShrinking = v.StartShrinking or 1.5
	local endShrinking = v.EndShrinking or 0
	local v5 = (v.ShrinkCycle or 1) * platformLeniency
	local diffAccepted = v.DiffAccepted or 0.125
	local shakeStart = v.ShakeStart or 0.4
	local shakeAmplitude = v.ShakeAmplitude or 6
	local shakeFrequency = v.ShakeFrequency or 35
	local successColor = v.SuccessColor or color
	local failColor = v.FailColor or color2
	local transitionInfo = v.TransitionInfo or info
	local counterStart = v.CounterStart or 50
	local counterWin = v.CounterWin or 100
	local counterLose = v.CounterLose or 0
	local counterGain = v.CounterGain or 25
	local counterLoss = v.CounterLoss or 10
	local counterDrain = v.CounterDrain or 1
	local v6 = (v.CounterTick or 0.1) * platformLeniency
	local counterColorStart = v.CounterColorStart or color3
	local counterColorEnd = v.CounterColorEnd or color4
	local counterShakeThreshold = v.CounterShakeThreshold or 30
	local counterShakeAmplitude = v.CounterShakeAmplitude or 8
	local counterShakeFrequency = v.CounterShakeFrequency or 25
	local instance = maid:Create("Frame")({
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = TrainingUiScale.Size(UDim2.fromScale(0.6, 0.5)),
		ZIndex = 2,
		BackgroundTransparency = 1,
		CleanDelay = transitionInfo.Time,
		OnClean = function(object)
			return {
				BackgroundTransparency = object:Animation(1, transitionInfo)
			}
		end
	}).Instance
	local v7 = counterStart
	local text = maid:Value(math.floor(v7) .. "%")
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

		v7 = math.clamp(v7 + p2, counterLose, counterWin)
		text:Set(math.floor(v7) .. "%")
		textColor:Set(Utility.Lerp_Color2(
			counterColorEnd,
			counterColorStart,
			(v7 - counterLose) / (counterWin - counterLose)
		))

		if counterWin <= v7 then
			finish(true) -- equivalent call inferred; original call site unknown
		elseif v7 <= counterLose then
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
			Text = text,
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
		if v7 < counterShakeThreshold then
			total += dt
			local v8 = (counterShakeThreshold - v7) / counterShakeThreshold
			local v9 = total * counterShakeFrequency
			local v10 = math.noise(v9, 0, 0) * counterShakeAmplitude * v8
			local v11 = math.noise(0, v9, 7.3) * counterShakeAmplitude * v8
			position:Set(UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(v10, v11))
		else
			total = 0
			position:Reset()
		end
	end))
	task.spawn(function()
		while maid.IsActive and task.wait(v6) do
			adjustCounter(-counterDrain)
		end
	end)
	task.spawn(function()
		while maid.IsActive do
			local extended = maid:Extend()
			local renderSteppedConnection = nil
			local shrink = nil
			local holder = nil
			local v8 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function Complete(flag2: boolean)
				v8 = flag2
				PlayTrainingSound(flag2 and "TrainingCompleteTRUE" or "TrainingCompleteFALSE")
				adjustCounter(flag2 and counterGain or -counterLoss)
			end

			local function Stop()
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end

				Complete(math.abs(shrink.Size.X.Scale - holder.Size.X.Scale) < diffAccepted) -- equivalent call inferred; original call site unknown
				extended:Destroy()
			end

			local uDim = UDim2.fromScale(random:NextNumber(), random:NextNumber())
			local instance2 = extended:Create("Frame")({
				Parent = instance,
				Position = uDim,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.15, 0.15),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				Name = "Pod",
				maid:Create("TextButton")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(startShrinking, startShrinking),
					BackgroundTransparency = 1,
					MouseButton1Up = Stop
				}),
				CleanDelay = transitionInfo.Time,
				extended:Create("Frame")({
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Name = "Holder",
					extended:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					extended:Create("ImageLabel")({
						Size = UDim2.fromScale(1.5, 1.5),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Image = "rbxassetid://134657809787110",
						ImageTransparency = maid:Animation(0, transitionInfo, {
							From = 1
						}),
						OnClean = function(object)
							return {
								ImageTransparency = object:Animation(1, transitionInfo),
								ImageColor3 = object:Animation(v8 and successColor or failColor, transitionInfo)
							}
						end
					}),
					extended:Create("UIStroke")({
						Thickness = 3,
						Color = Color3.new(1, 1, 1),
						Transparency = maid:Animation(0, transitionInfo, {
							From = 1
						}),
						OnClean = function(object)
							return {
								Transparency = object:Animation(1, transitionInfo),
								Color = object:Animation(v8 and successColor or failColor, transitionInfo)
							}
						end
					})
				}),
				extended:Create("Frame")({
					Name = "Shrink",
					Size = UDim2.fromScale(startShrinking, startShrinking),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					extended:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					extended:Create("UIStroke")({
						Thickness = 2,
						Color = Color3.new(1, 1, 1),
						Transparency = maid:Animation(0, transitionInfo, {
							From = 1
						}),
						OnClean = function(object)
							return {
								Transparency = object:Animation(1, transitionInfo),
								Color = object:Animation(v8 and successColor or failColor, transitionInfo)
							}
						end
					})
				})
			}).Instance
			shrink = instance2:FindFirstChild("Shrink")
			holder = instance2:FindFirstChild("Holder")
			local total2 = 0
			local v10 = extended
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				if maid.IsActive and v10.IsActive then
					total2 += dt
					local value4 = TweenService:GetValue(
						1 - math.abs(1 - total2 % (v5 * 2) / v5),
						easingStyle,
						easingDirection
					)
					local v14 = startShrinking + (endShrinking - startShrinking) * value4
					shrink.Size = UDim2.fromScale(v14, v14)
					local v15 = v4 * shakeStart

					if v15 <= total2 then
						local v16 = math.clamp((total2 - v15) / (v4 - v15), 0, 1)
						local v17 = total2 * shakeFrequency
						local v18 = math.noise(v17, 0, 0) * shakeAmplitude * v16
						local v19 = math.noise(0, v17, 7.3) * shakeAmplitude * v16
						instance2.Position = uDim + UDim2.fromOffset(v18, v19)
					end
				else
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
			local v13 = extended
			task.delay(v4, function()
				if not maid.IsActive then
					return
				end

				if v13.IsActive then
					Complete(false) -- equivalent call inferred; original call site unknown
					v13:Destroy()
				end
			end)
			task.wait(v3)
		end
	end)
	return function()
		maid:Destroy()
	end, text
end