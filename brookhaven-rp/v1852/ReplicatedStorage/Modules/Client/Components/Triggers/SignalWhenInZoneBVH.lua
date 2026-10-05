local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "SignalWhenInZoneBVH"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnOtherPlayerEntered = self._Janitor:Add(Signal.new())
	self.OnOtherPlayerExited = self._Janitor:Add(Signal.new())
	self.OnLocalPlayerEntered = self._Janitor:Add(Signal.new())
	self.OnLocalPlayerExited = self._Janitor:Add(Signal.new())
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "SignalWhenInZoneBVH:Entered", function(p)
		if p == Players.LocalPlayer then
			self.OnLocalPlayerEntered:Fire()
		else
			self.OnOtherPlayerEntered:Fire(p)
		end
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "SignalWhenInZoneBVH:Exited", function(p)
		if p == Players.LocalPlayer then
			self.OnLocalPlayerExited:Fire()
		else
			self.OnOtherPlayerExited:Fire(p)
		end
	end))
end

function v.QueryLocalPlayerInZone(p)
	return Remotes.invokeServerComponent(p.Instance, "SignalWhenInZoneBVH:IsInZone") == true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v