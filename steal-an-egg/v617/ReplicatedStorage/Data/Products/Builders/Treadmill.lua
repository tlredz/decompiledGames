require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
local t = require(ReplicatedStorage.Packages.t)

local function CreateTreadmillProductConfig(name: string, p2: string, productId: number)
	t.strict(t.string)(name)
	t.strict(t.string)(p2)
	t.strict(t.number)(productId)
	local treadmillNameExists, v = Treadmills.TreadmillNameExists(p2)
	assert(treadmillNameExists, v or `Treadmill "{p2}" does not exist`)
	local v2 = Treadmills.Directory[p2]
	local upgradeLevel = Treadmills.GetUpgradeLevel(p2)
	assert(upgradeLevel ~= nil, (`Treadmill "{p2}" has no upgrade level`))

	local function canBuyNextUpgrade(treadmillUpgradeLevel: number)
		if treadmillUpgradeLevel + 1 == upgradeLevel then
			return true
		end

		return false, "This is not your next treadmill upgrade"
	end

	local function authorize(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait and v3 then
			return canBuyNextUpgrade(v3.TreadmillUpgradeLevel)
		end

		return false, "Player profile not found"
	end

	local function ResolveFailedReceipt(p4, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if not Database.IsPlayerLoaded(p4) then
			return "Retry"
		end

		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p4)

		if not (unsafeGetProfileAwait and v3) then
			return "Retry"
		end

		if upgradeLevel <= v3.TreadmillUpgradeLevel then
			return "Satisfied"
		end

		return "Credit"
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		local v3 = Save.Await()

		if v3 then
			return canBuyNextUpgrade(v3.TreadmillUpgradeLevel)
		end

		return false, "Data not loaded"
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local TreadmillService = require(ServerScriptService.Controllers.TreadmillService)
		return TreadmillService.UpgradeTreadmill(p4, p2, false)
	end

	return {
		Name = name,
		ProductId = productId,
		DisplayName = v2.DisplayName,
		Desc = `Upgrade to the {v2.DisplayName} treadmill.`,
		Icon = v2.Icon,
		OneTime = true,
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
end

return CreateTreadmillProductConfig