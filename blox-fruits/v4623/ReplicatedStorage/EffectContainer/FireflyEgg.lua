local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("ServerStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fireflyEgg = FX:WaitForChild("FireflyEgg")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	local position = data.Position

	if (Workspace.CurrentCamera.CFrame.Position - position).Magnitude >= 500 then
		return
	end

	local stage = data.Stage

	if stage == "collectshard" then
		Util.Sound:Play("BF_Valentines_Ring_Hit_Success_01", position, nil, nil, 1 + math.random(-20, 50) / 100)
		local clone = data.big == true and fireflyEgg.FireflyEggShardCollect_big:Clone() or fireflyEgg.FireflyEggShardCollect:Clone()
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 2)

		if data.root then
			position = data.root.Position or position
		end

		clone.Position = position
		clone.Parent = Workspace._WorldOrigin

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	else
		if stage == "collect" then
			return
		end

		if stage == "reset" then
			Util.Sound:Play("BF_Valentines_Ring_Disappear_04", position)
		end
	end
end