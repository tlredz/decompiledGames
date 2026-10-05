local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ClothingRack"
})
local ClothesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Clothes.ClothesConfig)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local v2 = {
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerArm",
	"RightLowerArm",
	"LeftHand",
	"RightHand"
}
local v3 = {
	"LeftUpperLeg",
	"RightUpperLeg",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftFoot",
	"RightFoot"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function accessoryTypeNameToAssetTypeName(p: string)
	if p == "Hat" then
		return "Hat"
	end

	return p .. "Accessory"
end

local function GetAccessoryOffsetDerivationRig(accessories)
	local v4 = {}

	for _, item in accessories do
		table.insert(v4, {
			AssetId = item.Id,
			AccessoryType = Enum.AccessoryType:FromName(item.Type)
		})
	end

	local humanoidDescription = Instance.new("HumanoidDescription")
	humanoidDescription:SetAccessories(v4, true)
	local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
		humanoidDescription,
		Enum.HumanoidRigType.R15,
		Enum.AssetTypeVerification.ClientOnly
	)
	humanoidModelFromDescriptionAsync:PivotTo(CFrame.new(0, 10000, 10000))
	humanoidDescription.Parent = humanoidModelFromDescriptionAsync
	local humanoidRootPart = humanoidModelFromDescriptionAsync:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	end

	humanoidModelFromDescriptionAsync.Parent = workspace
	task.delay(5, function()
		Debris:AddItem(humanoidModelFromDescriptionAsync, 0)
	end)
	return humanoidModelFromDescriptionAsync
end

local v4 = nil
local flag = false
local _1Bab1yFollo1w = nil

local function getBabyFollowRemote()
	if _1Bab1yFollo1w == nil then
		_1Bab1yFollo1w = ReplicatedStorage.RE:WaitForChild("1Bab1yFollo1w")
	end

	return _1Bab1yFollo1w
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActiveFollowCharacterName()
	local playersBag = Players.LocalPlayer:FindFirstChild("PlayersBag")

	if playersBag == nil then
		return nil
	end

	local followCharacterName = playersBag:FindFirstChild("FollowCharacterName")

	if followCharacterName == nil or followCharacterName.Value == "NoFollowCharacter" then
		return nil
	end

	return followCharacterName.Value
end

local function resetCurrentlyWornClothingRackUI()
	if v4 == nil then
		return
	end

	if v4.clickerIcon then
		v4.clickerIcon.Image = "http://www.roblox.com/asset/?id=952752650"
	end

	v4.isWorn = false
	v4 = nil
end

Remotes.connect(AvatarEditorRequests.RESET_CHARACTER_APPEARANCE, function()
	if v4 == nil then
		return
	end

	if v4.clickerIcon then
		v4.clickerIcon.Image = "http://www.roblox.com/asset/?id=952752650"
	end

	v4.isWorn = false
	v4 = nil
end)

function v:Wear()
	if v4 ~= nil and v4 ~= self then
		if v4.clickerIcon then
			v4.clickerIcon.Image = "http://www.roblox.com/asset/?id=952752650"
		end

		v4.isWorn = false
	end

	self.isWorn = true
	v4 = self
	self.clickerIcon.Image = "rbxassetid://93354156459100"
	local rackDisplayedOutfitData = self.rackDisplayedOutfitData
	local v5 = not rackDisplayedOutfitData.Accessories and {} or table.clone(rackDisplayedOutfitData.Accessories) or {}
	WearingController.WearOutfitFromRack(rackDisplayedOutfitData.ShirtId, rackDisplayedOutfitData.PantsId, v5)
	NotificationController.NotifyCenter("Outfit equipped! (May be hidden under current clothing)")

	if self.Instance:GetAttribute("UseUGCTelemetry") == true then
		local items = {}

		for _, v7 in v5 do
			local v8 = {
				id = tonumber(v7.Id),
				assetType = accessoryTypeNameToAssetTypeName(v7.Type)
			}
			table.insert(items, v8)
		end

		if rackDisplayedOutfitData.ShirtId ~= nil then
			table.insert(items, {
				id = tonumber(rackDisplayedOutfitData.ShirtId),
				assetType = "Shirt"
			})
		end

		if rackDisplayedOutfitData.PantsId ~= nil then
			table.insert(items, {
				id = tonumber(rackDisplayedOutfitData.PantsId),
				assetType = "Pants"
			})
		end

		TelemetryController.SendClientInteraction("equipUGC", {
			items = items,
			location = self.Instance:GetAttribute("Location")
		})
	else
		local ids = { tonumber(rackDisplayedOutfitData.ShirtId), (tonumber(rackDisplayedOutfitData.PantsId)) }

		for _, v6 in v5 do
			table.insert(ids, (tonumber(v6.Id)))
		end

		TelemetryController.SendClientInteraction("equipRoleplayOutfit", {
			outfitName = self.Instance:GetAttribute("OutfitName"),
			assetIds = ids
		})
	end
end

function v:RestoreOriginalOutfit()
	self.isWorn = false

	if v4 == self then
		v4 = nil
	end

	self.clickerIcon.Image = "http://www.roblox.com/asset/?id=952752650"
	WearingController.RestoreOutfitFromRack()
end

function v:UpdateDisplayedRigOutfit(parent, data)
	if data.ShirtContent ~= nil then
		for _, childName in v2 do
			local child = parent:FindFirstChild(childName)

			if child then
				child.TextureID = data.ShirtContent
			end
		end
	end

	if data.PantsContent ~= nil then
		for _, childName in v3 do
			local child = parent:FindFirstChild(childName)

			if child then
				child.TextureID = data.PantsContent
			end
		end
	end

	for _, model in parent:GetChildren() do
		if model and model:IsA("Model") and model.Name == "ModelizedAccessory" then
			Debris:AddItem(model, 0)
		end
	end

	if data.Accessories then
		local accessoryOffsetDerivationRig = GetAccessoryOffsetDerivationRig(data.Accessories)
		local humanoidRootPart = accessoryOffsetDerivationRig:FindFirstChild("HumanoidRootPart")
		local humanoid = accessoryOffsetDerivationRig:FindFirstChild("Humanoid")
		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")
		assert(
			humanoidRootPart and humanoid,
			"ClothingRack: UpdateDisplayedRigOutfit - hrp or humanoid was not found in accessory offset derivation rig, this should never happen"
		)
		assert(
			humanoidRootPart2,
			"ClothingRack: UpdateDisplayedRigOutfit - hrp was not found in rig that accessories are attempting to be displayed on, this should never happen"
		)
		local accessories = humanoid:GetAccessories()

		for _, accessory in accessories do
			local model = Instance.new("Model")
			model.Name = "ModelizedAccessory"

			for _, child in accessory:GetChildren() do
				local clone = child:Clone()

				if clone:IsA("BasePart") or clone:IsA("MeshPart") then
					local objectSpace = humanoidRootPart.CFrame:ToObjectSpace(child.CFrame)
					clone.CanCollide = false
					clone.CanQuery = false
					clone.CanTouch = false
					clone.Anchored = true
					local weld = clone:FindFirstChildWhichIsA("Weld") or clone:FindFirstChildWhichIsA("WeldConstraint")

					if weld then
						weld.Enabled = false
						Debris:AddItem(weld, 0)
					end

					clone.Parent = model
					local v6 = clone
					task.spawn(function()
						v6.CFrame = humanoidRootPart2.CFrame * objectSpace
					end)
				else
					clone.Parent = model
				end
			end

			model.Parent = parent
		end
	end
end

function v:AssignOutfit(outfit)
	if self.Instance:GetAttribute("OutfitAssigned") then
		return
	end

	self.Instance:SetAttribute("OutfitAssigned", true)
	self.outfit = outfit

	for _, displayRig in self.displayRigs do
		self:UpdateDisplayedRigOutfit(displayRig, outfit)
	end
end

function v:GetOutfitConfigDataFromName(p: string)
	local nameIndexedConfig = ClothesConfig.getNameIndexedConfig()
	assert(
		nameIndexedConfig,
		"Name-indexed clothes config not loaded, this should never happen - is something wrong with the RC?"
	)
	local outfit = nameIndexedConfig.Outfits[p]
	assert(
		outfit,
		(`ClothingRack::GetOutfitConfigDataFromName - Outfit data not found for name "{p}" inside of the AvatarEditor/Clothes/Outfits RC path!`)
	)
	return outfit
end

function v:Construct()
	local characterDisplays = self.Instance:WaitForChild("CharacterDisplays")
	local outfitName = self.Instance:GetAttribute("OutfitName")
	assert(
		outfitName,
		"ClothingRack: No outfit name to display found - did you set the OutfitName attribute on the model?"
	)
	self._Janitor = Janitor.new()
	self.hitbox = self.Instance:WaitForChild("Hitbox"):WaitForChild("ClickDetector")
	self.clickerIcon = self.Instance:WaitForChild("Hitbox"):WaitForChild("Clicker"):WaitForChild("Hand")
	self.displayRigs = characterDisplays:GetChildren()
	self.rackDisplayedOutfitData = self:GetOutfitConfigDataFromName(outfitName)
	self:AssignOutfit(self.rackDisplayedOutfitData)
	self._Janitor:Add(self.hitbox.MouseHoverEnter:Connect(function()
		TweenService:Create(self.clickerIcon, TweenInfo.new(1.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	end))
	self._Janitor:Add(self.hitbox.MouseHoverLeave:Connect(function()
		TweenService:Create(self.clickerIcon, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.8, 0, 0.8, 0)
		}):Play()
	end))
	self._Janitor:Add(self.hitbox.MouseClick:Connect(function(_)
		if flag then
			return
		end

		flag = true
		local activeFollowCharacterName = getActiveFollowCharacterName() -- equivalent call inferred; original call site unknown

		if activeFollowCharacterName ~= nil then
			if _1Bab1yFollo1w == nil then
				_1Bab1yFollo1w = ReplicatedStorage.RE:WaitForChild("1Bab1yFollo1w")
			end

			_1Bab1yFollo1w:FireServer("TempDeleteFollowCharacter")
		end

		if self.isWorn then
			self:RestoreOriginalOutfit()
		else
			self:Wear()
		end

		if activeFollowCharacterName ~= nil then
			if _1Bab1yFollo1w == nil then
				_1Bab1yFollo1w = ReplicatedStorage.RE:WaitForChild("1Bab1yFollo1w")
			end

			_1Bab1yFollo1w:FireServer("CharacterFollowSpawnPlayer", activeFollowCharacterName)
		end

		task.wait(0.5)
		flag = false
	end))
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v