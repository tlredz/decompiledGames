local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local faye = require(ReplicatedStorage.Packages.faye)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local localPlayer = Players.LocalPlayer
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local tweenInfo = TweenInfo.new(gameSettings.lifeLostFadeTime)
local info = faye.Info(0.3)
local info2 = faye.Info(0.125, Enum.EasingStyle.Sine)
local info3 = faye.Info(0.5)
local info4 = faye.Info(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local color = Color3.fromRGB(80, 255, 120)
local color2 = Color3.fromRGB(255, 80, 80)
local color3 = Color3.new(1, 1, 1)
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
	local animator = faye.new()
	local value = animator:Value(0)
	local v = { animator:Value(true), animator:Value(true), (animator:Value(true)) }
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flash(textColor: Color3)
		if v2 == nil then
			return
		end

		v2.TextColor3 = textColor
		animator:LoadAnimation(v2, {
			TextColor3 = color3
		}, info4):Play()
	end

	value.Changed:Connect(function()
		flash(color) -- equivalent call inferred; original call site unknown
	end)
	animator:Create("CanvasGroup")({
		Size = UDim2.fromScale(1, TrainingUiScale.Of(0.2)),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Parent = parent,
		BackgroundTransparency = 1,
		animator:Create("Frame")({
			Name = "Bg",
			ZIndex = -1,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(),
			animator:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.85),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			})
		}),
		GroupTransparency = animator:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = animator:Animation(1, info)
			}
		end,
		animator:Create("TextLabel")({
			Name = "aTxt",
			Size = UDim2.fromScale(1, 0.2),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.35),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextTransparency = 0,
			Font = Enum.Font.SourceSansSemibold,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Color3.new(1, 1, 1),
			After = function(p2)
				v2 = p2
			end,
			Text = animator:Do(function(callback2, _, _)
				return (`{callback2(value)} / {10}`)
			end)
		}),
		animator:Create("Frame")({
			Size = UDim2.fromScale(0.2, 0.225),
			Instance.new("UIAspectRatioConstraint"),
			Position = UDim2.new(0.5, 0, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			animator:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.15)
			}),
			animator:Iterate(v, function(p2, p3, _, _)
				local value2 = animator:Value(UDim2.fromScale(1, 1))
				local value3 = animator:Value(UDim2.fromScale(1.2, 1.2))
				p3.Changed:Connect(function()
					flash(color2) -- equivalent call inferred; original call site unknown
					value3:Set(UDim2.fromScale(0.85, 0.85))
					value2:Set(UDim2.fromScale())

					if localPlayer:FindFirstChild("PlayerGui") then
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.Image = "rbxassetid://101053692073571"
						imageLabel.BackgroundTransparency = 1
						imageLabel.Size = UDim2.fromScale(1, 1)
						imageLabel.ImageColor3 = Color3.new(1)
						imageLabel.Parent = localPlayer.PlayerGui.Misc
						TweenService:Create(imageLabel, tweenInfo, {
							ImageTransparency = 1
						}):Play()
						DebrisModule:AddItem(imageLabel, 0.3)
					end
				end)
				return animator:Create("Frame")({
					CleanDelay = info3.Time,
					Size = UDim2.fromScale(1, 1),
					Name = "heart" .. p2,
					BackgroundTransparency = 1,
					animator:Create("ImageLabel")({
						BackgroundTransparency = 1,
						Size = animator:Animation(value3, info2),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Name = "Bg",
						ImageColor3 = Color3.new(0.45, 0.2, 0.2),
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0.35
					}),
					animator:Create("ImageLabel")({
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ImageColor3 = Color3.new(1, 0, 0),
						Size = animator:Animation(value2, info2),
						Name = "Fg",
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0
					})
				})
			end)
		}),
		animator:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			animator:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.95),
			GradientButton(animator, {
				Text = "Exit",
				TextXAlignment = Enum.TextXAlignment.Center,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(1, 0.3)
				}),
				Clicked = function()
					if callback ~= nil then
						PlayTrainingSound("TrainingExit")
						callback(false)
					end
				end,
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0)
				}
			})
		})
	})
	return function()
		animator:Destroy()
	end, v, 3, value, 10
end