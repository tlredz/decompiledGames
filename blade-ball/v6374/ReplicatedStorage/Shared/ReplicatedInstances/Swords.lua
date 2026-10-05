local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3("@game/ReplicatedStorage/Common/Utils/Utilities/Physics")
local v = require3("@game/ReplicatedStorage/Shared/ReplicatedInstances/SwordAccessories")
local v2 = require3("@game/ReplicatedStorage/Shared/AttrGeneration")
local v3 = require3("@game/ReplicatedStorage/ServerInfo")
local v4 = require3("@game/ReplicatedStorage/Shared/ReplicatedInstancesUtils")
local v5 = require3("@game/ReplicatedStorage/Shared/SwordAPI")
local v6 = require3("@game/ReplicatedStorage/Common/Logger")
local v7 = require3("@game/ReplicatedStorage/Common/Utils/Utilities/Inst")
local v8 = require3("@game/ReplicatedStorage/Shared/ReplicatedInstances")
local v9 = require3("@self/SwordMounts")
local remotes = ReplicatedStorage2.Remotes
local scope = v2.scope("Swords")
local scope2 = v6.namespace("RepInst"):scope("Swords")
local v10 = {
	"ParticleEmitter",
	"Beam",
	"Trail",
	"Fire",
	"Smoke",
	"Sparkles"
}
local isServer = RunService:IsServer()
RunService:IsClient()

local function tryLog(p, ...)
	if p then
		return true, ...
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isEffect(part)
	for _, className in v10 do
		if part:IsA(className) then
			return true
		end
	end

	return false
end

local function setSwordVisualHidden(folder, flag: boolean)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			if flag then
				if part.Transparency < 1 then
					part:SetAttribute("_originalTransparency", part.Transparency)
					part.Transparency = 1
				end
			else
				local _originalTransparency = part:GetAttribute("_originalTransparency")

				if typeof(_originalTransparency) == "number" then
					part.Transparency = _originalTransparency
					part:SetAttribute("_originalTransparency", nil)
				end
			end
		else
			-- equivalent call inferred; original call site unknown
			if isEffect(part) then
				if flag then
					if part.Enabled then
						part:SetAttribute("_originalEnabled", true)
						part.Enabled = false
					end
				elseif part:GetAttribute("_originalEnabled") == true then
					part.Enabled = true
					part:SetAttribute("_originalEnabled", nil)
				end
			end
		end
	end
end

local function applyMotorOffsets(parent, sword, isToggledOn: boolean)
	local c0AccessoryOffset = isToggledOn and sword.C0AccessoryOffset or sword.C0Offset
	local c1AccessoryOffset = isToggledOn and sword.C1AccessoryOffset or sword.C1Offset

	if not (c0AccessoryOffset or c1AccessoryOffset) then
		return
	end

	for _, v11 in parent:QueryDescendants(".SwordMotor"), nil, nil do
		if c1AccessoryOffset then
			v11.C1 *= c1AccessoryOffset
		end

		if c0AccessoryOffset then
			v11.C0 *= c0AccessoryOffset
		end
	end
end

local function rebindSordJoints(parent, clone)
	local sord = clone:FindFirstChild("sord")

	if not sord then
		return
	end

	for _, child in sord:GetChildren() do
		if not (child:IsA("Motor6D") or child:IsA("Weld")) then
			continue
		end

		local part0 = child:GetAttribute("Part0")

		if part0 then
			child.Part0 = parent:FindFirstChild(part0) or child.Part0
		end

		local part1 = child:GetAttribute("Part1")

		if part1 then
			child.Part1 = parent:FindFirstChild(part1) or child.Part0
		end
	end
end

if isServer then
	for _, child in ServerStorage.Misc.Swords:GetChildren() do
		local name = child.Name
		local rarity = name == ".Temp" and "Unique" or name

		for _, child2 in child:GetChildren() do
			if not (child2:IsA("Model") or child2:IsA("StringValue")) then
				continue
			end

			local clone = table.clone(child2:GetAttributes())
			clone.DisplayName = clone.Name or child2.Name
			clone.Name = child2.Name
			clone.Rarity = rarity
			clone.SwordType = clone.SwordType or clone.IsDual and "Dual" or "Single"
			clone.AnimationType = clone.AnimationType or clone.SwordType == "Dual" and "DualOld" or clone.SwordType
			clone.AnimationStyles = v5:GetStyles(clone.AnimationType)
			v8:AddObjectToCollection("Swords", child2.Name, child2, clone)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAppearanceLoaded:Connect(function(character)
			task.wait()
			character:SetAttribute("AppearanceLoaded", true)
		end)
	end)
end

local instanceReplicatorFor = v8.createInstanceReplicatorFor("Swords")

function instanceReplicatorFor:GetListByRarity()
	local _swordListByRarity = self._swordListByRarity

	if _swordListByRarity then
		return _swordListByRarity
	end

	local result = {}

	for k, v11 in self:GetCollection() do
		local v12 = result[v11.Rarity]

		if not v12 then
			v12 = {}
			result[v11.Rarity] = v12
		end

		v12[k] = v11
	end

	self._swordListByRarity = result
	return result
end

function instanceReplicatorFor:GetSword(p: string)
	return self:GetCollection()[p]
end

function instanceReplicatorFor:GetSwordsInRarity(p: string)
	return self:GetListByRarity()[p] or {}
end

function instanceReplicatorFor:EquipSwordTo(parent, currentlyEquippedSword: string, value: number?, flag: boolean?)
	local _ = parent.Name
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	scope2:info(playerFromCharacter, (`Equipping sword {currentlyEquippedSword}`))

	if v3.isRegionalTournamentMatch() then
		scope2:info(playerFromCharacter, "Forced base sword in regional tournament match")
		currentlyEquippedSword = "Base Sword"
		flag = nil
		value = nil
	end

	local sword = self:GetSword(currentlyEquippedSword)

	if not sword then
		scope2:warn(playerFromCharacter, (`SwordInfo not found for {currentlyEquippedSword}`))
		return
	end

	local state = v:ResolveState(parent, currentlyEquippedSword, sword, flag)
	local isToggledOn = state.HasAccessory and state.IsToggledOn
	local animationStyle

	if playerFromCharacter then
		animationStyle = playerFromCharacter:GetAttribute("AnimationStyle")
	else
		animationStyle = parent:GetAttribute("AnimationStyle")
	end

	local animationProfile = v5:GetAnimationProfile(
		sword.AnimationType,
		sword.SwordType,
		isToggledOn,
		animationStyle,
		parent
	)
	local v11 = isToggledOn or sword.ForcesAnimationProfile == true
	local swordAnimationProfile

	if not (animationProfile or not (sword.HasAnimationProfile and v11)) then
		swordAnimationProfile = currentlyEquippedSword
	end

	local v13 = scope.begin(parent, {
		swordName = currentlyEquippedSword,
		scale = value or 1,
		accessoryEquipped = isToggledOn,
		shouldCreateAccessory = state.ShouldCreate,
		animationProfile = animationProfile,
		swordAnimationProfile = swordAnimationProfile,
		animationStyle = animationStyle
	})

	if not v13 then
		scope2:info(playerFromCharacter, "Same sword or accessory state already equipping, nothing to do")
		return v7.waitForQuery(parent, ">Model[$_equippedSword]", 60)
	end

	local torso = parent:WaitForChild("Torso", 5)

	if not scope.isCurrent(parent, v13) then
		scope2:info(playerFromCharacter, (`Unequipped sword {currentlyEquippedSword} before it could load`))
		return v7.waitForQuery(parent, ">Model[$_equippedSword]", 60)
	end

	local leftArm = parent:FindFirstChild("Left Arm")
	local rightArm = parent:FindFirstChild("Right Arm")

	if not (torso and leftArm and rightArm) then
		scope2:info(playerFromCharacter, (`Missing required parts for sword {currentlyEquippedSword}`))
		return
	end

	local instance = v4.getInstance("Swords", currentlyEquippedSword)

	if not scope.isCurrent(parent, v13) then
		scope2:info(playerFromCharacter, (`Unequipped sword {currentlyEquippedSword} before it could load`))
		return v7.waitForQuery(parent, ">Model[$_equippedSword]", 60)
	end

	if not instance then
		scope2:info(playerFromCharacter, (`Sword {currentlyEquippedSword} not found, using Base Sword`))
		instance = v4.getInstance("Swords", "Base Sword")
		sword = self:GetSword("Base Sword")

		if scope.isCurrent(parent, v13) then
			if playerFromCharacter then
				remotes.Notification:FireClient(
					playerFromCharacter,
					`Couldn't load your {currentlyEquippedSword}. Using the Base Sword for now. Try re-equipping it.`,
					10
				)
			end
		else
			scope2:info(playerFromCharacter, (`Unequipped sword {currentlyEquippedSword} before it could load`))
			return v7.waitForQuery(parent, ">Model[$_equippedSword]", 60)
		end
	end

	local clone = instance:Clone()

	if value and clone:IsA("Model") then
		clone:ScaleTo(clone:GetScale() * value)
	end

	for _, v14 in parent:QueryDescendants(".SwordMotor,[$_equippedSword],[$_swordAccessory]") do
		v14:Destroy()
	end

	if playerFromCharacter and currentlyEquippedSword == "DOT" then
		task.spawn(function()
			if not parent:WaitForChild("KaziGreenAccessory", 30) or (not scope.isCurrent(parent, v13) or clone.Parent ~= parent) then
				return
			end

			clone.Frogge.Handle.TextureID = "rbxassetid://12815008921"
		end)
	end

	if playerFromCharacter and isServer then
		remotes.FireSwordInfo:FireClient(playerFromCharacter, currentlyEquippedSword)
	end

	clone:SetAttribute("_equippedSword", true)
	clone.Parent = parent

	if state.IsInverted then
		setSwordVisualHidden(clone, not state.IsToggledOn)
	end

	v9.mount({
		Character = parent,
		Sword = clone,
		SwordName = currentlyEquippedSword,
		SwordType = sword.SwordType,
		Torso = torso,
		LeftArm = leftArm,
		RightArm = rightArm
	})
	applyMotorOffsets(parent, sword, isToggledOn)
	rebindSordJoints(parent, clone)

	if state.ShouldCreate and state.VariantName then
		v:EquipAccessoryTo(parent, currentlyEquippedSword, state.VariantName, v13)
	end

	if isServer then
		if playerFromCharacter then
			parent:SetAttribute("AnimationStyle", animationStyle)
		end

		v:UpdateHeadless(parent, state.Info, isToggledOn, v13)
	end

	local v14

	if state.HasAccessory then
		v14 = isToggledOn
	end

	if playerFromCharacter then
		playerFromCharacter:SetAttribute("HasAccessoryEquipped", v14)
		playerFromCharacter:SetAttribute("CurrentlyEquippedSword", currentlyEquippedSword)
	end

	parent:SetAttribute("HasAccessoryEquipped", v14)
	parent:SetAttribute("CurrentlyEquippedSword", currentlyEquippedSword)
	parent:SetAttribute("SelectedAccessoryVariant", state.VariantName)
	parent:SetAttribute("AnimationProfile", animationProfile)
	parent:SetAttribute("SwordAnimationProfile", swordAnimationProfile)
	scope2:info(
		playerFromCharacter,
		(`Equipped {currentlyEquippedSword} {isToggledOn and "with" or "without"} accessory`)
	)
	return clone
end

function instanceReplicatorFor:ForceEquipSwordTo(p, p2: string, p3: number?, flag: boolean?)
	scope.beginForced(p)
	return instanceReplicatorFor:EquipSwordTo(p, p2, p3, flag)
end

function instanceReplicatorFor.GetOrForceEquipSwordTo(_, instance, p: string, p2: number?, flag: boolean?)
	local v11 = instance:QueryDescendants(">Model[$_equippedSword]")[1]

	if v11 and instance:GetAttribute("CurrentlyEquippedSword") == p then
		return v11
	end

	return instanceReplicatorFor:ForceEquipSwordTo(instance, p, p2, flag)
end

function script.GetSword.OnInvoke(p: string)
	return instanceReplicatorFor:GetSword(p)
end

function script.GetInstance.OnInvoke(p: string)
	return instanceReplicatorFor:GetInstance(p)
end

function script.EquipSwordTo.OnInvoke(p, p2: string)
	return instanceReplicatorFor:EquipSwordTo(p, p2)
end

return instanceReplicatorFor