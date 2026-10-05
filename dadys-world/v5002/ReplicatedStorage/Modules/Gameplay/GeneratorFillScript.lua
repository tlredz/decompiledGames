local createVector = vector.create
local GeneratorFillScript = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local AnalyticsService = require(ReplicatedStorage.Modules.Services.AnalyticsService)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local IchorTransactions = require(ServerStorage.SharedModules.IchorTransactions)
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local MachineSpawnResolver = require(game.ReplicatedStorage.Modules.Gameplay.MachineSpawnResolver)
local MultiGenConfig = require(game.ServerStorage.Modules.Data.MultiGenConfig)
local BarnabyMinigameBridgeServer = require(ServerStorage.Modules.Combat.BarnabyMinigameBridgeServer)
local BarnabyCabinetScreen = require(ServerStorage.Modules.Combat.BarnabyCabinetScreen)
local genSlotSuffix = game.ReplicatedStorage.Modules.Gameplay:FindFirstChild("GenSlotSuffix")
local success, result = pcall(function()
	return genSlotSuffix and require(genSlotSuffix)
end)
local v = success and result or {
	forSlot = function(p)
		if p == 1 then
			return ""
		elseif p == 2 then
			return "_Mirror"
		end

		return "_S" .. p
	end
}
local GeneratorOffsetLookup = require(ReplicatedStorage.Modules.Gameplay.GeneratorOffsetLookup)

local function getGeneratorOffset(p, p2)
	return GeneratorOffsetLookup.forCharacter(p, p2)
end

local function nudgeIfClipped(p, value, folder)
	local primaryPart = value and value.PrimaryPart

	if not primaryPart then
		return p
	end

	local v2 = primaryPart.Size + createVector(0.2, 0.2, 0.2)

	for _, v3 in ipairs(workspace:GetPartBoundsInBox(p, v2)) do
		if not (v3:IsDescendantOf(value) or folder and v3:IsDescendantOf(folder)) and (CollectionService:HasTag(
			v3,
			"Wall"
		) or CollectionService:HasTag(v3, "Obstacle")) then
			return p + createVector(0, 1, 0)
		end
	end

	return p
end

local events = ReplicatedStorage:WaitForChild("Events")
local animateTower = events.AnimateTower
local animationStop = events.AnimationStop
local generatorUpdate = events:WaitForChild("GeneratorUpdate")
local skillcheckUpdate = events:WaitForChild("SkillcheckUpdate")
local editData = game.ReplicatedStorage:FindFirstChild("editData")
local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")
local Players = game:GetService("Players")
local dialogueEvent = ReplicatedStorage.StoryEvents.DialogueEvent
local generatorActivated = ReplicatedStorage.Events.GeneratorActivated
local StatisticsManager = require(ServerStorage.SharedModules.StatisticsManager)
local MachineEffects = require(ReplicatedStorage.Modules.Gameplay.MachineEffects)
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

local function extendPipeStack(instance)
	local pipestacks = instance:GetAttribute("Pipestacks") or 1

	if type(pipestacks) ~= "number" or pipestacks <= 1 then
		return
	end

	local baseMachine = instance:FindFirstChild("BaseMachine") or instance:FindFirstChild("wipGenerator")

	if not baseMachine then
		return
	end

	local v2 = 1e999
	local v3 = -1e999
	local models = {}

	for _, model in ipairs(baseMachine:GetChildren()) do
		if not (model:IsA("Model") and model.Name:match("^Pipe%d*$")) then
			continue
		end

		for _, part in ipairs(model:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			v2 = math.min(v2, part.Position.Y - part.Size.Y / 2)
			v3 = math.max(v3, part.Position.Y + part.Size.Y / 2)
		end

		table.insert(models, model)
	end

	if #models == 0 or v2 == 1e999 then
		return
	end

	local v4 = v3 - v2

	for i = 1, pipestacks - 1 do
		for _, v5 in ipairs(models) do
			local clone = v5:Clone()
			clone.Name = v5.Name .. "_ext" .. i
			clone:PivotTo(v5:GetPivot() + Vector3.new(0, v4 * i, 0))
			clone.Parent = baseMachine
		end
	end
end

local count = 0

function GeneratorFillScript.Initialize(folder)
	if not (folder and folder:IsA("Model")) then
		warn("[GeneratorFillScript] Invalid generator model provided")
		return
	end

	local v2 = {
		"BaseShape_6Slot",
		"BaseShape_8Slot",
		"BaseShape_4SlotCircle",
		"BaseShape_4Slot"
	}
	local v3 = { "TreadmillBase_2Slot", "TreadmillBase_3Slot", "TreadmillBase_4Slot" }
	local baseMachine = folder:FindFirstChild("BaseMachine") or folder:FindFirstChild("wipGenerator")

	if baseMachine then
		for _, childName in ipairs(v2) do
			local child = baseMachine:FindFirstChild(childName)

			if child then
				child:Destroy()
			end
		end
	end

	local treadmillGame = folder:FindFirstChild("TreadmillGame")
	local treadmillBaseVariants = treadmillGame and treadmillGame:FindFirstChild("TreadmillBaseVariants")

	if treadmillBaseVariants then
		for _, childName in ipairs(v3) do
			local child = treadmillBaseVariants:FindFirstChild(childName)

			if child then
				child:Destroy()
			end
		end
	end

	local treadmillGame2 = folder:GetAttribute("MinigameType") ~= "MovementTreadmill" and folder:FindFirstChild("TreadmillGame")

	if treadmillGame2 then
		treadmillGame2:Destroy()
	end

	if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
		count += 1
		local v4 = (folder:GetAttribute("_DebugInitCount") or 0) + 1
		folder:SetAttribute("_DebugInitCount", v4)
		local v5 = debug.traceback("", 2):sub(1, 200)
		print(string.format(
			"[GenFill] INIT call #%d for gen=%s (this gen total inits=%d, isDual=%s)\n%s",
			count,
			folder.Name,
			v4,
			tostring(folder:GetAttribute("IsDualGen")),
			v5
		))
	end

	pcall(extendPipeStack, folder)

	if not folder.Parent then
		return
	end

	local stats = folder:WaitForChild("Stats", 1)

	if not stats then
		warn("[GeneratorFillScript] Generator missing Stats folder after timeout:", folder.Name)
		return
	end

	local v4 = false
	local destroyingConnection = nil
	local ancestryChangedConnection = nil
	local v5 = {}

	local function markDestroyed()
		v4 = true

		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end

		for _, v6 in ipairs(v5) do
			if v6.characterdestroying then
				v6.characterdestroying:Disconnect()
				v6.characterdestroying = nil
			end

			if v6.characterdeath then
				v6.characterdeath:Disconnect()
				v6.characterdeath = nil
			end

			if not v6.playerremoving then
				continue
			end

			v6.playerremoving:Disconnect()
			v6.playerremoving = nil
		end
	end

	destroyingConnection = folder.Destroying:Connect(markDestroyed)
	ancestryChangedConnection = folder.AncestryChanged:Connect(function()
		if not folder:IsDescendantOf(game) then
			markDestroyed()
		end
	end)
	local prompt = folder:WaitForChild("Prompt", 1)

	if not prompt then
		warn("[GeneratorFillScript] Generator missing Prompt:", folder.Name)
		return
	end

	local attachment = prompt:WaitForChild("Attachment", 1)

	if not attachment then
		warn("[GeneratorFillScript] Generator Prompt missing Attachment:", folder.Name)
		return
	end

	local proximityPrompt = attachment:WaitForChild("ProximityPrompt", 1)

	if not proximityPrompt then
		warn("[GeneratorFillScript] Generator missing ProximityPrompt:", folder.Name)
		return
	end

	local flag = false
	local flag2 = false

	if not folder:GetAttribute("MachineId") then
		local position = nil

		if folder:IsA("BasePart") then
			position = folder.Position
		elseif folder:IsA("Model") then
			if folder.PrimaryPart then
				position = folder.PrimaryPart.Position
			else
				position = folder:GetPivot().Position
			end
		end

		local v6

		if position then
			v6 = tostring((math.floor(position.X))) .. "_" .. tostring((math.floor(position.Y))) .. "_" .. tostring((math.floor(position.Z))) .. "_" .. tostring(math.random(
				1000,
				9999
			))
		else
			v6 = tostring(tick()) .. "_" .. tostring(math.random(1000, 9999))
		end

		folder:SetAttribute("MachineId", v6)
	end

	local animations = {}

	for _, animation in ipairs(folder:GetDescendants()) do
		if animation:IsA("Animation") and animation.AnimationId ~= "" then
			table.insert(animations, animation)
		end
	end

	task.spawn(function()
		if #animations > 0 then
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(animations)
			end)
		end

		for _, animationController in ipairs(folder:GetDescendants()) do
			if not animationController:IsA("AnimationController") then
				continue
			end

			local v6 = animationController:FindFirstChildOfClass("Animator")

			if not v6 then
				v6 = Instance.new("Animator")
				v6.Parent = animationController
			end

			local reveal = animationController:FindFirstChild("Reveal")
			local idle = animationController:FindFirstChild("Idle")

			if reveal and reveal:IsA("Animation") and not object[animationController] then
				local v7 = reveal
				local success2, result2 = pcall(function()
					return v6:LoadAnimation(v7)
				end)

				if success2 and result2 then
					result2.Looped = false
					result2.Priority = Enum.AnimationPriority.Action
					object[animationController] = result2
					result2:Play(0, 0, 0)
					local RunService = game:GetService("RunService")
					RunService.Heartbeat:Wait()
					result2:Stop(0)
				end
			end

			if idle and idle:IsA("Animation") and not object2[animationController] then
				local v7 = idle
				local success2, result2 = pcall(function()
					return v6:LoadAnimation(v7)
				end)

				if success2 and result2 then
					result2.Looped = true
					result2.Priority = Enum.AnimationPriority.Idle
					object2[animationController] = result2
				end
			end

			local v7 = object[animationController]
			local v8 = object2[animationController]

			if not v7 or not v8 or animationController:GetAttribute("_RevealIdleWired") then
				continue
			end

			animationController:SetAttribute("_RevealIdleWired", true)
			local v9 = v8
			v7.Stopped:Connect(function()
				if not v9.IsPlaying then
					v9:Play()
				end
			end)
		end
	end)
	local minigameType = folder:GetAttribute("MinigameType")
	local v6 = {
		[""] = minigameType,
		_Mirror = folder:GetAttribute("Prompt" .. 2 .. "MinigameType"),
		["_S" .. 3] = folder:GetAttribute("Prompt" .. 3 .. "MinigameType"),
		["_S" .. 4] = folder:GetAttribute("Prompt" .. 4 .. "MinigameType"),
		["_S" .. 5] = folder:GetAttribute("Prompt" .. 5 .. "MinigameType"),
		["_S" .. 6] = folder:GetAttribute("Prompt" .. 6 .. "MinigameType"),
		["_S" .. 7] = folder:GetAttribute("Prompt" .. 7 .. "MinigameType"),
		["_S" .. 8] = folder:GetAttribute("Prompt" .. 8 .. "MinigameType")
	}

	local function setOverlayVisible(folder2, p, p2)
		if not folder2 then
			return
		end

		if p then
			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("MeshPart") then
					if descendant:GetAttribute("_OriginalTransparency") == nil then
						descendant:SetAttribute("_OriginalTransparency", descendant.Transparency)
					end

					descendant.Transparency = descendant:GetAttribute("_OriginalTransparency") or 0
				end

				if descendant:IsA("BasePart") then
					if descendant:GetAttribute("_OriginalCanCollide") == nil then
						descendant:SetAttribute("_OriginalCanCollide", descendant.CanCollide)
					end

					descendant.CanCollide = descendant:GetAttribute("_OriginalCanCollide") == true
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					if descendant:GetAttribute("_OriginalTransparency") == nil then
						descendant:SetAttribute("_OriginalTransparency", descendant.Transparency)
					end

					descendant.Transparency = descendant:GetAttribute("_OriginalTransparency") or 0
				end
			end
		else
			if p2 then
				folder2:Destroy()
				return
			end

			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("MeshPart") then
					if descendant:GetAttribute("_OriginalTransparency") == nil then
						descendant:SetAttribute("_OriginalTransparency", descendant.Transparency)
					end

					descendant.Transparency = 1
				end

				if descendant:IsA("BasePart") then
					if descendant:GetAttribute("_OriginalCanCollide") == nil then
						descendant:SetAttribute("_OriginalCanCollide", descendant.CanCollide)
					end

					descendant.CanCollide = false
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					if descendant:GetAttribute("_OriginalTransparency") == nil then
						descendant:SetAttribute("_OriginalTransparency", descendant.Transparency)
					end

					descendant.Transparency = 1
				end
			end
		end
	end

	for _, v7 in ipairs({
		"",
		"_Mirror",
		"_S3",
		"_S4",
		"_S5",
		"_S6",
		"_S7",
		"_S8"
	}) do
		local v8 = v6[v7]
		setOverlayVisible(folder:FindFirstChild("CircleMinigame" .. v7), v8 == "Circle", true)
		setOverlayVisible(folder:FindFirstChild("TreadmillGame" .. v7), v8 == "MovementTreadmill")
		local folder2 = folder:FindFirstChild("SwimmyBarnaby" .. v7)
		local v9 = v8 == "Barnaby"
		setOverlayVisible(folder2, v9, true)

		if not (v9 and folder2) then
			continue
		end

		pcall(function()
			BarnabyCabinetScreen.Set(folder, "idle")
		end)
		pcall(function()
			BarnabyCabinetScreen.StartGlowPulse(folder)
		end)

		for _, light in ipairs(folder2:GetDescendants()) do
			if light:IsA("Light") and light.Name ~= "BarnabyIdleGlow" then
				light.Enabled = false
			end
		end
	end

	local function setHidden(folder2, p)
		if folder2:IsA("BasePart") then
			if not folder2:GetAttribute("_OriginalTransparency") then
				folder2:SetAttribute("_OriginalTransparency", folder2.Transparency)
			end

			folder2.Transparency = p and 1 or folder2:GetAttribute("_OriginalTransparency") or 0
		elseif folder2:IsA("Model") then
			for _, part in ipairs(folder2:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				if not part:GetAttribute("_OriginalTransparency") then
					part:SetAttribute("_OriginalTransparency", part.Transparency)
				end

				part.Transparency = p and 1 or part:GetAttribute("_OriginalTransparency") or 0
			end
		end
	end

	local function applyLightSwap(p, p2)
		local child = folder:FindFirstChild("QuickLinks" .. p)
		local defaultLight = child and child:FindFirstChild("DefaultLight")

		if defaultLight then
			for _, objectValue in ipairs(defaultLight:GetChildren()) do
				if objectValue:IsA("ObjectValue") and objectValue.Value then
					setHidden(objectValue.Value, p2)
				end
			end
		end

		local objectValue = folder:FindFirstChild("TreadmillLightReference" .. p)

		if objectValue and objectValue:IsA("ObjectValue") and objectValue.Value then
			setHidden(objectValue.Value, not p2)
		end
	end

	applyLightSwap("", minigameType == "MovementTreadmill")

	for i = 2, 8 do
		if not folder:FindFirstChild("Prompt" .. i) then
			break
		end

		local attribute = folder:GetAttribute("Prompt" .. i .. "MinigameType") or minigameType
		applyLightSwap(i == 2 and "_Mirror" or "_S" .. i, attribute == "MovementTreadmill")
	end

	local v7 = {
		Original = "Extract",
		Circle = "Extract",
		MovementTreadmill = "Run",
		Barnaby = "Play"
	}
	local v8 = {
		"Left",
		"Right",
		"Back",
		"Front",
		"Far Left",
		"Far Right",
		"Back Left",
		"Back Right"
	}
	local v9 = {
		Original = "Machine",
		Circle = "Machine",
		MovementTreadmill = "Treadmill",
		Barnaby = "Arcade"
	}
	local v10 = {
		Original = "Ichor",
		Circle = "Ichor",
		MovementTreadmill = "Treadmill",
		Barnaby = "Arcade"
	}

	local function positionPrompt(childName, p, _, value)
		local part = folder:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			return
		end

		local v11 = value or 1
		part.CanQuery = false
		local proximityPrompt2 = part:FindFirstChild("Attachment") and part.Attachment:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt2 then
			proximityPrompt2.MaxActivationDistance = 6
			proximityPrompt2.RequiresLineOfSight = false
			proximityPrompt2.ObjectText = v7[p] or "Extract"

			if folder:FindFirstChild("Prompt2") ~= nil then
				proximityPrompt2.ActionText = (v8[v11] or "Slot " .. v11) .. " Side " .. (v9[p] or "Machine")
			else
				proximityPrompt2.ActionText = v10[p] or "Ichor"
			end
		end
	end

	positionPrompt("Prompt", minigameType, "", 1)

	for i = 2, 8 do
		if not folder:FindFirstChild("Prompt" .. i) then
			break
		end

		local attribute = folder:GetAttribute("Prompt" .. i .. "MinigameType") or minigameType
		local v11 = i == 2 and "_Mirror" or "_S" .. i
		positionPrompt("Prompt" .. i, attribute, v11, i)
	end

	local v11 = "default"
	local info = workspace:FindFirstChild("Info")

	if info then
		v11 = info:FindFirstChild("ForceMovementTreadmill") and "movement" or folder:GetAttribute("MinigameType") == "MovementTreadmill" and "movement" or v11
	end

	local treadmillTeleportPositions

	if v11 == "movement" then
		treadmillTeleportPositions = folder:FindFirstChild("TreadmillTeleportPositions") or folder:FindFirstChild("TeleportPositions")
	else
		treadmillTeleportPositions = folder:FindFirstChild("TeleportPositions")
	end

	local v12 = not treadmillTeleportPositions and {} or treadmillTeleportPositions:GetChildren() or {}

	if treadmillTeleportPositions then
		for _, _ in pairs(v12) do

		end
	end

	local activePlayer = stats:WaitForChild("ActivePlayer", 1)

	if not activePlayer then
		warn("[GeneratorFillScript] Generator Stats missing primary active-character value:", folder.Name)
		return
	end

	local forSlot = v.forSlot

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPromptName(p)
		if p == 1 then
			return "Prompt"
		end

		return "Prompt" .. p
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getActivePlayerName(p)
		if p == 1 then
			return "ActivePlayer"
		end

		return "ActivePlayer" .. p
	end

	local function ensureActivePlayerValue(p)
		local activePlayerName = getActivePlayerName(p) -- equivalent call inferred; original call site unknown
		local v13 = stats:FindFirstChild(activePlayerName)

		if not v13 then
			v13 = Instance.new("ObjectValue")
			v13.Name = activePlayerName
			v13.Parent = stats
		end

		return v13
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolvePromptPP(i)
		local child = folder:FindFirstChild(getPromptName(i))
		local attachment2 = child and child:FindFirstChild("Attachment")
		return attachment2 and attachment2:FindFirstChildOfClass("ProximityPrompt")
	end

	local minigameType2 = folder:GetAttribute("MinigameType") or "Original"
	table.clear(v5)
	table.insert(v5, {
		index = 1,
		activePlayer = activePlayer,
		prompt = proximityPrompt,
		promptPart = prompt,
		minigameType = minigameType2,
		suffix = ""
	})

	for i = 2, 8 do
		local child = folder:FindFirstChild(getPromptName(i))

		if not child then
			break
		end

		local promptPP = resolvePromptPP(i) -- equivalent call inferred; original call site unknown

		if not promptPP then
			break
		end

		local suffix = forSlot(i)
		local attribute = folder:GetAttribute("Prompt" .. i .. "MinigameType") or minigameType2
		local activePlayerName = getActivePlayerName(i) -- equivalent call inferred; original call site unknown
		local activePlayer2 = stats:FindFirstChild(activePlayerName)

		if not activePlayer2 then
			activePlayer2 = Instance.new("ObjectValue")
			activePlayer2.Name = activePlayerName
			activePlayer2.Parent = stats
		end

		table.insert(v5, {
			index = i,
			activePlayer = activePlayer2,
			prompt = promptPP,
			promptPart = child,
			minigameType = attribute,
			suffix = suffix
		})
	end

	for _, v13 in ipairs(v5) do
		local suffix = v13.suffix

		if v13.minigameType == "MovementTreadmill" then
			local child = folder:FindFirstChild("TreadmillLightReference" .. suffix)
			v13.lightPart = child and child.Value

			if not v13.lightPart then
				local treadmillGame3 = folder:FindFirstChild("TreadmillGame" .. suffix)

				if not treadmillGame3 then
					if suffix == "" then
						treadmillGame3 = folder:FindFirstChild("TreadmillGame")
					else
						treadmillGame3 = false
					end
				end

				v13.lightPart = treadmillGame3 and treadmillGame3:FindFirstChild("TreadmillLight")
			end
		else
			local child = folder:FindFirstChild("LightReference" .. suffix)

			if child and child.Value then
				v13.lightPart = child.Value
			else
				local v14 = folder:FindFirstChild("BaseMachine" .. suffix) or folder:FindFirstChild("wipGenerator" .. suffix)
				v13.lightPart = v14 and v14:FindFirstChild("Light") or folder:FindFirstChild("Light" .. suffix)
			end
		end

		if v13.lightPart or v13.index ~= 1 then
			continue
		end

		v13.lightPart = folder:FindFirstChild("Light")
	end

	local indexesByLightPart = {}

	for _, v13 in ipairs(v5) do
		if not v13.lightPart then
			continue
		end

		if indexesByLightPart[v13.lightPart] then
			warn(string.format(
				"[GeneratorFillScript] Slot %d light collides with slot %d (same instance %s) — lights wired wrong on template?",
				v13.index,
				indexesByLightPart[v13.lightPart],
				v13.lightPart:GetFullName()
			))
			v13.lightPart = nil
		else
			indexesByLightPart[v13.lightPart] = v13.index
		end
	end

	local function setPartVisible(part, p, p2)
		if not (part and part:IsA("BasePart")) then
			return
		end

		if not p and p2 then
			part:Destroy()
			return
		end

		if part:IsA("MeshPart") then
			if part:GetAttribute("_OriginalTransparency") == nil then
				part:SetAttribute("_OriginalTransparency", part.Transparency)
			end

			part.Transparency = not p and 1 or part:GetAttribute("_OriginalTransparency") or 0
		end

		if part:GetAttribute("_OriginalCanCollide") == nil then
			part:SetAttribute("_OriginalCanCollide", part.CanCollide)
		end

		part.CanCollide = p and part:GetAttribute("_OriginalCanCollide") == true
	end

	local v13 = false

	for _, v15 in ipairs(v5) do
		if v15.minigameType ~= "MovementTreadmill" then
			continue
		end

		v13 = true
		break
	end

	local count2 = #v5
	local v15 = v5[1] and v5[1].minigameType == "MovementTreadmill"
	local baseMachine2 = folder:FindFirstChild("BaseMachine") or folder:FindFirstChild("wipGenerator")

	if baseMachine2 then
		local v16 = v13 and (count2 == 2 or count2 == 4)
		setPartVisible(baseMachine2:FindFirstChild("BaseShape_4SlotCircle"), false)
		setPartVisible(baseMachine2:FindFirstChild("BaseShape_4Slot"), false)
		local baseMerge = baseMachine2:FindFirstChild("BaseMerge")
		setPartVisible(baseMerge, v16, true)

		if v16 and baseMerge and baseMerge:IsA("BasePart") then
			baseMerge.Transparency = 0
		end

		setPartVisible(baseMachine2:FindFirstChild("BaseShape_6Slot"), v13 and count2 == 6)
		local pedestal = baseMachine2:FindFirstChild("Pedestal")
		setPartVisible(pedestal and pedestal:FindFirstChild("PedestalBottom"), not v13, true)
		setPartVisible(baseMachine2:FindFirstChild("StaffOnlySticker"), not v13, true)
		local treadmillGame3 = folder:FindFirstChild("TreadmillGame")
		local treadmillBaseVariants2 = treadmillGame3 and treadmillGame3:FindFirstChild("TreadmillBaseVariants")

		if treadmillBaseVariants2 then
			setPartVisible(treadmillBaseVariants2:FindFirstChild("TreadmillBase_1Slot"), v13 and count2 == 1, true)
			local part = treadmillBaseVariants2:FindFirstChild("TreadmillBase_" .. 2 .. "Slot")

			if part and part:IsA("BasePart") then
				part:Destroy()
			end

			local part2 = treadmillBaseVariants2:FindFirstChild("TreadmillBase_" .. 3 .. "Slot")

			if part2 and part2:IsA("BasePart") then
				part2:Destroy()
			end

			local part3 = treadmillBaseVariants2:FindFirstChild("TreadmillBase_" .. 4 .. "Slot")

			if part3 and part3:IsA("BasePart") then
				part3:Destroy()
			end
		end

		local baseShape_8Slot = baseMachine2:FindFirstChild("BaseShape_8Slot")
		local v17 = v13 and count2 == 8
		setPartVisible(baseShape_8Slot, v17)

		if baseShape_8Slot and baseShape_8Slot:IsA("BasePart") and v17 then
			baseShape_8Slot.Size = createVector(10, 2, 10)
			baseShape_8Slot.Transparency = 0
			baseShape_8Slot.CanCollide = true
		end

		setPartVisible(baseMachine2:FindFirstChild("Tmbase_Y_Center"), v15)
	end

	for _, v16 in ipairs(v5) do
		local suffix = v16.suffix or ""
		local v17 = v16.minigameType == "MovementTreadmill"
		local v18 = suffix == ""
		local folder2 = folder:FindFirstChild("BaseMachine" .. suffix) or folder:FindFirstChild("wipGenerator" .. suffix)
		local v19 = folder:FindFirstChild("TreadmillGame" .. suffix) or v18 and folder:FindFirstChild("TreadmillGame")

		if folder2 then
			setPartVisible(folder2:FindFirstChild("Light"), not v17)
			setPartVisible(folder2:FindFirstChild("LightChassis"), not v17)

			for _, part in ipairs(folder2:GetDescendants()) do
				if part:IsA("BasePart") and part.Name:find("Valve") then
					setPartVisible(part, not v17)
				end
			end
		end

		if not v19 then
			continue
		end

		setPartVisible(v19:FindFirstChild("TreadmillLight"), v17)
		setPartVisible(v19:FindFirstChild("TreadmillLightBase"), v17)
		local treadmillCenterBase = v19:FindFirstChild("TreadmillCenterBase")

		if not treadmillCenterBase then
			continue
		end

		if v18 then
			if v13 and count2 == 8 and treadmillCenterBase:IsA("BasePart") then
				if treadmillCenterBase:GetAttribute("_OriginalTransparency") == nil then
					treadmillCenterBase:SetAttribute("_OriginalTransparency", treadmillCenterBase.Transparency)
				end

				treadmillCenterBase.Transparency = 1
			end
		else
			setPartVisible(treadmillCenterBase, false)
		end
	end

	local function collectSlotLights()
		local lightParts = {}

		for _, v16 in ipairs(v5) do
			if v16.lightPart then
				table.insert(lightParts, v16.lightPart)
			end
		end

		return lightParts
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function anyActivePlayer()
		for _, v16 in ipairs(v5) do
			if v16.activePlayer.Value then
				return true
			end
		end

		return false
	end

	local function slotForCharacter(p)
		if not p then
			return nil
		end

		for _, v16 in ipairs(v5) do
			if v16.activePlayer.Value == p then
				return v16
			end
		end

		return nil
	end

	local function isCharacterOnOtherSlot(character, p)
		if not character then
			return false
		end

		for _, v16 in ipairs(v5) do
			if v16 ~= p and v16.activePlayer.Value == character then
				return true
			end
		end

		return false
	end

	local function refreshPromptLockout()
		local stats2 = folder:FindFirstChild("Stats")
		local connie = stats2 and stats2:FindFirstChild("Connie")
		local v16

		if connie == nil then
			v16 = false
		else
			v16 = connie.Value == true
		end

		local completed = stats2 and stats2:FindFirstChild("Completed")
		local v17 = flag

		if not v17 then
			if completed == nil then
				v17 = false
			else
				v17 = completed.Value == true
			end
		end

		for _, v18 in ipairs(v5) do
			if not v18.prompt then
				continue
			end

			if v18.activePlayer.Value then
				v18.prompt.Enabled = false
			elseif v16 then
				v18.prompt.Enabled = true
			elseif v17 then
				v18.prompt.Enabled = false
			else
				v18.prompt.Enabled = true
			end
		end
	end

	for _, v16 in ipairs(v5) do
		v16.activePlayer.Changed:Connect(refreshPromptLockout)
	end

	local stats2 = folder:FindFirstChild("Stats")
	local completed = stats2 and stats2:FindFirstChild("Completed")

	if completed then
		completed.Changed:Connect(refreshPromptLockout)
	end

	local color = Color3.fromRGB(165, 54, 56)
	local color2 = Color3.fromRGB(255, 215, 130)

	for _, v16 in ipairs(v5) do
		local v17 = v16
		v16.activePlayer.Changed:Connect(function()
			local stats3 = folder:FindFirstChild("Stats")
			local completed2 = stats3 and stats3:FindFirstChild("Completed")

			if completed2 and completed2.Value then
				return
			end

			local lightPart = v17.lightPart

			if lightPart and lightPart:IsA("BasePart") then
				local color3 = v17.activePlayer.Value and color2 or color
				TweenService:Create(lightPart, TweenInfo.new(0.3), {
					Color = color3
				}):Play()
			end
		end)
	end

	folder:FindFirstChild("IchorFull")
	folder:FindFirstChild("Drip")
	local emitters = {}
	local ratesByEmitter = {}
	local ichorFX = folder:FindFirstChild("IchorFX") or folder:FindFirstChild("Ichor Fake position")

	if ichorFX then
		for _, emitter in ipairs(ichorFX:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			table.insert(emitters, emitter)
			ratesByEmitter[emitter] = emitter.Rate
		end
	end

	local total = 1
	local value = 0
	local now = 0
	local v16 = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyParticleRateMul()
		for _, v17 in ipairs(emitters) do
			if not v17.Enabled then
				continue
			end

			local v18 = ratesByEmitter[v17]

			if v18 then
				v17.Rate = v18 * v16
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setDripEnabled(enabled)
		if enabled then
			total = 1
			local stats3 = folder:FindFirstChild("Stats")
			local currentAmount = stats3 and stats3:FindFirstChild("CurrentAmount")
			value = currentAmount and currentAmount.Value or 0
			now = tick()
			v16 = 1
		end

		for _, v17 in ipairs(emitters) do
			v17.Enabled = enabled

			if not enabled then
				continue
			end

			local v18 = ratesByEmitter[v17]

			if v18 then
				v17.Rate = v18 * v16
			end
		end
	end

	setDripEnabled(false) -- equivalent call inferred; original call site unknown
	local drip = folder:FindFirstChild("Drip")
	local attachment2 = drip and drip:FindFirstChild("Attachment")
	local dripParticle = attachment2 and attachment2:FindFirstChild("DripParticle")

	if dripParticle then
		dripParticle.Enabled = false
	end

	local generators = ServerStorage:FindFirstChild("Generators")
	local generator = generators and generators:FindFirstChild("Generator")
	local prompt2 = generator and generator:FindFirstChild("Prompt")

	if prompt2 then
		for i = 1, 8 do
			local child = folder:FindFirstChild(getPromptName(i))

			if not child then
				break
			end

			for _, childName in ipairs({ "Pour", "Fail", "Correct" }) do
				if child:FindFirstChild(childName) then
					continue
				end

				local sound = prompt2:FindFirstChild(childName)

				if sound and sound:IsA("Sound") then
					sound:Clone().Parent = child
				end
			end
		end
	end

	local pour = prompt:WaitForChild("Pour", 1)
	local fail = prompt:WaitForChild("Fail", 1)
	local correct = prompt:WaitForChild("Correct", 1)

	if not (pour and fail and correct) then
		warn("[GeneratorFillScript] Generator missing sound effects (Pour/Fail/Correct):", folder.Name)
		return
	end

	if folder.PrimaryPart and pour.Parent ~= folder.PrimaryPart then
		pour.Parent = folder.PrimaryPart
	end

	for _, part in ipairs(folder:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name:sub(1, 6) == "Prompt") then
			continue
		end

		local pour2 = part:FindFirstChild("Pour")

		if pour2 and pour2 ~= pour then
			pour2:Destroy()
		end
	end

	local ichor = folder:FindFirstChild("Ichor")
	local valveReference = folder:WaitForChild("ValveReference", 1)

	if not valveReference then
		warn("[GeneratorFillScript] Generator missing ValveReference:", folder.Name)
		return
	end

	local _ = folder:FindFirstChild("FakeValveReference") or valveReference

	if not folder:WaitForChild("PlayerCompletion", 1) then
		warn("[GeneratorFillScript] Generator missing PlayerCompletion folder:", folder.Name)
		return
	end

	local v17 = false

	for _, v18 in ipairs(v5) do
		v18.skillchecking = false
	end

	for _, v18 in ipairs(v5) do
		v18.failedskillcheck = false
	end

	local v18 = {}
	local v19 = nil

	local function canseetarget(folder2, magnitude, promptPart)
		local position = folder2.PrimaryPart.Position
		local v20 = promptPart or folder:FindFirstChild("Prompt")

		if not v20 then
			return true
		end

		local v21 = (v20.Position - position).Unit * magnitude
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = folder2:GetDescendants()

		for _ = 1, 4 do
			local raycastResult = workspace:Raycast(position, v21, raycastParams)

			if not raycastResult or raycastResult.Instance and raycastResult.Instance:IsDescendantOf(folder) then
				return true
			end

			local model = raycastResult.Instance and raycastResult.Instance:FindFirstAncestorOfClass("Model")

			if model and model:FindFirstChildOfClass("Humanoid") then
				raycastParams:AddToFilter(model)
			else
				return magnitude - (raycastResult.Position - position).Magnitude <= 4
			end
		end

		return false
	end

	local function emitSuccessBurst()
		local ichorFX2 = folder:FindFirstChild("IchorFX")
		local dripSource = ichorFX2 and ichorFX2:FindFirstChild("DripSource")

		if dripSource then
			for _, emitter in ipairs(dripSource:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					pcall(emitter.Emit, emitter, 10)
				end
			end
		end
	end

	local function endmachine(p)
		local v20 = p or v5[1]
		local activePlayer2 = v20.activePlayer
		local value2 = activePlayer2.Value
		local playerFromCharacter = value2 and Players:GetPlayerFromCharacter(value2)

		if playerFromCharacter then
			generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
		end

		if v20.minigameType == "Barnaby" then
			pcall(function()
				BarnabyMinigameBridgeServer.StopClient(folder, v20.suffix)
			end)
		end

		v20.skillchecking = false
		v20.engagedAt = nil
		local success2, result2 = pcall(function()
			local v21 = false

			for _, v23 in ipairs(v5) do
				if not (v23 ~= v20 and v23.activePlayer.Value) then
					continue
				end

				v21 = true
				break
			end

			if not v21 then
				v17 = false

				if pour then
					pour:Stop()
				end

				setDripEnabled(false) -- equivalent call inferred; original call site unknown
			end

			local value3 = activePlayer2.Value

			if value3 then
				pcall(function()
					value3:SetAttribute("_DevGenOffsetY", nil)
					value3:SetAttribute("_DevGenOffsetZ", nil)
					value3:SetAttribute("_StoredGenOffsetY", nil)
					value3:SetAttribute("_StoredGenOffsetZ", nil)
					value3:SetAttribute("_GenTeleportPart", nil)
					value3:SetAttribute("_GenIsTreadmill", nil)
				end)
			end

			if value3 and value3:FindFirstChild("Config") and value3.Config:FindFirstChild("ModuleName") then
				local value4 = value3.Config.ModuleName.Value
				local tower = TowerLUT:GetTower(value4)
				local playerFromCharacter2 = Players:GetPlayerFromCharacter(value3)

				if playerFromCharacter2 then
					local minigameType3 = v20.minigameType
					ActionEvent:Record(
						playerFromCharacter2,
						"ExtractStopped",
						minigameType3 == "MovementTreadmill" and "movement" or minigameType3 == "Circle" and "circle" or minigameType3 == "Original" and "default" or minigameType3 == "Barnaby" and "barnaby" or "default"
					)
				end

				if tower then
					local success3, result3 = pcall(function()
						local module = require(tower)

						if type(module.GeneratorEndAbility) == "function" then
							module.GeneratorEndAbility(value3, folder, playerFromCharacter2)
						end
					end)

					if not success3 then
						warn("Failed to call GeneratorEndAbility for", value4, result3)
					end
				end
			end

			local v23 = v18[v20]

			if v23 then
				if type(v23.Stop) == "function" then
					local success3, result3 = pcall(function()
						v23.Stop()
					end)

					if not success3 then
						warn("[GeneratorFillScript] Failed to stop treadmill:", result3)
					end
				end

				v18[v20] = nil

				if v19 == v23 then
					v19 = nil
				end
			elseif v19 and v20.minigameType == "MovementTreadmill" then
				if type(v19.Stop) == "function" then
					pcall(function()
						v19.Stop()
					end)
				end

				v19 = nil
			end

			if value3 and value3.Parent ~= nil then
				local info2 = workspace:FindFirstChild("Info")

				if info2 and info2:FindFirstChild("ForceMovementTreadmill") or v20.minigameType == "MovementTreadmill" then
					local v24 = folder:FindFirstChild("QuickLinks" .. v20.suffix) or folder:FindFirstChild("QuickLinks") or folder:FindFirstChild("QuickLInks")

					if v24 then
						local defaultLight = v24:FindFirstChild("DefaultLight")

						if defaultLight then
							for _, objectValue in pairs(defaultLight:GetChildren()) do
								if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
									continue
								end

								local value4 = objectValue.Value

								if value4:IsA("BasePart") then
									value4.Transparency = 1
								elseif value4:IsA("Model") then
									for _, part in pairs(value4:GetDescendants()) do
										if part:IsA("BasePart") then
											part.Transparency = 1
										end
									end
								end
							end
						end
					end

					local child = folder:FindFirstChild("TreadmillTeleportPositions" .. v20.suffix)
					local treadmillTeleportPositions2 = folder:FindFirstChild("TreadmillTeleportPositions")
					local treadmillLeavePosition = folder:FindFirstChild("TreadmillLeavePosition" .. v20.suffix) or child and child:FindFirstChild("TreadmillLeavePosition")

					if not treadmillLeavePosition then
						if v20.suffix == "" then
							treadmillLeavePosition = folder:FindFirstChild("TreadmillLeavePosition")

							if not treadmillLeavePosition then
								if treadmillTeleportPositions2 then
									treadmillLeavePosition = treadmillTeleportPositions2:FindFirstChild("TreadmillLeavePosition") or nil
								else
									treadmillLeavePosition = nil
								end
							end
						else
							treadmillLeavePosition = nil
						end
					end

					if treadmillLeavePosition then
						local primaryPart = value3.PrimaryPart
						local humanoid = value3:FindFirstChild("Humanoid")

						if primaryPart and humanoid then
							local v25 = humanoid.HipHeight + primaryPart.Size.Y / 2
							local v27 = nudgeIfClipped(
								treadmillLeavePosition.CFrame + Vector3.new(0, v25, 0),
								value3,
								folder
							)

							-- equivalent calls inferred from this helper; original call sites unknown
							local function pivotModelTo(value4, cframe)
								value4:PivotTo(cframe)

								if value4:GetPivot() ~= cframe then
									value4:PivotTo(cframe)
								end
							end

							local playerFromCharacter2 = Players:GetPlayerFromCharacter(value3)

							if playerFromCharacter2 then
								playerFromCharacter2:SetAttribute("KM_TELEPORT_TEMPORARY_EXCEPTION", true)
								removeCharacterAntiExploitModule:Fire(playerFromCharacter2, true, nil, 5)
							end

							pivotModelTo(value3, v27) -- equivalent call inferred; original call site unknown
						end
					end
				end
			end
		end)

		if not success2 then
			warn("[GeneratorFillScript] endmachine errored:", result2)
		end

		local value3 = activePlayer2.Value

		if value3 and value3.Parent ~= nil then
			local primaryPart = value3.PrimaryPart

			if primaryPart then
				primaryPart.Anchored = false
				pcall(function()
					primaryPart:SetNetworkOwner(Players:GetPlayerFromCharacter(value3))
				end)
			end

			local decoding = value3:FindFirstChild("Decoding")

			if decoding then
				decoding.Value = nil
			end

			pcall(function()
				animationStop:FireAllClients(value3, "Decode")
			end)
		end

		pcall(function()
			animationStop:FireAllClients(folder, "Activate")
		end)
		activePlayer2.Value = nil
		v20.cooldown = false

		if v20.characterdestroying then
			v20.characterdestroying:Disconnect()
			v20.characterdestroying = nil
		end

		if v20.playerremoving then
			v20.playerremoving:Disconnect()
			v20.playerremoving = nil
		end

		if v20.characterdeath then
			v20.characterdeath:Disconnect()
			v20.characterdeath = nil
		end
	end

	for _, v20 in ipairs(v5) do
		v20.cooldown = false
	end

	local function onPromptTriggered(player, value2)
		local v20 = v5[value2 or 1] or v5[1]
		local activePlayer2 = v20.activePlayer
		local prompt3 = v20.prompt

		if player and player.Character then
			local character = player.Character
			local v21

			if character then
				for _, v23 in ipairs(v5) do
					if v23.activePlayer.Value ~= character then
						continue
					end

					v21 = v23
					break
				end
			end

			if v21 then
				local engagedAt = v21.engagedAt or 0
				local v22 = tick() - engagedAt
				local v23

				if v22 >= 0 then
					v23 = v22 < 0.5
				else
					v23 = false
				end

				local v24 = v21.skillchecking and v21.minigameType ~= "Barnaby"

				if v24 or v23 then
					warn(string.format(
						"[GenFill] E-press swallowed by dismount hold (skillcheck=%s recent=%s) — gen=%s player=%s",
						tostring(v24),
						tostring(v23),
						folder.Name,
						player and player.Name or "?"
					))
				else
					endmachine(v21)
				end

				return
			end
		end

		local minigameType3 = v20.minigameType or folder:GetAttribute("MinigameType")

		if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
			print(string.format(
				"[GenFill] onPromptTriggered: gen=%s mt=%s slot.minigameType=%s attr=%s",
				folder.Name,
				tostring(minigameType3),
				tostring(v20.minigameType),
				(tostring(folder:GetAttribute("MinigameType")))
			))
		end

		if minigameType3 == "Barnaby" then
			if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
				print("[GenFill] BARNABY EARLY-RETURN HIT for " .. folder.Name)
			end

			local character = player and player.Character

			if CollectionService:HasTag(player, "NoGenerator") then
				Network:Post(player, "ShowAbilityMessage", "You can't do that right now!")
				return
			end

			if character and character.PrimaryPart and character.PrimaryPart.Anchored == true then
				warn(string.format(
					"[GenFill] Barnaby entry refused (character anchored — pinned elsewhere?) — gen=%s player=%s",
					folder.Name,
					player and player.Name or "?"
				))
				return
			end

			if character and character:GetAttribute("Transforming") == true then
				warn(string.format(
					"[GenFill] Barnaby entry refused (Transforming) — gen=%s player=%s",
					folder.Name,
					player and player.Name or "?"
				))
				return
			end

			if character and character:FindFirstChild("Grabbed") then
				warn(string.format(
					"[GenFill] Barnaby entry refused (Grabbed) — gen=%s player=%s",
					folder.Name,
					player and player.Name or "?"
				))
				return
			end

			if character and character:GetAttribute("GrabbedBySquirm") then
				warn(string.format(
					"[GenFill] Barnaby entry refused (GrabbedBySquirm) — gen=%s player=%s",
					folder.Name,
					player and player.Name or "?"
				))
				return
			end

			if character and character:FindFirstChild("NoDecode") then
				return
			end

			if character and character:GetAttribute("AbilityAnimationActive") then
				warn(string.format(
					"[GenFill] Barnaby entry refused (AbilityAnimationActive) — gen=%s player=%s",
					folder.Name,
					not player and "?" or player.Name or "?"
				))
				Network:Post(player, "ShowAbilityMessage", "You can't do that right now!")
			else
				local stats3 = folder:FindFirstChild("Stats")
				local connie = stats3 and stats3:FindFirstChild("Connie")

				if connie and connie.Value == true then
					generatorActivated:Fire(player, folder)
					return
				end

				local completed2 = stats3 and stats3:FindFirstChild("Completed")

				if completed2 and completed2.Value == true then
					if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
						warn(string.format(
							"[GenFill] Barnaby entry BLOCKED — %s is already completed (%s pressed E on a finished gen)",
							folder.Name,
							player and player.Name or "?"
						))
					end
				else
					if activePlayer2.Value ~= nil then
						local value3 = activePlayer2.Value
						local humanoid = value3 and value3:FindFirstChildOfClass("Humanoid")
						local decoding = value3 and value3:FindFirstChild("Decoding")
						local v21

						if value3 == nil or value3.Parent == nil or humanoid == nil or not (humanoid.Health > 0) or decoding == nil then
							v21 = false
						else
							v21 = decoding.Value == folder
						end

						if v21 then
							warn(string.format(
								"[GenFill] Barnaby entry refused (slot occupied by %s) — gen=%s slot=%d player=%s",
								tostring(value3),
								folder.Name,
								v20.index or 1,
								player and player.Name or "?"
							))
							return
						end

						warn(string.format(
							"[GenFill] Barnaby slot held by STALE occupant %s (parent=%s decoding=%s) — force-cleaning and allowing entry — gen=%s player=%s",
							tostring(value3),
							tostring(value3 and value3.Parent ~= nil),
							tostring(decoding and decoding.Value),
							folder.Name,
							not player and "?" or player.Name or "?"
						))
						pcall(function()
							endmachine(v20)
						end)

						if activePlayer2.Value ~= nil then
							activePlayer2.Value = nil
						end
					end

					if v20.cooldown then
						if v20.cooldownSince == nil then
							v20.cooldownSince = tick()
						end

						if tick() - v20.cooldownSince > 5 then
							warn(string.format(
								"[GenFill] Barnaby slot cooldown STALE (empty slot, held %.1fs) — clearing and allowing entry — gen=%s player=%s",
								tick() - v20.cooldownSince,
								folder.Name,
								not player and "?" or player.Name or "?"
							))
							v20.cooldown = false
							v20.cooldownSince = nil
						else
							warn(string.format(
								"[GenFill] Barnaby entry refused (slot cooldown held %.1fs) — gen=%s slot=%d player=%s",
								tick() - v20.cooldownSince,
								folder.Name,
								v20.index or 1,
								player and player.Name or "?"
							))
							return
						end
					end

					if isCharacterOnOtherSlot(player and player.Character, v20) then
						warn(string.format(
							"[GenFill] Barnaby entry refused (character registered on a sibling slot) — gen=%s player=%s",
							folder.Name,
							player and player.Name or "?"
						))
						return
					end

					v20.cooldown = true
					v20.cooldownSince = tick()
					local character2 = player.Character

					if character2 and character2.PrimaryPart then
						local promptPart = v20 and v20.promptPart or folder:FindFirstChild("Prompt")
						local position = promptPart and promptPart.Position

						if position then
							local magnitude = (character2.PrimaryPart.Position - position).Magnitude

							if not canseetarget(character2, magnitude, promptPart) then
								warn(string.format(
									"[GenFill] Barnaby entry refused (no line-of-sight to prompt, dist=%.1f — something standing in the way?) — gen=%s player=%s",
									magnitude,
									folder.Name,
									player and player.Name or "?"
								))
								v20.cooldown = false
								return
							end
						end

						activePlayer2.Value = character2
						v20.engagedAt = tick()

						if character2.PrimaryPart.Anchored ~= true then
							character2.PrimaryPart.Anchored = true
						end

						local decoding = character2:FindFirstChild("Decoding")

						if decoding then
							decoding.Value = folder
						end

						local humanoid = character2:FindFirstChildOfClass("Humanoid")

						local function guardedEnd(p)
							if activePlayer2.Value ~= character2 then
								warn(string.format(
									"[GenFill] STALE slot listener '%s' (wired for %s) stood down — slot occupant now: %s — gen=%s",
									p,
									character2.Name,
									tostring(activePlayer2.Value),
									folder.Name
								))
								return
							end

							warn(string.format(
								"[GenFill] slot listener '%s' dismounting %s — gen=%s",
								p,
								character2.Name,
								folder.Name
							))
							endmachine(v20)
						end

						if humanoid then
							v20.characterdeath = humanoid.Died:Connect(function()
								guardedEnd("characterDied")
							end)
						end

						v20.characterdestroying = character2:GetPropertyChangedSignal("Parent"):Connect(function()
							if character2.Parent == nil then
								guardedEnd("characterRemoved")
							end
						end)
						v20.playerremoving = Players.PlayerRemoving:Connect(function(player2)
							if player2 == player then
								guardedEnd("playerLeft")
							end
						end)
						local primaryPart = character2.PrimaryPart
						local humanoid2 = character2:FindFirstChildOfClass("Humanoid")
						local v21 = folder:FindFirstChild("TeleportPositions" .. v20.suffix) or v20.suffix == "" and folder:FindFirstChild("TeleportPositions") or folder:FindFirstChild("TeleportPositions")
						local v22 = nil

						if v21 then
							for _, part in ipairs(v21:GetChildren()) do
								if not (part:IsA("BasePart") and part.Name == "TeleportPosition") then
									continue
								end

								v22 = part
								break
							end

							if not v22 then
								for _, part in ipairs(v21:GetChildren()) do
									if not part:IsA("BasePart") then
										continue
									end

									v22 = part
									break
								end
							end
						end

						if v22 and primaryPart and humanoid2 then
							local v23 = humanoid2.HipHeight + primaryPart.Size.Y / 2
							local v24 = v22.CFrame + Vector3.new(0, v23, 0)
							local success2, result2, v25 = pcall(getGeneratorOffset, character2, false)

							if success2 then
								local v26 = (result2 or 0) + (character2:GetAttribute("_DevGenOffsetY") or 0)
								local v27 = (v25 or 0) + (character2:GetAttribute("_DevGenOffsetZ") or 0)

								if v26 ~= 0 or v27 ~= 0 then
									v24 *= CFrame.new(0, v26, v27)
								end
							end

							character2:SetAttribute("_GenTeleportPart", v22:GetFullName())
							character2:SetAttribute("_GenIsTreadmill", false)
							pcall(function()
								removeCharacterAntiExploitModule:Fire(player, true, nil, 2)
							end)
							task.wait()

							if character2 and character2.Parent and character2.PrimaryPart and primaryPart and primaryPart.Parent and activePlayer2.Value == character2 then
								pcall(function()
									primaryPart:SetNetworkOwner(nil)
								end)
								character2:PivotTo(v24)
							end

							task.spawn(function()
								task.wait(1)
								pcall(function()
									removeCharacterAntiExploitModule:Fire(player, false)
								end)
							end)
						end

						local v23 = nil
						pcall(function()
							v23 = BarnabyMinigameBridgeServer.BeginSession(folder, player, v20.suffix)
						end)

						if v23 then
							local barnabyEnterEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("BarnabyEnterEvent")

							if barnabyEnterEvent then
								barnabyEnterEvent:FireClient(player, folder, v23, v20.suffix)

								if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
									print(string.format(
										"[GenFill] Barnaby session started for %s on %s",
										player.Name,
										folder.Name
									))
								end

								local passiveToon = TowerLUT:GetPassiveToon(character2)
								local passiveTower = TowerLUT:GetPassiveTower(character2)
								local v24 = false

								if passiveTower and not pcall(function()
									local module = require(passiveTower)

									if module and typeof(module.GeneratorBeginAbility) == "function" then
										module.GeneratorBeginAbility(character2, folder, player)
										v24 = true
									end
								end) then
									v24 = false
									warn("[GenFill] Barnaby GeneratorBeginAbility errored for", (tostring(passiveToon)))
								end

								if not v24 then
									animateTower:FireAllClients(character2, "Decode")
								end

								animateTower:FireAllClients(folder, "Activate")
								v17 = true
								setDripEnabled(true)

								if pour and not pour.IsPlaying then
									pour:Play()
								end

								if v20.prompt then
									v20.prompt.Enabled = false
								end

								ActionEvent:Record(player, "ExtractBegin", "barnaby")
								generatorUpdate:FireClient(player, folder, "Begin", "barnaby")
							else
								warn("[GenFill] BarnabyEnterEvent missing -- bridge not initialized?")
								endmachine(v20)
							end
						else
							warn("[GenFill] Barnaby BeginSession failed for", player.Name, folder.Name)
							endmachine(v20)
						end
					else
						v20.cooldown = false
						v20.cooldownSince = nil
					end
				end
			end
		else
			local v21, v22

			if v20.minigameType == "MovementTreadmill" then
				v21 = folder:FindFirstChild("TreadmillTeleportPositions" .. v20.suffix) or folder:FindFirstChild("TeleportPositions" .. v20.suffix) or v20.suffix == "" and folder:FindFirstChild("TreadmillTeleportPositions") or folder:FindFirstChild("TeleportPositions")
			else
				v21 = folder:FindFirstChild("TeleportPositions" .. v20.suffix) or v20.suffix == "" and folder:FindFirstChild("TeleportPositions") or folder:FindFirstChild("TeleportPositions")
			end

			v22 = not v21 and {} or v21:GetChildren() or {}

			if CollectionService:HasTag(player, "NoGenerator") then
				print("[GenPrompt] BLOCKED: player has NoGenerator tag")
				Network:Post(player, "ShowAbilityMessage", "You can't do that right now!")
			else
				local character = player.Character

				if character and character.PrimaryPart and character.PrimaryPart.Anchored == true or character and character:GetAttribute("Transforming") == true then
					return
				end

				if folder.Stats.Connie.Value == true then
					generatorActivated:Fire(player, folder)
					return
				end

				local completed2 = folder.Stats:FindFirstChild("Completed")

				if completed2 and completed2.Value == true or isCharacterOnOtherSlot(character, v20) or v20.cooldown then
					return
				end

				v20.cooldown = true
				task.wait()
				local success2, result2 = pcall(function()
					if not flag and activePlayer2.Value == nil then
						local character2 = player.Character or player.CharacterAdded:Wait()
						local decoding = character2:FindFirstChild("Decoding")
						local value3 = decoding and decoding.Value

						if value3 ~= nil then
							warn(string.format(
								"[GenFill] entry refused on %s slot %d — %s is still Decoding %s (parent=%s, sameGen=%s)",
								folder.Name,
								v20.index or 1,
								character2.Name,
								value3.Name,
								not value3.Parent and "nil" or value3.Parent.Name or "nil",
								(tostring(value3 == folder))
							))
						end

						if character2:GetChildren()[1] and character2.Parent ~= nil and character2.Parent == workspace.InGamePlayers and character2.Decoding.Value == nil then
							if character2:WaitForChild("Humanoid") then
								local primaryPart = character2.PrimaryPart
								local humanoid = character2:WaitForChild("Humanoid")
								local playerFromCharacter = Players:GetPlayerFromCharacter(character2)
								local v23 = nil

								local function invokeClientWithTimeout(playerFromCharacter2, humanoidRootPart, p)
									local getCharacterPosition = ReplicatedStorage.Events.GetCharacterPosition
									local flag3 = false
									local v24 = nil
									coroutine.wrap(function()
										local _, _ = pcall(function()
											v24 = getCharacterPosition:InvokeClient(playerFromCharacter2)
										end)
										flag3 = true
									end)()
									local lastTime = tick()

									while not flag3 and tick() - lastTime < p do
										local RunService = game:GetService("RunService")
										RunService.Heartbeat:Wait()
									end

									if flag3 then
										return v24
									end

									return humanoidRootPart.Position
								end

								local _, _ = pcall(function()
									if playerFromCharacter then
										v23 = invokeClientWithTimeout(
											playerFromCharacter,
											character2:WaitForChild("HumanoidRootPart"),
											0.2
										)
									end
								end)
								local promptPart = v20 and v20.promptPart or folder:FindFirstChild("Prompt")
								local position = promptPart and promptPart.Position

								if v23 == nil or not position then
									if position and not canseetarget(
										character2,
										(primaryPart.Position - position).Magnitude,
										promptPart
									) then
										return
									end
								elseif not canseetarget(character2, (v23 - position).Magnitude, promptPart) then
									return
								end

								if character2:FindFirstChild("Grabbing") and character2.Grabbing.Value == true or character2:FindFirstChild("Grabbed") then
									return
								end

								if character2:GetAttribute("GrabbedBySquirm") then
									warn(string.format(
										"[GenFill] Entry refused (GrabbedBySquirm) — gen=%s player=%s",
										folder.Name,
										player and player.Name or "?"
									))
									return
								end

								if character2:FindFirstChild("NoDecode") then
									return
								end

								if character2:GetAttribute("AbilityAnimationActive") then
									warn(string.format(
										"[GenFill] Entry refused (AbilityAnimationActive) — gen=%s player=%s",
										folder.Name,
										player and player.Name or "?"
									))
									Network:Post(player, "ShowAbilityMessage", "You can't do that right now!")
								elseif character2:WaitForChild("Decoding") and character2.Decoding.Value ~= folder and humanoid.Health >= 0 then
									local v24 = nil
									local info2 = workspace:FindFirstChild("Info")
									local v25 = info2 and info2:FindFirstChild("ForceMovementTreadmill") and true or v20.minigameType == "MovementTreadmill" or false

									if v25 then
										local treadmillTeleportPosition = folder:FindFirstChild("TreadmillTeleportPosition")

										if treadmillTeleportPosition then
											v24 = treadmillTeleportPosition
										elseif v21 and v21.Name:find("TreadmillTeleportPositions") == 1 then
											if #v22 > 1 then
												for _, v27 in pairs(v22) do
													if not (v27.Name:lower():find("front") or v27.Name:lower():find("approach")) then
														continue
													end

													v24 = v27
													break
												end

												if not v24 then
													v24 = v22[1]
												end
											else
												v24 = v22[1]
											end
										else
											for _, v27 in pairs(v22) do
												if v27.Name ~= "TreadmillTeleportPosition" then
													continue
												end

												v24 = v27
												break
											end

											if not v24 then
												local v27 = 1e999
												local v28 = nil

												for _, v29 in pairs(v22) do
													if v29.Name == "TreadmillLeavePosition" then
														continue
													end

													local v30 = (v29.Position - primaryPart.Position).Magnitude + ((v29.Position - folder.PrimaryPart.Position).Z < 0 and 0 or 10)

													if not (v30 < v27) then
														continue
													end

													v28 = v29
													v27 = v30
												end

												v24 = v28 or v22[1]
											end
										end
									else
										for _, v27 in pairs(v22) do
											if v27.Name ~= "TeleportPosition" then
												continue
											end

											v24 = v27
											break
										end
									end

									if v24 ~= nil then
										local v26 = humanoid.HipHeight + primaryPart.Size.Y / 2
										local v27 = v24.CFrame + Vector3.new(0, v26, 0)
										local v28, v29 = GeneratorOffsetLookup.forCharacter(character2, v25)
										local _DevGenOffsetY = character2:GetAttribute("_DevGenOffsetY") or 0
										local _DevGenOffsetZ = character2:GetAttribute("_DevGenOffsetZ") or 0
										local v30 = v28 + _DevGenOffsetY
										local v31 = v29 + _DevGenOffsetZ

										if v30 ~= 0 or v31 ~= 0 then
											v27 *= CFrame.new(0, v30, v31)
										end

										character2:SetAttribute("_GenTeleportPart", v24:GetFullName())
										character2:SetAttribute("_GenIsTreadmill", v25)
										removeCharacterAntiExploitModule:Fire(playerFromCharacter, true, nil, 2)
										task.wait()

										if character2.PrimaryPart.Anchored ~= true then
											character2.PrimaryPart:SetNetworkOwner(nil)
											character2.PrimaryPart.Anchored = true
										end

										task.spawn(function()
											task.wait(1)
											removeCharacterAntiExploitModule:Fire(playerFromCharacter, false)
										end)

										-- equivalent calls inferred from this helper; original call sites unknown
										local function pivotModelTo(character3, cframe)
											character3:PivotTo(cframe)

											if character3:GetPivot() ~= cframe then
												character3:PivotTo(cframe)
											end
										end

										pivotModelTo(character2, v27) -- equivalent call inferred; original call site unknown
										humanoid.WalkSpeed = 0
										prompt3.Enabled = false
										v17 = true
										character2.Decoding.Value = folder
										flag2 = true

										if pour and not pour.IsPlaying then
											pour:Play()
										end

										setDripEnabled(true)

										if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
											print(string.format(
												"[GenFill] DripParticle ENABLED for %s on %s",
												character2.Name,
												folder:GetFullName():sub(-40)
											))
										end

										local minigameType4 = v20.minigameType or folder:GetAttribute("MinigameType")
										local v32

										if minigameType4 == "MovementTreadmill" then
											v32 = "movement"
										elseif minigameType4 == "Circle" then
											v32 = "circle"
										elseif minigameType4 == "Original" then
											v32 = "default"
										elseif minigameType4 == "Barnaby" then
											v32 = "barnaby"
										else
											warn(
												"[GeneratorFillScript] CRITICAL: No valid MinigameType attribute on generator:",
												folder.Name,
												"- Attribute value:",
												minigameType4
											)
											v32 = "default"
										end

										ActionEvent:Record(player, "ExtractBegin", v32)
										generatorUpdate:FireClient(player, folder, "Begin", v32)

										if v32 ~= "movement" then
											local passiveToon = TowerLUT:GetPassiveToon(character2)

											if passiveToon then
												local passiveTower = TowerLUT:GetPassiveTower(character2)

												if passiveTower then
													local success3, result3 = pcall(function()
														local module = require(passiveTower)

														if module and typeof(module.GeneratorBeginAbility) == "function" then
															module.GeneratorBeginAbility(character2, folder, player)
														else
															animateTower:FireAllClients(character2, "Decode")
														end
													end)

													if not success3 then
														warn(
															"Error calling GeneratorBeginAbility for",
															passiveToon,
															":",
															result3
														)
														animateTower:FireAllClients(character2, "Decode")
													end
												else
													animateTower:FireAllClients(character2, "Decode")
												end
											else
												animateTower:FireAllClients(character2, "Decode")
											end
										end

										if v32 ~= "movement" then
											animateTower:FireAllClients(folder, "Activate")
										end

										activePlayer2.Value = character2
										v20.engagedAt = tick()

										if v32 == "movement" then
											local MovementTreadmillGenerator = require(ReplicatedStorage.Modules.Gameplay.MovementTreadmillGenerator)
											local v33 = MovementTreadmillGenerator.Initialize(
												folder,
												player,
												activePlayer2,
												v20
											)
											v18[v20] = v33
											v19 = v33
											local passiveToon = TowerLUT:GetPassiveToon(character2)
											local passiveTower = passiveToon and TowerLUT:GetPassiveTower(character2)

											if passiveTower then
												local success3, result3 = pcall(function()
													local module = require(passiveTower)

													if module and module.PassiveMachineTap and typeof(module.GeneratorBeginAbility) == "function" then
														module.GeneratorBeginAbility(character2, folder, player, true)
													end
												end)

												if not success3 then
													warn(
														"Error calling passive ability for",
														passiveToon,
														"on treadmill:",
														result3
													)
												end
											end
										end

										local success3, result3 = pcall(function()
											if v20.characterdestroying then
												v20.characterdestroying:Disconnect()
											end

											if v20.playerremoving then
												v20.playerremoving:Disconnect()
											end

											if v20.characterdeath then
												v20.characterdeath:Disconnect()
											end

											v20.characterdestroying = character2:GetPropertyChangedSignal("Parent"):Connect(function()
												endmachine(v20)
											end)
											v20.characterdeath = humanoid.Died:Connect(function()
												endmachine(v20)
											end)
											v20.playerremoving = Players.PlayerRemoving:Connect(function(player2)
												if player2 == player then
													endmachine(v20)
												end
											end)

											if character2 and character2.PrimaryPart and character2.PrimaryPart.Anchored ~= true then
												character2.PrimaryPart.Anchored = true
											end
										end)

										if not success3 then
											warn(result3)
											activePlayer2.Value = nil
										end
									end
								end
							end
						else
							activePlayer2.Value = nil
						end
					end
				end)

				if not success2 then
					warn(result2)
					activePlayer2.Value = nil
				end

				v20.cooldown = false
			end
		end
	end

	for _, v20 in ipairs(v5) do
		if not v20.prompt then
			continue
		end

		v20.prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
		local v21 = v20.index
		v20.prompt.Triggered:Connect(function(player)
			onPromptTriggered(player, v21)
		end)
	end

	folder.Stats.StopInteracting.OnServerEvent:Connect(function(player)
		local character = player and player.Character
		local v20

		if character then
			for _, v22 in ipairs(v5) do
				if v22.activePlayer.Value ~= character then
					continue
				end

				v20 = v22
				break
			end
		end

		if v20 then
			local engagedAt = v20.engagedAt or 0
			local v21 = tick() - engagedAt

			if v21 >= 0 and v21 < 0.5 then
				return
			else
				endmachine(v20)
			end
		end
	end)
	folder.Stats.ForceStop.Event:Connect(function(player)
		local character = player and player.Character
		local v20

		if character then
			for _, v22 in ipairs(v5) do
				if v22.activePlayer.Value ~= character then
					continue
				end

				v20 = v22
				break
			end
		end

		if v20 then
			local now2 = tick()

			if not v20._fsWindowStart or now2 - v20._fsWindowStart > 10 then
				v20._fsWindowStart = now2
				v20._fsCount = 0
			end

			v20._fsCount = (v20._fsCount or 0) + 1
			local _ = v20._fsCount > 3
			endmachine(v20)
		end
	end)
	local Y = ichor and ichor.Position.Y or 0
	local ichorFX2 = folder:FindFirstChild("IchorFX") or folder:FindFirstChild("Ichor Fake position")
	local ichorCap = ichorFX2 and (ichorFX2:FindFirstChild("IchorCap") or ichorFX2:FindFirstChild("Ichor Moving"))
	local filling_Ichor = ichorCap and ichorCap:FindFirstChild("Filling_Ichor")
	local animationController = ichorCap and ichorCap:FindFirstChildOfClass("AnimationController")
	local currentAmount = folder.Stats and folder.Stats:FindFirstChild("CurrentAmount")

	if filling_Ichor and animationController and currentAmount then
		local v20 = nil
		local v21 = animationController:FindFirstChildOfClass("Animator")

		if not v21 then
			v21 = Instance.new("Animator")
			v21.Parent = animationController
		end

		local animation = animationController:FindFirstChildOfClass("Animation")

		if animation then
			local success2, result2 = pcall(function()
				return v21:LoadAnimation(animation)
			end)

			if success2 and result2 then
				result2.Looped = true
				result2.Priority = Enum.AnimationPriority.Idle
				v20 = result2
			end
		end

		local count3 = 0
		local v22 = false

		local function refresh()
			filling_Ichor.Transparency = currentAmount.Value > 0 and 0 or 1

			-- equivalent call inferred; original call site unknown
			if anyActivePlayer() then
				if v20 and not (v20.IsPlaying or v22) then
					v22 = true
					count3 += 1
					local v23 = count3
					task.delay(1, function()
						if v23 == count3 then
							local v24 = anyActivePlayer() -- equivalent call inferred; original call site unknown

							if v24 and v20 and not v20.IsPlaying then
								v20:Play()
							end
						end

						v22 = false
					end)
				end
			else
				count3 += 1
				v22 = false

				if v20 and v20.IsPlaying then
					v20:Stop(0.3)
				end
			end
		end

		refresh()

		for _, v23 in ipairs(v5) do
			v23.activePlayer.Changed:Connect(refresh)
		end

		currentAmount.Changed:Connect(refresh)
	end

	local light = folder:FindFirstChild("Light")
	local baseMachine3 = folder:FindFirstChild("BaseMachine") or folder:FindFirstChild("wipGenerator")
	local light2 = baseMachine3 and baseMachine3:FindFirstChild("Light")

	if light and light2 then
		light2.Color = light.Color
		light:GetPropertyChangedSignal("Color"):Connect(function()
			light2.Color = light.Color
		end)
	end

	for _, v20 in ipairs(v5) do
		local v21 = folder:FindFirstChild("ValveReference" .. v20.suffix) or folder:FindFirstChild("ValveReference")
		local value2 = v21 and v21.Value

		if not value2 or not value2:IsA("BasePart") or value2.Anchored then
			continue
		end

		value2.Anchored = true
	end

	local function publishActiveStates()
		local v20 = false

		for _, v21 in ipairs(v5) do
			local v22 = v21.activePlayer.Value ~= nil
			folder:SetAttribute("Slot" .. v21.index .. "Spinning", v22)

			if v22 then
				v20 = true
			end
		end

		folder:SetAttribute("AnyActiveSlot", v20)
	end

	for _, v20 in ipairs(v5) do
		v20.activePlayer:GetPropertyChangedSignal("Value"):Connect(publishActiveStates)
	end

	publishActiveStates()
	CollectionService:AddTag(folder, "GenFXManaged")

	for _, v20 in ipairs(v5) do
		v20.ticktime = tick()
	end

	local tweenInfo = TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	folder.Stats.CurrentAmount.Changed:Connect(function()
		local playbackSpeed = 0.6 * (folder.Stats.CurrentAmount.Value / folder.Stats.RequiredAmount.Value - 0) + 0.6
		local now2 = tick()
		local v21 = now2 - now

		if v21 > 0 then
			local value2 = folder.Stats.CurrentAmount.Value
			local v22 = math.min(math.max(0, value2 - value) / v21, 10)
			total += (v22 - total) * 0.25
			value = value2
			now = now2
			local count3 = 0

			for _, v23 in ipairs(v5) do
				if v23.activePlayer.Value then
					count3 += 1
				end
			end

			v16 = math.clamp(math.max(count3, total / 1), 1, 4)
			applyParticleRateMul() -- equivalent call inferred; original call site unknown
		end

		local ichorFull = folder:FindFirstChild("IchorFull")
		local ichor2 = folder:FindFirstChild("Ichor")

		if ichorFull and ichor2 then
			local v22 = ichorFull.Size.X * math.clamp(
				folder.Stats.CurrentAmount.Value / folder.Stats.RequiredAmount.Value,
				0,
				1
			)
			TweenService:Create(ichor2, tweenInfo, {
				Size = Vector3.new(v22, ichor2.Size.Y, ichor2.Size.Z),
				Position = Vector3.new(ichor2.Position.X, Y + v22 / 2, ichor2.Position.Z)
			}):Play()
			local ichorFX3 = folder:FindFirstChild("IchorFX") or folder:FindFirstChild("Ichor Fake position")
			local ichorCap2 = ichorFX3 and (ichorFX3:FindFirstChild("IchorCap") or ichorFX3:FindFirstChild("Ichor Moving"))
			local filling_Ichor2 = ichorCap2 and ichorCap2:FindFirstChild("Filling_Ichor")

			if filling_Ichor2 and filling_Ichor2:IsA("BasePart") then
				local v23 = Y + v22
				TweenService:Create(filling_Ichor2, tweenInfo, {
					Position = Vector3.new(ichor2.Position.X, v23, ichor2.Position.Z)
				}):Play()
			end
		end

		if pour then
			TweenService:Create(pour, tweenInfo, {
				PlaybackSpeed = playbackSpeed
			}):Play()
		end
	end)
	local tweens = {}
	local threads = {}
	local object3 = setmetatable({}, {
		__mode = "k"
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getFakeValveForGen()
		local fakeValveReference = folder:FindFirstChild("FakeValveReference") or folder:FindFirstChild("ValveReference")
		return fakeValveReference and fakeValveReference.Value
	end

	local function getInitialValveSize(p)
		if not p then
			p = getFakeValveForGen()
		end

		if not p then
			return nil
		end

		local v20 = object3[p]

		if v20 then
			return v20
		end

		object3[p] = p.Size
		return p.Size
	end

	local fn

	local function resetEffects(_, options)
		for _, v20 in ipairs(fn()) do
			local fakeValve = v20.fakeValve

			if not fakeValve then
				fakeValve = getFakeValveForGen()
			end

			local size

			if fakeValve then
				size = object3[fakeValve]

				if not size then
					object3[fakeValve] = fakeValve.Size
					size = fakeValve.Size
				end
			end

			if size then
				TweenService:Create(v20.fakeValve, TweenInfo.new(0.5), {
					Size = size
				}):Play()
			end
		end

		local color3 = flag and Color3.fromRGB(58, 165, 56) or Color3.fromRGB(165, 54, 56)

		for _, v20 in ipairs(options or {}) do
			TweenService:Create(v20, TweenInfo.new(0.5), {
				Color = color3
			}):Play()
		end
	end

	local function cancelActiveEffects()
		for _, v20 in pairs(tweens) do
			v20:Cancel()
		end

		table.clear(tweens)

		for _, v20 in ipairs(threads) do
			local v21 = v20
			pcall(function()
				task.cancel(v21)
			end)
		end

		resetEffects(nil, collectSlotLights())
		table.clear(threads)
	end

	fn = function()
		local result2 = {}

		for _, v20 in ipairs(v5) do
			if v20.minigameType == "MovementTreadmill" then
				continue
			end

			local v21 = folder:FindFirstChild("ValveReference" .. v20.suffix) or folder:FindFirstChild("ValveReference")
			local v22 = folder:FindFirstChild("FakeValveReference" .. v20.suffix) or folder:FindFirstChild("FakeValveReference") or v21
			local valve = v21 and v21.Value
			local fakeValve = v22 and v22.Value

			if valve and fakeValve then
				table.insert(result2, {
					valve = valve,
					fakeValve = fakeValve
				})
			end
		end

		return result2
	end

	local function collectSlotFakeValves()
		local fakeValves = {}

		for _, v20 in ipairs(fn()) do
			table.insert(fakeValves, v20.fakeValve)
		end

		return fakeValves
	end

	folder.Stats.Connie.Changed:Connect(function()
		local v20 = collectSlotLights()
		cancelActiveEffects()

		if folder.Stats.Connie.Value == true then
			for _, v21 in ipairs(v5) do
				if not v21.activePlayer.Value then
					continue
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(v21.activePlayer.Value)

				if playerFromCharacter then
					generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
				end

				endmachine(v21)
			end

			if flag then
				local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

				for _, v21 in ipairs(v20) do
					TweenService:Create(v21, tweenInfo2, {
						Color = Color3.fromRGB(165, 54, 56)
					}):Play()
				end

				refreshPromptLockout()
			end

			local thread = task.spawn(function()
				tick()
				local ConnieMonster = require(ReplicatedStorage.MonsterData.ConnieMonster)
				local generatorWaitTime = ConnieMonster.GeneratorWaitTime
				local v21 = generatorWaitTime * 0.33
				local v22 = generatorWaitTime * 0.66

				local function playAnimationEffects()
					local WAIT_INTERVAL = 0.2
					local stats3 = folder:FindFirstChild("Stats")

					if not (stats3 and stats3:FindFirstChild("Connie") and stats3.Connie.Value) then
						return
					end

					local colors = {}

					for _, v23 in ipairs(v20) do
						colors[v23] = v23.Color
					end

					local color3 = Color3.fromRGB(73, 112, 142)

					local function tweenAllLights(duration, fn2)
						for _, v23 in ipairs(v20) do
							local tween = TweenService:Create(v23, TweenInfo.new(duration), {
								Color = fn2(v23)
							})
							table.insert(tweens, tween)
							tween:Play()
						end
					end

					local v23 = collectSlotFakeValves()
					local sizes = {}

					for _, v24 in ipairs(v23) do
						sizes[v24] = v24.Size
					end

					if #v23 > 0 then
						for _, v24 in ipairs(v23) do
							local sound = v24:FindFirstChild("Sound")

							if sound then
								sound:Play()
							end
						end

						local function tweenAllValves(fn2)
							for _, v24 in ipairs(v23) do
								local tween = TweenService:Create(
									v24,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									fn2(v24)
								)
								table.insert(tweens, tween)
								tween:Play()
							end
						end

						for _ = 1, 3 do
							tweenAllValves(function(p)
								local v24 = sizes[p]
								return {
									Size = Vector3.new(v24.X * 1.2, v24.Y * 0.9, v24.Z * 1.2)
								}
							end)
							tweenAllLights(0.2, function()
								return color3
							end)
							task.wait(WAIT_INTERVAL)
							tweenAllValves(function(p)
								local v24 = sizes[p]
								return {
									Size = Vector3.new(v24.X * 0.9, v24.Y * 1.2, v24.Z * 0.9)
								}
							end)
							tweenAllLights(0.2, function(p)
								return colors[p]
							end)
							task.wait(WAIT_INTERVAL)
						end

						tweenAllValves(function(p)
							return {
								Size = sizes[p]
							}
						end)
					else
						for _ = 1, 3 do
							tweenAllLights(0.2, function()
								return color3
							end)
							task.wait(WAIT_INTERVAL)
							tweenAllLights(0.2, function(p)
								return colors[p]
							end)
							task.wait(WAIT_INTERVAL)
						end
					end
				end

				table.insert(threads, task.spawn(function()
					task.wait(v21)
					playAnimationEffects()
				end))
				table.insert(threads, task.spawn(function()
					task.wait(v22)
					playAnimationEffects()
				end))
			end)
			table.insert(threads, thread)

			for _, v21 in ipairs(fn()) do
				v21.valve.Transparency = 1
				v21.fakeValve.Transparency = 0
			end
		else
			if flag then
				local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

				for _, v21 in ipairs(v20) do
					TweenService:Create(v21, tweenInfo2, {
						Color = Color3.fromRGB(58, 165, 56)
					}):Play()
				end

				proximityPrompt.Enabled = false
			end

			refreshPromptLockout()

			for _, v21 in ipairs(fn()) do
				v21.valve.Transparency = 0
				v21.fakeValve.Transparency = 1
			end
		end
	end)
	task.spawn(function()
		while not flag do
			task.wait(1)

			if v4 or folder.Parent == nil or not folder:FindFirstChild("Stats") then
				break
			end

			local completed2 = folder.Stats:FindFirstChild("Completed")
			local v20 = false

			for _, v22 in ipairs(v5) do
				if v22.activePlayer.Value == nil then
					continue
				end

				v20 = true
				break
			end

			if completed2 and completed2.Value == true and not v20 then
				flag = true
				refreshPromptLockout()
				pcall(function()
					local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					for _, part in ipairs((collectSlotLights())) do
						if part and part:IsA("BasePart") and part.Parent then
							TweenService:Create(part, tweenInfo2, {
								Color = Color3.fromRGB(58, 165, 56)
							}):Play()
						end
					end
				end)

				if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
					print(("[GenFill] External completion latched on %s — lights set green"):format(folder.Name))
				end

				break
			else
				for _, v22 in ipairs(v5) do
					local v23 = v22
					task.spawn(function()
						local activePlayer2 = v23.activePlayer
						local prompt3 = v23.prompt
						local value2 = activePlayer2.Value

						if value2 then
							local humanoid = value2:FindFirstChildOfClass("Humanoid")
							local decoding = value2:FindFirstChild("Decoding")
							local v24

							if value2.Parent == nil or humanoid == nil or not (humanoid.Health > 0) then
								v24 = false
							else
								v24 = decoding == nil or decoding.Value == folder
							end

							if not v24 then
								warn(string.format(
									"[GenFill] occupant watchdog: %s STALE on %s slot %d (inWorld=%s decoding=%s) — force-freeing the slot",
									tostring(value2),
									folder.Name,
									v23.index or 1,
									tostring(value2.Parent ~= nil),
									(tostring(decoding and decoding.Value))
								))
								pcall(function()
									endmachine(v23)
								end)

								if activePlayer2.Value == value2 then
									activePlayer2.Value = nil
								end
							end
						end

						local success2, result2 = pcall(function()
							if flag then
								prompt3.Enabled = false
							elseif activePlayer2.Value == nil then
								prompt3.Enabled = true
							else
								prompt3.Enabled = false
							end

							local stats3 = folder:FindFirstChild("Stats")
							local currentAmount2 = stats3 and stats3:FindFirstChild("CurrentAmount")
							local requiredAmount = stats3 and stats3:FindFirstChild("RequiredAmount")

							if currentAmount2 and requiredAmount and currentAmount2.Value >= requiredAmount.Value and not flag then
								local now2 = tick()

								if not v23._fullNoBellAt or now2 - v23._fullNoBellAt >= 3 then
									v23._fullNoBellAt = now2
									local value3 = activePlayer2.Value
									local completed3 = stats3:FindFirstChild("Completed")
									local name = folder.Name
									local index = v23.index or 1
									local value4 = currentAmount2.Value
									local value5 = requiredAmount.Value
									local v25 = not value3 and "nil" or value3.Name or "nil"
									local v26

									if value3 == nil then
										v26 = false
									else
										v26 = value3.Parent ~= nil
									end

									warn(string.format(
										"[GenFill] FULL METER, NO BELL on %s slot %d — amount=%.1f/%.1f occupant=%s occupantInWorld=%s filling=%s failedskillcheck=%s skillchecking=%s Stats.Completed=%s",
										name,
										index,
										value4,
										value5,
										v25,
										tostring(v26),
										tostring(v17),
										tostring(v23.failedskillcheck),
										tostring(v23.skillchecking),
										(tostring(completed3 and completed3.Value))
									))
								end
							end

							if activePlayer2.Value == nil or v17 ~= true or v23.failedskillcheck ~= false or activePlayer2.Value.Parent == nil then
								if flag2 then
									flag2 = false
									animationStop:FireAllClients(folder, "Activate")
								end
							else
								local humanoidRootPart = activePlayer2.Value:FindFirstChild("HumanoidRootPart")

								if humanoidRootPart and prompt3 and prompt3:IsA("BasePart") then
									local magnitude = (humanoidRootPart.Position - prompt3.Position).Magnitude

									if magnitude > 25 then
										if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
											warn(string.format(
												"[GenFill] Slot %d torn down — %s drifted %.1f studs from prompt (off-gen guard)",
												v23.index or 1,
												activePlayer2.Value.Name,
												magnitude
											))
										end

										local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

										if playerFromCharacter then
											generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
										end

										endmachine(v23)
										return
									end
								end

								flag2 = true
								local value3 = activePlayer2.Value
								local stats4 = value3:WaitForChild("Stats")
								local decodeSpeed = stats4:WaitForChild("DecodeSpeed")
								local decodeSpeedModifier = stats4:WaitForChild("DecodeSpeedModifier")
								local info2 = workspace:FindFirstChild("Info")
								local v24 = info2 and info2:FindFirstChild("ForceMovementTreadmill") and true or v23.minigameType == "MovementTreadmill" or false
								local v25 = v23.minigameType == "Barnaby"
								local decodeMultiplier = MachineEffects.GetDecodeMultiplier(folder)
								local v26 = decodeSpeed.Value * decodeSpeedModifier.Value * decodeMultiplier

								if not (v24 or v25) then
									folder.Stats.CurrentAmount.Value += v26
								end

								if not folder.PlayerCompletion:FindFirstChild(activePlayer2.Value.Name) then
									local numberValue = Instance.new("NumberValue")
									numberValue.Name = activePlayer2.Value.Name
									numberValue.Value = 0
									numberValue.Parent = folder.PlayerCompletion
								end

								if not v25 then
									folder.PlayerCompletion[activePlayer2.Value.Name].Value += v26
								end

								local trinkets = value3:WaitForChild("Trinkets")
								local trinket1 = trinkets:WaitForChild("Trinket1")
								local trinket2 = trinkets:WaitForChild("Trinket2")
								local child = ReplicatedStorage.TrinketData:FindFirstChild(trinket1.Value)
								local child2 = ReplicatedStorage.TrinketData:FindFirstChild(trinket2.Value)

								if child then
									local module = require(child)

									if module.MachineEvent then
										module.TriggerMachineEvent(trinket1, folder, activePlayer2)
									end
								end

								if child2 then
									local module = require(child2)

									if module.MachineEvent then
										module.TriggerMachineEvent(trinket2, folder, activePlayer2)
									end
								end

								if folder.Stats.CurrentAmount.Value >= folder.Stats.RequiredAmount.Value and not flag and activePlayer2.Value ~= nil then
									flag = true
									local value4 = folder.Stats.Completed.Value
									folder.Stats.Completed.Value = true
									local v27 = folder:GetAttribute("MinigameType") == "Barnaby"

									if not v27 then
										for i = 2, 8 do
											if folder:GetAttribute("Prompt" .. i .. "MinigameType") ~= "Barnaby" then
												continue
											end

											v27 = true
											break
										end
									end

									if v27 then
										pcall(function()
											BarnabyCabinetScreen.Set(folder, "win")
										end)
									end

									task.spawn(function()
										for i = 1, 6 do
											task.wait(1)
											local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

											if not inGamePlayers then
												continue
											end

											for i2, child3 in ipairs(inGamePlayers:GetChildren()) do
												local decoding = child3:FindFirstChild("Decoding")

												if not (decoding and decoding.Value == folder) then
													continue
												end

												warn(string.format(
													"[GeneratorFillScript] STUCK-PLAYER WATCHDOG: %s still Decoding on completed gen %s — force-cleaning (a cleanup path threw before unanchor, or entry committed post-completion)",
													child3.Name,
													folder.Name
												))
												local primaryPart = child3.PrimaryPart

												if primaryPart then
													primaryPart.Anchored = false
													local primaryPart2 = primaryPart
													local v29 = child3
													pcall(function()
														primaryPart2:SetNetworkOwner(Players:GetPlayerFromCharacter(v29))
													end)
												end

												local v28 = decoding
												pcall(function()
													v28.Value = nil
												end)
												local v29 = child3
												pcall(function()
													animationStop:FireAllClients(v29, "Decode")
												end)
												local playerFromCharacter = Players:GetPlayerFromCharacter(child3)

												if playerFromCharacter then
													generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
												end

												for i3, v30 in ipairs(v5) do
													if v30.activePlayer.Value ~= child3 then
														continue
													end

													if v30.minigameType == "Barnaby" then
														warn(string.format(
															"[GeneratorFillScript] STUCK-PLAYER WATCHDOG: closing orphaned Barnaby arcade for %s on %s (suffix=%q) — would otherwise ride the fish game to floor-end",
															child3.Name,
															folder.Name,
															v30.suffix or ""
														))
														local v31 = v30
														pcall(function()
															BarnabyMinigameBridgeServer.StopClient(folder, v31.suffix)
														end)
													end

													v30.activePlayer.Value = nil
												end
											end
										end

										pcall(function()
											animationStop:FireAllClients(folder, "Activate")
										end)
										pcall(function()
											local tweenInfo2 = TweenInfo.new(
												0.5,
												Enum.EasingStyle.Quad,
												Enum.EasingDirection.Out
											)

											for i, part in ipairs((collectSlotLights())) do
												if part and part:IsA("BasePart") and part.Parent then
													TweenService:Create(part, tweenInfo2, {
														Color = Color3.fromRGB(58, 165, 56)
													}):Play()
												end
											end
										end)
									end)
									local v28 = {}
									local playerFromCharacters = {}

									for i, v29 in ipairs(v5) do
										if not v29.activePlayer.Value then
											continue
										end

										local playerFromCharacter = Players:GetPlayerFromCharacter(v29.activePlayer.Value)

										if not playerFromCharacter then
											continue
										end

										v28[playerFromCharacter.Name] = true
										table.insert(playerFromCharacters, playerFromCharacter)
									end

									for i, v29 in ipairs(v5) do
										if not (v29 ~= v23 and v29.activePlayer.Value) then
											continue
										end

										local playerFromCharacter = Players:GetPlayerFromCharacter(v29.activePlayer.Value)

										if playerFromCharacter then
											generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
										end

										endmachine(v29)
									end

									local minigameType3 = folder:GetAttribute("MinigameType")
									local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)
									local modifierSnapshot = MachineEffects.GetModifierSnapshot(folder)

									for i, v29 in ipairs(playerFromCharacters) do
										ActionEvent:Record(v29, "ExtractCompleted", minigameType3, modifierSnapshot)
									end

									if not (value4 or workspace.Info:GetAttribute("DontCountGeneratorCompletions")) then
										workspace.Info.GeneratorsCompleted.Value += 1
									end

									if activePlayer2.Value ~= nil then
										local config = value3:WaitForChild("Config")
										local child3 = ReplicatedStorage.DialogueModules:FindFirstChild(config.ModuleName.Value)

										if child3 then
											local module = require(child3)
											dialogueEvent:Fire(
												value3,
												config.ModuleName.Value,
												module.FinishDecode[math.random(1, #module.FinishDecode)],
												4
											)
										end

										for i, v29 in ipairs(playerFromCharacters) do
											if v29 == playerFromCharacter then
												continue
											end

											local character = v29.Character
											local config2 = character and character:FindFirstChild("Config")
											local moduleName = config2 and config2:FindFirstChild("ModuleName")
											local value5 = moduleName and moduleName.Value

											if not (value5 and value5 ~= "") then
												continue
											end

											local child4 = ReplicatedStorage.DialogueModules:FindFirstChild(value5)

											if not child4 then
												continue
											end

											local module = require(child4)
											dialogueEvent:Fire(
												character,
												value5,
												module.FinishDecode[math.random(1, #module.FinishDecode)],
												4
											)
										end

										if playerFromCharacter then
											generatorUpdate:FireClient(playerFromCharacter, folder, "Complete")
										end

										ReplicatedStorage.Events.MachineCompletedEvent:Fire(
											activePlayer2.Value,
											folder,
											playerFromCharacters
										)

										if v23.minigameType == "Barnaby" then
											pcall(function()
												BarnabyMinigameBridgeServer.MarkWon(folder, v23.suffix)
											end)
											local suffix = v23.suffix
											local info3 = workspace:FindFirstChild("Info")
											local v29 = info3 and info3:GetAttribute("BarnabyWinAutoFly") == true and 3 or 0
											task.delay(v29, function()
												pcall(function()
													BarnabyMinigameBridgeServer.StopClient(folder, suffix)
												end)
											end)
										end

										local value5 = activePlayer2.Value

										if value5 and value5:FindFirstChild("Config") then
											local passiveToon = TowerLUT:GetPassiveToon(value5)
											local passiveTower = passiveToon and passiveToon ~= "" and TowerLUT:GetPassiveTower(value5)

											if passiveTower then
												local module = require(passiveTower)

												if typeof(module.GeneratorAbility) == "function" then
													task.spawn(function()
														module.GeneratorAbility(value5)
													end)
												end
											end
										end

										for i, v29 in ipairs(playerFromCharacters) do
											if v29 == playerFromCharacter then
												continue
											end

											local character = v29.Character

											if not (character and character:FindFirstChild("Config")) then
												continue
											end

											local passiveToon = TowerLUT:GetPassiveToon(character)

											if not (passiveToon and passiveToon ~= "") then
												continue
											end

											local passiveTower = TowerLUT:GetPassiveTower(character)

											if not passiveTower then
												continue
											end

											local module = require(passiveTower)

											if typeof(module.GeneratorAbility) ~= "function" then
												continue
											end

											local v30 = module
											local character2 = character
											task.spawn(function()
												v30.GeneratorAbility(character2)
											end)
										end

										v17 = false

										if pour then
											pour:Stop()
										end

										setDripEnabled(false) -- equivalent call inferred; original call site unknown
										local v29 = v18[v23]

										if v29 then
											if type(v29.Stop) == "function" then
												local success3, result3 = pcall(function()
													v29.Stop(true)
												end)

												if not success3 then
													warn(
														"[GeneratorFillScript] Failed to stop treadmill on completion:",
														result3
													)
												end
											end

											v18[v23] = nil

											if v19 == v29 then
												v19 = nil
											end
										end

										if playerFromCharacter then
											removeCharacterAntiExploitModule:Fire(playerFromCharacter, true)
										end

										task.wait()

										if v23.minigameType == "MovementTreadmill" and value3 and value3.Parent ~= nil then
											local child4 = folder:FindFirstChild("TreadmillTeleportPositions" .. v23.suffix)
											local treadmillTeleportPositions2 = folder:FindFirstChild("TreadmillTeleportPositions")
											local treadmillLeavePosition = folder:FindFirstChild("TreadmillLeavePosition" .. v23.suffix) or child4 and child4:FindFirstChild("TreadmillLeavePosition")

											if not treadmillLeavePosition then
												if v23.suffix == "" then
													treadmillLeavePosition = folder:FindFirstChild("TreadmillLeavePosition")

													if not treadmillLeavePosition then
														if treadmillTeleportPositions2 then
															treadmillLeavePosition = treadmillTeleportPositions2:FindFirstChild("TreadmillLeavePosition") or nil
														else
															treadmillLeavePosition = nil
														end
													end
												else
													treadmillLeavePosition = nil
												end
											end

											if treadmillLeavePosition then
												local primaryPart = value3.PrimaryPart
												local humanoid = value3:FindFirstChild("Humanoid")

												if primaryPart and humanoid then
													local v30 = humanoid.HipHeight + primaryPart.Size.Y / 2
													local v32 = nudgeIfClipped(
														treadmillLeavePosition.CFrame + Vector3.new(0, v30, 0),
														value3,
														folder
													)
													value3:PivotTo(v32)

													if value3:GetPivot() ~= v32 then
														value3:PivotTo(v32)
													end
												end
											end
										end

										value3.PrimaryPart.Anchored = false
										value3.PrimaryPart:SetNetworkOwner(playerFromCharacter)
										task.spawn(function()
											task.wait(1)

											if playerFromCharacter then
												removeCharacterAntiExploitModule:Fire(playerFromCharacter, false)
											end
										end)

										if value3:WaitForChild("Decoding") then
											value3.Decoding.Value = nil
										end

										animationStop:FireAllClients(value3, "Decode")
										animationStop:FireAllClients(folder, "Activate")

										local function _buildEligibleSet(eligibility)
											local result3 = {}

											if eligibility == "OnlyCompleters" then
												for i, objectValue in ipairs(folder.Stats:GetChildren()) do
													if not (objectValue:IsA("ObjectValue") and objectValue.Name:match("^ActivePlayer%d*$") and objectValue.Value) then
														continue
													end

													local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(objectValue.Value)

													if not playerFromCharacter2 then
														continue
													end

													local child4 = folder.PlayerCompletion:FindFirstChild(playerFromCharacter2.Name)
													result3[playerFromCharacter2.Name] = child4 and child4.Value or 0
												end
											else
												for i, child4 in pairs(folder.PlayerCompletion:GetChildren()) do
													result3[child4.Name] = child4.Value
												end
											end

											return result3
										end

										local machineFamily = folder:GetAttribute("MachineFamily") or "SINGLE"
										local rewardPolicy = MachineSpawnResolver.resolveRewardPolicy(
											MultiGenConfig,
											machineFamily
										)
										local v30 = _buildEligibleSet(rewardPolicy.Eligibility)
										local v31 = folder:GetAttribute("BreakRoomGen") and {} or v30
										local HolidayEventConfig = require(game.ReplicatedStorage.SharedData.HolidayEventConfig)
										local HolidayCurrencyModule = require(game.ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("HolidayCurrencyModule"))

										for k, v32 in pairs(v31) do
											local v33 = k
											local v34 = v32
											local success3, result3 = pcall(function()
												if Players:FindFirstChild(v33) then
													local GENERATOR_REWARD, v35, v36

													if rewardPolicy.AmountSplit == "Flat" then
														GENERATOR_REWARD = HolidayCurrencyModule.GENERATOR_REWARD
														v35 = 5
														v36 = 10
													else
														local v37 = v34 / folder.Stats.RequiredAmount.Value
														v35 = math.clamp(math.round(5 * v37), 0, 5)
														v36 = math.clamp(math.round(10 * v37), 0, 10)
														GENERATOR_REWARD = math.clamp(
															math.round(HolidayCurrencyModule.GENERATOR_REWARD * v37),
															0,
															HolidayCurrencyModule.GENERATOR_REWARD
														)
														print(string.format(
															"[BARNABY-ICHOR-DBG] gen=%s player=%s contribution=%.2f/%.0f ratio=%.2f -> ichor=%d tapes=%d",
															folder.Name,
															v33,
															v34,
															folder.Stats.RequiredAmount.Value,
															v37,
															v35,
															v36
														))
													end

													local v37 = not HolidayEventConfig.ENABLED and 0 or GENERATOR_REWARD
													local flag3 = false

													if v35 ~= 0 or v36 ~= 0 or v37 ~= 0 or v28[v33] then
														if Players:FindFirstChild(v33) then
															local player = Players[v33]
															editData:Invoke(Players[v33], function(p)
																if p then
																	if p.Data.EquippedTrinket1 == "UnreleasedIchorItem" or p.Data.EquippedTrinket2 == "UnreleasedIchorItem" then
																		local v38 = v35 + 1
																		IchorTransactions:GiveIchor(
																			player,
																			p,
																			v38,
																			true
																		)
																		AnalyticsService:TrackCoinEarned(
																			player,
																			v38,
																			"Generator",
																			{
																				HasIchorTrinket = true
																			}
																		)
																		flag3 = true
																	else
																		local v38 = v35
																		IchorTransactions:GiveIchor(
																			player,
																			p,
																			v38,
																			true
																		)
																		AnalyticsService:TrackCoinEarned(
																			player,
																			v38,
																			"Generator",
																			{
																				HasIchorTrinket = false
																			}
																		)
																	end

																	if v37 > 0 then
																		local matchLockedMultiplier = workspace.Info:GetAttribute("MatchLockedMultiplier")
																		local v38 = HolidayCurrencyModule.Grant(
																			player,
																			"Generator",
																			v37,
																			matchLockedMultiplier
																		)
																		print(string.format(
																			"[MachinePumpkins] gen=%s player=%s fill=%.2f/%.0f ichor=%d pumpkins=%d granted=%d",
																			folder.Name,
																			v33,
																			v34,
																			folder.Stats.RequiredAmount.Value,
																			v35,
																			v37,
																			v38
																		))
																	end

																	if v28[v33] then
																		StatisticsManager:IncrementKey(
																			player,
																			"GeneratorsCompleted",
																			1
																		)
																		local v38 = false

																		for k2, v40 in pairs(p.Data.Mastery) do
																			local character = player and player.Character
																			local config2 = character and character:FindFirstChild("Config")
																			local moduleName = config2 and config2:FindFirstChild("ModuleName")
																			local value6 = moduleName and moduleName.Value

																			if not (value6 and value6 ~= "" and v40.Name == value6) then
																				continue
																			end

																			v38 = v40
																			break
																		end

																		if v38 then
																			for k2, v40 in pairs(v38.RequirementList) do
																				if v40.Name == "CompleteGenerator" then
																					v40.Current += 1

																					if v40.Current >= v40.Amount then
																						v40.Current = v40.Amount
																					end
																				elseif v40.Name == "CompleteDuoGenerator" and #playerFromCharacters >= 2 then
																					v40.Current += 1

																					if v40.Current >= v40.Amount then
																						v40.Current = v40.Amount
																					end
																				end
																			end
																		end
																	end
																end
															end)
														end

														if workspace.Info.PlayerStats:FindFirstChild(v33) then
															local child4 = workspace.Info.PlayerStats:WaitForChild(v33)

															if flag3 then
																local ichor2 = child4:WaitForChild("Ichor")
																ichor2.Value += v35 + 1
															else
																local ichor2 = child4:WaitForChild("Ichor")
																ichor2.Value += v35
															end
														end

														local child4 = workspace.Info.PlayerStats:FindFirstChild(v33)

														if child4 then
															local survivalPoints = child4:WaitForChild("SurvivalPoints")
															survivalPoints.Value += v36
															local generators2 = child4:WaitForChild("Generators")
															generators2.Value += 1
														end
													end
												end
											end)

											if not success3 then
												warn("[GeneratorFillScript] reward grant failed for", k, ":", result3)
											end
										end

										activePlayer2.Value = nil
										prompt3.Enabled = false
										local tweenInfo2 = TweenInfo.new(
											0.5,
											Enum.EasingStyle.Quad,
											Enum.EasingDirection.Out,
											0,
											false
										)

										for i, v32 in ipairs((collectSlotLights())) do
											TweenService:Create(v32, tweenInfo2, {
												Color = Color3.fromRGB(58, 165, 56)
											}):Play()
										end

										folder.Prompt.Correct:Play()
									end
								elseif not (v24 or v25) then
									local v27 = math.random(1, 100)
									local skillCheckChanceMultiplier = MachineEffects.GetSkillCheckChanceMultiplier(folder)
									local skillCheckChanceAdditive = MachineEffects.GetSkillCheckChanceAdditive(folder)

									if v27 <= math.max(
										0,
										stats4.SkillCheckChance.Value * skillCheckChanceMultiplier + skillCheckChanceAdditive
									) and not v23.skillchecking and tick() - v23.ticktime >= 4 then
										task.spawn(function()
											if activePlayer2.Value ~= nil then
												v23.skillchecking = true
												local name = tostring(activePlayer2.Value.Name)
												local minigameType3 = v23.minigameType or folder:GetAttribute("MinigameType")
												local flag3

												if minigameType3 == "Circle" then
													flag3 = true
												elseif minigameType3 == "Original" then
													flag3 = false
												else
													flag3 = false

													if minigameType3 ~= "MovementTreadmill" then
														warn(
															"[GeneratorFillScript] Skill check fallback for attribute:",
															minigameType3
														)
													end
												end

												local v28

												if flag3 then
													local v29 = {
														type = "circle",
														generator = folder,
														boundarySize = stats4.BoundarySize.Value,
														boundaryModifier = stats4.BoundarySizeModifier.Value,
														randomPosition = true,
														movementPattern = "none",
														movementConfig = {
															speed = 1,
															amplitude = 50,
															radius = 30
														},
														circles = {
															{
																reward = 1
															},
															{
																reward = stats4.SkillCheckValue.Value
															},
															{
																reward = 0
															}
														}
													}

													local function invokeCircleSkillCheckWithTimeout(playerFromCharacter, p, p2)
														local v30 = skillcheckUpdate
														local flag4 = false
														local v31 = nil
														coroutine.wrap(function()
															local success3, result3 = pcall(function()
																v31 = v30:InvokeClient(playerFromCharacter, folder, p)
															end)
															flag4 = true
														end)()
														local lastTime = tick()

														while not flag4 and tick() - lastTime < p2 do
															local RunService = game:GetService("RunService")
															RunService.Heartbeat:Wait()
														end

														if flag4 then
															return v31
														end

														return "noinput"
													end

													local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

													if playerFromCharacter then
														if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
															print(string.format(
																"[GenFill] Skillcheck FIRE Circle gen=%s slot=%d player=%s",
																folder.Name,
																v23.index or 1,
																playerFromCharacter.Name
															))
														end

														v28 = invokeCircleSkillCheckWithTimeout(
															playerFromCharacter,
															v29,
															5
														)
													else
														v28 = "noinput"
													end
												else
													local v29 = stats4.BoundarySize.Value * stats4.BoundarySizeModifier.Value * math.random(
														95,
														105
													) / 100 / 1000
													local v30 = math.random(20, 100) / 100 - v29

													local function invokeClientWithTimeout(playerFromCharacter, p, p2, p3)
														local v31 = skillcheckUpdate
														local flag4 = false
														local v32 = nil
														coroutine.wrap(function()
															local success3, result3 = pcall(function()
																v32 = v31:InvokeClient(
																	playerFromCharacter,
																	folder,
																	p,
																	p2
																)
															end)
															flag4 = true
														end)()
														local lastTime = tick()

														while not flag4 and tick() - lastTime < p3 do
															local RunService = game:GetService("RunService")
															RunService.Heartbeat:Wait()
														end

														if flag4 then
															return v32
														end

														return "noinput"
													end

													local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

													if playerFromCharacter then
														if MultiGenConfig and MultiGenConfig.DEBUG_PRINT then
															print(string.format(
																"[GenFill] Skillcheck FIRE Original gen=%s slot=%d player=%s",
																folder.Name,
																v23.index or 1,
																playerFromCharacter.Name
															))
														end

														v28 = invokeClientWithTimeout(playerFromCharacter, v29, v30, 5)
													else
														v28 = "noinput"
													end
												end

												if flag3 and type(v28) == "table" then
													if v28.hit and v28.circle then
														if v28.circle == "great" then
															if not flag and activePlayer2.Value then
																v23.skillchecking = false
																local value4 = activePlayer2.Value
																local skillCheckValue = value4:WaitForChild("Stats"):WaitForChild("SkillCheckValue")
																folder.Stats.CurrentAmount.Value += skillCheckValue.Value
																folder.PlayerCompletion[activePlayer2.Value.Name].Value += skillCheckValue.Value
																folder:SetAttribute("LastSkillCheckResult", "great")
																folder:SetAttribute("LastSkillCheckTime", tick())
																emitSuccessBurst()
																local trinkets2 = value4:WaitForChild("Trinkets")
																local trinket12 = trinkets2:WaitForChild("Trinket1")
																local trinket22 = trinkets2:WaitForChild("Trinket2")
																local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
																local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

																if child3 then
																	local module = require(child3)

																	if module.SkillCheckCompleteEvent then
																		module.TriggerSkillCheckCompleteEvent(
																			trinket12,
																			folder,
																			activePlayer2
																		)
																	end
																end

																if child4 then
																	local module = require(child4)

																	if module.SkillCheckCompleteEvent then
																		module.TriggerSkillCheckCompleteEvent(
																			trinket22,
																			folder,
																			activePlayer2
																		)
																	end
																end
															end
														elseif v28.circle == "good" and not flag and activePlayer2.Value then
															v23.skillchecking = false
															local value4 = activePlayer2.Value
															folder:SetAttribute("LastSkillCheckResult", "good")
															folder:SetAttribute("LastSkillCheckTime", tick())
															emitSuccessBurst()
															local trinkets2 = value4:WaitForChild("Trinkets")
															local trinket12 = trinkets2:WaitForChild("Trinket1")
															local trinket22 = trinkets2:WaitForChild("Trinket2")
															local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
															local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

															if child3 then
																local module = require(child3)

																if module.SkillCheckCompleteEvent then
																	module.TriggerSkillCheckCompleteEvent(
																		trinket12,
																		folder,
																		activePlayer2
																	)
																end
															end

															if child4 then
																local module = require(child4)

																if module.SkillCheckCompleteEvent then
																	module.TriggerSkillCheckCompleteEvent(
																		trinket22,
																		folder,
																		activePlayer2
																	)
																end
															end
														end
													elseif not flag then
														if activePlayer2.Value ~= nil and tostring(activePlayer2.Value.Name) == name then
															local value4 = activePlayer2.Value
															folder:SetAttribute("LastSkillCheckResult", "miss")
															folder:SetAttribute("LastSkillCheckTime", tick())
															local trinkets2 = value4:WaitForChild("Trinkets")
															local trinket12 = trinkets2:WaitForChild("Trinket1")
															local trinket22 = trinkets2:WaitForChild("Trinket2")
															local flag4 = true
															local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
															local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

															if child3 then
																local module = require(child3)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket12,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

																			if playerFromCharacter then
																				displayMessage:FireClient(
																					playerFromCharacter,
																					module.GeneratorText,
																					Color3.fromRGB(100, 255, 100)
																				)
																			end
																		end
																	end
																end
															end

															if flag4 and child4 then
																local module = require(child4)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket22,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

																			if playerFromCharacter then
																				displayMessage:FireClient(
																					playerFromCharacter,
																					module.GeneratorText,
																					Color3.fromRGB(100, 255, 100)
																				)
																			end
																		end
																	end
																end
															end

															if flag4 then
																ReplicatedStorage.Events.MachineEvent:Fire(
																	activePlayer2.Value,
																	folder
																)
																local promptPart = v23 and v23.promptPart or folder:FindFirstChild("Prompt")
																local fail2 = promptPart and promptPart:FindFirstChild("Fail")

																if fail2 and fail2.Playing ~= true then
																	fail2:Play()
																end
															end
														end

														local minigameType4 = folder:GetAttribute("MinigameType")
														ActionEvent:Record(
															activePlayer2.Value,
															"ExtractFailed",
															minigameType4,
															1651
														)
														v23.failedskillcheck = true
														task.wait(3)
														v23.failedskillcheck = false
														v23.skillchecking = false

														if activePlayer2.Value and activePlayer2.Value.Parent ~= nil then
															setDripEnabled(true)
															local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

															if playerFromCharacter then
																ActionEvent:Record(
																	playerFromCharacter,
																	"ExtractContinue",
																	minigameType4
																)
															end

															animateTower:FireAllClients(folder, "Activate")
														end
													end
												elseif v28 == true then
													if not flag and activePlayer2.Value then
														v23.skillchecking = false
														local value4 = activePlayer2.Value
														folder:SetAttribute("LastSkillCheckResult", "good")
														folder:SetAttribute("LastSkillCheckTime", tick())
														emitSuccessBurst()
														local playerFromCharacter = Players:GetPlayerFromCharacter(value4)

														if playerFromCharacter then
															ActionEvent:Record(
																playerFromCharacter,
																"ExctractionSkillCheck",
																"good"
															)
														end

														local trinkets2 = value4:WaitForChild("Trinkets")
														local trinket12 = trinkets2:WaitForChild("Trinket1")
														local trinket22 = trinkets2:WaitForChild("Trinket2")
														local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
														local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

														if child3 then
															local module = require(child3)

															if module.SkillCheckCompleteEvent then
																module.TriggerSkillCheckCompleteEvent(
																	trinket12,
																	folder,
																	activePlayer2
																)
															end
														end

														if child4 then
															local module = require(child4)

															if module.SkillCheckCompleteEvent then
																module.TriggerSkillCheckCompleteEvent(
																	trinket22,
																	folder,
																	activePlayer2
																)
															end
														end
													end
												elseif v28 == "supercomplete" then
													if not flag and activePlayer2.Value then
														v23.skillchecking = false
														local value4 = activePlayer2.Value
														folder:SetAttribute("LastSkillCheckResult", "great")
														folder:SetAttribute("LastSkillCheckTime", tick())
														emitSuccessBurst()
														local playerFromCharacter = Players:GetPlayerFromCharacter(value4)

														if playerFromCharacter then
															ActionEvent:Record(
																playerFromCharacter,
																"ExctractionSkillCheck",
																"great"
															)
														end

														local trinkets2 = value4:WaitForChild("Trinkets")
														local trinket12 = trinkets2:WaitForChild("Trinket1")
														local trinket22 = trinkets2:WaitForChild("Trinket2")
														local skillCheckValue = value4:WaitForChild("Stats"):WaitForChild("SkillCheckValue")
														folder.Stats.CurrentAmount.Value += skillCheckValue.Value
														folder.PlayerCompletion[activePlayer2.Value.Name].Value += skillCheckValue.Value
														local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
														local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

														if child3 then
															local module = require(child3)

															if module.SkillCheckCompleteEvent then
																module.TriggerSkillCheckCompleteEvent(
																	trinket12,
																	folder,
																	activePlayer2
																)
															end
														end

														if child4 then
															local module = require(child4)

															if module.SkillCheckCompleteEvent then
																module.TriggerSkillCheckCompleteEvent(
																	trinket22,
																	folder,
																	activePlayer2
																)
															end
														end
													end
												elseif v28 == false then
													if not flag then
														if activePlayer2.Value ~= nil and tostring(activePlayer2.Value.Name) == name then
															local value4 = activePlayer2.Value
															folder:SetAttribute("LastSkillCheckResult", "miss")
															folder:SetAttribute("LastSkillCheckTime", tick())
															local trinkets2 = value4:WaitForChild("Trinkets")
															local trinket12 = trinkets2:WaitForChild("Trinket1")
															local trinket22 = trinkets2:WaitForChild("Trinket2")
															local flag4 = true
															local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
															local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

															if child3 then
																local module = require(child3)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket12,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			displayMessage:FireClient(
																				Players:GetPlayerFromCharacter(activePlayer2.Value),
																				module.GeneratorText,
																				Color3.fromRGB(100, 255, 100)
																			)
																		end
																	end
																end
															end

															if flag4 and child4 then
																local module = require(child4)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket22,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			displayMessage:FireClient(
																				Players:GetPlayerFromCharacter(activePlayer2.Value),
																				module.GeneratorText,
																				Color3.fromRGB(100, 255, 100)
																			)
																		end
																	end
																end
															end

															if flag4 then
																ReplicatedStorage.Events.MachineEvent:Fire(
																	activePlayer2.Value,
																	folder
																)
																local promptPart = v23 and v23.promptPart or folder:FindFirstChild("Prompt")
																local fail2 = promptPart and promptPart:FindFirstChild("Fail")

																if fail2 and fail2.Playing ~= true then
																	fail2:Play()
																end
															end
														end

														local minigameType4 = folder:GetAttribute("MinigameType")
														ActionEvent:Record(
															activePlayer2.Value,
															"ExtractFailed",
															minigameType4,
															"bad_timing"
														)
														v23.failedskillcheck = true
														task.wait(3)
														v23.failedskillcheck = false
														v23.skillchecking = false

														if activePlayer2.Value and activePlayer2.Value.Parent ~= nil then
															setDripEnabled(true)
															local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

															if playerFromCharacter then
																ActionEvent:Record(
																	playerFromCharacter,
																	"ExtractContinue",
																	minigameType4
																)
															end

															animateTower:FireAllClients(folder, "Activate")
														end
													end
												elseif v28 == "noinput" then
													if not flag then
														if activePlayer2.Value ~= nil and tostring(activePlayer2.Value.Name) == name then
															local trinkets2 = activePlayer2.Value:WaitForChild("Trinkets")
															local trinket12 = trinkets2:WaitForChild("Trinket1")
															local trinket22 = trinkets2:WaitForChild("Trinket2")
															local flag4 = true
															local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket12.Value)
															local child4 = ReplicatedStorage.TrinketData:FindFirstChild(trinket22.Value)

															if child3 then
																local module = require(child3)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket12,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			displayMessage:FireClient(
																				Players:GetPlayerFromCharacter(activePlayer2.Value),
																				module.GeneratorText,
																				Color3.fromRGB(100, 255, 100)
																			)
																		end
																	end
																end
															end

															if flag4 and child4 then
																local module = require(child4)

																if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
																	trinket22,
																	folder,
																	activePlayer2
																) then
																	flag4 = false

																	if module.GeneratorSound then
																		Audio:Play(module.GeneratorSound, {
																			Volume = 0.5,
																			Parent = folder
																		})
																	end

																	if module.GeneratorText then
																		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

																		if displayMessage then
																			displayMessage:FireClient(
																				Players:GetPlayerFromCharacter(activePlayer2.Value),
																				module.GeneratorText,
																				Color3.fromRGB(100, 255, 100)
																			)
																		end
																	end
																end
															end

															if flag4 then
																ReplicatedStorage.Events.MachineEvent:Fire(
																	activePlayer2.Value,
																	folder
																)
																local promptPart = v23 and v23.promptPart or folder:FindFirstChild("Prompt")
																local fail2 = promptPart and promptPart:FindFirstChild("Fail")

																if fail2 and fail2.Playing ~= true then
																	fail2:Play()
																end
															end
														end

														local minigameType4 = folder:GetAttribute("MinigameType")
														ActionEvent:Record(
															activePlayer2.Value,
															"ExtractFailed",
															minigameType4,
															"timed_out"
														)
														v23.failedskillcheck = true
														task.wait(5)
														v23.failedskillcheck = false
														v23.skillchecking = false

														if activePlayer2.Value and activePlayer2.Value.Parent ~= nil and folder and folder.Parent ~= nil then
															setDripEnabled(true)
															local playerFromCharacter = Players:GetPlayerFromCharacter(activePlayer2.Value)

															if playerFromCharacter then
																ActionEvent:Record(
																	playerFromCharacter,
																	"ExtractContinue",
																	minigameType4
																)
															end

															animateTower:FireAllClients(folder, "Activate")
														end
													end
												else
													warn(string.format(
														"[GenFill] unrecognized skillcheck result %s on %s slot %d (player=%s) — resetting skillchecking",
														tostring(v28),
														folder.Name,
														v23.index or 1,
														name
													))
													v23.skillchecking = false
												end
											end
										end)
										v23.ticktime = tick()
									end
								end
							end
						end)

						if not success2 then
							local value3 = activePlayer2.Value
							warn(string.format(
								"[GenFill] tick error on %s slot %d (occupant=%s): %s",
								folder.Name,
								v23.index or 1,
								value3 and value3.Name or "nil",
								(tostring(result2))
							))
						end
					end)
				end
			end
		end
	end)
end

function GeneratorFillScript.BeginAutoDrill(model, model2, p, value)
	if not (model and model:IsA("Model")) then
		warn("[GeneratorFillScript] BeginAutoDrill: invalid generator")
		return function() end
	end

	if not (model2 and model2:IsA("Model")) then
		warn("[GeneratorFillScript] BeginAutoDrill: invalid character")
		return function() end
	end

	local stats = model:FindFirstChild("Stats")
	local currentAmount = stats and stats:FindFirstChild("CurrentAmount")
	local requiredAmount = stats and stats:FindFirstChild("RequiredAmount")
	local completed = stats and stats:FindFirstChild("Completed")
	local forceStop = stats and stats:FindFirstChild("ForceStop")

	if not (currentAmount and requiredAmount and completed and forceStop) then
		warn("[GeneratorFillScript] BeginAutoDrill: generator missing Stats children")
		return function() end
	end

	if completed.Value then
		return function() end
	end

	local v2 = value or 10
	local playerFromCharacter = Players:GetPlayerFromCharacter(model2)
	local moduleName = model2:FindFirstChild("Config") and model2.Config:FindFirstChild("ModuleName")
	local v3 = nil
	local tower = moduleName and TowerLUT:GetTower(moduleName.Value)

	if tower then
		pcall(function()
			local module = require(tower)
			v3 = module

			if type(v3.GeneratorBeginDrill) == "function" then
				v3.GeneratorBeginDrill(model2, model, playerFromCharacter)
			end
		end)
	end

	GeneratorFillScript.PlayRevealAnimation(model)
	local emitters = {}
	local emitters2 = {}
	local ichorFX = model:FindFirstChild("IchorFX") or model:FindFirstChild("Ichor Fake position")

	if ichorFX then
		for _, emitter in ipairs(ichorFX:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent and emitter.Parent.Name == "DripCatch" then
				table.insert(emitters2, emitter)
			else
				table.insert(emitters, emitter)
			end
		end
	end

	local count2 = 0

	local function setIchorFakeParticles(enabled)
		for _, v4 in ipairs(emitters) do
			v4.Enabled = enabled
		end

		if enabled then
			count2 += 1
			local v4 = count2
			task.delay(1, function()
				if v4 == count2 then
					for _, v5 in ipairs(emitters2) do
						v5.Enabled = true
					end
				end
			end)
		else
			count2 += 1

			for _, v4 in ipairs(emitters2) do
				v4.Enabled = false
			end
		end
	end

	for _, v4 in ipairs(emitters) do
		v4.Enabled = true
	end

	count2 += 1
	local v4 = count2
	task.delay(1, function()
		if v4 == count2 then
			for _, v5 in ipairs(emitters2) do
				v5.Enabled = true
			end
		end
	end)
	local flag = true

	local function stop(p2)
		if not flag then
			return
		end

		flag = false

		if v3 and type(v3.GeneratorEndDrill) == "function" then
			pcall(v3.GeneratorEndDrill, model2, model, playerFromCharacter, p2)
		end

		for _, v5 in ipairs(emitters) do
			v5.Enabled = false
		end

		count2 += 1

		for _, v5 in ipairs(emitters2) do
			v5.Enabled = false
		end

		local revealParts = model:FindFirstChild("RevealParts")

		if revealParts then
			for _, emitter in ipairs(revealParts:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end

	local eventConnection = forceStop.Event:Connect(function()
		stop("force_stop")
	end)
	local changedConnection = completed.Changed:Connect(function(p2)
		if p2 then
			stop("completed")
		end
	end)
	local ancestryChangedConnection = model2.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stop("character_removed")
		end
	end)
	local ancestryChangedConnection2 = model.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stop("generator_removed")
		end
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while flag do
			local v5 = os.clock() - lastTime

			if p and p <= v5 then
				stop("duration_elapsed")
				break
			end

			if completed.Value then
				stop("completed")
				break
			end

			local v6 = v2 * 0.1
			local v7 = math.min(currentAmount.Value + v6, requiredAmount.Value)
			currentAmount.Value = v7

			if requiredAmount.Value <= v7 then
				completed.Value = true
				stop("completed")
				break
			else
				task.wait(0.1)
			end
		end

		eventConnection:Disconnect()
		changedConnection:Disconnect()
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection2:Disconnect()
	end)
	return function()
		stop("caller_cancelled")
	end
end

function GeneratorFillScript.PlayRevealAnimation(model)
	if not (model and model:IsA("Model")) then
		return 0
	end

	local revealParts = model:FindFirstChild("RevealParts")

	if not revealParts then
		return 0
	end

	local v2 = {}

	if (model:GetAttribute("MinigameType") or "Original") == "MovementTreadmill" then
		v2["Sand_Castle_002_idle 4"] = true
	else
		v2["Sand_Castle_001_T B"] = true
	end

	for _, folder in ipairs(revealParts:GetChildren()) do
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			end
		end
	end

	local folders = {}
	local count2 = 0

	for _, folder in ipairs(revealParts:GetChildren()) do
		if not v2[folder.Name] then
			continue
		end

		table.insert(folders, folder)

		for _, animationController in ipairs(folder:GetDescendants()) do
			if not animationController:IsA("AnimationController") then
				continue
			end

			local reveal = animationController:FindFirstChild("Reveal")
			local idle = animationController:FindFirstChild("Idle")

			if not (reveal and reveal:IsA("Animation")) then
				continue
			end

			local v3 = animationController:FindFirstChildOfClass("Animator")

			if not v3 then
				v3 = Instance.new("Animator")
				v3.Parent = animationController
			end

			for _, v4 in ipairs(v3:GetPlayingAnimationTracks()) do
				v4:Stop(0)
			end

			local v4 = object[animationController]

			if not v4 then
				local v5 = reveal
				local success2, result2 = pcall(function()
					return v3:LoadAnimation(v5)
				end)

				if success2 and result2 then
					result2.Looped = false
					result2.Priority = Enum.AnimationPriority.Action
					object[animationController] = result2

					if idle and idle:IsA("Animation") then
						local v6 = object2[animationController]

						if not v6 then
							local v7 = idle
							local success3, result3 = pcall(function()
								return v3:LoadAnimation(v7)
							end)

							if success3 and result3 then
								result3.Looped = true
								result3.Priority = Enum.AnimationPriority.Idle
								object2[animationController] = result3
								v6 = result3
							end
						end

						if v6 then
							result2.Stopped:Connect(function()
								if not v6.IsPlaying then
									v6:Play()
								end
							end)
						end
					end

					v4 = result2
				end
			end

			if not v4 then
				continue
			end

			v4:Play()
			count2 += 1
		end
	end

	task.spawn(function()
		local RunService = game:GetService("RunService")
		RunService.Heartbeat:Wait()

		for _, folder in ipairs(folders) do
			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if descendant.Name ~= "RootPart" then
						descendant.Transparency = 0
					end
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
				end
			end
		end
	end)
	return count2
end

return GeneratorFillScript