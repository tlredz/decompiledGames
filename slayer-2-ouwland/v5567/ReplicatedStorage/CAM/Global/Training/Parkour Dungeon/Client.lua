local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lever = require(script.Parent.lever)
local dropper = require(script.Parent.dropper)
local checkpoint = require(script.Parent.checkpoint)
local WipeTransition = require(ReplicatedStorage.CAM.Client.Components.Misc.Transitions.WipeTransition)
local ParkourTrainingUI = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Training.ParkourTrainingUI)
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local LoopsHandler = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.LoopsHandler)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local parkourTraining = workspace:WaitForChild("Map"):WaitForChild("DetachedMaps"):WaitForChild("ParkourTraining")
local v = {
	MapRoot = parkourTraining,
	CameraKey = "ParkourTraining",
	Icons = {
		Lever = "rbxassetid://85853569463281",
		Checkpoint = "rbxassetid://135018602259567"
	},
	Teleport = {
		LerpTime = 1,
		BufferTime = 0.25
	},
	TransitionWait = 0.35,
	FinishSettle = 1,
	InitialTpLocation = CFrame.new(-68, 890.25, 4076.099),
	SpawnLocations = {
		CFrame.new(-80.4131851, 890.25, 3942.9076),
		CFrame.new(-102.877495, 885.23407, 3386.349),
		(CFrame.new(406.698975, 905.248795, 3273.9809))
	},
	Levers = {
		{
			Lever = "Switch_1",
			Gate = "Gate1"
		},
		{
			Lever = "Switch_2",
			Gate = "Gate2"
		},
		{
			Lever = { "Switch_3", "Switch_4", "Switch_5" },
			Gate = "Gate3"
		},
		{
			Lever = { "Switch_6", "Switch_7" },
			Gate = "Gate4"
		}
	},
	MarkerPositions = {
		{
			Lever = createVector(-120.476, 898.435, 3853.299)
		},
		{
			Lever = createVector(-212.057, 934.025, 3575.058),
			Checkpoint = createVector(-104.662, 892.359, 3388.326)
		},
		{
			Lever = {
				createVector(-123.536, 952.635, 3278.08),
				createVector(-34.632, 952.011, 3296.739),
				createVector(-235.124, 971.707, 3426.915)
			},
			Checkpoint = createVector(409.666, 910.798, 3275.404)
		},
		{
			Lever = { createVector(491.013, 951.202, 3239.977), createVector(207.213, 1026.862, 2954.956) }
		}
	},
	DroppersFolderName = "Dropdown"
}

local function resolveLevers(p: number?)
	local v2 = p ~= nil and v.Levers[p] or nil

	if v2 == nil then
		return nil
	end

	local switchs = parkourTraining:FindFirstChild("Switchs")

	if switchs == nil then
		return nil
	end

	local lever2

	if typeof(v2.Lever) == "table" then
		lever2 = v2.Lever
	else
		lever2 = { v2.Lever }
	end

	local children = {}

	for k, childName in lever2 do
		local child = switchs:FindFirstChild(childName)

		if child == nil then
			return nil
		else
			children[k] = child
		end
	end

	local child

	if v2.Gate ~= nil then
		local gates = parkourTraining:FindFirstChild("Gates")
		child = gates and gates:FindFirstChild(v2.Gate)

		if child == nil then
			return nil
		end
	end

	if typeof(v2.Lever) ~= "table" then
		children = children[1]
	end

	return {
		Lever = children,
		Gate = child
	}
end

local v2 = {
	id = 0,
	cleaner = nil,
	currentThread = nil,
	currentLevers = {},
	lastLevers = {},
	droppers = {},
	currentSetupLevel = nil,
	currentCheckpoint = nil,
	activeMarkers = {},
	preTrainingCFrame = nil,
	debounce = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function asArray(lever2)
	if typeof(lever2) == "Instance" then
		return { lever2 }
	end

	return lever2
end

local function forEachSwitch(p, callback)
	for k, v3 in asArray(p.Lever) do
		callback(v3, k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAll(list, flag: boolean?)
	for _, v3 in list do
		v3:Destroy(flag)
	end

	table.clear(list)
end

local function computeMarkers(level: number, checkpoint2: number)
	local result = {}

	if typeof(level) ~= "number" then
		return result
	end

	local v3 = math.floor(level)
	local levers = resolveLevers(v3)
	local markerPosition = v.MarkerPositions[v3]

	if not (levers and markerPosition) then
		return result
	end

	local array = asArray(levers.Lever) -- equivalent call inferred; original call site unknown
	local lever3

	if typeof(markerPosition.Lever) == "table" then
		lever3 = markerPosition.Lever
	else
		lever3 = { markerPosition.Lever }
	end

	for k, v5 in array do
		local A_ = v5:FindFirstChild("A_")

		if not A_ or A_:GetAttribute("On") then
			continue
		end

		result[`parkour_lever_{v3}_{k}`] = {
			markerType = MarkerHandler.markerType.Regular,
			style = "Simple",
			img = v.Icons.Lever,
			position = lever3[k],
			tag = "ParkourMarkers",
			minDistance = 20,
			margin = 10,
			displayDistance = true
		}
		break
	end

	local v5 = v3 - 1
	local markerPosition2 = v.MarkerPositions[v5]

	if level % 1 == 0 and markerPosition2 and markerPosition2.Checkpoint and (checkpoint2 or 0) < v5 then
		result[`parkour_checkpoint_{v5}`] = {
			markerType = MarkerHandler.markerType.Regular,
			style = "Simple",
			img = v.Icons.Checkpoint,
			position = markerPosition2.Checkpoint,
			tag = "ParkourMarkers",
			minDistance = 15,
			margin = 10,
			displayDistance = true
		}
	end

	return result
end

local function syncMarkers(items)
	for k in v2.activeMarkers do
		if items[k] then
			continue
		end

		MarkerHandler.removeMarker(k)
		v2.activeMarkers[k] = nil
	end

	for k, item in items do
		if v2.activeMarkers[k] then
			continue
		end

		MarkerHandler.addMarker(k, item)
		v2.activeMarkers[k] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAllMarkers()
	for k in v2.activeMarkers do
		MarkerHandler.removeMarker(k)
	end

	table.clear(v2.activeMarkers)
end

local function teleportBack(ancestor, checkpoint2: number)
	Camera_Traffic_Handler[v.CameraKey] = true
	task.wait()
	local pivot = ancestor:GetPivot()
	local spawnLocation = v.SpawnLocations[checkpoint2]
	local cFrame = workspace.CurrentCamera.CFrame
	game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire("DeathEffect", pivot)
	local v3 = pivot:Inverse() * cFrame
	ancestor:PivotTo(spawnLocation)
	local v4 = spawnLocation * v3
	local lastTime = os.clock()
	local lerpTime = v.Teleport.LerpTime
	local bufferTime = v.Teleport.BufferTime
	local v5 = bufferTime / lerpTime
	Utility.AddValue(getvaluesfolder, "skill_stand_still", lerpTime + 0.15, "BoolValue")
	Utility.AddValue(getvaluesfolder, "pause_gameplay", lerpTime + 0.15, "BoolValue")
	Utility.AddValue(getvaluesfolder, "Invisible", lerpTime + 0.15, "BoolValue")
	LoopsHandler.Add("ParkourHandlerTeleportLoop", function()
		if Camera_Traffic_Handler.Equipped_Hirearchy ~= v.CameraKey then
			return true
		end

		local v6 = os.clock() - lastTime

		if lerpTime < v6 then
			return true
		end

		if bufferTime < v6 then
			local v7 = v6 / lerpTime - v5
			local v8 = v7 * v7 * v7 * v7 * (v7 * (v7 * (v7 * -20 + 70) - 84) + 35)
			workspace.CurrentCamera.CFrame = cFrame:Lerp(v4, v8)
		else
			workspace.CurrentCamera.CFrame = cFrame
		end

		return nil
	end)
	task.wait(lerpTime)
	game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire("Appear_Effect", ancestor:GetPivot())
	Camera_Traffic_Handler[v.CameraKey] = false
end

local function resetGate(gate)
	if gate:GetAttribute("IsCF") then
		for _, child in gate:GetChildren() do
			local startCF = child:GetAttribute("StartCF")

			if startCF then
				child.CFrame = startCF
			end
		end
	else
		local gateStart = gate:GetAttribute("GateStart")
		local top = gate:FindFirstChild("Top")

		if gateStart and top then
			top.CFrame = gateStart
		end
	end
end

local function resetWorld()
	for k in v.Levers do
		local levers = resolveLevers(k)

		if levers == nil then
			continue
		end

		for _, v3 in asArray(levers.Lever) do
			local A_ = v3:FindFirstChild("A_")

			if not A_ then
				continue
			end

			A_:SetAttribute("On", false)
			local startPivot = A_:GetAttribute("StartPivot")

			if startPivot then
				A_:PivotTo(startPivot)
			end
		end

		if levers.Gate then
			resetGate(levers.Gate)
		end
	end
end

local function setupLevelObserver(instance)
	local function onLevelChanged()
		syncMarkers(computeMarkers(instance:GetAttribute("Level"), instance:GetAttribute("Checkpoint")))
		local level = instance:GetAttribute("Level")

		if not level or level % 1 ~= 0 then
			return
		end

		local v3 = level - 2

		if instance:GetAttribute("Checkpoint") < v3 then
			instance:SetAttribute("Checkpoint", v3)
		end

		if level == v2.currentSetupLevel then
			return
		end

		local levers = resolveLevers(level)

		if levers == nil and v.Levers[level] ~= nil then
			v2.currentSetupLevel = nil
			return
		end

		v2.currentSetupLevel = level
		destroyAll(v2.lastLevers, true) -- equivalent call inferred; original call site unknown
		local v4 = v2
		v2.lastLevers = v2.currentLevers
		v4.currentLevers = {}

		if levers == nil then
			return
		end

		local array = asArray(levers.Lever) -- equivalent call inferred; original call site unknown
		local v6 = 1 / #array

		for k, v7 in array do
			local v8

			if k == 1 then
				v8 = levers.Gate
			end

			table.insert(v2.currentLevers, lever(v7, v8, v2.cleaner, instance, level, v6))
		end
	end

	onLevelChanged()
	v2.cleaner:Connect(instance:GetAttributeChangedSignal("Level"), onLevelChanged)
	local switchs = parkourTraining:FindFirstChild("Switchs")

	if switchs then
		v2.cleaner:Connect(switchs.ChildAdded, onLevelChanged)
	end

	local gates = parkourTraining:FindFirstChild("Gates")

	if gates then
		v2.cleaner:Connect(gates.ChildAdded, onLevelChanged)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCheckpointObserver(instance)
	local function onCheckpointChanged()
		syncMarkers(computeMarkers(instance:GetAttribute("Level"), instance:GetAttribute("Checkpoint")))
		local checkpoint2 = instance:GetAttribute("Checkpoint")

		if not checkpoint2 then
			return
		end

		if v2.currentCheckpoint ~= nil then
			v2.currentCheckpoint:Destroy()
			v2.currentCheckpoint = nil
		end

		v2.currentCheckpoint = checkpoint(
			v.MapRoot.Checkpoints:FindFirstChild("Checkpoint" .. checkpoint2),
			instance,
			v2.cleaner
		)
	end

	onCheckpointChanged()
	v2.cleaner:Connect(instance:GetAttributeChangedSignal("Checkpoint"), onCheckpointChanged)
end

local function setupKillBricks(ancestor, instance, p, p2, Leave)
	local killBricks = v.MapRoot.KillBricks

	local function handleBrick(p3)
		p3.Transparency = 1
		v2.cleaner:Connect(p3.Touched, function(instance2)
			if instance2 == nil or not instance2:IsDescendantOf(ancestor) or v2.debounce then
				return
			end

			v2.debounce = true
			p[p2.value]:Set(false)
			p2.value -= 1
			teleportBack(ancestor, instance:GetAttribute("Checkpoint"))

			if p2.value == 0 then
				Leave()
			else
				v2.debounce = false
			end
		end)
	end

	for _, child in killBricks:GetChildren() do
		child.Transparency = 1
		v2.cleaner:Connect(child.Touched, function(instance2)
			if instance2 == nil or not instance2:IsDescendantOf(ancestor) or v2.debounce then
				return
			end

			v2.debounce = true
			p[p2.value]:Set(false)
			p2.value -= 1
			teleportBack(ancestor, instance:GetAttribute("Checkpoint"))

			if p2.value == 0 then
				Leave()
			else
				v2.debounce = false
			end
		end)
	end

	v2.cleaner:Add(killBricks.ChildAdded:Connect(handleBrick))
end

local function setupDroppers(instance)
	local child = parkourTraining:FindFirstChild(v.DroppersFolderName)

	if child == nil then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleDropper(model)
		if not model:IsA("Model") then
			return
		end

		local v3 = dropper(model, v2.cleaner, instance)

		if v3 then
			table.insert(v2.droppers, v3)
		end
	end

	for _, child2 in child:GetChildren() do
		handleDropper(child2) -- equivalent call inferred; original call site unknown
	end

	v2.cleaner:Add(child.ChildAdded:Connect(handleDropper))
end

local function setupFinal(ancestor, Leave)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function bind(part)
		if not part:IsA("BasePart") then
			return
		end

		v2.cleaner:Connect(part.Touched, function(instance)
			if instance == nil or not instance:IsDescendantOf(ancestor) or v2.debounce then
				return
			end

			v2.debounce = true
			task.delay(v.FinishSettle, Leave)
		end)
	end

	local final = v.MapRoot:FindFirstChild("Final")

	if final and final:IsA("BasePart") then
		v2.cleaner:Connect(final.Touched, function(instance)
			if instance == nil or not instance:IsDescendantOf(ancestor) or v2.debounce then
				return
			end

			v2.debounce = true
			task.delay(v.FinishSettle, Leave)
		end)
	end

	v2.cleaner:Connect(v.MapRoot.ChildAdded, function(part)
		if part.Name == "Final" then
			bind(part) -- equivalent call inferred; original call site unknown
		end
	end)
end

local ParkourDungeon = {}

function ParkourDungeon.Do(p, instance, instance2)
	local id = math.random()
	v2.id = id

	if instance then
		v2.preTrainingCFrame = instance:GetPivot()
	end

	local v4 = {
		Switch = false
	}
	WipeTransition(v4)
	instance2:SetAttribute("Level", 1)
	instance2:SetAttribute("Checkpoint", 1)
	v2.cleaner = cleanit.new()
	setupLevelObserver(instance2)
	setupCheckpointObserver(instance2) -- equivalent call inferred; original call site unknown
	task.wait(v.TransitionWait)

	if v2.id ~= id then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Leave()
		if v2.id ~= id then
			return
		end

		SignalEvent.ToServer("training_signaler", "Stop")
	end

	local v5 = v2
	local currentThread, v7, v8 = ParkourTrainingUI(p.PlayerGui.ComponentsHolder, Leave)
	v5.currentThread = currentThread
	local v9 = {
		value = v8
	}

	if Utility.StreamingEnabledTeleport(v.InitialTpLocation) then
		if v2.id ~= id then
			return
		end

		v4.Switch = true
		task.wait(0.25)

		if v2.id ~= id then
			return
		end

		setupKillBricks(instance, instance2, v7, v9, Leave)
		setupDroppers(instance)
		setupFinal(instance, Leave)
	else
		Leave() -- equivalent call inferred; original call site unknown
	end
end

function ParkourDungeon.Stop(_, p, _)
	v2.id = 0
	v2.debounce = false
	local v3 = {
		Switch = false
	}
	WipeTransition(v3)

	if v2.currentThread ~= nil then
		v2.currentThread()
		v2.currentThread = nil
	end

	task.wait(v.TransitionWait)
	destroyAll(v2.currentLevers, nil) -- equivalent call inferred; original call site unknown
	destroyAll(v2.lastLevers, nil) -- equivalent call inferred; original call site unknown
	destroyAll(v2.droppers, nil) -- equivalent call inferred; original call site unknown
	v2.currentSetupLevel = nil
	resetWorld()
	clearAllMarkers() -- equivalent call inferred; original call site unknown

	if v2.currentCheckpoint ~= nil then
		v2.currentCheckpoint:Destroy()
		v2.currentCheckpoint = nil
	end

	if v2.cleaner ~= nil then
		v2.cleaner:Destroy()
		v2.cleaner = nil
	end

	Camera_Traffic_Handler[v.CameraKey] = false

	if v2.preTrainingCFrame and p then
		Utility.StreamingEnabledTeleport(v2.preTrainingCFrame)
	end

	v2.preTrainingCFrame = nil
	v3.Switch = true
end

return ParkourDungeon