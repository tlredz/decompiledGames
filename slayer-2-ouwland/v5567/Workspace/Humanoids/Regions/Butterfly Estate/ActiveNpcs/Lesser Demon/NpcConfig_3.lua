script:WaitForChild("Signals")
script:WaitForChild("Following")
script:WaitForChild("Idling")
script:WaitForChild("Skills")
script:WaitForChild("Spawning")
script:WaitForChild("Tasks")
local NpcConfig = {
	UniqueName = "",
	Profile = "Default",
	Folder = script.Parent,
	Following = require(script.Following),
	Spawning = require(script.Spawning),
	Tasks = require(script.Tasks),
	Properties = {
		Empty = 1,
		CanSpawn = 0,
		Spawned = 0,
		NoTarget = 1,
		GameplayPaused = 0,
		ShouldRun = 0,
		IsDoingSkill = 0,
		IsFleeing = 0,
		ActionsEnabled = 0,
		Invisible = 0,
		Ragdoll = 0,
		Stun = 0,
		CombatStun = 0,
		Strict_Stun = 0,
		IsAirborne = 0,
		TargetIsMovingAway = 0,
		TargetIsMovingTowards = 0,
		TargetHasHigherHP = 0,
		EntityHasHigherHP = 0,
		Strafing = 0,
		NotStrafing = 1,
		IsNotPathfinding = 1
	},
	Cache = {},
	Doing = {},
	Idling = require(script.Idling),
	Skills = require(script.Skills)
}

function NpcConfig.ClearCache()
	if NpcConfig.Cache ~= nil then
		for k, connection in pairs(NpcConfig.Cache) do
			local typeName = typeof(connection)

			if typeName == "RBXScriptConnection" then
				connection:Disconnect()
			end

			if typeName == "table" and connection.Destroy ~= nil or typeName == "Instance" then
				connection:Destroy()
			end

			NpcConfig.Cache[k] = nil
		end

		NpcConfig.Cache = {}
	end
end

local modulesByName = {}

for _, moduleScript in pairs(script.Signals:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

script.Parent:WaitForChild("AiSignal").Event:Connect(function(p, ...)
	if modulesByName[p] == nil then
		return
	end

	modulesByName[p](NpcConfig, ...)
end)
return NpcConfig