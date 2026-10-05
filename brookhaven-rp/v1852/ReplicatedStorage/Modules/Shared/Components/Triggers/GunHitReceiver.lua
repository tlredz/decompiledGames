local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "GunHitReceiver"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnPlayerShot = Signal.new()
	self._Janitor:Add(self.OnPlayerShot)

	if RunService:IsServer() then
		Remotes.createComponentRemoteEvent("receiveHit", self.Instance)
		self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "receiveHit", function(p, vector: Vector3)
			self.OnPlayerShot:Fire(p, vector)
		end))
	end
end

function v.Start(_) end

function v.OnPlayerShot(p, p2, vector: Vector3)
	if not RunService:IsClient() then
		p.OnPlayerShot:Fire(p2, vector)
		return
	end

	Remotes.fireServerComponent(p.Instance, "receiveHit", vector)
	p.OnPlayerShot:Fire(p2, vector)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v