local Players = game:GetService("Players")
local ItemInterface = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ItemInterface"))
local Charge = require(script:WaitForChild("Charge"))
local object = setmetatable({}, ItemInterface)
object.__index = object

function object.new(...)
	local self = setmetatable(ItemInterface.new(...), object)
	self.Charge = Charge.new(self)
	self:_Init()
	return self
end

function object.Destroy(p)
	p.Charge:Destroy()
	ItemInterface.Destroy(p)
end

function object:_Init() end

return object