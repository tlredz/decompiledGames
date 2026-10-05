require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local timecode = Time.Timecode
local t = require(ReplicatedStorage.Packages.t)

local function CreateEggSkipGrowthProductConfig(p: string, productId: number, maxRemainingSeconds: number)
	t.strict(t.string)(p)
	t.strict(t.number)(productId)
	t.strict(t.intersection(t.integer, t.numberPositive))(maxRemainingSeconds)
	local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	local v = BalanceConfig.Bind("Game.Balance.ProductRewards." .. p, {
		MaxRemainingSeconds = maxRemainingSeconds
	}, true, false, function(p4)
		local v2

		if p4.MaxRemainingSeconds > 0 then
			v2 = p4.MaxRemainingSeconds % 1 == 0
		else
			v2 = false
		end

		assert(v2)
	end)

	local function authorize(p4, p5)
		t.strict(t.instanceIsA("Player"))(p4)
		local Eggs = require(ServerScriptService.Controllers.Eggs)

		if p5 == nil then
			return Eggs.CanPurchaseSkipGrowth(p4, p)
		end

		return Eggs.CanRedeemSkipGrowth(p4, p)
	end

	local function ReservePrompt(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Eggs = require(ServerScriptService.Controllers.Eggs)
		return Eggs.ReserveSkipGrowthPrompt(p4, p)
	end

	local function CancelPrompt(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Eggs = require(ServerScriptService.Controllers.Eggs)
		Eggs.CancelSkipGrowthPrompt(p4, p)
	end

	local function precheck()
		local EggState = require(ReplicatedStorage.Client.EggState)
		return EggState.MayBuyChosenSkip()
	end

	local function ResolveFailedReceipt(p4, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if Database.IsPlayerLoaded(p4) then
			return "Credit"
		end

		return "Retry"
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Eggs = require(ServerScriptService.Controllers.Eggs)
		return Eggs.PurchaseSkipGrowth(p4, p)
	end

	local v2 = {
		Name = p,
		ProductId = productId,
		DisplayName = p,
		Desc = `Skip the growth of your egg by {timecode(v.MaxRemainingSeconds)}!`,
		EggSkipGrowthMaxRemainingSeconds = v.MaxRemainingSeconds,
		HoldWhilePending = true,
		Silent = true,
		Precheck = precheck,
		Authorize = authorize,
		ReservePrompt = ReservePrompt,
		CancelPrompt = CancelPrompt,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
	local BalanceConfig2 = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
	BalanceConfig2.Changed:Connect(function()
		v2.EggSkipGrowthMaxRemainingSeconds = v.MaxRemainingSeconds
		v2.Desc = `Skip the growth of your egg by {timecode(v.MaxRemainingSeconds)}!`
	end)
	return v2
end

return CreateEggSkipGrowthProductConfig