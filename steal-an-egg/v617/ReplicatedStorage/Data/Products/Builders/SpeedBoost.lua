require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)

local function validateTier(p, speedBoostTierIndex: number)
	if p == nil then
		return false, "Data not loaded"
	end

	local speedBoostTierIndex2 = TreadmillUtil.ResolveSpeedBoostTierIndex(p)

	if TreadmillUtil.MAX_SPEED_BOOST_TIER_INDEX <= speedBoostTierIndex2 then
		return false, "Max speed boost owned"
	end

	if speedBoostTierIndex == speedBoostTierIndex2 + 1 then
		return true
	end

	return false, "Purchase the previous speed boost first"
end

local function CreateSpeedBoostProductConfig(name: string, productId: number, speedBoostTierIndex: number, speedBoostMultiplier: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)
	t.strict(t.number)(speedBoostTierIndex)
	t.strict(t.number)(speedBoostMultiplier)

	if Constants.IS_STUDIO then
		local v

		if speedBoostTierIndex >= 1 then
			v = speedBoostTierIndex <= TreadmillUtil.MAX_SPEED_BOOST_TIER_INDEX
		else
			v = false
		end

		assert(v, (`Invalid speed boost tier index {speedBoostTierIndex}`))
		assert(
			TreadmillUtil.GetSpeedBoostMultiplierForTierIndex(speedBoostTierIndex) == speedBoostMultiplier,
			(`Invalid speed boost multiplier {speedBoostMultiplier} for tier {speedBoostTierIndex}`)
		)
	end

	local formatSpeedMultiplierValue = TreadmillUtil.FormatSpeedMultiplierValue(speedBoostMultiplier)

	local function authorize(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait and v then
			return validateTier(v, speedBoostTierIndex)
		end

		return false, "Player profile not found"
	end

	local function ResolveFailedReceipt(p4, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if not Database.IsPlayerLoaded(p4) then
			return "Retry"
		end

		local unsafeGetProfileAwait, v = Database.UnsafeGetProfileAwait(p4)

		if not (unsafeGetProfileAwait and v) then
			return "Retry"
		end

		if speedBoostTierIndex <= TreadmillUtil.ResolveSpeedBoostTierIndex(v) then
			return "Satisfied"
		end

		return "Credit"
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		return validateTier(Save.Await(), speedBoostTierIndex)
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local v, v2 = Database.UpdateProfileImmutable(p4, function(p5)
			local v3 = speedBoostTierIndex
			local v4

			if p5 == nil then
				v4 = false
			else
				local speedBoostTierIndex2 = TreadmillUtil.ResolveSpeedBoostTierIndex(p5)

				if TreadmillUtil.MAX_SPEED_BOOST_TIER_INDEX <= speedBoostTierIndex2 then
					v4 = false
				else
					v4 = v3 == speedBoostTierIndex2 + 1
				end
			end

			if not v4 then
				return false
			end

			local clone = table.clone(p5)
			clone.SpeedBoostTierIndex = speedBoostTierIndex
			return clone
		end):await()

		if v and v2 then
			return true
		end

		return false, "Purchase the previous speed boost first"
	end

	return {
		Name = name,
		ProductId = productId,
		DisplayName = `{formatSpeedMultiplierValue} Speed Boost`,
		Desc = `Upgrade your permanent speed boost to {formatSpeedMultiplierValue}.`,
		SpeedBoostTierIndex = speedBoostTierIndex,
		SpeedBoostMultiplier = speedBoostMultiplier,
		OneTime = true,
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
end

return CreateSpeedBoostProductConfig