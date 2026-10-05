local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local iceAgeCharge = FX:WaitForChild("IceEffects").IceAgeCharge
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
game:GetService("TweenService")
return function(data)
	local char = data.char
	local root = data.root
	local inputHeldDown = data.inputHeldDown

	if char:FindFirstChildOfClass("Humanoid") == nil or root == nil then
		return
	end

	local position = root.Position
	local currentCamera = Workspace.CurrentCamera

	if inputHeldDown == true then
		if (position - currentCamera.CFrame.Position).Magnitude > 800 then
			return
		end

		Util.Sound:Play("Ice_startup", root)

		for _, emitter in ipairs(iceAgeCharge:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Enabled = true
			clone:SetAttribute("IceAgeCharge", true)
			clone.Parent = char.LeftLowerArm
		end
	else
		for _, emitter in ipairs(char.LeftLowerArm:GetChildren()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("IceAgeCharge")) then
				continue
			end

			emitter.Enabled = false
			destroyAfter(emitter, 1)
		end
	end
end