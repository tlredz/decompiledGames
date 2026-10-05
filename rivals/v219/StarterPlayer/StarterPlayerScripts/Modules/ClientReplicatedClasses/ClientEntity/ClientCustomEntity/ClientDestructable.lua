local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ClientCustomEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientCustomEntity)
local shatterVisuals = Players.LocalPlayer.PlayerScripts.Assets.Destructables.ShatterVisuals
local visuals = Players.LocalPlayer.PlayerScripts.Assets.Destructables.Visuals
local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
local object = setmetatable({}, ClientCustomEntity)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientCustomEntity.new(...), object)
	self.ShatterModelAdded = Signal.new()
	self.AimAssistBlacklist = true
	self.PlayRubbleEffectOnDeath = nil
	self._shatter_template = shatterVisuals:FindFirstChild(self.Model.Name)
	self._death_animation_override = true
	self._death_sound_override = true
	self._visual = nil
	self._always_face_camera = self.Model:GetAttribute("AlwaysFaceCamera") or false
	self._shatter_sound_id = self.Model:GetAttribute("ShatterSoundID") or not self._shatter_template and "rbxassetid://14441658101" or self._shatter_template:GetAttribute("ShatterSoundID") or "rbxassetid://14441658101"
	self._next_update = 0
	self._shatter_effect_chance = 1
	self:_Init()
	return self
end

function object.Destroy(p)
	p.ShatterModelAdded:Destroy()
	ClientCustomEntity.Destroy(p)
end

function object:_RubbleEffect(_)
	for _, descendant in pairs(self.Model:GetDescendants()) do
		local hasTag = descendant:HasTag("IsRubble")

		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = hasTag and 0 or 1
		end

		if descendant:IsA("BasePart") then
			descendant.CanCollide = hasTag
		end
	end
end

function object:_ShatterEffect(p)
	local v = self._visual and self._visual.CFrame * cframe:Inverse() * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	) or self.Model:GetPivot()
	self.Model:ClearAllChildren()

	if math.random() > self._shatter_effect_chance and (workspace.CurrentCamera.CFrame.Position - v.Position).Magnitude > 24 then
		return
	end

	local clone = self._shatter_template:Clone()
	clone.Parent = self.Model
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(v)
	clone.PrimaryPart:Destroy()
	local shatterStrength = clone:GetAttribute("ShatterStrength") or 1
	local random = Random.new()

	for _, child in pairs(clone:GetChildren()) do
		local lookVector = CFrame.new(self.RootPart.Position, child.Position).LookVector
		local velocity = Vector3.new(lookVector.X, math.max(0, lookVector.Y) * 2, lookVector.Z) * (10 + 10 * math.random()) * shatterStrength
		child.CanCollide = true
		child.CanTouch = false
		child.Anchored = false
		child.RotVelocity = random:NextUnitVector() * 25 * math.random()
		child.Velocity = velocity

		for _, child2 in pairs(clone:GetChildren()) do
			if child2 == child then
				continue
			end

			local noCollisionConstraint = Instance.new("NoCollisionConstraint")
			noCollisionConstraint.Part0 = child
			noCollisionConstraint.Part1 = child2
			noCollisionConstraint.Parent = child
		end
	end

	if not p then
		Utility:CreateSound(
			self._shatter_sound_id,
			0.625 + 0.25 * math.random(),
			1.5 + 0.5 * math.random(),
			v.Position,
			true,
			10
		)
	end

	if self._visual then
		self._visual:Destroy()
		self._visual = nil
	end

	self.ShatterModelAdded:Fire(clone)
end

function object:_CheckDead(p)
	if self:IsAlive() then
		return
	end

	if self.PlayRubbleEffectOnDeath then
		self:_RubbleEffect(p)
	else
		self:_ShatterEffect(p)
	end
end

function object:_Setup()
	local child = visuals:FindFirstChild(self.Model.Name)

	if child then
		self._visual = child:Clone()
		self._visual.CanCollide = false
		self._visual.CanQuery = false
		self._visual.CanTouch = false
		self._visual.Anchored = true
		self._visual.Parent = self.Model
	end
end

function object:_Init()
	self.Died:Connect(function()
		self:_CheckDead()
	end)
	self:_Setup()
	task.defer(self._CheckDead, self, true)
end

return object