local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Chainsaw"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local now = 0
	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		if tick() - now < 0.6 then
			return
		end

		now = tick()
		Remotes.fireServerComponent(self.Instance, "ToggleChainsaw")
	end))
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v