local Players = game:GetService("Players")
local ViewModelParticlesLogic = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModelParticlesLogic)
local Katana = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Katana)
local object = setmetatable({}, Katana)
object.__index = object

function object.new(...)
	local self = setmetatable(Katana.new(...), object)
	self._particles_logic = ViewModelParticlesLogic.new(self)
	self:_Init()
	return self
end

function object.PlayDeflectHitSounds(object2)
	object2:CreateSound("rbxassetid://14776414133", 1.25, 1.5 + 0.5 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://14776437962", 1, 0.9 + 0.2 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://82797934287631", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object:Unequip(...)
	self._particles_logic:CancelEffect()
	Katana.Unequip(self, ...)
end

function object:Destroy()
	self._particles_logic:Destroy()
	Katana.Destroy(self)
end

function object:_Init()
	self.Equipped:Connect(function(p2)
		self._particles_logic:PlayEffect(0, p2 and 0 or 0.5)
	end)
end

return object