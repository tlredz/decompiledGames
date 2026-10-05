local Players = game:GetService("Players")
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self.AimAssistBlacklist = true
	self:_Init()
	return self
end

function object:_Init() end

return object