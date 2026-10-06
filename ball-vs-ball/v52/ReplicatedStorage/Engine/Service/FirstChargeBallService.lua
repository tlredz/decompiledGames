local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local server = PlayerData.server
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local GachaService = require(ReplicatedStorage.Engine.Service.GachaService)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local FirstChargeBallService = {
	server = {},
	PRODUCT_KEY = "Random Epic Ball",
	GACHA_CN_ID = "首充小球奖池",
	FEATURE_NAME = "首充球",
	SOURCE = "首充小球"
}
local remoteEvent = Net:RemoteEvent("FirstChargeBall/Result")
local random = Random.new()
local flag = false

local function init()
	if flag then
		return
	end

	flag = true
	DevProductService.server.bindProduct(FirstChargeBallService.PRODUCT_KEY, function(p)
		local plr = p.plr
		server.Service:waitForData(plr)

		if server[plr].hasBoughtFirstChargeBall() then
			warn((`[FirstChargeBallService] {plr.Name}({plr.UserId}) 重复购买首充小球（purchaseId={p.purchaseId}），照常发奖`))
		end

		local pool = GachaPool.getPool(FirstChargeBallService.GACHA_CN_ID)
		local v = pool and GachaPool.pick(pool, random, {
			context = GachaPool.getPlayerContext(plr)
		})
		assert(v, (`[FirstChargeBallService] 奖池 {FirstChargeBallService.GACHA_CN_ID} 无可抽物品`))
		local v2 = GachaService.server.grantPickedItem(plr, v, FirstChargeBallService.SOURCE, nil)
		server[plr].hasBoughtFirstChargeBall(true)
		remoteEvent:FireClient(plr, { v2 })
	end)
end

FirstChargeBallService.server.init = init
return FirstChargeBallService