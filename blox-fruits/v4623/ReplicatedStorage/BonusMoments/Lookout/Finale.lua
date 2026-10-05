local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local Sound = require(ReplicatedStorage.Util.Sound)
local BoatPresentation = require(script.Parent.BoatPresentation)
local BlackTransition = require(script.BlackTransition)
local Deck = require(script.Deck)
local SceneBuilder = require(script.SceneBuilder)
local Timing = require(script.Timing)
require(script.Types)
local modules = {
	CharacterPresentation = require(script.Parent.CharacterPresentation),
	Observation = require(script.Parent.Observation),
	Scene = require(script.Parent.Scene),
	ChaseIntro = require(script.ChaseIntro),
	CrateSequence = require(script.CrateSequence),
	CutsceneDialogue = require(script.CutsceneDialogue),
	Props = require(script.Props)
}
local frozen = table.freeze({
	Island = "Middle Town",
	MaxShips = 16,
	DepthOffset = 10000,
	CameraDistance = 40,
	CameraHeight = 5,
	CameraLateralOffset = -24,
	CameraPanDistance = 14,
	FailureCameraPanDistance = 16,
	WaterAttribute = "LocalCinematicWaterHeight"
})
local localPlayer = Players.LocalPlayer
local count = 0
local v2 = nil
local object = setmetatable({}, {
	__mode = "k"
})
local v3 = {}
local v4 = {}

function v3.validatePayload(data)
	if typeof(data) ~= "table" or typeof(data.Ships) ~= "table" or data.Variant ~= "Success" and data.Variant ~= "Failure" then
		return nil, "the finale payload has no ship tally"
	end

	local variant = data.Variant
	local failureTemplate

	if data.FailureTemplate == "Fisherman" or data.FailureTemplate == "Doghouse" then
		failureTemplate = data.FailureTemplate
	end

	if variant == "Failure" and not failureTemplate then
		return nil, "the failure finale payload has no valid failure template"
	end

	if variant == "Success" and data.FailureTemplate ~= nil then
		return nil, "the success finale payload cannot select a failure template"
	end

	local npcTemplatesReady = data.NpcTemplatesReady == true
	local npcTemplateKey

	if typeof(data.NpcTemplateKey) == "string" and data.NpcTemplateKey ~= "" then
		npcTemplateKey = data.NpcTemplateKey
	end

	if npcTemplatesReady and not npcTemplateKey then
		return nil, "the finale payload has no NPC template key"
	end

	if variant == "Failure" and not npcTemplatesReady then
		return nil, "the failure finale NPC templates are unavailable"
	end

	if typeof(data.SequenceSeed) ~= "number" or data.SequenceSeed % 1 ~= 0 or data.SequenceSeed < 1 or data.SequenceSeed > 2147483647 then
		return nil, "the finale payload has an invalid sequence seed"
	end

	local count2 = #data.Ships

	if count2 < 1 or frozen.MaxShips < count2 then
		return nil, (`the finale payload must contain between 1 and {frozen.MaxShips} ships`)
	end

	if variant == "Failure" and count2 ~= 1 then
		return nil, "the failure finale payload must contain exactly one ship"
	end

	for k in data.Ships do
		if typeof(k) ~= "number" or k % 1 ~= 0 or k < 1 or count2 < k then
			return nil, "the finale ship tally must be a contiguous array"
		end
	end

	if typeof(data.MainShipIndex) ~= "number" or data.MainShipIndex % 1 ~= 0 or data.MainShipIndex < 1 or count2 < data.MainShipIndex then
		return nil, "the finale payload has an invalid main ship index"
	end

	local ships = {}

	for i = 1, count2 do
		local ship = data.Ships[i]

		if not BoatPresentation.validateEntry(ship, false) then
			return nil, (`finale ship {i} has invalid presentation data`)
		end

		table.insert(ships, {
			Boat = ship.Boat,
			FlagColor = ship.FlagColor,
			HullColor = ship.HullColor,
			SailColor = ship.SailColor
		})
	end

	if ships[data.MainShipIndex].Boat ~= "Brigade" then
		return nil, "the finale main ship must be a Brigade"
	end

	if variant == "Failure" and data.MainShipIndex ~= 1 then
		return nil, "the failure finale main ship index must be one"
	end

	return {
		Ships = ships,
		MainShipIndex = data.MainShipIndex,
		NpcTemplatesReady = npcTemplatesReady,
		NpcTemplateKey = npcTemplateKey,
		FailureTemplate = failureTemplate,
		SequenceSeed = data.SequenceSeed,
		Variant = variant
	}, nil
end

function v3:cleanup(flag: boolean)
	if self.Cleaned then
		return
	end

	self.Cleaned = true
	self.Cancelled = true

	for _, sound in self.Sounds do
		Sound:Kill(sound)
	end

	table.clear(self.Sounds)
	local onFinished = self.OnFinished
	self.OnFinished = nil
	modules.CutsceneDialogue.closeOwned()

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	table.clear(self.Connections)
	local camera = self.Camera
	self.Camera = nil

	if camera then
		local success, result = pcall(camera.TeleportBack, camera, self.ReturnCFrame)

		if not success then
			warn((`[Lookout] Finale camera restoration failed: {tostring(result)}`))
		end
	end

	local transition = self.Transition
	self.Transition = nil

	if self.Folder then
		self.Folder:Destroy()
		self.Folder = nil
	end

	if self.OwnsWaterHeight then
		self.OwnsWaterHeight = false
		workspace:SetAttribute(frozen.WaterAttribute, self.PreviousWaterHeight)
	end

	if transition then
		BlackTransition.destroy(transition)
	end

	if v2 == self then
		v2 = nil
	end

	object[self.Moment] = nil

	if onFinished then
		task.defer(onFinished, flag)
	end
end

function v4.cancel(p)
	local v5 = v2

	if p and v5 and v5.Moment ~= p then
		return
	end

	count += 1

	if v5 then
		v3.cleanup(v5, false)
	end
end

function v4.isActiveFor(p)
	return v2 ~= nil and v2.Moment == p
end

function v4.handleMomentComplete(p)
	local v5 = v2

	if v5 and v5.Moment == p and v5.Variant == "Success" then
		object[p] = true
	end
end

function v4.handleMomentCleanup(p)
	if object[p] then
		object[p] = nil
	else
		v4.cancel(p)
	end
end

function v3.isLive(data)
	local v5 = not (data.Cancelled or data.Cleaned)

	if v5 then
		if data.Generation == count then
			return v2 == data
		else
			return false
		end
	end

	return v5
end

function v3.wait(p, p2: number)
	local total = 0

	while total < p2 and v3.isLive(p) do
		total += RunService.Heartbeat:Wait()
	end

	return v3.isLive(p)
end

function v3.createRuntime(data)
	return {
		isLive = function()
			return v3.isLive(data)
		end,
		beginDialogue = function()
			data.DialogueBeat += 1
		end,
		currentDialogueBeat = function()
			return data.DialogueBeat
		end,
		canContinue = function()
			return v3.isLive(data)
		end,
		wait = function(p: number)
			return v3.wait(data, p)
		end,
		giveConnection = function(p)
			table.insert(data.Connections, p)
		end,
		giveSound = function(p)
			if v3.isLive(data) then
				table.insert(data.Sounds, p)
			else
				Sound:Kill(p)
			end
		end
	}
end

function v3:createBlackTransition()
	local transition, v6 = BlackTransition.create()

	if not transition then
		error(v6 or "the finale black transition failed to initialize")
	end

	self.Transition = transition
	return transition
end

function v3:run(data)
	local v5, v6 = xpcall(function()
		local resolved, v7 = modules.Scene.resolve()

		if not resolved then
			error(v7 or "the Middle Town scene is unavailable")
		end

		local cache, v8 = BoatPresentation.resolveCache()

		if not cache then
			error(v8 or "the boat display cache is unavailable")
		end

		local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace:WaitForChild("_WorldOrigin", 5)

		if not _WorldOrigin then
			error("workspace._WorldOrigin is unavailable")
		end

		if not v3.isLive(self) then
			return
		end

		local templateFolder = modules.CharacterPresentation.resolveTemplateFolder(
			data.NpcTemplatesReady == true,
			data.Variant,
			data.FailureTemplate,
			data.NpcTemplateKey
		)

		if data.NpcTemplatesReady == true and not templateFolder then
			if data.Variant == "Failure" then
				error("the failure finale NPC templates did not replicate to PlayerGui")
			end

			warn("[Lookout] Finale NPC templates did not replicate to PlayerGui; using streamed fallbacks")
		end

		if not v3.isLive(self) then
			return
		end

		local child = _WorldOrigin:FindFirstChild((`LookoutFinale_{localPlayer.UserId}`))

		if child then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = `LookoutFinale_{localPlayer.UserId}`
		folder.Parent = _WorldOrigin
		self.Folder = folder
		local v9 = resolved.Center - createVector(0, 1, 0) * frozen.DepthOffset
		self.WaterHeight = v9.Y
		self.PreviousWaterHeight = workspace:GetAttribute(frozen.WaterAttribute)
		workspace:SetAttribute(frozen.WaterAttribute, v9.Y)
		self.OwnsWaterHeight = true
		local random = Random.new(data.SequenceSeed)
		local runtime = v3.createRuntime(self)
		local camera = self.Camera or CameraController.new()
		self.Camera = camera
		local folder2 = Instance.new("Folder")
		folder2.Name = "ChaseIntro"
		folder2.Parent = folder
		pcall(function()
			runtime.giveSound(Sound:Play(data.Variant == "Success" and "MiddleTownSFX.BF_MidTown_Ship_Quiz_Success_Cutscene_01" or "MiddleTownSFX.BF_MidTown_Ship_Quiz_Failure_Cutscene_01"))
		end)
		local ship = data.Ships[data.MainShipIndex]
		local v10, v11 = modules.ChaseIntro.run(
			runtime,
			folder2,
			cache,
			camera,
			v9,
			resolved.Forward,
			resolved.Right,
			ship.SailColor,
			data.Variant,
			data.FailureTemplate,
			templateFolder
		)

		if v10 then
			if not v3.isLive(self) then
				return
			end

			local blackTransition = v3.createBlackTransition(self)
			local v12 = nil
			local v13 = nil
			local v14 = false
			task.defer(function()
				local success, result, v15 = pcall(
					SceneBuilder.build,
					folder,
					cache,
					data,
					v9,
					resolved.Forward,
					resolved.Right,
					templateFolder,
					random
				)

				if success then
					v12 = result
					v13 = v15
				else
					v13 = tostring(result)
				end

				v14 = true
			end)

			if not BlackTransition.fadeToBlack(blackTransition, runtime, Timing.Shared.BlackTransitionTime) then
				return
			end

			while not v14 and v3.isLive(self) do
				RunService.Heartbeat:Wait()
			end

			if not v3.isLive(self) then
				return
			end

			local v15 = v12

			if not v15 then
				error(v13 or "the finale scene failed to initialize")
			end

			folder2:Destroy()

			if not v3.isLive(self) then
				return
			end

			modules.Props.startFruitLanding(runtime, v15.FruitJumps)
			local v16 = resolved.Forward * frozen.CameraDistance + resolved.Right * frozen.CameraLateralOffset + createVector(
				0,
				1,
				0
			) * frozen.CameraHeight
			local v17 = v15.CameraTarget + v16
			local v18

			if data.Variant == "Failure" then
				v18 = frozen.FailureCameraPanDistance
			else
				v18 = frozen.CameraPanDistance
			end

			local v19 = v15.CameraTarget + v16.Unit * v18
			camera:TeleportTo(CFrame.lookAt(v17, v15.CameraTarget))

			if not (runtime.wait(Timing.Shared.ScenePreRevealTime) and BlackTransition.fadeFromBlack(
				blackTransition,
				runtime,
				Timing.Shared.BlackTransitionTime
			)) then
				return
			end

			BlackTransition.destroy(blackTransition)
			self.Transition = nil
			camera.Animations:AnimateTo(CFrame.lookAt(v19, v15.CameraTarget), 1, Timing.Shared.CameraPanFrequency)
			modules.CutsceneDialogue.showMarine1(runtime)
			local v20 = false
			task.spawn(function()
				if runtime.wait(Timing.Shared.Marine2DialogueDelay) then
					modules.CutsceneDialogue.showMarine2(runtime)
					v20 = true
				end
			end)

			if not Deck.animateEntrances(runtime, v15.MarineEntrances, Timing.Shared.CameraPanTime) then
				return
			end

			while not v20 and runtime.isLive() do
				RunService.Heartbeat:Wait()
			end

			if not runtime.isLive() then
				return
			end

			camera.Animations:SkipToGoal()

			if not runtime.wait(Timing.Shared.Marine2DialogueHoldTime) then
				return
			end

			if not modules.CrateSequence.run(
				runtime,
				v15.FruitCrate,
				camera,
				v15.CameraTarget,
				data.Variant,
				data.FailureTemplate,
				v15.MainActor,
				v15.MarineEntrances,
				templateFolder
			) then
				return
			end

			local v21

			if data.Variant == "Failure" then
				v21 = Timing.Failure.FinaleHoldTime
			else
				v21 = Timing.Success.FinaleHoldTime
			end

			if not runtime.wait(v21) then
				return
			end

			local blackTransition2 = v3.createBlackTransition(self)

			if not BlackTransition.fadeToBlack(blackTransition2, runtime, Timing.Shared.BlackTransitionTime) then
				return
			end

			v3.cleanup(self, true)
			return true
		else
			folder2:Destroy()

			if v3.isLive(self) then
				error(v11 or "the finale chase intro failed")
			end
		end
	end, debug.traceback)

	if not v5 then
		warn((`[Lookout] Finale cutscene failed: {tostring(v6)}`))
	end

	if not self.Cleaned then
		v3.cleanup(self, false)
	end
end

function v4.play(moment, p2, onFinished)
	local v5, v6 = v3.validatePayload(p2)

	if not v5 then
		return false, v6
	end

	v4.cancel(nil)
	local v7 = modules.Observation.takeCamera(moment)
	modules.Observation.cancel(nil)

	if v5.Variant == "Success" then
		object[moment] = true
	end

	local v8 = {
		Moment = moment,
		Variant = v5.Variant,
		Generation = count,
		Folder = nil,
		Camera = 0,
		Transition = nil,
		ReturnCFrame = 0,
		OnFinished = 0,
		WaterHeight = 0,
		PreviousWaterHeight = nil,
		OwnsWaterHeight = false,
		Connections = 0,
		Sounds = 0,
		DialogueBeat = 1,
		Cancelled = false,
		Cleaned = false
	}
	local camera

	if v7 then
		camera = v7.Camera
	end

	v8.Camera = camera
	local returnCFrame

	if v7 then
		returnCFrame = v7.ReturnCFrame
	else
		returnCFrame = workspace.CurrentCamera.CFrame
	end

	v8.ReturnCFrame = returnCFrame
	v8.OnFinished = onFinished
	v8.Connections = {}
	v8.Sounds = {}
	v2 = v8

	local function cancelThisFinale()
		if v2 == v8 then
			v4.cancel(moment)
		end
	end

	table.insert(v8.Connections, localPlayer.CharacterAdded:Connect(cancelThisFinale))
	table.insert(v8.Connections, localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(function()
		if localPlayer:GetAttribute("CurrentLocation") ~= frozen.Island and v2 == v8 then
			v4.cancel(moment)
		end
	end))
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		table.insert(v8.Connections, humanoid.Died:Connect(cancelThisFinale))
	end

	task.spawn(v3.run, v8, v5)
	return true, nil
end

return table.freeze(v4)