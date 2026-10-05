local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "LeaveFamily"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Accept = self._Janitor:Add(Signal.new())
	self.Decline = self._Janitor:Add(Signal.new())
end

function v:Start()
	self._Janitor:Add(self.Instance.InteractButtons.Yes.Activated:Connect(function()
		Remotes.fireServer("LeaveFamily")
		self.Accept:Fire()
		self.Instance.Visible = false
	end))
	self._Janitor:Add(self.Instance.InteractButtons.No.Activated:Connect(function()
		self.Decline:Fire()
		self.Instance.Visible = false
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v