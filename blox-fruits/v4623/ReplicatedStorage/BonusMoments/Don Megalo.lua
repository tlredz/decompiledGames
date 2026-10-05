local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = {
	MAP_FOLDER = "Prison",
	LOCATIONS = "BonusMoment_Locations",
	KEY = "Key",
	GATE = "MegaloGate",
	CAPE = "SharkCape",
	CAPE_ROOT = "RootPart",
	CAMERA = "BouncerCamera"
}
local v2 = {
	NONE = 0,
	KEY = 1,
	GATE = 2,
	FIGHT = 3,
	CLEARED = 4,
	DONE = 5
}
local _ = {
	KEY_RANGE = 12,
	GATE_RANGE = 16,
	CAPE_RANGE = 12,
	HOLD = 0.2,
	CAPE_HOLD = 6,
	CAPE_TRIGGER = 4
}
local v3 = {
	RISE_SCALE = 1,
	TIME = 5,
	CAM_SIDE = 34,
	CAM_UP = -1,
	CAM_LOOK_UP = 6,
	CAM_FREQ = 1.2,
	JINGLE_DELAY = 1.8,
	SETTLE = 1.1,
	SOUND_FADE = 0.8,
	LOCK_GRACE = 3,
	KEEP_INTERVAL = 0.5,
	KEEP_SLACK = 0.05
}
local _ = {
	RADIUS = 40,
	INTERVAL = 0.35,
	BEAT = 4.8,
	LAST_BEAT = 5.2
}
local v4 = {
	"So, this is the infamous Don Megalo's \"cell\"...? It looks more like a penthouse suite!",
	"The Warden wasn't keeping Megalo locked up at all, he was just keeping him comfortable! But why would the Warden do that?",
	"That's a sweet-looking coat, that must belong to him. If Megalo isn't here, surely he won't mind if I just..."
}
local v5 = {
	BACK = 17,
	UP = 6.5,
	SIDE = 4,
	LOOK_UP = 4.2,
	PUSH_BACK = 12,
	PUSH_UP = 5.5,
	PUSH_SIDE = 1.5,
	DAMPING = 1,
	FREQ = 2.2,
	PUSH_FREQ = 1.1,
	RETURN = 0.45,
	RELEASE_GRACE = 0.35,
	WALK_FREQ = 1.1,
	SCROLL_TIME = 5,
	SCROLL_DISTANCE = 12,
	SCROLL_FREQ = 0.7,
	FRONT_BACK = 20,
	FRONT_UP = 7,
	FRONT_SIDE = 3,
	FRONT_LOOK_UP = 4,
	BEAT_1 = 3.2,
	BEAT_2 = 7.5
}
local v6 = nil
local FIGHT = 0
local v7 = {
	key = nil,
	gate = nil,
	cape = nil,
	camera = nil
}
local v8 = nil
local cFrame = nil
local to = 0
local v9 = nil
local renderSteppedConnection = nil
local v10 = {}
local flag = false
local heartbeatConnection = nil
local KEEP_INTERVAL = 0
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = false
local v15 = false
local v16 = false
local parent2 = nil
local transparency = 0
local flag2 = false
local v18 = nil
local v19 = false
local v20 = false
local heartbeatConnection2 = nil
local fn
local fn2
local v21 = nil
local v22 = {
	controller = nil,
	cancelled = false,
	follow = nil,
	mode = "Front",
	baseCF = nil,
	scrollStart = 0,
	model = nil
}

local function getLocationsFolder()
	if v8 and v8.Parent then
		return v8
	end

	local map = workspace:FindFirstChild("Map")
	local prison = map and map:FindFirstChild("Prison")
	local bonusMoment_Locations

	if prison then
		bonusMoment_Locations = prison:FindFirstChild("BonusMoment_Locations", true)
	end

	if not bonusMoment_Locations and map then
		bonusMoment_Locations = map:FindFirstChild("BonusMoment_Locations", true)
	end

	v8 = bonusMoment_Locations
	return bonusMoment_Locations
end

local function markersValid()
	local key = v7.key
	local gate = v7.gate
	local cape = v7.cape
	return key ~= nil and gate ~= nil and cape ~= nil and key:IsDescendantOf(workspace) and gate:IsDescendantOf(workspace) and (v15 or cape:IsDescendantOf(workspace))
end

local function resolveGate()
	local gate = v7.gate

	if gate and gate:IsDescendantOf(workspace) then
		return gate
	end

	local locationsFolder = getLocationsFolder()

	if not locationsFolder then
		return nil
	end

	local megaloGate = locationsFolder:FindFirstChild("MegaloGate")

	if not (megaloGate and megaloGate:IsA("BasePart")) then
		return nil
	end

	v7.gate = megaloGate

	if not cFrame then
		cFrame = megaloGate.CFrame
	end

	return megaloGate
end

local function resolveMarkers()
	local key = v7.key
	local gate = v7.gate
	local cape = v7.cape
	local v23

	if key == nil or gate == nil or cape == nil then
		v23 = false
	else
		v23 = key:IsDescendantOf(workspace) and gate:IsDescendantOf(workspace) and (v15 or cape:IsDescendantOf(workspace))
	end

	if v23 then
		return true
	end

	local locationsFolder = getLocationsFolder()

	if not locationsFolder then
		return false
	end

	local function grab(childName: string)
		local part = locationsFolder:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			return part
		end

		return nil
	end

	local v24 = v7
	local key2 = locationsFolder:FindFirstChild("Key")

	if not (key2 and key2:IsA("BasePart")) then
		key2 = nil
	end

	v24.key = key2
	local v25 = v7
	local bouncerCamera = locationsFolder:FindFirstChild("BouncerCamera")

	if not (bouncerCamera and bouncerCamera:IsA("BasePart")) then
		bouncerCamera = nil
	end

	v25.camera = bouncerCamera
	resolveGate()
	local sharkCape = locationsFolder:FindFirstChild("SharkCape")
	local v26 = v7

	if not (sharkCape and sharkCape:IsA("Model")) then
		sharkCape = nil
	end

	v26.cape = sharkCape
	local key3 = v7.key

	if key3 and not v14 then
		transparency = key3.Transparency
	end

	local key4 = v7.key
	local gate2 = v7.gate
	local cape2 = v7.cape
	return key4 ~= nil and gate2 ~= nil and cape2 ~= nil and key4:IsDescendantOf(workspace) and gate2:IsDescendantOf(workspace) and (v15 or cape2:IsDescendantOf(workspace))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyGateOffset(p: number)
	local gate = v7.gate
	local v23 = cFrame

	if gate and v23 then
		gate.CFrame = v23 + Vector3.new(0, p, 0)
	end
end

local function gateRise()
	local gate = v7.gate

	if gate then
		return gate.Size.Y * 1
	end

	return 0
end

local function fadeGateSounds()
	if #v10 == 0 then
		return
	end

	local v23 = v10
	v10 = {}

	for _, v24 in v23 do
		local v25 = v24
		pcall(function()
			Sound:FadeOut(v25, 0.8)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGateStepper()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v9 = nil
	fadeGateSounds()
end

local function stepGate()
	local v23 = v9

	if v23 then
		local v24 = os.clock() - v23.start

		if v23.duration - v24 <= 0.8 then
			fadeGateSounds()
		end

		local v25 = v24 / v23.duration

		if v25 >= 1 then
			to = v23.to
			v9 = nil
			applyGateOffset(to) -- equivalent call inferred; original call site unknown
			stopGateStepper() -- equivalent call inferred; original call site unknown
		else
			local v26 = 1 - (1 - math.clamp(v25, 0, 1)) ^ 3
			to = v23.from + (v23.to - v23.from) * v26
			local v27 = to
			local gate = v7.gate
			local v28 = cFrame

			if gate then
				if not v28 then
					return
				end

				gate.CFrame = v28 + Vector3.new(0, v27, 0)
			end
		end
	else
		stopGateStepper() -- equivalent call inferred; original call site unknown
	end
end

local function openGate(flag3: boolean)
	local gate = v7.gate

	if not (gate and cFrame) then
		return
	end

	local gate2 = v7.gate
	local to2 = not gate2 and 0 or gate2.Size.Y * v3.RISE_SCALE

	if flag3 then
		stopGateStepper() -- equivalent call inferred; original call site unknown
		to = to2
		local v24 = to
		local gate3 = v7.gate
		local v25 = cFrame

		if gate3 then
			if not v25 then
				return
			end

			gate3.CFrame = v25 + Vector3.new(0, v24, 0)
		end
	else
		if math.abs(to - to2) < 0.001 then
			return
		end

		v9 = {
			from = to,
			to = to2,
			start = os.clock(),
			duration = 5
		}

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(stepGate)
		end

		fadeGateSounds()
		pcall(function()
			table.insert(v10, Sound:Play("Other.StoneDoor", gate.Position, nil, 0.6, 0.95))
			table.insert(v10, Sound:Play("Other.ChainDragging", gate.Position, nil, 0.9, 0.8))
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeGate()
	if flag then
		return
	end

	stopGateStepper() -- equivalent call inferred; original call site unknown
	to = 0
	local gate = v7.gate
	local cFrame2 = cFrame

	if gate and cFrame2 then
		gate.CFrame = cFrame2
	end
end

local function keepGateOpen(p: number)
	if not flag then
		return
	end

	KEEP_INTERVAL += p

	if KEEP_INTERVAL < 0.5 then
		return
	end

	KEEP_INTERVAL = 0

	if v19 or v9 then
		return
	end

	local map = workspace:FindFirstChild("Map")

	if not (map and map:FindFirstChild("Prison")) then
		return
	end

	local gate = resolveGate()
	local v23 = cFrame

	if not (gate and v23) then
		return
	end

	local gate2 = v7.gate
	local cFrame2 = v23 + Vector3.new(0, not gate2 and 0 or gate2.Size.Y * v3.RISE_SCALE, 0)

	if (gate.CFrame.Position - cFrame2.Position).Magnitude <= 0.05 then
		return
	end

	local gate3 = v7.gate
	to = not gate3 and 0 or gate3.Size.Y * v3.RISE_SCALE
	gate.CFrame = cFrame2
end

local function latchGate(flag3: boolean)
	flag = true

	if not heartbeatConnection then
		KEEP_INTERVAL = 0.5
		heartbeatConnection = RunService.Heartbeat:Connect(keepGateOpen)
	end

	if v19 or v9 then
		return
	end

	resolveGate()
	openGate(flag3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlatchGate()
	flag = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	closeGate() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setKeyHidden(flag3: boolean)
	local key = v7.key

	if not key then
		v14 = flag3
		return
	end

	if flag3 and not v14 then
		transparency = key.Transparency
	end

	v14 = flag3
	key.Transparency = flag3 and 1 or transparency
	key.CanCollide = not flag3
end

local function capeAnchorPart(instance)
	local rootPart = instance:FindFirstChild("RootPart")

	if rootPart and rootPart:IsA("BasePart") then
		return rootPart
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCapeHidden(flag3: boolean)
	local cape = v7.cape
	v15 = flag3

	if not cape then
		return
	end

	if flag3 then
		local parent = cape.Parent

		if parent then
			parent2 = parent
			cape.Parent = nil
		end
	elseif parent2 and not cape.Parent then
		cape.Parent = parent2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPrompts()
	if v11 then
		v11:Destroy()
		v11 = nil
	end

	if v12 then
		v12:Destroy()
		v12 = nil
	end

	if v13 then
		v13:Destroy()
		v13 = nil
	end
end

local function makePrompt(parent, actionText: string, objectText: string, maxActivationDistance: number, holdDuration: number, onTriggered)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = actionText
	proximityPrompt.ObjectText = objectText
	proximityPrompt.MaxActivationDistance = maxActivationDistance
	proximityPrompt.HoldDuration = holdDuration
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = parent
	proximityPrompt.Triggered:Connect(onTriggered)
	return proximityPrompt
end

local function refreshPrompts()
	local v23 = v6
	local v24

	if v23 == nil then
		v24 = false
	else
		v24 = v23.Active and not (v23.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v24 and FIGHT == 0
	end

	if v12 then
		v12.Enabled = v24 and FIGHT == 1
	end

	if v13 then
		v13.Enabled = v24 and (FIGHT == 2 or FIGHT == 4)
	end
end

local function applyStage(p: number, flag3: boolean)
	FIGHT = p
	setKeyHidden(FIGHT >= 1) -- equivalent call inferred; original call site unknown

	if FIGHT >= 2 then
		flag = true

		if not heartbeatConnection then
			KEEP_INTERVAL = v3.KEEP_INTERVAL
			heartbeatConnection = RunService.Heartbeat:Connect(keepGateOpen)
		end

		if not (v19 or v9) then
			resolveGate()
			openGate(flag3)
		end
	else
		closeGate() -- equivalent call inferred; original call site unknown
	end

	if FIGHT == 2 then
		fn()
	else
		fn2()
	end

	if FIGHT >= 5 then
		v16 = true
	end

	setCapeHidden(FIGHT >= 5) -- equivalent call inferred; original call site unknown
	local v25 = v6
	local v26

	if v25 == nil then
		v26 = false
	else
		v26 = v25.Active and not (v25.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v26 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v26 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v26 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end
end

local function bouncerShot(instance, p: number, p2: number, p3: number, p4: number)
	if not (instance and instance.Parent) then
		return nil
	end

	local success, result = pcall(function()
		return instance:GetPivot()
	end)

	if success and result then
		local v23 = result.Position + result.LookVector * p + result.RightVector * p3 + Vector3.new(0, p2, 0)
		return CFrame.lookAt(v23, result.Position + Vector3.new(0, p4, 0))
	else
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWalkFollow()
	local follow = v22.follow
	v22.follow = nil

	if follow then
		follow:Disconnect()
	end
end

local function releaseCutsceneCamera()
	stopWalkFollow() -- equivalent call inferred; original call site unknown
	v22.cancelled = true
	v22.baseCF = nil
	v22.model = nil
	v22.mode = "Front"
	local controller = v22.controller
	v22.controller = nil

	if controller then
		controller:FadeOut(0.45)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function focusBouncerFront()
	v22.mode = "Front"
end

local function startWalkCamera(model)
	if v22.controller then
		return
	end

	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local controller = CameraController.new()
	v22.controller = controller
	v22.cancelled = false
	v22.model = model
	local camera = v7.camera
	local v24 = v22
	local baseCF2

	if camera then
		baseCF2 = camera.CFrame
	end

	v24.baseCF = baseCF2
	v22.mode = v22.baseCF and "Scroll" or "Front"
	v22.scrollStart = os.clock()
	stopWalkFollow() -- equivalent call inferred; original call site unknown
	v22.follow = RunService.RenderStepped:Connect(function()
		if v22.cancelled or v22.controller ~= controller then
			return
		end

		local v26 = nil
		local v27 = 1.1
		local baseCF = v22.baseCF

		if v22.mode == "Scroll" and baseCF then
			local v28 = math.clamp((os.clock() - v22.scrollStart) / 5, 0, 1)
			v26 = baseCF + baseCF.RightVector * (12 * v28)
			v27 = 0.7
		elseif model.Parent then
			v26 = bouncerShot(model, 20, 7, 3, 4)
		end

		if v26 then
			controller.Animations:AnimateTo(v26, 1, v27)
		end
	end)
end

local function buildButlerDialogue(p)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v23 = DialogueController.new()
	v23:setTitle("Megalo Guard")
	return v23:addPage("Main", function(object)
		stopWalkFollow() -- equivalent call inferred; original call site unknown
		local controller = v22.controller

		if not controller then
			controller = CameraController.new()
			v22.controller = controller
			v22.cancelled = false
		end

		v23:getMaid():GiveTask(releaseCutsceneCamera)
		local v24 = bouncerShot(p, 17, 6.5, 4, 4.2)

		if v24 then
			controller.Animations:AnimateTo(v24, 1, 2.2)
		end

		object:setTitle("Megalo Guard")
		object:noCancel()
		object:noSkip()
		object:addText("Hold it! You've got no business snooping around the Don's quarters.")
		object:jumpToOnAdvance("Warn")
		object:advanceAfterDelay(3.2)
	end):addPage("Warn", function(object)
		object:setTitle("Megalo Guard")
		object:noCancel()
		object:noSkip()
		local controller = v22.controller
		local v24 = bouncerShot(p, 12, 5.5, 1.5, 4.2)

		if controller and v24 and not v22.cancelled then
			controller.Animations:AnimateTo(v24, 1, 1.1)
		end

		object:addText("Surprised by the room? Megalo isn't exactly an ordinary prisoner. The Warden knows better than to put him behind common bars. As long as the Don keeps things quiet, everyone stays out of his way.")
		object:jumpToOnAdvance("Fight")
		object:advanceAfterDelay(7.5)
	end):addPage("Fight", function(object)
		object:setTitle("Megalo Guard")
		object:noCancel()
		object:addText("Anyways.. Since the Don isn't here to deal with you himself, I'll do him a favor by taking care of you myself!")
	end):build()
end

local function playButlerCutscene(p)
	local v23 = v6
	local flag3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reportFinished()
		if flag3 then
			return
		end

		flag3 = true

		if v23 then
			v23:FireServer("BouncerReady")
		end
	end

	if flag2 then
		stopWalkFollow() -- equivalent call inferred; original call site unknown
		v22.cancelled = true
		v22.baseCF = nil
		v22.model = nil
		focusBouncerFront() -- equivalent call inferred; original call site unknown
		local controller = v22.controller
		v22.controller = nil

		if controller then
			controller:FadeOut(v5.RETURN)
		end

		reportFinished() -- equivalent call inferred; original call site unknown
	else
		local DialogueController = require(game.ReplicatedStorage.DialogueController)

		if DialogueController.Active then
			stopWalkFollow() -- equivalent call inferred; original call site unknown
			v22.cancelled = true
			v22.baseCF = nil
			v22.model = nil
			focusBouncerFront() -- equivalent call inferred; original call site unknown
			local controller = v22.controller
			v22.controller = nil

			if controller then
				controller:FadeOut(v5.RETURN)
			end

			reportFinished() -- equivalent call inferred; original call site unknown
		else
			local butlerDialogue = buildButlerDialogue(p)
			flag2 = true
			local v24 = v6
			local v25

			if v24 == nil then
				v25 = false
			else
				v25 = v24.Active and not (v24.Completed or flag2)
			end

			if v11 then
				v11.Enabled = v25 and FIGHT == v2.NONE
			end

			if v12 then
				v12.Enabled = v25 and FIGHT == v2.KEY
			end

			if v13 then
				v13.Enabled = v25 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
			end

			butlerDialogue:getMaid():GiveTask(function()
				flag2 = false
				local v26 = v6
				local v27

				if v26 == nil then
					v27 = false
				else
					v27 = v26.Active and not (v26.Completed or flag2)
				end

				if v11 then
					v11.Enabled = v27 and FIGHT == v2.NONE
				end

				if v12 then
					v12.Enabled = v27 and FIGHT == v2.KEY
				end

				if v13 then
					v13.Enabled = v27 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
				end
			end)

			if DialogueController.start(butlerDialogue) == nil then
				flag2 = false
				local v26 = v6
				local v27

				if v26 == nil then
					v27 = false
				else
					v27 = v26.Active and not (v26.Completed or flag2)
				end

				if v11 then
					v11.Enabled = v27 and FIGHT == v2.NONE
				end

				if v12 then
					v12.Enabled = v27 and FIGHT == v2.KEY
				end

				if v13 then
					v13.Enabled = v27 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
				end

				stopWalkFollow() -- equivalent call inferred; original call site unknown
				v22.cancelled = true
				v22.baseCF = nil
				v22.model = nil
				focusBouncerFront() -- equivalent call inferred; original call site unknown
				local controller = v22.controller
				v22.controller = nil

				if controller then
					controller:FadeOut(v5.RETURN)
				end

				reportFinished() -- equivalent call inferred; original call site unknown
			else
				task.wait(0.8)
				reportFinished() -- equivalent call inferred; original call site unknown
			end
		end
	end
end

local function gateShotCFrame()
	local v23 = cFrame

	if not v23 then
		return nil
	end

	local currentCamera = workspace.CurrentCamera
	local v24

	if currentCamera then
		v24 = currentCamera.CFrame.Position
	else
		v24 = v23.Position + v23.RightVector * 20
	end

	local v25 = (v24 - v23.Position):Dot(v23.RightVector) >= 0 and 1 or -1
	local v26 = v23.Position + v23.RightVector * (34 * v25) + createVector(0, -1, 0)
	return CFrame.lookAt(v26, v23.Position + createVector(0, 6, 0))
end

local function playGateCinematic()
	local v23 = gateShotCFrame()

	if not v23 then
		openGate(false)
		return
	end

	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
	stopWalkFollow() -- equivalent call inferred; original call site unknown
	v22.cancelled = true
	v22.baseCF = nil
	v22.model = nil
	focusBouncerFront() -- equivalent call inferred; original call site unknown
	local controller = v22.controller
	v22.controller = nil

	if controller then
		controller:FadeOut(v5.RETURN)
	end

	local controller3 = CameraController.new()
	v22.controller = controller3
	v22.cancelled = false
	focusBouncerFront() -- equivalent call inferred; original call site unknown
	v22.baseCF = nil
	v22.model = nil
	local character = localPlayer.Character
	local v25

	if character then
		v25 = AttributeCounter.destroyable(character, "DisableMovement")
	else
		v25 = nil
	end

	local flag3 = false

	local function releaseMovement()
		if flag3 then
			return
		end

		flag3 = true

		if v25 then
			pcall(function()
				v25:Destroy()
			end)
		end
	end

	task.delay(10.9, releaseMovement)
	controller3.Animations:AnimateTo(v23, 1, 1.2)
	local gate = v7.gate

	if gate then
		pcall(function()
			Sound:Play("Other.LeverSFX", gate.Position, nil, 1, 1)
		end)
	end

	task.wait(1.8)

	if v22.controller == controller3 then
		openGate(false)
		task.wait(6.1)

		if v22.controller == controller3 then
			stopWalkFollow() -- equivalent call inferred; original call site unknown
			v22.cancelled = true
			v22.baseCF = nil
			v22.model = nil
			focusBouncerFront() -- equivalent call inferred; original call site unknown
			local controller2 = v22.controller
			v22.controller = nil

			if controller2 then
				controller2:FadeOut(v5.RETURN)
			end
		end
	end

	if not flag3 then
		flag3 = true

		if v25 then
			pcall(function()
				v25:Destroy()
			end)
		end
	end
end

local function buildTopFloorDialogue()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local v23 = DialogueController.new()
	v23:setTitle(localPlayer.DisplayName)

	for k, v24 in v4 do
		local v25 = k == #v4
		local v26

		if v25 then
			v26 = nil
		else
			v26 = `Line{k + 1}`
		end

		local v27 = v24
		v23 = v23:addPage(`Line{k}`, function(object)
			object:setTitle(localPlayer.DisplayName)
			object:noCancel()
			object:noSkip()
			object:addText(v27)

			if v26 then
				object:jumpToOnAdvance(v26)
			end

			object:advanceAfterDelay(v25 and 5.2 or 4.8)
		end)
	end

	return v23:build()
end

local function playDefeatDialogue()
	if flag2 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	local v23 = DialogueController.new():setTitle("Megalo Guard"):addPage("Main", function(object)
		object:setTitle("Megalo Guard")
		object:noCancel()
		object:addText("Finding the Don will be the last mistake you ever make...")
		object:jumpToOnAdvance("Escape")
	end):addPage("Escape", function(object)
		object:setTitle(localPlayer.DisplayName)
		object:noCancel()
		object:addText("That guy was tough... and that was only one of Don Megalo's guards!? I better get out of here before Don Megalo returns.")
	end):build()
	flag2 = true
	local v24 = v6
	local v25

	if v24 == nil then
		v25 = false
	else
		v25 = v24.Active and not (v24.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v25 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v25 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v25 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end

	v23:getMaid():GiveTask(function()
		flag2 = false
		local v26 = v6
		local v27

		if v26 == nil then
			v27 = false
		else
			v27 = v26.Active and not (v26.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v27 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v27 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v27 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end
	end)

	if DialogueController.start(v23) == nil then
		flag2 = false
		local v26 = v6
		local v27

		if v26 == nil then
			v27 = false
		else
			v27 = v26.Active and not (v26.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v27 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v27 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v27 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end
	end
end

local function playTopFloorDialogue()
	if flag2 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	local topFloorDialogue = buildTopFloorDialogue()
	flag2 = true
	local v23 = v6
	local v24

	if v23 == nil then
		v24 = false
	else
		v24 = v23.Active and not (v23.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v24 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v24 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v24 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end

	topFloorDialogue:getMaid():GiveTask(function()
		flag2 = false
		local v25 = v6
		local v26

		if v25 == nil then
			v26 = false
		else
			v26 = v25.Active and not (v25.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v26 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v26 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v26 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end
	end)

	if DialogueController.start(topFloorDialogue) == nil then
		flag2 = false
		local v25 = v6
		local v26

		if v25 == nil then
			v26 = false
		else
			v26 = v25.Active and not (v25.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v26 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v26 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v26 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end
	end
end

fn2 = function()
	local connection = heartbeatConnection2
	heartbeatConnection2 = nil

	if connection then
		connection:Disconnect()
	end
end

fn = function()
	if v20 or heartbeatConnection2 then
		return
	end

	local v23 = 0
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if v20 or FIGHT ~= 2 then
			return
		end

		local now = os.clock()

		if now < v23 then
			return
		end

		v23 = now + 0.35
		local cape = v7.cape
		local character = localPlayer.Character

		if not (cape and cape.Parent and character) then
			return
		end

		local success, result = pcall(function()
			return (character:GetPivot().Position - cape:GetPivot().Position).Magnitude
		end)

		if not success or result > 40 then
			return
		end

		v20 = true
		fn2()
		task.spawn(playTopFloorDialogue)
	end)
end

local function requestTakeKey()
	local v23 = v6

	if not v23 or FIGHT ~= 0 then
		return
	end

	if v23:InvokeServer("TakeKey") == true then
		applyStage(1, false)
	end
end

local function requestUnlock()
	local v23 = v6

	if not v23 or FIGHT ~= 1 then
		return
	end

	v19 = true

	if v23:InvokeServer("Unlock") == true then
		applyStage(2, false)
		playGateCinematic()
		v19 = false
	else
		v19 = false
		local v24 = v6
		local v25

		if v24 == nil then
			v25 = false
		else
			v25 = v24.Active and not (v24.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v25 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v25 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v25 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end
	end
end

local function requestTakeCape()
	local v23 = v6

	if not v23 or FIGHT ~= 2 then
		return
	end

	if v23:InvokeServer("TakeCape") == true then
		FIGHT = 3
	end

	local v24 = v6
	local v25

	if v24 == nil then
		v25 = false
	else
		v25 = v24.Active and not (v24.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v25 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v25 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v25 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end
end

local function requestClaimCape()
	local v23 = v6

	if not v23 or FIGHT ~= 4 then
		return
	end

	v23:InvokeServer("ClaimCape")
end

local function wire(maid)
	if not resolveMarkers() then
		return false
	end

	clearPrompts() -- equivalent call inferred; original call site unknown
	local key = v7.key
	local gate = v7.gate
	local cape = v7.cape

	if not (key and gate and cape) then
		return false
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Take"
	proximityPrompt.ObjectText = "Cell Block Key"
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.HoldDuration = 0.2
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = key
	proximityPrompt.Triggered:Connect(requestTakeKey)
	v11 = proximityPrompt
	local proximityPrompt2 = Instance.new("ProximityPrompt")
	proximityPrompt2:AddTag("ProximityPrompt")
	proximityPrompt2.ActionText = "Unlock"
	proximityPrompt2.ObjectText = "Office Gate"
	proximityPrompt2.MaxActivationDistance = 16
	proximityPrompt2.HoldDuration = 0.2
	proximityPrompt2.RequiresLineOfSight = false
	proximityPrompt2.Enabled = false
	proximityPrompt2.Parent = gate
	proximityPrompt2.Triggered:Connect(requestUnlock)
	v12 = proximityPrompt2
	local basePart = cape:FindFirstChild(v.CAPE_ROOT)

	if not (basePart and basePart:IsA("BasePart")) then
		basePart = cape:FindFirstChildWhichIsA("BasePart", true)
	end

	if not basePart then
		return false
	end

	local function onTriggered()
		if FIGHT == 4 then
			local v25 = v6

			if v25 then
				if FIGHT ~= v2.CLEARED then
					return
				end

				v25:InvokeServer("ClaimCape")
			end
		else
			local v25 = FIGHT == 2 and v6

			if v25 then
				if FIGHT ~= v2.GATE then
					return
				end

				if v25:InvokeServer("TakeCape") == true then
					FIGHT = v2.FIGHT
				end

				local v26 = v6
				local v27

				if v26 == nil then
					v27 = false
				else
					v27 = v26.Active and not (v26.Completed or flag2)
				end

				if v11 then
					v11.Enabled = v27 and FIGHT == v2.NONE
				end

				if v12 then
					v12.Enabled = v27 and FIGHT == v2.KEY
				end

				if v13 then
					v13.Enabled = v27 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
				end
			end
		end
	end

	local proximityPrompt3 = Instance.new("ProximityPrompt")
	proximityPrompt3:AddTag("ProximityPrompt")
	proximityPrompt3.ActionText = "Steal"
	proximityPrompt3.ObjectText = "Don Megalo's Coat"
	proximityPrompt3.MaxActivationDistance = 12
	proximityPrompt3.HoldDuration = 6
	proximityPrompt3.RequiresLineOfSight = false
	proximityPrompt3.Enabled = false
	proximityPrompt3.Parent = basePart
	proximityPrompt3.Triggered:Connect(onTriggered)
	v13 = proximityPrompt3
	proximityPrompt3.PromptButtonHoldBegan:Connect(function()
		if FIGHT ~= 2 then
			return
		end

		local v25 = {}
		v18 = v25
		task.delay(4, function()
			if v18 ~= v25 or FIGHT ~= 2 then
				return
			end

			v18 = nil

			if v13 then
				v13.Enabled = false
			end

			local v26 = v6

			if v26 then
				if FIGHT ~= v2.GATE then
					return
				end

				if v26:InvokeServer("TakeCape") == true then
					FIGHT = v2.FIGHT
				end

				local v27 = v6
				local v28

				if v27 == nil then
					v28 = false
				else
					v28 = v27.Active and not (v27.Completed or flag2)
				end

				if v11 then
					v11.Enabled = v28 and FIGHT == v2.NONE
				end

				if v12 then
					v12.Enabled = v28 and FIGHT == v2.KEY
				end

				if v13 then
					v13.Enabled = v28 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
				end
			end
		end)
	end)
	proximityPrompt3.PromptButtonHoldEnded:Connect(function()
		v18 = nil
	end)
	maid:GiveTask(function()
		clearPrompts() -- equivalent call inferred; original call site unknown
		stopWalkFollow() -- equivalent call inferred; original call site unknown
		v22.cancelled = true
		v22.baseCF = nil
		v22.model = nil
		focusBouncerFront() -- equivalent call inferred; original call site unknown
		local controller = v22.controller
		v22.controller = nil

		if controller then
			controller:FadeOut(v5.RETURN)
		end

		fn2()
		v21 = nil
		v19 = false
		stopGateStepper() -- equivalent call inferred; original call site unknown

		if FIGHT ~= 5 then
			closeGate() -- equivalent call inferred; original call site unknown
			setKeyHidden(false) -- equivalent call inferred; original call site unknown
		end

		if not v16 then
			local cape2 = v7.cape
			v15 = false

			if cape2 and parent2 and not cape2.Parent then
				cape2.Parent = parent2
			end
		end

		if v6 == maid then
			v6 = nil
		end
	end)
	local v25 = v6
	local v26

	if v25 == nil then
		v26 = false
	else
		v26 = v25.Active and not (v25.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v26 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v26 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v26 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end

	return true
end

local DonMegalo = {}
DonMegalo.LoadWhenCompleted = true

function DonMegalo.OnLoad(object)
	v6 = object

	if object.Completed then
		if resolveMarkers() then
			applyStage(5, true)
		end

		clearPrompts() -- equivalent call inferred; original call site unknown
	else
		if wire(object) then
			object:FireServer("Init")
			return
		end

		warn("[Don Megalo] missing \"BonusMoment_Locations\" markers under Map.Prison")
	end

	object:FireServer("Init")
end

function DonMegalo.OnActive(p, _: boolean)
	if v6 ~= p then
		return
	end

	local v23 = v6
	local v24

	if v23 == nil then
		v24 = false
	else
		v24 = v23.Active and not (v23.Completed or flag2)
	end

	if v11 then
		v11.Enabled = v24 and FIGHT == v2.NONE
	end

	if v12 then
		v12.Enabled = v24 and FIGHT == v2.KEY
	end

	if v13 then
		v13.Enabled = v24 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
	end
end

function DonMegalo.OnComplete(p, p2, p3)
	if v6 ~= p then
		return
	end

	if p3 == true and p2 ~= true then
		v16 = false
		v20 = false
		v19 = false
		applyStage(0, true)
	else
		applyStage(5, true)
	end

	clearPrompts() -- equivalent call inferred; original call site unknown
end

DonMegalo.RemoteEvents = {
	GateUnlocked = function(_)
		flag = true

		if not heartbeatConnection then
			KEEP_INTERVAL = v3.KEEP_INTERVAL
			heartbeatConnection = RunService.Heartbeat:Connect(keepGateOpen)
		end

		if not v19 then
			if v9 then
				return
			end

			resolveGate()

			if v7.gate then
				if not cFrame then
					return
				end

				local gate = v7.gate
				local v23 = not gate and 0 or gate.Size.Y * v3.RISE_SCALE
				stopGateStepper() -- equivalent call inferred; original call site unknown
				to = v23
				local v24 = to
				local gate2 = v7.gate
				local v25 = cFrame

				if gate2 then
					if not v25 then
						return
					end

					gate2.CFrame = v25 + Vector3.new(0, v24, 0)
				end
			end
		end
	end,
	GateLocked = function(_)
		unlatchGate() -- equivalent call inferred; original call site unknown
	end,
	Setup = function(p, value)
		if not (v6 == p and resolveMarkers()) then
			return
		end

		applyStage(typeof(value) ~= "number" and 0 or value, true)
	end,
	Stage = function(p, value)
		if v6 ~= p or typeof(value) ~= "number" or value == FIGHT then
			return
		end

		applyStage(value, false)
	end,
	Bouncer = function(p, model)
		if v6 ~= p then
			return
		end

		v18 = nil
		FIGHT = 3
		local v23 = v6
		local v24

		if v23 == nil then
			v24 = false
		else
			v24 = v23.Active and not (v23.Completed or flag2)
		end

		if v11 then
			v11.Enabled = v24 and FIGHT == v2.NONE
		end

		if v12 then
			v12.Enabled = v24 and FIGHT == v2.KEY
		end

		if v13 then
			v13.Enabled = v24 and (FIGHT == v2.GATE or FIGHT == v2.CLEARED)
		end

		if typeof(model) == "Instance" and model:IsA("Model") then
			v21 = model
			startWalkCamera(model)
		end
	end,
	BouncerWaypoint = function(p, value)
		if v6 ~= p then
			return
		end

		if typeof(value) == "number" and value >= 2 then
			focusBouncerFront() -- equivalent call inferred; original call site unknown
		end
	end,
	BouncerArrived = function(p)
		if v6 ~= p then
			return
		end

		local v23 = v21

		if v23 and v23.Parent then
			task.spawn(playButlerCutscene, v23)
			return
		end

		stopWalkFollow() -- equivalent call inferred; original call site unknown
		v22.cancelled = true
		v22.baseCF = nil
		v22.model = nil
		focusBouncerFront() -- equivalent call inferred; original call site unknown
		local controller = v22.controller
		v22.controller = nil

		if controller then
			controller:FadeOut(v5.RETURN)
		end
	end,
	BouncerDown = function(p)
		if v6 ~= p then
			return
		end

		v18 = nil
		v21 = nil
		stopWalkFollow() -- equivalent call inferred; original call site unknown
		v22.cancelled = true
		v22.baseCF = nil
		v22.model = nil
		focusBouncerFront() -- equivalent call inferred; original call site unknown
		local controller = v22.controller
		v22.controller = nil

		if controller then
			controller:FadeOut(v5.RETURN)
		end

		applyStage(4, false)
		task.spawn(playDefeatDialogue)
	end
}
return DonMegalo