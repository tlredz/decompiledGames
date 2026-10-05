local Players = game:GetService("Players")
local FestiveLightsCircuit = require(Players.LocalPlayer.PlayerScripts.Modules.FestiveLightsCircuit)
local BaseChainsaw = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("BaseChainsaw"))
local object = setmetatable({}, BaseChainsaw)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseChainsaw.new(...), object)
	self._festive_lights_circuit_body = FestiveLightsCircuit.new(
		0.5,
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light1"),
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light2"),
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light3")
	)
	self._festive_lights_circuit_spin = FestiveLightsCircuit.new(
		0.1,
		self.ItemModel:WaitForChild("Spin"):WaitForChild("Light1"),
		self.ItemModel:WaitForChild("Spin"):WaitForChild("Light2"),
		self.ItemModel:WaitForChild("Spin"):WaitForChild("Light3")
	)
	self:_Init()
	return self
end

function object:Update(p2, p3, p4)
	BaseChainsaw.Update(self, p2, p3, p4)

	if not p4.IsActive then
		return
	end

	self._festive_lights_circuit_body:Update(p2)
	self._festive_lights_circuit_spin:Update(p2)
end

function object:Destroy()
	self._festive_lights_circuit_body:Destroy()
	self._festive_lights_circuit_spin:Destroy()
	BaseChainsaw.Destroy(self)
end

function object:_Init() end

return object