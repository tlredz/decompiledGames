local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TeleportOnSeatLeave"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._playerSitting = false
end

function v:Start()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = self.Instance.Occupant

		if occupant and occupant:IsDescendantOf(Players.LocalPlayer.Character) then
			self._playerSitting = true
			return
		end

		self:Teleport()
		self._playerSitting = false
	end))
end

function v:Teleport()
	if not self._playerSitting then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		print("TeleportOnSeatLeave:Teleport() - No active character")
		return
	end

	local teleportSpot = self.Instance:FindFirstChild("TeleportSpot")

	if not teleportSpot then
		warn("TeleportOnSeatLeave:Start() - No teleport spot found")
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		warn("TeleportOnSeatLeave:Teleport() - No humanoid found")
		return
	end

	task.wait()
	character:PivotTo(teleportSpot.WorldCFrame)
	humanoid:ChangeState(Enum.HumanoidStateType.Landed)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v