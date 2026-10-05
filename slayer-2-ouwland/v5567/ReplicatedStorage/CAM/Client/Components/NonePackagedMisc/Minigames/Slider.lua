local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local faye = require(ReplicatedStorage.Packages.faye)
local random = Random.new()
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local tweenInfo = TweenInfo.new(gameSettings.lifeLostFadeTime)
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

local v = { 0.15, 0.375 }
local v2 = { 0.1, 0.25 }
local info = faye.Info(0.3)
local info2 = faye.Info(0.125, Enum.EasingStyle.Sine)
local info3 = faye.Info(0.5)
local size = TrainingUiScale.Size(UDim2.fromScale(0.75, 0.85))
local color = Color3.new(0.615686, 1, 0.615686)
local info4 = faye.Info(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
return function(parent, options)
	local v3 = options or {}
	local stop = v3.Stop
	local onComplete = v3.OnComplete
	local v4 = v3.Thread and v3.Thread:Extend() or faye.new()
	local timer = v3.Timer or 30
	local maxHearts = v3.MaxHearts or 3
	local platformLeniency = PlatformLeniency()
	local v6 = (v3.Lifetime or 4) * platformLeniency
	local v7 = (v3.AppearanceTime or 2) * platformLeniency
	local holderSize = v3.HolderSize or size
	local barSizeX = v3.BarSizeX or v
	local barSizeY = v3.BarSizeY or 0.1
	local radius = v3.Radius or v2
	local draggerXOffset = v3.DraggerXOffset or 7
	local hitboxPadding = v3.HitboxPadding or 20
	local transitionInfo = v3.TransitionInfo or info
	local heartTween = v3.HeartTween or info2
	local outInfo = v3.OutInfo or info3
	local lerpBackRate = v3.LerpBackRate or 10
	local shakeStart = v3.ShakeStart or 0.5
	local shakeAmplitude = v3.ShakeAmplitude or 6
	local shakeFrequency = v3.ShakeFrequency or 35
	local lowThreshold = v3.LowThreshold or 10
	local instance = v4:Create("CanvasGroup")({
		Size = holderSize,
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		CleanDelay = transitionInfo.Time,
		GroupTransparency = v4:Animation(0, transitionInfo, {
			From = 1
		}),
		OnClean = function(object)
			return {
				GroupTransparency = object:Animation(1, transitionInfo)
			}
		end
	}).Instance
	local lastTime = os.clock()
	local value = v4:Value(timer)
	local v8 = {}
	local v9 = false

	for i = 1, maxHearts do
		v8[i] = v4:Value(true)
	end

	task.spawn(function()
		while v4.IsActive and task.wait(0.5) do
			local v10 = math.floor(timer - (os.clock() - lastTime))
			value:Set(v10)

			if not (v10 <= 0) then
				continue
			end

			if stop ~= nil then
				stop(true)
			end

			v4:Destroy()
			break
		end
	end)
	v4:Spawn(function()
		while instance ~= nil and instance.Parent ~= nil do
			local extended = v4:Extend()
			local v10 = 6.283185307179586 * random:NextNumber()
			local v11 = random:NextNumber() * (radius[2] - radius[1]) + radius[1]
			local v12 = math.cos(v10) * v11
			local v13 = math.sin(v10) * v11
			local v14 = random:NextInteger(1, 2) == 1
			local v15 = false
			local v16 = false
			local v17 = nil
			local scale = nil
			local now = os.clock()
			local uDim = UDim2.fromScale(v12 + 0.5, v13 + 0.5)
			local v18 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function Complete(flag: boolean)
				v18 = flag
				PlayTrainingSound(flag and "TrainingCompleteTRUE" or "TrainingCompleteFALSE")

				if onComplete then
					onComplete(flag)
				end

				if not flag and maxHearts > 0 then
					v8[maxHearts]:Set(false)
					maxHearts -= 1

					if maxHearts == 0 then
						if stop then
							stop(false)
						end

						v4:Destroy()
					end
				end
			end

			local uDim2 = UDim2.fromScale(random:NextNumber() * (barSizeX[2] - barSizeX[1]) + barSizeX[1], barSizeY)
			local rotation = (random:NextNumber() - 0.5) * 2 * 4 * 15 + (v14 and 0 or 180)
			local v20 = nil
			local instance2 = extended:Create("Frame")({
				Name = "Wrapper",
				Parent = instance,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v12 + 0.5, v13 + 0.5),
				Size = uDim2 + UDim2.fromOffset(hitboxPadding * 2, hitboxPadding * 2),
				Rotation = rotation,
				BackgroundTransparency = 1,
				CleanDelay = transitionInfo.Time,
				MouseEnter = function()
					v16 = true
				end,
				MouseLeave = function()
					v16 = false
					v15 = false
				end,
				extended:Create("CanvasGroup")({
					Name = "MainHolder",
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -hitboxPadding * 2, 1, -hitboxPadding * 2),
					BackgroundTransparency = 1,
					GroupTransparency = v4:Animation(0, transitionInfo, {
						From = 1
					}),
					OnClean = function(object, instance3)
						if instance3.Parent == nil then
							return
						end

						local actual = instance3:FindFirstChild("Actual")

						if actual then
							actual.BackgroundColor3 = Color3.new(1, 1, 1)
						end

						return {
							GroupTransparency = object:Animation(1, transitionInfo),
							GroupColor3 = object:Animation(
								v18 and Color3.new(0.14902, 0.894118, 0.14902) or Color3.new(1, 0, 0),
								transitionInfo
							)
						}
					end,
					After = function(p2)
						v20 = p2
					end,
					v4:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					v4:Create("Frame")({
						v4:Create("UIStroke")({
							Thickness = 1,
							Color = Color3.new(1, 1, 1),
							BorderOffset = UDim.new(0, 2),
							Transparency = 0.5,
							v4:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 0.75)
								}),
								Rotation = 160
							})
						}),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = v4:Animation(UDim2.new(1, -3, 1, -3), springInfo, {
							From = UDim2.new(0.5, -3, 0.5, -3)
						}),
						Name = "Actual",
						v4:Create("UICorner")({
							CornerRadius = UDim.new(1)
						}),
						BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
						BackgroundTransparency = 0.25,
						v4:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 0.65)
							})
						}),
						v4:Create("ImageLabel")({
							Name = "Arrows",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.3, 1.2),
							Rotation = 90,
							BackgroundTransparency = 1,
							Image = "rbxassetid://93693040307287",
							v4:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.65),
									NumberSequenceKeypoint.new(1, 1)
								}),
								Rotation = 90
							})
						}),
						v4:Create("Frame")({
							Name = "Dragger",
							Size = UDim2.new(1, -15, 1, -15),
							AnchorPoint = Vector2.new(0, 0.5),
							ZIndex = 2,
							Position = UDim2.new(0, draggerXOffset, 0.5, 0),
							Instance.new("UIAspectRatioConstraint"),
							v4:Create("UICorner")({
								CornerRadius = UDim.new(1)
							}),
							v4:Create("UIStroke")({
								Thickness = 1,
								BorderOffset = UDim.new(0, 4),
								Color = Color3.new(1, 1, 1),
								v4:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0),
										NumberSequenceKeypoint.new(0.1, 0.7),
										NumberSequenceKeypoint.new(1, 1)
									}),
									Rotation = 180
								})
							}),
							v4:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 0.5)
								}),
								Rotation = 180
							}),
							v4:Create("TextButton")({
								Name = "Hitbox",
								Text = "",
								Size = UDim2.new(1.2, 15, 1.2, 15),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								BackgroundTransparency = 1,
								ZIndex = 3,
								MouseButton1Down = function()
									v15 = true
								end,
								MouseButton1Up = function()
									v15 = false
								end
							})
						}),
						v4:Create("Frame")({
							Name = "Final",
							Size = UDim2.new(1, -6, 1, -6),
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -3, 0.5, 0),
							Instance.new("UIAspectRatioConstraint"),
							v4:Create("UICorner")({
								CornerRadius = UDim.new(1)
							}),
							BackgroundTransparency = 0,
							BackgroundColor3 = Color3.new(0.615686, 1, 0.615686),
							OnClean = function(p2)
								if p2 == nil or p2.Parent == nil then
									return
								else
									return {
										BackgroundColor3 = Color3.new(1, 1, 1)
									}
								end
							end,
							v4:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.85),
									NumberSequenceKeypoint.new(1, 0.95)
								}),
								Rotation = 170
							}),
							v4:Create("UIStroke")({
								Thickness = 1,
								Color = Color3.new(1, 1, 1),
								Transparency = 0.5,
								BorderOffset = UDim.new(0, 2),
								v4:Create("UIGradient")({
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 0),
										NumberSequenceKeypoint.new(1, 0.75)
									}),
									Rotation = 160
								})
							})
						})
					})
				})
			}).Instance
			task.spawn(function()
				while extended.IsActive do
					local v25 = task.wait()

					if v20.Parent == nil then
						break
					end

					local actual = v20:FindFirstChild("Actual")
					local dragger = actual and actual:FindFirstChild("Dragger")
					local final = actual and actual:FindFirstChild("Final")

					if not actual or not dragger or not final or actual.AbsoluteSize.X <= 0 then
						continue
					end

					local v26 = os.clock() - now

					if shakeStart <= v26 then
						local v27 = math.clamp((v26 - shakeStart) / (v6 - shakeStart), 0, 1)
						local v28 = v26 * shakeFrequency
						local v29 = math.noise(v28, 0, 0) * shakeAmplitude * v27
						local v30 = math.noise(0, v28, 7.3) * shakeAmplitude * v27
						instance2.Position = uDim + UDim2.fromOffset(v29, v30)
					end

					local v27 = 1 - (6 + final.AbsoluteSize.X) / actual.AbsoluteSize.X

					if v15 and v16 then
						local v28 = v20.AbsolutePosition + v20.AbsoluteSize / 2
						local v29 = Vector2.new(mouse.X, mouse.Y) - v28
						local absoluteRotation = math.rad(v20.AbsoluteRotation)
						local v30 = (v29.X * math.cos(absoluteRotation) + v29.Y * math.sin(absoluteRotation) + v20.AbsoluteSize.X / 2) / v20.AbsoluteSize.X

						if v17 == nil then
							v17 = v30
							scale = dragger.Position.X.Scale
						end

						local v31 = v30 - v17
						local v32 = math.clamp(scale + v31, 0, v27)
						dragger.Position = UDim2.new(v32, draggerXOffset, 0.5, 0)

						if v27 <= v32 then
							Complete(true) -- equivalent call inferred; original call site unknown
							extended:Destroy()
							break
						end
					else
						v17 = nil
						scale = nil
						local scale2 = dragger.Position.X.Scale
						local v28 = math.min(1, lerpBackRate * v25)
						dragger.Position = UDim2.new(scale2 * (1 - v28), draggerXOffset, 0.5, 0)
					end
				end
			end)
			local v25 = extended
			task.delay(v6, function()
				if not v4.IsActive then
					return
				end

				if v25.IsActive then
					Complete(false) -- equivalent call inferred; original call site unknown
					v25:Destroy()
				end
			end)
			task.wait(v7)
		end
	end)
	v4:Create("CanvasGroup")({
		Size = UDim2.fromScale(1, TrainingUiScale.Of(0.2)),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Parent = parent,
		BackgroundTransparency = 1,
		v4:Create("Frame")({
			Name = "Bg",
			ZIndex = -1,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(),
			v4:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = -90
			})
		}),
		GroupTransparency = v4:Animation(0, transitionInfo, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = v4:Animation(1, transitionInfo)
			}
		end,
		v4:Create("Frame")({
			Size = UDim2.fromScale(0.2, 0.225),
			Instance.new("UIAspectRatioConstraint"),
			Position = UDim2.new(0.5, 0, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			v4:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.15)
			}),
			v4:Iterate(v8, function(p2, p3, _, _)
				local value2 = v4:Value(UDim2.fromScale(1, 1))
				local value3 = v4:Value(UDim2.fromScale(1.2, 1.2))
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
				return v4:Create("Frame")({
					CleanDelay = outInfo.Time,
					Size = UDim2.fromScale(1, 1),
					Name = "heart" .. p2,
					BackgroundTransparency = 1,
					v4:Create("ImageLabel")({
						BackgroundTransparency = 1,
						Size = v4:Animation(value3, heartTween),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Name = "Bg",
						ImageColor3 = Color3.new(0.45, 0.2, 0.2),
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0.35
					}),
					v4:Create("ImageLabel")({
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ImageColor3 = Color3.new(1, 0, 0),
						Size = v4:Animation(value2, heartTween),
						Name = "Fg",
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0
					})
				})
			end)
		}),
		v4:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			v4:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.95),
			GradientButton(v4, {
				Text = "Exit",
				TextXAlignment = Enum.TextXAlignment.Center,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(1, 0.3)
				}),
				Clicked = function()
					if stop ~= nil then
						PlayTrainingSound("TrainingExit")
						stop(false)
					end
				end,
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0)
				}
			})
		}),
		v4:Create("Frame")({
			Size = UDim2.fromScale(0.2, 0.25),
			Position = UDim2.new(1, -15, 1, -15),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			v4:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.005, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			v4:Create("Frame")({
				Name = "bIcon",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Instance.new("UIAspectRatioConstraint"),
				v4:Create("ImageLabel")({
					Name = "Main",
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120352136875263"
				})
			}),
			v4:Create("TextLabel")({
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
				Text = v4:Do(function(callback, animator, animation)
					local v10 = callback(value)

					if v10 <= lowThreshold then
						ReplicatedStorage.Assets.Sounds.Misc.FriendlierCountdown.TimePosition = 0
						ReplicatedStorage.Assets.Sounds.Misc.FriendlierCountdown:Play()

						if not v9 then
							v9 = true
							animation.Parent.bIcon.Main.Rotation = -15
							animator:LoadAnimation(animation, {
								TextColor3 = color
							}, info4):Play()
							animator:LoadAnimation(animation.Parent.bIcon.Main, {
								Rotation = 15,
								ImageColor3 = color
							}, info4):Play()
						end
					end

					return (`Survive {Utility.formatTime(v10)}`)
				end)
			})
		})
	})
	return function()
		v4:Destroy()
	end, value
end