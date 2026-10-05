local createVector = vector.create
local v = {}
local success, result = pcall(function()
	return require(script.Parent:WaitForChild("Frames", 5))
end)
local v2 = success and result or nil
local v3 = 0.75
local v4 = 0.01

function v.new(game, part)
	local self = setmetatable({}, {
		__index = v
	})
	self.Part = part
	self.Game = game
	self.OverlapParams = OverlapParams.new()
	self.OverlapParams.FilterDescendantsInstances = { part }
	self.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	self.CanEndGame = true
	self.Weightless = true
	self.IsSpinning = false
	self.Velocity_Y = -0.1
	self.Acceleration_Y = -5
	return self
end

function v:Destroy()
	self.Destroyed = true
	self.Velocity_Y = 0
	self.Part:Destroy()
end

function v.SetGravity(_, p: number?)
	if p then
		v3 = p
	end
end

function v.SetIntroFloat(_, p: number?)
	if p then
		v4 = p
	end
end

function v:Jump()
	self.Velocity_Y = math.max(math.max(0, self.Velocity_Y) + 0.8, 1)
	self.Weightless = false
end

function v:IsOutOfBounds()
	local SCREEN_HEIGHT = self.Game.GAME_CONFIG.SCREEN_HEIGHT
	local Y = self.Part.Position.Y
	return SCREEN_HEIGHT * 0.5 < Y or Y < SCREEN_HEIGHT * -0.5
end

function v:IsOverlapping()
	local parent = self.Part.Parent

	if parent then
		return #parent:GetPartBoundsInBox(self.Part.CFrame, self.Part.Size * 0.8, self.OverlapParams) > 0
	end

	return false
end

function v:tick(p)
	if self.Destroyed then
		return
	end

	if self.Anim then
		self.Anim:Advance(p)
	end

	local v5 = self.Weightless and self.Acceleration_Y * p * v3 * v4 or self.Acceleration_Y * p * v3
	self.Velocity_Y = math.max(-2, self.Velocity_Y + v5)
	local v6 = (self.Velocity_Y + 2) / 4
	local cframe = CFrame.Angles(0, 0, 1.5707963267948966 * (v6 - 0.5))

	if self.IsSpinning then
		local zAngle = (self.ZAngle or 0) + p * 10
		cframe = CFrame.Angles(0, 0, zAngle)
		self.ZAngle = zAngle
	end

	local v7 = CFrame.new(self.Part.Position + Vector3.new(0, self.Velocity_Y * 60 * p, 0)) * cframe
	self.Part:PivotTo(v7 * CFrame.Angles(0, 3.141592653589793, 0))

	if self:IsOutOfBounds() or self:IsOverlapping() then
		return -1
	end
end

return function(p, options, instance, p2: string)
	local v5 = options or {}
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.Transparency = 1
	part.Color = v5.Color or Color3.new(0.796078, 0.760784, 0.25098)
	part.Size = v5.Size or createVector(1, 1, 1)
	local v6 = v.new(p, part)

	if v2 and v2.Fish and #v2.Fish > 0 then
		local v7 = part.Size * (v2.FishScale or 1)
		local plane = v2.buildPlane(v7, v2.Fish)
		plane.CFrame = part.CFrame
		plane.Parent = part
		v6.Anim = v2.newAnimator(plane, v2.Fish, v2.FishFPS)
		return v6
	else
		local clone = instance:Clone()

		if clone:IsA("MeshPart") then
			clone.TextureID = p2 or clone.TextureID
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CFrame = part.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		clone.Parent = part
		return v6
	end
end