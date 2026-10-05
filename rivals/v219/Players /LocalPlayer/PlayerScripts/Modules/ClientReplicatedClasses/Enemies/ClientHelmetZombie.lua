local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local v = { "rbxassetid://95537657751620", "rbxassetid://79660414273289" }
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "DinkEffect" then
		ClientEnemy.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	Utility:CreateSound(
		v[math.random(1, #v)],
		0.625 + 0.25 * math.random(),
		1 + 0.5 * math.random(),
		object2.RootPart,
		true,
		10
	)
	Utility:PlayParticles(object2.Model:FindFirstChild("Head") and object2.Model.Head:FindFirstChild("DinkVFX"))
end

function object:_Init() end

return object