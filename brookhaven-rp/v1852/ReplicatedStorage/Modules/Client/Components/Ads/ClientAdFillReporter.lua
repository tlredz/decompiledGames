local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ClientAdFillReporter"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local value = instance.Value

	if value.Status == Enum.AdUnitStatus.Active then
		Remotes.fireServer("Impression", instance.Parent.Name, true)
	end

	self._Janitor:Add(value:GetPropertyChangedSignal("Status"):Connect(function()
		if value.Status == Enum.AdUnitStatus.Active then
			Remotes.fireServer("Impression", instance.Parent.Name, true)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v