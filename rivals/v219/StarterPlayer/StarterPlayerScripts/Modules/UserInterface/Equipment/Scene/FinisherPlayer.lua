local ReplicatedStorage = game:GetService("ReplicatedStorage")
local finishers = ReplicatedStorage.Modules.Finishers
local FinisherPlayer = {}
FinisherPlayer.__index = FinisherPlayer

function FinisherPlayer.new(scene)
	local self = setmetatable({}, FinisherPlayer)
	self.Scene = scene
	self._dummy_template = self.Scene.Model:WaitForChild("FinisherDummy")
	self._fake_player = self.Scene.Model:WaitForChild("FakePlayer")
	self._playing_hash = 0
	self._last_rig = nil
	self._last_finisher = nil
	self:_Init()
	return self
end

function FinisherPlayer:GetHumanoidCFrame()
	return self._dummy_template:GetPivot()
end

function FinisherPlayer:OnCustomizingStateChanged()
	task.defer(self._StartPlaying, self)
end

function FinisherPlayer:OnStateChanged()
	task.defer(self._StartPlaying, self)
end

function FinisherPlayer:_StartPlaying()
	self._playing_hash += 1
	local _playing_hash = self._playing_hash

	if self._last_rig then
		self._last_rig:Destroy()
		self._last_rig = nil
	end

	if self._last_finisher then
		self._last_finisher:Destroy()
		self._last_finisher = nil
	end

	local selectedCosmetic = self.Scene.Equipment:GetSelectedCosmetic()

	if self.Scene.Equipment:GetCustomizingType() ~= "Finisher" then
		return
	end

	while true do
		self._last_rig = self._dummy_template:Clone()
		self._last_rig:PivotTo(self:GetHumanoidCFrame() * CFrame.new(0, 0, 8))
		self._last_rig.Parent = self.Scene.Model
		self._last_rig.Humanoid:MoveTo((self._last_rig:GetPivot() * CFrame.new(0, 0, -16)).Position)
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://14266666697"
		local success, result = pcall(self._last_rig.Humanoid.LoadAnimation, self._last_rig.Humanoid, animation)

		if success then
			result:Play(0)
		end

		wait(0.5)

		if self._playing_hash ~= _playing_hash then
			break
		end

		if success then
			result:Stop(0)
		end

		self._last_rig:PivotTo(self._last_rig:GetPivot() * CFrame.Angles(
			0.17453292519943295,
			0,
			math.sign(math.random() - 0.5) * 0.17453292519943295
		))
		self._last_rig.HumanoidRootPart.AssemblyLinearVelocity *= 0
		self._last_rig.Humanoid.Health = 0

		for _, part in pairs(self._last_rig:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			for _, part2 in pairs(self._last_rig:GetChildren()) do
				if not (part2:IsA("BasePart") and part2 ~= part) then
					continue
				end

				local noCollisionConstraint = Instance.new("NoCollisionConstraint")
				noCollisionConstraint.Part1 = part2
				noCollisionConstraint.Part0 = part
				noCollisionConstraint.Parent = part
			end
		end

		for _, part in pairs(self._last_rig:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end

		local v = selectedCosmetic == "RANDOM_COSMETIC" and "Ragdoll" or selectedCosmetic or "Ragdoll"
		local v2 = {
			Character = self._fake_player
		}
		local module = require(finishers[v])
		self._last_finisher = module.new(self._last_rig.Humanoid, false, v2)
		self._last_finisher:Simulate()

		if self._playing_hash ~= _playing_hash then
			break
		end

		wait(3)

		if self._playing_hash ~= _playing_hash then
			break
		end

		if self._last_rig then
			self._last_rig:Destroy()
			self._last_rig = nil
		end

		if not self._last_finisher then
			continue
		end

		self._last_finisher:Destroy()
		self._last_finisher = nil
	end
end

function FinisherPlayer:_Setup()
	self._dummy_template.Parent = nil
end

function FinisherPlayer:_Init()
	self:_Setup()
end

return FinisherPlayer