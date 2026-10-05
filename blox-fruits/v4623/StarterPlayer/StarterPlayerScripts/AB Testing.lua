local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:FindFirstChild("CommF_")
local questUpdate = remotes:FindFirstChild("QuestUpdate")
local localPlayer = game.Players.LocalPlayer
local TestingGroupUtil = require(ReplicatedStorage.TestingGroupUtil)
local Effect = require(ReplicatedStorage.Effect)
local GuideModule = require(ReplicatedStorage.GuideModule)
local IrisLog = require(ReplicatedStorage.Util:WaitForChild("IrisLog"))
local AETESTING = IrisLog.new("A/E TESTING", "Tester", {
	Hidden = true
})
AETESTING:EnsureTab("Log")
AETESTING:EnsureTab("Tools")
local Global = require(game.ReplicatedStorage.Global)
local AB_TEST_OVERRIDES = Global.AB_TEST_OVERRIDES

if typeof(AB_TEST_OVERRIDES) ~= "table" then
	AB_TEST_OVERRIDES = {}
	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.AB_TEST_OVERRIDES = AB_TEST_OVERRIDES
end

local function GetOverride(p: string)
	return AB_TEST_OVERRIDES[p]
end

local function SetOverride(p: string, p2)
	AB_TEST_OVERRIDES[p] = p2
end

local function ClearOverride(p: string)
	AB_TEST_OVERRIDES[p] = nil
end

local v = nil
local v2 = nil
local v3 = "NormalFlow"
local flag = false
local v4 = "Normal"
local v5 = false
local v6 = false
local v7 = false
local v8 = false
local flag2 = false
local v9 = false

local function IsMarines()
	local team = localPlayer.Team
	local name = team and team.Name or ""
	return typeof(name) == "string" and string.lower(name) == "marines"
end

local function ActiveQuestInternal()
	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v10

	if typeof(name) == "string" then
		v10 = string.lower(name) == "marines"
	else
		v10 = false
	end

	if v10 then
		return "MarineQuest"
	end

	return "BanditQuest1"
end

local function ActiveEnemyName()
	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v10

	if typeof(name) == "string" then
		v10 = string.lower(name) == "marines"
	else
		v10 = false
	end

	if v10 then
		return "Trainee"
	end

	return "Bandit"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearLogTab()
	local tab = AETESTING:EnsureTab("Log")
	table.clear(tab.Lines)
end

local function SetQuestLog(p: string?, p2: string?)
	ClearLogTab() -- equivalent call inferred; original call site unknown

	if p == "Force" and p2 then
		AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2 forced -> "), (tostring(p2)))
	elseif p == "UseAB" then
		AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2 using AB"))
	end

	AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2: "), (tostring(v4)))
	AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1: "), (tostring(v3)))
end

local function SetCombatLog(p: string?, value: string?)
	ClearLogTab() -- equivalent call inferred; original call site unknown

	if p == "Force" and typeof(value) == "string" then
		AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1 forced -> "), (tostring(value)))
	elseif p == "UseAB" then
		AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1 using AB"))
	end

	AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2: "), (tostring(v4)))
	AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1: "), (tostring(v9)))
end

local function GetLevel()
	local data = localPlayer:FindFirstChild("Data")

	if not data then
		return
	end

	local level = data:FindFirstChild("Level")

	if level and level:IsA("IntValue") then
		return level
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRoot()
	return ((localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart"))
end

local function GetVariantFromAB()
	local v10 = TestingGroupUtil.getGroup(localPlayer.UserId, "QuestStatesV2"):await()
	v10:inspectErr(warn)
	local nullable = v10:asNullable()

	if typeof(nullable) == "string" and (nullable == "Normal" or nullable == "AutoQuestNoRetrack") then
		return nullable
	end

	warn("[QuestStatesV2] bad AB value:", nullable, (typeof(nullable)))
	return nil
end

local function GetCombatFromAB()
	local v10 = TestingGroupUtil.getGroup(localPlayer.UserId, "CombatEquipV1"):await()
	v10:inspectErr(warn)
	local nullable = v10:asNullable()

	if typeof(nullable) == "string" and (nullable == "NormalFlow" or nullable == "StartEquipped") then
		return nullable
	end

	warn("[CombatEquipV1] bad AB value:", nullable, (typeof(nullable)))
	return nil
end

local function FindQuestGiver(p: string)
	local nPCList = GuideModule.Data and GuideModule.Data.NPCList

	if type(nPCList) ~= "table" then
		return nil
	end

	for instance, v10 in pairs(nPCList) do
		if not (type(v10) == "table" and v10.InternalQuestName == p and typeof(instance) == "Instance") then
			continue
		end

		if instance:IsA("BasePart") then
			return instance
		end

		if not instance:IsA("Model") then
			continue
		end

		local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")

		if primaryPart then
			return primaryPart
		end
	end

	return nil
end

local function WaitForQuestGiver(value: number?)
	local v10 = value or 8
	local lastTime = os.clock()
	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v11

	if typeof(name) == "string" then
		v11 = string.lower(name) == "marines"
	else
		v11 = false
	end

	local v12

	if v11 then
		v12 = "MarineQuest"
	else
		v12 = "BanditQuest1"
	end

	while os.clock() - lastTime < v10 do
		local questGiver = FindQuestGiver(v12)

		if questGiver then
			return questGiver
		else
			task.wait(0.2)
		end
	end

	return (FindQuestGiver(v12))
end

local v10 = false
local v11 = nil

local function TraceStart(p, p2)
	if not p2 or v10 and v11 == p2 then
		return
	end

	v10 = true
	v11 = p2
	Effect.new("QuestTracingLine"):play({ p, p2, 1 })
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TraceStop(p)
	if not v10 then
		return
	end

	if v11 then
		Effect.new("QuestTracingLine"):play({ p, v11, 2 })
	end

	v10 = false
	v11 = nil
end

local flag3 = false
local childAddedConnection = nil

local function isBanditModel(p)
	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v13 = typeof(name) == "string" and string.lower(name) == "marines" and "Trainee" or "Bandit"
	local name2 = p.Name
	return name2 == v13 or string.find(string.lower(name2), string.lower(v13), 1, true) ~= nil
end

local function NotifierToEnemies(humanoidRootPart)
	for _, billboardGui in ipairs(humanoidRootPart:GetChildren()) do
		if billboardGui:IsA("BillboardGui") and billboardGui:GetAttribute("QuestBanditMarker") == true then
			return
		end
	end

	local clone = ReplicatedStorage.Assets.GUI:WaitForChild("EnemyNotifier"):Clone()
	clone:SetAttribute("QuestBanditMarker", true)
	clone.Adornee = humanoidRootPart
	clone.Parent = humanoidRootPart
end

local function ClearEnemiesNotifiers()
	local enemies = workspace:FindFirstChild("Enemies")

	if not enemies then
		return
	end

	for _, billboardGui in ipairs(enemies:GetDescendants()) do
		if billboardGui:IsA("BillboardGui") and billboardGui:GetAttribute("QuestBanditMarker") == true then
			billboardGui:Destroy()
		end
	end
end

local function setIndicatorsEnabled(flag4: boolean)
	if flag4 then
		if flag3 then
			return
		end

		flag3 = true
		local enemies = workspace:FindFirstChild("Enemies")

		if not enemies then
			return
		end

		for _, model in ipairs(enemies:GetChildren()) do
			if not model:IsA("Model") then
				continue
			end

			local team = localPlayer.Team
			local name = team and team.Name or ""
			local v13 = typeof(name) == "string" and string.lower(name) == "marines" and "Trainee" or "Bandit"
			local name2 = model.Name

			if not (name2 == v13 or string.find(string.lower(name2), string.lower(v13), 1, true) ~= nil) then
				continue
			end

			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart

			if humanoidRootPart then
				NotifierToEnemies(humanoidRootPart)
			end
		end

		childAddedConnection = enemies.ChildAdded:Connect(function(model)
			if not flag3 then
				return
			end

			if model:IsA("Model") then
				local team = localPlayer.Team
				local name = team and team.Name or ""
				local v13 = typeof(name) == "string" and string.lower(name) == "marines" and "Trainee" or "Bandit"
				local name2 = model.Name

				if name2 == v13 or string.find(string.lower(name2), string.lower(v13), 1, true) ~= nil then
					task.wait(0.1)
					local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart

					if humanoidRootPart then
						NotifierToEnemies(humanoidRootPart)
					end
				end
			end
		end)
	else
		flag3 = false

		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		ClearEnemiesNotifiers()
	end
end

local function isBanditQuestFromQuest(p)
	if typeof(p) ~= "table" then
		return false
	end

	local task2 = p.Task
	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v12

	if typeof(name) == "string" then
		v12 = string.lower(name) == "marines"
	else
		v12 = false
	end

	if typeof(task2) == "table" and task2[v12 and "Trainee" or "Bandit"] ~= nil then
		return true
	end

	local internalQuestName = p.InternalQuestName

	if typeof(internalQuestName) ~= "string" then
		return false
	end

	local team2 = localPlayer.Team
	local name2 = team2 and team2.Name or ""
	local v13

	if typeof(name2) == "string" then
		v13 = string.lower(name2) == "marines"
	else
		v13 = false
	end

	return internalQuestName == (v13 and "MarineQuest" or "BanditQuest1")
end

local function isBanditQuestFromInfo(p)
	if typeof(p) ~= "table" then
		return false
	end

	local internalQuestName = p.InternalQuestName

	if typeof(internalQuestName) ~= "string" then
		return false
	end

	local team = localPlayer.Team
	local name = team and team.Name or ""
	local v12

	if typeof(name) == "string" then
		v12 = string.lower(name) == "marines"
	else
		v12 = false
	end

	return internalQuestName == (v12 and "MarineQuest" or "BanditQuest1")
end

local function applyTEST(p: string, p2: string?)
	v4 = p
	v5 = p == "Retrack" or p == "NoRetrack"
	v6 = p == "Retrack" or p == "AutoQuestRetrack"
	v7 = p == "AutoQuestNoRetrack" or p == "AutoQuestRetrack"
	v8 = p == "AutoQuestNoRetrack" or p == "AutoQuestRetrack"
	local root = GetRoot() -- equivalent call inferred; original call site unknown
	TraceStop(root) -- equivalent call inferred; original call site unknown
	flag3 = false

	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	ClearEnemiesNotifiers()
	flag2 = false

	if v5 then
		TraceStart(root, WaitForQuestGiver(3))
	end

	if v8 then
		pcall(function()
			local team = localPlayer.Team
			local name = team and team.Name or ""
			return commF_:InvokeServer(
				"StartQuest",
				typeof(name) == "string" and string.lower(name) == "marines" and "MarineQuest" or "BanditQuest1",
				1
			)
		end)
		flag2 = true
		TraceStop(root) -- equivalent call inferred; original call site unknown
		setIndicatorsEnabled(v7)
	end

	if p2 then
		if p2 ~= "Force" then
			p = nil
		end

		SetQuestLog(p2, p)
	end
end

local function TryCombatEquipNow()
	local data = localPlayer:FindFirstChild("Data")
	local level

	if data then
		level = data:FindFirstChild("Level")

		if not (level and level:IsA("IntValue")) then
			level = nil
		end
	end

	if not level or level.Value >= 10 or not v9 then
		return
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local backpack = localPlayer:FindFirstChild("Backpack")

	if not backpack then
		return
	end

	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			return
		end
	end

	local v12 = nil

	for _, tool in ipairs(backpack:GetChildren()) do
		if not (tool:IsA("Tool") and tool.ToolTip == "Melee") then
			continue
		end

		v12 = tool
		break
	end

	if not v12 then
		return
	end

	pcall(function()
		if humanoid then
			humanoid:EquipTool(v12)
		else
			v12.Parent = character
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCombatEquip(p: string, p2: string?)
	v3 = p
	v9 = p == "StartEquipped"

	if v9 then
		task.spawn(function()
			task.wait(0.15)
			TryCombatEquipNow()
		end)
	end

	if p2 and p2 ~= "Init" then
		if p2 ~= "Force" then
			p = nil
		end

		SetCombatLog(p2, p)
	elseif p2 == "Init" then
		ClearLogTab() -- equivalent call inferred; original call site unknown
		AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2: "), (tostring(v4)))
		AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1: "), (tostring(v9)))
	end
end

local function BuildToggleTabOnce()
	if flag then
		return
	end

	flag = true
	AETESTING:AppendToTab("Tools", AETESTING:Gold("QuestStatesV2"))

	for _, v12 in ipairs({ "AutoQuestNoRetrack" }) do
		local questStatesV = v12
		AETESTING:AppendToTab("Tools", AETESTING:Button(`Force {v12}`, function()
			AB_TEST_OVERRIDES.QuestStatesV2 = questStatesV
			applyTEST(questStatesV, "Force")
		end))
	end

	AETESTING:AppendToTab("Tools", AETESTING:NewLine())
	AETESTING:AppendToTab("Tools", AETESTING:Button("Current State", function()
		AB_TEST_OVERRIDES.QuestStatesV2 = nil
		task.spawn(function()
			local variantFromAB = GetVariantFromAB()
			v = variantFromAB
			applyTEST(variantFromAB or "Normal", "UseAB")
		end)
	end))
	AETESTING:AppendToTab("Tools", AETESTING:NewLine())
	AETESTING:AppendToTab("Tools", AETESTING:Gold("CombatEquipV1"))
	AETESTING:AppendToTab("Tools", AETESTING:Button("Force StartEquipped", function()
		AB_TEST_OVERRIDES.CombatEquipV1 = "StartEquipped"
		v3 = "StartEquipped"
		v9 = true
		task.spawn(function()
			task.wait(0.15)
			TryCombatEquipNow()
		end)
		SetCombatLog("Force", "StartEquipped")
	end))
	AETESTING:AppendToTab("Tools", AETESTING:Button("Force NormalFlow", function()
		AB_TEST_OVERRIDES.CombatEquipV1 = "NormalFlow"
		v3 = "NormalFlow"
		v9 = false
		SetCombatLog("Force", "NormalFlow")
	end))
	AETESTING:AppendToTab("Tools", AETESTING:NewLine())
	AETESTING:AppendToTab("Tools", AETESTING:Button("Current State (AB)", function()
		AB_TEST_OVERRIDES.CombatEquipV1 = nil
		task.spawn(function()
			local combatFromAB = GetCombatFromAB()
			v2 = combatFromAB
			applyCombatEquip(combatFromAB or "NormalFlow") -- equivalent call inferred; original call site unknown
			ClearLogTab() -- equivalent call inferred; original call site unknown
			AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1 using AB"))
			AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2: "), (tostring(v4)))
			AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1: "), (tostring(v9)))
		end)
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BanditQuestAccepted()
	local root = GetRoot() -- equivalent call inferred; original call site unknown
	TraceStop(root) -- equivalent call inferred; original call site unknown
	flag2 = true
	setIndicatorsEnabled(v7)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BanditQuestCompleted()
	local root = GetRoot() -- equivalent call inferred; original call site unknown
	flag3 = false

	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	ClearEnemiesNotifiers()
	flag2 = false

	if v6 then
		TraceStart(root, WaitForQuestGiver(3))
		return
	end

	TraceStop(root) -- equivalent call inferred; original call site unknown
end

local function QuestUpdate(p, p2)
	local data = localPlayer:FindFirstChild("Data")
	local level

	if data then
		level = data:FindFirstChild("Level")

		if not (level and level:IsA("IntValue")) then
			level = nil
		end
	end

	if not level then
		return
	end

	if level.Value >= 10 then
		local root = GetRoot() -- equivalent call inferred; original call site unknown
		TraceStop(root) -- equivalent call inferred; original call site unknown
		flag3 = false

		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		ClearEnemiesNotifiers()
		flag2 = false
	else
		local v12 = typeof(p2) ~= "table" and {} or p2.Context or {}
		local v13

		if typeof(p) == "table" then
			local task2 = p.Task
			local team = localPlayer.Team
			local name = team and team.Name or ""
			local v14

			if typeof(name) == "string" then
				v14 = string.lower(name) == "marines"
			else
				v14 = false
			end

			if typeof(task2) == "table" and task2[v14 and "Trainee" or "Bandit"] ~= nil then
				v13 = true
			else
				local internalQuestName = p.InternalQuestName

				if typeof(internalQuestName) == "string" then
					local team2 = localPlayer.Team
					local name2 = team2 and team2.Name or ""
					v13 = internalQuestName == (typeof(name2) == "string" and string.lower(name2) == "marines" and "MarineQuest" or "BanditQuest1")
				else
					v13 = false
				end
			end
		else
			v13 = false
		end

		if not v13 then
			if typeof(p2) == "table" then
				local internalQuestName = p2.InternalQuestName

				if typeof(internalQuestName) == "string" then
					local team = localPlayer.Team
					local name = team and team.Name or ""
					v13 = internalQuestName == (typeof(name) == "string" and string.lower(name) == "marines" and "MarineQuest" or "BanditQuest1")
				else
					v13 = false
				end
			else
				v13 = false
			end
		end

		if flag2 and not v13 then
			local root = GetRoot() -- equivalent call inferred; original call site unknown
			TraceStop(root) -- equivalent call inferred; original call site unknown
			flag3 = false

			if childAddedConnection then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end

			ClearEnemiesNotifiers()
			flag2 = false
		elseif v12 == "Complete" and v13 then
			BanditQuestCompleted() -- equivalent call inferred; original call site unknown
		elseif v13 then
			if flag2 then
				setIndicatorsEnabled(v7)
			else
				BanditQuestAccepted() -- equivalent call inferred; original call site unknown
			end
		end
	end
end

task.delay(2, function()
	local data = localPlayer:FindFirstChild("Data")
	local level

	if data then
		level = data:FindFirstChild("Level")

		if not (level and level:IsA("IntValue")) then
			level = nil
		end
	end

	if not level or level.Value >= 10 then
		return
	end

	BuildToggleTabOnce()
	v = GetVariantFromAB()
	v2 = GetCombatFromAB()
	local questStatesV2 = AB_TEST_OVERRIDES.QuestStatesV2
	local v12 = typeof(questStatesV2) == "string" and questStatesV2 or v or "Normal"
	local combatEquipV1 = AB_TEST_OVERRIDES.CombatEquipV1
	local v13 = typeof(combatEquipV1) == "string" and combatEquipV1 or v2 or "NormalFlow"
	local v14 = v13 ~= "NormalFlow" and v13 ~= "StartEquipped" and "NormalFlow" or v13
	applyTEST(v12, "Init")
	v3 = v14
	v9 = v14 == "StartEquipped"

	if v9 then
		task.spawn(function()
			task.wait(0.15)
			TryCombatEquipNow()
		end)
	end

	ClearLogTab() -- equivalent call inferred; original call site unknown
	AETESTING:AppendToTab("Log", AETESTING:Gold("QuestStatesV2: "), (tostring(v4)))
	AETESTING:AppendToTab("Log", AETESTING:Gold("CombatEquipV1: "), (tostring(v9)))
	questUpdate.OnClientEvent:Connect(QuestUpdate)
end)