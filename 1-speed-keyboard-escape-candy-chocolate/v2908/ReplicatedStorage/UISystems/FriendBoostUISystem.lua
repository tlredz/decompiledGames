local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Icon = require(ReplicatedStorage.TopbarPlus.Icon)
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local FriendBoost = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("FriendBoost"))
local FriendBoostUISystem = {}
local flag = false
local v = false
local localPlayer = Players.LocalPlayer
local v2 = Icon.new()
v2:setLabel("Invite")
v2.selected:Connect(function()
	v2:deselect()
	local success, result = pcall(function()
		SocialService:PromptGameInvite(localPlayer)
	end)

	if not success then
		warn("FriendInviteIcon: PromptGameInvite failed —", result)
	end
end)
local PERCENT_PER_FRIEND = FriendBoost.PERCENT_PER_FRIEND
local MAX_BOOST_PERCENT = FriendBoost.MAX_BOOST_PERCENT

local function countFriendsInServer()
	local count = 0

	for _, v4 in ipairs(Players:GetPlayers()) do
		if v4 == localPlayer then
			continue
		end

		local success, result = pcall(localPlayer.IsFriendsWithAsync, localPlayer, v4.UserId)

		if not (success and result) then
			continue
		end

		count += 1

		if FriendBoost.MAX_FRIENDS <= count then
			break
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateLabel(guiObject, friendBoostPercent)
	guiObject.RichText = true

	if not (friendBoostPercent and friendBoostPercent > 0) then
		guiObject.Visible = false
		return
	end

	if MAX_BOOST_PERCENT <= friendBoostPercent then
		guiObject.Text = string.format(
			"<font color=\"#FFD700\">⚡ MAX FRIEND BOOST</font> <font color=\"#00FF00\">+%d%%</font>",
			friendBoostPercent
		)
	else
		guiObject.Text = string.format(
			"<font color=\"#00FF00\">Multiplier</font> +%d%% <font color=\"#00FF00\">(Friends)</font>",
			friendBoostPercent
		)
	end

	guiObject.Visible = true
end

function FriendBoostUISystem:RefreshFriendCount()
	if v then
		return
	end

	ClientState:Update({
		FriendBoostPercent = math.min(
			math.min(countFriendsInServer(), FriendBoost.MAX_FRIENDS) * PERCENT_PER_FRIEND,
			MAX_BOOST_PERCENT
		)
	})
	self:UpdateDisplay()
end

function FriendBoostUISystem:ApplyOverride(friendBoostPercent)
	v = MAX_BOOST_PERCENT <= friendBoostPercent
	ClientState:Update({
		FriendBoostPercent = friendBoostPercent
	})
	self:UpdateDisplay()
end

function FriendBoostUISystem:UpdateDisplay()
	local friendBoostPercent = ClientState:Get().FriendBoostPercent or 0

	for _, guiObject in ipairs(CollectionService:GetTagged("FriendBoostTextLabel")) do
		if not (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
			continue
		end

		updateLabel(guiObject, friendBoostPercent) -- equivalent call inferred; original call site unknown
	end
end

function FriendBoostUISystem:InitLogic()
	if flag then
		return
	end

	flag = true
	self:UpdateDisplay()
end

function FriendBoostUISystem.OnClose(_) end

return FriendBoostUISystem