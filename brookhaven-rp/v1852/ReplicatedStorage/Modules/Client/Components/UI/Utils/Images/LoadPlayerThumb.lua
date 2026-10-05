local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = Component.new({
	Tag = "LoadPlayerThumb"
})
local v2 = nil

function v:GetThumbnail()
	return (Promise.new(function(callback, _, _)
		while not v2 do
			task.wait()
		end

		callback(v2)
	end))
end

function v:IsValidInstance()
	return self.Instance:IsA("ImageLabel") or self.Instance:IsA("ImageButton")
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if not self:IsValidInstance() then
		return
	end

	self:GetThumbnail():andThen(function(image)
		if not image then
			return
		end

		self.Instance.Image = image
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

local onGameStart

onGameStart = function()
	local userId = Players.LocalPlayer.UserId
	local avatarThumbnail = Enum.ThumbnailType.AvatarThumbnail
	local size100x100 = Enum.ThumbnailSize.Size100x100
	local success, result = pcall(function()
		local userThumbnailAsync, _ = Players:GetUserThumbnailAsync(userId, avatarThumbnail, size100x100)
		return userThumbnailAsync
	end)

	if success then
		v2 = result
		return
	end

	task.wait(1)
	onGameStart()
end

task.spawn(function()
	onGameStart()
end)
return v