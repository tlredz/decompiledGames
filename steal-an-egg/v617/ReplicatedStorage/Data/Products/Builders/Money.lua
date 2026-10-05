local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(script.Parent.Parent.Internal.ProductTypes)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Desc = "Purchase bonus money!",
	HoldWhilePending = true
}

local function withDefaults(items)
	local clone = table.clone(v)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

local function rewardAmountFrom(value: string)
	local v2 = string.match(value, "^Money_(%d+)$")

	if v2 == nil then
		error((`money product "{value}" must be named Money_<amount>`))
	end

	local v3 = tonumber(v2)

	if v3 == nil or v3 <= 0 then
		error((`money product "{value}" must carry a positive amount`))
	end

	return v3
end

local function moneyLabel(p: number)
	return (`${Simple.FormatCompact(p, ".#")} Money`)
end

local function profileReady(p)
	if p then
		return true
	end

	return false, "Player data is not loaded yet."
end

local function CreateMoneyProductConfig(name: string, productId: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)
	local v2 = BalanceConfig.Bind("Game.Balance.ProductRewards." .. name, {
		Amount = rewardAmountFrom(name)
	}, true, false, function(p3)
		assert(p3.Amount > 0)
	end)

	local function authorize(p3)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p3)

		if unsafeGetProfileAwait then
			return profileReady(v3)
		end

		return false, "Failed to retrieve player data."
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		return profileReady(Save.Await())
	end

	local function grant(p3)
		local MoneyService = require(ServerScriptService.Controllers.MoneyService)
		MoneyService.AddMoney(p3, v2.Amount, {
			source = "DevProduct"
		})
		return true
	end

	local amount = v2.Amount
	local v3 = {
		Name = name,
		ProductId = productId,
		DisplayName = `${Simple.FormatCompact(amount, ".#")} Money`,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
	local clone = table.clone(v)

	for k, v4 in v3 do
		clone[k] = v4
	end

	BalanceConfig.Changed:Connect(function()
		local v4 = clone
		local amount2 = v2.Amount
		v4.DisplayName = `${Simple.FormatCompact(amount2, ".#")} Money`
	end)
	return clone
end

return CreateMoneyProductConfig