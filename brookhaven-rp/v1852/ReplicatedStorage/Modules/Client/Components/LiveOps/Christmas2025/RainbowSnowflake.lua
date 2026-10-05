local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "RainbowSnowflake"
})
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v2 = {
	[50] = 0.016666666666666666,
	[80] = 0.03333333333333333,
	[100] = 0.06666666666666667,
	[150] = 0.1,
	[200] = 0.2,
	[300] = 0.5
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._animationJanitor = Janitor.new()
	self.originalCFrame = self.Instance:WaitForChild("Part").CFrame
end

function v:Collect()
	if self.Collected then
		return
	end

	self.Collected = true
	Remotes.fireServer("RainbowSnowflakeCollected", self.Instance.Name)

	for _, sound in self.Instance.Glow:GetChildren() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end

	TweenService:Create(self.Instance.Part, TweenInfo.new(1), {
		CFrame = CFrame.new(0, 10, 0) * self.Instance.Part.CFrame * CFrame.Angles(0, 540, 0),
		Transparency = 1
	}):Play()
	TweenService:Create(self.Instance.Glow.One, TweenInfo.new(1), {
		Position = createVector(-5.105, -0, -0.214)
	}):Play()
	TweenService:Create(self.Instance.Glow.Two, TweenInfo.new(1), {
		Position = createVector(4.459, -0, -0.214)
	}):Play()

	for _, beam in self.Instance.Glow:GetChildren() do
		if not beam:IsA("Beam") then
			continue
		end

		TweenService:Create(beam, TweenInfo.new(1), {
			Width0 = 40,
			Width1 = 40,
			Brightness = 0
		}):Play()
		local v3 = beam
		task.delay(2, function()
			v3.Enabled = false
		end)
	end

	if self.Instance:GetAttribute("RepeatableCollection") then
		return
	end

	task.delay(3, function()
		self._animationJanitor:Cleanup()
		self.Instance:Destroy()
	end)
end

function v:Reset()
	if not self.Collected then
		return
	end

	TweenService:Create(self.Instance.Part, TweenInfo.new(1), {
		CFrame = self.originalCFrame,
		Transparency = 0
	}):Play()
	TweenService:Create(self.Instance.Glow.One, TweenInfo.new(1), {
		Position = self.originalGlowCFrameOne
	}):Play()
	TweenService:Create(self.Instance.Glow.Two, TweenInfo.new(1), {
		Position = self.originalGlowCFrameTwo
	}):Play()

	for _, beam in self.Instance.Glow:GetChildren() do
		if not beam:IsA("Beam") then
			continue
		end

		TweenService:Create(beam, TweenInfo.new(1), {
			Width0 = 25,
			Width1 = 25,
			Brightness = 3
		}):Play()
		local v3 = beam
		task.delay(2, function()
			v3.Enabled = true
		end)
	end

	task.wait(1)
	self.Collected = false
end

function v:Start()
	local instance = self.Instance
	local part = instance:WaitForChild("Part")
	local glow = instance:WaitForChild("Glow")
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(p)
		if not p.Data.LiveOpsEventData.Christmas2025.SnowflakesCollected[self.Instance.Name] then
			return
		end

		self.Instance:Destroy()
	end)

	if self.Instance.Parent == nil then
		return
	end

	self._animationJanitor:Add(self.Instance.PrimaryPart.Touched:Connect(function(otherPart)
		local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

		if not (playerFromCharacter and playerFromCharacter == Players.LocalPlayer) then
			return
		end

		self:Collect()
	end))
	local total = 0
	local position = part.Position
	local number = Random.new():NextNumber(0, 180)
	self._animationJanitor:Add(RunService.Heartbeat:Connect(function(dt)
		local magnitude = (workspace.CurrentCamera.CFrame.Position - position).Magnitude
		local v3 = 0.016666666666666666

		for k, v5 in v2 do
			if not (k < magnitude) then
				continue
			end

			v3 = v5
			break
		end

		number += dt
		total += dt

		if total < v3 then
			return
		end

		total = 0
		local character = Players.LocalPlayer.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		local position2 = workspace.CurrentCamera.CFrame.Position
		local vector2 = Vector3.new(position2.X, position.Y, position2.Z)
		part.CFrame = CFrame.new(position, vector2) * CFrame.new(0, math.sin(number * 2) / 1.5, 0) * CFrame.Angles(
			0,
			0,
			math.sin(number) / 3
		)
		glow.CFrame = CFrame.new(glow.CFrame.Position, vector2)
	end))
end

function v:Stop()
	self._animationJanitor:Destroy()
	self._Janitor:Destroy()
end

return v