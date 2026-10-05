local Players = game:GetService("Players")
local ClientItem = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
local object = setmetatable({}, ClientItem)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientItem.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object