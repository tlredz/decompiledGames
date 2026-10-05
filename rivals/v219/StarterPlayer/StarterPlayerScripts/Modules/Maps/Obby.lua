local Players = game:GetService("Players")
local ClientMap = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientDuel.ClientMap)
local object = setmetatable({}, ClientMap)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientMap.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self.ClientDuel:SetReplicate("DuelMusic", "Obby")
end

return object