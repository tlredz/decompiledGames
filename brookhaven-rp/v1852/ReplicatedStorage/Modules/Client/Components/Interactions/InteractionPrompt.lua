local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local PropertyObjectUtil = require(ReplicatedStorage.Modules.Shared.Housing.Objects.PropertyObjectUtil)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local v = Component.new({
	Tag = "InteractionPrompt"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"PropertyPermissions",
		PropertyPermissions
	)
	self._enabled = true
	self.Interacted = self._Janitor:Add(Signal.new())
end

function v:Interact(p: number?)
	if not self:HasPermission() then
		return
	end

	self.Interacted:Fire(p)
end

function v:SetEnabled(enabled: boolean)
	self._enabled = enabled
end

function v:HasPermission()
	if not (self._enabled and self.Instance:GetAttribute("InteractionDisabled") ~= true) then
		return false
	end

	if (self.Instance:IsA("VehicleSeat") or self.Instance:IsA("Seat")) and self.Instance.Disabled then
		return false
	end

	if not self._propertyPermissions or (self.Instance:IsA("Seat") or self.Instance:IsA("VehicleSeat")) and self.Instance:GetAttribute("ActivateRPAnimOnSit") then
		return true
	end

	if self.Instance:GetAttribute("RequirePermissions") == false then
		return true
	end

	return PropertyObjectUtil.HasPermissionAndIsCloseEnough(
		Players.LocalPlayer,
		self.Instance,
		37,
		self._propertyPermissions,
		{ "Owner", "Roommate" }
	)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v