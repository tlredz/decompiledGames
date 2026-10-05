local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("ServerStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local heartReward = FX:WaitForChild("HeartReward")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local random = Random.new()
return function(data)
	local _ = data.char
	local root = data.root

	if (Workspace.CurrentCamera.CFrame.Position - root:GetPivot().Position).Magnitude >= 850 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = `{script.Name}:Stage{data.stage}`
	folder.Parent = Workspace._WorldOrigin
	destroyAfter(folder, 5)
	Util.Sound:Play("BF_Quest_Completion_Reward_05", root)
	local clone = heartReward.ValentinesAward:Clone()
	clone.Weld.Part0 = root
	clone.Parent = folder
	task.delay(ParticleState(clone), clone.Destroy, clone)

	for _ = 1, 5 do
		task.spawn(function()
			local position2 = root.Position + Vector3.new(
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15)
			)
			local v2 = root.Position + Vector3.new(
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15)
			)
			local v3 = root.Position + Vector3.new(
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15),
				random:NextNumber(-15, 15)
			)
			local position = root.Position
			local clone2 = heartReward.HeartBezier:Clone()
			clone2.Position = position2
			clone2.Parent = folder
			clone2.Particle.ParticleEmitter:Emit(1)

			for i = 0, 1, RunService.Heartbeat:Wait() / random:NextNumber(0.28, 0.4) do
				position = root.Position
				local v4 = position2 + (v2 - position2) * i
				local v5 = v2 + (v3 - v2) * i
				local v6 = v3 + (position - v3) * i
				local v7 = v4 + (v5 - v4) * i
				clone2.Position = v7 + (v5 + (v6 - v5) * i - v7) * i
				task.wait()
			end

			clone2.Position = position
			task.delay(ParticleState(clone2, false), clone2.Destroy, clone2)
		end)
	end

	task.wait(0.18)
	local clone2 = heartReward.Burst:Clone()
	clone2.Weld.Part0 = root
	clone2.Parent = folder
	task.delay(ParticleState(clone2), clone2.Destroy, clone2)
end