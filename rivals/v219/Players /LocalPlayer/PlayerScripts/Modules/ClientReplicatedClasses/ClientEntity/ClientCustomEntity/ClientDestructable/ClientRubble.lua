local Players = game:GetService("Players")
local ClientDestructable = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientCustomEntity.ClientDestructable)
local object = setmetatable({}, ClientDestructable)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientDestructable.new(...), object)
	self.PlayRubbleEffectOnDeath = true
	self:_Init()
	return self
end

function object:_Init() end

return object