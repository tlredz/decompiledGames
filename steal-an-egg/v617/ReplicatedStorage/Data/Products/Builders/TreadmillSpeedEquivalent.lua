require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)

local function canPurchase(p)
	if p == nil then
		return false, "Player data is not loaded yet."
	end

	return true, nil
end

local function CreateTreadmillSpeedEquivalentProductConfig(name: string, productId: number, durationSeconds: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)
	t.strict(t.number)(durationSeconds)
	assert(productId > 0, "Treadmill equivalent product id must be positive")
	assert(durationSeconds > 0, "Treadmill equivalent duration must be positive")
	local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	local v = BalanceConfig.Bind("Game.Balance.TreadmillProductRewards." .. tostring(productId), {
		DurationSeconds = durationSeconds
	}, true, false, function(p4)
		assert(p4.DurationSeconds > 0)
	end)

	local function durationLabel()
		return TreadmillUtil.FormatTreadmillSpeedEquivalentDuration(v.DurationSeconds)
	end

	local function authorize(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v2 = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait then
			return canPurchase(v2)
		end

		return false, "Player data is not loaded yet."
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		return canPurchase(Save.Await())
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local SpeedPowerService = require(ServerScriptService.Controllers.SpeedPowerService)
		local v2, amount = SpeedPowerService.AddTreadmillEquivalentSpeedPower(p4, v.DurationSeconds)

		if not v2 then
			return false, 0
		end

		local NotifyItem = require(ServerScriptService.Library.Functions.NotifyItem)
		NotifyItem(p4, {
			Kind = "SpeedPower",
			Amount = amount
		})
		return true, amount
	end

	local v2 = {
		Name = name,
		ProductId = productId,
		DisplayName = `Speed - {TreadmillUtil.FormatTreadmillSpeedEquivalentDuration(v.DurationSeconds)}`,
		Desc = "Instantly gain the speed you currently earn on your treadmill.",
		TreadmillSpeedEquivalentDurationSeconds = v.DurationSeconds,
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
	local BalanceConfig2 = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	BalanceConfig2.Changed:Connect(function()
		v2.TreadmillSpeedEquivalentDurationSeconds = v.DurationSeconds
		v2.DisplayName = `Speed - {TreadmillUtil.FormatTreadmillSpeedEquivalentDuration(v.DurationSeconds)}`
	end)
	return v2
end

return CreateTreadmillSpeedEquivalentProductConfig