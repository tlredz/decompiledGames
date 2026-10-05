local Players = game:GetService("Players")
local VoiceChatService = game:GetService("VoiceChatService")
local Cache = require(game.ReplicatedStorage.UserGenerated.Concurrency.Cache)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local v = Cache.new({
	Callback = function(p)
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(p)
	end,
	AssertKey = Asserts.Integer,
	MaxAge = 1e999
})
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	task.delay(60, function()
		if not Players:GetPlayerByUserId(userId) then
			v:Delete(userId)
		end
	end)
end)
task.spawn(function()
	v:GetAsync(Players.LocalPlayer.UserId)
end)
return table.freeze({
	IsVoiceEnabledForUserIdAsync = function(self: number, flag: boolean?)
		Asserts.Integer(self)
		Asserts.Optional(Asserts.Boolean)(flag)

		if flag then
			return v:Get(self)
		end

		return v:GetAsync(self)
	end
})