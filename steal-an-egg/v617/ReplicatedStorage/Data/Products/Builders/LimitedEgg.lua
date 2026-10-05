local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
require(ReplicatedStorage.Shared.Types.Eggs)
require(ReplicatedStorage.Data.LimitedEgg.Types.Interface)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
require(script.Parent.Parent.Internal.ProductTypes)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	HoldWhilePending = true,
	Icon = "",
	Silent = true
}
local random = Random.new()

local function withDefaults(items)
	local clone = table.clone(v)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

local function presentation(p: number)
	local v2 = p == 1 and "A limited pet egg." or `{p} limited pet eggs.`
	return `Limited Egg x{p}`, v2
end

local function rollGrants(p, p2: number, purchaseId: string?)
	local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
	local result = table.create(p2)

	for i = 1, p2 do
		local rollWeighted = Numeric.RollWeighted(p.DropTable, random)
		t.strict(t.string)(rollWeighted)
		local egg = EggRecords.NewEgg(rollWeighted)
		egg.PurchaseId = purchaseId
		result[i] = {
			Uid = HttpService:GenerateGUID(false):gsub("-", ""):lower(),
			Record = egg
		}
	end

	return result
end

local function CreateLimitedEggProductConfig(name: string, productId: number, p3: number, p4)
	t.strict(t.string)(name)
	t.strict(t.numberPositive)(productId)
	t.strict(t.intersection(t.integer, t.numberPositive))(p3)
	t.strict(t.table)(p4)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function liveCount()
		for _, offer in p4.Offers do
			if offer.ProductName == name then
				return offer.Amount
			end
		end

		return p3
	end

	local function authorize(p5)
		t.strict(t.instanceIsA("Player"))(p5)
		local Database = require(ServerScriptService.Library.Database)

		if Database.IsPlayerLoaded(p5) then
			return true
		end

		return false, "Data not loaded"
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)

		if Save.Await() == nil then
			return false, "Data not loaded"
		end

		return true
	end

	local function grant(p5, p6)
		t.strict(t.instanceIsA("Player"))(p5)
		local Eggs = require(ServerScriptService.Controllers.Eggs)
		local purchaseId

		if not (p6 == nil or p6.PurchaseId == nil) then
			purchaseId = tostring(p6.PurchaseId)
		end

		local grantPaidEggBatch = Eggs.GrantPaidEggBatch
		local v4 = liveCount() -- equivalent call inferred; original call site unknown
		return grantPaidEggBatch(p5, (rollGrants(p4, v4, purchaseId)))
	end

	local v2 = liveCount() -- equivalent call inferred; original call site unknown
	local desc = v2 == 1 and "A limited pet egg." or `{v2} limited pet eggs.`
	local v4 = {
		Name = name,
		ProductId = productId,
		DisplayName = `Limited Egg x{v2}`,
		Desc = desc,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
	local clone = table.clone(v)

	for k, v5 in v4 do
		clone[k] = v5
	end

	BalanceConfig.Changed:Connect(function()
		local v5 = clone
		local v6 = clone
		local v7 = liveCount() -- equivalent call inferred; original call site unknown
		local desc2 = v7 == 1 and "A limited pet egg." or `{v7} limited pet eggs.`
		v5.DisplayName = `Limited Egg x{v7}`
		v6.Desc = desc2
	end)
	return clone
end

return CreateLimitedEggProductConfig