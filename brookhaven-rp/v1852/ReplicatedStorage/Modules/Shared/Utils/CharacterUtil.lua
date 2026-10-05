local createVector = vector.create
local CharacterUtil = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MathUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("MathUtil"))

function CharacterUtil.getPlayerFromCharacterPart(parent, flag: boolean?)
	if flag and parent.Name ~= "HumanoidRootPart" then
		return
	end

	for _ = 1, 2 do
		parent = parent.Parent
		local v = parent and parent:IsA("Model") and parent

		if v then
			return Players:GetPlayerFromCharacter(v)
		end

		if not parent then
			return nil
		end
	end

	return nil
end

function CharacterUtil.standOn(instance, p, flag: boolean?)
	instance:PivotTo(CharacterUtil.getStandOnCFrame(instance, p, flag))
end

function CharacterUtil:getStandOnCFrame(instance2, flag: boolean?)
	local humanoidRootPart = self:WaitForChild("HumanoidRootPart")
	self.WorldPivot = humanoidRootPart.CFrame
	local hipHeight

	if self.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		hipHeight = self:FindFirstChild("Left Leg").Size.Y + humanoidRootPart.Size.Y / 2
	else
		hipHeight = self.Humanoid.HipHeight
	end

	if flag then
		return (instance2.CFrame:ToWorldSpace(CFrame.new(
			MathUtil.nextNumber(-instance2.Size.X / 2, instance2.Size.X / 2),
			hipHeight + (instance2.Size + humanoidRootPart.Size).Y / 2,
			MathUtil.nextNumber(-instance2.Size.Z / 2, instance2.Size.Z / 2)
		)))
	end

	return (instance2.CFrame:ToWorldSpace(CFrame.new(0, hipHeight + (instance2.Size + humanoidRootPart.Size).Y / 2, 0)))
end

function CharacterUtil.standAtBase(instance, p)
	instance:PivotTo(CharacterUtil.getBaseCFrame(instance, p))
end

function CharacterUtil.getBaseCFrame(p, p2)
	return CharacterUtil.getStandOnCFrame(p, p2, false) * CFrame.new(0, -p2.Size.Y, 0)
end

function CharacterUtil.removeFromSeat(instance)
	local humanoid

	if instance then
		humanoid = instance:FindFirstChild("Humanoid") or nil
	end

	if not humanoid then
		return
	end

	local seatPart = humanoid.SeatPart

	if not seatPart then
		return
	end

	while humanoid.Parent and seatPart.Parent and humanoid.SeatPart == seatPart do
		local seatWeld = seatPart:FindFirstChild("SeatWeld")

		if seatWeld then
			seatWeld:Destroy()
		end

		task.wait(0.05)
	end

	RunService.Heartbeat:Wait()
	return instance.Parent and humanoid.SeatPart ~= seatPart
end

function CharacterUtil:createViewportHeadshot()
	local camera = Instance.new("Camera")
	self.PrimaryPart.Anchored = true
	local pivot = self:GetPivot()
	local v = self.Humanoid.RigType == Enum.HumanoidRigType.R15 and 1.5 or 0
	local position = (pivot * CFrame.new(0, v, -2.5)).Position
	camera.CFrame = CFrame.lookAlong(position, -pivot.LookVector)
	local worldModel = Instance.new("WorldModel")
	self.Parent = worldModel
	camera.Parent = worldModel
	return worldModel
end

function CharacterUtil.distanceTo(instance, instance2, value: string?)
	local child = instance:FindFirstChild(value or "HumanoidRootPart")

	if child == nil then
		return nil
	end

	if instance2:IsA("Model") then
		return (child.Position - instance2:GetPivot().Position).Magnitude
	end

	if instance2:IsA("Attachment") then
		return (child.Position - instance2.WorldPosition).Magnitude
	end

	return (child.Position - instance2.Position).Magnitude
end

function CharacterUtil.isDescendantOfCharacter(parent)
	while parent ~= nil do
		if parent:IsA("Model") then
			if not (Players:GetPlayerFromCharacter(parent) == nil and parent:FindFirstChildOfClass("Humanoid") == nil) then
				return true
			end
		end

		parent = parent.Parent
	end

	return false
end

function CharacterUtil.detectPlayersInFront(player, vector2: Vector3?)
	local character = player.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local part = Instance.new("Part")
	part.Size = vector2 or createVector(6, 6, 6)
	part.Transparency = 0.5
	part.CanCollide = false
	part.Anchored = true
	part.Parent = game.Workspace
	part.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }
	local partsInPart = workspace:GetPartsInPart(part, overlapParams)
	local models = {}

	for _, v in pairs(partsInPart) do
		local model = v:FindFirstAncestorOfClass("Model")

		if model and model:FindFirstChild("Humanoid") then
			table.insert(models, model)
		end
	end

	part:Destroy()
	return models
end

return CharacterUtil