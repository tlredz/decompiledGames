local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TrackComponentRemote"
})

function v:Construct()
	if self.Instance.Parent == nil then
		return
	end

	self._janitor = Janitor.new()
	self._parent = self.Instance.Parent
	self._removed = false
	self._janitor:Add(self.Instance.Destroying:Once(function()
		if self._removed then
			return
		end

		self._removed = true
		Remotes.trackComponentRemoteRemoval(self.Instance, self._parent)
	end))
	Remotes.trackComponentRemote(self.Instance)
end

function v:Stop()
	task.delay(1, function()
		if self._removed then
			return
		end

		self._removed = true
		Remotes.trackComponentRemoteRemoval(self.Instance, self._parent)
	end)
	self._janitor:Destroy()
end

return v