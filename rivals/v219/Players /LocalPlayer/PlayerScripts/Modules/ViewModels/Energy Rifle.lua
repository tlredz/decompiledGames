local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local energyBeamTracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("EnergyBeamTracerEffect")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.GetTracerTemplate(_)
	return energyBeamTracerEffect
end

function object:_Init() end

return object