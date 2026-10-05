local Players = game:GetService("Players")
local ItemInterface = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ItemInterface"))
local ScopeModifier = require(script:WaitForChild("ScopeModifier"))
local object = setmetatable({}, ItemInterface)
object.__index = object

function object.new(...)
	local self = setmetatable(ItemInterface.new(...), object)
	self.ScopeModifier = ScopeModifier.new(self)
	self:_Init()
	return self
end

function object.Unequip(p, ...)
	p.ScopeModifier:Refresh()
	ItemInterface.Unequip(p, ...)
end

function object.Destroy(p)
	p.ScopeModifier:Destroy()
	ItemInterface.Destroy(p)
end

function object:_Init() end

return object