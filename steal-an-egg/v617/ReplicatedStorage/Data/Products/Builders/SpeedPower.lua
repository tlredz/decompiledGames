require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local t = require(ReplicatedStorage.Packages.t)

local function CreateSpeedPowerProductConfig(name: string, productId: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)
	local amount = tonumber((name:gsub("SpeedPower_", ""):gsub("%D", "")))
	assert(amount ~= nil, "Speed power product name must include a numeric reward amount")
	assert(amount > 0, "Speed power reward must be positive")
	local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	local v2 = BalanceConfig.Bind("Game.Balance.ProductRewards." .. name, {
		Amount = amount
	}, true, false, function(p2)
		assert(p2.Amount > 0)
	end)

	local function ensureDataLoaded(p2)
		if p2 then
			return true
		end

		return false, "Player data is not loaded yet."
	end

	local function authorize(p2)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p2)

		if unsafeGetProfileAwait then
			return ensureDataLoaded(v3)
		end

		return false, "Failed to retrieve player data."
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		return ensureDataLoaded(Save.Await())
	end

	local function grant(p2)
		t.strict(t.instanceIsA("Player"))(p2)
		local SpeedPowerService = require(ServerScriptService.Controllers.SpeedPowerService)
		local v3, amount2 = SpeedPowerService.AddSpeedPower(p2, v2.Amount, "Instant")

		if not v3 then
			return false, 0
		end

		task.spawn(function()
			local NotifyItem = require(ServerScriptService.Library.Functions.NotifyItem)
			NotifyItem(p2, {
				Kind = "SpeedPower",
				Amount = amount2
			})
		end)
		return true, amount2
	end

	local v3 = {
		Name = name,
		ProductId = productId,
		DisplayName = `+{Simple.FormatCompact(v2.Amount, ".#")} Speed`,
		Desc = "Purchase bonus speed!",
		SpeedPowerReward = v2.Amount,
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
	local BalanceConfig2 = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	BalanceConfig2.Changed:Connect(function()
		v3.DisplayName = `+{Simple.FormatCompact(v2.Amount, ".#")} Speed`
		v3.SpeedPowerReward = v2.Amount
	end)
	return v3
end

return CreateSpeedPowerProductConfig