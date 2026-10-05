require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local t = require(ReplicatedStorage.Packages.t)

local function CreateTreadmillAdEggBoostConfig(p: string, productId: number)
	t.strict(t.string)(p)
	t.strict(t.number)(productId)

	local function ServerTest(p3)
		local Database = require(ServerScriptService.Library.Database)
		local unsafeGetProfileAwait, v = Database.UnsafeGetProfileAwait(p3)

		if unsafeGetProfileAwait and v then
			return true
		end

		return false, "Player data is not loaded yet."
	end

	local function Callback(p3)
		local AdEggBoostReward = require(ServerScriptService.Controllers.AdEggBoostServer.AdEggBoostReward)
		AdEggBoostReward.Grant(p3)
		return true
	end

	return {
		Name = p,
		ProductId = productId,
		DisplayName = p,
		Desc = "Treadmill Egg Ad Boost — 5 min x2 egg growth from rewarded video.",
		HoldWhilePending = true,
		Silent = true,
		Authorize = ServerTest,
		Grant = Callback
	}
end

return CreateTreadmillAdEggBoostConfig