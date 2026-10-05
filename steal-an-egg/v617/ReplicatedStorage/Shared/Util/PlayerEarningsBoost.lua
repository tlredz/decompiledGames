local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local PlayerEarningsBoost = {}
PlayerEarningsBoost.DURATION_SECONDS = 900
PlayerEarningsBoost.EXPIRES_AT_ATTRIBUTE = "EarningsBoostExpiresAt"

function PlayerEarningsBoost.GetConfiguredMultiplier()
	return BossMasteryFlags.CashBoosterMultiplier:Get()
end

function PlayerEarningsBoost.GetRemainingSecondsFromExpiry(value: number?, p: number?)
	if typeof(value) == "number" then
		return (math.max(0, value - (p or Workspace:GetServerTimeNow())))
	end

	return 0
end

function PlayerEarningsBoost.GetRemainingSeconds(instance, p: number?)
	if instance == nil then
		return 0
	end

	return PlayerEarningsBoost.GetRemainingSecondsFromExpiry(instance:GetAttribute("EarningsBoostExpiresAt"), p)
end

function PlayerEarningsBoost.GetMultiplier(p)
	if PlayerEarningsBoost.GetRemainingSeconds(p) > 0 then
		return PlayerEarningsBoost.GetConfiguredMultiplier()
	end

	return 1
end

function PlayerEarningsBoost.GetChangedSignal(object)
	return object:GetAttributeChangedSignal("EarningsBoostExpiresAt")
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
PlayerEarningsBoost = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind(
	"Game.Balance.PlayerEarningsBoost",
	PlayerEarningsBoost,
	{
		MULTIPLIER = true,
		DURATION_SECONDS = true
	},
	false
)
return PlayerEarningsBoost