local AssetManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = false
local parts = ReplicatedStorage:WaitForChild("Parts")
local v2 = {}
local v3 = {}
local v4 = 1
local v5 = {
	Speed = "BuffParticles/Speed",
	Stamina = "BuffParticles/Stamina",
	SkillCheck = "BuffParticles/SkillCheck",
	DecodeSpeed = "BuffParticles/DecodeSpeed",
	Stealth = "BuffParticles/Stealth",
	Death = "DeathPart",
	ItemDropEffect = "ItemDrop",
	Smoke = "SmokeParticle"
}

local function _resolvePath(p: string)
	if v5[p] then
		return v5[p]
	end

	return p
end

local function _navigatePath(childName: string)
	if not string.find(childName, "/") then
		return parts:FindFirstChild(childName)
	end

	local child = parts

	for childName2 in string.gmatch(childName, "[^/]+") do
		child = child:FindFirstChild(childName2)

		if not child then
			return nil
		end
	end

	return child
end

local function _trackInstance(clone, model, assetPath: string, duration: number?)
	local v6 = v4
	v4 += 1
	local now = tick()
	local v7 = v2
	local expiresAt

	if duration then
		expiresAt = now + duration or nil
	end

	v7[v6] = {
		instance = clone,
		parent = model,
		assetPath = assetPath,
		createdAt = now,
		expiresAt = expiresAt,
		cleanupScheduled = duration ~= nil
	}

	if not model then
		return v6
	end

	local v10 = model:IsA("Model") and model or model:FindFirstAncestorOfClass("Model")

	if v10 and v10:FindFirstChild("Humanoid") then
		if not v3[v10] then
			v3[v10] = {}
		end

		table.insert(v3[v10], v6)

		if v then
			print("[AssetManager] Tracked", assetPath, "for", v10.Name, "- ID:", v6)
		end
	end

	return v6
end

local function _cleanupTracked(p: number)
	local v6 = v2[p]

	if not v6 then
		return
	end

	if v6.parent then
		local parent = v6.parent:IsA("Model") and v6.parent or v6.parent:FindFirstAncestorOfClass("Model")

		if parent and v3[parent] then
			local index = table.find(v3[parent], p)

			if index then
				table.remove(v3[parent], index)
			end

			if #v3[parent] == 0 then
				v3[parent] = nil
			end
		end
	end

	if v6.instance and v6.instance.Parent then
		v6.instance:Destroy()

		if v then
			print("[AssetManager] Cleaned up", v6.assetPath, "- ID:", p)
		end
	end

	v2[p] = nil
end

function AssetManager:GetAsset(p: string, p2)
	local v6

	if v5[p] then
		v6 = v5[p]
	else
		v6 = p
	end

	local v7 = _navigatePath(v6)

	if v7 then
		return v7
	end

	if not (p2 and p2.optional) then
		warn("[AssetManager] Asset not found:", p, "(resolved to:", v6 .. ")")
	end

	return nil
end

function AssetManager:Clone(p: string, p2)
	local asset = self:GetAsset(p, p2)

	if not asset then
		return nil
	end

	local success, result = pcall(function()
		return asset:Clone()
	end)

	if success then
		return result
	end

	warn("[AssetManager] Failed to clone", p, ":", result)
	return nil
end

function AssetManager:CloneWithCleanup(p: string, p2: number, p3)
	local clone = self:Clone(p, p3)

	if clone then
		Debris:AddItem(clone, p2)
	end

	return clone
end

function AssetManager:CloneBatch(list)
	local clones = {}

	for _, v6 in ipairs(list) do
		local clone = self:Clone(v6)

		if clone then
			table.insert(clones, clone)
		end
	end

	return clones
end

function AssetManager:CloneTracked(assetPath: string, parent, duration: number?, p2)
	local clone = self:Clone(assetPath, p2)

	if not clone then
		return nil, nil
	end

	clone.Parent = parent
	local v6 = _trackInstance(clone, parent, assetPath, duration)

	if duration then
		Debris:AddItem(clone, duration)
		task.delay(duration, function()
			_cleanupTracked(v6)
		end)
	end

	return clone, v6
end

function AssetManager.CleanupTracked(_, p: number)
	_cleanupTracked(p)
end

function AssetManager:CleanupForCharacter(p)
	local v6 = v3[p]

	if v6 then
		local clone = table.clone(v6)

		for _, v7 in ipairs(clone) do
			_cleanupTracked(v7)
		end

		v3[p] = nil

		if v then
			print("[AssetManager] Cleaned up", #clone, "instances for", p.Name)
		end
	elseif v then
		print("[AssetManager] No tracked instances for", p.Name)
	end
end

function AssetManager:GetBuffParticlesFolder(p: string)
	return self:GetAsset("BuffParticles/" .. p)
end

function AssetManager:CloneBuffParticlePair(p: string)
	return self:CloneBatch({ "BuffParticles/" .. p .. "/BuffParticle", "BuffParticles/" .. p .. "/Glow" })
end

function AssetManager:GetTextBoxVariant(p: string?)
	local asset = p and self:GetAsset("TextBox" .. p, {
		optional = true
	})

	if asset then
		return asset
	end

	return self:GetAsset("TextBox")
end

function AssetManager:GetActiveInstanceCount()
	local count = 0

	for _ in pairs(v2) do
		count += 1
	end

	return count
end

function AssetManager.GetActiveInstancesByType(_, p: string)
	local instances = {}

	for _, v6 in pairs(v2) do
		if v6.assetPath == p and v6.instance and v6.instance.Parent then
			table.insert(instances, v6.instance)
		end
	end

	return instances
end

function AssetManager:PrintStats()
	print("========================================")
	print("[AssetManager] Statistics")
	print("========================================")
	print("Active Instances:", self:GetActiveInstanceCount())
	print("Tracked Characters:", #v3)
	print("")
	local v6 = {}

	for _, v7 in pairs(v2) do
		v6[v7.assetPath] = (v6[v7.assetPath] or 0) + 1
	end

	print("By Asset Type:")

	for k, v7 in pairs(v6) do
		print("  ", k, "=", v7)
	end

	print("")
	local now = tick()
	local count = 0

	for _, v7 in pairs(v2) do
		if v7.expiresAt and v7.expiresAt < now then
			count += 1
		end
	end

	if count > 0 then
		warn("[AssetManager] Found", count, "expired instances that weren't cleaned up!")
	end

	print("========================================")
end

function AssetManager.SetDebugMode(_, flag: boolean)
	v = flag
	print("[AssetManager] Debug mode:", flag)
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		local character = player.Character

		if character then
			AssetManager:CleanupForCharacter(character)
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(10)
		local now = tick()
		local count = 0

		for k, v6 in pairs(v2) do
			if v6.expiresAt and v6.expiresAt < now then
				if v6.instance and v6.instance.Parent then
					warn("[AssetManager] Force cleanup expired instance:", v6.assetPath)
					v6.instance:Destroy()
				end

				_cleanupTracked(k)
				count += 1
			end

			if not v6.instance or v6.instance.Parent then
				continue
			end

			_cleanupTracked(k)
			count += 1
		end

		if v and count > 0 then
			print("[AssetManager] Periodic cleanup removed", count, "instances")
		end
	end
end)

if not parts then
	error("[AssetManager] ReplicatedStorage.Parts folder not found! AssetManager cannot function.")
end

print("[AssetManager] Initialized - Tracking:", true, "Debug:", v)
return AssetManager