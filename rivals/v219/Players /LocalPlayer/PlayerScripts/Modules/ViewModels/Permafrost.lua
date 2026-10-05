local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local freezeRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("FreezeRayExplosionEffect")
local colorSequence = ColorSequence.new(Color3.fromRGB(30, 225, 255))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._gauge_tickers = {}
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(_, position, p)
	local clone = freezeRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://18429092842", 0.4, 1 + 0.2 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 4)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_UpdateGaugeTickers()
	local rotation = -45 - 270 * (1 - self.ClientItem:Get("Ammo") / self.ClientItem.Info.MaxAmmo)

	for _, _gauge_ticker in pairs(self._gauge_tickers) do
		_gauge_ticker.Rotation = rotation
	end
end

function object:_Setup()
	for _, descendant in pairs(self.ItemModel:GetDescendants()) do
		if descendant:HasTag("PermafrostGaugeTicker") then
			table.insert(self._gauge_tickers, descendant)
		end
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("MaxAmmo"):Connect(function()
		self:_UpdateGaugeTickers()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateGaugeTickers()
	end)
	self:_Setup()
	self:_UpdateGaugeTickers()
end

return object