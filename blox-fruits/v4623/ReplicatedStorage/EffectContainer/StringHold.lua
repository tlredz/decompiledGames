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
require(ReplicatedStorage:WaitForChild("FX"))
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

		for _, v in pairs(data.Full and { script.strinhold, script.sniperparticle } or { script.strinhold }) do
			local clone = v:Clone()
			clone:SetAttribute("StringCharge", true)
			clone.CFrame = data.Full and char.RightHand.CFrame or char.LeftHand.CFrame
			clone.Parent = char
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = clone
			weldConstraint.Part1 = data.Full and char.RightHand or char.LeftHand
			weldConstraint.Parent = clone
		end
	else
		for _, folder in ipairs(char:GetChildren()) do
			if not folder:GetAttribute("StringCharge") then
				continue
			end

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(folder, 2)
		end
	end
end