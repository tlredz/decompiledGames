local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local Portal = require(script:WaitForChild("Portal"))
local PortalModel = {}
PortalModel.__index = PortalModel

function PortalModel.new(model)
	local self = setmetatable({}, PortalModel)
	self.Model = model
	self.Portals = {}
	self._item_id = self.Model:GetAttribute("ItemID")
	self._user_id = self.Model:GetAttribute("UserID")
	self._teleport_cooldowns = {}
	self:_Init()
	return self
end

function PortalModel:GetPortal(p2)
	for k, portal in pairs(self.Portals) do
		if portal.Model == p2 then
			return portal, k
		end
	end
end

function PortalModel:GetOtherPortal(p2)
	return self.Portals[3 - p2.PortalNum]
end

function PortalModel:ArePortalsGrown()
	return self.Portals[1] and self.Portals[1]:IsGrown() and self.Portals[2] and self.Portals[2]:IsGrown()
end

function PortalModel:CanWarp()
	return self.Portals[1] and self.Portals[2] and (not self._user_id or self._user_id == Players.LocalPlayer.UserId)
end

function PortalModel:Update(p2)
	for _, portal in pairs(self.Portals) do
		portal:Update(p2)
	end
end

function PortalModel:Destroy()
	for _, portal in pairs(self.Portals) do
		portal:Destroy()
	end

	pcall(function()
		self.Model:Destroy()
	end)
end

function PortalModel:_Touched(p, p2)
	if not (self:CanWarp() and self:ArePortalsGrown()) then
		return
	end

	local otherPortal = self:GetOtherPortal(p)

	if not otherPortal then
		return
	end

	local assemblyRootPart = p2.AssemblyRootPart or p2

	if p2.Parent ~= Players.LocalPlayer.Character or tick() < (self._teleport_cooldowns[p.PortalNum][assemblyRootPart] or 0) or not (FighterController.LocalFighter and FighterController.LocalFighter:IsAlive()) then
		return
	end

	local raycastWhitelist = GameplayUtility:GetRaycastWhitelist(Players.LocalPlayer:GetAttribute("EnvironmentID"))
	local raycastResult = Utility:Raycast(
		p.Hitbox.Position,
		assemblyRootPart.Position,
		(p.Hitbox.Position - assemblyRootPart.Position).Magnitude,
		raycastWhitelist,
		Enum.RaycastFilterType.Include
	)

	if raycastResult.Instance and not raycastResult.Instance:IsDescendantOf(assemblyRootPart.Parent) then
		return
	end

	self._teleport_cooldowns[p.PortalNum][assemblyRootPart] = tick() + 0.25
	self._teleport_cooldowns[otherPortal.PortalNum][assemblyRootPart] = tick() + 1
	FighterController.LocalFighter.Entity:WarpTo(otherPortal:GetTeleportCFrame())
	Utility:CreateSound("rbxassetid://86785771664692", 0.5, 1 + 0.1 * math.random(), p.Hitbox.Position, true, 10)
	Utility:CreateSound(
		"rbxassetid://81610952487049",
		1,
		1 + 0.1 * math.random(),
		otherPortal.Hitbox.Position,
		true,
		10
	)
	ReplicatedStorage.Remotes.Replication.Fighter.PlayMechanicsSound:FireServer("Warp")
	ReplicatedStorage.Remotes.Replication.Fighter.JustWarped:FireServer(self._item_id, p.PortalNum)
end

function PortalModel:_UpdateVisuals()
	local canWarp = self:CanWarp()

	for _, portal in pairs(self.Portals) do
		portal:UpdateVisuals(canWarp)
	end
end

function PortalModel:_ChildRemoved(p)
	local portal, v = self:GetPortal(p)

	if not portal then
		return
	end

	portal:Destroy()
	self.Portals[v] = nil
	self:_UpdateVisuals()
end

function PortalModel:_ChildAdded(model)
	if not model:IsA("Model") then
		return
	end

	self:_ChildRemoved(model)
	local v = Portal.new(model)
	self.Portals[v.PortalNum] = v
	self:_UpdateVisuals()
	self._teleport_cooldowns[v.PortalNum] = {}
	v.Hitbox.Touched:Connect(function(otherPart)
		self:_Touched(v, otherPart)
	end)

	local function check_now()
		for _, part in pairs(Players.LocalPlayer.Character and Players.LocalPlayer.Character:GetChildren() or {}) do
			if not part:IsA("BasePart") then
				continue
			end

			if not Utility:IsWithinPart(
				v.Hitbox,
				part.Position,
				createVector(1, 1, 1) * math.max(part.Size.X, part.Size.Y, part.Size.Z) * 1.4142135623730951
			) then
				continue
			end

			self:_Touched(v, part)
			break
		end
	end

	v.FinishedGrowing:Connect(check_now)
	check_now()
end

function PortalModel:_Init()
	self.Model.ChildAdded:Connect(function(child)
		self:_ChildAdded(child)
	end)
	self.Model.ChildRemoved:Connect(function(child)
		self:_ChildRemoved(child)
	end)
end

return PortalModel