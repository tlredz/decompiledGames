local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Audio = require(game.ReplicatedStorage.Audio)
local EffectController = require(script.EffectController)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Notification = require(game.ReplicatedStorage.Notification)
local Net = require(game.ReplicatedStorage.Modules.Net)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("WorldTeleporter"):tag("Controller"):traceback():display():build()
local WorldTeleporter = require(game.ReplicatedStorage.React.Components.WorldTeleporter)
local useDebounceRef = require(game.ReplicatedStorage.React.Hooks.useDebounceRef)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useGatewayAccess = require(game.ReplicatedStorage.React.Hooks.Player.useGatewayAccess)
local useBonusMoments = require(game.ReplicatedStorage.React.Hooks.Island.useBonusMoments)
require(script.Types)
local CONSTANTS = require(script.CONSTANTS)
local currentMap = Map.findCurrentMap()
local PRESETS = EffectController.Profiles.PRESETS
local v2 = {
	Hidden = EffectController.Profiles.copy(PRESETS.Dormant),
	Dormant = EffectController.Profiles.copy(PRESETS.Dormant),
	Active = EffectController.Profiles.copy(PRESETS.Active),
	Overcharged = EffectController.Profiles.copy(PRESETS.Overcharged)
}
local v3 = {
	RiseDamping = 0.45,
	RiseFrequency = 2.2,
	FallDamping = 1,
	FallFrequency = 2.5
}
local v4 = {
	{ "TeleporterVFX", "Base" },
	{ "TeleporterVFX", "MainBeam" },
	{ "Meshs", "FlareMesh" },
	{ "Meshs", "BeamMesh" },
	{ "Meshs", "Lines" },
	{ "Meshs", "SideMesh" },
	{ "Charge", "Center" },
	{ "Smokes" }
}

for _, v5 in v2 do
	v5.Global.Motion = table.clone(v3)
end

local v5 = nil
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

function requestAsync(p)
	return Net:RemoteFunction("WorldTeleporter"):InvokeServer(p)
end

function isInsideTeleporter(player, instance)
	local smokes = instance:FindFirstChild("Smokes")

	if not (smokes and smokes:IsA("BasePart")) then
		return false
	end

	local cFrame = smokes.CFrame
	local Y = smokes.Size.Y
	local character = player.Character

	if not character then
		return false
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return false
	end

	local v6 = math.abs(primaryPart.Position.Y - cFrame.Position.Y)

	if Y / 2 < v6 then
		return false
	end

	return not ((Vector3.new(primaryPart.Position.X, 0, primaryPart.Position.Z) - Vector3.new(
		cFrame.Position.X,
		0,
		cFrame.Position.Z
	)).Magnitude > 25)
end

function playTeleportSound(soundId: string, instance)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId

	if instance then
		sound.Parent = instance:FindFirstChild("Base") or SoundService
	else
		sound.Parent = SoundService
	end

	sound.PlayOnRemove = true
	sound:Destroy()
end

function checkIfCanUseTeleporter(player, p)
	local character = player.Character

	if not character then
		return false
	end

	local busy = character:FindFirstChild("Busy")

	if not busy or busy.Value then
		return false
	end

	return isInsideTeleporter(player, p)
end

function getEffectState(instance, p)
	if instance:GetAttribute(CONSTANTS.UNLOCKED_ATTR_KEY) ~= true then
		return "Hidden"
	end

	if not isInsideTeleporter(instance, p) then
		return "Dormant"
	end

	if instance:GetAttribute(CONSTANTS.COMPLETED_ATTR_KEY) == true then
		return "Overcharged"
	end

	return "Active"
end

function describeInstance(instance)
	if not instance then
		return "nil"
	end

	local v6 = {}

	for _, child in instance:GetChildren() do
		table.insert(v6, (`{child.Name}:{child.ClassName}`))
	end

	return (`{instance:GetFullName()} ({instance.ClassName}, parent={instance.Parent and instance.Parent:GetFullName() or "nil"}, children=[{table.concat(v6, ", ")}])`)
end

function describePlayerState(player, instance)
	local attribute = player:GetAttribute(CONSTANTS.UNLOCKED_ATTR_KEY)
	local attribute2 = player:GetAttribute(CONSTANTS.COMPLETED_ATTR_KEY)
	local character = player.Character
	local primaryPart

	if character then
		primaryPart = character.PrimaryPart
	end

	local busy

	if character then
		busy = character:FindFirstChild("Busy")
	end

	local smokes = instance:FindFirstChild("Smokes")
	local v6 = not (smokes and smokes:IsA("BasePart")) and "no trigger" or tostring(smokes.Position)
	local v7 = not primaryPart and "nil" or tostring(primaryPart.Position)
	local v8 = not (busy and busy:IsA("BoolValue")) and "no Busy value" or tostring(busy.Value)
	local insideTeleporter = isInsideTeleporter(player, instance)
	return (`{CONSTANTS.UNLOCKED_ATTR_KEY}={tostring(attribute)} ({typeof(attribute)}), {CONSTANTS.COMPLETED_ATTR_KEY}={tostring(attribute2)}, inside={insideTeleporter}, hrp={v7}, trigger={v6}, busy={v8}`)
end

function requestEffectStreaming(instance, p)
	if not workspace.StreamingEnabled then
		p.info("streaming disabled, not requesting stream around teleporter")
		return
	end

	local position = instance:GetPivot().Position
	p.info((`streaming enabled, requesting stream around {position}`))
	local success, result = pcall(function()
		Players.LocalPlayer:RequestStreamAroundAsync(position, 15)
	end)
	p.info((`stream request finished: success={success}{success and "" or `, error={result}`}`))
end

function findMissingEffectInstance(p, p2: number, p3)
	local v6 = os.clock() + p2

	for _, list in v4 do
		local child = p

		for _, childName in list do
			if child then
				child = child:WaitForChild(childName, (math.max(v6 - os.clock(), 0.05)))
			else
				child = nil
			end
		end

		local joined = table.concat(list, ".")

		if child then
			p3.trace((`found {joined} ({child.ClassName})`))
		else
			p3.info((`missing {joined}`))
			return joined
		end
	end

	return nil
end

function waitForEffectInstances(instance, callback, p)
	local lastTime = os.clock()
	p.info((`waiting for effect instances on {describeInstance(instance)}`))
	requestEffectStreaming(instance, p)
	local v6 = os.clock() + 15

	while callback() do
		local missingEffectInstance = findMissingEffectInstance(instance, 1, p)

		if not missingEffectInstance then
			p.info((`all effect instances present after {os.clock() - lastTime}s`))
			return true
		end

		p.info((`still waiting on {missingEffectInstance} after {os.clock() - lastTime}s, teleporter now {describeInstance(instance)}`))

		if not (v6 <= os.clock()) then
			continue
		end

		v6 = os.clock() + 15
		p.warn((`still waiting on {instance:GetFullName()}.{missingEffectInstance} before starting the effect`))
		warn((`[WorldTeleporter] still waiting on {instance:GetFullName()}.{missingEffectInstance} before starting the effect`))
		requestEffectStreaming(instance, p)
	end

	p.info("stopped waiting for effect instances, teleporter no longer alive")
	return false
end

function createEffectController(instance, instance2, p)
	local v6 = nil
	local lastTime = os.clock()
	local flag = true
	p.info((`creating effect controller from {instance:GetFullName()} under {instance2:GetFullName()}`))
	task.spawn(function()
		while flag do
			task.wait(5)

			if flag then
				p.info((`still creating effect controller after {os.clock() - lastTime}s`))
			end
		end
	end)
	local success, result = pcall(function()
		v6 = EffectController.fromTemplate(instance, instance2, v2.Hidden, false)
	end)
	flag = false

	if success then
		local v7 = v6

		if v7 then
			local counts = v7:GetCounts()
			p.info((`effect controller ready after {os.clock() - lastTime}s: copy={describeInstance(v7.Instance)}, meshes={counts.Meshes}, mainBeams={counts.Beams.MainBeam}, columnBeams={counts.Beams.BeamColumns}, groundRing={counts.Particles.GroundRing}, flares={counts.Particles.Flares}, topGlow={counts.Particles.TopGlow}, smoke={counts.Particles.Smoke}, debris={counts.Particles.Debris}, lights={counts.Lights}`))
		end

		return v7
	else
		p.warn((`failed to start effect controller after {os.clock() - lastTime}s: {result}`))
		warn((`[WorldTeleporter] failed to start effect controller for {instance:GetFullName()}: {result}`))
		return nil
	end
end

function runEffectStateLoop(object, instance, callback, p)
	p.info((`state loop starting on {instance:GetFullName()}`))
	local v6 = nil
	local v7 = true
	local v8 = 0

	while callback() do
		local effectState = getEffectState(Players.LocalPlayer, instance)

		if effectState ~= v6 then
			p.info((`state {tostring(v6)} -> {effectState} (instant={v7}) with {describePlayerState(Players.LocalPlayer, instance)}`))
			local v9 = effectState
			local success, result = pcall(function()
				object:SetProfile(v2[v9], v7)
				object:SetVisible(v9 ~= "Hidden")
				instance:SetAttribute("EffectState", v9)
			end)

			if success then
				p.info((`applied state {effectState}, attribute now {tostring(instance:GetAttribute("EffectState"))}`))
				v6 = effectState
			else
				p.warn((`effect state update failed, effect frozen: {result}`))
				warn((`[WorldTeleporter] effect state update failed, effect frozen: {result}`))
				return
			end
		end

		if v8 <= os.clock() then
			v8 = os.clock() + 5
			p.info((`state loop alive: state={tostring(v6)}, settled={object:IsSettled()}, {describePlayerState(Players.LocalPlayer, instance)}`))
		end

		v7 = false
		task.wait(0.1)
	end

	p.info("state loop ending, teleporter no longer alive")
end

local class = {}
class.__index = class

function class:_PromptTeleportAsync(instance, player)
	local extended = v.extend("_PromptTeleportAsync")
	extended.info((`called fn: (teleporter: {instance:GetFullName()}, player: {player})`))
	local character = player.Character

	if not character then
		extended.trace("returning blocked, no character")
		return "Blocked"
	end

	if player:HasTag("IS_MID_TELEPORT_PROMPT") then
		extended.trace("returning blocked, mid prompt")
		return "Blocked"
	end

	if player:GetAttribute(CONSTANTS.UNLOCKED_ATTR_KEY) ~= true then
		extended.trace("returning blocked, no access")
		return "Blocked"
	end

	local v6 = {
		Type = "GetLocations"
	}
	local v7 = requestAsync(v6)
	assert(v7.Type == "GetLocations", "bad response")

	if v7.WasSuccess == true then
		local locations = v7.Locations

		if RunService:IsStudio() then
			extended.trace(function()
				return "valid-locations", locations
			end)
		end

		if #locations == 0 then
			extended.trace("returning Blocked, no locations available")
			Notification.new("<Color=Red>No locations available!<Color=/>"):Display()
			return "Blocked"
		else
			extended.trace("passed initial checks, adding debounce tag")
			player:AddTag("IS_MID_TELEPORT_PROMPT")
			local connection = nil
			local renderSteppedConnection = nil
			local flag = false
			connection = CollectionService:GetInstanceRemovedSignal("IS_MID_TELEPORT_PROMPT"):Connect(function(p2)
				if p2 == player then
					if flag then
						return
					end

					flag = true
					connection:Disconnect()
					renderSteppedConnection:Disconnect()
				end
			end)
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not checkIfCanUseTeleporter(player, instance) then
					player:RemoveTag("IS_MID_TELEPORT_PROMPT")

					if flag then
						return
					end

					flag = true
					connection:Disconnect()
					renderSteppedConnection:Disconnect()
				end
			end)
			local success, result = pcall(function()
				local screenGui = Instance.new("ScreenGui")
				screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				screenGui.ScreenInsets = Enum.ScreenInsets.None
				screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
				screenGui.IgnoreGuiInset = true
				screenGui.Name = "WorldTeleporterRoot"
				screenGui.Parent = playerGui
				screenGui.DisplayOrder = 3
				screenGui.Enabled = true
				screenGui.ResetOnSpawn = false
				local v8 = Signal.new()
				local fn = nil
				local renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
					if not checkIfCanUseTeleporter(player, instance) then
						v8:Fire(nil)
					end
				end)

				local function component(_)
					local v9 = useGatewayAccess()
					local v10 = useAttribute(player, CONSTANTS.COMPLETED_ATTR_KEY) == true
					local state, setState = React.useState(true)
					local v11 = useBonusMoments()
					local v12 = React.useMemo(function()
						if not currentMap then
							return false
						end

						local isCompletedsByAddress = {}

						for _, v13 in v11 do
							isCompletedsByAddress[v13.Address] = v13.IsCompleted
						end

						for _, island in currentMap.Islands do
							if not island.BonusMoments then
								continue
							end

							for _, bonusMoment in island.BonusMoments do
								if isCompletedsByAddress[Map.getAddress(bonusMoment)] ~= true then
									return false
								end
							end
						end

						return true
					end, { v11 })
					print((`has completed others: {v12}, has completedMap: {v10}`))
					React.useEffect(function()
						fn = function()
							setState(false)
						end

						return function()
							fn = nil
						end
					end, {})
					local v13, v14 = useDebounceRef(10)
					local ref = React.useRef(false)
					React.useEffect(function()
						task.spawn(function()
							if state then
								playTeleportSound(Audio.fx["world-teleporter"]["open.ogg"])
							end
						end)
					end, { state })
					return React.createElement(WorldTeleporter, {
						IsOpen = v9 == true and state,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.85, 0.85),
						OnSelect = function(p2)
							if not state or ref.current then
								return
							end

							if table.find(locations, p2.Index.Key) then
								playTeleportSound(Audio.fx["world-teleporter"]["select.ogg"])
								v8:Fire(p2)
							else
								local name = p2.Display.Name or p2.Index.Key
								local new = Notification.new
								local v18

								if #Map.getRequiredUnlockables(p2) > 0 then
									v18 = `<Color=Red>You haven't unlocked {name} yet!<Color=/>`
								else
									v18 = `<Color=Red>No teleport destinations found at {name}!<Color=/>`
								end

								new(v18):Display()
							end
						end,
						OnPuzzleComplete = v12 == true and v10 == false and (function()
							print("on completed")
							ref.current = true

							if v13.current then
								print("debounce fail")
								return
							end

							v14()
							print("requesting complete")
							playTeleportSound(Audio.fx["world-teleporter"]["sea-completed-animation.ogg"])
							task.delay(CONSTANTS.COMPLETION_SEQUENCE.DURATION - 1, function()
								playTeleportSound(Audio.fx["world-teleporter"].vfx["charge.ogg"])
							end)
							requestAsync({
								Type = "CompleteMap"
							})
						end or nil) or nil,
						OnCelebrationComplete = v12 == true and v10 == false and (function()
							ref.current = false
						end or nil) or nil
					})
				end

				local root = ReactRoblox.createRoot(screenGui)
				root:render((ReactRoblox.createPortal(React.createElement(component), screenGui)))
				local v9 = v8:Wait()
				renderSteppedConnection2:Disconnect()

				if fn then
					fn()
					task.wait(1)
				end

				root:unmount()
				screenGui:Destroy()
				v8:Destroy()
				local trace = extended.trace
				local v11

				if v9 then
					v11 = v9.Index.Key or nil
				end

				trace((`completed selection: {v11}`))

				if not v9 then
					extended.trace("returning left as no island was selected")
					return "Left"
				end

				local _EffectController = self._EffectControllers[instance]

				if _EffectController then
					local v12 = Signal.new()
					local v13 = false
					extended.trace("playing teleport effect")
					playTeleportSound(Audio.fx["world-teleporter"].vfx["charge.ogg"])
					local v14 = _EffectController:Teleport(character, function()
						v13 = true
						v12:Fire()
					end)

					if not v13 then
						v12:Wait()
					end

					extended.trace("finished teleport effect")
					v14()
				else
					extended.warn((`no effect controller for {instance:GetFullName()}, teleporting without fx`))
				end

				local v12 = {
					Type = "TeleportTo",
					IslandKey = v9.Index.Key
				}
				extended.trace(function()
					return "sending request", v12
				end)
				local v13 = requestAsync(v12)
				assert(v13.Type == "TeleportTo", "bad response")

				if v13.WasSuccess == true then
					extended.trace("returning teleported")
					return "Teleported"
				end

				assert(v13.WasSuccess == false, "bad response")

				if v13.ErrMessage then
					Notification.new(v13.ErrMessage):Display()
				end

				extended.warn((`returning error, request "{v12.Type}" failed`))
				return "Error"
			end)
			player:RemoveTag("IS_MID_TELEPORT_PROMPT")

			if not success then
				error(result, 0)
			end

			return result
		end
	else
		assert(v7.WasSuccess == false, "bad response")
		extended.warn((`request "{v6.Type}" failed`))
		return "Blocked"
	end
end

function class:RegionEntered()
	v.info("RegionEntered()")
	self._IsPlayerOnIsland = true
end

function class:RegionLeaving()
	v.info("RegionLeaving()")
	self._IsPlayerOnIsland = false
end

local serviceLocker = ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_IsPlayerOnIsland = false,
		LoadForLocations = { "Middle Town" },
		_KnownTeleporters = {},
		_EffectControllers = {},
		_Connections = {},
		Maid = Maid.new()
	}, class)

	local function processPotentialTeleporter(model)
		local extended = v.extend("teleporter")
		extended.info((`processing potential teleporter {describeInstance(model)}`))

		if not model:IsA("Model") then
			extended.warn("why is the teleporter not a model?")
			return
		end

		if object._KnownTeleporters[model] then
			extended.info("teleporter already known, cleaning up the previous run first")
			object._KnownTeleporters[model]()
		end

		local flag = true
		local v7 = model
		local v8 = nil

		local function getIsAlive()
			return flag
		end

		local function cleanUp()
			if not flag then
				extended.info((`clean up requested again for {model.Name}, already dead`))
				return
			end

			extended.info((`removing teleporter {model.Name}: {debug.traceback("clean up called from", 2)}`))
			flag = false
			object._KnownTeleporters[model] = nil

			if v5 == model then
				extended.info("releasing header template")
				v5 = nil
			end

			local v9 = v8
			v8 = nil

			if v9 then
				extended.info((`destroying effect controller and its copy {v9.Instance:GetFullName()}`))
				object._EffectControllers[v9.Instance] = nil
				v9:Destroy()
			end
		end

		object._KnownTeleporters[model] = cleanUp

		local function onStep()
			if Players.LocalPlayer:GetAttribute(CONSTANTS.UNLOCKED_ATTR_KEY) ~= true or not checkIfCanUseTeleporter(
				Players.LocalPlayer,
				v7
			) or Players.LocalPlayer:HasTag("IS_MID_TELEPORT_PROMPT") then
				return
			end

			extended.trace("new player found, prompting teleport")
			local success, result = pcall(function()
				local _PromptTeleportAsync = object:_PromptTeleportAsync(v7, Players.LocalPlayer)
				extended.trace((`prompt returned result "{_PromptTeleportAsync}"`))
			end)
			extended.trace("finished teleport async")

			if not success then
				extended.warn((`prompt error: {result}`))
			end

			Players.LocalPlayer:RemoveTag("IS_MID_TELEPORT_PROMPT")
		end

		task.spawn(function()
			extended.info((`prompt loop starting, on island={object._IsPlayerOnIsland}`))

			while flag do
				if object._IsPlayerOnIsland then
					onStep()
					task.wait(0.2)
				else
					task.wait(5)
				end
			end

			extended.info("prompt loop ending")
		end)
		task.spawn(function()
			extended.info("effect thread starting")

			if not waitForEffectInstances(model, getIsAlive, extended) then
				extended.info("effect thread ending, instances never arrived")
				return
			end

			local parent = model.Parent

			if not (flag and parent) then
				extended.info((`effect thread ending before swap, alive={flag}, parent={describeInstance(parent)}`))
				return
			end

			local effectController = createEffectController(model, parent, extended)

			if not effectController then
				extended.info("effect thread ending, no controller")
			elseif flag then
				local instance = effectController.Instance
				v5 = model
				model.Parent = nil
				model.Destroying:Connect(function()
					extended.info("template destroyed")
					cleanUp()
				end)
				v8 = effectController
				v7 = instance
				object._EffectControllers[instance] = effectController
				instance.AncestryChanged:Connect(function()
					local isDescendant = instance:IsDescendantOf(game)
					extended.info((`copy ancestry changed, parent={instance.Parent and instance.Parent:GetFullName() or "nil"}, in game={isDescendant}`))

					if not isDescendant then
						cleanUp()
					end
				end)
				extended.info((`swapped replicated teleporter for copy {describeInstance(instance)}, template parent now {tostring(model.Parent)}`))
				runEffectStateLoop(effectController, instance, getIsAlive, extended)
			else
				extended.info("teleporter died while creating the controller, destroying it")
				effectController:Destroy()
			end
		end)
	end

	table.insert(object._Connections, CollectionService:GetInstanceAddedSignal("WORLD_TELEPORTER"):Connect(function(p)
		v.info((`tag "WORLD_TELEPORTER" added: {describeInstance(p)}`))
		processPotentialTeleporter(p)
	end))
	table.insert(
		object._Connections,
		CollectionService:GetInstanceRemovedSignal("WORLD_TELEPORTER"):Connect(function(model)
			v.info((`tag "WORLD_TELEPORTER" removed: {describeInstance(model)}, is template={model == v5}`))

			if not model:IsA("Model") or model == v5 then
				return
			end

			local _KnownTeleporter = object._KnownTeleporters[model]

			if _KnownTeleporter then
				_KnownTeleporter()
			else
				v.info("removed instance was never known")
			end
		end)
	)
	local tagged = CollectionService:GetTagged("WORLD_TELEPORTER")
	v.info((`found {#tagged} instance(s) tagged "WORLD_TELEPORTER", streaming={workspace.StreamingEnabled}, {CONSTANTS.UNLOCKED_ATTR_KEY}={tostring(Players.LocalPlayer:GetAttribute(CONSTANTS.UNLOCKED_ATTR_KEY))}`))

	for k, v7 in tagged do
		v.info((`tagged #{k}: {describeInstance(v7)}`))
		local v8 = v7
		task.spawn(function()
			processPotentialTeleporter(v8)
		end)
	end

	return object
end, function(list)
	v.info("destroying controller")

	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	for _, _KnownTeleporter in list._KnownTeleporters do
		if not _KnownTeleporter then
			continue
		end

		local v7 = _KnownTeleporter
		local success, result = pcall(function()
			v7()
		end)

		if not success then
			warn((`failed to clean up teleporter: {result}`))
		end
	end

	setmetatable(list, nil)
	table.clear(list)
end)
v.info((`module required, initialized={serviceLocker.IsInitialized}`))

if serviceLocker.IsInitialized == false then
	serviceLocker.init()
	v.info("init finished")
end

return serviceLocker