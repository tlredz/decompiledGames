local ReplicatedStorage = game:GetService("ReplicatedStorage")
local engine = ReplicatedStorage.Engine
local PlayerData = require(engine.Service.PlayerData)
local server = PlayerData.server
local TimedPurchaseService = require(engine.Service.TimedPurchaseService)
local StarterPackService = {
	server = {}
}
local flag = false

local function init()
	if flag then
		return
	end

	flag = true
	TimedPurchaseService.server.init({
		key = "starterPack",
		productKey = "Starter Pack",
		waitForData = function(self)
			server.Service:waitForData(self)
		end,
		grantReward = function(p)
			local RewardItemService = require(engine.Service.RewardItemService)
			local v = RewardItemService.grant(p, "新手礼包")

			if not v.ok then
				warn((`[StarterPackService] 新手礼包发放失败：{v.reason}`))
			end
		end,
		getRemaining = function(p)
			return server[p].starterPack.remainingSeconds()
		end,
		setRemaining = function(p, p2: number)
			server[p].starterPack.remainingSeconds(p2)
		end,
		getPurchased = function(p)
			return server[p].starterPack.purchased()
		end,
		setPurchased = function(p, flag2: boolean)
			server[p].starterPack.purchased(flag2)
		end
	})
end

StarterPackService.server.init = init
return StarterPackService