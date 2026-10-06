local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local Net = require(ReplicatedStorage.Packages.Net)
local OneTimeRewardService = require(script.Parent.OneTimeRewardService)
local remoteEvent = Net:RemoteEvent("FriendInviteRewardResults")
local flag = false
local v = nil
local fn

local function initServer(p)
	if flag then
		warn("[FriendInviteRewardService] 重复初始化被忽略")
		return
	end

	flag = true
	local data = p.data
	v = OneTimeRewardService.new({
		hasClaimed = function(p2)
			return data[p2].hasClaimedFriendInviteFreeChest()
		end,
		markClaimed = function(p2)
			data[p2].hasClaimedFriendInviteFreeChest(true)
		end,
		grantReward = p.grantReward
	})
	local v2 = OneTimeRewardService.new({
		hasClaimed = function(p2)
			return data[p2].hasReceivedFriendInviteFreeChest()
		end,
		markClaimed = function(p2)
			data[p2].hasReceivedFriendInviteFreeChest(true)
		end,
		grantReward = p.grantReward
	})

	local function processPlayerAdded(player)
		data.Service:waitForData(player)

		if player.Parent ~= Players then
			return
		end

		local v3 = not data[player].hasJoinedGameBefore()
		data[player].hasJoinedGameBefore(true)
		print((`[FriendInviteReward] 玩家进服：玩家={player.UserId}，首次进服={v3}`))

		if not v3 then
			return
		end

		local referredByPlayerId = player:GetJoinData().ReferredByPlayerId

		if typeof(referredByPlayerId) ~= "number" or referredByPlayerId <= 0 then
			print((`[FriendInviteReward] 不满足邀请来源：玩家={player.UserId}，邀请人={tostring(referredByPlayerId)}`))
			return
		end

		print((`[FriendInviteReward] 资格校验成功：邀请人={referredByPlayerId}，新玩家={player.UserId}`))
		local claim = v2.claim(player)

		if claim.ok then
			remoteEvent:FireClient(player, claim.results, "friendInvitee")
			print((`[FriendInviteReward] 被邀请者奖励成功：玩家={player.UserId}`))
		else
			print((`[FriendInviteReward] 被邀请者奖励失败：玩家={player.UserId}，原因={claim.reason}`))
		end

		local playerByUserId = Players:GetPlayerByUserId(referredByPlayerId)

		if playerByUserId then
			fn(playerByUserId)
		else
			print((`[FriendInviteReward] 邀请人已不在线，跳过邀请人发奖：邀请人={referredByPlayerId}`))
		end
	end

	Players.PlayerAdded:Connect(function(player)
		task.spawn(processPlayerAdded, player)
	end)

	for _, v3 in Players:GetPlayers() do
		task.spawn(processPlayerAdded, v3)
	end

	Players.PlayerRemoving:Connect(function(player)
		v.cleanup(player)
		v2.cleanup(player)
	end)
end

fn = function(playerByUserId)
	if not v then
		warn("[FriendInviteReward] 服务尚未初始化，无法发放邀请人奖励")
		return {
			ok = false,
			reason = "not_initialized"
		}
	end

	local claim = v.claim(playerByUserId)

	if not claim.ok then
		print((`[FriendInviteReward] 邀请人无奖励或发奖失败：玩家={playerByUserId.UserId}，原因={claim.reason}`))
		return claim
	end

	remoteEvent:FireClient(playerByUserId, claim.results, "friendInvite")
	print((`[FriendInviteReward] 邀请人奖励成功：玩家={playerByUserId.UserId}`))
	return claim
end

local function showResults(p, p2)
	if typeof(p) ~= "table" then
		return
	end

	local Config = require(ReplicatedStorage.Engine.Service.Config)
	local friendInviteFreeChest = Config.misc.friendInviteFreeChest
	local id = friendInviteFreeChest and friendInviteFreeChest["箱子id"]

	if typeof(id) ~= "string" then
		warn("[FriendInviteReward] 好友邀请奖励缺少有效箱子配置")
		return
	end

	local v2 = p2 == "friendInvitee" and "friendInvitee" or "friendInvite"
	local RewardConfirmQueue = require(ReplicatedStorage.Engine.Gui.RewardConfirmQueue)
	RewardConfirmQueue.enqueue(p, id, v2)
end

local function promptInvite()
	local localPlayer = Players.LocalPlayer
	local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer)

	if not (success and result) then
		warn("[FriendInviteReward] 当前玩家不能发送游戏邀请")
		return
	end

	local success2, result2 = pcall(SocialService.PromptGameInvite, SocialService, localPlayer)

	if not success2 then
		warn((`[FriendInviteReward] 打开邀请面板失败：{result2}`))
	end
end

local function openInvite()
	local PlayerData = require(script.Parent.PlayerData)

	if PlayerData.client.hasClaimedFriendInviteFreeChest() then
		promptInvite()
		return
	end

	local RewardConfirmQueue = require(ReplicatedStorage.Engine.Gui.RewardConfirmQueue)
	RewardConfirmQueue.enqueueInvitePrompt(promptInvite)
end

if not RunService:IsServer() then
	remoteEvent.OnClientEvent:Connect(showResults)
end

return {
	server = {
		init = initServer,
		claimInviterReward = fn
	},
	client = {
		promptInvite = openInvite,
		promptNativeInvite = promptInvite
	}
}