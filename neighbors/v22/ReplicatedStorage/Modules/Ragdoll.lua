local Ragdoll = {}
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Utility = require(ServerStorage.Modules.Utility)

function Ragdoll:SetRagdoll(instance, flag: boolean, p: number?, flag2: boolean?)
	local humanoid = instance:FindFirstChild("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not flag or (not humanoid or not humanoidRootPart or instance:GetAttribute("Ragdoll")) then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter and playerFromCharacter:GetAttribute("VR") and playerFromCharacter:GetAttribute("DisableVRRagdoll") then
		return
	end

	Utility:ChangeStat(instance, "Ragdoll", flag, p)
	humanoid:UnequipTools()

	if flag2 then
		Utility:ChangeStat(instance, "Tripped", flag, p)
	end
end

function Ragdoll.RemoveRagdoll(_, p)
	Utility:ChangeStat(p, "Ragdoll", false)
	Utility:ChangeStat(p, "Tripped", false)
end

function Ragdoll.Trip(_, p, p2: number?)
	Ragdoll:SetRagdoll(p, true, p2, true)
end

if RunService:IsClient() then
	error("The Ragdoll module can only be used on the Server!")
end

return Ragdoll