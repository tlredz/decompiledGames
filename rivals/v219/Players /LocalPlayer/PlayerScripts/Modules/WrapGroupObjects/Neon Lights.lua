local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self:_Init()
	return self
end

function object.Update(p, _)
	local offsetStudsV = math.floor(tick() * 10) * 0.027 % 0.25

	for _, extraObject in pairs(p.ExtraObjects) do
		extraObject.OffsetStudsV = offsetStudsV
	end
end

function object:_Init() end

return object