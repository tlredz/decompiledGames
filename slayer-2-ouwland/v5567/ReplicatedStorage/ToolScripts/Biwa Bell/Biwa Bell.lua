local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local SequenceTeleport = require(ReplicatedStorage.CAM.Client.Modules.SequenceTeleport)
local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification
local BiwaBell = {}
local localPlayer = Players.LocalPlayer
local biwaBellServer = script.Parent:WaitForChild("Biwa BellServer")
local v = MuzanSettings.LairRingLength - MuzanSettings.LairFallLead + MuzanSettings.LairFallDelay
local v2 = v + MuzanSettings.LairTeleportAtFall
local v3 = v + MuzanSettings.LairFallLength
local v4 = v3 + MuzanSettings.LairRiseLength
local v5 = nil

local function setHeadCam()
	local character = localPlayer.Character
	local head = character ~= nil and character:FindFirstChild("Head") or nil
	local getvaluesfolder = Utility.getvaluesfolder(localPlayer)

	if head == nil or getvaluesfolder == nil then
		return
	end

	if v5 == nil or v5.Parent == nil then
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "camsubject"
		objectValue.Parent = getvaluesfolder
		v5 = objectValue
	end

	v5.Value = head
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHeadCam()
	if v5 ~= nil then
		v5:Destroy()
		v5 = nil
	end
end

local v6 = nil

local function syncLairZoom(instance)
	if instance:GetAttribute("InMuzanLair") == true then
		local getvaluesfolder = Utility.getvaluesfolder(localPlayer)

		if getvaluesfolder == nil then
			return
		end

		if v6 == nil or v6.Parent == nil then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = "MaxZoom"
			numberValue.Value = MuzanSettings.LairMaxZoom
			numberValue.Parent = getvaluesfolder
			v6 = numberValue
		end
	elseif v6 ~= nil then
		v6:Destroy()
		v6 = nil
	end
end

local function hookLairZoom(object)
	object:GetAttributeChangedSignal("InMuzanLair"):Connect(function()
		syncLairZoom(object)
	end)
	syncLairZoom(object)
end

if localPlayer.Character ~= nil then
	local character = localPlayer.Character
	character:GetAttributeChangedSignal("InMuzanLair"):Connect(function()
		syncLairZoom(character)
	end)
	syncLairZoom(character)
end

localPlayer.CharacterAdded:Connect(hookLairZoom)
local v7 = nil
local now = 0
local now2 = 0

local function startSequence()
	now = os.clock()
	clearHeadCam() -- equivalent call inferred; original call site unknown
	v7 = SequenceTeleport.Start({
		Ring = biwaBellServer:FindFirstChild("BiwaBellRing"),
		Fall = biwaBellServer:FindFirstChild("TeleportFall"),
		Rise = biwaBellServer:FindFirstChild("TeleportRise"),
		RingLength = MuzanSettings.LairRingLength,
		FallLead = MuzanSettings.LairFallLead,
		FallDelay = MuzanSettings.LairFallDelay,
		FallLength = MuzanSettings.LairFallLength,
		TeleportAtFall = MuzanSettings.LairTeleportAtFall,
		RiseLength = MuzanSettings.LairRiseLength,
		CoverDelay = 0.5,
		UncoverLead = 0.5,
		LockName = `{localPlayer.Name}_BiwaBellLock`,
		OnCovered = function()
			local character = localPlayer.Character

			if character ~= nil then
				character:SetAttribute("InMuzanLair", localPlayer:GetAttribute(MuzanSettings.LairAttribute) == true)
			end
		end
	})
end

localPlayer:GetAttributeChangedSignal(MuzanSettings.LairAttribute):Connect(function()
	local v8 = localPlayer:GetAttribute(MuzanSettings.LairAttribute) == true
	local character = localPlayer.Character
	local v9

	if character ~= nil then
		v9 = character:FindFirstChild("HumanoidRootPart") or nil
	end

	if character == nil or v9 == nil then
		return
	end

	local lairArrival

	if v8 then
		lairArrival = MuzanSettings.LairArrival
	else
		lairArrival = localPlayer:GetAttribute(MuzanSettings.LairReturnAttribute)

		if typeof(lairArrival) ~= "CFrame" then
			if v7 ~= nil and v7.IsActive() then
				v7.Cancel()
				v7 = nil
			end

			character:SetAttribute("InMuzanLair", false)
			clearHeadCam() -- equivalent call inferred; original call site unknown
			return
		end
	end

	if v7 == nil or not (v7.IsActive() and v7.SetDestination(lairArrival)) then
		clearHeadCam() -- equivalent call inferred; original call site unknown
		now = os.clock() - v2
		v7 = SequenceTeleport.Start({
			FallLength = 0,
			TeleportAtFall = 0,
			RiseLength = 0,
			LockName = `{localPlayer.Name}_BiwaBellLock`,
			Destination = lairArrival,
			OnCovered = function()
				character:SetAttribute("InMuzanLair", v8)
			end
		})
	else
		task.delay(v3 - v2, setHeadCam)
		task.delay(v4 - v2 + 0.5, clearHeadCam)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function worldAllows()
	local v8 = Worlds.ById[game.PlaceId]

	if v8 ~= nil and v8.BiwaBellEnabled == true then
		return true
	end

	notification:Fire("Notify", {
		Text = "Can't use biwa bell here",
		Type = "Denied"
	})
	return false
end

function BiwaBell.check(_, _: string)
	-- equivalent call inferred; original call site unknown
	if not worldAllows() then
		return false
	end

	if localPlayer:GetAttribute(MuzanSettings.LairAttribute) == true or not InCombat.biasedCheck(localPlayer) then
		return true
	end

	notification:Fire("Notify", {
		Text = `Can't enter the lair while in combat ({Utility.formatTime(InCombat.biasedTimeLeft(localPlayer))} left)`,
		Type = "Denied"
	})
	return false
end

function BiwaBell.MouseDown(instance, p: string)
	-- equivalent call inferred; original call site unknown
	if not (worldAllows() and instance ~= nil) then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or not Checker.check(localPlayer, nil, "BiwaBell") then
		return
	end

	local data = Utility.GetData(localPlayer)

	if data == nil or Utility.HeldItem(data, p) == nil or v7 ~= nil and v7.IsActive() then
		return
	end

	if os.clock() < now + v4 + 1 or os.clock() - now2 < 1 then
		return
	end

	now2 = os.clock()

	if localPlayer:GetAttribute(MuzanSettings.LairAttribute) ~= true then
		local reputation = data:FindFirstChild("Reputation")

		if reputation == nil or reputation.Value >= MuzanSettings.LairEntryReputation or Quests.GetPlayerQuestState(
			localPlayer,
			MuzanSettings.LairBlockedQuest
		) == "Doing" or InCombat.biasedCheck(localPlayer) then
			return
		end
	end

	startSequence()
end

function BiwaBell.UnEquipped(_, _: string?)
	if v7 == nil or v <= os.clock() - now then
		return
	end

	v7.Cancel()
	v7 = nil
	now = 0
end

return BiwaBell