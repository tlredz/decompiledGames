local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ClickDetectorWithTool"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.MouseClickWrapper = self._Janitor:Add(Instance.new("BindableEvent"))
	self.MouseClick = self.MouseClickWrapper.Event

	if not self.Instance:IsA("ClickDetector") then
		warn("Tagged ClickDetectorWithTool is not a ClickDetector", self.Instance)
		return
	end

	self.clickDetector = self.Instance
	self._Janitor:Add(self.clickDetector.MouseClick:Connect(function(p)
		self:Fire(p)
	end))
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

function v:HoldingToolFire(p)
	Remotes.fireServerComponent(self.Instance, "FireOnServer")
	self:Fire(p)
end

function v:Fire(p2)
	self.MouseClickWrapper:Fire(p2)
end

return v