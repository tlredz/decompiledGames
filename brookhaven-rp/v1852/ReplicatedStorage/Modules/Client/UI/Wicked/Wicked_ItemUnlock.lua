local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Wicked_ItemUnlock"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Go.Activated:Connect(function()
		Remotes.fireServer("SendPlayerToShop")
		self.Instance.Visible = false
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v