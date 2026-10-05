local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AnimationSpeedDrivenSeat"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._animationJanitor = Janitor.new()
	self.characterRemovingConnections = {}
	self.animationCache = {}
end

function v:Reset()
	self._animationJanitor:Cleanup()

	if self.currentAnimationTrack then
		self.currentAnimationTrack:Stop()
	end

	if self.currentOccupantHumanoid then
		self.currentOccupantHumanoid.HipHeight = self.currentHipHeight
	end

	self.currentCharacter = nil
	self.currentOccupantHumanoid = nil
	self.currentOccupantHumanoidRootPart = nil
	self.currentAnimationTrack = nil
end

function v:Start()
	local instance = self.Instance
	self.currentCharacter = nil
	self.currentOccupantHumanoid = nil
	self.currentOccupantHumanoidRootPart = nil
	self.currentAnimationTrack = nil
	self.currentHipHeight = 0
	local speedMultiplier = self.Instance:GetAttribute("SpeedMultiplier") or 1
	self._Janitor:Add(instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		if not instance.Occupant then
			self:Reset()
			return
		end

		self.currentCharacter = instance.Occupant.Parent
		self.currentOccupantHumanoid = instance.Occupant
		self.currentHipHeight = self.currentOccupantHumanoid.HipHeight
		self.currentOccupantHumanoidRootPart = instance.Occupant.Parent:FindFirstChild("HumanoidRootPart")

		if not self.currentOccupantHumanoidRootPart then
			return
		end

		local speedAnimation = self.Instance:FindFirstChild("SpeedAnimation")
		self.currentAnimationTrack = self.animationCache[self.currentCharacter]

		if self.currentAnimationTrack == nil then
			local animator = self.currentOccupantHumanoid:FindFirstChild("Animator")

			if animator == nil then
				warn("No animator found for " .. self.currentCharacter.Name)
			else
				self.currentAnimationTrack = animator:LoadAnimation(speedAnimation)
				self.animationCache[self.currentCharacter] = self.currentAnimationTrack
			end
		end

		self.currentAnimationTrack:Play()
		self.currentOccupantHumanoid.HipHeight = 0
		self._animationJanitor:Add(RunService.RenderStepped:Connect(function()
			if self.currentOccupantHumanoidRootPart.Parent == nil then
				self._animationJanitor:Cleanup()
			else
				self.currentAnimationTrack:AdjustSpeed(self.currentOccupantHumanoidRootPart.AssemblyLinearVelocity.Magnitude * speedMultiplier)
			end
		end))
	end))

	local function onPlayerAdded(p)
		local characterRemovingConnection = self.characterRemovingConnections[p.UserId]

		if characterRemovingConnection ~= nil then
			characterRemovingConnection:Disconnect()
			self.characterRemovingConnections[p.UserId] = nil
		end

		self.characterRemovingConnections[p.UserId] = p.CharacterRemoving:Connect(function(character)
			if self.animationCache[character] ~= nil then
				self.animationCache[character]:Destroy()
				self.animationCache[character] = nil
			end

			if self.currentCharacter == character then
				self:Reset()
			end
		end)
	end

	self._Janitor:Add(Players.PlayerAdded:Connect(onPlayerAdded))

	for _, v2 in Players:GetPlayers() do
		onPlayerAdded(v2)
	end

	self._Janitor:Add(Players.PlayerRemoving:Connect(function(player)
		local characterRemovingConnection = self.characterRemovingConnections[player.UserId]

		if characterRemovingConnection ~= nil then
			characterRemovingConnection:Disconnect()
			self.characterRemovingConnections[player.UserId] = nil
		end

		local character = player.Character

		if character ~= nil and self.currentCharacter == character then
			self:Reset()
		end
	end))
end

function v:Stop()
	for _, characterRemovingConnection in self.characterRemovingConnections do
		characterRemovingConnection:Disconnect()
	end

	self.characterRemovingConnections = {}
	self:Reset()
	self._Janitor:Destroy()
	self._animationJanitor:Destroy()
end

return v