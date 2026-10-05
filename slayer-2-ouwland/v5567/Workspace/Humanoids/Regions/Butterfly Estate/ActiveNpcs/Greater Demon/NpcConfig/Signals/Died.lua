local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(data)
	local ServerStorage = game:GetService("ServerStorage")
	require(ServerStorage.SAM.AiThings.NpcNetwork.Tasks.PerformSkill).CancelAll(data, true)

	if data.Folder == nil or data.Folder:GetAttribute("Temporary") ~= true then
		data.Spawning.Entity = nil
		data.Spawning.LastSpawned = os.clock()
		data.Spawning.ClearCache()
		data.Following.Reset(data)
		data.Properties.Empty = 1
		data.Properties.Spawned = 0
		data.Properties.CanSpawn = 0
		data.Properties.GameplayPaused = 0
		data.Properties.ShouldRun = data.CanRun == false and 0 or 1
		data.Properties.IsDoingSkill = 0
		data.Properties.IsFleeing = 0
		data.Properties.Distance = 0
		data.Properties.InCombatRange = 0
		data.Properties.IsNotInCombatRange = 1
		data.Properties.LowerCombatRange = 0
		data.Properties.TargetIsMovingAway = 0
		data.Properties.TargetIsMovingTowards = 0
		data.Properties.Ragdoll = 0
		data.Properties.Stun = 0
		data.Properties.CombatStun = 0
		data.Properties.Strict_Stun = 0
		data.Properties.TargetHasHigherHP = 0
		data.Properties.EntityHasHigherHP = 0
		data.Properties.Strafing = 0
		data.Properties.NotStrafing = 1
	else
		local entity = data.Spawning.Entity
		local raycastParamsName

		if data.Spawning.Cache ~= nil then
			raycastParamsName = data.Spawning.Cache.RaycastParamsName or nil
		end

		if entity ~= nil then
			entity.Parent = workspace.Debree
		end

		data.Spawning.Entity = nil
		data.Spawning.ClearCache()
		data.Following.ResetOld(data)

		if entity ~= nil then
			PlayerStatResolver.Release(entity)
		end

		RaycastHelper.ReleaseDynamicParams(raycastParamsName)
		data.Folder:Destroy()
	end
end