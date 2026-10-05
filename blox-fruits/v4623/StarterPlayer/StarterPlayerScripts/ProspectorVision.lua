local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local DialogueController = require(ReplicatedStorage.DialogueController)
local Effect = require(ReplicatedStorage.Effect)
local Realm = require(ReplicatedStorage.Util.Realm)
local Util = require(ReplicatedStorage.Util)
local v = {
	Location = "Volcano Cave",
	Mark = "EvilProspector",
	Alerted = "ProspectorAlerted",
	Lantern = "ProspectorLantern",
	LanternColor = Color3.fromRGB(255, 214, 150),
	Beam = "ProspectorBeam",
	BeamColor = Color3.fromRGB(255, 214, 49),
	Range = 60,
	HalfAngle = 0.4328416544945937,
	Confirm = 0,
	Memory = 0.25,
	RaySteps = 4
}
local v2 = {
	ALERT_COLOR = Color3.fromRGB(255, 96, 64)
}
local v3 = {
	WAIT_FOR_MOBS = 6,
	SEARCH_RADIUS = 400,
	MAX_SHOTS = 2,
	SHOT_TIME = 2.6,
	SOLO_SHOT_TIME = 4,
	PAN_DIST = 26,
	PAN_UP = 7,
	PAN_LEAD = 14,
	SLIDE_RATE = 9,
	LOOK_UP = 1.5,
	RETURN_TIME = 0.8,
	DIALOGUE_TIMEOUT = 20,
	LINES = {
		"Prospectors... so they're the ones tearing this mountain open.",
		"Those lanterns sweep every inch of this cave.",
		"I shouldn't let them see me."
	}
}
local v4 = {
	NAME = "Magma Drill",
	REMOTE_NAME = "ProspectorDrillRemote",
	BIT_NAME = "Drillbit",
	COG_NAME = "cog",
	SMOKE_NAME = "DrillHitSmoke",
	BIT_SPEED = 7.5398223686155035,
	COG_SPEED = 2.199114857512855,
	RENDER_DISTANCE = 600,
	SHAKE_TIME = 0.35,
	SHAKE_AMOUNT = 0.45,
	SMOKE_EMIT = 14,
	HIT_SOUND = "Magma1.MagmaSmallSummon",
	BREAK_SOUND = "Magma1.MagmaClapExplosion",
	BOOM_SOUND = "Explosions.ExplosionHeavy",
	ERUPT_SOUND = "Magma1.MagmaEruption",
	CHUNK_MAX = 14,
	CHUNKS_PER_PART = 3,
	CHUNK_SCALE_MIN = 0.16,
	CHUNK_SCALE_MAX = 0.32,
	CHUNK_SIZE_MIN = 1,
	CHUNK_SIZE_MAX = 6,
	CHUNK_SPEED = 45,
	CHUNK_LIFETIME = 2.4,
	COMBUST_RANGE = 800,
	EMBER_COLOR = Color3.fromRGB(255, 140, 60),
	DEEP_COLOR = Color3.fromRGB(120, 50, 25),
	SMOKE_COLOR = Color3.fromRGB(60, 55, 52),
	ROCK_COLOR = Color3.fromRGB(90, 80, 70),
	HIGHLIGHT_COLOR = Color3.fromRGB(255, 70, 60),
	HIGHLIGHT_TIME = 0.45,
	WRECK_SCALE_MIN = 0.55,
	WRECK_SCALE_MAX = 0.8,
	WRECK_SPEED = 26,
	WRECK_SPIN = 14,
	WRECK_SETTLE = 3.5,
	WRECK_LIFETIME = 30,
	WRECK_FADE = 1.5,
	SECONDARY_BLASTS = 4,
	SECONDARY_RADIUS = 10,
	TIP_HOST = "Slash1",
	EMBER_NAME = "DrillEmbers",
	METEOR_INTERVAL = 8,
	METEOR_MIN = 1,
	METEOR_MAX = 3,
	METEOR_MIN_DIST = 14,
	METEOR_SPREAD = 26,
	METEOR_DURATION = 2.2,
	METEOR_SCALE = 0.25,
	METEOR_ARC = 0.65,
	METEOR_SHAKE_DISTANCE = 80,
	METEOR_SOUND_RADIUS = 12,
	METEOR_SOUND = "Magma1.MagmaEruption",
	MOMENT_NAME = "Magma Ore Extraction",
	DONE_ATTRIBUTE = "MagmaDrillPlugged",
	ROCKS_NAME = "RocksPlugged",
	ROCKS_SPAWN_DELAY = 4,
	ROCKS_WAIT = 30,
	FRENZY_ATTRIBUTE = "DrillFrenzy",
	FRENZY_BIT_MULT = 2.4,
	FRENZY_COG_MULT = 2.1,
	FRENZY_SHAKE = 0.17,
	FRENZY_METEOR_BONUS = 3,
	FRENZY_EMBER_EMIT = 55,
	FRENZY_SMOKE_EMIT = 8,
	FRENZY_PULSE_MIN = 1.4,
	FRENZY_PULSE_MAX = 2.6,
	FRENZY_PULSE_RANGE = 200,
	FRENZY_PULSE_SOUND = "Tremor.LoudTremorWave1",
	FRENZY_ONSET_SOUND = "Magma1.MagmaEruption",
	APPROACH_RANGE = 60,
	APPROACH_TIME = 3.2,
	APPROACH_PAN_DIST = 30,
	APPROACH_PAN_UP = -11,
	APPROACH_LOOK_UP = -14,
	APPROACH_SLIDE = 7,
	APPROACH_LINES = {
		"So THIS is what's been causing all the strange things happening on the island...",
		"I should destroy that drill and put a stop to it."
	},
	COLLAPSE_DELAY = 1.4,
	COLLAPSE_LINES = {
		"I need to get out of here before this place caves in!",
		"That lift behind the drill should run now that the shaking has stopped."
	},
	RUMBLE_MIN_GAP = 0.9,
	RUMBLE_MAX_GAP = 1.8,
	RUMBLE_SHAKE_MIN = 3,
	RUMBLE_SHAKE_MAX = 5.5,
	RUMBLE_SOUND = "Tremor.LoudTremorWave1",
	RUMBLE_SOUND_CHANCE = 0.85,
	RUMBLE_SOUND_RADIUS = 140,
	RUMBLE_JOLT_CHANCE = 0.25,
	RUMBLE_JOLT_SHAKE = 7,
	RUMBLE_JOLT_SOUND = "Explosions.ExplosionHeavy",
	EXCLUDE = {
		Slash1 = true,
		HumanoidRootPart = true,
		Head = true,
		UpperTorso = true,
		LowerTorso = true
	}
}

if Realm.getCurrentSeaAsync() ~= "Sea1" then
	return
end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local prospectorSightRemote = remotes:WaitForChild("ProspectorSightRemote")
local localPlayer = Players.LocalPlayer

local function readString(attributeName: string, p: string)
	local attribute = prospectorSightRemote:GetAttribute(attributeName)

	if typeof(attribute) == "string" then
		return attribute
	end

	return p
end

local function readNumber(attributeName: string, p: number)
	local attribute = prospectorSightRemote:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function readColor(attributeName: string, color: Color3)
	local attribute = prospectorSightRemote:GetAttribute(attributeName)

	if typeof(attribute) == "Color3" then
		return attribute
	end

	return color
end

local clone = table.clone(v)

local function readTuning()
	local v5 = clone
	local location = v.Location
	local location2 = prospectorSightRemote:GetAttribute("Location")

	if typeof(location2) ~= "string" then
		location2 = location
	end

	v5.Location = location2
	local v6 = clone
	local mark = v.Mark
	local mark2 = prospectorSightRemote:GetAttribute("Mark")

	if typeof(mark2) == "string" then
		mark = mark2
	end

	v6.Mark = mark
	local v7 = clone
	local alerted = v.Alerted
	local alerted2 = prospectorSightRemote:GetAttribute("Alerted")

	if typeof(alerted2) == "string" then
		alerted = alerted2
	end

	v7.Alerted = alerted
	local v8 = clone
	local lantern = v.Lantern
	local lantern2 = prospectorSightRemote:GetAttribute("Lantern")

	if typeof(lantern2) == "string" then
		lantern = lantern2
	end

	v8.Lantern = lantern
	local v9 = clone
	local lanternColor = v.LanternColor
	local lanternColor2 = prospectorSightRemote:GetAttribute("LanternColor")

	if typeof(lanternColor2) == "Color3" then
		lanternColor = lanternColor2
	end

	v9.LanternColor = lanternColor
	local v10 = clone
	local beam = v.Beam
	local beam2 = prospectorSightRemote:GetAttribute("Beam")

	if typeof(beam2) == "string" then
		beam = beam2
	end

	v10.Beam = beam
	local v11 = clone
	local beamColor = v.BeamColor
	local beamColor2 = prospectorSightRemote:GetAttribute("BeamColor")

	if typeof(beamColor2) == "Color3" then
		beamColor = beamColor2
	end

	v11.BeamColor = beamColor
	local v12 = clone
	local range = v.Range
	local range2 = prospectorSightRemote:GetAttribute("Range")

	if typeof(range2) == "number" then
		range = range2
	end

	v12.Range = range
	local v13 = clone
	local halfAngle = v.HalfAngle
	local halfAngle2 = prospectorSightRemote:GetAttribute("HalfAngle")

	if typeof(halfAngle2) == "number" then
		halfAngle = halfAngle2
	end

	v13.HalfAngle = halfAngle
	local v14 = clone
	local confirm = v.Confirm
	local confirm2 = prospectorSightRemote:GetAttribute("Confirm")

	if typeof(confirm2) == "number" then
		confirm = confirm2
	end

	v14.Confirm = confirm
	local v15 = clone
	local memory = v.Memory
	local memory2 = prospectorSightRemote:GetAttribute("Memory")

	if typeof(memory2) == "number" then
		memory = memory2
	end

	v15.Memory = memory
	local v16 = clone
	local raySteps = v.RaySteps
	local raySteps2 = prospectorSightRemote:GetAttribute("RaySteps")

	if typeof(raySteps2) == "number" then
		raySteps = raySteps2
	end

	v16.RaySteps = raySteps
end

readTuning()
prospectorSightRemote.AttributeChanged:Connect(readTuning)
local v5 = {}
local v6 = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

local function refreshRayFilter()
	local now = os.clock()

	if now - v6 < 1 then
		return
	end

	v6 = now
	local children = {}

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"Boats"
	} do
		local child = Workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
end

local function tintLantern(instance, flag: boolean)
	local head = instance:FindFirstChild("Head")

	if not head then
		return
	end

	local light = head:FindFirstChild(clone.Lantern)

	if light and light:IsA("SpotLight") then
		local color

		if flag then
			color = v2.ALERT_COLOR
		else
			color = clone.LanternColor
		end

		light.Color = color
	end

	local part = head:FindFirstChild(clone.Beam)

	if part and part:IsA("BasePart") then
		local color

		if flag then
			color = v2.ALERT_COLOR
		else
			color = clone.BeamColor
		end

		part.Color = color
	end
end

local function track(model)
	if not (model:IsA("Model") and model.Parent) or v5[model] or model:GetAttribute(clone.Mark) ~= true then
		return
	end

	v5[model] = {
		seenSince = nil,
		lastSeen = 0,
		reportedAt = 0,
		pendingLoss = false,
		alertTint = false
	}
end

local function untrack(p)
	v5[p] = nil
end

local enemies = Workspace:WaitForChild("Enemies")

for _, child in enemies:GetChildren() do
	track(child)
end

enemies.ChildAdded:Connect(function(child)
	task.defer(track, child)
	task.delay(1, track, child)
end)
enemies.ChildRemoved:Connect(untrack)

local function localRoot()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function isAlive()
	local character = localPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	return humanoid ~= nil and humanoid.Health > 0
end

local function concealed()
	local character = localPlayer.Character
	return character ~= nil and character:FindFirstChild("DoorMode") ~= nil
end

local function sightBlocked(position: Vector3, position2: Vector3)
	local v7 = position2 - position
	local magnitude = v7.Magnitude

	if magnitude < 0.001 then
		return false
	end

	local unit = v7.Unit

	for _ = 1, clone.RaySteps do
		local raycastResult = Workspace:Raycast(position, unit * magnitude, raycastParams)

		if not raycastResult then
			return false
		end

		if raycastResult.Instance.Transparency < 1 then
			return true
		end

		magnitude -= (raycastResult.Position - position).Magnitude + 0.1

		if magnitude <= 0 then
			return false
		else
			position = raycastResult.Position + unit * 0.1
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lanternCFrame(instance)
	local head = instance:FindFirstChild("Head")

	if head and head:IsA("BasePart") and head:FindFirstChild(clone.Lantern) then
		return head.CFrame
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function litBy(cframe: CFrame, position: Vector3)
	local v7 = position - cframe.Position
	local magnitude = v7.Magnitude

	if clone.Range < magnitude then
		return false
	end

	return magnitude < 0.001 or v7.Unit:Dot(cframe.LookVector) >= math.cos(clone.HalfAngle)
end

local function canSee(instance, character)
	local v7 = lanternCFrame(instance) -- equivalent call inferred; original call site unknown

	if not v7 then
		return false
	end

	for _, childName in { "HumanoidRootPart", "Head" } do
		local part = character:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local v8 = litBy(v7, part.Position) -- equivalent call inferred; original call site unknown

		if v8 and not sightBlocked(v7.Position, part.Position) then
			return true
		end
	end

	return false
end

local flag = false
local flag2 = false

local function nearestProspectors(position: Vector3)
	local humanoidRootParts = {}

	for k in v5 do
		local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") and (humanoidRootPart.Position - position).Magnitude <= v3.SEARCH_RADIUS then
			table.insert(humanoidRootParts, humanoidRootPart)
		end
	end

	table.sort(humanoidRootParts, function(a, b)
		return (a.Position - position).Magnitude < (b.Position - position).Magnitude
	end)
	return humanoidRootParts
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatLook(p)
	local vector2 = Vector3.new(p.CFrame.LookVector.X, 0, p.CFrame.LookVector.Z)

	if vector2.Magnitude > 0.001 then
		return vector2.Unit
	end

	return createVector(0, 0, 1)
end

local function panShotFor(p, position: Vector3, SOLO_SHOT_TIME: number)
	local position2 = p.Position
	local v7 = flatLook(p) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z)
	local v8

	if vector2.Magnitude > 0.001 then
		v8 = vector2.Unit
	else
		v8 = -v7
	end

	local v9 = position2 + v8 * v3.PAN_DIST + createVector(0, 1, 0) * v3.PAN_UP
	local v10 = position2 + v7 * v3.PAN_LEAD + createVector(0, 1, 0) * v3.LOOK_UP
	local v11 = v7 * (v3.SLIDE_RATE * SOLO_SHOT_TIME)
	return function(p2: number)
		local v12 = v11 * p2
		return v9 + v12, v10 + v12
	end
end

local function panShot(object, p: number, callback)
	local v7, v8 = callback(0)

	if not (v7 and v8) then
		return
	end

	object:TeleportTo(CFrame.lookAt(v7, v8))
	local total = 0

	while total < p do
		total += RunService.RenderStepped:Wait()
		local character = localPlayer.Character
		local humanoid

		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end

		local v9

		if humanoid == nil then
			v9 = false
		else
			v9 = humanoid.Health > 0
		end

		if not v9 then
			break
		end

		local v10, v11 = callback((math.clamp(total / p, 0, 1)))

		if v10 and v11 then
			if (v10 - v11).Magnitude > 0.001 then
				object:SetCFrame(CFrame.lookAt(v10, v11))
			end
		else
			break
		end
	end
end

local function startLines(p)
	if DialogueController.Active then
		return
	end

	pcall(function()
		DialogueController.start({
			Title = "",
			Get = function()
				return {
					Text = table.clone(p)
				}
			end
		})
	end)
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule

		if playerScripts then
			playerModule = playerScripts:FindFirstChild("PlayerModule")
		end

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return module:GetControls()
	end)

	if success then
		return result
	end

	return nil
end

local function runCinematic(fn)
	flag2 = true
	local v7 = CameraController.new()
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule

		if playerScripts then
			playerModule = playerScripts:FindFirstChild("PlayerModule")
		end

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return module:GetControls()
	end)

	if not success then
		result = nil
	end

	local folder = nil

	if result then
		pcall(function()
			result:Disable()
		end)
	end

	local character = localPlayer.Character

	if character then
		folder = Instance.new("Folder")
		folder.Name = "DisableMovement"
		folder.Parent = character
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function unlock()
		if result then
			pcall(function()
				result:Enable()
			end)
			result = nil
		end

		if folder then
			folder:Destroy()
			folder = nil
		end
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid then
		humanoid.Died:Once(unlock)
	end

	local success2, result2 = pcall(function()
		fn(v7)
	end)

	if not success2 then
		warn((`[ProspectorVision] cinematic failed: {result2}`))
	end

	unlock() -- equivalent call inferred; original call site unknown
	v7:FadeOut(v3.RETURN_TIME)
	task.delay(v3.RETURN_TIME + 0.4, function()
		v7:Destroy()
	end)
	flag2 = false
end

local function runIntro()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if humanoidRootPart then
		local character2 = localPlayer.Character
		local humanoid

		if character2 then
			humanoid = character2:FindFirstChildOfClass("Humanoid")
		end

		local v7

		if humanoid == nil then
			v7 = false
		else
			v7 = humanoid.Health > 0
		end

		if v7 then
			local v8 = os.clock() + v3.WAIT_FOR_MOBS
			local v9 = nearestProspectors(humanoidRootPart.Position)

			while #v9 == 0 and os.clock() < v8 do
				task.wait(0.25)
				local character3 = localPlayer.Character
				local humanoidRootPart2

				if character3 then
					humanoidRootPart2 = character3:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				if humanoidRootPart2 then
					v9 = nearestProspectors(humanoidRootPart2.Position)
				else
					flag = false
					return
				end
			end

			if #v9 == 0 then
				flag = false
			else
				runCinematic(function(p)
					task.spawn(startLines, v3.LINES)
					local character3 = localPlayer.Character
					local humanoidRootPart2

					if character3 then
						humanoidRootPart2 = character3:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
						humanoidRootPart2 = nil
					end

					local position

					if humanoidRootPart2 then
						position = humanoidRootPart2.Position
					else
						position = humanoidRootPart.Position
					end

					local v10 = math.min(#v9, v3.MAX_SHOTS)
					local SOLO_SHOT_TIME

					if v10 == 1 then
						SOLO_SHOT_TIME = v3.SOLO_SHOT_TIME
					else
						SOLO_SHOT_TIME = v3.SHOT_TIME
					end

					for i = 1, v10 do
						local character4 = localPlayer.Character
						local humanoid2

						if character4 then
							humanoid2 = character4:FindFirstChildOfClass("Humanoid")
						end

						local v11

						if humanoid2 == nil then
							v11 = false
						else
							v11 = humanoid2.Health > 0
						end

						if not v11 then
							break
						end

						panShot(p, SOLO_SHOT_TIME, panShotFor(v9[i], position, SOLO_SHOT_TIME))
					end

					local v11 = os.clock() + v3.DIALOGUE_TIMEOUT

					while DialogueController.Active and os.clock() < v11 do
						local character4 = localPlayer.Character
						local humanoid2

						if character4 then
							humanoid2 = character4:FindFirstChildOfClass("Humanoid")
						end

						local v12

						if humanoid2 == nil then
							v12 = false
						else
							v12 = humanoid2.Health > 0
						end

						if not v12 then
							break
						end

						task.wait(0.1)
					end
				end)
			end

			return
		end
	end

	flag = false
end

local function maybeIntro()
	if flag or localPlayer:GetAttribute("CurrentLocation") ~= clone.Location then
		return
	end

	flag = true
	task.spawn(runIntro)
end

RunService.Heartbeat:Connect(function()
	if localPlayer:GetAttribute("CurrentLocation") == clone.Location then
		if flag2 then
			return
		end

		local character = localPlayer.Character

		if character then
			local character2 = localPlayer.Character
			local humanoidRootPart

			if character2 then
				humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if humanoidRootPart then
				local character3 = localPlayer.Character
				local humanoid

				if character3 then
					humanoid = character3:FindFirstChildOfClass("Humanoid")
				end

				local v7

				if humanoid == nil then
					v7 = false
				else
					v7 = humanoid.Health > 0
				end

				if v7 then
					refreshRayFilter()
					local now = os.clock()
					local character4 = localPlayer.Character
					local v8

					if character4 == nil then
						v8 = false
					else
						v8 = character4:FindFirstChild("DoorMode") ~= nil
					end

					for k, v9 in v5 do
						if not k.Parent then
							continue
						end

						local alertTint = k:GetAttribute(clone.Alerted) == true

						if alertTint ~= v9.alertTint then
							v9.alertTint = alertTint
							tintLantern(k, alertTint)
						end

						local v11 = not v8 and canSee(k, character)

						if v11 then
							v9.lastSeen = now
						end

						local v12 = now - v9.lastSeen <= clone.Memory

						if v9.pendingLoss then
							if v12 then
								if not alertTint and now - v9.reportedAt > 0.25 then
									v9.pendingLoss = false
								end
							else
								v9.pendingLoss = false
								prospectorSightRemote:FireServer(k, true)
							end
						elseif alertTint then
							v9.seenSince = nil
						elseif v12 then
							if v11 and not v9.seenSince then
								v9.seenSince = now
							end

							local seenSince = v9.seenSince

							if seenSince and not (now - seenSince < clone.Confirm or now - v9.reportedAt < 0.25) then
								v9.reportedAt = now
								v9.seenSince = nil
								v9.pendingLoss = true
								prospectorSightRemote:FireServer(k, false)
							end
						else
							v9.seenSince = nil
						end
					end
				end
			end
		end
	else
		for _, v7 in v5 do
			v7.seenSince = nil
		end
	end
end)
localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(maybeIntro)

if not flag and localPlayer:GetAttribute("CurrentLocation") == clone.Location then
	flag = true
	task.spawn(runIntro)
end

local child = remotes:WaitForChild(v4.REMOTE_NAME)
local v7 = nil
local cFramesByPart = {}
local v8 = nil
local parts = {}
local position = nil
local v9 = nil
local v10 = 0
local flag3 = false
local v11 = false
local connection = nil
local v12 = nil
local v13 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function clearDrillFlash()
	if v13 then
		v13:Cancel()
		v13 = nil
	end

	if v12 then
		v12:Destroy()
		v12 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropDrill()
	clearDrillFlash() -- equivalent call inferred; original call site unknown

	if connection then
		connection:Disconnect()
		connection = nil
	end

	v11 = false
	v7 = nil
	v8 = nil
	position = nil
	v9 = nil
	table.clear(cFramesByPart)
	table.clear(parts)
	flag3 = false
end

local function flashDrill(folder)
	clearDrillFlash() -- equivalent call inferred; original call site unknown
	local highlight = Instance.new("Highlight")
	highlight.Name = "DrillDamageFlash"
	highlight.Adornee = folder
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = v4.HIGHLIGHT_COLOR
	highlight.OutlineColor = v4.HIGHLIGHT_COLOR
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0
	highlight.Parent = folder
	local tween = TweenService:Create(
		highlight,
		TweenInfo.new(v4.HIGHLIGHT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			FillTransparency = 1,
			OutlineTransparency = 1
		}
	)
	tween.Completed:Once(function()
		if v12 == highlight then
			clearDrillFlash() -- equivalent call inferred; original call site unknown
		end
	end)
	v12 = highlight
	v13 = tween
	tween:Play()
end

local v14 = false
local flag4 = false
local v15 = nil
local v16 = nil
local descendantAddedConnection = nil
local v17 = {}

local function hideInstanceLocally(descendant)
	if descendant:IsA("BasePart") then
		if v17[descendant] == nil then
			v17[descendant] = descendant.CanCollide
		end

		descendant.LocalTransparencyModifier = 1
		descendant.CanCollide = false
	elseif descendant:IsA("ParticleEmitter") then
		if v17[descendant] == nil then
			v17[descendant] = descendant.Enabled
		end

		descendant.Enabled = false
		descendant:Clear()
	elseif descendant:IsA("Light") then
		if v17[descendant] == nil then
			v17[descendant] = descendant.Enabled
		end

		descendant.Enabled = false
	end
end

local function showDrillLocally()
	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	for instance, v18 in v17 do
		if not instance.Parent then
			continue
		end

		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = 0
			instance.CanCollide = v18
		elseif instance:IsA("ParticleEmitter") then
			instance.Enabled = v18
		elseif instance:IsA("Light") then
			instance.Enabled = v18
		end
	end

	table.clear(v17)
	v16 = nil
end

local function hideDrillLocally(folder)
	if v16 == folder then
		return
	end

	showDrillLocally()
	v16 = folder

	for _, descendant in folder:GetDescendants() do
		hideInstanceLocally(descendant)
	end

	descendantAddedConnection = folder.DescendantAdded:Connect(hideInstanceLocally)
end

local function rocksTemplate()
	local bonusMoments = ReplicatedStorage:WaitForChild("BonusMoments", v4.ROCKS_WAIT)
	local child2

	if bonusMoments then
		child2 = bonusMoments:WaitForChild(v4.MOMENT_NAME, v4.ROCKS_WAIT)
	end

	local model

	if child2 then
		model = child2:WaitForChild(v4.ROCKS_NAME, v4.ROCKS_WAIT)
	end

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function despawnRocks()
	local v18 = v15
	v15 = nil

	if v18 then
		v18:Destroy()
	end
end

local flag5 = false

local function spawnRocks(flag6: boolean)
	if v15 or flag5 then
		return
	end

	flag5 = true
	local v18 = rocksTemplate()
	flag5 = false

	if not v18 then
		warn((`[ProspectorVision] missing {v4.ROCKS_NAME} model under the replicated {v4.MOMENT_NAME} module`))
		return
	end

	if v15 or not v14 then
		return
	end

	local clone2 = v18:Clone()
	clone2.Parent = Workspace
	v15 = clone2

	if flag6 then
		local position2 = clone2:GetPivot().Position
		Util.Sound:Play(v4.BOOM_SOUND, position2, 100, 0.7, 0.9)
		Effect.new("DustExplosion"):play({
			CFrame = CFrame.new(position2),
			Size = { 10, 34 },
			Duration = 1.3,
			ColorSequence = ColorSequence.new(v4.ROCK_COLOR, v4.DEEP_COLOR)
		})
		Effect.new("GroundSmash"):play({
			Size = 24,
			Position = position2,
			Normal = createVector(0, 1, 0),
			Color = v4.ROCK_COLOR,
			Duration = 2.5
		})
		Util.CameraShaker:ShakeOnce(5, 8, 0.05, 1.4)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adoptDrill(folder)
	if v14 then
		hideDrillLocally(folder)
	else
		task.spawn(function()
			local v18 = os.clock() + 10
			local part = folder:FindFirstChild(v4.BIT_NAME, true)

			while not part and os.clock() < v18 and folder.Parent do
				task.wait(0.2)
				part = folder:FindFirstChild(v4.BIT_NAME, true)
			end

			if not folder.Parent or v7 == folder then
				return
			end

			if v14 then
				hideDrillLocally(folder)
				return
			end

			dropDrill() -- equivalent call inferred; original call site unknown
			v7 = folder
			position = folder:GetPivot().Position
			local part2 = folder:FindFirstChild(v4.TIP_HOST, true)

			if part2 and part2:IsA("BasePart") then
				local attachment = part2:FindFirstChildOfClass("Attachment")
				local v19

				if attachment then
					v19 = attachment.WorldPosition
				else
					v19 = part2.Position
				end

				v9 = v19
			else
				v9 = position
			end

			for _, part3 in folder:GetDescendants() do
				if not part3:IsA("BasePart") or v4.EXCLUDE[part3.Name] then
					continue
				end

				cFramesByPart[part3] = part3.CFrame

				if part3.Name == v4.COG_NAME then
					table.insert(parts, part3)
				end
			end

			if part and part:IsA("BasePart") then
				v8 = part
			end

			v11 = folder:GetAttribute(v4.FRENZY_ATTRIBUTE) == true
			connection = folder:GetAttributeChangedSignal(v4.FRENZY_ATTRIBUTE):Connect(function()
				if v7 ~= folder then
					return
				end

				local v19 = folder:GetAttribute(v4.FRENZY_ATTRIBUTE) == true

				if v19 == v11 then
					return
				end

				v11 = v19

				if not v19 then
					return
				end

				local v20 = v9 or position

				if v20 then
					Util.Sound:Play(v4.FRENZY_ONSET_SOUND, v20, v4.FRENZY_PULSE_RANGE, 0.8, 1)
				end

				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") and emitter.Name == v4.EMBER_NAME then
						emitter:Emit(v4.FRENZY_EMBER_EMIT)
					end
				end

				v10 = os.clock() + v4.SHAKE_TIME * 3
				local currentCamera = Workspace.CurrentCamera

				if currentCamera and v20 and (currentCamera.CFrame.Position - v20).Magnitude <= v4.FRENZY_PULSE_RANGE then
					Util.CameraShaker:ShakeOnce(6, 9, 0.15, 1.6)
				end
			end)
		end)
	end
end

local function shatterDrill(folder, position2: Vector3)
	local count = 0

	for _, part in folder:GetDescendants() do
		if v4.CHUNK_MAX <= count then
			break
		end

		if not part:IsA("BasePart") or (part.Transparency >= 1 or v4.EXCLUDE[part.Name]) then
			continue
		end

		for _ = 1, v4.CHUNKS_PER_PART do
			if v4.CHUNK_MAX <= count then
				break
			end

			count += 1
			local clone2 = part:Clone()

			for _, descendant in clone2:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("Attachment") or descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Light")) then
					continue
				end

				descendant:Destroy()
			end

			local halfSize = part.Size / 2
			local vector2 = Vector3.new(
				(math.random() - 0.5) * 2 * halfSize.X,
				(math.random() - 0.5) * 2 * halfSize.Y,
				(math.random() - 0.5) * 2 * halfSize.Z
			)
			local cFrame = part.CFrame * CFrame.new(vector2)
			local v20 = v4.CHUNK_SCALE_MIN + (v4.CHUNK_SCALE_MAX - v4.CHUNK_SCALE_MIN) * math.random()
			local size = part.Size * v20
			local v22 = math.max(size.X, size.Y, size.Z)

			if v4.CHUNK_SIZE_MAX < v22 then
				size *= v4.CHUNK_SIZE_MAX / v22
			elseif v22 < v4.CHUNK_SIZE_MIN then
				size *= v4.CHUNK_SIZE_MIN / v22
			end

			clone2.Name = "ProspectorDrillChunk"
			clone2.Size = size
			clone2.CFrame = cFrame
			clone2.Anchored = false
			clone2.CanCollide = false
			clone2.CanQuery = false
			clone2.CanTouch = false
			clone2.Massless = true
			local v23 = cFrame.Position - position2
			clone2.AssemblyLinearVelocity = (not (v23.Magnitude > 0.001) and createVector(0, 1, 0) or v23.Unit) * (v4.CHUNK_SPEED * (0.5 + math.random() * 0.5)) + Vector3.new(
				0,
				18 + math.random() * 22,
				0
			)
			clone2.AssemblyAngularVelocity = Vector3.new(
				(math.random() - 0.5) * 12,
				(math.random() - 0.5) * 12,
				(math.random() - 0.5) * 12
			)
			clone2.Parent = Workspace
			Debris:AddItem(clone2, v4.CHUNK_LIFETIME)
		end
	end
end

local function scatterWreck(folder, position2: Vector3)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or (v4.EXCLUDE[part.Name] or part.Transparency >= 1) then
			continue
		end

		local clone2 = part:Clone()

		for _, descendant in clone2:GetDescendants() do
			descendant:Destroy()
		end

		local v18 = v4.WRECK_SCALE_MIN + (v4.WRECK_SCALE_MAX - v4.WRECK_SCALE_MIN) * math.random()
		clone2.Name = "ProspectorDrillWreck"
		clone2.Material = Enum.Material.CorrodedMetal
		clone2.Size = part.Size * v18
		clone2.Anchored = false
		clone2.CanCollide = true
		clone2.CanQuery = false
		clone2.CanTouch = false
		clone2.Massless = false
		local vector2 = Vector3.new(part.Position.X - position2.X, 0, part.Position.Z - position2.Z)
		local v19

		if vector2.Magnitude > 0.001 then
			v19 = vector2.Unit
		else
			v19 = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * createVector(0, 0, 1)
		end

		clone2.AssemblyLinearVelocity = v19 * (v4.WRECK_SPEED * (0.6 + math.random() * 0.6)) + Vector3.new(
			0,
			22 + math.random() * 18,
			0
		)
		clone2.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * v4.WRECK_SPIN
		clone2.Parent = Workspace
		task.delay(v4.WRECK_SETTLE, function()
			if clone2.Parent then
				clone2.Anchored = true
			end
		end)
		local v21 = clone2
		task.delay(v4.WRECK_LIFETIME, function()
			if v21.Parent then
				TweenService:Create(v21, TweenInfo.new(v4.WRECK_FADE), {
					Transparency = 1
				}):Play()
			end
		end)
		Debris:AddItem(clone2, v4.WRECK_LIFETIME + v4.WRECK_FADE + 0.2)
	end
end

local function drillFloorPosition(p, vector2: Vector3)
	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = {}

	if p then
		table.insert(filterDescendantsInstances, p)
	end

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"Boats"
	} do
		local child2 = Workspace:FindFirstChild(childName)

		if child2 then
			table.insert(filterDescendantsInstances, child2)
		end
	end

	raycastParams2.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = Workspace:Raycast(vector2, createVector(0, -80, 0), raycastParams2)

	if raycastResult then
		return raycastResult.Position
	end

	return vector2 - createVector(0, 12, 0)
end

local function combustDrill(cframe: CFrame)
	flag4 = true
	local position2 = cframe.Position
	local currentCamera = Workspace.CurrentCamera
	local v18 = currentCamera == nil or (currentCamera.CFrame.Position - position2).Magnitude <= v4.COMBUST_RANGE
	local v19 = v7
	local position3 = drillFloorPosition(v19, position2)

	if v19 and v18 then
		shatterDrill(v19, position2)
		scatterWreck(v19, position2)
	end

	dropDrill() -- equivalent call inferred; original call site unknown

	if not v18 then
		return
	end

	Util.Sound:Play(v4.BREAK_SOUND, position2, 110, 0.9, 1)
	Util.Sound:Play(v4.BOOM_SOUND, position2, 110, 0.8, 1)
	Util.Sound:Play(v4.ERUPT_SOUND, position2, 110, 1.1, 0.9)
	Effect.new("MeteorExplosion"):play({
		SmokeColor = v4.SMOKE_COLOR,
		Origin = CFrame.new(position2) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0),
		Scale = 2,
		Lifetime = 1.4
	})
	Effect.new("FireExplosion"):play({
		Position = position2,
		Emit = 45,
		Speed = 55,
		Scale = 2.2
	})
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(position2),
		Size = { 10, 38 },
		Duration = 1.4,
		ColorSequence = ColorSequence.new(v4.EMBER_COLOR, v4.DEEP_COLOR)
	})
	Effect.new("GroundSmash"):play({
		Size = 26,
		Position = position3,
		Normal = createVector(0, 1, 0),
		Color = v4.ROCK_COLOR,
		Duration = 2.5
	})
	Effect.new("ExpandRing"):play({
		Origin = CFrame.lookAt(position3, position3 + createVector(0, 1, 0)),
		Color = v4.EMBER_COLOR,
		Size = { createVector(8, 8, 1), createVector(70, 70, 1) },
		Duration = 0.7
	})

	for i = 1, 2 do
		local ringWind = Effect.new("RingWind")
		local v21 = {
			CFrame = CFrame.new(position3 + Vector3.new(0, i * 3, 0)),
			Transparency = { 0.15, 1 },
			Radius = { 8, i * 10 + 34 },
			Duration = i * 0.15 + 0.7,
			Color = 0
		}
		local color

		if i % 2 == 0 then
			color = v4.DEEP_COLOR
		else
			color = v4.EMBER_COLOR
		end

		v21.Color = color
		ringWind:play(v21)
	end

	Util.CameraShaker:ShakeOnce(6, 9, 0.06, 1.9)

	for i = 1, v4.SECONDARY_BLASTS do
		local v21 = i
		task.delay(0.12 + i * (0.1 + math.random() * 0.12), function()
			local position4 = position2 + Vector3.new(
				(math.random() - 0.5) * 2 * v4.SECONDARY_RADIUS,
				math.random() * 6,
				(math.random() - 0.5) * 2 * v4.SECONDARY_RADIUS
			)
			Effect.new("FireExplosion"):play({
				Position = position4,
				Emit = 18,
				Speed = 35,
				Scale = 1.1 + math.random() * 0.4
			})

			if v21 % 2 == 0 then
				Effect.new("MeteorExplosion"):play({
					SmokeColor = v4.SMOKE_COLOR,
					Origin = CFrame.new(position4) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0),
					Scale = 0.9,
					Lifetime = 1
				})
			end

			Util.Sound:Play(v4.BOOM_SOUND, position4, 70, 1.05 + math.random() * 0.2, 0.7)
			Util.CameraShaker:ShakeOnce(2.5, 10, 0.05, 0.9)
		end)
	end
end

local flag6 = false

local function startCollapseWarning(position2: Vector3)
	if localPlayer:GetAttribute("CurrentLocation") ~= clone.Location then
		return
	end

	task.delay(v4.COLLAPSE_DELAY, function()
		if localPlayer:GetAttribute("CurrentLocation") ~= clone.Location or DialogueController.Active then
			return
		end

		task.spawn(function()
			pcall(function()
				DialogueController.start({
					Title = "",
					Get = function()
						return {
							Text = table.clone(v4.COLLAPSE_LINES)
						}
					end
				})
			end)
		end)
	end)

	if flag6 then
		return
	end

	flag6 = true
	task.spawn(function()
		while localPlayer:GetAttribute("CurrentLocation") == clone.Location and not v7 do
			if math.random() < v4.RUMBLE_JOLT_CHANCE then
				Util.CameraShaker:ShakeOnce(v4.RUMBLE_JOLT_SHAKE, 9, 0.05, 1.4)
				Util.Sound:Play(
					v4.RUMBLE_JOLT_SOUND,
					position2,
					v4.RUMBLE_SOUND_RADIUS,
					0.6 + math.random() * 0.15,
					0.85
				)
			else
				local v18 = v4.RUMBLE_SHAKE_MIN + math.random() * (v4.RUMBLE_SHAKE_MAX - v4.RUMBLE_SHAKE_MIN)
				Util.CameraShaker:ShakeOnce(v18, 7, 0.08, 1.3)
			end

			if math.random() < v4.RUMBLE_SOUND_CHANCE then
				Util.Sound:Play(v4.RUMBLE_SOUND, position2, v4.RUMBLE_SOUND_RADIUS, 0.7 + math.random() * 0.25, 0.85)
			end

			task.wait(v4.RUMBLE_MIN_GAP + math.random() * (v4.RUMBLE_MAX_GAP - v4.RUMBLE_MIN_GAP))
		end

		flag6 = false
	end)
end

child.OnClientEvent:Connect(function(p, p2)
	if p == "Hit" then
		v10 = os.clock() + v4.SHAKE_TIME
		local folder = v7

		if folder then
			flashDrill(folder)

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Name == v4.SMOKE_NAME then
					emitter:Emit(v4.SMOKE_EMIT)
				end
			end

			local v18 = position

			if v18 then
				Util.Sound:Play(v4.HIT_SOUND, v18, 60, 0.95 + math.random() * 0.15, 0.8)
			end
		end
	elseif p == "Destroyed" and typeof(p2) == "CFrame" then
		combustDrill(p2)
		startCollapseWarning(p2.Position)
	end
end)
RunService.RenderStepped:Connect(function()
	if not (v7 and v7.Parent) then
		return
	end

	local v19 = position
	local currentCamera = Workspace.CurrentCamera

	if currentCamera and v19 and (currentCamera.CFrame.Position - v19).Magnitude > v4.RENDER_DISTANCE then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()
	local v20 = v4.BIT_SPEED * (not v11 and 1 or v4.FRENZY_BIT_MULT)
	local v21 = v4.COG_SPEED * (not v11 and 1 or v4.FRENZY_COG_MULT)
	local v22 = serverTimeNow % (6.283185307179586 / v20) * v20
	local v23 = serverTimeNow % (6.283185307179586 / v21) * v21
	local v24 = v10 - os.clock()
	local v25 = not (v24 > 0) and 0 or v4.SHAKE_AMOUNT * math.clamp(v24 / v4.SHAKE_TIME, 0, 1)

	if v11 then
		v25 = math.max(v25, v4.FRENZY_SHAKE)
	end

	local v26 = v25 > 0
	local v27 = not v26 and createVector(0, 0, 0) or Vector3.new(
		(math.random() - 0.5) * 2 * v25,
		(math.random() - 0.5) * 2 * v25,
		(math.random() - 0.5) * 2 * v25
	)
	local v28 = v8
	local v29 = v28 and v28.Parent and cFramesByPart[v28]

	if v29 then
		v28.CFrame = (v29 + v27) * CFrame.Angles(0, 0, v22)
	end

	for k, v30 in parts do
		if not v30.Parent then
			continue
		end

		local v31 = cFramesByPart[v30]

		if not v31 then
			continue
		end

		local v32

		if k % 2 == 0 then
			v32 = -v23
		else
			v32 = v23
		end

		v30.CFrame = (v31 + v27) * CFrame.Angles(v32, 0, 0)
	end

	if v26 then
		for k, v30 in cFramesByPart do
			if k == v28 or not k.Parent or table.find(parts, k) then
				continue
			end

			k.CFrame = v30 + v27
		end

		flag3 = true
	elseif flag3 then
		flag3 = false

		for k, cFrame in cFramesByPart do
			if k == v28 or not k.Parent or table.find(parts, k) then
				continue
			end

			k.CFrame = cFrame
		end
	end
end)
local model = enemies:FindFirstChild(v4.NAME)

if model and model:IsA("Model") then
	if v14 then
		hideDrillLocally(model)
	else
		task.spawn(function()
			local v18 = os.clock() + 10
			local part = model:FindFirstChild(v4.BIT_NAME, true)

			while not part and os.clock() < v18 and model.Parent do
				task.wait(0.2)
				part = model:FindFirstChild(v4.BIT_NAME, true)
			end

			if not model.Parent or v7 == model then
				return
			end

			if v14 then
				hideDrillLocally(model)
				return
			end

			dropDrill() -- equivalent call inferred; original call site unknown
			v7 = model
			position = model:GetPivot().Position
			local part2 = model:FindFirstChild(v4.TIP_HOST, true)

			if part2 and part2:IsA("BasePart") then
				local attachment = part2:FindFirstChildOfClass("Attachment")
				local v19

				if attachment then
					v19 = attachment.WorldPosition
				else
					v19 = part2.Position
				end

				v9 = v19
			else
				v9 = position
			end

			for _, part3 in model:GetDescendants() do
				if not part3:IsA("BasePart") or v4.EXCLUDE[part3.Name] then
					continue
				end

				cFramesByPart[part3] = part3.CFrame

				if part3.Name == v4.COG_NAME then
					table.insert(parts, part3)
				end
			end

			if part and part:IsA("BasePart") then
				v8 = part
			end

			v11 = model:GetAttribute(v4.FRENZY_ATTRIBUTE) == true
			connection = model:GetAttributeChangedSignal(v4.FRENZY_ATTRIBUTE):Connect(function()
				if v7 ~= model then
					return
				end

				local v19 = model:GetAttribute(v4.FRENZY_ATTRIBUTE) == true

				if v19 == v11 then
					return
				end

				v11 = v19

				if not v19 then
					return
				end

				local v20 = v9 or position

				if v20 then
					Util.Sound:Play(v4.FRENZY_ONSET_SOUND, v20, v4.FRENZY_PULSE_RANGE, 0.8, 1)
				end

				for _, emitter in model:GetDescendants() do
					if emitter:IsA("ParticleEmitter") and emitter.Name == v4.EMBER_NAME then
						emitter:Emit(v4.FRENZY_EMBER_EMIT)
					end
				end

				v10 = os.clock() + v4.SHAKE_TIME * 3
				local currentCamera = Workspace.CurrentCamera

				if currentCamera and v20 and (currentCamera.CFrame.Position - v20).Magnitude <= v4.FRENZY_PULSE_RANGE then
					Util.CameraShaker:ShakeOnce(6, 9, 0.15, 1.6)
				end
			end)
		end)
	end
end

enemies.ChildAdded:Connect(function(model2)
	if model2.Name == v4.NAME and model2:IsA("Model") then
		adoptDrill(model2) -- equivalent call inferred; original call site unknown
	end
end)
enemies.ChildRemoved:Connect(function(child2)
	if child2 == v7 then
		dropDrill() -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	local v18 = -1

	while true do
		task.wait(0.3)
		local folder = v7
		local startPosition = v9

		if not (folder and folder.Parent and startPosition) then
			continue
		end

		local currentCamera = Workspace.CurrentCamera

		if currentCamera and (currentCamera.CFrame.Position - startPosition).Magnitude > v4.RENDER_DISTANCE then
			continue
		end

		local serverTimeNow = Workspace:GetServerTimeNow()
		local v20 = math.floor(serverTimeNow / v4.METEOR_INTERVAL)

		if v20 == v18 then
			continue
		end

		local random = Random.new(v20)

		if random:NextNumber(0.5, v4.METEOR_INTERVAL - 2.5) > serverTimeNow - v20 * v4.METEOR_INTERVAL then
			continue
		end

		local v21 = not v11 and 20 or v4.FRENZY_EMBER_EMIT
		v18 = v20

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") and emitter.Name == v4.EMBER_NAME then
				emitter:Emit(v21)
			end
		end

		Util.Sound:Play(v4.METEOR_SOUND, startPosition, v4.METEOR_SOUND_RADIUS, 1.35, 0.45)
		local integer = random:NextInteger(v4.METEOR_MIN, v4.METEOR_MAX)

		if v11 then
			integer += v4.FRENZY_METEOR_BONUS
		end

		for _ = 1, integer do
			local number = random:NextNumber(-3.141592653589793, 3.141592653589793)
			local v22 = v4.METEOR_MIN_DIST + random:NextNumber() * v4.METEOR_SPREAD
			local endPosition = drillFloorPosition(
				folder,
				startPosition + Vector3.new(math.cos(number) * v22, 0, math.sin(number) * v22) + createVector(0, 10, 0)
			)
			local number2 = random:NextNumber(0, 0.4)
			local startPosition2 = startPosition
			task.delay(number2, function()
				Effect.new("Volcano"):play({
					Mode = "Shoot",
					StartPosition = startPosition2,
					EndPosition = endPosition,
					Duration = v4.METEOR_DURATION,
					Scale = v4.METEOR_SCALE,
					ArcScale = v4.METEOR_ARC,
					SimpleArc = true,
					ShakeDistance = v4.METEOR_SHAKE_DISTANCE,
					SoundRadius = v4.METEOR_SOUND_RADIUS,
					CraterAnywhere = true
				})
			end)
		end
	end
end)
task.spawn(function()
	while true do
		task.wait(v4.FRENZY_PULSE_MIN + math.random() * (v4.FRENZY_PULSE_MAX - v4.FRENZY_PULSE_MIN))
		local folder = v7
		local v18 = v9 or position

		if not (v11 and folder and folder.Parent and v18) then
			continue
		end

		local currentCamera = Workspace.CurrentCamera

		if not currentCamera or (currentCamera.CFrame.Position - v18).Magnitude > v4.FRENZY_PULSE_RANGE then
			continue
		end

		Util.CameraShaker:ShakeOnce(2.5 + math.random() * 2, 7, 0.12, 1.1)

		if math.random() < 0.5 then
			Util.Sound:Play(v4.FRENZY_PULSE_SOUND, v18, v4.FRENZY_PULSE_RANGE, 0.75, 0.35)
		end

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") and emitter.Name == v4.SMOKE_NAME then
				emitter:Emit(v4.FRENZY_SMOKE_EMIT)
			end
		end
	end
end)
local v18 = false

local function drillPanShot(vector2: Vector3, position2: Vector3)
	local vector3 = Vector3.new(position2.X - vector2.X, 0, position2.Z - vector2.Z)
	local vector4 = not (vector3.Magnitude > 0.001) and createVector(0, 0, 1) or vector3.Unit
	local cross = vector4:Cross(createVector(0, 1, 0))
	local v19 = vector2 + vector4 * v4.APPROACH_PAN_DIST + createVector(0, 1, 0) * v4.APPROACH_PAN_UP
	local v20 = vector2 + createVector(0, 1, 0) * v4.APPROACH_LOOK_UP
	local v21 = cross * v4.APPROACH_SLIDE
	return function(p: number)
		local v22 = v21 * (p - 0.5)
		return v19 + v22, v20 + v22
	end
end

task.spawn(function()
	while not v18 do
		task.wait(0.4)

		if flag2 or DialogueController.Active then
			continue
		end

		local v20 = position

		if not (v7 and v7.Parent and v20 and localPlayer:GetAttribute("CurrentLocation") == clone.Location) then
			continue
		end

		local character = localPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if not humanoidRootPart then
			continue
		end

		local character2 = localPlayer.Character
		local humanoid

		if character2 then
			humanoid = character2:FindFirstChildOfClass("Humanoid")
		end

		local v21

		if humanoid == nil then
			v21 = false
		else
			v21 = humanoid.Health > 0
		end

		if not v21 or (humanoidRootPart.Position - v20).Magnitude > v4.APPROACH_RANGE then
			continue
		end

		v18 = true
		local v22 = v20
		local v23 = humanoidRootPart
		runCinematic(function(p)
			task.spawn(startLines, v4.APPROACH_LINES)
			panShot(p, v4.APPROACH_TIME, drillPanShot(v22, v23.Position))
			local v24 = os.clock() + v3.DIALOGUE_TIMEOUT

			while DialogueController.Active and os.clock() < v24 do
				local character3 = localPlayer.Character
				local humanoid2

				if character3 then
					humanoid2 = character3:FindFirstChildOfClass("Humanoid")
				end

				local v25

				if humanoid2 == nil then
					v25 = false
				else
					v25 = humanoid2.Health > 0
				end

				if not v25 then
					break
				end

				task.wait(0.1)
			end
		end)
	end
end)

local function syncMomentState()
	local v19 = localPlayer:GetAttribute(v4.DONE_ATTRIBUTE) == true

	if v19 == v14 then
		return
	end

	v14 = v19

	if v19 then
		local model2 = v7 or enemies:FindFirstChild(v4.NAME)

		if model2 and model2:IsA("Model") then
			hideDrillLocally(model2)
		end

		dropDrill() -- equivalent call inferred; original call site unknown

		if flag4 then
			task.delay(v4.ROCKS_SPAWN_DELAY, function()
				if v14 then
					spawnRocks(true)
				end
			end)
		elseif not v15 then
			if flag5 then
				return
			end

			flag5 = true
			local v20 = rocksTemplate()
			flag5 = false

			if not v20 then
				warn((`[ProspectorVision] missing {v4.ROCKS_NAME} model under the replicated {v4.MOMENT_NAME} module`))
			elseif not v15 then
				if not v14 then
					return
				end

				local clone2 = v20:Clone()
				clone2.Parent = Workspace
				v15 = clone2
			end
		end
	else
		flag4 = false
		despawnRocks() -- equivalent call inferred; original call site unknown
		showDrillLocally()
		local model2 = enemies:FindFirstChild(v4.NAME)

		if model2 and model2:IsA("Model") then
			adoptDrill(model2) -- equivalent call inferred; original call site unknown
		end
	end
end

localPlayer:GetAttributeChangedSignal(v4.DONE_ATTRIBUTE):Connect(syncMomentState)
syncMomentState()