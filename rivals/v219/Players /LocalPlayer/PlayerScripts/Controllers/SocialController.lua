local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.CanSendGameInviteChanged = Signal.new()
	self.FriendsFetched = Signal.new()
	self.CanSendGameInvite = nil
	self.Friends = {}
	self._is_friends_with = {}
	self:_Init()
	return self
end

function class:IsFriendsWith(p2)
	local v = self._is_friends_with[tostring(p2)]

	if v then
		return v
	end

	local success, result = pcall(Players.LocalPlayer.IsFriendsWithAsync, Players.LocalPlayer, p2)

	if success then
		return result
	end

	warn("Failed to check IsFriendsWithAsync, error:", result)
	return false
end

function class.PromptFriendInvite(_)
	local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
	experienceInviteOptions.PromptMessage = "Challenge your friends to a duel!"
	experienceInviteOptions.InviteMessageId = "1dc4ba3b-4978-ea4f-9c63-35babfc20045"
	experienceInviteOptions.LaunchData = HttpService:JSONEncode({
		SenderHash = ReplicatedStorage.Remotes.Misc.RequestInviteData:InvokeServer()
	})
	SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
end

function class:_FetchFriends()
	for _ = 1, 3 do
		local success, friendsOnlineAsync = pcall(Players.LocalPlayer.GetFriendsOnlineAsync, Players.LocalPlayer, 50)

		if success then
			self.Friends = friendsOnlineAsync
			break
		else
			warn("Failed to fetch GetFriendsOnlineAsync, error:", friendsOnlineAsync)
			wait(1)
		end
	end

	for _, friend in pairs(self.Friends) do
		self._is_friends_with[tostring(friend.VisitorId)] = true
	end

	self.FriendsFetched:Fire()
end

function class:_FetchCanSendGameInvite()
	for _ = 1, 3 do
		local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, Players.LocalPlayer)

		if success then
			self.CanSendGameInvite = result
			break
		else
			warn("Failed to fetch CanSendGameInviteAsync:", result)
			wait(1)
		end
	end

	self.CanSendGameInviteChanged:Fire()
end

function class:_Init()
	task.defer(self._FetchFriends, self)
	task.defer(self._FetchCanSendGameInvite, self)
end

return class._new()