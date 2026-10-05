local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
local Trove = require(packages:WaitForChild("Trove"))
local Observers = require(packages:WaitForChild("Observers"))
local CutsceneController = require(ReplicatedStorage.client.legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(ReplicatedStorage.client.legacyControllers:WaitForChild("PlayerController"))
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera

local function daRotatey(p, p2, p3)
	return CFrame.fromOrientation(math.rad(p), math.rad(p2), (math.rad(p3)))
end

local v = {
	Bellona = {
		Start = CFrame.new(-8815.177, -2196.134, 754.629) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Target = CFrame.new(-8815.177, -2252.166, 754.629) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Reveal = CFrame.new(-8821.509, -2467.719, 755.937) * CFrame.fromOrientation(-1.5707963267948966, 0, 0)
	},
	Apollo = {
		Start = CFrame.new(-8829.483, -2740.52, 734.33) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Target = CFrame.new(-8829.483, -2815.668, 734.33) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Reveal = CFrame.new(-8829.479, -2992.808, 734.33) * CFrame.fromOrientation(-1.5707963267948966, 0, 0)
	},
	Poseidon = {
		Start = CFrame.new(-8821.918, -3052.116, 740.757) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Target = CFrame.new(-8821.918, -3111.126, 740.757) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Reveal = CFrame.new(-8832.295, -3326.283, 740.764) * CFrame.fromOrientation(-1.5707963267948966, 0, 0)
	},
	Zeus = {
		Start = CFrame.new(-8825.571, -3389.623, 726.25) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Target = CFrame.new(-8825.571, -3459.777, 726.25) * CFrame.fromOrientation(-1.5707963267948966, 0, 0),
		Reveal = CFrame.new(-8825.92, -4084.963, 708.035) * CFrame.fromOrientation(-0.7853981633974483, 0, 0)
	},
	Hades = {
		Start = CFrame.new(-8833.718, -4191.746, 283.283),
		Target = CFrame.new(-8833.791, -4191.565, 179.172),
		Reveal = CFrame.new(-8830.151, -4218.418, -23.71) * CFrame.fromOrientation(
			-0.003298672286269283,
			-0.049323004661359755,
			0
		)
	}
}

local function getSealModel(p: string)
	for _, v2 in CollectionService:GetTagged("DivineSeal") do
		if v2:GetAttribute("GodName") == p then
			return v2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(player, flag: boolean, anchored: boolean)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.Anchored = anchored
	PlayerController:ToggleControls(not flag)
	ProximityPromptService.Enabled = not flag
end

local function tweenSealBreak(folder)
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Quint)

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
			local v2 = descendant
			task.delay(0.6, function()
				v2.CanCollide = false
			end)
		elseif descendant:IsA("ParticleEmitter") then
			descendant:Emit(descendant:GetAttribute("BurstCount") or 30)
			TweenService:Create(descendant, tweenInfo2, {
				Rate = 0
			}):Play()
			local v2 = descendant
			task.delay(1, function()
				v2.Enabled = false
			end)
		end
	end
end

local function createWhiteFlash(maid)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SealBreakFlashGui"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 100
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	maid:Add(screenGui)
	return frame
end

local function playExplosionFlipbook(parent)
	local VIOLENTEXPLOSION = script.VIOLENTEXPLOSION
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "SealBreakExplosion"
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Position = UDim2.fromScale(0, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Image = VIOLENTEXPLOSION.Image
	imageLabel.ImageRectSize = VIOLENTEXPLOSION.ImageRectSize
	imageLabel.ZIndex = 101
	imageLabel.Parent = parent

	for i = 1, 203, 101 do
		for i2 = 1, 362, 72 do
			imageLabel.ImageRectOffset = Vector2.new(i2, i)
			task.wait(0.025)
		end
	end

	imageLabel:Destroy()
end

return {
	Start = function(_, p, p2: string)
		return Promise.new(function(callback)
			if p ~= localPlayer then
				return callback()
			end

			local v2 = v[p2]

			if not v2 then
				warn((`[DivineSealBreak] No camera config for god: {p2}`))
				return callback()
			end

			local sealModel = getSealModel(p2)
			local maid = Trove.new()
			setPlayerState(p, true, true) -- equivalent call inferred; original call site unknown
			maid:Add(function()
				setPlayerState(p, false, false) -- equivalent call inferred; original call site unknown
			end)
			maid:Add(Observers.observeCharacters(function(p3, p4)
				if p3 == p then
					return nil
				end

				return HideInstances(p4)
			end))
			CutsceneController:DisableAllScreens(16.5)
			local whiteFlash = createWhiteFlash(maid)
			task.spawn(function()
				CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(1.5, 0)
			end)
			task.wait(0.75)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local cFrame = currentCamera.CFrame
			currentCamera.CFrame = v2.Start
			currentCamera.Focus = currentCamera.CFrame
			maid:Add(function()
				currentCamera.CFrame = cFrame
				currentCamera.CameraType = Enum.CameraType.Custom
			end)
			task.wait(0.75)
			task.spawn(function()
				CutsceneController:ShowBars(13, 0.05, 0.1)
			end)
			local lastTime = os.clock()
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = v2.Start
			maid:Add(cFrameValue)
			TweenService:Create(cFrameValue, TweenInfo.new(6.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Value = v2.Target
			}):Play()
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v4 = os.clock() - lastTime
				local v5 = math.clamp(v4 / 6.5, 0, 1) ^ 2 * 1.7 + 0.1
				currentCamera.CFrame = cFrameValue.Value + Vector3.new(
					math.sin(v4 * 30) * v5,
					math.cos(v4 * 30 * 1.3) * v5 * 0.7,
					math.sin(v4 * 30 * 0.8) * v5 * 0.5
				)
				currentCamera.Focus = currentCamera.CFrame
			end)
			task.wait(6.5)
			renderSteppedConnection:Disconnect()
			whiteFlash.BackgroundTransparency = 0

			if sealModel then
				tweenSealBreak(sealModel)
			end

			script.explode:Play()
			TweenService:Create(whiteFlash, TweenInfo.new(2, Enum.EasingStyle.Quint), {
				BackgroundTransparency = 1
			}):Play()
			currentCamera.CFrame = v2.Target
			currentCamera.Focus = currentCamera.CFrame
			task.wait(2)
			task.wait(1.5)
			local cFrameValue2 = Instance.new("CFrameValue")
			cFrameValue2.Value = v2.Target
			maid:Add(cFrameValue2)
			local renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
				currentCamera.CFrame = cFrameValue2.Value
			end)
			TweenService:Create(cFrameValue2, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Value = v2.Reveal
			}):Play()
			task.delay(1, function()
				CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(2, 2)
			end)
			task.wait(3)
			renderSteppedConnection2:Disconnect()
			maid:Destroy()
			task.wait(2)
			callback()
		end)
	end
}