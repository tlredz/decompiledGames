local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local subspaceTripmineExplosion = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("SubspaceTripmineExplosion")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.PlayHideMineSound(_, p)
	Utility:CreateSound("rbxassetid://11956590", 1, 1, p.Hitbox, true, 5)
end

function object.ExplosionEffect(p, position)
	Utility:CreateSound("rbxassetid://11984351", 0.5, 1, position, true, 10)
	Utility:CreateSound("rbxassetid://11984254", 1, 0.75, position, true, 10)
	local clone = subspaceTripmineExplosion:Clone()
	clone.CFrame = CFrame.new(position)
	clone.PointLight.Range = p.ClientItem.Info.ExplosionRadius * 3
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	wait(1)
	clone.Sparkles.Enabled = false
	local pointLight = clone.PointLight
	Utility:RenderstepForLoop(0, 100, 1, function(p2)
		pointLight.Brightness = 40 * (1 - (p2 / 100) ^ 4)
	end)
end

function object:_Init() end

return object