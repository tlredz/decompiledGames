local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FunctionsController = require(Players.LocalPlayer.PlayerScripts.Controllers.FunctionsController)
local Grenade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grenade)
local object = setmetatable({}, Grenade)
object.__index = object

function object.new(...)
	local self = setmetatable(Grenade.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(object2, p, p2)
	Utility:CreateSound("rbxassetid://99261833097954", 0.5, 0.9 + 0.2 * math.random(), p, true, 10)
	FunctionsController:FireAsync(object2:ToEnum("ExplosionEffect"), p, p2)
end

function object:_Init() end

return object