local TweenService = game:GetService("TweenService")
game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Util = require(game.ReplicatedStorage.Util)
local VRichText = require(game.ReplicatedStorage.Util.VRichText)
local FX = require(game.ReplicatedStorage.FX)
local cutscene = FX:WaitForChild("DogHouse").Cutscene
local phase2 = cutscene.phase2
local phase1 = cutscene.phase1
local dogHouse = script.DogHouse
local v = {
	{
		Up = "rbxassetid://140608666790006",
		Down = "rbxassetid://121019858201939"
	},
	{
		Up = "rbxassetid://79535802365107",
		Down = "rbxassetid://79254730626430"
	},
	{
		Up = "rbxassetid://81250506679273",
		Down = "rbxassetid://113017394455846"
	}
}

local function playSfx(soundId: string?, options)
	if not soundId or soundId == "" or soundId == "rbxassetid://0" then
		return
	end

	local v2 = options or {}
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = v2.Volume or 1
	sound.PlaybackSpeed = v2.PlaybackSpeed or 1
	sound.Parent = v2.Parent or SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	Debris:AddItem(sound, 8)
end

local v2 = 0

local function nextShakePair()
	local count = #v

	if count == 0 then
		return nil
	elseif count == 1 then
		return v[1]
	end

	local v3

	repeat
		v3 = math.random(1, count)
	until v3 ~= v2

	v2 = v3
	return v[v3]
end

local v3 = {
	TopOpen = UDim2.fromScale(0, -0.15),
	TopClose = UDim2.fromScale(0, -0.3),
	BottomOpen = UDim2.fromScale(0, 0.8),
	BottomClose = UDim2.fromScale(0, 1)
}
return function(data)
	local phase = data.Phase

	if phase == 1 then
		local spot = data.Spot
		local camera1 = data.Camera1
		local camera2 = data.Camera2
		local text = data.Text

		if not (spot and spot:IsA("BasePart")) then
			warn("[DogHouse.Cutscene] missing Spot")
			return
		end

		if not (camera1 and camera1:IsA("BasePart")) then
			warn("[DogHouse.Cutscene] missing Camera1")
			return
		end

		if not (camera2 and camera2:IsA("BasePart")) then
			warn("[DogHouse.Cutscene] missing Camera2")
			return
		end

		local target = data.Target or data.Player

		if not (target and target:IsA("Player")) then
			warn("[DogHouse.Cutscene] Target is not a Player", target)
			return
		end

		local playerGui = target:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			warn("[DogHouse.Cutscene] not found for", target.Name)
			return
		end

		playerGui.Main.Enabled = false
		local dogHouseScene = playerGui:FindFirstChild("DogHouseScene")

		if dogHouseScene then
			dogHouseScene:Destroy()
		end

		local dogHouseCutsceneModel = workspace:FindFirstChild("DogHouseCutsceneModel")

		if dogHouseCutsceneModel then
			dogHouseCutsceneModel:Destroy()
		end

		local clone = phase1:Clone()
		clone.Name = "DogHouseScene"
		clone.ResetOnSpawn = false
		clone.IgnoreGuiInset = true
		clone.DisplayOrder = 999999
		clone.Enabled = true
		clone.Parent = playerGui
		clone.Dialogue.TextFrame:ClearAllChildren()
		clone.Dialogue.Visible = false
		local top = clone:WaitForChild("Top")
		local bottom = clone:WaitForChild("Bottom")
		local clone2 = dogHouse:Clone()
		clone2.Name = "DogHouseCutsceneModel"
		clone2.Parent = workspace
		clone2:PivotTo(spot.CFrame)

		for _, part in ipairs(clone2:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		local primaryPart = clone2.PrimaryPart or clone2:FindFirstChildWhichIsA("BasePart", true)
		local v4 = true
		local cFrame = spot.CFrame
		task.spawn(function()
			local dogHouseJumpHeight = data.DogHouseJumpHeight or 4
			local dogHouseJumpTime = data.DogHouseJumpTime or 0.18
			local dogHouseShakeTime = data.DogHouseShakeTime or 0.35
			local dogHouseFallTime = data.DogHouseFallTime or 0.16
			local dogHouseSitTime = data.DogHouseSitTime or 0.28

			while v4 and clone2 and clone2.Parent do
				local v5 = nextShakePair()
				local v6 = cFrame * CFrame.new(0, dogHouseJumpHeight, 0) * CFrame.Angles(
					-0.06981317007977318,
					math.rad((math.random(-5, 5))),
					(math.rad((math.random(-4, 4))))
				)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = clone2:GetPivot()
				local changedConnection = cFrameValue.Changed:Connect(function(cframe)
					if clone2 and clone2.Parent then
						clone2:PivotTo(cframe)
					end
				end)
				local tween = TweenService:Create(
					cFrameValue,
					TweenInfo.new(dogHouseJumpTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Value = v6
					}
				)
				playSfx(v5 and v5.Up, {
					Parent = primaryPart,
					Volume = 0.9,
					PlaybackSpeed = 0.97 + math.random() * 0.06
				})
				tween:Play()
				tween.Completed:Wait()
				changedConnection:Disconnect()
				cFrameValue:Destroy()
				local lastTime = os.clock()

				while v4 and clone2 and clone2.Parent and os.clock() - lastTime < dogHouseShakeTime do
					clone2:PivotTo(v6 * CFrame.new(
						math.random(-22, 22) / 100,
						math.random(-10, 10) / 100,
						math.random(-22, 22) / 100
					) * CFrame.Angles(
						math.rad((math.random(-5, 5))),
						math.rad((math.random(-7, 7))),
						(math.rad((math.random(-5, 5))))
					))
					task.wait(0.03333333333333333)
				end

				local cFrameValue2 = Instance.new("CFrameValue")
				cFrameValue2.Value = clone2:GetPivot()
				local changedConnection2 = cFrameValue2.Changed:Connect(function(cframe)
					if clone2 and clone2.Parent then
						clone2:PivotTo(cframe)
					end
				end)
				local tween2 = TweenService:Create(
					cFrameValue2,
					TweenInfo.new(dogHouseFallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Value = cFrame
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				changedConnection2:Disconnect()
				cFrameValue2:Destroy()

				if clone2 and clone2.Parent then
					clone2:PivotTo(cFrame)
				end

				playSfx(v5 and v5.Down, {
					Parent = primaryPart,
					Volume = 1,
					PlaybackSpeed = 0.97 + math.random() * 0.06
				})
				task.wait(dogHouseSitTime)
			end

			if clone2 and clone2.Parent then
				clone2:PivotTo(cFrame)
			end
		end)
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local cameraType = currentCamera.CameraType
			local cameraSubject = currentCamera.CameraSubject
			local cFrame2 = currentCamera.CFrame
			local fieldOfView = currentCamera.FieldOfView
			local v5 = Util.Sound:Play("Dragon.Rumble", nil, nil, nil, 1)
			local flag = true
			task.spawn(function()
				local count = 0

				while flag do
					count += 1
					Util.CameraShaker:ShakeOnce(math.min(count * 2.5 + 9, 26), math.min(count + 9, 15), 0.1, 0.4)
					task.wait(0.2)
				end
			end)
			task.wait(data.PreCutsceneRumbleTime or 1.6)
			local frame = Instance.new("Frame")
			frame.Name = "DogHouseCutsceneFade"
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = 1000
			frame.Parent = clone
			local tween = TweenService:Create(
				frame,
				TweenInfo.new(data.FadeToBlackTime or 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			flag = false

			if v5 then
				pcall(function()
					Util.Sound:FadeOut(v5, 0.5)
				end)
			end

			Util.CameraShaker:SetEnabled(false)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = camera1.CFrame
			currentCamera.FieldOfView = data.FOV or 55
			TweenService:Create(
				frame,
				TweenInfo.new(data.FadeFromBlackTime or 0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					BackgroundTransparency = 1
				}
			):Play()
			local flag2 = false
			local characterAddedConnection = nil
			characterAddedConnection = target.CharacterAdded:Connect(function(character)
				flag2 = true
				Util.CameraShaker:SetEnabled(true)
				currentCamera.CameraType = Enum.CameraType.Custom
				local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)

				if humanoid then
					currentCamera.CameraSubject = humanoid
				end

				pcall(function()
					playerGui.Main.Enabled = true
				end)
				local dogHouseScene2 = playerGui:FindFirstChild("DogHouseScene")

				if dogHouseScene2 then
					dogHouseScene2:Destroy()
				end

				local dogHouseEyesCutscene = playerGui:FindFirstChild("DogHouseEyesCutscene")

				if dogHouseEyesCutscene then
					dogHouseEyesCutscene:Destroy()
				end

				v4 = false

				if clone2 then
					clone2:Destroy()
				end

				if characterAddedConnection then
					characterAddedConnection:Disconnect()
					characterAddedConnection = nil
				end
			end)
			local v6 = VRichText:New(clone.Dialogue.TextFrame, text, {
				Font = "SourceSansBold",
				TextScaled = true,
				TextScale = 0.3,
				TextColor3 = "White",
				TextStrokeColor3 = "Black",
				TextStrokeTransparency = 0,
				ContainerHorizontalAlignment = "Center",
				ContainerVerticalAlignment = "Center",
				TextYAlignment = "Center",
				AnimateStepGrouping = "Letter",
				AnimateStepFrequency = 1,
				AnimateStepTime = 0.001,
				AnimateStyle = "Wiggle",
				AnimateStyleTime = 0.1,
				AnimateStyleAmplitude = 1.8
			}, true)
			clone.Dialogue.Visible = true
			v6:Animate(false)
			local tweenInfo = TweenInfo.new(data.BarOpenTime or 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(top, tweenInfo, {
				Position = v3.TopOpen
			}):Play()
			TweenService:Create(bottom, tweenInfo, {
				Position = v3.BottomOpen
			}):Play()
			task.wait(data.DialogueHoldTime or data.CameraStillTime or 7.5)

			if flag2 then
				return
			end

			clone.Dialogue.Visible = false
			clone.Dialogue.TextFrame:ClearAllChildren()
			task.wait(data.AfterDialogueOutWait or 0.25)
			v4 = false
			local fastCameraTime = data.FastCameraTime or 0.85
			local quickCloseTime = data.QuickCloseTime or 0.25
			local tweenInfo2 = TweenInfo.new(quickCloseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local tween2 = TweenService:Create(
				currentCamera,
				TweenInfo.new(fastCameraTime, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{
					CFrame = camera2.CFrame
				}
			)
			local _ = {
				Volume = 1
			}
			tween2:Play()
			task.delay(fastCameraTime * (data.BarCloseAt or 0.45), function()
				if clone and clone.Parent then
					TweenService:Create(top, tweenInfo2, {
						Position = v3.TopClose
					}):Play()
					TweenService:Create(bottom, tweenInfo2, {
						Position = v3.BottomClose
					}):Play()
				end
			end)
			tween2.Completed:Wait()

			if flag2 then
				return
			end

			task.wait(data.HoldTime or 0.15)
			local dogHouseEyesCutscene = playerGui:FindFirstChild("DogHouseEyesCutscene")

			if dogHouseEyesCutscene then
				dogHouseEyesCutscene:Destroy()
			end

			local clone3 = phase2:Clone()
			clone3.Name = "DogHouseEyesCutscene"
			clone3.ResetOnSpawn = false
			clone3.IgnoreGuiInset = true
			clone3.DisplayOrder = 1000000
			clone3.Enabled = true
			clone3.Parent = playerGui
			local frame2 = clone3:WaitForChild("Frame")
			local _1 = clone3:WaitForChild("1")
			local _2 = clone3:WaitForChild("2")
			local _3 = clone3:WaitForChild("3")
			frame2.ZIndex = 1
			_1.ZIndex = 10
			_2.ZIndex = 11
			_3.ZIndex = 12
			local sound = Instance.new("Sound")
			sound.Name = "grrrrr"
			sound.SoundId = "rbxassetid://140461735149971"
			sound.Volume = data.Volume or 1
			sound.PlaybackSpeed = data.PlaybackSpeed or 1
			sound.Parent = SoundService
			sound.Ended:Once(function()
				sound:Destroy()
			end)
			Debris:AddItem(sound, 30)
			local tweenInfo3 = TweenInfo.new(data.FadeInTime or 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local tweenInfo4 = TweenInfo.new(data.FadeOutTime or 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			frame2.Visible = true
			frame2.BackgroundTransparency = 0
			_1.Visible = true
			_2.Visible = false
			_3.Visible = false
			_1.ImageTransparency = 1
			_2.ImageTransparency = 0
			_3.ImageTransparency = 0
			task.wait(data.StartDelay or 0.2)
			sound:Play()
			local tween3 = TweenService:Create(_1, tweenInfo3, {
				ImageTransparency = 0
			})
			tween3:Play()
			tween3.Completed:Wait()
			_2.Visible = true
			task.wait(data.Frame2Delay or 0.15)
			_3.Visible = true
			task.wait(data.HoldOpenTime or 0.35)
			_1.ImageTransparency = 0
			_2.ImageTransparency = 0
			_3.ImageTransparency = 0
			task.wait(data.ExtraHoldTime or 0.5)
			local v7 = { TweenService:Create(_1, tweenInfo4, {
					ImageTransparency = 1
				}), TweenService:Create(_2, tweenInfo4, {
					ImageTransparency = 1
				}), TweenService:Create(_3, tweenInfo4, {
					ImageTransparency = 1
				}) }

			for _, v8 in ipairs(v7) do
				v8:Play()
			end

			local _ = {
				TweenService:Create(_1, tweenInfo4, {
					BackgroundTransparency = 1
				}),
				TweenService:Create(_2, tweenInfo4, {
					BackgroundTransparency = 1
				}),
				TweenService:Create(_3, tweenInfo4, {
					BackgroundTransparency = 1
				}),
				TweenService:Create(frame2, tweenInfo4, {
					BackgroundTransparency = 1
				})
			}

			for _, v8 in ipairs(v7) do
				v8:Play()
			end

			TweenService:Create(sound, tweenInfo4, {
				Volume = 0
			}):Play()
			task.wait(tweenInfo4.Time + 0.05)

			if sound and sound.Parent then
				sound:Destroy()
			end

			if clone3 and clone3.Parent then
				clone3:Destroy()
			end

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end

			Util.CameraShaker:SetEnabled(true)

			if not flag2 then
				currentCamera.CameraType = cameraType
				currentCamera.CameraSubject = cameraSubject
				currentCamera.CFrame = cFrame2
				currentCamera.FieldOfView = fieldOfView
			end

			if clone and clone.Parent then
				clone:Destroy()
			end

			if clone2 and clone2.Parent then
				clone2:Destroy()
			end

			playerGui.Main.Enabled = true
		else
			clone:Destroy()
			clone2:Destroy()
		end
	elseif phase == 2 then
		local target = data.Target or data.Player

		if not (target and target:IsA("Player")) then
			warn("[DogHouse.Cutscene] Target is not a Player", target)
			return
		end

		local playerGui = target:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			warn("[DogHouse.Cutscene] not found for", target.Name)
			return
		end

		local dogHouseEyesCutscene = playerGui:FindFirstChild("DogHouseEyesCutscene")

		if dogHouseEyesCutscene then
			dogHouseEyesCutscene:Destroy()
		end

		local clone = phase2:Clone()
		clone.Name = "DogHouseEyesCutscene"
		clone.ResetOnSpawn = false
		clone.IgnoreGuiInset = true
		clone.DisplayOrder = 999999
		clone.Enabled = true
		clone.Parent = playerGui
		local frame = clone:WaitForChild("Frame")
		local _1 = clone:WaitForChild("1")
		local _2 = clone:WaitForChild("2")
		local _3 = clone:WaitForChild("3")
		local sound = Instance.new("Sound")
		sound.Name = "grrrrr"
		sound.SoundId = "rbxassetid://140461735149971"
		sound.Volume = data.Volume or 1
		sound.PlaybackSpeed = data.PlaybackSpeed or 1
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		Debris:AddItem(sound, 30)
		local tweenInfo = TweenInfo.new(data.FadeInTime or 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(data.FadeOutTime or 0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		frame.Visible = true
		frame.BackgroundTransparency = 0
		_1.Visible = true
		_2.Visible = false
		_3.Visible = false
		_1.ImageTransparency = 1
		_2.ImageTransparency = 0
		_3.ImageTransparency = 0
		task.wait(data.StartDelay or 0.2)
		sound:Play()
		local tween = TweenService:Create(_1, tweenInfo, {
			ImageTransparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
		_2.Visible = true
		task.wait(data.Frame2Delay or 0.15)
		_3.Visible = true
		task.wait(data.HoldOpenTime or 0.35)
		_1.ImageTransparency = 0
		_2.ImageTransparency = 0
		_3.ImageTransparency = 0
		task.wait(data.ExtraHoldTime or 0.5)
		local v4 = { TweenService:Create(_1, tweenInfo2, {
				ImageTransparency = 1
			}), TweenService:Create(_2, tweenInfo2, {
				ImageTransparency = 1
			}), TweenService:Create(_3, tweenInfo2, {
				ImageTransparency = 1
			}) }

		for _, v5 in ipairs(v4) do
			v5:Play()
		end

		local _ = {
			TweenService:Create(_1, tweenInfo2, {
				BackgroundTransparency = 1
			}),
			TweenService:Create(_2, tweenInfo2, {
				BackgroundTransparency = 1
			}),
			TweenService:Create(_3, tweenInfo2, {
				BackgroundTransparency = 1
			}),
			TweenService:Create(frame, tweenInfo2, {
				BackgroundTransparency = 1
			})
		}

		for _, v5 in ipairs(v4) do
			v5:Play()
		end

		TweenService:Create(sound, tweenInfo2, {
			Volume = 0
		}):Play()
		task.wait(tweenInfo2.Time + 0.05)

		if sound and sound.Parent then
			sound:Destroy()
		end

		if clone and clone.Parent then
			clone:Destroy()
		end
	end
end