local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local MechanicsController = require(Players.LocalPlayer.PlayerScripts.Controllers.MechanicsController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local vortexes = Players.LocalPlayer.PlayerScripts.Assets.Misc.Vortexes
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._vortexes = {}
	self._forces = {}
	self._was_sitting = false
	self:_Init()
	return self
end

function class:UpdateForces()
	local humanoid = FighterController.LocalFighter and FighterController.LocalFighter.Entity and FighterController.LocalFighter.Entity.Humanoid
	local rootPart = humanoid and humanoid.RootPart

	if rootPart then
		for k, _vortex in pairs(self._vortexes) do
			local magnitude = (k.Position - rootPart.Position).Magnitude

			if k.Size.X / 2 < magnitude then
				if k.Size.X * 1 < magnitude then
					local _force = self._forces[k]

					if _force then
						self:_Cleanup(_force)
						self._forces[k] = nil
					end
				end
			elseif _vortex.UserID ~= Players.LocalPlayer.UserId and (not _vortex.TeamID or _vortex.TeamID ~= Players.LocalPlayer:GetAttribute("TeamID")) and not self._forces[k] then
				local vectorForce = Instance.new("VectorForce")
				vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
				vectorForce.Attachment0 = rootPart.RootRigAttachment
				vectorForce.Parent = nil
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.Parent = rootPart
				self._forces[k] = {
					RootPart = rootPart,
					VectorForce = vectorForce,
					BodyVelocity = bodyVelocity
				}
			end
		end

		if next(self._forces) then
			if MechanicsController.IsSliding then
				MechanicsController:StopSliding()
			end

			for k, _force in pairs(self._forces) do
				if not rootPart.Position:FuzzyEq(k.Position) then
					local cframe = CFrame.new(rootPart.Position, k.Position)
					local v = (cframe.RightVector * 0.15 + cframe.LookVector) * 5000
					_force.VectorForce.Force = v.Unit * math.min(v.Magnitude, 5000)
					_force.BodyVelocity.Velocity = cframe.LookVector * 50
				end

				humanoid.Sit = true
				self._was_sitting = true
			end
		elseif self._was_sitting then
			self._was_sitting = false
			humanoid.Sit = false
		end
	else
		for _, _force in pairs(self._forces) do
			self:_Cleanup(_force)
		end

		self._forces = {}
	end
end

function class:UpdateVisuals(p2)
	for k, _vortex in pairs(self._vortexes) do
		local v = math.clamp((tick() - _vortex.Start) / _vortex.Lifetime, 0, 1)
		_vortex.Clock += p2 * (v ^ 4 + 1)
		local v2 = math.max(0.01, 1 - v ^ 4)
		local v3 = CFrame.new(k.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, _vortex.Clock * (v ^ 4 * 4 + 4) % 6.283185307179586, 0) * CFrame.Angles(
			(1 - v ^ 6 * 3) * 0.7853981633974483,
			0,
			0
		) * CFrame.Angles(0, _vortex.Clock * (v ^ 4 * 4 + 4) % 6.283185307179586, 0)
		_vortex.Visual:ScaleTo(_vortex.OriginalScale * _vortex.ScaleSpring.Value * v2)
		_vortex.Visual:PivotTo(v3)

		if not (tick() > _vortex.NextShrink) then
			continue
		end

		_vortex.NextShrink = tick() + 0.25
		_vortex.ScaleSpring.Value -= 0.125
	end
end

function class:Update(p)
	self:UpdateForces(p)
	self:UpdateVisuals(p)
end

function class:_Cleanup(p)
	p.VectorForce:Destroy()
	p.BodyVelocity:Destroy()
end

function class:_ObjectAdded(parent)
	self:_ObjectRemoved(parent)
	Utility:CreateSound("rbxassetid://90138246017443", 1.25, 0.75 + 0.1 * math.random(), parent, true)
	local clone = (vortexes:FindFirstChild(parent:GetAttribute("ViewModelName") or "Default") or vortexes.Default):Clone()
	clone:ScaleTo(clone:GetScale() * parent.Size.X / 24)
	clone.Parent = parent
	local scaleSpring = Spring.new(1, 0.75, 20)
	scaleSpring.Value = 0
	self._vortexes[parent] = {
		Visual = clone,
		OriginalScale = clone:GetScale(),
		ScaleSpring = scaleSpring,
		NextShrink = tick() + 0.5,
		Start = tick(),
		Clock = 0,
		Lifetime = parent:GetAttribute("Lifetime"),
		TeamID = parent:GetAttribute("TeamID"),
		UserID = parent:GetAttribute("UserID")
	}
end

function class:_ObjectRemoved(p)
	self._vortexes[p] = nil

	if self._forces[p] then
		self:_Cleanup(self._forces[p])
		self._forces[p] = nil
	end
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("Vortex"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("Vortex"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("Vortex")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()