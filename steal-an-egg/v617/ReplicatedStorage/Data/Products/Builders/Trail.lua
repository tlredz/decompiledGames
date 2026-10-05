require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local Trails = require(ReplicatedStorage.Data.Trails)
local t = require(ReplicatedStorage.Packages.t)

local function CreateTrailProductConfig(name: string, p2: string, productId: number)
	t.strict(t.string)(name)
	t.strict(t.string)(p2)
	t.strict(t.number)(productId)
	local trailNameExists, v = Trails.TrailNameExists(p2)
	assert(trailNameExists, v or `Trail "{p2}" does not exist`)
	local v2 = Trails.Directory[p2]

	local function validateData(p4)
		if not p4 then
			return false, "Player data not found"
		end

		if p4.TrailInventory[p2] then
			return false, "You already own this trail"
		end

		return true
	end

	local function authorize(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait and v3 then
			return validateData(v3)
		end

		return false, "Player profile not found"
	end

	local function ResolveFailedReceipt(p4, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if not Database.IsPlayerLoaded(p4) then
			return "Retry"
		end

		local unsafeGetProfileAwait, v3 = Database.UnsafeGetProfileAwait(p4)

		if unsafeGetProfileAwait and v3 and v3.TrailInventory[p2] then
			return "Satisfied"
		end

		return "Retry"
	end

	local function precheck()
		local Save = require(ReplicatedStorage.Shared.Save)
		local v3 = Save.Await()

		if v3 then
			return validateData(v3)
		end

		return false, "Data not loaded"
	end

	local function grant(p4)
		t.strict(t.instanceIsA("Player"))(p4)
		local TrailShop = require(ServerScriptService.Controllers.TrailShop)
		return TrailShop.GrantOwnedTrail(p4, p2, true)
	end

	return {
		Name = name,
		ProductId = productId,
		DisplayName = v2.DisplayName,
		Desc = `Unlock the {v2.DisplayName} trail.`,
		Icon = v2.Icon,
		OneTime = true,
		HoldWhilePending = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
end

return CreateTrailProductConfig