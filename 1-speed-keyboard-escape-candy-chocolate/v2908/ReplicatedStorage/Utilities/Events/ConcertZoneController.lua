local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GravityManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GravityManager"))
local JumpHeightManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("JumpHeightManager"))
local ConcertSharedConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ConcertSharedConfig"))
local ConcertZoneController = {}
ConcertZoneController.__index = ConcertZoneController

function ConcertZoneController.new()
	local self = setmetatable({}, ConcertZoneController)
	self._zonePart = nil
	self._gravityPart = nil
	self._player = Players.LocalPlayer
	self._isInsideZone = false
	self._isInsideGravityZone = false
	self._originalTimeOfDay = Lighting.TimeOfDay
	self._originalGravity = Workspace.Gravity
	self._originalJumpHeight = nil
	self._originalJumpPower = nil
	self._boundHumanoid = nil
	self._activeEffects = {
		NoGravity = false,
		Spinning = false,
		ChickenParty = false,
		FastDay = false
	}
	self._chickenCostume = nil
	self._lastCharacter = nil
	self._checkTimer = 0
	return self
end

function ConcertZoneController:scan(parent)
	if not parent then
		return
	end

	if parent.Parent and parent.Parent:IsA("Model") then
		parent = parent.Parent
	end

	local zonePart = nil
	local gravityPart = nil

	for _, part in ipairs(parent:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "ConcertZone" then
			zonePart = part
		elseif part.Name == "GravityPart" then
			gravityPart = part
		end
	end

	if not zonePart then
		warn("[ConcertZoneController] Missing part 'ConcertZone' in scene. Env overrides will be disabled.")
	end

	self._zonePart = zonePart
	self._gravityPart = gravityPart
	self._originalTimeOfDay = Lighting.TimeOfDay
	self._originalGravity = Workspace.Gravity
end

function ConcertZoneController:_isCharacterInZone(instance)
	if not (self._zonePart and instance) then
		return false
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local pointToObjectSpace = self._zonePart.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	local halfSize = self._zonePart.Size / 2
	local v2 = math.abs(pointToObjectSpace.X) <= halfSize.X
	local v3 = math.abs(pointToObjectSpace.Y) <= halfSize.Y + 10
	local v4 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
	return v2 and v3 and v4
end

function ConcertZoneController:_updateAllPlayerChickenOutfits()
	for _, v in ipairs(Players:GetPlayers()) do
		local character = v.Character

		if not character then
			continue
		end

		local _isCharacterInZone = self:_isCharacterInZone(character)

		if self._activeEffects.ChickenParty and _isCharacterInZone then
			if not character:FindFirstChild("ChickenOutfit_Temp") then
				self:_restoreOriginalBody(character)
				local _attachCostume = self:_attachCostume(character)

				if _attachCostume then
					self:_hideOriginalBody(character, _attachCostume)
				end
			end
		else
			local chickenOutfit_Temp = character:FindFirstChild("ChickenOutfit_Temp")

			if chickenOutfit_Temp then
				chickenOutfit_Temp:Destroy()
				self:_restoreOriginalBody(character)
			end
		end
	end
end

function ConcertZoneController:_checkPlayerInZone()
	return self:_isCharacterInZone(self._player.Character)
end

function ConcertZoneController:update(p: number)
	if not (self._zonePart or self._gravityPart) then
		return
	end

	self._checkTimer += p

	if self._checkTimer >= 0.25 then
		self._checkTimer = 0
		local character = self._player.Character
		local v = character ~= self._lastCharacter
		self._lastCharacter = character
		local _checkPlayerInZone = self:_checkPlayerInZone()

		if _checkPlayerInZone ~= self._isInsideZone or v then
			self._isInsideZone = _checkPlayerInZone

			if self._isInsideZone then
				self:_onEnterZone()
			else
				self:_onExitZone()
			end
		end

		self._isInsideGravityZone = self:_checkPlayerInGravityPart()
		local concertState = Workspace:FindFirstChild("ConcertState")
		local v2 = {
			NoGravity = false,
			Spinning = false,
			ChickenParty = false,
			FastDay = false
		}

		if concertState then
			for childName in pairs(v2) do
				local boolValue = concertState:FindFirstChild(childName)

				if boolValue and boolValue:IsA("BoolValue") then
					v2[childName] = boolValue.Value
				end
			end
		end

		local v3 = {
			NoGravity = self._isInsideGravityZone and v2.NoGravity,
			Spinning = self._isInsideZone and v2.Spinning,
			ChickenParty = self._isInsideZone and v2.ChickenParty,
			FastDay = self._isInsideZone and v2.FastDay
		}

		if v then
			self._activeEffects.NoGravity = nil
			self._activeEffects.ChickenParty = nil
			self._boundHumanoid = nil
		end

		self:_reconcileEffects(v3)
		self:_updateAllPlayerChickenOutfits()
	end

	self:_runFrameEffects(p)
end

function ConcertZoneController:_onEnterZone()
	self._originalTimeOfDay = Lighting.TimeOfDay
	Lighting.TimeOfDay = "00:00:00"
end

function ConcertZoneController:_onExitZone()
	Lighting.TimeOfDay = self._originalTimeOfDay
end

function ConcertZoneController:_checkPlayerInGravityPart()
	local _gravityPart = self._gravityPart or self._zonePart

	if not _gravityPart then
		return false
	end

	local character = self._player.Character

	if not character then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local pointToObjectSpace = _gravityPart.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	local halfSize = _gravityPart.Size / 2
	local v2 = math.abs(pointToObjectSpace.X) <= halfSize.X
	local v3 = _gravityPart == self._gravityPart and 0 or 10
	local v4 = math.abs(pointToObjectSpace.Y) <= halfSize.Y + v3
	local v5 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
	return v2 and v4 and v5
end

function ConcertZoneController:_restoreOriginalBody(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		local chickenOldTransparency = descendant:GetAttribute("ChickenOldTransparency")

		if chickenOldTransparency == nil then
			continue
		end

		descendant.Transparency = chickenOldTransparency
		descendant:SetAttribute("ChickenOldTransparency", nil)
	end
end

function ConcertZoneController:_hideOriginalBody(folder, ancestor)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) or ancestor and descendant:IsDescendantOf(ancestor) then
			continue
		end

		if descendant:GetAttribute("ChickenOldTransparency") == nil then
			descendant:SetAttribute("ChickenOldTransparency", descendant.Transparency)
		end

		descendant.Transparency = 1
	end
end

function ConcertZoneController:_getFootPart(instance)
	return instance:FindFirstChild("LeftFoot", true) or instance:FindFirstChild("RightFoot", true) or instance:FindFirstChild(
		"LeftLowerLeg",
		true
	) or instance:FindFirstChild("RightLowerLeg", true) or instance:FindFirstChild("Left Leg", true) or instance:FindFirstChild(
		"Right Leg",
		true
	)
end

function ConcertZoneController:_attachCostume(parent)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local chickenCostume = ReplicatedStorage:FindFirstChild("ChickenCostume")

	if not (chickenCostume and humanoidRootPart) then
		return nil
	end

	local clone = chickenCostume:Clone()
	clone.Name = "ChickenOutfit_Temp"
	clone.Parent = parent
	local basePart = clone:FindFirstChildWhichIsA("BasePart")

	if not basePart then
		return nil
	end

	basePart.Anchored = false
	basePart.CanCollide = false
	basePart.Massless = true
	local position = (self:_getFootPart(parent) or humanoidRootPart).Position
	basePart.CFrame = humanoidRootPart.CFrame
	local v = basePart.Position.Y - basePart.Size.Y / 2
	local v2 = position.Y - v
	basePart.CFrame += Vector3.new(0, v2, 0)
	local weldConstraint = Instance.new("WeldConstraint", basePart)
	weldConstraint.Part0 = basePart
	weldConstraint.Part1 = humanoidRootPart
	weldConstraint.Parent = basePart
	return clone
end

function ConcertZoneController:_reconcileEffects(data)
	local character = self._player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if data.NoGravity ~= self._activeEffects.NoGravity then
		self._activeEffects.NoGravity = data.NoGravity

		if data.NoGravity then
			GravityManager.set("ConcertZone", self._originalGravity * 0.1, 100)

			if humanoid then
				if humanoid ~= self._boundHumanoid then
					self._boundHumanoid = humanoid
					JumpHeightManager.setHumanoid(humanoid)
					self._originalJumpHeight = humanoid.JumpHeight
					self._originalJumpPower = humanoid.JumpPower
				end

				if humanoid.UseJumpPower then
					humanoid.JumpPower = self._originalJumpPower * 1.5
				else
					JumpHeightManager.set("ConcertZone", self._originalJumpHeight * 2.5, 100)
				end
			end
		else
			GravityManager.release("ConcertZone")
			JumpHeightManager.release("ConcertZone")

			if humanoid and self._originalJumpHeight then
				humanoid.JumpHeight = self._originalJumpHeight
				humanoid.JumpPower = self._originalJumpPower
			end

			self._originalJumpHeight = nil
			self._originalJumpPower = nil
			self._boundHumanoid = nil
		end
	end

	if data.ChickenParty ~= self._activeEffects.ChickenParty then
		self._activeEffects.ChickenParty = data.ChickenParty
		self:_updateAllPlayerChickenOutfits()
	end

	if data.FastDay ~= self._activeEffects.FastDay then
		self._activeEffects.FastDay = data.FastDay

		if not data.FastDay then
			if self._isInsideZone then
				Lighting.TimeOfDay = "00:00:00"
			else
				Lighting.TimeOfDay = self._originalTimeOfDay
			end
		end
	end

	self._activeEffects.Spinning = data.Spinning
end

function ConcertZoneController:_runFrameEffects(p: number)
	local spinSpeed = ConcertSharedConfig.SpinSpeed or 10

	for _, v in ipairs(Players:GetPlayers()) do
		local character = v.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if (self._activeEffects.Spinning or self._activeEffects.ChickenParty) and character and self:_isCharacterInZone(character) then
			if humanoidRootPart and humanoid then
				if humanoid.AutoRotate then
					humanoid:SetAttribute("ConcertSpinOldAutoRotate", true)
					humanoid.AutoRotate = false
				end

				humanoidRootPart.CFrame *= CFrame.Angles(0, spinSpeed * p, 0)
			end
		elseif humanoid and humanoid:GetAttribute("ConcertSpinOldAutoRotate") then
			humanoid.AutoRotate = true
			humanoid:SetAttribute("ConcertSpinOldAutoRotate", nil)
		end
	end

	if not self._activeEffects.FastDay then
		self._fastDayTime = nil
		return
	end

	local fastDayCycleDuration = ConcertSharedConfig.FastDayCycleDuration or 10
	self._fastDayTime = (self._fastDayTime or 0) + p
	Lighting.ClockTime = self._fastDayTime / fastDayCycleDuration % 1 * 24
end

function ConcertZoneController:destroy()
	self:_reconcileEffects({
		NoGravity = false,
		Spinning = false,
		ChickenParty = false,
		FastDay = false
	})
	self:_updateAllPlayerChickenOutfits()

	for _, v in ipairs(Players:GetPlayers()) do
		local character = v.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not (humanoid and humanoid:GetAttribute("ConcertSpinOldAutoRotate")) then
			continue
		end

		humanoid.AutoRotate = true
		humanoid:SetAttribute("ConcertSpinOldAutoRotate", nil)
	end

	Lighting.TimeOfDay = self._originalTimeOfDay
	self._zonePart = nil
	self._gravityPart = nil
	self._lastCharacter = nil
end

return ConcertZoneController