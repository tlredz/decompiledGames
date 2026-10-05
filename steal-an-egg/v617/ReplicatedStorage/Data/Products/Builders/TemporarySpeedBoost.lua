require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)

local function canPurchaseTemporarySpeedBoost(p)
	if p == nil then
		return false, "Data not loaded"
	end

	return true
end

local function CreateTemporarySpeedBoostProductConfig(name: string, productId: number, durationSeconds: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)
	t.strict(t.number)(durationSeconds)
	assert(durationSeconds > 0, "Temporary speed boost duration must be positive")
	local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	local v = BalanceConfig.Bind("Game.Balance.ProductRewards." .. name, {
		DurationSeconds = durationSeconds
	}, true, false, function(p4)
		assert(p4.DurationSeconds > 0)
	end)

	local function durationLabel()
		return TreadmillUtil.FormatTemporarySpeedBoostProductDuration(v.DurationSeconds)
	end

	local function authorize(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v2 = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait and v2 then
			return canPurchaseTemporarySpeedBoost(v2)
		end

		return false, "Player profile not found"
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		return canPurchaseTemporarySpeedBoost(Save.Await())
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local SpeedPowerService = require(ServerScriptService.Controllers.SpeedPowerService)
		return SpeedPowerService.AddTemporarySpeedBoostDuration(p4, v.DurationSeconds)
	end

	local v2 = {
		Name = name,
		ProductId = productId,
		DisplayName = `x2 Speed Boost ({TreadmillUtil.FormatTemporarySpeedBoostProductDuration(v.DurationSeconds)})`,
		Desc = `Double all speed gains for {TreadmillUtil.FormatTemporarySpeedBoostProductDuration(v.DurationSeconds)}.`,
		TemporarySpeedBoostDurationSeconds = v.DurationSeconds,
		TemporarySpeedBoostMultiplier = TreadmillUtil.GetTemporarySpeedBoostMultiplier(),
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
	local BalanceConfig2 = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	BalanceConfig2.Changed:Connect(function()
		v2.TemporarySpeedBoostDurationSeconds = v.DurationSeconds
		v2.TemporarySpeedBoostMultiplier = TreadmillUtil.GetTemporarySpeedBoostMultiplier()
		v2.DisplayName = `x2 Speed Boost ({TreadmillUtil.FormatTemporarySpeedBoostProductDuration(v.DurationSeconds)})`
		v2.Desc = `Double all speed gains for {TreadmillUtil.FormatTemporarySpeedBoostProductDuration(v.DurationSeconds)}.`
	end)
	return v2
end

return CreateTemporarySpeedBoostProductConfig