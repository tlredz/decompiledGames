local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Observers = require(packages.Observers)
local Replion = require(packages.Replion)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local v = Replion.Client:WaitReplion("TidefallEntry")
local v2 = nil
local v3 = nil

local function setDropoffPromptEnabled(carryingLostDiver: boolean)
	for _, part in ipairs(CollectionService:GetTagged("TidefallLostDiverDropoff")) do
		if not part:IsA("BasePart") then
			continue
		end

		local tidefallDropoffPrompt = part:FindFirstChild("TidefallDropoffPrompt")

		if tidefallDropoffPrompt and tidefallDropoffPrompt:IsA("ProximityPrompt") then
			tidefallDropoffPrompt.Enabled = carryingLostDiver
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupCarry()
	if v2 then
		v2:Destroy()
		v2 = nil
	end
end

local function getDiverModel()
	if v3 and v3.Parent then
		return v3
	end

	for _, model in ipairs(CollectionService:GetTagged("TidefallLostDiver")) do
		if not (model:IsA("Model") and model.Parent) then
			continue
		end

		v3 = model
		return model
	end

	return nil
end

local function setModelHidden(folder, flag: boolean)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = flag and 1 or 0
			descendant.CanCollide = not flag
		elseif descendant:IsA("ProximityPrompt") and descendant.Name == "TidefallPickupPrompt" then
			descendant.Enabled = not flag
		end
	end
end

local function attachCloneToCharacter(instance)
	cleanupCarry() -- equivalent call inferred; original call site unknown
	local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	local clone = instance:Clone()
	clone.Name = "CarriedLostDiver"
	CollectionService:RemoveTag(clone, "TidefallLostDiver")

	if not clone.PrimaryPart then
		clone.PrimaryPart = clone:FindFirstChildWhichIsA("BasePart", true)
	end

	local primaryPart = clone.PrimaryPart

	if not primaryPart then
		clone:Destroy()
		return
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.Massless = true
		elseif descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		elseif descendant:IsA("Humanoid") then
			descendant:ChangeState(Enum.HumanoidStateType.Physics)
			descendant.EvaluateStateMachine = false
		end
	end

	clone.Parent = workspace
	primaryPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0.5, 2) * CFrame.Angles(0, 3.141592653589793, 0)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = primaryPart
	weldConstraint.Part1 = humanoidRootPart
	weldConstraint.Parent = primaryPart
	v2 = clone
end

local function applyState()
	local savedLostDiver = v:Get("SavedLostDiver")
	local carryingLostDiver = v:Get("CarryingLostDiver")

	for _, model in ipairs(CollectionService:GetTagged("TidefallLostDiver")) do
		if model:IsA("Model") and model.Parent then
			setModelHidden(model, savedLostDiver or carryingLostDiver)
		end
	end

	if carryingLostDiver then
		local v4 = not v2 and getDiverModel()

		if v4 then
			attachCloneToCharacter(v4)
		end
	else
		cleanupCarry() -- equivalent call inferred; original call site unknown
	end

	setDropoffPromptEnabled(carryingLostDiver)
end

return {
	Start = function(self)
		self.trove = Trove.new()
		Observers.observeTag("TidefallLostDiver", function(model)
			if model:IsA("Model") and model.Parent then
				v3 = model
				applyState()
			end

			return function() end
		end)
		Observers.observeTag("TidefallLostDiverDropoff", function(part)
			if part:IsA("BasePart") then
				applyState()
			end

			return function() end
		end)
		self.trove:Add(v:OnDataChange(function()
			applyState()
		end))
		applyState()
	end
}