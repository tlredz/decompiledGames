local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local vector = Vector2.new(0.5, 0.5)
local v = Component.new({
	Tag = "Summer2026ButtonAnimation"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function randomStarInterval()
	return 0.8999999999999999 + math.random() * 0.8999999999999999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomVariance()
	return 1 + (math.random() * 2 - 1) * 0.25
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._time = 0
	self._sparkle = nil
	self._templateStar = nil
	self._stars = {}
	self._starCountdown = randomStarInterval()
end

function v:Start()
	self._sparkle = self.Instance:WaitForChild("Sparkle")
	self._templateStar = self.Instance:WaitForChild("TemplateStar")
	local visiblePointer = self.Instance:FindFirstChild("VisiblePointer")
	local visibleInstance

	if visiblePointer ~= nil then
		visibleInstance = visiblePointer.Value
	end

	self._visibleInstance = visibleInstance
end

function v:_spawnStar()
	local clone = self._templateStar:Clone()
	clone.ImageTransparency = 0
	clone.Size = UDim2.fromScale(0, 0)
	clone.Parent = self.Instance
	local v2 = math.random() * 3.141592653589793 * 2
	local vector2 = Vector2.new(math.cos(v2), (math.sin(v2)))
	local vector3 = Vector2.new((vector2.X + 1) / 2, (vector2.Y + 1) / 2)
	table.insert(self._stars, {
		instance = clone,
		time = 0,
		duration = randomVariance() * 10,
		peakSize = randomVariance() * 0.2,
		endPosition = vector3
	})
end

function v:_updateStars(p: number)
	self._starCountdown -= p

	if self._starCountdown <= 0 then
		self:_spawnStar()
		self._starCountdown = randomStarInterval()
	end

	for i = #self._stars, 1, -1 do
		local _star = self._stars[i]
		_star.time += p
		local v2 = _star.time / _star.duration

		if v2 >= 1 then
			_star.instance:Destroy()
			table.remove(self._stars, i)
		else
			local v3 = _star.peakSize * math.sin(v2 * 3.141592653589793)
			_star.instance.Size = UDim2.fromScale(v3, v3)
			local lerped = vector:Lerp(_star.endPosition, v2)
			_star.instance.Position = UDim2.fromScale(lerped.X, lerped.Y)
		end
	end
end

function v:RenderSteppedUpdate(p: number)
	local _sparkle = self._sparkle

	if _sparkle == nil or self._templateStar == nil or self._visibleInstance ~= nil and not self._visibleInstance.Visible then
		return
	end

	self._time += p
	_sparkle.Rotation = self._time / 15 * 360 % 360
	local v2 = (math.sin(self._time * 0.8975979010256552) + 1) * 0.5 * -0.33834586466165395 + 1.2781954887218043
	_sparkle.Size = UDim2.fromScale(v2, v2)

	if self._visibleInstance ~= nil then
		self:_updateStars(p)
	end
end

function v:Stop()
	for _, _star in self._stars do
		_star.instance:Destroy()
	end

	table.clear(self._stars)
	self._Janitor:Destroy()
end

return v