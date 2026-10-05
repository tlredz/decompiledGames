local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self.ReloadBulletsModel = self.ItemModel:WaitForChild("ReloadBullets")
	self.BulletsModel = self.ItemModel:WaitForChild("Bullets")
	self._bullet_parts = {}
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local ammoReserve = self.ClientItem:Get("AmmoReserve")
	local ammo = self.ClientItem:Get("Ammo")

	for k, v in pairs(self._bullet_parts.BulletsModel) do
		for _, child in pairs(v:GetChildren()) do
			self:_LocalTransparencyModifier(child, "AmmoVisual", k <= ammo and 0 or 1)
		end
	end

	for k, v in pairs(self._bullet_parts.ReloadBulletsModel) do
		for _, child in pairs(v:GetChildren()) do
			self:_LocalTransparencyModifier(child, "AmmoVisual", k <= ammoReserve and 0 or 1)
		end
	end
end

function object:_Setup()
	for _, v in pairs({ "ReloadBulletsModel", "BulletsModel" }) do
		self._bullet_parts[v] = {}

		for i = 1, 6 do
			self._bullet_parts[v][i] = self[v]:WaitForChild(i)
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
	self:_Setup()
	task.spawn(self._UpdateAmmoVisual, self)
end

return object