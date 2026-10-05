local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self:_Init()
	return self
end

function object.StartAiming(_)
	return false
end

function object.FinishAiming(_)
	return false
end

function object:ReplicateFromServer(p, ...)
	if p == "TransformProjectile" then
		if not self:IsRendered() then
			return
		end

		local v = ...
		self.ViewModel:TransformProjectile(v, self._projectile_part_to_model[v])
	else
		if p ~= "MiniExplosionEffect" then
			Gun.ReplicateFromServer(self, p, ...)
			return
		end

		if not self:IsRendered() then
			return
		end

		local v = ...
		v:Destroy()
		self.ViewModel:PlayCastParticles(v.Position, 2)
	end
end

function object:_Init() end

return object