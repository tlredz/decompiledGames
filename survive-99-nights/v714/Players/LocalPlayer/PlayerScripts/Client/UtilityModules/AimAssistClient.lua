local AimAssistClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local instances = {}
local v = {
	Crossbow = true,
	["Infernal Crossbow"] = true
}

function GetMaxAngle()
	local platform = Client.Utility.GetPlatform()

	if platform == "Console" then
		return 2.5, 60, 12
	elseif platform == "Mobile" then
		return 8, 90, 18
	end

	return 1, nil
end

function AimAssistClient.GetNearestEnemy(p, p2)
	local v2 = 1e999
	local v3 = nil

	for _, v4 in pairs(instances) do
		if v4:GetAttribute("Tamed") or p2 and p2[v4] then
			continue
		end

		local magnitude = (v4:GetPivot().Position - p).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = v4
		v2 = magnitude
	end

	return v3, v2
end

function AimAssistClient.GetAimAssistDir(p, p2, p3, p4, value)
	local result = {}
	local v2, v3, v4 = GetMaxAngle()

	if p4 then
		v2 = p4
		v3 = nil
		v4 = nil
	end

	if v2 == nil or p3 and v[p3] then
		return p2
	end

	local v5 = value or 500
	local projectileHit = Client.CollisionUtility.GetProjectileHit(p, p + p2 * v5)

	if projectileHit and projectileHit.Instance then
		local parent = projectileHit.Instance.Parent

		if parent and parent:HasTag("NPC") and not (parent:GetAttribute("NotAttackable") or parent:GetAttribute("NotDamageable")) then
			return p2, { parent }
		end
	end

	local v6 = math.rad(v2)
	local v7 = v3 and math.rad(v3)
	local v8 = -1

	for _, v9 in pairs(instances) do
		if v9:GetAttribute("Tamed") then
			continue
		end

		local position = v9:GetPivot().Position
		local v10 = position - p
		local magnitude = v10.Magnitude

		if not (magnitude < v5) then
			continue
		end

		local unit = v10.Unit
		local angleBetweenVectors = Client.Utility.GetAngleBetweenVectors(p2, unit)
		local v11

		if v7 then
			if angleBetweenVectors < v7 then
				v11 = magnitude < v4
			else
				v11 = false
			end
		else
			v11 = v7
		end

		if not (angleBetweenVectors < v6 or v11) then
			continue
		end

		local v12 = math.clamp(1 - magnitude / v5, 0, 1)
		local v13 = (v11 and 2 or v12) + math.clamp(1 - angleBetweenVectors / v6, 0, 1) * 2

		if not (v8 < v13) then
			continue
		end

		local projectileHit2 = Client.CollisionUtility.GetProjectileHit(p, position)

		if not (projectileHit2 and (projectileHit2.Instance.Parent == v9 or projectileHit2.Instance.Parent.Parent == v9)) then
			continue
		end

		if angleBetweenVectors < v6 / 2 then
			table.insert(result, v9)
		end

		v8 = v13
		p2 = unit
	end

	return p2, result
end

function NPCAdded(instance)
	if not instance:GetAttribute("NotAttackable") then
		table.insert(instances, instance)
	end
end

function NPCRemoved(p)
	local index = table.find(instances, p)

	if index then
		table.remove(instances, index)
	end
end

function AimAssistClient.Init()
	Client.Utility.ForAllTagged("NPC", NPCAdded, NPCRemoved)
end

return AimAssistClient