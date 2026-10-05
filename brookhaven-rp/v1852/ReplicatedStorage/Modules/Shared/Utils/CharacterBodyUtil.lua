local CharacterBodyUtil = {}
local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NotificationService

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	NotificationService = require(ServerScriptService.Modules.UI.NotificationService)
else
	NotificationService = nil
end

local NotificationController

if RunService:IsClient() then
	NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
else
	NotificationController = nil
end

local UgcDynamicHeadConstants = require(ReplicatedStorage.Modules.Shared.AvatarEditor.UgcDynamicHeadConstants)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local v = {
	[UgcDynamicHeadConstants.SKYE] = {
		Head = Color3.fromRGB(174, 122, 89),
		LeftArm = Color3.fromRGB(174, 122, 89),
		LeftLeg = Color3.fromRGB(174, 122, 89),
		RightArm = Color3.fromRGB(174, 122, 89),
		RightLeg = Color3.fromRGB(174, 122, 89),
		Torso = Color3.fromRGB(174, 122, 89)
	},
	[UgcDynamicHeadConstants.BRIAN] = {
		Head = Color3.fromRGB(251, 182, 149),
		LeftArm = Color3.fromRGB(251, 182, 149),
		LeftLeg = Color3.fromRGB(251, 182, 149),
		RightArm = Color3.fromRGB(251, 182, 149),
		RightLeg = Color3.fromRGB(251, 182, 149),
		Torso = Color3.fromRGB(251, 182, 149)
	}
}
local _ = {
	HeightScale = 1,
	WidthScale = 1,
	DepthScale = 1,
	HeadScale = 1,
	BodyTypeScale = 0,
	ProportionScale = 0
}

function CharacterBodyUtil.GetForcedSkinColorForCharacter(p)
	if p == nil then
		return nil
	end

	local name = UgcDynamicHeadConstants.GetNameFromCharacter(p)

	if name == nil then
		return nil
	end

	return v[name]
end

function CharacterBodyUtil.ApplyForcedSkinColorIfNeeded(instance)
	local forcedSkinColorForCharacter = CharacterBodyUtil.GetForcedSkinColorForCharacter(instance)

	if forcedSkinColorForCharacter == nil or instance == nil then
		return false
	end

	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if humanoid ~= nil then
		local appliedDescription = humanoid:GetAppliedDescription()
		appliedDescription.HeadColor = forcedSkinColorForCharacter.Head
		appliedDescription.LeftArmColor = forcedSkinColorForCharacter.LeftArm
		appliedDescription.LeftLegColor = forcedSkinColorForCharacter.LeftLeg
		appliedDescription.RightArmColor = forcedSkinColorForCharacter.RightArm
		appliedDescription.RightLegColor = forcedSkinColorForCharacter.RightLeg
		appliedDescription.TorsoColor = forcedSkinColorForCharacter.Torso
		appliedDescription.HeightScale = 1
		appliedDescription.WidthScale = 1
		appliedDescription.DepthScale = 1
		appliedDescription.HeadScale = 1
		appliedDescription.BodyTypeScale = 0
		appliedDescription.ProportionScale = 0
		CharacterBodyUtil.ApplyDescription(humanoid, appliedDescription)
	end

	local bodyColors = instance:FindFirstChildWhichIsA("BodyColors")

	if bodyColors == nil then
		return true
	end

	bodyColors.HeadColor3 = forcedSkinColorForCharacter.Head
	bodyColors.LeftArmColor3 = forcedSkinColorForCharacter.LeftArm
	bodyColors.LeftLegColor3 = forcedSkinColorForCharacter.LeftLeg
	bodyColors.RightArmColor3 = forcedSkinColorForCharacter.RightArm
	bodyColors.RightLegColor3 = forcedSkinColorForCharacter.RightLeg
	bodyColors.TorsoColor3 = forcedSkinColorForCharacter.Torso
	return true
end

function CharacterBodyUtil.StripUgcBodyTextureIfNeeded(object, flag: boolean?)
	if flag ~= true and not GameUtil.IsFranchise() then
		return false
	end

	local parent = object.Parent

	if parent == nil or not parent:IsA("Model") or UgcDynamicHeadConstants.GetNameFromCharacter(parent) == nil then
		return false
	end

	for _, part in parent:GetChildren() do
		if not part:IsA("MeshPart") then
			continue
		end

		local bodyPartR15 = object:GetBodyPartR15(part)

		if not (bodyPartR15 ~= Enum.BodyPartR15.Unknown and bodyPartR15 ~= Enum.BodyPartR15.Head) then
			continue
		end

		part.TextureID = ""
		local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")

		if surfaceAppearance ~= nil then
			surfaceAppearance:Destroy()
		end
	end

	return true
end

local function getLayeredBodyCoverage(object)
	local v2 = false
	local v3 = false

	for _, v4 in object:GetAccessories(false) do
		local accessoryType = v4.AccessoryType

		if accessoryType == Enum.AccessoryType.Pants or accessoryType == Enum.AccessoryType.Shorts or accessoryType == Enum.AccessoryType.DressSkirt then
			v2 = true
		elseif accessoryType == Enum.AccessoryType.Shirt or accessoryType == Enum.AccessoryType.TShirt or accessoryType == Enum.AccessoryType.Sweater or accessoryType == Enum.AccessoryType.Jacket then
			v3 = true
		end
	end

	return v2, v3
end

function CharacterBodyUtil.GetPlatformCompliantVersionOfDescription(data)
	local v2 = AvatarEditorService:CheckApplyDefaultClothing(data)

	if v2 == nil then
		return data, false
	end

	local layeredBodyCoverage, v3 = getLayeredBodyCoverage(data)

	if layeredBodyCoverage then
		v2.Pants = data.Pants
	end

	if v3 then
		v2.Shirt = data.Shirt
		v2.GraphicTShirt = data.GraphicTShirt
	end

	if v2.Pants == data.Pants and v2.Shirt == data.Shirt and v2.GraphicTShirt == data.GraphicTShirt then
		return data, false
	end

	return v2, true
end

function CharacterBodyUtil.ApplyDescription(object, p)
	assert(object, "No humanoid provided to CharacterBodyUtil.ApplyDescription.")
	assert(p, "No HumanoidDescription provided to CharacterBodyUtil.ApplyDescription.")
	local platformCompliantVersionOfDescription, v2 = CharacterBodyUtil.GetPlatformCompliantVersionOfDescription(p)
	object:ApplyDescriptionAsync(platformCompliantVersionOfDescription, Enum.AssetTypeVerification.ClientOnly)
	CharacterBodyUtil.StripUgcBodyTextureIfNeeded(object)
	return v2
end

function CharacterBodyUtil.ApplyDescriptionWithModestyLayerNotification(p, p2, p3)
	local v2 = CharacterBodyUtil.ApplyDescription(p2, p3)

	if p and v2 then
		if RunService:IsServer() then
			NotificationService.NotifyEditor(p, "Missing clothing - Applied basic outfit")
		elseif p == Players.LocalPlayer then
			NotificationController.NotifyEditor("Missing clothing - Applied basic outfit")
		end
	end
end

return CharacterBodyUtil