local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleDoor"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v2 = self._Janitor:Add(Instance.new("Animation"))
	v2.AnimationId = self.Instance:GetAttribute("OpenAnimation")
	local v3 = self._Janitor:Add(Instance.new("Animation"))
	v3.AnimationId = self.Instance:GetAttribute("CloseAnimation")
	task.spawn(function()
		ContentProvider:PreloadAsync({ v2, v3 })
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v