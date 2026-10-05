local Players = game:GetService("Players")
local ClientMap = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientDuel.ClientMap)
local v = { "Museum - Day", "Museum - Dusk", "Museum - Night" }
local object = setmetatable({}, ClientMap)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientMap.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:SetReplicate("LightingProfileOverride", v[Random.new(self._seed):NextInteger(1, #v)])
end

return object