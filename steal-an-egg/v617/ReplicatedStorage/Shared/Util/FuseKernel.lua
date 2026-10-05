local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fusion = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Fusion
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage2.Data.Assets)
local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
local AssetItem = require(ReplicatedStorage2.Shared.Types.AssetItem)
local EggRecords = require(ReplicatedStorage2.Shared.Util.EggRecords)
local t = require(ReplicatedStorage2.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local strict = t.strict(t.boolean)
local strict2 = t.strict(intersection)
local strict3 = t.strict(t.optional(t.string))
local strict4 = t.strict(t.string)
local strict5 = t.strict(t.table)
local FuseKernel = {}

local function averageOf(list)
	strict5(list)
	assert(#list == fusion.INPUT_COUNT, (`A fuse consumes exactly {fusion.INPUT_COUNT} pets`))
	local total = 0

	for _, v in ipairs(list) do
		strict2(v)
		assert(v > 0, "Every fuse input needs a positive scale")
		total += v
	end

	return total / fusion.INPUT_COUNT
end

local function refusalFor(data, p: string?, flag: boolean, flag2: boolean?)
	if flag2 == nil or data.CreatorTemporary == true == flag2 then
		local v = Assets.Directory[data.Category]

		if v == nil or v.CannotFuse == true then
			return "That pet cannot be fused"
		end

		if data.IsFavorite == true then
			return "Favorite pets cannot be fused"
		end

		if flag == (data.InFuse == true) then
			if p == nil or data.Category == p then
				return nil
			end

			return "All pets must be the same category"
		elseif flag then
			return "That pet is not in this fuse machine"
		else
			return "That pet is already in a fuse machine"
		end
	elseif flag2 then
		return "This fuse only takes temporary creator pets"
	else
		return "Temporary creator pets cannot be fused with permanent ones"
	end
end

function FuseKernel.MayEnterFuse(p: string, p2, p3: string?, flag: boolean, flag2: boolean?)
	strict4(p)
	assert(AssetItem.SerializedAssetItemData(p2))
	strict3(p3)
	strict(flag)
	local v = refusalFor(p2, p3, flag, flag2)
	return v == nil, v
end

function FuseKernel.MayEnterRift(p: string, data)
	strict4(p)
	assert(AssetItem.SerializedAssetItemData(data))

	if Assets.Directory[data.Category] == nil then
		return false, "That pet cannot be offered"
	end

	if data.IsFavorite == true then
		return false, "Favorite pets cannot be offered"
	end

	if data.InFuse == true then
		return false, "That pet is in a fuse machine"
	end

	return true, nil
end

function FuseKernel.BandWeightBias(p, p2: number, p3: number)
	strict2(p2)
	strict2(p3)
	assert(p2 > 0, "A scale band cannot start at or below zero")
	assert(p2 <= p3, "A scale band cannot end below where it starts")
	return (math.exp(math.log((averageOf(p))) / 0.6931471805599453 * (math.log((p2 + p3) / 2) / 0.6931471805599453) * fusion.BIAS_STRENGTH))
end

function FuseKernel.DrawFusedScale(p, p2)
	averageOf(p)
	return EggRecords.DrawAssetScale(p2, function(p3: number, p4: number)
		return FuseKernel.BandWeightBias(p, p3, p4)
	end)
end

function FuseKernel.PriceFor(list)
	assert(AssetItem.AssetItemDataArray(list))
	assert(#list == fusion.INPUT_COUNT, (`Pricing a fuse needs exactly {fusion.INPUT_COUNT} pets`))
	local v = fusion.PRICED_MINUTES_OF_INCOME * 60
	local total = 0
	local v2 = 0

	for _, v3 in ipairs(list) do
		total += AssetEarnings.RatePerSecond(v3) * v
		v2 = math.max(v2, #v3.Mutations)
	end

	local ONE_MUTATION_SURCHARGE = 1

	if v2 == 1 then
		ONE_MUTATION_SURCHARGE = fusion.ONE_MUTATION_SURCHARGE
	elseif v2 >= 2 then
		ONE_MUTATION_SURCHARGE = fusion.MANY_MUTATION_SURCHARGE
	end

	return (math.floor(math.floor(total) * ONE_MUTATION_SURCHARGE))
end

return FuseKernel