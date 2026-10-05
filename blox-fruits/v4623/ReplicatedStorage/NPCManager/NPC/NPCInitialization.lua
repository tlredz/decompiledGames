-- failed to load script (decompiled with syntax error):
-- rMaJBiSiQsQuFFZddOXEfQEsO:320: Expected identifier when parsing expression, got `Start {

game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
RunService:IsServer()
local RunService2 = game:GetService("RunService")
local isClient = RunService2:IsClient()
require(game.ReplicatedStorage.NPCManager.Types)
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Modules.Util.Signal)
local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
require(game.ReplicatedStorage.NPCManager.State)
local InteractionController = require(game.ReplicatedStorage.NPCManager.NPC.NPCInitialization.InteractionController)

local function getNPCInitializationDebugPath(instance)
	if not instance then
		return "<nil>"
	end

	local success, result = pcall(function()
		return instance:GetFullName()
	end)

	if success then
		return result
	end

	return instance.Name
end

local function logNPCInitialization(_: string) end

local function warnNPCInitialization(_: string) end

-- equivalent calls inferred from this helper; original call sites unknown
local function warnNPCInitializationStalled(_, _: string, _: string)
	task.delay(5, function() end)
end

local function InitializeHumanoid(object, model, head)
	local currentHumanoid = model:FindFirstChildWhichIsA("Humanoid")

	if not (currentHumanoid or model:FindFirstChildWhichIsA("AnimationController")) then
		if model:GetAttribute("CompositeTextureId") then
			currentHumanoid = Instance.new("AnimationController")
			currentHumanoid.Parent = model
		else
			currentHumanoid = Instance.new("Humanoid")

			if not model:FindFirstChild("Torso") then
				currentHumanoid.RigType = Enum.HumanoidRigType.R15
			end

			currentHumanoid.Name = "Humanoid"
			currentHumanoid.Parent = head
			currentHumanoid.NameDisplayDistance = 40
			currentHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
			currentHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			currentHumanoid.DisplayName = ""
			currentHumanoid.BreakJointsOnDeath = false
			currentHumanoid.AutoRotate = false
			currentHumanoid.RequiresNeck = false
			currentHumanoid.EvaluateStateMachine = false
		end
	end

	if currentHumanoid then
		currentHumanoid.Parent = head
		object._modelState._currentHumanoid = currentHumanoid
	end

	return currentHumanoid
end

local function initGuide(object, humanoidRootPart)
	local GuideModule = require(game.ReplicatedStorage:WaitForChild("GuideModule"))
	local Quests = require(game.ReplicatedStorage:WaitForChild("Quests"))

	if humanoidRootPart and (object._npcInfo.QuestInfo and object._npcInfo.QuestInfo.Type) == 1 then
		local dialogueCallback = object._npcInfo.DialogueCallback()

		if not dialogueCallback then
			warn((`can't get dialogue for {object._modelState._instance.Name}`))
			return
		end

		local internalQuestName = dialogueCallback.InternalQuestName

		if internalQuestName then
			local quest = Quests[internalQuestName]
			local levelReqs = {}

			for _, v in pairs(quest) do
				if v.LevelReq then
					table.insert(levelReqs, v.LevelReq)
				end
			end

			GuideModule:AppendNPCData(humanoidRootPart, {
				Levels = levelReqs,
				NPCName = object._modelState._instance.Name,
				InternalQuestName = internalQuestName,
				Position = humanoidRootPart.Position
			})
		end
	end
end

local function initSpecialNPCs(object)
	local model = object:getModel()

	if model.Name == "Mysterious Entity" then
		model.ChildAdded:Connect(function(humanoid)
			if humanoid:IsA("Humanoid") then
				humanoid.DisplayName = game.Players.LocalPlayer.Name
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				model:SetAttribute("DisplayName", humanoid.DisplayName)
			end
		end)
		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			pcall(function()
				humanoid.DisplayName = game.Players.LocalPlayer.Name
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				model:SetAttribute("DisplayName", humanoid.DisplayName)
			end)
		end

		task.spawn(function()
			if not game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.CharacterAdded:Wait()
			end

			repeat
				task.wait(1)
			until game.Players.LocalPlayer:HasAppearanceLoaded() and model.Parent == workspace.NPCs

			local humanoidModelFromDescription = game.Players:CreateHumanoidModelFromDescription(
				game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.CharacterAppearanceId),
				Enum.HumanoidRigType.R15
			)
			pcall(function()
				if humanoidModelFromDescription.Head:FindFirstChildWhichIsA("Decal") then
					local decal = model.Head:FindFirstChildWhichIsA("Decal")
					decal.Texture = humanoidModelFromDescription.Head:FindFirstChildWhichIsA("Decal").Texture
				else
					model.Head:FindFirstChildWhichIsA("Decal"):Destroy()
				end
			end)

			for _, child in pairs(humanoidModelFromDescription:GetChildren()) do
				if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors") or child:IsA("Accessory") then
					local clone = child:Clone()

					if clone:IsA("Accessory") then
						local v = clone
						pcall(function()
							if v:FindFirstChild("Animator", true) then
								return
							end

							local accessoryWeld = v:FindFirstChild("AccessoryWeld", true)

							if accessoryWeld.Part1 then
								accessoryWeld.Part1 = model:FindFirstChild(accessoryWeld.Part1.Name)
							end

							v.Parent = model
						end)
					else
						clone.Parent = model
					end
				elseif child:IsA("BasePart") and model:FindFirstChild(child.Name) then
					local child2 = model:FindFirstChild(child.Name)
					child2.Color = child.Color
					child2.Transparency = child.Transparency

					if child:IsA("MeshPart") then
						child2.Transparency = 1
						local clone = child:Clone()
						clone.Parent = model
						local weld = Instance.new("Weld", child2)
						weld.Part0 = child2
						weld.Part1 = clone
					end
				end

				if not child:IsA("BasePart") then
					continue
				end

				local v = child
				model.ChildAdded:Connect(function(child2)
					if child2.Name == v.Name then
						child2.Color = v.Color
						child2.Transparency = v.Transparency
					end
				end)
			end
		end)
	end
end

local function WaitForIdleLoad(object, track)
	while task.wait() do
		track:Play()
		local speed = track.Speed
		track:AdjustSpeed(999)
		track.DidLoop:Wait()
		track:AdjustSpeed(speed)

		if not object._modelState._instance.Parent then
			continue
		end

		local v = true
		pcall(function()
			local v2 = false

			for _, descendant in pairs(object._modelState._instance:GetDescendants()) do
				if not (descendant:IsA("Bone") or descendant:IsA("Motor6D")) then
					continue
				end

				v2 = true

				if descendant.Transform:FuzzyEq(CFrame.new()) then
					continue
				end

				v = false
				break
			end

			if not v2 then
				v = false
			end
		end)

		if not v then
			break
		end
	end
end

local function loadIdleAnimation(object, _)
	local model = object:getModel()
	model.Parent = workspace
	local nPCConfig = model:FindFirstChild("NPCConfig")
	local _ = nPCConfig and nPCConfig:GetAttributes()
	local animator = assert(object:getAnimator())
	local idle = model:FindFirstChild("idle")

	if idle and idle.ClassName == "Animation" then
		local track = animator:LoadAnimation(idle)
		WaitForIdleLoad(object, track)
		track:Play()
	elseif object._npcInfo.IgnoreIdleAnimation then
		if animator then
			animator:SetAttribute("IdleLoaded", true)
		end
	else
		local idleList = Config.IdleList
		local animation = Instance.new("Animation")
		animation.Name = "idle"
		animation.AnimationId = "rbxassetid://" .. idleList[object._npcInfo.IdleAnimationId or Random.new(#model.Name + 1):NextInteger(
			1,
			#idleList - 1
		)]
		local track = animator:LoadAnimation(animation)
		WaitForIdleLoad(object, track)
		track:Play()
	end
end

local function loadGroundEffect(object)
	local model = object:getModel()
	assert(object._npcInfo.QuestInfo)
	local _ = object._modelState._rootPart
	model:FindFirstChild("Head")
	assert(object._modelState._currentHumanoid)
end

local function disableAnimations(instance)
	local animator = instance:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	for _, v in animator:GetPlayingAnimationTracks() do
		v:Stop(0)
	end

	animator:Destroy()
end

local function initializeNPC(object)
	assert(isClient)
	local model = object:getModel()
	local _name = object._npcInfo._name or model.Name
	local result

	if model then
		local success
		success, result = pcall(function()
			return model:GetFullName()
		end)

		if not success then
			result = model.Name
		end
	else
		result = "<nil>"
	end

	`Start {_name}; model={result} Optimized={tostring(model:GetAttribute("Optimized"))}`
	model.Parent = game.ReplicatedStorage.NPCs
	local result2

	if model then
		local success
		success, result2 = pcall(function()
			return model:GetFullName()
		end)

		if not success then
			result2 = model.Name
		end
	else
		result2 = "<nil>"
	end

	`Moved {_name} to ReplicatedStorage.NPCs while initializing; path={result2}`

	if not model:GetAttribute("Optimized") then
		local result3

		if model then
			local success
			success, result3 = pcall(function()
				return model:GetFullName()
			end)

			if not success then
				result3 = model.Name
			end
		else
			result3 = "<nil>"
		end

		`Waiting for Optimized on {_name}; path={result3}`
		warnNPCInitializationStalled() -- equivalent call inferred; original call site unknown
		model:GetAttributeChangedSignal("Optimized"):Wait();
		`Optimized received for {_name}`
	end

	local head = model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")

	if not head then
		local result3

		if model then
			local success
			success, result3 = pcall(function()
				return model:GetFullName()
			end)

			if not success then
				result3 = model.Name
			end
		else
			result3 = "<nil>"
		end

		`Waiting for Head/Torso/HumanoidRootPart on {_name}; path={result3}`
		warnNPCInitializationStalled() -- equivalent call inferred; original call site unknown
	end

	while not head do
		task.wait()
		head = model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
	end

	`Found head/root fallback {head.Name} for {_name}`
	local alignPosition = head and head:FindFirstChild("AlignPosition")

	if alignPosition then
		alignPosition:Destroy()
	end

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	else
		`No HumanoidRootPart/Torso found for {_name}; interaction and culling distance may not work`
	end

	object._modelState._rootPart = humanoidRootPart
	local initializeHumanoid = InitializeHumanoid(object, model, head)

	if initializeHumanoid then
		if model:GetAttribute(Config.ANIMATIONS_DISABLED_ATTRIBUTE) == true then
			disableAnimations(initializeHumanoid)
		end

		`Humanoid/AnimationController ready for {_name}: {initializeHumanoid.ClassName}`
	else
		`No Humanoid or AnimationController created for {_name}`
	end

	initGuide(object, humanoidRootPart)
	initSpecialNPCs(object)
	local animator = object:getAnimator()

	if animator and initializeHumanoid and model:FindFirstChild("Head") and model:FindFirstChild("LowerTorso") then
		task.spawn(function()
			local success, result3 = pcall(function()
				loadIdleAnimation(object, initializeHumanoid)
			end)

			if not success then
				task.spawn(error, (`Failed to load idle animation for NPC: {model.Name}, Error: {result3}`))
			end
		end)
	else
		`Skipping idle animation load for {_name}; Animator={tostring(animator ~= nil)} Humanoid={tostring(initializeHumanoid ~= nil)} Head={tostring(model:FindFirstChild("Head") ~= nil)} LowerTorso={tostring(model:FindFirstChild("LowerTorso") ~= nil)}`
	end

	object._interactionController = InteractionController.new(object)
	object._isInitialized = true
	model:SetAttribute("NPCReady", true)
	local result3

	if model then
		local success
		success, result3 = pcall(function()
			return model:GetFullName()
		end)

		if not success then
			result3 = model.Name
		end
	else
		result3 = "<nil>"
	end

	local parent = model.Parent
	local result4

	if parent then
		local success
		success, result4 = pcall(function()
			return parent:GetFullName()
		end)

		if not success then
			result4 = parent.Name
		end
	else
		result4 = "<nil>"
	end

	`Ready {_name}; model={result3} Parent={result4}`
end

return initializeNPC