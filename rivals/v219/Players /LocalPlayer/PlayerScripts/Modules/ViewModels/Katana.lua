local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("WrapController"))
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local deflectActiveEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.DeflectActiveEffects
local deflectHitEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.DeflectHitEffects
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._deflect_hit_attachment = nil
	self._deflect_active_attachment = nil
	self._deflect_active_attachment_not_local = nil
	self:_Init()
	return self
end

function object:PlayDeflectActiveParticles()
	Utility:PlayParticles(self._deflect_active_attachment)

	if not self.ClientItem.ClientFighter:Get("IsSpectating") then
		local _deflect_active_attachment_not_local = self._deflect_active_attachment_not_local
		local parent

		if self.ClientItem.ClientFighter.Entity then
			parent = self.ClientItem.ClientFighter.Entity.RootPart or nil
		end

		_deflect_active_attachment_not_local.Parent = parent
		Utility:PlayParticles(self._deflect_active_attachment_not_local)
	end
end

function object:PlayDeflectHitParticles()
	Utility:PlayParticles(self._deflect_hit_attachment)
end

function object.PlayDeflectHitSounds(object2)
	object2:CreateSound("rbxassetid://14776414133", 1.25, 1.5 + 0.5 * math.random(), true, 5)
	object2:CreateSound("rbxassetid://14776437962", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object:ClearDeflectActiveParticles()
	for _, emitter in pairs(self._deflect_active_attachment_not_local:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Clear()
		end
	end
end

function object:Destroy()
	self._deflect_active_attachment_not_local:Destroy()
	ClientViewModel.Destroy(self)
end

function object:_Setup()
	self._deflect_hit_attachment = self.ItemModel:FindFirstChild("_katana_deflect_hit", true)
	self._deflect_active_attachment = self.ItemModel:FindFirstChild("_katana_deflect_active", true)
	local clones = {}

	if self._deflect_hit_attachment then
		for _, child in pairs((deflectHitEffects:FindFirstChild(self.Name) or deflectHitEffects.Default).Attachment:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = self._deflect_hit_attachment
			table.insert(clones, clone)
		end
	end

	if self._deflect_active_attachment then
		local v = deflectActiveEffects:FindFirstChild(self.Name) or deflectActiveEffects.Default

		for _, child in pairs(v.Attachment:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = self._deflect_active_attachment
			table.insert(clones, clone)
		end

		self._deflect_active_attachment_not_local = Instance.new("Attachment")
		self._deflect_active_attachment_not_local.Name = "_katana_deflect_active_not_local"

		for _, child in pairs(v.NotLocal:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = self._deflect_active_attachment_not_local
			table.insert(clones, clone)
		end
	end

	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clones), self.ClientItem:GetWrap(), true)
end

function object:_Init()
	self:_Setup()
end

return object