local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local AchievementGiver = RunService:IsServer() and require(ServerStorage.SharedModules.AchievementGiver) or nil
local GlistenRageBar = {}
GlistenRageBar.__index = GlistenRageBar
local v = {
	Greeting = { "Please— Is anyone there...?", "Hello? Anyone out there...?", "Did I hear someone...?" },
	Toon = {
		"Thank goodness you're here...",
		"Seeing you really helps me stay calm... Thanks.",
		"It's you!— Stay nearby, please...?",
		"I was worried I'd be alone down here...",
		"It's you! Stay close please— I enjoy your company."
	},
	GettingAngry = { "Please, don't leave me alone...", "I don't want to be alone...", "I need someone..." },
	Angry = { "I-I can't take it anymore!", "That's it, I can't take it!", "It hurts...!" },
	Elevator = { "Wait! Don't leave me!", "Wait! No... NO!", "You're leaving me?!" }
}

function GlistenRageBar.new(character, options)
	local object = setmetatable({}, GlistenRageBar)
	object.character = character
	object.config = options or {}
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoidRootPart then
		warn("GlistenRageBar: No HumanoidRootPart found")
		return nil
	end

	object.hrp = humanoidRootPart
	object.humanoid = character:WaitForChild("Humanoid", 10)
	object.head = character:FindFirstChild("Head") or humanoidRootPart
	object.rageGUI = humanoidRootPart:FindFirstChild("RageGUI")

	if not object.rageGUI then
		warn("GlistenRageBar: No RageGUI found on HumanoidRootPart - make sure model has it")
		return nil
	end

	local maxFrame = object.rageGUI:FindFirstChild("MaxFrame")

	if maxFrame then
		object.progressBar = maxFrame:FindFirstChild("CurrentFrame")
	end

	if not object.progressBar then
		warn("GlistenRageBar: RageGUI structure invalid - needs MaxFrame.CurrentFrame")
		return nil
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	object.DialogueEvent = events and events:FindFirstChild("MonsterDialogueEvent")
	object.AnimateTower = events and events:FindFirstChild("AnimateTower")
	object.AnimateStop = events and events:FindFirstChild("AnimationStop")
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
	local v2 = not inGamePlayers and 0 or math.max(#inGamePlayers:GetChildren() - 1, 0)
	object.maxRage = math.clamp(75 - v2 * 5, 40, 75)
	object.currentRage = 0
	object.tickInterval = 0.25
	object.detectionRadius = options.DetectionRadius or 25
	object.isActivated = false
	object.transformed = false
	object.calmed = false
	object.currentFriends = {}
	object.friendTalkTick = {}
	object.gettingAngryTick = nil
	object.gettingAngry = false
	object.cooldown = 15
	object.foundPlayersFirstTime = {}
	object.proximityTimers = {}
	object.proximityRequirement = 30
	object.calmedGraceTicks = 8
	object.calmedGrace = 0
	object.panicApplied = false
	object.ignoredCharacters = {}
	object.ignoreObjects = {}
	character:SetAttribute("SuppressChasingUntilActivated", true)
	character:SetAttribute("GlistenActivated", false)
	character:SetAttribute("GlistenRageTier", "passive")
	TweenService:Create(object.progressBar, TweenInfo.new(0), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()
	object.progressBar.Size = UDim2.new(0, 0, 1, 0)
	object.rageGUI.Enabled = true
	object.currentRage = 0
	object.isActivated = false
	object.transformed = false
	object:setupConnections()
	object:buildIgnoreLists()
	object:startRageLoop()
	task.spawn(function()
		task.wait(math.random(400, 500) / 100)

		if object.character and object.character.Parent then
			object:showDialogue("Greeting", "all")
		end
	end)
	print("GlistenRageBar: Initialized with MaxRage:", object.maxRage, "(players:", v2, ")")
	return object
end

function GlistenRageBar:buildIgnoreLists()
	task.spawn(function()
		task.wait(1)
		local currentRoom = workspace:FindFirstChild("CurrentRoom")

		if not currentRoom then
			return
		end

		local model = currentRoom:FindFirstChildOfClass("Model")

		if not model then
			return
		end

		local monsters = model:FindFirstChild("Monsters")

		if monsters then
			for _, folder in pairs(monsters:GetChildren()) do
				if table.find(self.ignoredCharacters, folder) then
					continue
				end

				for _, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						table.insert(self.ignoreObjects, part)
					end
				end

				table.insert(self.ignoredCharacters, folder)
			end
		end

		local generators = model:FindFirstChild("Generators")

		if generators then
			for _, folder in pairs(generators:GetChildren()) do
				if table.find(self.ignoredCharacters, folder) then
					continue
				end

				for _, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						table.insert(self.ignoreObjects, part)
					end
				end

				table.insert(self.ignoredCharacters, folder)
			end
		end
	end)
end

function GlistenRageBar:setupConnections()
	local info = workspace:FindFirstChild("Info")

	if info then
		local panic = info:FindFirstChild("Panic")

		if panic then
			self.panicConnection = panic.Changed:Connect(function(p)
				if p == true and not self.panicApplied then
					self.panicApplied = true
					local total = 1.2
					local cardModifiers = info:FindFirstChild("CardModifiers")

					if cardModifiers and cardModifiers:FindFirstChild("MonsterPanicReduction") then
						total += cardModifiers.MonsterPanicReduction.Value
					end

					if self.humanoid then
						self.humanoid.WalkSpeed = self.humanoid.WalkSpeed * total
					end

					local chaser = self.character:FindFirstChild("Chaser")

					if chaser then
						local patrolSpeed = chaser:FindFirstChild("PatrolSpeed")
						local runSpeed = chaser:FindFirstChild("RunSpeed")

						if patrolSpeed then
							patrolSpeed.Value *= total
						end

						if runSpeed then
							runSpeed.Value *= total
						end
					end
				end
			end)
		end

		local generatorsCompleted = info:FindFirstChild("GeneratorsCompleted")
		local requiredGenerators = info:FindFirstChild("RequiredGenerators")

		if generatorsCompleted and requiredGenerators then
			self.generatorsConnection = generatorsCompleted.Changed:Connect(function()
				if generatorsCompleted.Value / requiredGenerators.Value >= 1 and not self.transformed then
					self.transformed = true
					self:showDialogue("Elevator", "all")
					local firstChild = self.hrp:FindFirstChild("Break")

					if firstChild then
						firstChild:Play()
					end

					if self.AnimateTower then
						self.AnimateTower:FireAllClients(self.character, "LostInterest")
						self.character:SetAttribute("ChaseState", "lost")
					end

					self.rageGUI.Enabled = false
					task.wait(1.5)

					if self.character and self.character.Parent then
						self:triggerActivation()
					end
				end
			end)
		end
	end

	self.ancestryConnection = self.character.AncestryChanged:Connect(function()
		if not self.character.Parent then
			self:cleanup()
			local GlistenMonster = require(ReplicatedStorage.MonsterData.GlistenMonster)

			if GlistenMonster.RageBarInstances then
				GlistenMonster.RageBarInstances[self.character] = nil
			end
		end
	end)
end

function GlistenRageBar:canSeeTarget(ancestor, p)
	if not (ancestor and ancestor.PrimaryPart) then
		return false
	end

	local position = self.hrp.Position
	local v2 = math.min(p, (ancestor.PrimaryPart.Position - position).Magnitude + 2)
	local v3 = (ancestor.PrimaryPart.Position - position).Unit * v2
	local raycastParams = RaycastParams.new()
	local filterDescendantsInstances = {}
	table.insert(filterDescendantsInstances, self.character)
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in pairs(inGamePlayers:GetChildren()) do
			if child ~= ancestor then
				table.insert(filterDescendantsInstances, child)
			end
		end
	end

	for _, ignoreObject in pairs(self.ignoreObjects) do
		table.insert(filterDescendantsInstances, ignoreObject)
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(position, v3, raycastParams)

	if not (raycastResult and raycastResult.Instance) then
		return false
	end

	if raycastResult.Instance:IsDescendantOf(ancestor) then
		return true
	end

	local partsInPart = workspace:GetPartsInPart(self.hrp)

	for _, v5 in ipairs(partsInPart) do
		if v5.Name == "HumanoidRootPart" and v5.Parent == ancestor then
			return true
		end
	end

	return false
end

function GlistenRageBar:findNearbyPlayers()
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if not inGamePlayers then
		return nil
	end

	local vector = Vector3.new(0, self.hrp.Size.Y / 2 + self.humanoid.HipHeight, 0)
	local count = 0
	local count2 = 0
	local result = {}

	for _, child in pairs(inGamePlayers:GetChildren()) do
		if not (child:FindFirstChild("HumanoidRootPart") and child:FindFirstChild("Humanoid")) then
			continue
		end

		local humanoid = child.Humanoid
		count += 1

		if humanoid.Health <= 0 or child:FindFirstChild("NoTarget") then
			continue
		end

		local magnitude = (self.hrp.Position - vector - child.HumanoidRootPart.Position).Magnitude

		if not (magnitude < self.detectionRadius) then
			continue
		end

		count2 += 1

		if self:canSeeTarget(child, self.detectionRadius) then
			result[#result + 1] = { child, magnitude }
		end
	end

	self._findDebugCounter = (self._findDebugCounter or 0) + 1

	if self._findDebugCounter >= 16 then
		self._findDebugCounter = 0
		print(
			string.format(
				"GlistenRageBar: findNearbyPlayers - checked %d players, %d in range (<%d), found: ",
				count,
				count2,
				self.detectionRadius
			),
			result
		)
	end

	return result
end

function GlistenRageBar:startRageLoop()
	if self.currentRage ~= 0 then
		warn("GlistenRageBar: currentRage was not 0 at loop start! Resetting from", self.currentRage)
		self.currentRage = 0
	end

	print(
		"GlistenRageBar: Starting rage loop - isActivated:",
		self.isActivated,
		"character.Parent:",
		self.character.Parent ~= nil
	)
	self.rageCoroutine = task.spawn(function()
		local count = 0

		while self.character.Parent and not self.isActivated do
			count += 1
			local nearbyPlayers = self:findNearbyPlayers()
			local v2 = {}
			local v3 = #nearbyPlayers > 0
			local v4 = not v3 and self.calmedGrace > 0

			if v3 then
				self.calmed = true
				self.calmedGrace = self.calmedGraceTicks
				self.currentFriends = nearbyPlayers

				for _, nearbyPlayer in pairs(nearbyPlayers) do
					local v5 = nearbyPlayer[1]
					v2[v5] = true
					self:handleToonDialogue(v5)
					self:checkResearch(v5)

					if not (AchievementGiver and v5.Parent) then
						continue
					end

					local v6 = (self.proximityTimers[v5] or 0) + self.tickInterval
					self.proximityTimers[v5] = v6

					if not (self.proximityRequirement <= v6) then
						continue
					end

					local playerFromCharacter = Players:GetPlayerFromCharacter(v5)

					if playerFromCharacter then
						AchievementGiver:CompleteAchievementOneOff(playerFromCharacter, "ID_41_Attached")
					end

					self.proximityTimers[v5] = nil
				end
			elseif v4 then
				self.calmed = true
				self.calmedGrace -= 1
				self.nearestPlayers = nil
			else
				self.calmed = false
				self.nearestPlayers = nil
			end

			for k, proximityTimer in pairs(self.proximityTimers) do
				if k.Parent then
					if not v2[k] then
						local v5 = proximityTimer - self.tickInterval

						if v5 <= 0 then
							self.proximityTimers[k] = nil
						else
							self.proximityTimers[k] = v5
						end
					end
				else
					self.proximityTimers[k] = nil
				end
			end

			local currentRage = self.currentRage

			if v3 then
				self.currentRage = math.clamp(self.currentRage - 1, 0, self.maxRage)
			elseif not v4 then
				self.currentRage = math.clamp(self.currentRage + 0.25, 0, self.maxRage)
			end

			if math.floor(self.currentRage) ~= math.floor(currentRage) then
				print(string.format(
					"GlistenRageBar: Rage %.1f -> %.1f (calmed=%s, friend=%s)",
					currentRage,
					self.currentRage,
					tostring(self.calmed),
					self.nearestPlayers and table.concat(self.nearestPlayers, ", ") or "none"
				))
			end

			self:updateRageBar()
			local v5 = self.currentRage / self.maxRage
			self.character:SetAttribute("GlistenRageTier", v5 >= 0.5 and "normal" or "passive")

			if v5 >= 1 and not self.transformed then
				self.transformed = true
				self:showDialogue("Angry", "all")
				local firstChild = self.hrp:FindFirstChild("Break")

				if firstChild then
					firstChild:Play()
				end

				if self.AnimateTower then
					self.AnimateTower:FireAllClients(self.character, "LostInterest")
					self.character:SetAttribute("ChaseState", "lost")
				end

				task.wait(1.5)

				if self.character and self.character.Parent then
					self:triggerActivation()
				end
			end

			if v5 >= 0.5 and not (self.gettingAngry or self.transformed) then
				self.gettingAngry = true

				if self.gettingAngryTick == nil or tick() - self.gettingAngryTick >= 6 then
					self:showDialogue("GettingAngry", "all")
					self.gettingAngryTick = tick()
				end
			elseif v5 < 0.5 and self.gettingAngry then
				self.gettingAngry = false
			end

			if self.transformed then
				self.rageGUI.Enabled = false
				print("GlistenRageBar: Loop exiting - transformed=true after", count, "iterations")
				break
			else
				task.wait(self.tickInterval)
			end
		end

		print(
			"GlistenRageBar: Rage loop ended - iterations:",
			count,
			"isActivated:",
			self.isActivated,
			"character.Parent:",
			self.character.Parent ~= nil
		)
	end)
end

function GlistenRageBar:handleToonDialogue(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter or self.transformed then
		return
	end

	if self.friendTalkTick[character] then
		if tick() - self.friendTalkTick[character] >= self.cooldown then
			self.friendTalkTick[character] = tick()
			self:showDialogueToPlayer("Toon", playerFromCharacter)
		end
	else
		self.friendTalkTick[character] = tick()
		self:showDialogueToPlayer("Toon", playerFromCharacter)
	end
end

function GlistenRageBar:updateRageBar()
	if not self.progressBar then
		return
	end

	local v2 = self.currentRage / self.maxRage
	local tweenInfo = TweenInfo.new(0.275, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	TweenService:Create(self.progressBar, tweenInfo, {
		Size = UDim2.new(math.clamp(v2, 0, 1), 0, 1, 0)
	}):Play()
end

function GlistenRageBar:triggerActivation()
	if self.isActivated then
		return
	end

	print("Twisted Glisten is activating!")
	self.isActivated = true
	self.character:SetAttribute("GlistenActivated", true)
	self.character:SetAttribute("SuppressChasingUntilActivated", false)
	self.character:SetAttribute("ForceAggressiveFace", true)

	if self.rageGUI then
		self.rageGUI.Enabled = false
	end

	local GlistenMonster = require(ReplicatedStorage.MonsterData.GlistenMonster)
	local chaser = self.character:FindFirstChild("Chaser")

	if chaser then
		local patrolSpeed = chaser:FindFirstChild("PatrolSpeed")
		local runSpeed = chaser:FindFirstChild("RunSpeed")
		local waitTime = chaser:FindFirstChild("WaitTime")

		if patrolSpeed then
			patrolSpeed.Value = GlistenMonster.ActivatedWalkSpeed or 15
		end

		if runSpeed then
			runSpeed.Value = GlistenMonster.ActivatedRunSpeed or 24
		end

		if waitTime then
			waitTime.Value = 0
		end
	end

	if self.humanoid then
		self.humanoid.WalkSpeed = GlistenMonster.ActivatedWalkSpeed or 15
	end

	local animations = self.character:FindFirstChild("Animations")

	if animations then
		local walk = animations:FindFirstChild("Walk")

		if walk then
			local activatedWalkAnimationId = GlistenMonster.ActivatedWalkAnimationId

			if activatedWalkAnimationId then
				print("GlistenRageBar: Swapping Walk animation from", walk.AnimationId, "to", activatedWalkAnimationId)
				walk.AnimationId = activatedWalkAnimationId
			else
				warn("GlistenRageBar: No ActivatedWalkAnimationId in config")
			end
		else
			warn("GlistenRageBar: Walk animation not found in Animations folder")
		end
	else
		warn("GlistenRageBar: Animations folder not found on character")
	end

	local info = workspace:FindFirstChild("Info")

	if info and info:FindFirstChild("Panic") and info.Panic.Value and not self.panicApplied then
		self.panicApplied = true
		local total = 1.2
		local cardModifiers = info:FindFirstChild("CardModifiers")

		if cardModifiers and cardModifiers:FindFirstChild("MonsterPanicReduction") then
			total += cardModifiers.MonsterPanicReduction.Value
		end

		self.humanoid.WalkSpeed = self.humanoid.WalkSpeed * total

		if chaser then
			local patrolSpeed = chaser:FindFirstChild("PatrolSpeed")
			local runSpeed = chaser:FindFirstChild("RunSpeed")

			if patrolSpeed then
				patrolSpeed.Value *= total
			end

			if runSpeed then
				runSpeed.Value *= total
			end
		end
	end
end

function GlistenRageBar:checkResearch(instance)
	if table.find(self.foundPlayersFirstTime, instance) then
		return
	end

	table.insert(self.foundPlayersFirstTime, instance)
	local info = workspace:FindFirstChild("Info")

	if not info then
		return
	end

	local playerStats = info:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	local child = playerStats:FindFirstChild(instance.Name)
	local survivalPoints = child and child:FindFirstChild("SurvivalPoints")

	if survivalPoints then
		survivalPoints.Value += 3
	end

	local config = instance:FindFirstChild("Config")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	if not shared.ResearchGranted then
		shared.ResearchGranted = {}
	end

	shared.ResearchGranted[playerFromCharacter.UserId .. "_" .. self.character.Name] = true
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if editData then
		pcall(function()
			editData:Invoke(playerFromCharacter, function(p2)
				if not p2 then
					return
				end

				local name = self.character.Name
				local value = config and config:FindFirstChild("ModuleName") and config.ModuleName.Value or ""
				local v3 = config ~= nil and TowerLUT:HasPassive(config.Parent, "Rodger") and 10 or 5
				local v4 = false

				for _, v6 in pairs(p2.Data.Research) do
					if v6[1] ~= name then
						continue
					end

					v4 = true
					v6[2] += v3

					if v6[2] >= 100 then
						v6[2] = 100
					end

					break
				end

				if not v4 then
					table.insert(p2.Data.Research, { name, v3 })
				end

				if p2.Data.Milestones.Monster then
					p2.Data.Milestones.Monster = p2.Data.Milestones.Monster + 1
				else
					p2.Data.Milestones.Monster = 1
				end

				local v6 = nil

				for _, v8 in pairs(p2.Data.Mastery) do
					if v8.Name ~= value then
						continue
					end

					v6 = v8
					break
				end

				if v6 then
					for _, v8 in pairs(v6.RequirementList) do
						if v8.Name == "EncounterMonster" then
							v8.Current += 1

							if v8.Current >= v8.Amount then
								v8.Current = v8.Amount
							end
						end

						if v8.Name ~= "CollectResearch" then
							continue
						end

						v8.Current += v3

						if v8.Current >= v8.Amount then
							v8.Current = v8.Amount
						end
					end
				end
			end)
		end)
	end

	pcall(function()
		local sharedData = ReplicatedStorage:FindFirstChild("SharedData")

		if sharedData and info then
			local HolidayCurrencyModule = require(sharedData:WaitForChild("HolidayCurrencyModule"))
			local matchLockedMultiplier = info:GetAttribute("MatchLockedMultiplier")
			HolidayCurrencyModule.Grant(
				playerFromCharacter,
				"Monster",
				HolidayCurrencyModule.MONSTER_REWARD,
				matchLockedMultiplier
			)
		end
	end)

	if playerStats then
		local child2 = playerStats:FindFirstChild(playerFromCharacter.Name)
		local monsters = child2 and child2:FindFirstChild("Monsters")

		if monsters then
			monsters.Value += 1
		end
	end
end

function GlistenRageBar:showDialogue(p2, p3)
	if not (self.DialogueEvent and v[p2]) then
		return
	end

	local v2 = v[p2][math.random(1, #v[p2])]

	if p3 == "all" then
		self.DialogueEvent:FireAllClients("GlistenMonster", v2, 5)
	end
end

function GlistenRageBar:showDialogueToPlayer(p2, player)
	if not (self.DialogueEvent and v[p2]) then
		return
	end

	local v2 = v[p2][math.random(1, #v[p2])]
	self.DialogueEvent:FireClient(player, "GlistenMonster", v2, 5)
end

function GlistenRageBar:setCurrentFriends(nearestPlayers)
	self.nearestPlayers = nearestPlayers
end

function GlistenRageBar:cleanup()
	if self.rageCoroutine then
		task.cancel(self.rageCoroutine)
		self.rageCoroutine = nil
	end

	if self.panicConnection then
		self.panicConnection:Disconnect()
		self.panicConnection = nil
	end

	if self.generatorsConnection then
		self.generatorsConnection:Disconnect()
		self.generatorsConnection = nil
	end

	if self.ancestryConnection then
		self.ancestryConnection:Disconnect()
		self.ancestryConnection = nil
	end
end

return GlistenRageBar