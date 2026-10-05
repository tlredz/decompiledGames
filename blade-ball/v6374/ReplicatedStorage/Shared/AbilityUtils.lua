local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Shared.Nanoid)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local v8 = require3(ReplicatedStorage2.ServerInfo)
local v9 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v10 = require3(ReplicatedStorage2.Shared.Inventory)
local client = v10.Client
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local updateSignal = v2.new()
local v12 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getSwordAccessoryInfo()
	local equipped = client:GetEquipped("Sword")
	return equipped and v9:GetCollection()[equipped.Name]
end

local function getSwordAccessoryFolder()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil
	end

	for _, child in character:GetChildren() do
		if child:GetAttribute("_swordAccessory") then
			return child
		end
	end

	return nil
end

local v13 = nil

local function hideMount()
	if v13 then
		return
	end

	local swordAccessoryInfo = getSwordAccessoryInfo() -- equivalent call inferred; original call site unknown

	if not swordAccessoryInfo then
		return
	end

	local child = script.HideTracks:FindFirstChild(swordAccessoryInfo.Name)

	if not child then
		return
	end

	local swordAccessoryFolder = getSwordAccessoryFolder()
	local parent = swordAccessoryFolder and swordAccessoryFolder.Parent

	if not (swordAccessoryFolder and parent) then
		return
	end

	local animator = swordAccessoryFolder:FindFirstChildWhichIsA("Animator", true) or parent:FindFirstChildWhichIsA(
		"Animator",
		true
	)

	if not animator then
		return
	end

	local track = animator:LoadAnimation(child)
	track:Play(0)
	v13 = track
	updateSignal:Fire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showMount()
	if not v13 then
		return
	end

	v13:Stop(0)
	v13 = nil
	updateSignal:Fire()
end

local function updateMount()
	local swordAccessoryInfo = getSwordAccessoryInfo() -- equivalent call inferred; original call site unknown

	if not swordAccessoryInfo or swordAccessoryInfo.Name ~= "Reindeer" and swordAccessoryInfo.Name ~= "Polar Bear" and swordAccessoryInfo.Name ~= "Winter Wolf" then
		return showMount()
	end

	if next(v12) then
		hideMount()
		return
	end

	showMount() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlaying(nanoid: string, flag: boolean?)
	v12[nanoid] = flag
	updateMount()
end

if isClient then
	Players.LocalPlayer.CharacterRemoving:Connect(function()
		table.clone(v12)
		updateMount()
	end)
end

local function getEquippedAbility(instance)
	if typeof(instance) ~= "Instance" then
		return {
			Name = "Dash",
			Id = "Dash"
		}
	end

	local abilityOverride = instance:GetAttribute("AbilityOverride")

	if type(abilityOverride) == "string" then
		return {
			Name = abilityOverride,
			Id = abilityOverride
		}
	end

	if isServer then
		if v3.Server:GetReplionFor(instance, "Inventory") then
			return v10.Server:GetEquipped(instance, "Ability")
		end
	else
		if not isClient then
			return nil
		end

		assert(
			instance == Players.LocalPlayer,
			"Can't call `getEquippedAbility` in client for another player that is not LocalPlayer"
		)

		if v3.Client:GetReplion("Inventory") then
			return v10.Client:GetEquipped("Ability")
		end
	end

	return nil
end

local AbilityUtils = {}
AbilityUtils.updateSignal = updateSignal

function AbilityUtils.isHiding()
	return v13 ~= nil
end

AbilityUtils.setPlaying = setPlaying

function AbilityUtils.playAnimationTrack(object, _: string, duration: number)
	local nanoid = v5.nanoid()
	setPlaying(nanoid, true) -- equivalent call inferred; original call site unknown
	local endedConnection = nil
	local thread = nil
	local flag = false

	local function onEnd()
		if flag then
			return
		end

		flag = true

		if endedConnection then
			endedConnection:Disconnect()
			endedConnection = nil
		end

		if thread then
			v.SafeCancel(thread)
			thread = nil
		end

		task.delay(1, function()
			setPlaying(nanoid, nil) -- equivalent call inferred; original call site unknown
		end)
	end

	endedConnection = object.Ended:Once(onEnd)
	thread = task.delay(duration, onEnd)
	object:Play()
	return function(...)
		object:Stop(...)
	end
end

function AbilityUtils.isAbilityDisabled(p: string?)
	if not p then
		return false
	end

	local fFlag = v6.FFlag.GetFFlag("DisabledAbilities", "")
	local v14 = string.split(fFlag, ";") or {}
	return table.find(v14, p) ~= nil
end

function AbilityUtils.getDisabledAbilities()
	local fFlag = v6.FFlag.GetFFlag("DisabledAbilities", "")
	return string.split(fFlag, ";") or {}
end

AbilityUtils.getEquippedAbility = getEquippedAbility

function AbilityUtils.getAbilityUpgrade(instance, p: string)
	if typeof(instance) ~= "Instance" then
		return 0
	end

	if v8.isTournamentMatchServer() and v7.AbilityUpgrade then
		return v7.AbilityUpgrade
	end

	if isServer then
		local replionFor = v3.Server:GetReplionFor(instance, "Data")

		if replionFor then
			return replionFor:Get({ "AbilityUpgrades", p }) or 0
		end

		return nil
	else
		if not isClient then
			return nil
		end

		assert(
			instance == Players.LocalPlayer,
			"Can't call `getEquippedAbility` in client for another player that is not LocalPlayer"
		)
		local replion = v3.Client:GetReplion("Data")

		if replion then
			return replion:Get({ "AbilityUpgrades", p }) or 0
		end

		return nil
	end
end

function AbilityUtils.onEquip(instance, callback)
	if typeof(instance) ~= "Instance" then
		return v4.new()
	end

	local maid = v4.new()
	local equippedAbility = getEquippedAbility(instance)

	local function updateAbility()
		local equippedAbility2 = getEquippedAbility(instance)

		if equippedAbility2 and equippedAbility and equippedAbility.Name == equippedAbility2.Name then
			return
		end

		if isServer and equippedAbility2 then
			instance:SetAttribute("CurrentlyEquippedAbility", equippedAbility2.Name)
		end

		task.spawn(callback, equippedAbility2, equippedAbility)
		equippedAbility = equippedAbility2
	end

	if isServer then
		maid:Add(v10.Server:OnEquip(instance, "Ability", updateAbility))
	elseif isClient then
		assert(
			instance == Players.LocalPlayer,
			"Can't call `getEquippedAbility` in client for another player that is not LocalPlayer"
		)
		maid:Add(v10.Client:OnEquip("Ability", updateAbility))
	end

	maid:Add(instance:GetAttributeChangedSignal("AbilityOverride"):Connect(updateAbility))
	maid:Add(task.defer(updateAbility))
	return maid
end

return AbilityUtils