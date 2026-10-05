local Players = game:GetService("Players")
Players.LocalPlayer:WaitForChild("PlayerGui")
local CollectionService = game:GetService("CollectionService")
local ParticleModule = require(script:WaitForChild("ParticleModule"))

local function addEmitter(emitter)
	if emitter:IsA("ParticleEmitter") and emitter.Parent:IsA("GuiBase") then
		ParticleModule:AddEmitter(emitter, 1)
	end
end

CollectionService:GetInstanceAddedSignal("UIEmitter"):Connect(addEmitter)
CollectionService:GetInstanceRemovedSignal("UIEmitter"):Connect(function(p)
	ParticleModule:RemoveEmitter(p)
end)