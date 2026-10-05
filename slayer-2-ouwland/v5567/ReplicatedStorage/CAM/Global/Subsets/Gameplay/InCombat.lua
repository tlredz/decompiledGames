local InCombat = {
	InCombatTime = 30
}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

function InCombat.RegularIncludeAI(p, value)
	if p == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder == nil then
		return false
	end

	local DMG = getvaluesfolder:FindFirstChild("DMG")

	if DMG ~= nil then
		if Utility.Tick() - (DMG:GetAttribute("LastAttacked") or 0) <= InCombat.InCombatTime - (value or 0) then
			return true
		end

		if Utility.Tick() - (DMG:GetAttribute("LastEngaged") or 0) <= InCombat.InCombatTime - (value or 0) then
			return true
		end
	end

	return false
end

function InCombat.Regular(p, value)
	if p == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder == nil then
		return false
	end

	local DMG = getvaluesfolder:FindFirstChild("DMG")

	if DMG ~= nil then
		if Utility.Tick() - (DMG:GetAttribute("LastAttackedByPlayer") or 0) <= InCombat.InCombatTime - (value or 0) then
			return true
		end

		if Utility.Tick() - (DMG:GetAttribute("LastEngagedPlayer") or 0) <= InCombat.InCombatTime - (value or 0) then
			return true
		end
	end

	return false
end

function InCombat.biasedCheck(p, p2)
	if isStudio then
		return InCombat.RegularIncludeAI(p, p2)
	end

	return InCombat.Regular(p, p2)
end

function InCombat.biasedTimeLeft(p, value)
	if p == nil then
		return 0
	end

	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder == nil then
		return 0
	end

	local DMG = getvaluesfolder:FindFirstChild("DMG")

	if DMG == nil then
		return 0
	end

	local v3 = InCombat.InCombatTime - (value or 0)
	local v4 = Utility.Tick()
	return (math.max(
		0,
		v3 - (v4 - (DMG:GetAttribute(isStudio and "LastAttacked" or "LastAttackedByPlayer") or 0)),
		v3 - (v4 - (DMG:GetAttribute(isStudio and "LastEngaged" or "LastEngagedPlayer") or 0))
	))
end

return InCombat