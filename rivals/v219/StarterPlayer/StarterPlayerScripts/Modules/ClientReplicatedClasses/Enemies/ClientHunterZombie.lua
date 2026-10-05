local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ExplosiveZombieExplosionEffect")
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "HunterLeapEffect" then
		ClientEnemy.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	object2:_PlayAnimation("rbxassetid://89570876299263", 0, nil, 3)
	Utility:CreateSound("rbxassetid://118467983008802", 1, 1 + 0.25 * math.random(), object2.RootPart, true, 10)
end

function object:_Init() end

return object