local FestiveLightsCircuit = {}
FestiveLightsCircuit.__index = FestiveLightsCircuit

function FestiveLightsCircuit.new(interval, ...)
	local self = setmetatable({}, FestiveLightsCircuit)
	self._interval = interval
	self._references = { ... }
	self._connections = {}
	self._colors = {}
	self._formatted = {}
	self._next_update = 0
	self._offset = 0
	self:_Init()
	return self
end

function FestiveLightsCircuit:Update(_)
	if tick() < self._next_update then
		return
	end

	self._next_update = tick() + self._interval
	self._offset += 1

	for k, v in pairs(self._formatted) do
		v.Reference.Transparency = 1
		v.Visual.Transparency = 0
		v.Visual.Color = self._colors[(k + self._offset) % #self._colors + 1]
	end
end

function FestiveLightsCircuit:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self._references = {}
	self._formatted = {}
end

function FestiveLightsCircuit:_UpdateColors()
	self._colors = {}
	self._next_update = 0

	for _, _reference in pairs(self._references) do
		table.insert(self._colors, _reference.Color)
	end

	self:Update(0)
end

function FestiveLightsCircuit:_Setup()
	for _, _reference in pairs(self._references) do
		table.insert(self._connections, _reference:GetPropertyChangedSignal("Color"):Connect(function()
			self:_UpdateColors()
		end))
		table.insert(self._formatted, {
			Reference = _reference,
			Visual = _reference:WaitForChild("Visual")
		})
	end
end

function FestiveLightsCircuit:_Init()
	self:_Setup()
	self:_UpdateColors()
end

return FestiveLightsCircuit