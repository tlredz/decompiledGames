local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local BaseSatchel = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSatchel)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("PizzaExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, BaseSatchel)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSatchel.new(...), object)
	self._registered_ammo_visuals = {}
	self._charm_attachment_parent = self._charm_pivot_attachment and self._charm_pivot_attachment.Parent
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 0.4, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://74472565321499", 1.2, 1 + 0.2 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 8)
		end
	end

	clone.PointLight.Range = p * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	for k, _registered_ammo_visual in pairs(self._registered_ammo_visuals) do
		local v = _registered_ammo_visual <= self.ClientItem:Get("Ammo")
		self:_LocalTransparencyModifier(k, "AmmoVisual", v and 0 or 1)

		if not (_registered_ammo_visual == 1 and self._charm_pivot_attachment) then
			continue
		end

		local _charm_pivot_attachment = self._charm_pivot_attachment
		local parent

		if v then
			parent = self._charm_attachment_parent or nil
		end

		_charm_pivot_attachment.Parent = parent
	end
end

function object:_RegisterAmmoVisual(p2, p3)
	self._registered_ammo_visuals[p2] = p3
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 1"):WaitForChild("MeshPart1"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 1"):WaitForChild("MeshPart2"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 1"):WaitForChild("MeshPart3"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 1"):WaitForChild("MeshPart4"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 2"):WaitForChild("MeshPart1"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 2"):WaitForChild("MeshPart2"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 2"):WaitForChild("MeshPart3"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 2"):WaitForChild("MeshPart4"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 3"):WaitForChild("MeshPart1"), 3)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 3"):WaitForChild("MeshPart2"), 3)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 3"):WaitForChild("MeshPart3"), 3)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Slice 3"):WaitForChild("MeshPart4"), 3)
end

return object