local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.new(1, 0, 0)
local info = faye.Info(0.3)
local info2 = faye.Info(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
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

return function(parent, callback)
	local v = faye.new()
	local v2 = false
	local lastTime = os.clock()
	local value = v:Value(150)
	local v3 = false
	v:Spawn(function()
		while task.wait(0.5) do
			local v4 = math.floor(150 - (os.clock() - lastTime))
			value:Set(v4)

			if not (v4 <= 0) then
				continue
			end

			if callback == nil then
				break
			end

			callback()
			break
		end
	end)
	v:Create("CanvasGroup")({
		Name = "BoulderPushUI",
		Size = UDim2.fromScale(1, TrainingUiScale.Of(0.2)),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Parent = parent,
		BackgroundTransparency = 1,
		v:Create("Frame")({
			Name = "Bg",
			ZIndex = -1,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(),
			v:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.6, 0.7),
					NumberSequenceKeypoint.new(0.8, 0.9),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			})
		}),
		GroupTransparency = v:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = v:Animation(1, info)
			}
		end,
		v:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			v:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.95),
			GradientButton(v, {
				Text = "Exit",
				TextXAlignment = Enum.TextXAlignment.Center,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(1, 0.3)
				}),
				Clicked = function()
					if v2 or callback == nil then
						return
					end

					v2 = true

					if PopUpCreator.new({
						Type = "Question",
						Content = "Are you sure you want to leave?"
					}).Result:Wait(5) == "Yes" then
						PlayTrainingSound("TrainingExit")
						callback()
					end

					v2 = false
				end,
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0)
				}
			})
		}),
		v:Create("Frame")({
			Size = UDim2.fromScale(0.2, 0.25),
			Position = UDim2.new(1, -15, 1, -15),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			v:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.005, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			v:Create("Frame")({
				Name = "bIcon",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Instance.new("UIAspectRatioConstraint"),
				v:Create("ImageLabel")({
					Name = "Main",
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120352136875263"
				})
			}),
			v:Create("TextLabel")({
				Name = "aTxt",
				Size = UDim2.fromScale(1, 0.7),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.0375, 0.5),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextTransparency = 0,
				Font = Enum.Font.SourceSansSemibold,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = Color3.new(1, 1, 1),
				Text = v:Do(function(callback2, animator, animation)
					local v4 = callback2(value)

					if v4 <= 10 then
						ReplicatedStorage.Assets.Sounds.Misc.countDown.TimePosition = 0
						ReplicatedStorage.Assets.Sounds.Misc.countDown:Play()

						if not v3 then
							v3 = true
							animation.Parent.bIcon.Main.Rotation = -15
							animator:LoadAnimation(animation, {
								TextColor3 = color
							}, info2):Play()
							animator:LoadAnimation(animation.Parent.bIcon.Main, {
								Rotation = 15,
								ImageColor3 = color
							}, info2):Play()
						end
					end

					return Utility.formatTime(v4)
				end)
			})
		})
	})
	return function()
		v:Destroy()
	end
end