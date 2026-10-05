local Players = game:GetService("Players")
local FestiveLightsCircuit = require(Players.LocalPlayer.PlayerScripts.Modules.FestiveLightsCircuit)
local Fists = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Fists)
local object = setmetatable({}, Fists)
object.__index = object

function object.new(...)
	local self = setmetatable(Fists.new(...), object)
	self._festive_lights_circuits = {}
	self:_Init()
	return self
end

function object:Update(p2, p3, p4)
	Fists.Update(self, p2, p3, p4)

	if not p4.IsActive then
		return
	end

	for _, _festive_lights_circuit in pairs(self._festive_lights_circuits) do
		_festive_lights_circuit:Update(p2)
	end
end

function object:Destroy()
	for _, _festive_lights_circuit in pairs(self._festive_lights_circuits) do
		_festive_lights_circuit:Destroy()
	end

	Fists.Destroy(self)
end

function object:_Setup()
	for k in pairs(self._arm_submodels) do
		table.insert(
			self._festive_lights_circuits,
			FestiveLightsCircuit.new(0.5, k:WaitForChild("Light1"), k:WaitForChild("Light2"), k:WaitForChild("Light3"))
		)
	end
end

function object:_Init()
	self:_Setup()
end

return object