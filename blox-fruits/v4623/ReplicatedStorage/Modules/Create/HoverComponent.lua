local class = {}
class.__index = class
local v = {
	DEFAULT = {
		Exit = Color3.fromRGB(141, 0, 2)
	},
	HOVER = {
		Exit = Color3.fromRGB(179, 0, 2)
	}
}

function class:Destroy()
	if self._Destroyed then
		return
	end

	self._Destroyed = true
	self:Disconnect()
end

function class:Connect()
	if self._Connected or self._Destroyed then
		return
	end

	self._Connected = true
	table.insert(self._Connections, self._Rbx.MouseEnter:Connect(function()
		self._Rbx.ImageColor3 = self._HoverColor
	end))
	table.insert(self._Connections, self._Rbx.MouseLeave:Connect(function()
		self._Rbx.ImageColor3 = self._DefaultColor
	end))
end

function class:Disconnect()
	if not self._Connected then
		return
	end

	self._Connected = false

	for _, _Connection in pairs(self._Connections) do
		_Connection:Disconnect()
	end

	table.clear(self._Connections)
end

return function(data)
	local defaultColor = assert(data.defaultColor, "info.defaultColor")
	local hoverColor = assert(data.hoverColor, "info.hoverColor")

	if typeof(defaultColor) == "string" then
		defaultColor = assert(v.DEFAULT[defaultColor], defaultColor)
	end

	if typeof(hoverColor) == "string" then
		hoverColor = assert(v.HOVER[hoverColor], hoverColor)
	end

	local object = setmetatable({
		_Rbx = assert(data.rbx, "bad info.rbx"),
		_Connected = false,
		_Destroyed = false,
		_Connections = {},
		_DefaultColor = defaultColor,
		_HoverColor = hoverColor
	}, class)
	object:Connect()
	return object
end