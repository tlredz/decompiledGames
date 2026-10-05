local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
game:GetService("Debris")
local Observers = require(ReplicatedStorage.packages.Observers)
local Promise = require(ReplicatedStorage.packages.Promise)
local Trove = require(ReplicatedStorage.packages.Trove)
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local PlayerController = require(ReplicatedStorage.client.legacyControllers.PlayerController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local assets = require(ReplicatedStorage.shared.utils.assets)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local cframe = CFrame.new(
	-1473.24097,
	134.070999,
	728.927002,
	1,
	-1.42108488e-14,
	4.14152156e-29,
	1.42108488e-14,
	1,
	6.2172464e-15,
	-1.29767571e-28,
	-6.2172464e-15,
	1
)
local cframe2 = CFrame.new(
	-1299.90002,
	140.83934,
	281.676727,
	-0.80802691,
	-0.0795286745,
	0.583753109,
	-0,
	0.990846992,
	0.134989858,
	-0.589145541,
	0.109075435,
	-0.800631046
)
local cframe3 = CFrame.new(
	-1473.2406,
	132.701035,
	728.927368,
	0.999999046,
	1.42108488e-14,
	4.14151765e-29,
	1.42108488e-14,
	1,
	6.2172464e-15,
	4.14151765e-29,
	6.2172464e-15,
	0.999999046
)
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function createTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(player, flag: boolean, anchored: boolean)
	PlayerController:ToggleControls(not flag)
	ProximityPromptService.Enabled = not flag
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	assert(humanoidRootPart:IsA("BasePart"))
	humanoidRootPart.Anchored = anchored
end

return {
	Start = function(_, player, _: string)
		local maid = Trove.new()
		return Promise.new(function(callback, _, _)
			local WAIT_INTERVAL = 0.8
			local _ = player.Character

			if not workspace:FindFirstChild("MarianasVeilEntryCutscene", true) then
				warn("Marainas Veil Entry Cutscene model is not streamed in somehow.")
				return callback()
			end

			if player ~= localPlayer then
				return callback()
			end

			local clone = maid:Clone(script.Camera)
			clone:PivotTo(cframe)
			clone.Parent = workspace
			local clone2 = maid:Clone(script.Rig)
			clone2:PivotTo(cframe3)
			clone2.Parent = workspace
			task.spawn(pcall, function()
				local value = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("rod").Value

				if not value then
					return
				end

				local model = assets.getAsync("rod", value):FindFirstChildOfClass("Model")

				if not model then
					return
				end

				local clone3 = model:Clone()
				local handle = clone3:FindFirstChild("handle") or clone3:FindFirstChild("Handle") or clone3.PrimaryPart
				local motor6D = Instance.new("Motor6D")
				motor6D.Name = "WeldToArm"
				motor6D.Part0 = clone2:FindFirstChild("Right Arm")
				motor6D.Part1 = handle
				motor6D.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
					-1.5707963267948966,
					-3.141592653589793,
					0
				)
				motor6D.Parent = handle
				clone3.Parent = clone2
			end)
			task.spawn(pcall, function()
				clone2.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
			end)
			local track = clone.AnimationController.Animator:LoadAnimation(clone.Animation)
			local track2 = clone2.Humanoid.Animator:LoadAnimation(script.PlayerAnimation)
			track:Play(0, 0, 0)
			track2:Play(0, 0, 0)
			local clone3 = maid:Clone(script.Sound)
			clone3.TimePosition = 0
			clone3.Parent = script
			local clone4 = maid:Clone(script.Sound2)
			clone4.TimePosition = 0
			clone4.Parent = script
			clone3.Volume = 0
			clone3:Play()
			clone4.Volume = 0
			clone4:Play()
			local v = 5

			while track.Length == 0 or track2.Length == 0 or clone3.TimeLength == 0 or clone4.TimeLength == 0 do
				v -= task.wait()

				if v <= 0 then
					break
				end
			end

			clone3.TimePosition = 0
			clone3.Volume = 0.5
			clone3:Stop()
			clone4.TimePosition = 0
			clone4.Volume = 0.5
			clone4:Stop()
			track:Stop(0)
			track2:Stop(0)
			track.TimePosition = 0
			track2.TimePosition = 0
			setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
			maid:Add(function()
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end)
			CutsceneController:DisableAllScreens(15.200000000000001)
			CutsceneController:Fade(2, 0.4, 0.4)
			task.wait(WAIT_INTERVAL)
			CutsceneController:ShowBars(15.200000000000001, 0, 0.1)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.FieldOfView = 40
			maid:Add(function()
				currentCamera.FieldOfView = 70
				currentCamera.CameraType = Enum.CameraType.Custom
			end)
			maid:Add(RunService.PreRender:Connect(function()
				currentCamera.CFrame = clone.Bone.CFrame
			end))
			local v3 = maid:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			local v4 = maid:Add(function()
				track2:Stop(0)
				track2:Destroy()
			end)
			clone3:Play()
			clone4:Play()
			track.TimePosition = 0
			track:Play()
			track2.TimePosition = 0
			track2:Play()
			maid:Add(Observers.observeCharacters(function(_, p)
				return HideInstances(p)
			end))
			task.spawn(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
			end)
			maid:Add(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
			end)
			task.wait(9.5)
			CutsceneController:Fade(2, 0.4, 0.4)
			task.wait(WAIT_INTERVAL)
			maid:Remove(v4)
			maid:Remove(v3)
			maid:Remove(clone2)
			clone:PivotTo(cframe2)
			createTween(currentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				FieldOfView = 70
			}) -- equivalent call inferred; original call site unknown
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = cframe2
			cFrameValue.Changed:Connect(function(cframe4)
				clone.Bone:PivotTo(cframe4)
			end)
			;(createTween(cFrameValue, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				Value = cframe2 * CFrame.new(0, 0, 25)
			})).Completed:Once(function()
				cFrameValue:Destroy()
			end)
			task.spawn(function()
				local clone5 = playerGui.hud.location:Clone()
				clone5.Position = UDim2.fromScale(0.5, 0.05)
				clone5.title.Text = "• Mariana's Veil •"
				clone5.Parent = playerGui.Cutscene
				local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Linear)
				createTween(clone5.title, tweenInfo3, {
					TextTransparency = 0
				}) -- equivalent call inferred; original call site unknown
				createTween(clone5.title.UIStroke, tweenInfo3, {
					Transparency = 0
				}) -- equivalent call inferred; original call site unknown
				task.wait(3)
				createTween(clone5.title, tweenInfo3, {
					TextTransparency = 1
				}) -- equivalent call inferred; original call site unknown
				createTween(clone5.title.UIStroke, tweenInfo3, {
					Transparency = 1
				}) -- equivalent call inferred; original call site unknown
				task.wait(1)
				clone5:Destroy()
			end)
			task.wait(3)
			CutsceneController:Fade(2, 0.4, 0.4)
			task.wait(WAIT_INTERVAL)
			maid:Destroy()
			callback()
		end):catch(warn):finally(function()
			maid:Destroy()
		end)
	end
}