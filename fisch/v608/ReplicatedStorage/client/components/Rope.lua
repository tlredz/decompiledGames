local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local localPlayer = Players.LocalPlayer
local v = nil
local track = nil
local v2 = Component.new({
	Tag = "Rope"
})

local function Slide(cFrame, position, slideDuration, p2, p3, p4)
	local v3 = cFrame * CFrame.new(position)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	humanoidRootPart.Anchored = false
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = cFrame
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		humanoidRootPart.CFrame = cFrameValue.Value
	end)

	if character ~= v then
		v = character
		track = animator:LoadAnimation(script:WaitForChild("Animation"))
	end

	PlayerController:ToggleControls(false)
	track:Play()
	humanoidRootPart.CFrame = cFrame
	local tween = TweenService:Create(cFrameValue, TweenInfo.new(slideDuration, Enum.EasingStyle.Linear), {
		Value = v3
	})
	tween:Play()
	task.wait(slideDuration * 0.7)

	if p3 then
		CutsceneController:Fade(3, 0.1, 0.1)
	end

	if tween.PlaybackState == Enum.PlaybackState.Playing then
		tween.Completed:Wait()
	end

	heartbeatConnection:Disconnect()
	cFrameValue:Destroy()
	track:Stop()

	if p2 then
		Net:RemoteEvent("RequestArea"):FireServer(p2)
	end

	if p4 then
		humanoidRootPart.Anchored = true
	end

	PlayerController:ToggleControls(true)
end

function v2:Slide()
	local spawnCFrame = self.Instance:GetAttribute("SpawnCFrame")
	local direction = self.Instance:GetAttribute("Direction")
	local slideDuration = self.Instance:GetAttribute("SlideDuration")
	local _ = spawnCFrame * CFrame.new(direction)
	local targetCFrame = self.Instance:GetAttribute("TargetCFrame")

	if not self.Instance:GetAttribute("Entering") then
		Slide(spawnCFrame, direction, slideDuration, targetCFrame, true)
		return
	end

	Slide(spawnCFrame, direction, slideDuration, targetCFrame, true, true)
	Slide(
		targetCFrame * CFrame.fromEulerAnglesXYZ(0, 3.141592653589793, 0),
		direction - createVector(0, 10, 0),
		slideDuration,
		nil,
		false
	)
end

function v2:Construct()
	self.trove = Trove.new()
end

function v2:Start()
	local prompt = self.Instance:WaitForChild("Prompt")
	self.trove:Add(prompt.Triggered:Connect(function()
		self:Slide()
	end))
end

function v2:Stop()
	self.trove:Destroy()
end

return v2