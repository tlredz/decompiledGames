local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Throwable = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Throwable)
local object = setmetatable({}, Throwable)
object.__index = object

function object.new(...)
	local self = setmetatable(Throwable.new(...), object)
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "MolotovExplode" then
		Throwable.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	local v = ...
	object2.ViewModel:ExplosionEffect(v, object2.Info.FireRadius)
end

function object:_Init()
	self.ProjectileThrown:Connect(function(p2, _)
		Utility:CreateSound("rbxassetid://14812827928", 1, 1, p2, true, 10)
	end)
end

return object