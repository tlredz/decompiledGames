local Players = game:GetService("Players")
local FestiveLightsCircuit = require(Players.LocalPlayer.PlayerScripts.Modules.FestiveLightsCircuit)
local Exogun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Exogun)
local midnightFestiveExogunExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("MidnightFestiveExogunExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(22, 5, 255))
local object = setmetatable({}, Exogun)
object.__index = object

function object.new(...)
	local self = setmetatable(Exogun.new(...), object)
	self._festive_lights_circuit = FestiveLightsCircuit.new(
		0.5,
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light1"),
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light2"),
		self.ItemModel:WaitForChild("Body"):WaitForChild("Light3")
	)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(p, p2, p3)
	Exogun.ExplosionEffect(p, p2, p3, midnightFestiveExogunExplosionParticles)
end

function object:Update(p2, p3, p4)
	Exogun.Update(self, p2, p3, p4)

	if not p4.IsActive then
		return
	end

	self._festive_lights_circuit:Update(p2)
end

function object:Destroy()
	self._festive_lights_circuit:Destroy()
	Exogun.Destroy(self)
end

function object:_Init() end

return object