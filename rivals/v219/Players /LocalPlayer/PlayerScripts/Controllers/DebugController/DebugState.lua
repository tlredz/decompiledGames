local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedClass.new(), object)
	self.Data.AreHandicapsEnabled = false
	self.Data.DisableTransparentHats = false
	self:_Init()
	return self
end

function object:_Init() end

return object._new()