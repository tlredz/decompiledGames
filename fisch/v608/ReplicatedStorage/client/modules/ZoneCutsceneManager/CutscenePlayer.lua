local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local Trove = require(ReplicatedStorage.packages.Trove)
require("./Types")
local module = require("../../legacyControllers/HudController")
local module2 = require("../../legacyControllers/PlayerController")
local CutscenePlayer = {
	Trove = Trove.new(),
	Playing = nil,
	BackgroundMusic = nil,
	FadeGui = nil,
	FadeFrame = nil
}
local now = 0
local v = 1
local v2 = false
local v3 = false
local v4 = false
local lastTime = nil
local v5 = {}
local volumesBySoundGroup = {}
local coreGuiEnableds = {}

function CutscenePlayer.DisableUIAndMusic()
	local playerGui = module:GetPlayerGui()
	local character = localPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid:UnequipTools()
			CutscenePlayer.Trove:Add(humanoid.Died:Once(CutscenePlayer.Abort))
			CutscenePlayer.Trove:Add(localPlayer.CharacterAdded:Once(CutscenePlayer.Abort))
		end

		character:SetAttribute("ZoneCutscenePlaying", 0)
	end

	module2:ToggleControls(false)

	for _, screenGui in playerGui:GetDescendants() do
		if not screenGui:IsA("ScreenGui") or not screenGui.Enabled or screenGui:HasTag("IgnoreCinematic") then
			continue
		end

		v5[screenGui] = true
		screenGui.Enabled = false
		local v6 = screenGui
		task.delay(0.1, function()
			v6.Enabled = false
		end)
	end

	StarterGui:SetCore("TopbarEnabled", false)
	SoundService:SetListener(Enum.ListenerType.CFrame, CFrame.new(10000000000, 10000000000, 10000000000))

	for _, soundGroup in pairs(SoundService:GetChildren()) do
		if not (soundGroup:IsA("SoundGroup") and soundGroup.Volume > 0) then
			continue
		end

		volumesBySoundGroup[soundGroup] = soundGroup.Volume
		soundGroup.Volume = 0
	end

	for _, v6 in Enum.CoreGuiType:GetEnumItems() do
		if v6 == Enum.CoreGuiType.All then
			continue
		end

		coreGuiEnableds[v6] = StarterGui:GetCoreGuiEnabled(v6)
		StarterGui:SetCoreGuiEnabled(v6, false)
	end

	UserInputService.MouseIconEnabled = false
	workspace:SetAttribute("ClientCutsceneRunning", true)
end

function CutscenePlayer.RestoreUIAndMusic()
	local character = localPlayer.Character

	if character then
		character:SetAttribute("ZoneCutscenePlaying", nil)
	end

	module2:ToggleControls(true)

	for k, enabled in pairs(v5) do
		if k and k.Parent then
			k.Enabled = enabled
		end
	end

	SoundService:SetListener(Enum.ListenerType.Camera)

	for k, volume in volumesBySoundGroup do
		if k and k.Parent then
			k.Volume = volume
		end
	end

	for k, v6 in coreGuiEnableds do
		StarterGui:SetCoreGuiEnabled(k, v6)
	end

	StarterGui:SetCore("TopbarEnabled", true)
	UserInputService.MouseIconEnabled = true
	table.clear(v5)
	table.clear(volumesBySoundGroup)
	table.clear(coreGuiEnableds)
	workspace:SetAttribute("ClientCutsceneRunning", nil)
end

function CutscenePlayer.Abort()
	CutscenePlayer.Trove:Clean()
	CutscenePlayer.Playing = nil
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	CutscenePlayer.RestoreUIAndMusic()

	if CutscenePlayer.BackgroundMusic then
		CutscenePlayer.BackgroundMusic:Stop()
		CutscenePlayer.BackgroundMusic:Destroy()
		CutscenePlayer.BackgroundMusic = nil
	end

	if CutscenePlayer.FadeGui then
		CutscenePlayer.FadeGui:Destroy()
		CutscenePlayer.FadeGui = nil
		CutscenePlayer.FadeFrame = nil
	end
end

function CutscenePlayer.FadeOut(flag: boolean)
	if v2 or v3 or not CutscenePlayer.Playing then
		return
	end

	local playing = CutscenePlayer.Playing
	v2 = true
	v4 = false
	lastTime = tick()
	local FINAL_FADE_OUT_TIME = flag and playing.FINAL_FADE_OUT_TIME or playing.FADE_DURATION
	local tweenInfo = TweenInfo.new(FINAL_FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(CutscenePlayer.FadeFrame, tweenInfo, {
		BackgroundTransparency = 0
	})
	tween:Play()

	if flag then
		TweenService:Create(
			CutscenePlayer.BackgroundMusic,
			TweenInfo.new(playing.MUSIC_FADE_OUT_TIME, Enum.EasingStyle.Linear),
			{
				Volume = 0
			}
		):Play()
	end

	tween.Completed:Once(function()
		v2 = false
		lastTime = nil

		if flag then
			v3 = true
			CutscenePlayer.Trove:Clean()
			currentCamera.CameraType = Enum.CameraType.Custom
			task.wait(playing.FINAL_HOLD_TIME)

			if CutscenePlayer.BackgroundMusic then
				CutscenePlayer.BackgroundMusic:Stop()
				CutscenePlayer.BackgroundMusic:Destroy()
				CutscenePlayer.BackgroundMusic = nil
			end

			local tweenInfo2 = TweenInfo.new(
				playing.FINAL_FADE_IN_TIME,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.InOut
			)
			local tween2 = TweenService:Create(CutscenePlayer.FadeFrame, tweenInfo2, {
				BackgroundTransparency = 1
			})
			tween2:Play()
			tween2.Completed:Wait()

			if CutscenePlayer.FadeGui then
				CutscenePlayer.FadeGui:Destroy()
				CutscenePlayer.FadeGui = nil
				CutscenePlayer.FadeFrame = nil
			end

			CutscenePlayer.RestoreUIAndMusic()
			CutscenePlayer.Playing = nil
			v = 1
			now = 0
			lastTime = nil
			v4 = false
			v3 = false
		else
			v += 1
			now = tick()
			local tweenInfo2 = TweenInfo.new(playing.FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(CutscenePlayer.FadeFrame, tweenInfo2, {
				BackgroundTransparency = 1
			}):Play()
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end
	end)
end

function CutscenePlayer.UpdateCamera(_: number)
	if not CutscenePlayer.Playing then
		return
	end

	local SEGMENTS = CutscenePlayer.Playing.SEGMENTS

	if v > #SEGMENTS then
		CutscenePlayer.FadeOut(true)
		return
	end

	local v6 = tick() - now
	local v7 = SEGMENTS[v]
	local speed_scale = v7.speed_scale or 1
	local v8 = v7.duration / speed_scale
	local v9 = math.clamp(v6 / v8, 0, 1)

	if v7.force_fade_out and v7.force_fade_out <= v6 and not (v4 or v2) then
		v4 = true
		CutscenePlayer.FadeOut(v == #SEGMENTS)
	end

	if v7.type == "orbit" then
		if lastTime then
			v6 = v7.force_fade_out + (tick() - lastTime)
		end

		local v10 = math.clamp(v6 / v8, 0, 1) * (v7.orbit_angle or 6.283185307179586) + (v7.start_angle or 0)
		local v11 = v7.center + Vector3.new(math.cos(v10) * v7.radius, v7.height_offset, math.sin(v10) * v7.radius)
		local center = v7.center
		local v12 = not (v7.bank_tilt and v7.bank_tilt > 0) and 0 or math.sin(v10 * 2) * v7.bank_tilt * 3.141592653589793 / 4
		currentCamera.CFrame = CFrame.lookAt(v11, center, createVector(0, 1, 0)) * CFrame.Angles(0, 0, v12)
	else
		if lastTime then
			v6 = v7.force_fade_out + (tick() - lastTime)
		end

		local v10 = math.clamp(v6 / v8, 0, 1)
		local positions = v7.positions
		local v11 = #positions - 1
		local v12 = v10 * v11
		local v13 = math.floor(v12)
		local v14 = v12 - v13
		local v15 = math.clamp(v13, 0, v11 - 1)
		local position = positions[v15 + 1]
		local position2 = positions[v15 + 2]
		local lerped = position:Lerp(position2, v14)
		local lookat = v7.lookat or lerped + (position2 - position).Unit * 30 - createVector(0, 15, 0)
		local v16 = v7.bank_tilt and v7.bank_tilt > 0 and 0 or 0
		currentCamera.CFrame = CFrame.lookAt(lerped, lookat, createVector(0, 1, 0)) * CFrame.Angles(0, 0, v16)
	end

	currentCamera.Focus = currentCamera.CFrame

	if not v4 and v9 >= 1 then
		CutscenePlayer.FadeOut(v == #SEGMENTS)
	end
end

function CutscenePlayer.PlayCutscene(playing)
	if CutscenePlayer.Playing then
		warn("Attempt to start cutscene before the previous finished")
		return false
	end

	CutscenePlayer.DisableUIAndMusic()
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local sound = Instance.new("Sound")
	sound.SoundId = playing.MUSIC_ID
	sound.Volume = 0
	sound.Looped = true
	sound.Parent = SoundService
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShowcaseFade"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ClipToDeviceSafeArea = false
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	screenGui.Parent = module:GetPlayerGui()
	CutscenePlayer.BackgroundMusic = sound
	CutscenePlayer.FadeGui = screenGui
	CutscenePlayer.FadeFrame = frame
	sound:Play()
	TweenService:Create(
		sound,
		TweenInfo.new(playing.MUSIC_FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Volume = playing.MUSIC_VOLUME
		}
	):Play()
	TweenService:Create(
		frame,
		TweenInfo.new(playing.INITIAL_FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = 1
		}
	):Play()
	now = tick()
	v = 1
	print(v)
	CutscenePlayer.Playing = playing
	CutscenePlayer.Trove:Connect(RunService.RenderStepped, CutscenePlayer.UpdateCamera)
	return true
end

return CutscenePlayer