local createVector = vector.create
local v = {}
local _, _ = pcall(function()
	return require(script.Parent:WaitForChild("Frames", 5))
end)

function v.new(game, model)
	local self = setmetatable({}, {
		__index = v
	})
	self.Model = model
	self.Game = game
	return self
end

function v:Destroy()
	self.Destroyed = true
	self.Model:Destroy()
end

function v:tick(p)
	if self.Destroyed then
		return
	end

	if self.Anims then
		for _, anim in ipairs(self.Anims) do
			anim:Advance(p)
		end
	end

	local SCREEN_WIDTH = self.Game.GAME_CONFIG.SCREEN_WIDTH
	local v2 = self.Model:GetPivot() + Vector3.new(-p * SCREEN_WIDTH, 0, 0)
	self.Model:PivotTo(v2)

	if self._fadeDecals then
		local v3 = SCREEN_WIDTH * -0.5
		local v4 = SCREEN_WIDTH * -0.78
		local transparency = math.clamp((v2.X - v3) / (v4 - v3), 0, 1)

		for _, _fadeDecal in ipairs(self._fadeDecals) do
			_fadeDecal.Transparency = transparency
		end
	end

	if v2.X < SCREEN_WIDTH * -0.475 then
		if not self.Scored then
			self.Scored = true
			self.Game:IncreaseScore(1)
		end

		if v2.X < SCREEN_WIDTH * -0.78 then
			self:Destroy()
		end
	end
end

return function(p, p2, instance, _, p3)
	local GAME_CONFIG = p.GAME_CONFIG
	local MIN_SIZE = GAME_CONFIG.MIN_SIZE
	local SCREEN_HEIGHT = GAME_CONFIG.SCREEN_HEIGHT
	local v2 = p3 or GAME_CONFIG.GAP_HEIGHT
	local v3 = SCREEN_HEIGHT * -0.5
	local v4 = SCREEN_HEIGHT * 0.5
	local v5 = SCREEN_HEIGHT - MIN_SIZE.Y * 2 - v2
	local model = Instance.new("Model")
	model.Name = "ObstacleSet"
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CFrame = CFrame.new(0, 0, 0)
	part.Parent = model
	model.PrimaryPart = part
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.TopSurface = "Smooth"
	part2.BottomSurface = "Smooth"
	part2.Transparency = 1
	part2.Color = Color3.new(0.113725, 0.796078, 0.137255)
	part2.Size = MIN_SIZE + Vector3.new(0, v5 * p2, 0)
	part2.CFrame = CFrame.new(0, v3 + part2.Size.Y * 0.5, 0)
	part2.Parent = model
	local clone = part2:Clone()
	clone.Size = MIN_SIZE + Vector3.new(0, v5 * (1 - p2), 0)
	clone.CFrame = CFrame.new(0, v4 + clone.Size.Y * -0.5, 0)
	clone.Parent = model
	local v6 = v.new(p, model)
	local clone2 = instance:Clone()
	clone2.Size = part2.Size / createVector(0.5, 1, 5) + createVector(0, 6, 0)
	clone2:PivotTo(part2:GetPivot() * CFrame.new(0, -2, 0))
	clone2.Parent = part2
	clone2:AddTag("BendySeaweed")
	local clone3 = instance:Clone()
	clone3.Size = clone.Size / createVector(0.5, 1, 5) + createVector(0, 6, 0)
	clone3:PivotTo(clone:GetPivot() * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.new(0, -2, 0))
	clone3.Parent = clone
	clone3:AddTag("BendySeaweed")
	return v6
end