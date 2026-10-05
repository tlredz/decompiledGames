local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = {}
local v2 = nil
local v3 = false

local function anyClaims()
	return next(v) ~= nil
end

local function findTemplate()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local spawnLock

	if assets ~= nil then
		spawnLock = assets:FindFirstChild("SpawnLock")
	end

	if spawnLock == nil and not v3 then
		v3 = true
		warn("SpawnLock: ReplicatedStorage.Assets.SpawnLock does not exist, so the spawn barrier cannot be raised")
	end

	return spawnLock
end

local function collidableParts(folder)
	local parts = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function consider(part)
		if part:IsA("BasePart") and part.CanCollide then
			parts[#parts + 1] = part
		end
	end

	consider(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in folder:GetDescendants() do
		consider(descendant) -- equivalent call inferred; original call site unknown
	end

	return parts
end

local function touchesCharacter(p, character)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { character }
	return #Workspace:GetPartsInPart(p, overlapParams) > 0
end

local function solidifyOnceClear(clone)
	local v5 = collidableParts(clone)

	for _, v6 in v5 do
		v6.CanCollide = false
	end

	if #v5 == 0 then
		return
	end

	task.spawn(function()
		while #v5 > 0 do
			RunService.Heartbeat:Wait()

			if clone.Parent == nil then
				break
			end

			local localPlayer = Players.LocalPlayer
			local character

			if localPlayer ~= nil then
				character = localPlayer.Character
			end

			for i = #v5, 1, -1 do
				local v6 = v5[i]

				if not (character == nil or not touchesCharacter(v6, character)) then
					continue
				end

				v6.CanCollide = true
				table.remove(v5, i)
			end
		end
	end)
end

local function raiseBarrier()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local spawnLock

	if assets ~= nil then
		spawnLock = assets:FindFirstChild("SpawnLock")
	end

	if spawnLock == nil and not v3 then
		v3 = true
		warn("SpawnLock: ReplicatedStorage.Assets.SpawnLock does not exist, so the spawn barrier cannot be raised")
	end

	if spawnLock == nil then
		return nil
	end

	local clone = spawnLock:Clone()
	solidifyOnceClear(clone)
	clone.Parent = Workspace
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncBarrier()
	local v5 = v2

	if next(v) ~= nil then
		if v5 == nil or v5.Parent == nil then
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local spawnLock

			if assets ~= nil then
				spawnLock = assets:FindFirstChild("SpawnLock")
			end

			if spawnLock == nil and not v3 then
				v3 = true
				warn("SpawnLock: ReplicatedStorage.Assets.SpawnLock does not exist, so the spawn barrier cannot be raised")
			end

			local clone

			if spawnLock ~= nil then
				clone = spawnLock:Clone()
				solidifyOnceClear(clone)
				clone.Parent = Workspace
			end

			v2 = clone
		end
	else
		v2 = nil

		if v5 ~= nil then
			v5:Destroy()
		end
	end
end

local v4 = {
	ObtainLock = function()
		local frozen = table.freeze({})
		v[frozen] = true
		syncBarrier() -- equivalent call inferred; original call site unknown
		return function()
			if v[frozen] == nil then
				return
			end

			v[frozen] = nil
			syncBarrier() -- equivalent call inferred; original call site unknown
		end
	end,
	IsLocked = function()
		return next(v) ~= nil
	end
}
return table.freeze(v4)