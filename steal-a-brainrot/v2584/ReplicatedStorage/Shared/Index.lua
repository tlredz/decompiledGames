local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Index = require(ReplicatedStorage.Datas.Index)
local Updates = require(ReplicatedStorage.Shared.Updates)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Animals = require(datas.Animals)
local BaseSkinsFlags = require(ReplicatedStorage.Shared.Flags.BaseSkinsFlags)
local Index2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getLimitedTime(p: string)
	local v = Index[p]
	return FFlags:GetInstant(`{p}Timer`, v and v.LimitedMutation)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLimitedEventIndexExpired(p: string)
	local v = Index[p]

	if not v or v.IsMutation then
		return false
	end

	local limitedTime = getLimitedTime(p) -- equivalent call inferred; original call site unknown

	if limitedTime then
		return limitedTime < workspace:GetServerTimeNow()
	end

	return false
end

local function shouldUseExplicitIndexKey(p: string, object)
	local v = Index[p]

	if v == nil or v.CountAllMutations ~= true then
		return false
	else
		local limitedEventIndexExpired = isLimitedEventIndexExpired(p) -- equivalent call inferred; original call site unknown
		return limitedEventIndexExpired and object:Get("Migrations.LimitedIndexProgress_v1") == true
	end
end

function Index2.GetIndexLimitedTime(_, p: string)
	return getLimitedTime(p)
end

function Index2:CanShowInIndex(p: string)
	local animal = Animals[p]
	return not not animal and not (animal.IsEnabled and not animal.IsEnabled()) and not animal.HideFromIndex
end

function Index2.CanProgressIndex(_, p: string)
	local limitedEventIndexExpired = isLimitedEventIndexExpired(p) -- equivalent call inferred; original call site unknown
	return not limitedEventIndexExpired
end

local v = {
	Strawberry = "Strawberry Elephant",
	Meowl = "Meowl",
	Skibidi = "Skibidi Toilet",
	Headless = "Headless Horseman",
	["John Pork"] = "John Pork",
	Spyder = "Spyder Elephant"
}

function Index2:IsComplete(instance, value: string?)
	local v2 = Synchronizer:Get(instance)

	if not v2 then
		return false
	end

	if value == "1 OF 1" then
		return BaseSkinsFlags.OneOfOneEnabled:Get() and instance:GetAttribute("HasOneOfOneBrainrot") == true
	end

	local v3 = v[value]

	if v3 == nil then
		local v4 = v2:Get("Index")
		local count = 0
		local completitionForcedAmount = 0
		local v5 = value and Index[value]

		if v5 and v5.DisableIndex or v5 and v5.Update and not Updates.Methods.IsEnabled(v5.Update) then
			return false
		end

		local index = v5 and v5.Index

		if index then
			local v6 = Index[value]
			local v7

			if v6 == nil or v6.CountAllMutations ~= true then
				v7 = false
			else
				local limitedEventIndexExpired = isLimitedEventIndexExpired(value) -- equivalent call inferred; original call site unknown
				v7 = limitedEventIndexExpired and v2:Get("Migrations.LimitedIndexProgress_v1") == true
			end

			for k, v8 in index do
				if not v8.IgnoreIndexCounter then
					completitionForcedAmount += 1
				end

				local v9 = v4[k]

				if not v9 then
					continue
				end

				local v10

				if v5 and v5.CustomIndex then
					v10 = v9[v5.CustomIndex.Name]
				elseif v7 then
					v10 = v9[value]
				elseif v5 and not v5.IsMutation then
					v10 = next(v9) ~= nil
				else
					v10 = v9[value]
				end

				if v10 then
					count += 1
				end
			end

			local completitionPercent = v5 and v5.CompletitionPercent or value == "Default" and 0.75 or 1

			if completitionPercent ~= 1 then
				completitionForcedAmount = math.max(math.ceil(completitionForcedAmount * completitionPercent), 1)

				if v5 and v5.CompletitionForcedAmount then
					completitionForcedAmount = v5.CompletitionForcedAmount
				end
			end

			return completitionForcedAmount <= count
		else
			for k in Animals do
				if not Index2:CanShowInIndex(k) then
					continue
				end

				completitionForcedAmount += 1
				local v6 = v4[k]

				if v6 and v6[value or "Default"] then
					count += 1
				end
			end

			local completitionPercent = v5 and v5.CompletitionPercent or value == "Default" and 0.75 or 1

			if completitionPercent ~= 1 then
				completitionForcedAmount = math.max(math.ceil(completitionForcedAmount * completitionPercent), 1)

				if v5 and v5.CompletitionForcedAmount then
					completitionForcedAmount = v5.CompletitionForcedAmount
				end
			end

			return completitionForcedAmount <= count
		end
	else
		for _, v4 in v2:Get("AnimalPodiums") do
			if typeof(v4) == "table" and v4.Index == v3 then
				return true
			end
		end

		return false
	end
end

function Index2.GetIndexAnimals(_, p, value: string?)
	local v2 = Synchronizer:Get(p)

	if not v2 then
		return nil
	end

	local v3 = v2:Get("Index")
	local v4 = value and Index[value]
	local index = v4 and v4.Index

	if index then
		local count = 0
		local completitionForcedAmount = 0
		local count2 = 0
		local v5 = Index[value]
		local v6

		if v5 == nil or v5.CountAllMutations ~= true then
			v6 = false
		else
			local limitedEventIndexExpired = isLimitedEventIndexExpired(value) -- equivalent call inferred; original call site unknown
			v6 = limitedEventIndexExpired and v2:Get("Migrations.LimitedIndexProgress_v1") == true
		end

		for k, v7 in index do
			count2 += 1

			if not v7.IgnoreIndexCounter then
				completitionForcedAmount += 1
			end

			local v8 = v3[k]

			if not v8 then
				continue
			end

			local v9

			if v4 and v4.CustomIndex then
				v9 = v8[v4.CustomIndex.Name]
			elseif v6 then
				v9 = v8[value]
			elseif v4 and not v4.IsMutation then
				v9 = next(v8) ~= nil
			else
				v9 = v8[value]
			end

			if v9 then
				count += 1
			end
		end

		local completitionPercent = v4 and v4.CompletitionPercent or value == "Default" and 0.75 or 1

		if completitionPercent ~= 1 then
			completitionForcedAmount = math.max(math.ceil(completitionForcedAmount * completitionPercent), 1)

			if v4 and v4.CompletitionForcedAmount then
				completitionForcedAmount = v4.CompletitionForcedAmount
			end
		end

		return count, completitionForcedAmount, count2
	else
		local count = 0
		local completitionForcedAmount = 0
		local count2 = 0

		for k, _ in Animals do
			if not Index2:CanShowInIndex(k) then
				continue
			end

			count += 1
			completitionForcedAmount += 1
			local v5 = v3[k]

			if not v5 then
				continue
			end

			local v6 = v5[value or "Default"]

			if not v6 or v6 <= 0 then
				continue
			end

			count2 += 1
		end

		local completitionPercent = v4 and v4.CompletitionPercent or value == "Default" and 0.75 or 1

		if completitionPercent ~= 1 then
			completitionForcedAmount = math.max(math.ceil(completitionForcedAmount * completitionPercent), 1)

			if v4 and v4.CompletitionForcedAmount then
				completitionForcedAmount = v4.CompletitionForcedAmount
			end
		end

		return count2, completitionForcedAmount, count
	end
end

function Index2.GetMultipliers(_, p)
	local total = 0

	if not Synchronizer:Get(p) then
		return total
	end

	local v2 = 0 + (Index2:IsComplete(p) == true and 1 or 0)

	for k, v3 in Index do
		if v3.LimitedMutation or not v3.IsMutation then
			continue
		end

		v2 += Index2:IsComplete(p, k) == true and 1 or 0
	end

	total += v2 * 0.5
	return total
end

return Index2