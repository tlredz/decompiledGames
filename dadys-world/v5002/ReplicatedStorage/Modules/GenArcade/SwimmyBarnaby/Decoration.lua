local createVector = vector.create
local v = {}
local success, result = pcall(function()
	return require(script.Parent:WaitForChild("Frames", 5))
end)
local v2 = success and result or nil

function v.new(game, model, p, value)
	local self = setmetatable({}, {
		__index = v
	})
	self.Model = model
	self.Game = game
	self.Speed = self.Game.GAME_CONFIG.SPEED * (value or 0.6)
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
	local v3 = self.Model:GetPivot() + Vector3.new(-p * speed, 0, 0)
	self.Model:PivotTo(v3)

	if self.Animator then
		self.Animator:Advance(p)
	end

	if self.OutOfBound > v3.X then
		self:Destroy()
	end
end

return function(p, data)
	local v3 = p.GAME_CONFIG.SCREEN_HEIGHT * -0.5
	local depth = data.Depth or 0
	local model = Instance.new("Model")
	model.Name = data.Name or "Decor"
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CFrame = CFrame.new(0, 0, 0)
	part.Parent = model
	model.PrimaryPart = part
	local yPos = data.YPos or v3
	local v4 = nil

	if v2 and data.Frames and #data.Frames > 0 then
		local size = data.Size or 6
		local v5

		if data.Animate then
			v5 = v2.buildPlane(Vector3.new(size, size, 0), data.Frames)
			v4 = v5
		else
			local v6 = { data.Frames[math.random(1, #data.Frames)] }
			v5 = v2.buildPlane(Vector3.new(size, size, 0), v6)
		end

		if data.Transparency and data.Transparency > 0 then
			for _, decal in ipairs(v5:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Transparency = data.Transparency
				end
			end
		end

		v5.CFrame = CFrame.new(0, yPos, depth)
		v5.Parent = model
	elseif data.Options and #data.Options > 0 then
		local clone = data.Options[math.random(1, #data.Options)]:Clone()
		clone:PivotTo(CFrame.new(0, yPos, depth) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0))
		clone.Parent = model
	end

	local v5 = v.new(p, model, data.XOffset, data.DriftMul)

	if v4 and v2 and v2.newAnimator then
		v5.Animator = v2.newAnimator(v4, data.Frames, data.FPS)
	end

	return v5
end