local createVector = vector.create
local v = {}

function v.new(game, model, p)
	local self = setmetatable({}, {
		__index = v
	})
	self.Model = model
	self.Game = game
	self.Speed = self.Game.GAME_CONFIG.SPEED
	self.OutOfBound = -p * 1.1
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

	local speed = self.Speed
	local v2 = self.Model:GetPivot() + Vector3.new(-p * speed, 0, 0)
	self.Model:PivotTo(v2)

	if self.OutOfBound > v2.X then
		self:Destroy()
	end
end

return function(p, data)
	local GAME_CONFIG = p.GAME_CONFIG
	local MIN_SIZE = GAME_CONFIG.MIN_SIZE
	local SCREEN_HEIGHT = GAME_CONFIG.SCREEN_HEIGHT
	local _ = GAME_CONFIG.SCREEN_WIDTH
	local GAP_HEIGHT = GAME_CONFIG.GAP_HEIGHT
	local v2 = SCREEN_HEIGHT * -0.5
	local _ = SCREEN_HEIGHT * 0.5
	local _ = SCREEN_HEIGHT - MIN_SIZE.Y * 2 - GAP_HEIGHT
	local depth = data.Depth or 0
	local model = Instance.new("Model")
	model.Name = "LargeDecor"
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CFrame = CFrame.new(0, 0, 0)
	part.Parent = model
	model.PrimaryPart = part
	local clone = data.Options[math.random(1, #data.Options)]:Clone()
	clone.Transparency = 0
	local v3 = math.random() * 3.141592653589793 * 2
	clone:PivotTo(CFrame.new(0, v2, depth) * CFrame.Angles(0, v3, 0))
	clone.Parent = model
	return v.new(p, model, data.XOffset)
end