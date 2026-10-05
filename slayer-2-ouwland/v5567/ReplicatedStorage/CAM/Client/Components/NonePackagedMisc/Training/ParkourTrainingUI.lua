local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local tweenInfo = TweenInfo.new(gameSettings.lifeLostFadeTime)
local localPlayer = Players.LocalPlayer
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
local info2 = faye.Info(0.125, Enum.EasingStyle.Sine)
local info3 = faye.Info(0.5)
local v = {
	Mobile = 6,
	Xbox = 5
}
local info4 = faye.Info(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
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
	local v2 = false
	local v3 = faye.new()
	local Y = GuiService:GetGuiInset().Y
	local result = {}
	local lastTime = os.clock()
	local v4 = (localPlayer == nil or localPlayer:GetAttribute("Device") ~= "Mobile") and 360 or 503.99999999999994
	local value = v3:Value(v4)
	local v5 = localPlayer == nil and 4 or v[localPlayer:GetAttribute("Device")] or 4

	for i = 1, v5 do
		result[i] = v3:Value(true)
	end

	v3:Spawn(function(...)
		while task.wait(0.5) do
			local v6 = math.floor(v4 - (os.clock() - lastTime))
			value:Set(v6)

			if not (v6 <= 0 and callback ~= nil) then
				continue
			end

			callback()
			break
		end
	end)
	local v6 = false
	v3:Create("CanvasGroup")({
		Name = "ParkourTrainingUI",
		ZIndex = -10,
		Size = UDim2.new(1, 0, 1, Y),
		Position = UDim2.fromOffset(0, -Y),
		Parent = parent,
		BackgroundTransparency = 1,
		GroupTransparency = v3:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = v3:Animation(1, info3)
			}
		end,
		v3:Create("Frame")({
			Name = "Top",
			Size = UDim2.fromScale(1, 0.35),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.15,
			v3:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = 90
			})
		}),
		v3:Create("Frame")({
			Size = TrainingUiScale.Size(UDim2.fromScale(0.2, 0.045)),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.05, 0, 0.05, Y),
			BackgroundTransparency = 1,
			v3:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.005, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			v3:Create("Frame")({
				Name = "Icon",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Instance.new("UIAspectRatioConstraint"),
				v3:Create("ImageLabel")({
					Name = "Main",
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120352136875263"
				})
			}),
			v3:Create("TextLabel")({
				Name = "Txt",
				Size = UDim2.fromScale(1, 0.7),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.0375, 0.5),
				BackgroundTransparency = 1,
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.new(1, 1, 1),
				Text = v3:Do(function(callback2, animator, animation)
					local v7 = callback2(value)

					if v7 <= 30 then
						ReplicatedStorage.Assets.Sounds.Misc.countDown.TimePosition = 0
						ReplicatedStorage.Assets.Sounds.Misc.countDown:Play()

						if not v6 then
							v6 = true
							animation.Parent.Icon.Main.Rotation = -15
							animator:LoadAnimation(animation, {
								TextColor3 = Color3.new(1, 0, 0)
							}, info4):Play()
							animator:LoadAnimation(animation.Parent.Icon.Main, {
								Rotation = 15,
								ImageColor3 = Color3.new(1, 0, 0)
							}, info4):Play()
						end
					end

					return Utility.formatTime(v7)
				end)
			})
		}),
		v3:Create("Frame")({
			Size = UDim2.fromScale(0.04, 0.04),
			AnchorPoint = Vector2.new(0.5, 0),
			Instance.new("UIAspectRatioConstraint"),
			Position = UDim2.new(0.5, 0, 0.015, Y),
			BackgroundTransparency = 1,
			v3:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.15)
			}),
			v3:Iterate(result, function(p2, p3, _, _)
				local value2 = v3:Value(UDim2.fromScale(1, 1))
				local value3 = v3:Value(UDim2.fromScale(1.2, 1.2))
				p3.Changed:Connect(function()
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
				return v3:Create("Frame")({
					CleanDelay = info3.Time,
					Size = UDim2.fromScale(1, 1),
					Name = "heart" .. p2,
					BackgroundTransparency = 1,
					v3:Create("ImageLabel")({
						BackgroundTransparency = 1,
						Size = v3:Animation(value3, info2),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Name = "Bg",
						ImageColor3 = Color3.new(0.45, 0.2, 0.2),
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0.35
					}),
					v3:Create("ImageLabel")({
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ImageColor3 = Color3.new(1, 0, 0),
						Size = v3:Animation(value2, info2),
						Name = "Fg",
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0
					})
				})
			end)
		}),
		v3:Create("Frame")({
			Name = "Bottom",
			Size = UDim2.fromScale(1, 0.1),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.5,
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			v3:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0.65),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			}),
			v3:Create("Frame")({
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.095, 0.5),
				Name = "ButtonHolder",
				v3:Create("UIAspectRatioConstraint")({
					AspectRatio = 4
				}),
				GradientButton(v3, {
					Text = "Exit",
					TextXAlignment = Enum.TextXAlignment.Center,
					GradientTransparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.75),
						NumberSequenceKeypoint.new(1, 0.3)
					}),
					Clicked = function()
						if v2 == false then
							v2 = true

							if PopUpCreator.new({
								Type = "Question",
								Content = "Are you sure you want to leave the Dungeon?"
							}).Result:Wait(5) == "Yes" then
								PlayTrainingSound("TrainingExit")
								callback()
							end

							v2 = false
						end
					end,
					Properties = {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0)
					}
				})
			})
		})
	})
	return function()
		v3:Destroy()
	end, result, v5
end