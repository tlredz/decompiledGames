local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local hands = FX:WaitForChild("LightEffects").JewelsOfLightCharge.Hands
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
game:GetService("TweenService")
return function(data)
	local _ = data.player
	local char = data.char
	local root = data.root
	local inputHeldDown = data.inputHeldDown

	if char:FindFirstChildOfClass("Humanoid") == nil or root == nil then
		return
	end

	local position = root.Position
	local currentCamera = Workspace.CurrentCamera
	local v = { "RightHand", "LeftHand" }

	if inputHeldDown == true then
		if (position - currentCamera.CFrame.Position).Magnitude > 700 then
			return
		end

		for i = 1, 2 do
			for _, emitter in ipairs(hands:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local clone = emitter:Clone()
				clone.Enabled = true
				clone:SetAttribute("JewelsOfLightCharge", true)
				clone.Parent = char[v[i]]
			end
		end

		local ray = Ray.new(root.Position, createVector(0, -40, 0))
		local part, v2 = game.Workspace:FindPartOnRayWithWhitelist(ray, { Workspace.Map })

		if part then
			local clone = hands.Parent.dust:Clone()
			clone.CFrame = CFrame.new(v2) * CFrame.Angles(0, 0, 1.5707963267948966)
			clone.Parent = _WorldOrigin

			for _, child in ipairs(clone.Attachment:GetChildren()) do
				child.Color = ColorSequence.new(part.Color)
				child:Emit(20)
			end

			destroyAfter(clone, 2)
		end
	else
		for i = 1, 2 do
			for _, emitter in ipairs(char[v[i]]:GetChildren()) do
				if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("JewelsOfLightCharge")) then
					continue
				end

				emitter.Enabled = false
				destroyAfter(emitter, 1)
			end
		end
	end
end