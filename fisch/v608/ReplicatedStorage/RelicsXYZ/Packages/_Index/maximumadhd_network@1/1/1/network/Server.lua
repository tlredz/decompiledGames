local class = {}
class.__index = class
local parent = script.Parent
local Players = game:GetService("Players")
local Types = require(parent.Types)
local signal = Types.Signal

function class:Fire(p2, ...)
	self.Dispatch:Fire(p2, ...)
end

function class.FireAll(p, ...)
	for _, v in Players:GetPlayers() do
		p.Dispatch:Fire(v, ...)
	end
end

function class.FireAllExcept(p, p2, ...)
	for _, v in Players:GetPlayers() do
		if v ~= p2 then
			p.Dispatch:Fire(v, ...)
		end
	end
end

function class.FireList(p, items, ...)
	for _, item in items do
		p.Dispatch:Fire(item, ...)
	end
end

function class.FireWithFilter(p, callback, ...)
	for _, v in Players:GetPlayers() do
		if callback(v) then
			p.Dispatch:Fire(v, ...)
		end
	end
end

function class:On(callback)
	function self.Receiver(p2, ...)
		if pcall(self.Validator, ...) then
			callback(p2, ...)
		end
	end
end

local function newServer(id: string, validator)
	return (setmetatable({
		Id = id,
		Validator = validator,
		Receiver = nil,
		Dispatch = signal.new()
	}, class))
end

return table.freeze({
	new = newServer
})