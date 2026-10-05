local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Class = require(script.Class)
local new = Class()
local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	function new:init(origin, goal, options)
		if typeof(origin) ~= "Vector3" then
			error("LightningBolt: `from` must be a Vector3")
		end

		if typeof(goal) ~= "Vector3" then
			error("LightningBolt: `to` must be a Vector3")
		end

		self.options = options or {}

		if self.options.seed then
			self.random = Random.new(self.options.seed)
		else
			self.random = Random.new()
		end

		self.origin = origin
		self.goal = goal
		self.depth = self.options.depth or 0
		self.thickness = self.options.thickness or 1
		self.rep = self.options.bends or 6

		if self.options.color then
			if typeof(self.options.color) == "Color3" then
				self.color = self.options.color
			elseif typeof(self.options.color) == "BrickColor" then
				self.color = self.options.color.Color
			else
				error("LightningBolt: `Options.color` must be a Color3 or BrickColor")
			end
		else
			self.color = BrickColor.new("White").Color
		end

		self.material = self.options.material or Enum.Material.Neon
		self.branches = {}
		self.lines = {
			{
				origin = origin,
				goal = goal,
				transparency = self.options.transparency or 0.4,
				depth = self.depth
			}
		}
		self:generateBolt()
	end

	function new:GetOptions()
		local options = {}

		for k, option in pairs(self.options) do
			options[k] = option
		end

		return options
	end

	function new:GetLines()
		local result = {}

		for i = 1, #self.lines do
			result[i] = self.lines[i]
		end

		for i = 1, #self.branches do
			local lines = self.branches[i]:GetLines()

			for i2 = 1, #lines do
				result[#result + 1] = lines[i2]
			end
		end

		return result
	end

	function new.IsDestroyed(p)
		return p.destroyed or false
	end

	function new.IsDrawn(p)
		return p.drew or false
	end

	function new:generateBolt()
		for _ = 1, self.rep do
			self:bend()
		end
	end

	function new:displace(p, p2, p3, p4)
		return (CFrame.new(p, p2) * CFrame.new(
			math.sin(3.141592653589793 * p4 * 2) * p3,
			math.cos(3.141592653589793 * p4 * 2) * p3,
			0
		)).p
	end

	function new:bend()
		for i = 1, #self.lines do
			local line = self.lines[i]
			local goal = line.goal
			line.goal = self:displace(
				line.origin + (line.goal - line.origin).unit * (line.goal - line.origin).magnitude * self.random:NextInteger(
					40,
					60
				) / 100,
				line.goal,
				self.random:NextInteger(-530, 530) / 100,
				self.random:NextNumber()
			)
			self.lines[#self.lines + 1] = {
				origin = line.goal,
				goal = goal,
				transparency = line.transparency,
				depth = line.depth
			}

			if not (line.depth <= (self.options.max_depth or 3)) then
				continue
			end

			local v2 = (self.origin - line.goal).magnitude / (self.origin - self.goal).magnitude

			if not (self.random:NextInteger(1, 100) < (self.options.fork_chance or 50) * v2) then
				continue
			end

			local options = self:GetOptions()
			options.depth = line.depth + 1
			options.bends = options.fork_bends or 2
			local v3 = new(
				line.goal,
				line.goal + (line.goal - line.origin).unit * self.random:NextInteger(20, 40),
				options
			)
			self.branches[#self.branches + 1] = v3
		end
	end

	function new:Draw(p)
		local model = Instance.new("Model")
		self.model = model
		model.Name = "LightningBolt"
		self.SegmentCache = {}
		local clone = part:Clone()
		clone.Material = self.material
		clone.Color = self.color
		local lines = self:GetLines()

		for i = 1, #lines do
			local line = lines[i]
			local clone2 = clone:Clone()
			clone2.Size = Vector3.new(
				self.thickness - line.depth * 2 * 0.1,
				self.thickness - line.depth * 2 * 0.1,
				(line.origin - line.goal).magnitude + 0.5
			)
			clone2.CFrame = CFrame.new((line.goal + line.origin) / 2, line.goal)
			clone2.Transparency = line.transparency
			clone2.Parent = model
			table.insert(self.SegmentCache, i, clone2)
		end

		model.Parent = p or workspace
		self.drew = true

		if self.options.decay then
			Debris:AddItem(model, tonumber(self.options.decay) or 0)
			self.destroyed = true
		end
	end

	function new:Update(origin, goal, transparency, color, thickness)
		self.color = color
		self.thickness = thickness
		self.transparency = transparency
		self.branches = {}
		self.lines = {
			{
				origin = origin,
				goal = goal,
				transparency = 0,
				depth = self.depth
			}
		}
		self:generateBolt()
		local lines = self:GetLines()

		for i = 1, #lines do
			local line = lines[i]
			local v2 = self.SegmentCache[i]
			v2.Size = Vector3.new(
				self.thickness - line.depth * 2 * 0.1,
				self.thickness - line.depth * 2 * 0.1,
				(line.origin - line.goal).magnitude + 0.5
			)
			v2.CFrame = CFrame.new((line.goal + line.origin) / 2, line.goal)
			v2.Transparency = transparency
			v2.Color = color
		end
	end

	function new:Destroy()
		if self.model then
			self.model:Destroy()
			self.destroyed = true
		end
	end
end

return (setmetatable({
	new = new
}, {
	__call = function(_, ...)
		return new(...)
	end
}))