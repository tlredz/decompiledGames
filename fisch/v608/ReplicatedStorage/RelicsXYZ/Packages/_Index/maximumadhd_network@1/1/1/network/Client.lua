local class = {}
class.__index = class
local parent = script.Parent
local Types = require(parent.Types)
local signal = Types.Signal

function class:Fire(...)
	self.Dispatch:Fire(...)
end

function class:On(callback)
	function self.Receiver(...)
		if pcall(self.Validator, ...) then
			callback(...)
		end
	end
end

local function newClient(id: string, validator)
	return (setmetatable({
		Id = id,
		Validator = validator,
		Receiver = nil,
		Dispatch = signal.new()
	}, class))
end

return table.freeze({
	new = newClient
})