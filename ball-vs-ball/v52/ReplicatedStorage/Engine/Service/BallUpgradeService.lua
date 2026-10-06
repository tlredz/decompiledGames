local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local remoteFunction = Net:RemoteFunction("BallUpgradeRequest")
local flag = false

local function upgrade(p, p2, p3)
	assert(RunService:IsServer(), "BallUpgradeService.server.upgrade 只能在服务端调用")
	local ItemService = require(script.Parent.ItemService)
	return ItemService.server.consumeAndGrantBallUpgrade(p, p2, p3)
end

return {
	server = {
		init = function()
			assert(RunService:IsServer(), "BallUpgradeService.server.init 只能在服务端调用")

			if flag then
				return
			end

			flag = true
			remoteFunction.OnServerInvoke = upgrade
		end,
		upgrade = upgrade
	},
	client = {
		upgrade = function(p: string, p2)
			assert(RunService:IsClient(), "BallUpgradeService.client.upgrade 只能在客户端调用")
			local success, result = pcall(function()
				return remoteFunction:InvokeServer(p, p2)
			end)

			if success then
				return result
			end

			return {
				ok = false,
				reason = "network_error"
			}
		end
	}
}