local createVector = vector.create
local Base = {}
Base.__index = Base
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Server)
local v = {
	Flying = 0,
	Dead = 1
}

function Base.new(player, object, p2, _)
	local v2 = {
		Position = object.Position,
		Velocity = createVector(0, 0, 0),
		Acceleration = createVector(0, 0, 0),
		State = 0,
		Object = object,
		CastParams = RaycastParams.new(),
		Caster = player,
		Type = p2
	}
	v2.CastParams.FilterDescendantsInstances = { player.Character, workspace.ProjectileInstances, workspace.Terrain }
	v2.CastParams.FilterType = Enum.RaycastFilterType.Exclude
	setmetatable(v2, Base)
	return v2
end

function Base:ApplyAcceleration(acceleration: Vector3)
	self.Acceleration = acceleration
end

function Base:Update(p: number)
	if self.State == v.Collided then
		return
	end

	self.Position += self.Velocity * p
	self.Velocity += self.Acceleration + createVector(0, -0.55, 0)
	self.Acceleration = createVector(0, 0, 0)

	if self.Object then
		local v2 = math.sin(tick() * 8)
		local v3 = math.cos(tick() * 8)

		if self.ProjectileAngle then
			self.Object.CFrame = CFrame.new(self.Position) * self.ProjectileAngle
		else
			self.Object.CFrame = CFrame.new(self.Position) * CFrame.Angles(v2, v2 + v3, v3)
		end
	end

	local raycastResult = workspace:Raycast(self.Position, self.Velocity * p, self.CastParams)

	if raycastResult then
		ReplicatedStorage.Remotes.ProjectileHit:Fire(self.Object, raycastResult)
	end

	if not raycastResult then
		return
	end

	self.State = v.Collided
	self.Position = raycastResult.Position
	self.Object.Position = raycastResult.Position
	return raycastResult
end

return Base