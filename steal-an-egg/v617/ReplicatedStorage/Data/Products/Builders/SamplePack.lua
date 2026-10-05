local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(script.Parent.Parent.Internal.ProductTypes)
local SamplePacks = require(ReplicatedStorage.Data.SamplePacks)

local function createSamplePack(name: string, productId: number)
	local v = {
		Name = name,
		ProductId = productId,
		SamplePackProduct = true,
		HoldWhilePending = true,
		Giftable = true,
		Authorize = function(p3, receipt)
			local Commerce = require(ServerScriptService.Controllers.ScrambleService.Commerce)
			return Commerce.getCanPurchase(p3, {
				productId = productId,
				receipt = receipt
			})
		end,
		Precheck = function()
			return false, "Samples are no longer available for purchase."
		end,
		Grant = function(p3, p4)
			if p4 == nil then
				return false
			end

			local Commerce = require(ServerScriptService.Controllers.ScrambleService.Commerce)
			return Commerce.GrantGift(p3, p4)
		end
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		local v2 = SamplePacks.Find(productId)

		if v2 == nil then
			return
		end

		local displayName = Simple.Format(v2.Amount, "precision-integer") .. " Samples"
		v.DisplayName = displayName
		v.Desc = "Purchase " .. displayName .. "."
	end

	refresh() -- equivalent call inferred; original call site unknown
	SamplePacks.getChangedSignal():Connect(refresh)
	return v
end

return createSamplePack