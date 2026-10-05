local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._registered_ammo_visuals = {
		Bullets = {},
		ReloadBullets = {}
	}
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local v = self:IsAnimationPlaying("Reload") or self:IsAnimationPlaying("EmptyReload")
	local ammoReserve = self.ClientItem:Get("AmmoReserve")
	local ammo = self.ClientItem:Get("Ammo")
	local v2 = ammoReserve + ammo

	for k, bullet in pairs(self._registered_ammo_visuals.Bullets) do
		local v4

		if v then
			v4 = k <= v2 and 0 or 1
		else
			v4 = k <= ammo and 0 or 1
		end

		self:_LocalTransparencyModifier(bullet, "AmmoVisual", v4)
	end

	for k, reloadBullet in pairs(self._registered_ammo_visuals.ReloadBullets) do
		self:_LocalTransparencyModifier(reloadBullet, "AmmoVisual", k <= ammo and 0 or 1)
	end
end

function object:_RegisterAmmoVisual(p2, p3)
	table.insert(self._registered_ammo_visuals[p2], p3)
end

function object:_RegisterDefaultAmmoVisuals()
	for _, childName in pairs({ "ReloadBullets", "Bullets" }) do
		local child = self.ItemModel:WaitForChild(childName)

		for i = 1, 6 do
			self:_RegisterAmmoVisual(childName, child:WaitForChild(i))
		end
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.AnimationPlayed:Connect(function(p)
		if p == "Reload" or p == "EmptyReload" then
			self:_UpdateAmmoVisual()
		end
	end)
	self.AnimationStopped:Connect(function(p)
		if p == "Reload" or p == "EmptyReload" then
			self:_UpdateAmmoVisual()
		end
	end)
	task.defer(self._UpdateAmmoVisual, self)
end

return object