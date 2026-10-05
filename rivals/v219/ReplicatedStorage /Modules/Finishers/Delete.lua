local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	object2:_HideBody()
end

function object:_Init() end

return object