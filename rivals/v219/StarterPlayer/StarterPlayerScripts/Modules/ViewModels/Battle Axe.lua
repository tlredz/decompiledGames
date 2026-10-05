local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc.BattleAxeSpinParticles.Attachment
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.PlaySpinParticles(p)
	local clone = attachment:Clone()
	clone.Parent = p.ClientItem.ClientFighter.Entity.RootPart
	BetterDebris:AddItem(clone, 3)
	Utility:PlayParticles(clone)

	for _, emitter in pairs(clone:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:SetAttribute("IgnoreVisibilityCheck", true)
		Utility:ScaleParticleEmitter(emitter, p.ClientItem.Info.SpinRadius / 3)
	end
end

function object:_Init() end

return object