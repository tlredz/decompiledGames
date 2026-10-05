local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local GUI = require(ReplicatedStorage.Client.GUI)
local Hud = require(ReplicatedStorage.Client.Hud)
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local Save = require(ReplicatedStorage.Shared.Save)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, -1, true)
local localPlayer = Players.LocalPlayer
local screenGui = GUI.ActivePets()
local v = Hud.Find("PetsButton")
local equipBest = screenGui.Frame.EquipBest
local badge

if v == nil then
	badge = nil
else
	badge = v:FindFirstChild("Badge")
end

local badge2 = equipBest:FindFirstChild("Badge")
local v2 = nil
local v3 = nil
assert(screenGui:IsA("ScreenGui"), "PlayerGui.ActivePets must be a ScreenGui")
assert(equipBest:IsA("GuiButton"), "ActivePets.Frame.EquipBest must be a GuiButton")

local function stopBadgePulse(p, instance)
	if instance ~= nil then
		instance:Cancel()
		instance:Destroy()
	end

	if p == nil then
		return nil
	end

	local ensureUIScale = EnsureUIScale(p)
	ensureUIScale.Scale = 1
	p.Visible = false
	return nil
end

local function startBadgePulse(badge3, p)
	if badge3 == nil then
		return nil
	end

	badge3.Visible = true

	if p ~= nil then
		return p
	end

	local uIScale = EnsureUIScale(badge3)
	uIScale.Scale = 0.8
	local tween = TweenService:Create(uIScale, tweenInfo, {
		Scale = 1.2
	})
	tween:Play()
	return tween
end

local function refresh()
	local v4 = Save.Await(localPlayer)
	local petPenCapacityGuidance

	if v4 ~= nil then
		petPenCapacityGuidance = v4.PetPenCapacityGuidance
	end

	local v5

	if petPenCapacityGuidance == nil then
		v5 = false
	else
		v5 = petPenCapacityGuidance.Triggered and not petPenCapacityGuidance.PetsTabAcknowledged
	end

	local v6

	if petPenCapacityGuidance == nil then
		v6 = false
	else
		v6 = petPenCapacityGuidance.Triggered and not petPenCapacityGuidance.EquipBestAcknowledged
	end

	if v5 then
		v2 = startBadgePulse(badge, v2)
	else
		local v7 = badge
		local v8 = v2

		if v8 ~= nil then
			v8:Cancel()
			v8:Destroy()
		end

		if v7 ~= nil then
			local ensureUIScale = EnsureUIScale(v7)
			ensureUIScale.Scale = 1
			v7.Visible = false
		end

		v2 = nil
	end

	if v6 then
		v3 = startBadgePulse(badge2, v3)
		return
	end

	local v7 = badge2
	local v8 = v3

	if v8 ~= nil then
		v8:Cancel()
		v8:Destroy()
	end

	if v7 ~= nil then
		local ensureUIScale_2 = EnsureUIScale(v7)
		ensureUIScale_2.Scale = 1
		v7.Visible = false
	end

	v3 = nil
end

local PetPenCapacityGuidanceController = {}

function PetPenCapacityGuidanceController.AcknowledgePetsBadge()
	if badge == nil or not badge.Visible then
		return
	end

	local v4 = badge
	local v5 = v2

	if v5 ~= nil then
		v5:Cancel()
		v5:Destroy()
	end

	if v4 ~= nil then
		local ensureUIScale = EnsureUIScale(v4)
		ensureUIScale.Scale = 1
		v4.Visible = false
	end

	v2 = nil
	task.spawn(function()
		local v7, v8 = TryCall(AssetRoster.AckPetsBadge)

		if not v7 or v8 ~= true then
			refresh()
		end
	end)
end

function PetPenCapacityGuidanceController.AcknowledgeEquipBestBadge()
	if badge2 == nil or not badge2.Visible then
		return
	end

	local v4 = badge2
	local v5 = v3

	if v5 ~= nil then
		v5:Cancel()
		v5:Destroy()
	end

	if v4 ~= nil then
		local ensureUIScale = EnsureUIScale(v4)
		ensureUIScale.Scale = 1
		v4.Visible = false
	end

	v3 = nil
	task.spawn(function()
		local v7, v8 = TryCall(AssetRoster.AckEquipBestBadge)

		if not v7 or v8 ~= true then
			refresh()
		end
	end)
end

function PetPenCapacityGuidanceController.Initialize()
	Save.Watch("PetPenCapacityGuidance"):Connect(refresh)
	task.spawn(refresh)
end

return PetPenCapacityGuidanceController