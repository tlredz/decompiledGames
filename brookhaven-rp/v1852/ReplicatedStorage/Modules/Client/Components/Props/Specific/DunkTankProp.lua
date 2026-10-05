local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GunHitReceiver = require(ReplicatedStorage.Modules.Shared.Components.Triggers.GunHitReceiver)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DunkTankProp"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local expect = GunHitReceiver:WaitForInstance(self.Instance:WaitForChild("Hitbox")):expect()
	self._Janitor:Add(expect.OnPlayerShot:Connect(function(_, _)
		self.Instance:FindFirstChild("DunkRemote"):FireServer()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v