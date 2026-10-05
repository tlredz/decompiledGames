local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = Component.new({
	Tag = "KickConfirmationPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local yes = self.Instance:WaitForChild("Yes")
	local no = self.Instance:WaitForChild("No")
	self._Janitor:Add(yes.Activated:Connect(function()
		self.Instance.Visible = false
		self.callback(true)
	end))
	self._Janitor:Add(no.Activated:Connect(function()
		self.Instance.Visible = false
		self.callback(false)
	end))
	local playerDetails = self.Instance:WaitForChild("PlayerDetails")
	local name = playerDetails:WaitForChild("Name")
	self.longName = name:WaitForChild("LongName")
	self.username = name:WaitForChild("UserName")
	self.playerIcon = playerDetails:WaitForChild("PlayerIcon")
	self.message = self.Instance:WaitForChild("Message")
end

function v:Init(player, text: string, callback)
	self.player = player
	self.callback = callback
	self.longName.Text = player.DisplayName
	self.username.Text = `@{player.Name}`
	self._Janitor:AddPromise(Promise.new(function(callback2, callback3, _)
		local userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size60x60
		)

		if v2 then
			callback2(userThumbnailAsync)
		else
			callback3()
		end
	end):timeout(3):andThen(function(image)
		self.playerIcon.Image = image
	end, function()
		self.playerIcon.Image = ""
	end))
	self.message.Text = text
	self.Instance.Visible = true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v