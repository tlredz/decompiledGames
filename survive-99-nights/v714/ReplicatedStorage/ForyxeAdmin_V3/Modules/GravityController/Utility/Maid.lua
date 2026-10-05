local v = {
	["function"] = function(callback)
		callback()
	end,
	RBXScriptConnection = function(connection)
		connection:Disconnect()
	end,
	Instance = function(instance)
		instance:Destroy()
	end,
	table = function(instance)
		instance:Destroy()
	end
}
local Maid = {}
Maid.__index = Maid
Maid.ClassName = "Maid"

function Maid.new(...)
	local self = setmetatable({}, Maid)
	self.Trash = {}

	for _, v2 in pairs({ ... }) do
		self:Mark(v2)
	end

	return self
end

function Maid:Mark(p2)
	local typeName = typeof(p2)

	if v[typeName] then
		self.Trash[p2] = typeName
	else
		error(("Maid does not support type \"%s\""):format(typeName), 2)
	end
end

function Maid:Unmark(p2)
	if p2 then
		self.Trash[p2] = nil
	else
		self.Trash = {}
	end
end

function Maid:Sweep()
	for k, v2 in pairs(self.Trash) do
		v[v2](k)
	end

	self.Trash = {}
end

Maid.Destroy = Maid.Sweep
return Maid