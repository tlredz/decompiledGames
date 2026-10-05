local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
require(ReplicatedStorage.Shared.Types.AssetItem)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local rank = Rarity.Rarities.Secret.Rank
local v = {
	CFrame.new(-17.4227905, 1.14494324, -23.6600342),
	CFrame.new(-13.1647339, 1.14494324, -28.0780945),
	CFrame.new(-7.01275635, 1.14494324, -31.1100464),
	CFrame.new(7.54925537, 1.79094315, -31.1380615),
	CFrame.new(13.3172607, 1.14494324, -28.1280518),
	CFrame.new(17.959259, 1.14494324, -24.9380493)
}
local SpecialLuckyBlockAsset = {}

local function qualifies(p: string)
	local v2 = Assets.Directory[p]
	local luckyBlockDropTable = v2 and v2.LuckyBlockDropTable or nil
	return typeof(luckyBlockDropTable) == "table" and #luckyBlockDropTable > 0
end

local function stampOf(value: string, p)
	local specialLuckyBlockCapturedAt = p.SpecialLuckyBlockCapturedAt

	if typeof(specialLuckyBlockCapturedAt) == "number" then
		return specialLuckyBlockCapturedAt
	end

	return string.byte(value, 1) or 0
end

local function shelfOf(p)
	local specialLuckyBlockColumn = p.SpecialLuckyBlockColumn
	local v2

	if typeof(specialLuckyBlockColumn) == "number" and specialLuckyBlockColumn >= 1 then
		v2 = specialLuckyBlockColumn <= 6
	else
		v2 = false
	end

	if v2 then
		return specialLuckyBlockColumn
	end

	return nil
end

local function olderFirst(p, p2)
	local uid = p.uid
	local specialLuckyBlockCapturedAt = p.data.SpecialLuckyBlockCapturedAt

	if typeof(specialLuckyBlockCapturedAt) ~= "number" then
		specialLuckyBlockCapturedAt = string.byte(uid, 1) or 0
	end

	local uid2 = p2.uid
	local specialLuckyBlockCapturedAt2 = p2.data.SpecialLuckyBlockCapturedAt

	if typeof(specialLuckyBlockCapturedAt2) ~= "number" then
		specialLuckyBlockCapturedAt2 = string.byte(uid2, 1) or 0
	end

	if specialLuckyBlockCapturedAt == specialLuckyBlockCapturedAt2 then
		return p.uid < p2.uid
	end

	return specialLuckyBlockCapturedAt < specialLuckyBlockCapturedAt2
end

function SpecialLuckyBlockAsset.MatchesCategory(p: string)
	local v2 = Assets.Directory[p]
	local luckyBlockDropTable = v2 and v2.LuckyBlockDropTable or nil
	return typeof(luckyBlockDropTable) == "table" and #luckyBlockDropTable > 0
end

function SpecialLuckyBlockAsset.Matches(p)
	local category = p.Category
	local v2 = Assets.Directory[category]
	local luckyBlockDropTable = v2 and v2.LuckyBlockDropTable or nil
	return typeof(luckyBlockDropTable) == "table" and #luckyBlockDropTable > 0
end

function SpecialLuckyBlockAsset.Capacity()
	return 36
end

function SpecialLuckyBlockAsset.ProgressGoalForCategory(p: string)
	local rarity = Assets.Directory[p].Rarity
	local rank2 = rarity and rarity.Rank
	assert(typeof(rank2) == "number", (`Special lucky block "{p}" has no rarity rank`))

	if rank2 < rank then
		return 1
	end

	if rank2 == rank then
		return 2
	end

	return 3
end

function SpecialLuckyBlockAsset.ProgressGoalFor(p)
	return SpecialLuckyBlockAsset.ProgressGoalForCategory(p.Category)
end

function SpecialLuckyBlockAsset.CountHeld(items)
	local total = 0

	for _, item in pairs(items) do
		total += SpecialLuckyBlockAsset.Matches(item) and 1 or 0
	end

	return total
end

function SpecialLuckyBlockAsset.NextOpenColumn(items, p: string?)
	local v2 = {}

	for k, item in pairs(items) do
		local specialLuckyBlockColumn

		if not (k == p or not SpecialLuckyBlockAsset.Matches(item)) then
			specialLuckyBlockColumn = item.SpecialLuckyBlockColumn
			local v3

			if typeof(specialLuckyBlockColumn) == "number" and specialLuckyBlockColumn >= 1 then
				v3 = specialLuckyBlockColumn <= 6
			else
				v3 = false
			end

			if not v3 then
				specialLuckyBlockColumn = nil
			end
		end

		if specialLuckyBlockColumn ~= nil then
			v2[specialLuckyBlockColumn] = (v2[specialLuckyBlockColumn] or 0) + 1
		end
	end

	local v3 = 1e999
	local v4 = nil

	for i = 1, 6 do
		local v5 = v2[i] or 0

		if not (v5 < 6 and v5 < v3) then
			continue
		end

		v4 = i
		v3 = v5
	end

	return v4
end

function SpecialLuckyBlockAsset.BuildLayout(items, cframe: CFrame)
	local v2 = {}

	for k, item in pairs(items) do
		local specialLuckyBlockColumn

		if SpecialLuckyBlockAsset.Matches(item) then
			specialLuckyBlockColumn = item.SpecialLuckyBlockColumn
			local v3

			if typeof(specialLuckyBlockColumn) == "number" and specialLuckyBlockColumn >= 1 then
				v3 = specialLuckyBlockColumn <= 6
			else
				v3 = false
			end

			if not v3 then
				specialLuckyBlockColumn = nil
			end
		end

		if specialLuckyBlockColumn == nil then
			continue
		end

		local v3 = v2[specialLuckyBlockColumn] or {}
		v2[specialLuckyBlockColumn] = v3
		v3[#v3 + 1] = {
			uid = k,
			data = item
		}
	end

	local result = {}

	for i = 1, 6 do
		local v3 = v2[i]

		if v3 == nil then
			continue
		end

		table.sort(v3, olderFirst)

		for i2 = 1, math.min(#v3, 6) do
			local v4 = createVector(0, 1, 0) * ((i2 - 1) * 6)
			result[#result + 1] = {
				uid = v3[i2].uid,
				data = v3[i2].data,
				column = i,
				row = i2,
				cframe = cframe * v[i] + v4
			}
		end
	end

	return result
end

return SpecialLuckyBlockAsset