local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MachineEffects = require(script.Parent.MachineEffects)
local BrushaSignature = require(ReplicatedStorage.Parts.RenderModules.BrushaSignature)
local BrushaAbility = {
	BOOST_ATTRIBUTE = "BrushaBoosted",
	BOOST_SKIN_ATTRIBUTE = "BrushaBoostedSkin",
	MACHINE_RANGE = 10,
	MAX_DURATION = 7,
	LEASH_SLACK = 1.5,
	RESULT_TIMEOUT = 60,
	GetMinigame = function()
		local minigames = script:FindFirstChild("Minigames")
		local minigame1 = minigames and minigames:FindFirstChild("Minigame1")

		if not minigame1 then
			warn("[BrushaAbility] Minigame1 module is missing")
			return nil
		end

		local success, result = pcall(require, minigame1)

		if success then
			return result
		end

		warn("[BrushaAbility] Minigame1 failed to load:", result)
		return nil
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function machinePosition(instance)
	if instance.PrimaryPart then
		return instance.PrimaryPart.Position
	end

	return instance:GetPivot().Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWorkable(model)
	if model:IsA("Model") and model:IsDescendantOf(workspace) then
		return model:FindFirstChild("Stats") ~= nil
	end

	return false
end

local function isFinished(instance)
	local stats = instance:FindFirstChild("Stats")

	if not stats then
		return true
	end

	local completed = stats:FindFirstChild("Completed")

	if completed and completed.Value == true then
		return true
	end

	local currentAmount = stats:FindFirstChild("CurrentAmount")
	local requiredAmount = stats:FindFirstChild("RequiredAmount")
	return currentAmount ~= nil and requiredAmount ~= nil and currentAmount.Value >= requiredAmount.Value
end

local function buildSightParams(instance)
	local children = { instance }
	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	local currentRoomModel = currentRoom and currentRoom:FindFirstChildOfClass("Model")
	local monsters = currentRoomModel and currentRoomModel:FindFirstChild("Monsters")

	if monsters then
		for _, child in ipairs(monsters:GetChildren()) do
			table.insert(children, child)
		end
	end

	local elevators = workspace:FindFirstChild("Elevators")

	if elevators then
		for _, child in ipairs(elevators:GetChildren()) do
			table.insert(children, child)
		end
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if child ~= instance then
				table.insert(children, child)
			end
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = children
	return raycastParams
end

local function hasLineOfSight(instance, ancestor, sightParams)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local position = humanoidRootPart.Position
	local workspace2 = workspace
	local v = machinePosition(ancestor) -- equivalent call inferred; original call site unknown
	local raycastResult = workspace2:Raycast(position, v - position, sightParams)
	return raycastResult ~= nil and raycastResult.Instance ~= nil and raycastResult.Instance:IsDescendantOf(ancestor)
end

function BrushaAbility.PaintIdentity(instance)
	local currentSkin = instance and instance:GetAttribute("CurrentSkin")

	if type(currentSkin) == "string" and currentSkin ~= "" then
		return currentSkin
	end

	return "Default"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSamePaint(instance, p)
	if p and instance:GetAttribute(BrushaAbility.BOOST_ATTRIBUTE) then
		return instance:GetAttribute(BrushaAbility.BOOST_SKIN_ATTRIBUTE) == p
	end

	return false
end

function BrushaAbility.FindNearestMachine(instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local v = BrushaAbility.PaintIdentity(instance)
	local sightParams = buildSightParams(instance)
	local position = humanoidRootPart.Position
	local MACHINE_RANGE = BrushaAbility.MACHINE_RANGE
	local MACHINE_RANGE2 = BrushaAbility.MACHINE_RANGE
	local v2 = nil
	local v3 = nil

	for _, v4 in ipairs(CollectionService:GetTagged("Generator")) do
		-- equivalent call inferred; original call site unknown
		if not isWorkable(v4) then
			continue
		end

		local v5 = machinePosition(v4) -- equivalent call inferred; original call site unknown
		local magnitude = (v5 - position).Magnitude

		if not (magnitude <= BrushaAbility.MACHINE_RANGE) then
			continue
		end

		local v6 = nil
		local v7

		if isFinished(v4) then
			v7 = "That Machine is already finished!"
		else
			local samePaint = isSamePaint(v4, v) -- equivalent call inferred; original call site unknown
			v7 = samePaint and "That Machine already has this art!" or not hasLineOfSight(instance, v4, sightParams) and "You need line of sight with that Machine!" or v6
		end

		if v7 then
			if magnitude <= MACHINE_RANGE2 then
				v3 = v7
				MACHINE_RANGE2 = magnitude
			end
		elseif magnitude <= MACHINE_RANGE then
			v2 = v4
			MACHINE_RANGE = magnitude
		end
	end

	return v2, MACHINE_RANGE, v3
end

local object = setmetatable({}, {
	__mode = "k"
})

local function abort(state, abortReason)
	if state.aborted or state.committed then
		return false
	end

	state.aborted = true
	state.abortReason = abortReason
	return true
end

local object2 = setmetatable({}, {
	__mode = "k"
})

local function paintTrack(character, childName)
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local animations = character and character:FindFirstChild("Animations")
	local animation = animations and animations:FindFirstChild(childName)

	if not (animator and animation and animation:IsA("Animation")) then
		return nil
	end

	local v = object2[character]

	if not v then
		v = {}
		object2[character] = v
	end

	if v[childName] then
		return v[childName]
	end

	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if success and result then
		result.Priority = Enum.AnimationPriority.Action4
		v[childName] = result
		return result
	else
		warn("[BrushaAbility] could not load animation " .. childName .. ":", result)
		return nil
	end
end

local function notebookDecal(character)
	local quickLinks = character and character:FindFirstChild("QuickLinks")

	if not quickLinks then
		return nil
	end

	local notebookDecal2 = quickLinks:FindFirstChild("NotebookDecal") or quickLinks:FindFirstChild("NotebookArtImage")
	local value = notebookDecal2 and notebookDecal2.Value

	if value and value:IsA("Decal") then
		return value
	end

	return nil
end

local function startNotebookFade(state)
	local notebookDecal2 = notebookDecal(state.character)

	if not notebookDecal2 then
		return
	end

	state.notebookDecal = notebookDecal2
	local parent = notebookDecal2.Parent

	if parent and parent:IsA("BasePart") then
		state.notebookMesh = parent
		parent.Transparency = 0
	end

	local paintingTexture = state.character:GetAttribute("PaintingTexture")

	if type(paintingTexture) == "string" and paintingTexture ~= "" then
		notebookDecal2.Texture = paintingTexture
	end

	notebookDecal2.Transparency = 1
	local tween = TweenService:Create(
		notebookDecal2,
		TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Transparency = 0
		}
	)
	state.notebookTween = tween
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopNotebookFade(state)
	if state.notebookTween then
		state.notebookTween:Cancel()
		state.notebookTween = nil
	end

	if state.notebookMesh then
		if state.notebookMesh.Parent then
			state.notebookMesh.Transparency = 1
		end

		state.notebookMesh = nil
	end

	if state.notebookDecal then
		if state.notebookDecal.Parent then
			state.notebookDecal.Transparency = 1
		end

		state.notebookDecal = nil
	end
end

local function startPaintAnimation(state)
	startNotebookFade(state)
	local paintStartTrack = paintTrack(state.character, "PaintStart")
	local paintLoopTrack = paintTrack(state.character, "Paint")
	state.paintStartTrack = paintStartTrack
	state.paintLoopTrack = paintLoopTrack
	task.spawn(function()
		if paintStartTrack then
			paintStartTrack.Looped = false
			paintStartTrack:Play(0)
			paintStartTrack.Stopped:Wait()
		end

		if state.finished or state.aborted or not paintLoopTrack then
			return
		end

		paintLoopTrack.Looped = true
		paintLoopTrack:Play(0)
	end)
end

local function stopPaintAnimation(state)
	stopNotebookFade(state) -- equivalent call inferred; original call site unknown

	if state.paintStartTrack then
		state.paintStartTrack:Stop()
		state.paintStartTrack = nil
	end

	if state.paintLoopTrack then
		state.paintLoopTrack:Stop()
		state.paintLoopTrack = nil
	end

	local v = paintTrack(state.character, "PaintEnd")

	if v then
		v.Looped = false
		v:Play(0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startWatchdog(data, minigame)
	task.spawn(function()
		local character = data.character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local health = humanoid and humanoid.Health

		if not health then
			health = 0
		end

		while not (data.aborted or data.finished) do
			local humanoid2 = character and character:FindFirstChild("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local decoding = character and character:FindFirstChild("Decoding")
			local spotted = data.player and data.player:GetAttribute("Spotted")
			local v = nil
			local abortReason

			if humanoid2 and not (humanoid2.Health <= 0) and character.Parent == workspace.InGamePlayers then
				if humanoid2.Health < health then
					abortReason = "You got hit!"
				elseif spotted == nil or spotted == data.spottedAt then
					if decoding and decoding.Value ~= nil then
						abortReason = "You started extracting"
					elseif data.machine:IsDescendantOf(workspace) then
						if isFinished(data.machine) then
							abortReason = "That Machine was finished!"
						elseif humanoidRootPart then
							local v3 = machinePosition(data.machine) -- equivalent call inferred; original call site unknown
							abortReason = (v3 - humanoidRootPart.Position).Magnitude > BrushaAbility.MACHINE_RANGE * BrushaAbility.LEASH_SLACK and "Walked away from the Machine" or v
						else
							abortReason = "Walked away from the Machine"
						end
					else
						abortReason = "Machine is gone"
					end
				else
					abortReason = "A Twisted spotted you!"
				end
			else
				abortReason = "Brusha went down"
			end

			if abortReason then
				local v3 = data
				local v4

				if v3.aborted or v3.committed then
					v4 = false
				else
					v3.aborted = true
					v3.abortReason = abortReason
					v4 = true
				end

				if v4 and minigame.interrupt then
					pcall(minigame.interrupt, data, abortReason)
				end

				break
			else
				health = humanoid2.Health
				task.wait(0.1)
			end
		end
	end)
end

local v = nil

local function provisionMinigameGui(player)
	if not RunService:IsServer() then
		return
	end

	if not v then
		local success, result = pcall(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			return require(ServerScriptService.Modules.GuiProvisioner)
		end)

		if success then
			v = result
		else
			warn("[BrushaAbility] GuiProvisioner unavailable:", result)
			return
		end
	end

	v.give(player, "BrushaAbilityUI")
end

local v2 = {}
local count = 0

if RunService:IsServer() then
	local Network = require(ReplicatedStorage.SharedUtils.Network)
	Network:AddAction("BrushaMinigameResult", function(p, p2, p3)
		local v3 = v2[p2]

		if not (v3 and v3.player == p) then
			return
		end

		v3.success = p3 == true

		if v3.success and v3.session then
			v3.session.committed = true
		end

		v3.resolved = true
	end)
end

function BrushaAbility:PromptClient()
	local player = self.player

	if not player then
		return false
	end

	local Network = require(ReplicatedStorage.SharedUtils.Network)
	count += 1
	local clientSessionId = count
	local v4 = {
		player = player,
		resolved = false,
		success = false,
		session = self
	}
	v2[clientSessionId] = v4
	self.clientSessionId = clientSessionId
	provisionMinigameGui(player)
	Network:Post(player, "BrushaMinigameStart", clientSessionId, self.maxDuration)
	local v5 = os.clock() + BrushaAbility.RESULT_TIMEOUT

	while not v4.resolved do
		if self.aborted then
			Network:Post(player, "BrushaMinigameCancel", clientSessionId, self.abortReason)
			v2[clientSessionId] = nil
			return false
		else
			if not player.Parent then
				v2[clientSessionId] = nil
				return false
			end

			if v5 <= os.clock() then
				Network:Post(player, "BrushaMinigameCancel", clientSessionId, "Timed out")
				v2[clientSessionId] = nil
				return false
			else
				task.wait(0.1)
			end
		end
	end

	v2[clientSessionId] = nil
	return v4.success
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tellPlayer(player, p, color)
	if not player then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local displayMessage = events and events:FindFirstChild("DisplayMessage")

	if displayMessage then
		displayMessage:FireClient(player, p, color)
	end
end

local function fireTrinketMachineBuff(instance, p)
	local trinkets = instance:FindFirstChild("Trinkets")
	local trinketData = ReplicatedStorage:FindFirstChild("TrinketData")

	if not (trinkets and trinketData) then
		return
	end

	for _, childName in ipairs({ "Trinket1", "Trinket2" }) do
		local child = trinkets:FindFirstChild(childName)
		local child2 = child and trinketData:FindFirstChild(child.Value)

		if not child2 then
			continue
		end

		local success, result = pcall(require, child2)

		if not (success and type(result) == "table" and result.MachineBuffEvent and result.TriggerMachineBuffEvent) then
			continue
		end

		local success2, result2 = pcall(result.TriggerMachineBuffEvent, instance, p)

		if not success2 then
			warn("[BrushaAbility] " .. child.Value .. " machine-buff hook errored:", result2)
		end
	end
end

local object3 = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectSignature(p)
	for _, connection in ipairs(p.connections) do
		connection:Disconnect()
	end

	table.clear(p.connections)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropSignature(instance)
	local v3 = object3[instance]

	if not v3 then
		return
	end

	object3[instance] = nil
	disconnectSignature(v3) -- equivalent call inferred; original call site unknown
	v3.signature:destroy()
end

local function raiseSignature(instance)
	if not RunService:IsServer() then
		return
	end

	dropSignature(instance) -- equivalent call inferred; original call site unknown
	local v3 = machinePosition(instance) -- equivalent call inferred; original call site unknown
	local v4 = v3 + createVector(0, 12.5, 0)
	local success, result = pcall(BrushaSignature.new, v4, {
		parent = instance
	})

	if not success then
		warn("[BrushaAbility] signature billboard failed to build:", result)
		return
	end

	local v5 = {
		signature = result,
		connections = {}
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function takeDown()
		if v5.tornDown then
			return
		end

		v5.tornDown = true

		if object3[instance] == v5 then
			object3[instance] = nil
		end

		disconnectSignature(v5) -- equivalent call inferred; original call site unknown
		result:playExit(true)
	end

	table.insert(v5.connections, instance:GetAttributeChangedSignal(BrushaAbility.BOOST_ATTRIBUTE):Connect(function()
		if instance:GetAttribute(BrushaAbility.BOOST_ATTRIBUTE) then
			return
		end

		takeDown() -- equivalent call inferred; original call site unknown
	end))
	local stats = instance:FindFirstChild("Stats")

	for _, childName in ipairs({ "Completed", "CurrentAmount" }) do
		local child = stats and stats:FindFirstChild(childName)

		if child then
			table.insert(v5.connections, child.Changed:Connect(function()
				if isFinished(instance) then
					takeDown() -- equivalent call inferred; original call site unknown
				end
			end))
		end
	end

	object3[instance] = v5
end

function BrushaAbility.BoostMachine(instance, p)
	if not (instance and instance:IsDescendantOf(workspace)) then
		return false
	end

	local skin = BrushaAbility.PaintIdentity(p)

	if not MachineEffects.ApplyArt(instance, "BrushaBoost", {
		skin = skin
	}) then
		return false
	end

	instance:SetAttribute(BrushaAbility.BOOST_SKIN_ATTRIBUTE, skin)
	raiseSignature(instance)
	return true
end

function BrushaAbility.PreloadGraffiti(parent)
	if not RunService:IsServer() then
		return
	end

	local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local part = MachineEffects.GetBoostArtTemplate(parent:GetAttribute("CurrentSkin"))

	if not (part and part:IsA("MeshPart")) then
		return
	end

	local clone = part:Clone()
	clone.Name = "PRELOAD_BrushaGraffiti"
	clone.Size = createVector(0.2, 0.2, 0.2)
	clone.CFrame = humanoidRootPart.CFrame
	clone.Massless = true
	clone.Anchored = false
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Transparency = 0
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = humanoidRootPart
	motor6D.Part1 = clone
	motor6D.Parent = clone
	motor6D.C0 = CFrame.new(0, 0, -0.3)
	clone.Parent = parent
	Debris:AddItem(clone, 10)
end

function BrushaAbility.Run(instance, character, machine)
	local minigame = BrushaAbility.GetMinigame()

	if not minigame then
		return false, "The minigame is unavailable"
	end

	local v3 = {
		player = instance,
		character = character,
		machine = machine,
		maxDuration = BrushaAbility.MAX_DURATION,
		startedAt = os.clock(),
		spottedAt = instance and instance:GetAttribute("Spotted"),
		aborted = false,
		finished = false,
		abortReason = nil,
		state = nil
	}

	if minigame.setup then
		local success, result = pcall(minigame.setup, v3)

		if not success then
			warn("[BrushaAbility] minigame setup errored:", result)
			return false, "Minigame failed to start"
		end

		if result == false then
			if minigame.cleanup then
				pcall(minigame.cleanup, v3)
			end

			return false, "Minigame failed to start"
		end
	end

	v3.minigame = minigame
	object[character] = v3
	startPaintAnimation(v3)
	startWatchdog(v3, minigame) -- equivalent call inferred; original call site unknown
	local success, result = pcall(minigame.run, v3)
	v3.finished = true
	object[character] = nil
	stopPaintAnimation(v3)

	if minigame.cleanup then
		pcall(minigame.cleanup, v3)
	end

	if not success then
		warn("[BrushaAbility] minigame errored:", result)
		return false, "Minigame failed"
	end

	if result ~= true or v3.aborted then
		return false, v3.abortReason or "Minigame failed"
	end

	if isFinished(machine) then
		return false, "That Machine was finished!"
	end

	if not BrushaAbility.BoostMachine(machine, character) then
		return false, "Machine is gone"
	end

	fireTrinketMachineBuff(character, machine)
	local success2, result2 = pcall(function()
		local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
		ActionEvent:Record(instance, "MachineBuffed", machine)
	end)

	if not success2 then
		warn("[BrushaAbility] MachineBuffed record failed:", result2)
	end

	return true, "Machine boosted"
end

function BrushaAbility:Cancel(value)
	local v3 = self and object[self]

	if not v3 or v3.finished then
		return false
	end

	local abortReason = value or "Interrupted"
	local v5

	if v3.aborted or v3.committed then
		v5 = false
	else
		v3.aborted = true
		v3.abortReason = abortReason
		v5 = true
	end

	if not v5 then
		return false
	end

	local minigame = v3.minigame

	if minigame and minigame.interrupt then
		pcall(minigame.interrupt, v3, v3.abortReason)
	end

	print("[BrushaAbility] cancelled live run for", self.Name, "-", v3.abortReason)
	return true
end

function BrushaAbility.Activate(p, p2, p3, callback, callback2)
	task.spawn(function()
		local v3, v4 = BrushaAbility.Run(p, p2, p3)

		if v3 then
			if callback2 then
				local success, result = pcall(callback2)

				if not success then
					warn("[BrushaAbility] cooldown confirm failed:", result)
				end
			end

			tellPlayer(
				p,
				"Machine boosted — 25% faster extraction, 15% higher Skill Check chance!",
				Color3.fromRGB(190, 130, 255)
			) -- equivalent call inferred; original call site unknown
		else
			if callback then
				local success, result = pcall(callback)

				if not success then
					warn("[BrushaAbility] cooldown refund failed:", result)
				end
			end

			tellPlayer(p, v4 or "The Machine wasn't boosted.", Color3.fromRGB(255, 170, 60)) -- equivalent call inferred; original call site unknown
		end
	end)
end

return BrushaAbility