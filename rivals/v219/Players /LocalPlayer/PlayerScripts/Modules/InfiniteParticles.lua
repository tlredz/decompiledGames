local Players = game:GetService("Players")
local infiniteAmmoParticle = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InfiniteAmmoParticle")
local v = {
	"RichText",
	"Text",
	"TextColor",
	"TextTransparency"
}
local InfiniteParticles = {}
InfiniteParticles.__index = InfiniteParticles

function InfiniteParticles.new(ammo_element, reserve_element)
	local self = setmetatable({}, InfiniteParticles)
	self._ammo_element = ammo_element
	self._reserve_element = reserve_element
	self._is_active = false
	self._ammo_active = false
	self._reserve_active = false
	self._particles = {}
	self._next_particle = 0
	self:_Init()
	return self
end

function InfiniteParticles:SetActive(p, p2)
	self._ammo_active = p and true or false
	self._reserve_active = p2 and true or false
	self._is_active = self._ammo_active or self._reserve_active

	if not self._is_active then
		self:_Clear()
	end
end

function InfiniteParticles:Update(p)
	if self._is_active then
		self:_UpdateInfiniteAmmo(p, self._ammo_active, self._reserve_active)
	end
end

function InfiniteParticles:Destroy()
	self:_Clear()
end

function InfiniteParticles:_Clear()
	for i = #self._particles, 1, -1 do
		self:_CleanupParticle(i)
	end
end

function InfiniteParticles:_CleanupParticle(p2)
	local _particle = self._particles[p2]

	for _, connection in pairs(_particle.Connections) do
		connection:Disconnect()
	end

	_particle.Particle:Destroy()
	table.remove(self._particles, p2)
end

function InfiniteParticles:_SpawnInfiniteAmmoParticle(parent)
	if not (parent and parent:IsDescendantOf(Players)) then
		return
	end

	local clone = infiniteAmmoParticle:Clone()
	clone.Position = UDim2.new(
		parent.TextXAlignment == Enum.TextXAlignment.Left and 0 or 1,
		parent.TextBounds.X * math.random() * (parent.TextXAlignment == Enum.TextXAlignment.Left and 1 or -1),
		0.5,
		parent.TextBounds.Y * 0.5 * (math.random() - 0.5)
	)
	clone.Parent = parent
	clone:TweenSize(UDim2.new(), "In", "Back", 0.75, true)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		for _, v2 in pairs(v) do
			clone[v2] = parent[v2]
		end
	end

	local connections = {}

	for _, propertyName in pairs(v) do
		table.insert(connections, parent:GetPropertyChangedSignal(propertyName):Connect(update))
	end

	update() -- equivalent call inferred; original call site unknown
	table.insert(self._particles, {
		Particle = clone,
		Connections = connections,
		Position = clone.Position,
		Velocity = Vector2.new(math.random() - 0.5, -math.random() - 0.5) * 100,
		Start = tick()
	})
end

function InfiniteParticles:_UpdateInfiniteAmmo(p)
	for i = #self._particles, 1, -1 do
		local _particle = self._particles[i]

		if tick() - _particle.Start >= 1 or not _particle.Particle.Parent then
			self:_CleanupParticle(i)
		else
			local v2 = math.min(_particle.Particle.Parent.AbsoluteSize.X, _particle.Particle.Parent.AbsoluteSize.Y)
			local v3 = _particle.Velocity.X * p / 60 * 4
			local v4 = _particle.Velocity.Y * p / 60 + 0.25 * (tick() - _particle.Start) ^ 2
			_particle.Position += UDim2.new(0, v2 * v3, 0, v2 * v4)
			_particle.Particle.Position = _particle.Position
			_particle.Particle.Rotation += v3 * 200
		end
	end

	if tick() < self._next_particle then
		return
	end

	self._next_particle = tick() + 0.1

	if self._ammo_active then
		self:_SpawnInfiniteAmmoParticle(self._ammo_element)
	end

	if self._reserve_active then
		self:_SpawnInfiniteAmmoParticle(self._reserve_element)
	end
end

function InfiniteParticles:_Init() end

return InfiniteParticles