local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FunctionsController = require(Players.LocalPlayer.PlayerScripts.Controllers.FunctionsController)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.PlayHideMineSound(_, p)
	Utility:CreateSound("rbxassetid://17675605394", 1, 1.25, p.Hitbox, true, 5)
end

function object.ExplosionEffect(object2, p)
	FunctionsController:FireAsync(object2:ToEnum("NukeEffect"), p, object2.ClientItem.Info.ExplosionRadius * 3, 0.25)
end

function object:_Init() end

return object