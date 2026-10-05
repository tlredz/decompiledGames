local Debris = game:GetService("Debris")
local part = Instance.new("Part")
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
local v = {
	GetOptions = function(self)
		return table.clone(self.options)
	end,
	GetLines = function(self)
		local clone = table.clone(self.lines)

		for _, branch in self.branches do
			local lines = branch:GetLines()
			table.move(lines, 1, #lines, #clone + 1, clone)
		end

		return clone
	end,
	IsDestroyed = function(p)
		return p.destroyed or false
	end,
	IsDrawn = function(p)
		return p.drew or false
	end,
	Draw = function(self, p)
		local model = Instance.new("Model")
		model.Name = "LightningBolt"
		self.model = model

		for _, v2 in self:GetLines() do
			local clone = part:Clone()
			local v3 = self.thickness - v2.depth * 2 * 0.1
			clone.Material = self.material
			clone.Color = self.color
			clone.Size = Vector3.new(v3, v3, (v2.goal - v2.origin).Magnitude + 0.5)
			clone.CFrame = CFrame.lookAt((v2.goal + v2.origin) * 0.5, v2.goal)
			clone.Transparency = v2.transparency
			clone.Parent = model
		end

		model.Parent = p or workspace.CurrentCamera
		self.drew = true
		local decay = self.options.decay

		if decay then
			Debris:AddItem(model, tonumber(decay) or 0)
			self.destroyed = true
		end
	end,
	Destroy = function(self)
		if self.model then
			self.model:Destroy()
			self.destroyed = true
		end
	end
}
local create

create = function(goal: Vector3, vector: Vector3, options)
	assert(typeof(goal) == "Vector3", "LightningBolt: `origin` must be a Vector3")
	assert(typeof(vector) == "Vector3", "LightningBolt: `goal` must be a Vector3")
	local v2 = options or {}
	local v3

	if v2 then
		v3 = v2.seed
	end

	local random = Random.new(v3)
	local branches = {}
	local self = setmetatable({
		options = v2 or {},
		random = random,
		origin = goal,
		goal = vector,
		depth = v2.max_depth or 0,
		thickness = v2.thickness or 1,
		rep = v2.bends or 6,
		color = v2.color or Color3.fromRGB(255, 255, 255),
		material = v2.material or Enum.Material.Neon,
		branches = branches
	}, {
		__index = v
	})
	local lines = {
		{
			origin = goal,
			goal = vector,
			transparency = v2.transparency or 0.4,
			depth = self.depth
		}
	}
	self.lines = lines

	for _ = 1, self.rep do
		for i = 1, #lines do
			local v6 = lines[i]
			local goal2 = v6.goal
			local v7 = v6.origin + (goal2 - v6.origin) * (random:NextInteger(40, 60) / 100)
			local number = random:NextNumber()
			local v8 = random:NextInteger(-530, 530) / 100
			local v9 = math.sin(3.141592653589793 * number * 2) * v8
			local v10 = math.cos(3.141592653589793 * number * 2) * v8
			v6.goal = (CFrame.lookAt(v7, v6.goal) * CFrame.new(v9, v10, 0)).Position
			table.insert(lines, {
				origin = v6.goal,
				goal = goal2,
				transparency = v6.transparency,
				depth = v6.depth
			})

			if not (v6.depth <= (v2.max_depth or 3)) then
				continue
			end

			local v11 = (goal - v6.goal).Magnitude / (goal - vector).Magnitude

			if not (random:NextInteger(1, 100) < (v2.fork_chance or 50) * v11) then
				continue
			end

			local options2 = self:GetOptions()
			options2.depth = v6.depth + 1
			options2.bends = options2.fork_bends or 2
			table.insert(
				branches,
				(create(v6.goal, v6.goal + (v6.goal - v6.origin).Unit * random:NextInteger(20, 40), options2))
			)
		end
	end

	return self
end

return {
	create = create
}