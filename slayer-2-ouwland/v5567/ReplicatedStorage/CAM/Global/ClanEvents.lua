local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Clans = require(ReplicatedStorage.CAM.Clans)
local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local raritiesByName = {}
local ClanEvents = {
	FOLDER_NAME = "ClanEvents"
}

for _, rarity in Clans.Rarities do
	raritiesByName[string.lower(rarity.name)] = rarity.rarity
end

function ClanEvents.RarityIndex(value)
	if type(value) == "string" then
		return raritiesByName[string.lower(value)]
	end

	return nil
end

function ClanEvents.RarityNames()
	local names = {}

	for _, rarity in Clans.Rarities do
		table.insert(names, rarity.name)
	end

	return names
end

local function rootOf(p)
	local _, v = Utility.GetData(p)

	if v ~= nil then
		return v
	end

	local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
	local data

	if player_Service ~= nil then
		data = player_Service:FindFirstChild("Data")
	end

	if data == nil then
		return nil
	end

	local v2

	if RunService:IsRunning() then
		v2 = p.Name
	else
		v2 = `{p.Name}-Studio`
	end

	return data:FindFirstChild(v2)
end

function ClanEvents.Root(p)
	if p == nil then
		return nil
	end

	return rootOf(p)
end

function ClanEvents.Folder(p)
	if p == nil then
		return nil
	end

	local v = rootOf(p)

	if v == nil then
		return nil
	end

	return (v:FindFirstChild(ClanEvents.FOLDER_NAME))
end

local function folderOf(p, flag: boolean)
	if p == nil then
		return nil
	end

	local parent = rootOf(p)

	if parent == nil then
		return nil
	end

	local v2 = parent:FindFirstChild(ClanEvents.FOLDER_NAME)

	if v2 ~= nil then
		return v2
	end

	if not flag then
		return nil
	end

	v2 = Instance.new("Folder")
	v2.Name = ClanEvents.FOLDER_NAME
	v2.Parent = parent
	return v2
end

function ClanEvents.Read(p)
	local result = {}
	local child

	if p ~= nil then
		local v = rootOf(p)

		if v ~= nil then
			child = v:FindFirstChild(ClanEvents.FOLDER_NAME)

			if child == nil then
				child = nil
			end
		end
	end

	if child == nil then
		return result
	end

	for _, folder in child:GetChildren() do
		if not (folder:IsA("Folder") and Clans.GetClan(folder.Name) ~= nil) then
			continue
		end

		local rarityTo = folder:FindFirstChild("RarityTo")
		local spins = folder:FindFirstChild("Spins")

		if not (rarityTo ~= nil and spins ~= nil) then
			continue
		end

		local rarityIndex = ClanEvents.RarityIndex(rarityTo.Value)
		local spins2 = spins.Value

		if rarityIndex == nil or spins2 <= 0 then
			continue
		end

		result[folder.Name] = {
			rarity = rarityIndex,
			spins = spins2
		}
	end

	return result
end

function ClanEvents.RarityOf(p: string?, p2)
	if p == nil then
		return nil
	end

	local clan = Clans.GetClan(p)

	if clan == nil then
		return nil
	end

	local v = ClanEvents.Read(p2)[p]

	if v == nil then
		return clan.rarity
	end

	return v.rarity
end

function ClanEvents.TierOf(p: string?, p2)
	local rarity = ClanEvents.RarityOf(p, p2)

	if rarity == nil then
		return nil
	end

	for _, rarity2 in Clans.Rarities do
		if rarity2.rarity == rarity then
			return rarity2
		end
	end

	return nil
end

function ClanEvents.ByRarity(p)
	local v = ClanEvents.Read(p)
	local result = {}

	for _, rarity in Clans.Rarities do
		result[rarity.rarity] = {}
	end

	for _, rarity in Clans.Rarities do
		for k, v2 in Clans.ByRarity[rarity.rarity] do
			local v3 = v[k]
			local v4

			if v3 == nil or result[v3.rarity] == nil then
				v4 = rarity.rarity
			else
				v4 = v3.rarity
			end

			result[v4][k] = v2
		end
	end

	return result
end

function ClanEvents.BuildPool(options)
	local v = {}
	local v2 = options or {}

	for _, rarity in Clans.Rarities do
		v[rarity.rarity] = {}
	end

	for _, rarity in Clans.Rarities do
		for k in pairs(Clans.ByRarity[rarity.rarity]) do
			local rarity2 = v2[k] or rarity.rarity

			if v[rarity2] == nil then
				rarity2 = rarity.rarity
			end

			table.insert(v[rarity2], k)
		end
	end

	local result = {}

	for _, rarity in Clans.Rarities do
		local v3 = v[rarity.rarity]

		if not (#v3 > 0) then
			continue
		end

		local v4 = rarity.chance / #v3

		for _, v5 in v3 do
			result[v5] = v4
		end
	end

	return result
end

local function signatureOf(items)
	local v = {}

	for k, item in items do
		table.insert(v, (`{k}={item.rarity}`))
	end

	table.sort(v)
	return table.concat(v, ";")
end

function ClanEvents.Signature(p)
	return signatureOf(ClanEvents.Read(p))
end

local v = {}

function ClanEvents.Wheel(p)
	local v2 = ClanEvents.Read(p)
	local v3 = signatureOf(v2)

	if v3 == "" then
		return Spinners.Clan
	end

	local v4 = v[v3]

	if v4 ~= nil then
		return v4
	end

	local rarities = {}

	for k, v5 in v2 do
		rarities[k] = v5.rarity
	end

	local v5 = Spinners.new({
		Cost = Spinners.Clan.Cost,
		Pool = ClanEvents.BuildPool(rarities)
	})
	v[v3] = v5
	return v5
end

function ClanEvents.Grant(p, name: string, name2: string, value: number)
	if p == nil or Clans.GetClan(name) == nil then
		return false
	end

	local rarityIndex = ClanEvents.RarityIndex(name2)

	if rarityIndex == nil then
		return false
	end

	local v2 = math.floor(value or 0)

	if v2 <= 0 then
		return false
	end

	local parent

	if p ~= nil then
		local parent2 = rootOf(p)

		if parent2 ~= nil then
			parent = parent2:FindFirstChild(ClanEvents.FOLDER_NAME)

			if parent == nil then
				parent = Instance.new("Folder")
				parent.Name = ClanEvents.FOLDER_NAME
				parent.Parent = parent2
			end
		end
	end

	if parent == nil then
		return false
	end

	local parent3 = parent:FindFirstChild(name)

	if parent3 == nil then
		parent3 = Instance.new("Folder")
		parent3.Name = name
		parent3.Parent = parent
	end

	local v5 = parent3:FindFirstChild("RarityTo")

	if v5 == nil then
		v5 = Instance.new("StringValue")
		v5.Name = "RarityTo"
		v5.Parent = parent3
	end

	local v6 = parent3:FindFirstChild("Spins")

	if v6 == nil then
		v6 = Instance.new("NumberValue")
		v6.Name = "Spins"
		v6.Parent = parent3
	end

	for _, rarity in Clans.Rarities do
		if rarity.rarity ~= rarityIndex then
			continue
		end

		name2 = rarity.name
		break
	end

	v5.Value = name2
	v6.Value = v2
	return true
end

function ClanEvents.Clear(p, childName: string?)
	local child

	if p ~= nil then
		local v2 = rootOf(p)

		if v2 ~= nil then
			child = v2:FindFirstChild(ClanEvents.FOLDER_NAME)

			if child == nil then
				child = nil
			end
		end
	end

	if child == nil then
		return
	end

	if childName == nil then
		Utility.ClearChildren(child)
		return
	end

	local child2 = child:FindFirstChild(childName)

	if child2 ~= nil then
		child2:Destroy()
	end
end

function ClanEvents.Consume(p)
	local child

	if p ~= nil then
		local v2 = rootOf(p)

		if v2 ~= nil then
			child = v2:FindFirstChild(ClanEvents.FOLDER_NAME)

			if child == nil then
				child = nil
			end
		end
	end

	if child == nil then
		return
	end

	for _, folder in child:GetChildren() do
		if not folder:IsA("Folder") then
			continue
		end

		local spins = folder:FindFirstChild("Spins")

		if spins == nil then
			folder:Destroy()
		else
			local v2 = spins.Value - 1

			if v2 <= 0 then
				folder:Destroy()
			else
				spins.Value = v2
			end
		end
	end
end

return ClanEvents