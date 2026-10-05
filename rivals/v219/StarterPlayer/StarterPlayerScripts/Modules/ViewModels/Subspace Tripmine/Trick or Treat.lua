local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
local FunctionsController = require(Players.LocalPlayer.PlayerScripts.Controllers.FunctionsController)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(object2, p)
	for i = 1, 3 do
		local v = p + Vector3.new(10 * (math.random() - 0.5), i ^ 2, 10 * (math.random() - 0.5))
		local v2 = object2.ClientItem.Info.ExplosionRadius * (1 + 1 * math.random())
		FunctionsController:FireAsync(object2:ToEnum("ExplosionEffect"), v, v2, (i - 1) * 0.25 + 1)
		wait(0.1)
	end
end

function object:_Init() end

return object