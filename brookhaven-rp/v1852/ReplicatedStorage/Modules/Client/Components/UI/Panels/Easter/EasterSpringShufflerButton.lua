local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Packages.Remotes)
local Easter2026Controller = require(ReplicatedStorage.Modules.Client.LiveOps.Easter2026Controller)
local v = Component.new({
	Tag = "EasterSpringShufflerButton"
})

function v:UpdateUI(p2: number)
	if p2 == 1 then
		local counter = self.Instance:WaitForChild("Counter")
		counter.Text = "1 USE LEFT"
	else
		local counter_2 = self.Instance:WaitForChild("Counter")
		counter_2.Text = `{p2} USES LEFT`
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(Easter2026Controller.SpringShufflerCounterUpdated:Connect(function(p: number)
		self:UpdateUI(p)
	end))
	self:UpdateUI(Easter2026Controller.SpringShufflerCounter)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v