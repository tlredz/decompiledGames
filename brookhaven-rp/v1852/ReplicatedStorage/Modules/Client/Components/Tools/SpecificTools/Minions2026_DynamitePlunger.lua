local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "Minions2026_DynamitePlunger",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._Janitor:Add(self._equipJanitor)
	self._lastPlungerClick = 0
end

function v:_IsLocallyOwned()
	local parent = self.Instance.Parent
	return parent ~= nil and Players:GetPlayerFromCharacter(parent) == Players.LocalPlayer
end

function v:_TryPlaceDynamite()
	if self.Instance:GetAttribute("DynamitePlaced") == true then
		return
	end

	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local mouse = Players.LocalPlayer:GetMouse()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Instance, character }
	raycastParams.RespectCanCollide = true
	local origin = mouse.UnitRay.Origin
	local v2 = mouse.UnitRay.Direction * 40
	local raycastResult = workspace:Raycast(origin, v2, raycastParams)

	if raycastResult == nil then
		return
	end

	Remotes.fireServerComponent(self.Instance, "PlaceDynamite", raycastResult.Position)
end

function v:Detonate()
	local now = os.clock()

	if now - self._lastPlungerClick < 0.5 then
		return
	end

	self._lastPlungerClick = now

	if self.Instance:GetAttribute("DynamitePlaced") ~= true then
		return
	end

	Remotes.fireServerComponent(self.Instance, "Detonate")
end

function v:_OnEquipped()
	self._equipJanitor:Cleanup()

	if not self:_IsLocallyOwned() then
		return
	end

	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		self:_TryPlaceDynamite()
	end))
end

function v:_OnUnequipped()
	self._equipJanitor:Cleanup()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:_OnEquipped()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:_OnUnequipped()
	end))

	if instance.Parent ~= nil and Players:GetPlayerFromCharacter(instance.Parent) == Players.LocalPlayer then
		self:_OnEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v