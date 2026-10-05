local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Tyrannosaurus"
})
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
	self._holdJanitor = nil
end

function v:_StopWatchingForTeleport()
	if self._holdJanitor ~= nil then
		self._holdJanitor:Destroy()
		self._holdJanitor = nil
	end
end

function v:_WatchForTeleport(instance, instance2)
	local attachment1 = instance2.Attachment1

	if attachment1 == nil or attachment1:IsDescendantOf(self.Instance) == false then
		return
	end

	self:_StopWatchingForTeleport()
	local maid = Janitor.new()
	self._holdJanitor = maid
	local position = instance.Position
	local pivot = self.Instance:GetPivot()
	local v2 = os.clock() + 0.5
	maid:Add(RunService.Heartbeat:Connect(function()
		local position2 = instance.Position
		local magnitude = (position2 - position).Magnitude
		position = position2

		if os.clock() < v2 or magnitude < 12 then
			pivot = self.Instance:GetPivot()
			return
		end

		self:_StopWatchingForTeleport()

		if instance2.Parent ~= nil then
			instance2:Destroy()
		end

		local tyrannosaurusMouthGrab = instance:FindFirstChild("TyrannosaurusMouthGrab")

		if tyrannosaurusMouthGrab ~= nil then
			tyrannosaurusMouthGrab:Destroy()
		end

		self.Instance:PivotTo(pivot)
		Remotes.fireServerComponent(self.Instance, "RequestReleaseGrabForTeleport")
	end))
end

function v:_OnCharacterAdded(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

	if humanoidRootPart == nil then
		return
	end

	self._Janitor:Add(humanoidRootPart.ChildAdded:Connect(function(rigidConstraint)
		if rigidConstraint:IsA("RigidConstraint") and rigidConstraint.Name == "TyrannosaurusMouthWeld" then
			self:_WatchForTeleport(humanoidRootPart, rigidConstraint)
		end
	end))
	self._Janitor:Add(humanoidRootPart.ChildRemoved:Connect(function(rigidConstraint)
		if rigidConstraint:IsA("RigidConstraint") and rigidConstraint.Name == "TyrannosaurusMouthWeld" then
			self:_StopWatchingForTeleport()
		end
	end))
end

function v:Start()
	if localPlayer.Character ~= nil then
		self:_OnCharacterAdded(localPlayer.Character)
	end

	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function(character)
		self:_OnCharacterAdded(character)
	end))
	self._Janitor:Add(localPlayer.CharacterRemoving:Connect(function()
		self:_StopWatchingForTeleport()
	end))
end

function v:Stop()
	self:_StopWatchingForTeleport()
	self._Janitor:Destroy()
end

return v