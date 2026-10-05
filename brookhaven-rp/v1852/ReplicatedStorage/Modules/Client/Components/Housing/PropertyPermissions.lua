local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
local v = nil
local v2 = Component.new({
	Tag = "PropertyPermissions"
})
local color = Color3.fromRGB(4, 175, 236)

function v2:Construct()
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	v = LotUtil
	self._Janitor = Janitor.new()
	self.lotRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "LotRoot", LotRoot)
	self.propertyRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "PropertyRoot", PropertyRoot)
end

function v2:Start()
	local mainHouseScript = self.Instance:FindFirstChild("MainHouseScript")

	if mainHouseScript then
		self.permissionsFolder = mainHouseScript:WaitForChild("PermissionPlayers", 10)
	else
		self.permissionsFolder = self.Instance:WaitForChild("PermissionPlayers", 10)
	end

	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Permissions:Disallow", function()
		self:Disallow()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Permissions:SoftDisallow", function()
		self:SoftDisallow()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Permissions:Allow", function()
		self:Allow()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Permissions:SoftAllow", function()
		self:SoftAllow()
	end))
end

function v2:Stop()
	self._Janitor:Destroy()
end

function v2.TryAddRoommate(p, p2)
	Remotes.fireServerComponent(p.Instance, "Permissions:AddRoommate", p2)
end

function v2.TryRemoveRoommate(p, p2)
	Remotes.fireServerComponent(p.Instance, "Permissions:RemoveRoommate", p2)
end

function v2.TryDisallow(p, p2)
	Remotes.fireServerComponent(p.Instance, "Permissions:Disallow", p2)
end

function v2.TryAllow(p, p2)
	Remotes.fireServerComponent(p.Instance, "Permissions:Allow", p2)
end

function v2.TrySetPropPlacementBlockedForOthers(p, flag: boolean)
	return Remotes.invokeServerComponent(p.Instance, "Permissions:SetPropPlacementBlockedForOthers", flag)
end

function v2.IsPropPlacementBlockedForOthers(p)
	return Remotes.invokeServerComponent(p.Instance, "Permissions:IsPropPlacementBlockedForOthers")
end

function v2.IsDisallowed(p, p2)
	return Remotes.invokeServerComponent(p.Instance, "Permissions:IsDisallowed", p2)
end

function v2.ClearProps(p, p2)
	return Remotes.invokeServerComponent(p.Instance, "Permissions:ClearProps", p2)
end

function v2:GetRoles(p2)
	if self.propertyRoot:GetOwner() == p2 then
		return { "Owner" }
	end

	local child = self.permissionsFolder:FindFirstChild(p2.Name)

	if child == nil then
		return nil
	end

	return string.split(child.Value, ",")
end

function v2:HasRole(p, p2: string)
	local roles = self:GetRoles(p)
	return roles ~= nil and table.find(roles, p2) ~= nil
end

function v2:HasAnyRole(p, ...)
	local roles = self:GetRoles(p)

	if roles == nil then
		return false
	end

	for _, v3 in { ... } do
		if table.find(roles, v3) ~= nil then
			return true
		end
	end

	return false
end

function v2:Disallow()
	if self.Instance:FindFirstChild("BannedBlock") ~= nil then
		return
	end

	self:SoftAllow()
	local bannedBlock = v.GetBannedBlock(self.lotRoot:GetId())

	if bannedBlock == nil then
		warn("No block found for lot " .. self.lotRoot:GetId())
		return
	end

	local clone = bannedBlock:Clone()
	clone.Name = "BannedBlock"
	clone.Parent = self.Instance
end

function v2:SoftDisallow()
	if self.Instance:FindFirstChild("SoftBannedBlock") ~= nil then
		return
	end

	local bannedBlock = v.GetBannedBlock(self.lotRoot:GetId())

	if bannedBlock == nil then
		warn("No block found for lot " .. self.lotRoot:GetId())
		return
	end

	local clone = bannedBlock:Clone()
	clone.Name = "SoftBannedBlock"
	local basePart = clone:FindFirstChildWhichIsA("BasePart")

	if basePart then
		basePart.Color = color
	end

	clone.Parent = self.Instance
end

function v2:Allow()
	local bannedBlock = self.Instance:FindFirstChild("BannedBlock")

	if bannedBlock == nil then
		return
	end

	bannedBlock:Destroy()
end

function v2:SoftAllow()
	local softBannedBlock = self.Instance:FindFirstChild("SoftBannedBlock")

	if softBannedBlock == nil then
		return
	end

	softBannedBlock:Destroy()
end

return v2