local FishHelper = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FishingIndexInventoryData = require(game.ReplicatedStorage.FishReplicated:WaitForChild("FishingIndexInventoryData"))
local FishInventory = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SerData"):WaitForChild("FishInventory"))
local FishIndex = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SerData"):WaitForChild("FishIndex"))
local Base91 = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Base91"))
local isServer = RunService:IsServer()
local v = {
	Shiny = 1.5
}

function FishHelper.DecodeFishInventory(str)
	if str then
		return FishInventory.decode(Base91.decodeBuffer(buffer.fromstring(str)))
	end

	return {}
end

function FishHelper.GetFishInventory(instance)
	if isServer ~= true then
		error("FishHelper::GetFishInventory cannot be called on the client!")
	end

	local Global = require(game.ReplicatedStorage.Global)
	local wrappedPlayer = Global.getWrappedPlayer(instance)

	if not wrappedPlayer then
		return nil
	end

	local session = wrappedPlayer.getSession()

	if not session then
		return nil
	end

	local data = session.Data

	if not data then
		return nil
	end

	if not data.EncodedFishInventory then
		return {}
	end

	instance:SetAttribute("EncodedFishIndex", data.EncodedFishIndex)
	return FishHelper.DecodeFishInventory(data.EncodedFishInventory)
end

function FishHelper.SetFishInventory(p, p2)
	if isServer ~= true then
		error("FishHelper::SetFishInventory cannot be called on the client!")
	end

	local Global = require(game.ServerStorage.Global)
	local wrappedPlayer = Global.getWrappedPlayer(p)

	if not wrappedPlayer then
		return false
	end

	local session = wrappedPlayer.getSession()

	if not session then
		return false
	end

	local data = session.Data

	if not data then
		return false
	end

	data.EncodedFishInventory = buffer.tostring(Base91.encodeBuffer(FishInventory.encode(p2)))
	return true
end

function FishHelper.AddFishToIndex(instance, p: number, p2: number)
	if isServer ~= true then
		error("FishHelper::AddFishToIndex cannot be called on the client!")
	end

	local Global = require(game.ReplicatedStorage.Global)
	local wrappedPlayer = Global.getWrappedPlayer(instance)

	if not wrappedPlayer then
		return false
	end

	local session = wrappedPlayer.getSession()

	if not session then
		return false
	end

	local data = session.Data

	if not data then
		return false
	end

	local encodedFishIndex = data.EncodedFishIndex
	local v2 = encodedFishIndex == nil and {} or FishIndex.decode(Base91.decodeBuffer(buffer.fromstring(encodedFishIndex)))
	local v3 = v2[p]

	if v3 == nil then
		v2[p] = {
			CaughtCount = 1,
			LowestWeight = p2,
			HighestWeight = p2
		}
	else
		v3.CaughtCount += 1
		v3.LowestWeight = math.min(v3.LowestWeight, p2)
		v3.HighestWeight = math.max(v3.HighestWeight, p2)
	end

	data.EncodedFishIndex = buffer.tostring(Base91.encodeBuffer(FishIndex.encode(v2)))
	instance:SetAttribute("EncodedFishIndex", data.EncodedFishIndex)
	return true
end

function FishHelper.GetTrueWeightRaw(p: number, p2: number, items)
	local v2 = FishingIndexInventoryData == nil and {
		MinWeight = 10,
		MaxWeight = 50
	} or FishingIndexInventoryData.FishIndex[p]
	local total = 1

	if items then
		for _, item in items do
			local v3 = v[item]

			if v3 then
				total += 1 - v3
			end
		end
	end

	local v3 = v2.MinWeight * total
	return v3 + (v2.MaxWeight * total - v3) / 65535 * p2
end

function FishHelper.GetTrueWeight(data)
	return FishHelper.GetTrueWeightRaw(data.Id, data.Weight, data.Modifiers)
end

function FishHelper.FormatTrueWeight(p: number)
	return (string.gsub(string.format("%.2fkg", p), ".00", ""))
end

function FishHelper:SetTrueWeight(p: number)
	local v2 = FishingIndexInventoryData == nil and {
		MinWeight = 10,
		MaxWeight = 50
	} or FishingIndexInventoryData.FishIndex[self.Id]
	local total = 1

	for _, modifier in self.Modifiers do
		local v3 = v[modifier]

		if v3 then
			total += 1 - v3
		end
	end

	local v3 = v2.MinWeight * total
	local v4 = v2.MaxWeight * total
	local v5 = (v4 - v3) / 65535
	self.Weight = math.round((math.max(v3, (math.min(v4, p))) - v3) / v5)
	self.Weight = math.max(0, (math.min(65535, self.Weight)))
end

function FishHelper.newFish(p: string, p2: number, options)
	local v2 = {
		Id = FishingIndexInventoryData.NameMap[p],
		Modifiers = options or {},
		Weight = 0,
		WEAK_UID = 0
	}
	local HttpService = game:GetService("HttpService")
	v2.WEAK_UID = HttpService:GenerateGUID(false)
	assert(v2.Id)
	FishHelper.SetTrueWeight(v2, p2)
	return v2
end

return FishHelper