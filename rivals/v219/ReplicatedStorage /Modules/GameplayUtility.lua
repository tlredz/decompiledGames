local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local maps = ReplicatedStorage.Assets.Temp.Maps
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.TEMP_MAPS_FOLDER = maps
	self.OOB_DEFAULT_WARN_DELAY = 1
	self.OOB_DEFAULT_KILL_DELAY = 4
	self:_Init()
	return self
end

function class.IsThingInWorkspace(_, instance)
	return instance:IsDescendantOf(workspace) or instance:IsDescendantOf(maps)
end

function class:IsEntity(parent)
	while parent and parent ~= workspace do
		if CollectionService:HasTag(parent, "Entity") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return false
end

function class.GetEnvironmentID(_, parent)
	while parent and parent:IsDescendantOf(workspace) do
		local environmentID = parent:GetAttribute("EnvironmentID")

		if environmentID then
			return environmentID
		else
			parent = parent.Parent
		end
	end

	return nil
end

function class.GetSmokeCloudBetweenPoints(_, p, p2)
	for _, v in pairs(CollectionService:GetTagged("SmokeCloud")) do
		if Utility:SphereLineIntersection(v.Position, v.Size.X / 2, p, p2) then
			return v
		end
	end
end

function class.GetSmokeCloudsInSphere(_, p, value, p2, p3)
	local v = value or 0
	local result = {}

	for _, v2 in pairs(CollectionService:GetTagged("SmokeCloud")) do
		if (p - v2.Position).Magnitude > v2.Size.X / 2 + v or p2 and p3 and p3 < Utility:AngleBetweenVectors(
			p2,
			v2.Position - p
		) then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

function class.GetEquippedItems(_, p, list, value)
	if not p then
		return {}
	end

	local v = nil
	local v2 = nil

	for k, v4 in pairs(list) do
		if v4:Get("ObjectID") ~= p then
			continue
		end

		v2 = k
		v = v4
		break
	end

	if not v then
		return {}
	end

	local result = {}

	for i = v2, v2 + (value or 0) do
		result[list[(i - 1) % #list + 1]] = true
	end

	return result
end

function class.KnockbackTaggedParts(_, value, p, p2, p3, p4, p5, p6)
	local v = "RaycastWhitelist" .. (value or "")
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("Knockbackable")

	for _, v2 in pairs(workspace:GetPartBoundsInRadius(p, p2, overlapParams)) do
		if v2.Anchored or v2.Position:FuzzyEq(p) or p5 and p6 and p6 < Utility:AngleBetweenVectors(p5, v2.Position - p) then
			continue
		end

		if not v2:HasTag(v) then
			continue
		end

		if v2:HasTag("TrowelBrick") then
			v2.CustomPhysicalProperties = PhysicalProperties.new(
				0.1,
				v2.CurrentPhysicalProperties.Friction,
				v2.CurrentPhysicalProperties.Elasticity
			)
		end

		v2.Velocity = p4 or (v2.Position - p).Unit * p3 * (1 - (v2.Position - p).Magnitude / p2)
	end
end

function class:GetRaycastRedirection(p, p2, lookDir, p3, p4)
	if p4 <= 0 then
		return lookDir
	end

	local v = {}
	self:GetEntitiesWithinSphere(p, p2, p3, 128, false, nil, nil, nil, function(entity)
		local lookVector = CFrame.new(p3, entity.RootPart.Position).LookVector
		local v2 = {
			Entity = entity,
			LookDir = lookVector,
			Angle = Utility:AngleBetweenVectors(lookDir, lookVector)
		}
		table.insert(v, v2)
	end)
	table.sort(v, function(a, b)
		return a.Angle < b.Angle
	end)

	if v[1] and v[1].Angle < p4 then
		lookDir = v[1].LookDir or lookDir
	end

	return lookDir
end

function class:SwitchingWeaponsMakesSense(p, p2)
	local v = {}

	for k, _ in pairs(ItemLibrary.Classes) do
		v[k] = {}
	end

	for _, v2 in pairs(ShopLibrary:GetReleasedOwnableWeapons(CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET)) do
		local _ = ItemLibrary.Items[v2].Class

		for k, class2 in pairs(ItemLibrary.Classes) do
			if not self:CanUseWeapon(p, p2, v2, class2.Slot) then
				continue
			end

			table.insert(v[k], v2)

			if #v[k] > 1 then
				return true
			end
		end
	end

	return false
end

function class:CanUseWeapon(object2, object3, p, p2)
	if not (p and object2 and object3) then
		return false
	end

	local weaponPool = object2:Get("WeaponPool")
	local weaponPoolFilterType = object2:Get("WeaponPoolFilterType")
	local index

	if weaponPool then
		if weaponPoolFilterType == "Whitelist" then
			index = table.find(weaponPool, p)
		else
			index = false
		end
	else
		index = weaponPool
	end

	if not (table.find(ShopLibrary:GetReleasedOwnableWeapons(CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET), p) or index) then
		return false
	end

	if not (object3:GetWeaponData(p) or object2:Get("IsInShootingRange") or object2:Get("CanUseLockedWeapons") or self:_CanUseWeaponFromFFlag(p) or table.find(
		object2:Get("FreeWeaponTrials") or {},
		p
	)) then
		return false
	end

	if weaponPool then
		if weaponPoolFilterType == "Whitelist" and not table.find(weaponPool, p) or weaponPoolFilterType == "Blacklist" and table.find(
			weaponPool,
			p
		) then
			return false
		end
	end

	if p2 and ItemLibrary.SlotToClass[p2].Name ~= ItemLibrary.Items[p].Class and not object2:Get("WeaponClassRestrictionDisabled") then
		return false
	end

	return true
end

function class.GetSpread(_, p, p2, p3, p4, p5, p6, p7)
	local v = math.min(p3 and p2 or 1, p4 and 0.75 or 1)
	local v2 = math.rad(p) * v

	if p7 and p6 and p6 > 1 and p5 == 1 then
		return CFrame.identity
	end

	if not p7 or not p6 or not (p6 > 1) or p5 == nil then
		return CFrame.Angles(0, 0, 6.283185307179586 * math.random()) * CFrame.Angles(v2 * math.random(), 0, 0)
	end

	local v3 = v2 / 0.75

	if p5 % 2 == 0 then
		return CFrame.Angles(0, 0, 6.283185307179586 / (p6 - 1) * p5) * CFrame.Angles(v3 / 2 / 2, 0, 0)
	end

	return CFrame.Angles(0, 0, 6.283185307179586 / (p6 - 1) * p5) * CFrame.Angles(v3 / 2, 0, 0)
end

function class.IsInWhitelist(_, instance, items)
	for _, instance2 in pairs(items) do
		if instance == instance2 or instance2:IsA("Instance") and instance:IsDescendantOf(instance2) then
			return true
		end
	end

	return false
end

function class:GetMousePositionFromCameraData(p, p2, _, cframe, p3, p4, p5)
	local v = p3 and p3.CFrame * (p4 or CFrame.identity)

	if v then
		cframe = CFrame.new(cframe.Position, v.Position) or cframe
	end

	local v2 = cframe * (p5 or CFrame.identity)
	local _, v3 = self:GetEntitiesFromRaycast(p, p2, v2.Position, v2.LookVector, CONSTANTS.MAX_RAYCAST_DISTANCE)
	return v3.Position
end

function class.GetMouseLocationFromCameraData(_, p, cframe, p2, p3, p4, p5, p6)
	local raycastWhitelist = class:GetRaycastWhitelist(p4, p6)
	local v = p2 and p2.CFrame * (p3 or CFrame.identity)

	if v then
		cframe = CFrame.new(cframe.Position, v.Position) or cframe
	end

	local raycastResult = nil

	for _ = 1, 10 do
		local raycastResult2 = Utility:Raycast(
			cframe.Position,
			cframe.Position + cframe.LookVector,
			p5,
			raycastWhitelist,
			Enum.RaycastFilterType.Include
		)
		raycastResult = Utility:Raycast(
			p.Position,
			raycastResult2.Position,
			p5,
			raycastWhitelist,
			Enum.RaycastFilterType.Include
		)

		if not raycastResult.Instance or raycastResult.Instance.Transparency < 0.99 then
			break
		end

		table.insert(raycastWhitelist, raycastResult.Instance)
	end

	return raycastResult
end

function class:GetRaycastWhitelist(value, object2, options, p)
	local result = p and {} or CollectionService:GetTagged("RaycastWhitelist" .. (value or ""))

	if not object2 then
		return result
	end

	local v = options or {}
	local entityFromModels = {}

	for _, v2 in pairs(CollectionService:GetTagged("Entity")) do
		local entityFromModel = self:GetEntityFromModel(v2)

		if v[entityFromModel] or not object2:IsValidTarget(entityFromModel) or entityFromModel:Get("EnvironmentID") ~= value then
			continue
		end

		for _, v3 in pairs(entityFromModel:GetHitboxes(object2.GrabSmallHitboxes)) do
			table.insert(result, v3)
			entityFromModels[v3] = entityFromModel
		end
	end

	return result, entityFromModels
end

function class:GetEntityFromModel(p)
	if CONSTANTS.IS_SERVER then
		local FighterService = require(ServerStorage.Services.FighterService)
		local EnemyService = require(ServerStorage.Services.EnemyService)
		local fighter = FighterService:GetFighter(p)
		return fighter and fighter.Entity or EnemyService:GetEnemy(p)
	else
		if not CONSTANTS.IS_CLIENT then
			return
		end

		local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
		local EnemyController = require(Players.LocalPlayer.PlayerScripts.Controllers.EnemyController)
		local fighter = FighterController:GetFighter(p)
		return fighter and fighter.Entity or EnemyController:GetEnemy(p)
	end
end

function class:GetEntityFromTouch(p, object2, p2)
	local entityFromModel = self:GetEntityFromModel((self:IsEntity(p2)))

	if entityFromModel and entityFromModel:Get("EnvironmentID") == p and object2:IsValidTarget(entityFromModel) then
		return entityFromModel
	end
end

function class:GetEntitiesWithinSphere(p, p2, position, p3, p4, p5, p6, value, callback, p7)
	if p7 then
		local v = tonumber(p7) or tonumber(false) or 30
		local part = Instance.new("Part")
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Material = Enum.Material.ForceField
		part.CanTouch = false
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Anchored = true
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(1, 1, 1) * p3 * 2
		part.CFrame = CFrame.new(position)
		part.Parent = workspace
		BetterDebris:AddItem(part, v)
		local part2 = Instance.new("Part")
		part2.Color = Color3.fromRGB(255, 0, 0)
		part2.Material = Enum.Material.Neon
		part2.CanTouch = false
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CastShadow = false
		part2.Anchored = true
		part2.Shape = Enum.PartType.Ball
		part2.Size = createVector(0.1, 0.1, 0.1)
		part2.CFrame = CFrame.new(position)
		part2.Parent = workspace
		BetterDebris:AddItem(part2, v)
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = self:GetRaycastWhitelist(p, p2, nil, true)
	local raycastWhitelist = not p4 and self:GetRaycastWhitelist(p)
	local include = not p4 and Enum.RaycastFilterType.Include
	local v = {}

	for _, v2 in pairs(workspace:GetPartBoundsInRadius(position, p3, overlapParams)) do
		local v3 = v2:GetAttribute("IsAssemblyRootPart") and v2 or v2.AssemblyRootPart or v2

		if v[v3] or p5 and p6 and (value or 3) < (v2.Position - position).Magnitude and p6 < Utility:AngleBetweenVectors(
			p5,
			v2.Position - position
		) then
			continue
		end

		local entityFromTouch = self:GetEntityFromTouch(p, p2, v2)

		if not entityFromTouch or v[entityFromTouch] or not entityFromTouch:IsAlive() or not (p4 or not Utility:Raycast(
			position,
			v2.Position,
			(position - v2.Position).Magnitude,
			raycastWhitelist,
			include
		).Instance) then
			continue
		end

		v[entityFromTouch] = true
		v[v3] = true
		task.spawn(callback, entityFromTouch, v2)
	end
end

function class:GetEntitiesFromPoint(p, p2, p3, value)
	local v = {}
	self:GetEntitiesWithinSphere(p, p2, p3, value or 0, nil, nil, nil, nil, function(entity, hitbox)
		table.insert(v, {
			Entity = entity,
			Hitbox = hitbox
		})
	end)
	return v
end

function class:GetEntitiesFromRaycast(p, p2, p3, p4, p5, value, p6, p7)
	local v = p6 and Utility:CloneTable(p6, true) or {}
	local v2 = value or 0
	local v3 = 1
	local raycastResult2 = nil
	local result = {}
	local raycastResult = nil

	while v3 <= 1 + v2 do
		local raycastWhitelist, v5 = self:GetRaycastWhitelist(p, p2, v)
		raycastResult = Utility:Raycast(p3, p3 + p4, p5, raycastWhitelist, Enum.RaycastFilterType.Include)
		local entity = v5[raycastResult.Instance]
		raycastResult2 = raycastResult2 or raycastResult

		if not entity then
			break
		end

		table.insert(result, {
			Entity = entity,
			Hitbox = raycastResult.Instance,
			RaycastResult = raycastResult,
			IsFromPoint = nil
		})
		v[entity] = true

		if entity.Model:GetAttribute("PierceThrough") then
			v2 += 1
		end

		v3 += 1
	end

	for _, v5 in pairs(self:GetEntitiesFromPoint(p, p2, p3)) do
		v5.RaycastResult = raycastResult2
		v5.IsFromPoint = true
		table.insert(result, 1, v5)
	end

	if not (raycastResult and p7) then
		return result, raycastResult
	end

	local magnitude = (raycastResult.Position - p3).Magnitude
	local part = Instance.new("Part")
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Material = Enum.Material.ForceField
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Anchored = true
	part.Size = Vector3.new(0.1, 0.1, magnitude)
	part.CFrame = CFrame.new(p3, raycastResult.Position) * CFrame.new(0, 0, -magnitude / 2)
	part.Parent = workspace
	BetterDebris:AddItem(part, 10)
	return result, raycastResult
end

function class:GetJumpPadPlacement(p, p2, p3, p4, p5, p6)
	local raycastWhitelist = self:GetRaycastWhitelist(p)
	local v = p5 and p5.CFrame * (p6 or CFrame.identity)
	local cframe

	if v then
		cframe = CFrame.new(p4.Position, v.Position) or p4
	else
		cframe = p4
	end

	if cframe ~= cframe then
		cframe = CFrame.new(p4.Position)
	end

	local raycastResult = Utility:Raycast(
		cframe.Position,
		cframe.Position + cframe.LookVector * CONSTANTS.MAX_RAYCAST_DISTANCE,
		CONSTANTS.MAX_RAYCAST_DISTANCE,
		raycastWhitelist,
		Enum.RaycastFilterType.Include
	)
	local raycastResult2 = Utility:Raycast(
		p3.Position,
		p3.Position + (raycastResult.Position - p3.Position).Unit * p2,
		p2,
		raycastWhitelist,
		Enum.RaycastFilterType.Include
	)

	if raycastResult2.Instance and not (raycastResult2.Instance:HasTag("Barrier") or Utility:IsWithinTaggedParts(
		"Barrier",
		raycastResult2.Position
	) or class:IsWithinOOBPart(raycastResult2.Position)) then
		return
			raycastResult2,
			CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(p3.Position * createVector(1, 0, 1), raycastResult2.Position * createVector(1, 0, 1)).Rotation * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
	end

	return raycastResult2, nil
end

function class.GetSubspaceTripminePlacement(_, p, vector2, p2)
	local vector3 = vector2:FuzzyEq(p2) and vector2 or p2 + (vector2 - p2).Unit * math.min(p, (vector2 - p2).Magnitude)
	local identity = vector3:FuzzyEq(p2) and CFrame.identity or CFrame.new(
		vector3 * createVector(1, 0, 1),
		p2 * createVector(1, 0, 1)
	)
	return CFrame.new(vector3) * identity.Rotation
end

function class:GetOOBWarnDelay(p2)
	local selected = p2 or self.OOB_DEFAULT_WARN_DELAY

	if selected == -1 then
		return 1e999
	end

	return selected
end

function class:GetOOBKillDelay(p2)
	local selected = p2 or self.OOB_DEFAULT_KILL_DELAY

	if selected == -1 then
		return 1e999
	end

	return selected
end

function class:IsWithinOOBPart(p, p2)
	if Utility:IsWithinTaggedParts("OutOfBoundsSafePart", p) then
		return nil
	end

	local isWithinTaggedParts = Utility:IsWithinTaggedParts("OutOfBoundsPart", p, p2, true)
	table.sort(isWithinTaggedParts, function(a, b)
		return self:GetOOBWarnDelay(a:GetAttribute("WarnDelay")) + self:GetOOBKillDelay(a:GetAttribute("KillDelay")) < self:GetOOBWarnDelay(b:GetAttribute("WarnDelay")) + self:GetOOBKillDelay(b:GetAttribute("KillDelay"))
	end)
	return isWithinTaggedParts[1]
end

function class:_CanUseWeaponFromFFlag(p)
	local success, result = pcall(function()
		local v

		if CONSTANTS.IS_SERVER then
			v = require(ServerStorage.Services.FFlagService)
		else
			v = require(Players.LocalPlayer.PlayerScripts.Controllers.FFlagController)
		end

		return v:GetFFlag("FreeToUse" .. ItemLibrary.Items[p].Status .. "Weapons")
	end)

	if not success then
		warn("Failed to fetch FreeWeapons FFlag")
	end

	return success and result
end

function class:_Init() end

return class._new()