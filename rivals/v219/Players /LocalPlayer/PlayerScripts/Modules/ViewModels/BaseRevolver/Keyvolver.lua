local Players = game:GetService("Players")
local BaseRevolver = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRevolver)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 218, 155))
local object = setmetatable({}, BaseRevolver)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRevolver.new(...), object)
	self._is_empty = nil
	self._keyvolver_bullets = {}
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_UpdateAmmoContext()
	local ammo = self.ClientItem:Get("Ammo")
	local ammoReserve = self.ClientItem:Get("AmmoReserve")

	for k, bullet in pairs(self._keyvolver_bullets.Bullets) do
		self:_LocalTransparencyModifier(bullet, "AmmoVisual", k <= ammo and 0 or 1)
	end

	for k, reloadBullet in pairs(self._keyvolver_bullets.ReloadBullets) do
		self:_LocalTransparencyModifier(reloadBullet, "AmmoVisual", ammo < k and k <= ammo + ammoReserve and 0 or 1)
	end

	local is_empty = ammo <= 0

	if is_empty == self._is_empty then
		return
	end

	self._is_empty = is_empty
	local v2 = self._is_empty and "Empty" or ""
	self:ChangeEquipAnimation("Equip" .. v2)
	self:ChangeIdleAnimation("Idle" .. v2)
	self:ChangeSprintAnimation("Sprint" .. v2)
	self:ChangeInspectAnimation("Inspect" .. v2)
end

function object:_Setup()
	for _, v in pairs({ "Bullets", "ReloadBullets" }) do
		self._keyvolver_bullets[v] = {}

		for i = 1, 6 do
			self._keyvolver_bullets[v][i] = self.ItemModel:WaitForChild(v .. i):WaitForChild("Bullet")
		end
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateAmmoContext()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoContext()
	end)
	self:_Setup()
	self:_UpdateAmmoContext()
end

return object