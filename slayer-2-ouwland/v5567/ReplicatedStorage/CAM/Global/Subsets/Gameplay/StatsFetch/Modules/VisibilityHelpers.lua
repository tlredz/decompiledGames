local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SkillStats = require(script.Parent.SkillStats)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
local clock = os.clock
local VisibilityHelpers = {}

function VisibilityHelpers.GetHoldTiming(instance, p: string)
	if instance == nil then
		return nil
	end

	local child = instance:FindFirstChild(RunService:IsServer() and "SHCS" or "SHC")

	if child == nil then
		return nil
	end

	local value = child.Value

	if value == nil or value == "" then
		return nil
	end

	local v = SkillStats.Get(value, instance)

	if v == nil or not v[p] then
		return nil
	end

	local last_performed = child:GetAttribute("last_performed")
	local v2 = PlayerProfile.skill_info[value]

	if last_performed and v2 and v2.Max_Hold_Time then
		local v3 = clock() - last_performed
		local max_Hold_Time = v2.Max_Hold_Time
		return max_Hold_Time - v3, max_Hold_Time
	else
		return nil
	end
end

function VisibilityHelpers.NormalizeTiming(p: number?, p2: number?)
	if p ~= nil and p2 == nil then
		return p, p
	end

	if p2 ~= nil and p == nil then
		p = p2
	end

	return p, p2
end

return VisibilityHelpers