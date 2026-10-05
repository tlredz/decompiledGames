local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local faye = require(ReplicatedStorage.Packages.faye)
local TrainingUiScale = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.TrainingUiScale)
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

local uDim = UDim2.fromScale(1.2, 0.1)
local info = faye.Info(0.35)
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0, 0)
local color3 = Color3.new(1, 0.901961, 0)
local color4 = Color3.new(0.368627, 1, 0)
return function(parent, options)
	local v = options or {}
	local stop = v.Stop
	local v2 = v.Thread and v.Thread:Extend() or faye.new()
	local trackerSize = v.TrackerSize or uDim
	local transitionInfo = v.TransitionInfo or info
	local colorStart = v.ColorStart or color
	local colorEnd = v.ColorEnd or color2
	local insideColor = v.InsideColor or color4
	local outsideColor = v.OutsideColor or color3
	local guiInset = GuiService:GetGuiInset()
	local v3 = false
	local startingPercent = v.StartingPercent or 50
	local winPercent = v.WinPercent or 100
	local losePercent = v.LosePercent or 0
	local total = 0
	local position = v2:Value(UDim2.new(0.5, 0, 1 - trackerSize.Y.Scale / 2, 0))
	local v4 = startingPercent
	local text = v2:Value(math.floor(startingPercent) .. "%")
	local value3 = v2:Value(false)
	local value4 = v2:Value(outsideColor)
	local textColor = v2:Value(colorStart)
	local position2 = v2:Value(UDim2.fromScale(0.5, 0.5))
	value3.Changed:Connect(function(p2)
		if p2 then
			value4:Set(insideColor)
		else
			value4:Reset()
		end
	end)
	local total2 = 0
	local v5 = 0
	local position3 = v2:Value(UDim2.new(0.5, 0, 1, 0))
	local v6 = nil
	local v7 = nil
	local v8 = v2:Create("CanvasGroup")
	local v9 = {
		Parent = parent,
		Size = UDim2.new(1, 0, 1, guiInset.Y),
		Position = UDim2.new(0, 0, 0, -guiInset.Y),
		BackgroundTransparency = 1,
		GroupTransparency = v2:Animation(0, transitionInfo, {
			From = 1
		}),
		OnClean = function(object)
			return {
				GroupTransparency = object:Animation(1, transitionInfo)
			}
		end,
		InputBegan = function(_, p2)
			if p2.UserInputType ~= Enum.UserInputType.MouseButton1 and p2.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			v3 = true
		end,
		InputEnded = function(_, p2)
			if p2.UserInputType ~= Enum.UserInputType.MouseButton1 and p2.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			v3 = false
		end
	}
	local v10 = v2:Create("Frame")({
		Size = TrainingUiScale.Size(UDim2.fromScale(0.025, 0.5)),
		v2:Create("UIAspectRatioConstraint")({
			AspectRatio = 0.125
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.75, 0.5),
		v2:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		BackgroundTransparency = 0,
		v2:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.25),
				NumberSequenceKeypoint.new(1, 0.75)
			}),
			Rotation = -90
		}),
		v2:Create("UIStroke")({
			Thickness = 1,
			Color = Color3.new(1, 1, 1),
			BorderOffset = UDim.new(0, 2),
			v2:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.75)
				}),
				Rotation = 160
			})
		}),
		v2:Create("Frame")({
			Name = "tracker",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = trackerSize,
			BackgroundTransparency = 0.8,
			v2:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			ZIndex = 3,
			Position = position,
			BackgroundColor3 = v2:Animation(value4, transitionInfo),
			After = function(p2)
				v6 = p2
			end,
			v2:Create("UIStroke")({
				Thickness = 1,
				Color = v2:Animation(value4, transitionInfo)
			})
		}),
		v2:Create("Frame")({
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position3,
			ZIndex = 2,
			Size = UDim2.fromScale(0.5, 0.5),
			Instance.new("UIAspectRatioConstraint"),
			After = function(p2)
				v7 = p2
			end,
			v2:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			v2:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.5)
				}),
				Rotation = 160
			}),
			v2:Create("UIStroke")({
				Thickness = 1,
				Color = Color3.new(1, 1, 1),
				BorderOffset = UDim.new(0, 2),
				v2:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.65),
						NumberSequenceKeypoint.new(1, 0.8)
					}),
					Rotation = 160
				})
			})
		}),
		v2:Create("Frame")({
			Size = UDim2.new(1, -8, 1, -8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			v2:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			v2:Create("ImageLabel")({
				Size = UDim2.fromScale(3.5, 1),
				Image = "rbxassetid://119835436329241",
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.fromScale(1, 0.4),
				v2:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0.85)
					}),
					Rotation = 160
				})
			}),
			BackgroundColor3 = Color3.new(),
			v2:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.75),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = 230
			}),
			v2:Create("UIStroke")({
				Thickness = 1,
				Color = Color3.new(1, 1, 1),
				BorderOffset = UDim.new(0, 2),
				v2:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.65),
						NumberSequenceKeypoint.new(1, 0.8)
					}),
					Rotation = 160
				})
			})
		})
	})
	local v11 = v2:Create("Frame")
	local v12 = {
		Name = "Progressholder",
		Size = UDim2.fromScale(0.2, 0.3),
		Position = UDim2.fromScale(0.5, 0.98),
		AnchorPoint = Vector2.new(0.5, 1),
		v2:Create("UIAspectRatioConstraint")({
			AspectRatio = 3
		}),
		BackgroundTransparency = 1
	}
	local v13 = v2:Create("TextLabel")({
		Size = UDim2.fromScale(1, 0.2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position2,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansSemibold,
		Text = text,
		ZIndex = 2,
		TextColor3 = textColor,
		TextScaled = true
	})
	local v14 = v2:Create("ImageLabel")({
		Name = "Bg",
		Image = "rbxassetid://134657809787110",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ImageColor3 = Color3.new(0.05, 0.05, 0.05)
	})
	local v15

	if v.NoExit ~= true then
		v15 = v2:Create("Frame")({
			Size = UDim2.fromScale(0.3, 0.27),
			v2:Create("UIAspectRatioConstraint")({
				AspectRatio = 3
			}),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1.05),
			GradientButton(v2, {
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
		})
	end

	v12[2], v12[3], v12[4] = v13, v14, v15
	do local _values = table.pack(v10, v11(v12)); for _k = 1, _values.n do v9[_k] = _values[_k] end end
	v8(v9)
	local v16 = 0
	local v17 = 0
	local total3 = 0
	local v18 = 0
	local platformLeniency = PlatformLeniency()
	local v20 = (v.MinSpeed or 0.08) / platformLeniency
	local v21 = (v.MaxSpeed or 0.48) / platformLeniency
	local v22 = (v.MinCommit or 0.25) * platformLeniency
	local v23 = (v.MaxCommit or 1) * platformLeniency
	local v24 = (v.Smoothing or 4) / platformLeniency
	local v25 = v21 * (v.BarSpeedMult or 1.5)
	local v26 = (v.BarSizeScale or 0.55) * (v.ParentAspect or 0.125) / 2
	local percentStep = v.PercentStep or 1
	local percentGainTick = v.PercentGainTick or 0.1
	local v27 = percentGainTick * (v.PercentLossMult or 0.65)
	local v28 = 0
	local flag = false
	local shakeThreshold = v.ShakeThreshold or 30
	local shakeAmplitude = v.ShakeAmplitude or 8
	local shakeFrequency = v.ShakeFrequency or 25
	local total4 = 0
	local halfScale = trackerSize.Y.Scale / 2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rollVelocity()
		v17 = (v20 + math.random() * (v21 - v20)) * (math.random() < 0.5 and -1 or 1)
		v18 = v22 + math.random() * (v23 - v22)
		total3 = 0
	end

	rollVelocity() -- equivalent call inferred; original call site unknown
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if flag then
			return
		end

		total3 += dt

		if v18 <= total3 then
			rollVelocity() -- equivalent call inferred; original call site unknown
		end

		local v30 = math.min(v24 * dt, 1)
		v16 += (v17 - v16) * v30
		total += v16 * dt

		if total >= 1 then
			total = 1
			v16 = -math.abs(v16)
			v17 = -math.abs(v17)
		elseif total <= 0 then
			total = 0
			v16 = math.abs(v16)
			v17 = math.abs(v17)
		end

		position:Set(UDim2.new(0.5, 0, halfScale + (1 - 2 * halfScale) * (1 - total), 0))
		local v31 = v3 and v25 or -v25
		local v32 = math.min(v24 * dt, 1)
		v5 += (v31 - v5) * v32
		total2 += v5 * dt

		if total2 >= 1 then
			total2 = 1
			v5 = math.min(0, v5)
		elseif total2 <= 0 then
			total2 = 0
			v5 = math.max(0, v5)
		end

		position3:Set(UDim2.new(0.5, 0, v26 + (1 - 2 * v26) * (1 - total2), 0))
		local v33

		if v6 and v7 and v6.AbsoluteSize.Y > 0 then
			local Y = v6.AbsolutePosition.Y
			local v34 = Y + v6.AbsoluteSize.Y
			local Y2 = v7.AbsolutePosition.Y

			if Y <= Y2 + v7.AbsoluteSize.Y then
				v33 = Y2 <= v34
			else
				v33 = false
			end
		else
			v33 = false
		end

		value3:Set(v33)
		local v34 = v33 and percentGainTick or v27
		v28 += dt

		while v34 <= v28 do
			v28 -= v34
			local v35 = v4 + (v33 and percentStep or -percentStep)

			if winPercent <= v35 then
				v4 = winPercent
				text:Set(math.floor(winPercent) .. "%")
				textColor:Set(Utility.Lerp_Color2(colorEnd, colorStart, 1))
				flag = true

				if stop then
					stop(true)
				end

				v2:Destroy()
				break
			elseif v35 <= losePercent then
				v4 = losePercent
				text:Set(math.floor(losePercent) .. "%")
				textColor:Set(Utility.Lerp_Color2(colorEnd, colorStart, 0))
				flag = true

				if stop then
					stop(false)
				end

				v2:Destroy()
				break
			else
				v4 = v35
				text:Set(math.floor(v35) .. "%")
				textColor:Set(Utility.Lerp_Color2(
					colorEnd,
					colorStart,
					(v35 - losePercent) / (winPercent - losePercent)
				))
			end
		end

		if v4 < shakeThreshold then
			total4 += dt
			local v35 = (shakeThreshold - v4) / shakeThreshold
			local v36 = total4 * shakeFrequency
			local v37 = math.noise(v36, 0, 0) * shakeAmplitude * v35
			local v38 = math.noise(0, v36, 7.3) * shakeAmplitude * v35
			position2:Set(UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(v37, v38))
		else
			total4 = 0
			position2:Reset()
		end
	end)
	return function()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		v2:Destroy()
	end, text
end