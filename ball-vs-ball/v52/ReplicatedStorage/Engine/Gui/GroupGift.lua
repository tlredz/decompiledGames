local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GroupJoinRewardService = require(ReplicatedStorage.Engine.Service.GroupJoinRewardService)
local RewardConfirmQueue = require(ReplicatedStorage.Engine.Gui.RewardConfirmQueue)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)

-- equivalent calls inferred from this helper; original call sites unknown
local function findModel()
	local firstChild = workspace:FindFirstChild("大厅")
	return firstChild and firstChild:FindFirstChild("群组礼包")
end

local function showResults(results)
	if typeof(results) ~= "table" then
		return
	end

	local Config = require(ReplicatedStorage.Engine.Service.Config)
	local joinGroupFreeChest = Config.misc.joinGroupFreeChest
	local id = joinGroupFreeChest and joinGroupFreeChest["箱子id"]

	if typeof(id) == "string" then
		RewardConfirmQueue.enqueue(results, id, "group")
	else
		warn("[GroupGift] 群组奖励缺少有效箱子配置")
	end
end

return {
	Init = function()
		if ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME then
			return
		end

		local model = findModel() -- equivalent call inferred; original call site unknown

		if not model then
			warn("[GroupGift] 找不到大厅[群组礼包]")
			return
		end

		local proximityPrompt = model:WaitForChild("triggerPart"):WaitForChild("ProximityPrompt")
		task.spawn(function()
			if GroupJoinRewardService.client.hasClaimed() and model.Parent then
				model:Destroy()
			end
		end)
		proximityPrompt.Triggered:Connect(function(player)
			if player ~= Players.LocalPlayer then
				return
			end

			local request = GroupJoinRewardService.client.request()

			if request.ok then
				showResults(request.results)

				if model.Parent then
					model:Destroy()
				end
			elseif request.reason ~= "not_joined" then
				warn((`[GroupGift] 领取失败: {request.reason}`))
			end
		end)
	end
}