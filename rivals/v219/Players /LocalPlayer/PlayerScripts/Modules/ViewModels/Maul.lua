local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local maulSlamParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.MaulSlamParticles
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.SlamSoundEffect(_, p, _)
	Utility:CreateSound("rbxassetid://72483809453170", 1 + 0.25 * math.random(), 0.9 + 0.2 * math.random(), p, true, 10)
	Utility:CreateSound(
		"rbxassetid://129922197154277",
		1 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
end

function object.SlamEffect(_, position, p)
	local clone = maulSlamParticles:Clone()
	clone.CFrame = CFrame.new(position) + createVector(0, 0.1, 0)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 10)
	Utility:ScaleParticleEmitter(clone, p / 32)
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object