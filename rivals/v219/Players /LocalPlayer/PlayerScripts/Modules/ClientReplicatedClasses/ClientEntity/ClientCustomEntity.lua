local Players = game:GetService("Players")
local ClientEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
local object = setmetatable({}, ClientEntity)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEntity.new(...), object)
	self:_Init()
	return self
end

function object.GetHealth(p)
	return p.Model:GetAttribute("Health")
end

function object.GetMaxHealth(p)
	return p.Model:GetAttribute("MaxHealth")
end

function object:_Init()
	self.Model:GetAttributeChangedSignal("MaxHealth"):Connect(function()
		self.HealthChanged:Fire()
	end)
	self.Model:GetAttributeChangedSignal("Health"):Connect(function()
		self.HealthChanged:Fire()
	end)
end

return object