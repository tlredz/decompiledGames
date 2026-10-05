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
local _ = FX:WaitForChild("FlameEffects").EnkaiCharge
local charge = FX:WaitForChild("Phoenix1").Charge
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
	local v = { data.limb or "RightHand" }

	if inputHeldDown == true then
		if char:FindFirstChild("Phoenix") or (position - currentCamera.CFrame.Position).Magnitude > 1000 then
			return
		end

		Util.Sound:Play("Mera_FlameStartup", root)
		local play = Util.Sound:Play("Mera_FireLoop", root)
		play.Looped = true

		for _, emitter in ipairs(charge.Charge:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Enabled = true
			clone:SetAttribute("Phoenix1Charge", true)
			clone.Parent = char[v[1]]
		end
	else
		local mera_FireLoop = root:FindFirstChild("Mera_FireLoop")

		if mera_FireLoop then
			mera_FireLoop:Stop()
			mera_FireLoop:Destroy()
		end

		for _, emitter in ipairs(char[v[1]]:GetChildren()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Phoenix1Charge")) then
				continue
			end

			emitter.Enabled = false
			destroyAfter(emitter, 1)
		end
	end
end