local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._hide_this_mesh = self.ItemModel:WaitForChild("Body"):WaitForChild("MeshPart")
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local v = self.ClientItem:Get("Ammo") > 0
	self._hide_this_mesh.Material = v and Enum.Material.Glass or Enum.Material.SmoothPlastic
	self:_LocalTransparencyModifier(self._hide_this_mesh, "AmmoVisual", v and 0 or 1)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	task.spawn(self._UpdateAmmoVisual, self)
end

return object