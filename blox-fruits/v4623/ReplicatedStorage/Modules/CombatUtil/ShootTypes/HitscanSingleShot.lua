local Net = require(game.ReplicatedStorage.Modules.Net)
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
local localPlayer = game.Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
require(game.ReplicatedStorage.Util)
return function(state, p)
	local targetPosition = state.TargetPosition
	local attackerCharacter = state.AttackerCharacter or localPlayer.Character
	raycastParams.FilterDescendantsInstances = { attackerCharacter, workspace.Boats, workspace._WorldOrigin }
	local _ = state.origin
	local cframe = CFrame.lookAt(state.origin, state.TargetPosition)

	if state.Angles then
		cframe *= state.Angles[1].Angle
	end

	local range = p.Range

	if state.AttackerIsMob then
		range = attackerCharacter:GetAttribute("AbilityAggroRange") or range
	end

	local v = (cframe * CFrame.new(0, 0, -range)).Position - cframe.Position
	local raycastResult = workspace:Raycast(state.origin, v.Unit * range, raycastParams)
	local v2 = {}
	local instances = {}
	local instance = raycastResult and raycastResult.Instance

	if instance then
		local rigOfHitPart = CombatUtil:GetRigOfHitPart(instance)
		local humanoid = rigOfHitPart and rigOfHitPart:FindFirstChild("Humanoid")

		if humanoid and humanoid:IsA("NumberValue") then
			if humanoid.Value > 0 then
				table.insert(instances, instance)
				v2[rigOfHitPart] = true
			end
		elseif rigOfHitPart and not rigOfHitPart:FindFirstChild("ForceField") and humanoid and humanoid.Health > 0 and humanoid.RootPart then
			table.insert(instances, instance)
			v2[rigOfHitPart] = true
		end

		state.TargetPosition = raycastResult.Position
		targetPosition = state.TargetPosition
	end

	if instances[1] then
		state.HitLimb = instances[1]
	end

	if not state.HitMap and raycastResult then
		state.HitMap = {
			Hit = raycastResult.Instance,
			Position = raycastResult.Position,
			Normal = raycastResult.Normal
		}
	end

	if state.AttackerIsMob then
		if next(v2) then
			local GunService = require(game.ServerScriptService.Services.GunService)
			GunService:MobRegisterHit(attackerCharacter, targetPosition, instances)
		end
	else
		Net:RemoteEvent("ShootGunEvent"):FireServer(targetPosition, instances)

		for ancestor in v2 do
			if CombatUtil:ApplyDamageHighlight(ancestor, attackerCharacter, p.Name, "Gun") then
				continue
			end

			local filterDescendantsInstances = { ancestor }

			for _, filterDescendantsInstance in raycastParams.FilterDescendantsInstances do
				table.insert(filterDescendantsInstances, filterDescendantsInstance)
			end

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			local v3 = (targetPosition - state.origin).Unit * range
			local raycastResult2 = workspace:Raycast(state.origin, v3, raycastParams)
			state.TargetPosition = raycastResult2 and raycastResult2.Position or state.origin + v3

			if state.HitLimb and state.HitLimb:IsDescendantOf(ancestor) then
				state.HitLimb = nil
			end
		end
	end

	local Effect = require(game.ReplicatedStorage.Effect)
	task.spawn(function()
		Effect.new("Gun_M1.RequestM1"):play(state)
	end)
end