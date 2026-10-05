require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local ScrambleTradeInFlags = require(ReplicatedStorage.Shared.Flags.ScrambleTradeInFlags)
local RiftMachineSchedule = require(ReplicatedStorage.Shared.Util.RiftMachineSchedule)
local t = require(ReplicatedStorage.Packages.t)

local function resolveRobuxCost(p: number, p2)
	local currencySpent

	if p2 ~= nil then
		currencySpent = p2.CurrencySpent
	end

	if type(currencySpent) == "number" and currencySpent > 0 then
		return currencySpent
	end

	local success, result, v = pcall(Marketplace.Price, p, true)

	if success and v and type(result) == "number" and result > 0 then
		return result
	end

	return nil
end

local function CreateRiftRefreshProductConfig(name: string, productId: number)
	t.strict(t.string)(name)
	t.strict(t.number)(productId)

	local function authorize(p3, p4)
		t.strict(t.instanceIsA("Player"))(p3)

		if productId <= 0 then
			return false, "Rift refresh is not available yet"
		end

		local v

		if RiftMachineSchedule.IsLaboratoryTime() then
			v = require(ServerScriptService.Controllers.ScrambleTradeInService)
		else
			v = require(ServerScriptService.Controllers.RiftService)
		end

		return v.CanPurchasePaidRefresh(p3, p4 ~= nil)
	end

	local function precheck()
		if productId <= 0 then
			return false, "Rift refresh is not available yet"
		end

		if RiftMachineSchedule.IsLaboratoryTime() and not ScrambleTradeInFlags.Enabled:Get() or not RiftMachineSchedule.IsLaboratoryTime() and RiftFlags.Retired:Get() then
			return false, "The trade-in machine is closed"
		end

		return true
	end

	local function ResolveFailedReceipt(p3, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if Database.IsPlayerLoaded(p3) then
			return "Credit"
		end

		return "Retry"
	end

	local function grant(p3, p4)
		t.strict(t.instanceIsA("Player"))(p3)
		local v

		if RiftMachineSchedule.IsLaboratoryTime() then
			v = require(ServerScriptService.Controllers.ScrambleTradeInService)
		else
			v = require(ServerScriptService.Controllers.RiftService)
		end

		local redeemPaidRefresh = v.RedeemPaidRefresh
		local result

		if p4 ~= nil then
			result = p4.CurrencySpent
		end

		if type(result) == "number" and result > 0 then
			return redeemPaidRefresh(p3, result)
		end

		local success, v3
		success, result, v3 = pcall(Marketplace.Price, productId, true)

		if not success or not v3 or type(result) ~= "number" or not (result > 0) then
			result = nil
		end

		return redeemPaidRefresh(p3, result)
	end

	return {
		Name = name,
		ProductId = productId,
		DisplayName = "Laboratory Refresh",
		Desc = "Instantly reroll the 3 eggs Dr. Scramble is asking for!",
		HoldWhilePending = true,
		Silent = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
end

return CreateRiftRefreshProductConfig