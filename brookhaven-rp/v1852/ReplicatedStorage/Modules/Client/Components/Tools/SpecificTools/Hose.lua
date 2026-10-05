local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Hose"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:Activated()
	end))
	self._Janitor:Add(self.Instance.Deactivated:Connect(function()
		self:Deactivated()
	end))
end

function v:ActivatedButton(p: string, p2: string, _)
	if p ~= "Fire" then
		return
	end

	if p2 == "Begin" then
		self:Activated()
	elseif p2 == "End" then
		self:Deactivated()
	elseif p2 == "Activated" then
		self:Activated()
		task.wait(0.1)
		self:Deactivated()
	end
end

function v:Activated()
	Remotes.fireServerComponent(self.Instance, "FireHoseActivation", true)
	Remotes.fireServerComponent(self.Instance, "Toggle", true)
end

function v:Deactivated()
	Remotes.fireServerComponent(self.Instance, "FireHoseActivation", false)
	Remotes.fireServerComponent(self.Instance, "Toggle", false)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v