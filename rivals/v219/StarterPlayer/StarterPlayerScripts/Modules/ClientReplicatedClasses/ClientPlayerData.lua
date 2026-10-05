local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedClass = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ReplicatedClass"))
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(p)
	local self = setmetatable(ReplicatedClass.new(p, true), object)
	self:_Init()
	return self
end

function object:_Init() end

return object