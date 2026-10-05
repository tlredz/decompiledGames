require(script.Parent.Parent.Internal.ProductTypes)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local t = require(ReplicatedStorage.Packages.t)

local function CreateServerLuckConfig(p: string, productId: number, multiplier: number)
	t.strict(t.string)(p)
	t.strict(t.number)(productId)
	t.strict(t.number)(multiplier)
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local v = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.ProductRewards." .. p .. "", {
		Multiplier = multiplier
	}, true, false, function(p4)
		assert(p4.Multiplier > 1)
	end)

	local function authorize(_)
		local ServerLuck = require(ServerScriptService.Controllers.ServerLuck)

		if ServerLuck.GetState().Multiplier >= v.Multiplier then
			return false, "Server already has equal or better luck"
		end

		return true
	end

	local function ResolveFailedReceipt(p4, _, _: string?)
		local Database = require(ServerScriptService.Library.Database)

		if Database.IsPlayerLoaded(p4) then
			return "Credit"
		end

		return "Retry"
	end

	local function grant(p4)
		local ServerLuck = require(ServerScriptService.Controllers.ServerLuck)
		ServerLuck.HandlePurchase(v.Multiplier, p4)
		return true
	end

	return {
		Name = p,
		ProductId = productId,
		DisplayName = p,
		HoldWhilePending = true,
		Silent = true,
		Authorize = authorize,
		Grant = grant,
		ResolveFailedReceipt = ResolveFailedReceipt
	}
end

return CreateServerLuckConfig