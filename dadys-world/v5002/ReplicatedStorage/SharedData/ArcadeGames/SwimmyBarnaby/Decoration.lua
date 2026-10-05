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

	if v2 and data.Frames and #data.Frames > 0 then
		local frame = data.Frames[math.random(1, #data.Frames)]
		local size = data.Size or 6
		local plane = v2.buildPlane(Vector3.new(size, size, 0), { frame })

		if data.Transparency and data.Transparency > 0 then
			for _, decal in ipairs(plane:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Transparency = data.Transparency
				end
			end
		end

		plane.CFrame = CFrame.new(0, yPos, depth)
		plane.Parent = model
	elseif data.Options and #data.Options > 0 then
		local clone = data.Options[math.random(1, #data.Options)]:Clone()
		clone:PivotTo(CFrame.new(0, yPos, depth) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0))
		clone.Parent = model
	end

	return v.new(p, model, data.XOffset, data.DriftMul)
end