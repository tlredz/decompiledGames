local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local BaseRPG = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRPG)
local object = setmetatable({}, BaseRPG)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRPG.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, blastRadius)
	local explosion = Instance.new("Explosion")
	explosion.BlastRadius = blastRadius
	explosion.BlastPressure = 0
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.Position = position
	explosion.Parent = workspace
	BetterDebris:AddItem(explosion, 5)
	Utility:CreateSound("rbxasset://sounds/collide.wav", 0.5, 0.9 + 0.2 * math.random(), position, true, 10)
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileShot:Connect(function(_, object3)
			local sound = Utility:CreateSound("rbxasset://sounds/Rocket whoosh 01.wav", 0.5, 1, object3.Part, true)
			object3:GetAttributeChangedSignal("Destroying"):Wait()
			sound:Destroy()
		end)
	end)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Part"))
end

return object