local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HeadlessPlayback = {}
local v = {
	"Effects",
	"Hitboxes",
	"Movement",
	"Status",
	"Utility",
	"General",
	"Flow",
	"Combat",
	"Visual",
	"Audio"
}
local v2 = {}
local flag = false

local function _ensureClientSharedHelpers()
	if flag or type(shared) ~= "table" then
		return
	end

	local customMoveVFX = ReplicatedStorage:FindFirstChild("CustomMoveVFX") or ReplicatedStorage:WaitForChild(
		"CustomMoveVFX",
		10
	)
	local moveEditorCli = customMoveVFX and (customMoveVFX:FindFirstChild("MoveEditorCli") or customMoveVFX:WaitForChild(
		"MoveEditorCli",
		10
	))
	local timelineManager = moveEditorCli and (moveEditorCli:FindFirstChild("TimelineManager") or moveEditorCli:WaitForChild(
		"TimelineManager",
		10
	))

	if not timelineManager then
		return
	end

	local v3 = shared.timelinecores ~= nil
	local timelineCoreHelpers = shared.timelinecores == nil and timelineManager:FindFirstChild("TimelineCoreHelpers")

	if timelineCoreHelpers then
		shared.timelinecores = timelineCoreHelpers
		pcall(require, timelineCoreHelpers)
	end

	local particleCompositePresetRuntime = shared.ParticleCompositePresetRuntime == nil and timelineManager:FindFirstChild("ParticleCompositePresetRuntime")

	if particleCompositePresetRuntime then
		shared.ParticleCompositePresetRuntime = particleCompositePresetRuntime
	end

	local emitterSpecCodec = shared.EmitterSpecCodec == nil and timelineManager:FindFirstChild("EmitterSpecCodec")

	if emitterSpecCodec then
		shared.EmitterSpecCodec = emitterSpecCodec
	end

	local customAnimCutsceneHelpers = timelineManager:FindFirstChild("CustomAnimCutsceneHelpers")

	if customAnimCutsceneHelpers then
		shared.CutsceneHelper = shared.CutsceneHelper or customAnimCutsceneHelpers
		shared.CustomAnimCutsceneHelpers = shared.CustomAnimCutsceneHelpers or customAnimCutsceneHelpers
	end

	local timelineEntryLocalAnimRuntime = timelineManager:FindFirstChild("TimelineEntryLocalAnimRuntime")

	if timelineEntryLocalAnimRuntime and shared.TimelineEntryLocalAnimRuntime == nil then
		shared.TimelineEntryLocalAnimRuntime = timelineEntryLocalAnimRuntime
	end

	for _, childName in ipairs({
		"TimelineEntryLocalAnimPartBridge",
		"TimelineEntryLocalAnimParticleBridge",
		"TimelineEntryLocalAnimPresetMeshBridge"
	}) do
		local child = moveEditorCli:FindFirstChild(childName)

		if child and shared[childName] == nil then
			shared[childName] = child
		end
	end

	if shared.timelinecores ~= nil then
		flag = true

		if not v3 then
			for k, v4 in pairs(v2) do
				if v4 == false then
					v2[k] = nil
				end
			end
		end
	end
end

local moveEditorGeneratedParticleRegistry = nil

local function _getGeneratedRegistry()
	if type(moveEditorGeneratedParticleRegistry) == "table" then
		return moveEditorGeneratedParticleRegistry
	end

	if type(shared) == "table" and type(shared.MoveEditorGeneratedParticleRegistry) == "table" then
		moveEditorGeneratedParticleRegistry = shared.MoveEditorGeneratedParticleRegistry
		return moveEditorGeneratedParticleRegistry
	end

	local customMoveVFX = ReplicatedStorage:FindFirstChild("CustomMoveVFX")
	local moveEditorCli = customMoveVFX and customMoveVFX:FindFirstChild("MoveEditorCli")
	local assetsManager = moveEditorCli and moveEditorCli:FindFirstChild("AssetsManager")
	local generatedParticleRegistry = assetsManager and assetsManager:FindFirstChild("GeneratedParticleRegistry")

	if not generatedParticleRegistry and customMoveVFX then
		generatedParticleRegistry = customMoveVFX:FindFirstChild("GeneratedParticleRegistry", true)
	end

	if generatedParticleRegistry and generatedParticleRegistry:IsA("ModuleScript") then
		local success, result = pcall(require, generatedParticleRegistry)

		if success and type(result) == "table" then
			moveEditorGeneratedParticleRegistry = result
			return moveEditorGeneratedParticleRegistry
		end
	end

	return nil
end

local v3 = {}

local function _prewarmGeneratedParticles(p)
	if type(p) ~= "table" or type(p.Data) ~= "table" then
		return
	end

	local v4 = _getGeneratedRegistry()

	if not v4 or type(v4.registerEmitterFromEncodedSnapshot) ~= "function" then
		return
	end

	local getEmitterById = v4.getEmitterById
	local count = 0
	local count2 = 0

	for _, v5 in ipairs(p.Data) do
		if not (type(v5) == "table" and v5.EventType == "Particle" and type(v5.Properties) == "table") then
			continue
		end

		local properties = v5.Properties
		local __GeneratedParticleSourceSnapshot = properties.__GeneratedParticleSourceSnapshot

		if type(__GeneratedParticleSourceSnapshot) == "string" then
			__GeneratedParticleSourceSnapshot = __GeneratedParticleSourceSnapshot:gsub("^%s+", ""):gsub("%s+$", "")
		end

		if not (type(__GeneratedParticleSourceSnapshot) == "string" and #__GeneratedParticleSourceSnapshot > 0) then
			continue
		end

		local generatedParticleId = v3[__GeneratedParticleSourceSnapshot]
		local v7

		if generatedParticleId and type(getEmitterById) == "function" then
			v7 = select(1, getEmitterById(generatedParticleId)) ~= nil
		else
			v7 = false
		end

		if generatedParticleId and v7 then
			properties.__GeneratedParticleId = generatedParticleId
			count += 1
		else
			local __GeneratedParticleDisplayName = properties.__GeneratedParticleDisplayName or properties.Name or properties.ParticleName or "Generated Particle"
			local success, result, v8 = pcall(
				v4.registerEmitterFromEncodedSnapshot,
				__GeneratedParticleSourceSnapshot,
				__GeneratedParticleDisplayName
			)

			if success and type(result) == "string" and result ~= "" then
				v3[__GeneratedParticleSourceSnapshot] = result
				properties.__GeneratedParticleId = result

				if typeof(v8) == "Instance" and properties.__GeneratedParticleDisplayName == nil then
					properties.__GeneratedParticleDisplayName = v8.Name
				end

				count2 += 1
			end
		end
	end

	if not (count2 > 0) then
		local _ = count > 0
	end
end

local v4 = nil
local v5 = nil
local propertyDefaults = nil
local v6 = {}

local function _getCompositeDeps()
	local customMoveVFX = ReplicatedStorage:FindFirstChild("CustomMoveVFX")
	local moveEditorCli = customMoveVFX and customMoveVFX:FindFirstChild("MoveEditorCli")
	local customCompositePresetSupport = (not v4 and moveEditorCli and true or false) and moveEditorCli:FindFirstChild(
		"CustomCompositePresetSupport",
		true
	)

	if customCompositePresetSupport then
		local success, result = pcall(require, customCompositePresetSupport)

		if success and type(result) == "table" then
			v4 = result
		end
	end

	local customVfxAssetCodec = not v5 and (type(shared) == "table" and typeof(shared.CustomVfxAssetCodec) == "Instance" and shared.CustomVfxAssetCodec or moveEditorCli and moveEditorCli:FindFirstChild(
		"CustomVfxAssetCodec",
		true
	))

	if customVfxAssetCodec then
		local success, result = pcall(require, customVfxAssetCodec)

		if success and type(result) == "table" then
			v5 = result
		end
	end

	if propertyDefaults ~= nil then
		return v4, v5
	end

	local eventTypes = ReplicatedStorage:FindFirstChild("EventTypes")
	local effects = eventTypes and eventTypes:FindFirstChild("Effects")
	local particle = effects and effects:FindFirstChild("Particle")

	if particle then
		local success, result = pcall(require, particle)

		if success and type(result) == "table" then
			propertyDefaults = result.PropertyDefaults or false
		end
	end

	return v4, v5
end

local function _prewarmCompositePresets(p)
	if type(p) ~= "table" or type(p.Data) ~= "table" then
		return
	end

	local v7, v8 = _getCompositeDeps()
	local assetTemplates = ReplicatedStorage:FindFirstChild("AssetTemplates")

	if not v7 or type(v7.materializePayloadFromPropertyValue) ~= "function" or (not v8 or type(v8.decode) ~= "function") then
		return
	end

	if not assetTemplates then
		return
	end

	local splitDeepClone = nil

	if type(shared) == "table" and typeof(shared.timelinecores) == "Instance" then
		local success, timelinecores = pcall(require, shared.timelinecores)

		if success and type(timelinecores) == "table" then
			splitDeepClone = timelinecores.splitDeepClone
		end
	end

	local v9 = type(v7.getRootFolderName) ~= "function" and "MoveEditorCustomPresetAttachments" or v7.getRootFolderName() or "MoveEditorCustomPresetAttachments"
	local child = assetTemplates:FindFirstChild(v9)
	local defaultProps

	if propertyDefaults ~= false then
		defaultProps = propertyDefaults or nil
	end

	local count = 0
	local count2 = 0
	local count3 = 0
	local count4 = 0

	for _, v11 in ipairs(p.Data) do
		if not (type(v11) == "table" and v11.EventType == "Particle" and type(v11.Properties) == "table") then
			continue
		end

		count += 1
		local properties = v11.Properties
		local presetName = properties.PresetName
		local __MoveEditorCompositePresetPayload = properties.__MoveEditorCompositePresetPayload
		local v12

		if type(__MoveEditorCompositePresetPayload) == "string" then
			v12 = #__MoveEditorCompositePresetPayload > 0
		else
			v12 = false
		end

		local __DeepSearchSourcePath = properties.__DeepSearchSourcePath
		local v13

		if type(__DeepSearchSourcePath) == "string" then
			v13 = #__DeepSearchSourcePath > 0
		else
			v13 = false
		end

		if not (type(presetName) == "string" and presetName ~= "" and (v12 or v13)) then
			continue
		end

		count2 += 1
		local v14 = v6[presetName] or child and child:FindFirstChild(presetName) ~= nil

		if v14 then
			count3 += 1
		end

		if v14 then
			continue
		end

		local v15 = {
			warnDiag = function() end,
			encodeProps = v8.encode,
			decodeProps = function(p2, p3)
				return v8.decode(p2, splitDeepClone, p3)
			end,
			defaultProps = defaultProps,
			assetTemplates = assetTemplates,
			displayName = properties.Name or properties.ParticleName or presetName,
			markRuntimeRoot = function() end
		}
		local success, v16

		if v12 then
			local result, v17
			success, result, v16, v17 = pcall(
				v7.materializePayloadFromPropertyValue,
				presetName,
				presetName,
				__MoveEditorCompositePresetPayload,
				v15
			)
		elseif type(v7.resolveSourceInstanceByPath) == "function" and type(v7.materializeFromSourceInstance) == "function" then
			local sourceInstanceByPath = v7.resolveSourceInstanceByPath(__DeepSearchSourcePath)

			if sourceInstanceByPath then
				local result, v17
				success, result, v16, v17 = pcall(
					v7.materializeFromSourceInstance,
					presetName,
					presetName,
					sourceInstanceByPath,
					v15
				)
			else
				local _ = "source_unresolved:" .. tostring(__DeepSearchSourcePath):sub(1, 48)
				success = true
				v16 = false
			end
		else
			success = true
			v16 = false
		end

		if not (success and v16 == true) then
			continue
		end

		v6[presetName] = true
		child = child or assetTemplates:FindFirstChild(v9)
		count4 += 1
	end
end

local function resolveHandler(eventType, eventCategory)
	local v7 = tostring(eventType)

	if v2[v7] ~= nil then
		return v2[v7] or nil
	end

	local eventTypes = ReplicatedStorage:FindFirstChild("EventTypes")

	if not eventTypes then
		return nil
	end

	local moduleScript = nil

	if type(eventCategory) == "string" and eventCategory ~= "" then
		local child = eventTypes:FindFirstChild(eventCategory)

		if child then
			moduleScript = child:FindFirstChild(eventType)
		end
	end

	if not moduleScript then
		for _, childName in ipairs(v) do
			local child = eventTypes:FindFirstChild(childName)

			if not child then
				continue
			end

			moduleScript = child:FindFirstChild(eventType)

			if moduleScript and moduleScript:IsA("ModuleScript") then
				break
			else
				moduleScript = nil
			end
		end
	end

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		v2[v7] = false
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if not success or type(result) ~= "table" then
		return nil
	end

	v2[v7] = result
	return result
end

local v7 = {}

local function eventBranch(p)
	local branch = p.Branch

	if (branch == nil or branch == "") and type(p.Properties) == "table" then
		branch = p.Properties._branch
	end

	if type(branch) == "string" and branch ~= "" then
		return branch
	end

	return nil
end

local v8 = {
	Burn = true,
	Dismantle = true,
	Disintegrate = true,
	Shatter = true
}
local v9 = nil

local function getcoresforgate()
	if type(v9) == "table" then
		return v9
	end

	if type(shared) ~= "table" or typeof(shared.timelinecores) ~= "Instance" then
		return nil
	end

	local success, timelinecores = pcall(require, shared.timelinecores)

	if success and type(timelinecores) == "table" then
		v9 = timelinecores
		return timelinecores
	end

	return nil
end

local v10 = {
	["Has Victim"] = true,
	["No Victim"] = true,
	["UserHP Below"] = true,
	["UserHP Above"] = true,
	["VictimHP Below"] = true,
	["VictimHP Above"] = true,
	Finisher = true,
	["User Has IFrames"] = true,
	["User In Awakening"] = true,
	["User Moving Direction"] = true,
	["User Jumping"] = true,
	["User Falling"] = true,
	["User Has Effect"] = true,
	["Distance Below"] = true,
	["Distance Above"] = true,
	["User Airborne"] = true,
	["User Grounded"] = true,
	["Victim Airborne"] = true,
	["Victim Grounded"] = true,
	["User Ragdoll"] = true,
	["User Ragdolled"] = true,
	["Victim Ragdolled"] = true,
	["User Blocking"] = true,
	["Victim Blocking"] = true,
	["User Stunned"] = true,
	["Victim Stunned"] = true,
	["User Speed Above"] = true,
	["User Speed Below"] = true,
	["Victim Speed Above"] = true,
	["Victim Speed Below"] = true,
	["If Hit Behind"] = true,
	["User Facing Victim"] = true,
	["Victim Facing User"] = true,
	["User Has Accessory"] = true,
	["Victim Has Accessory"] = true,
	["User Has Attribute"] = true,
	["Victim Has Attribute"] = true
}

local function resolvegatevictim(p)
	if type(p) ~= "table" then
		return nil
	end

	local model = rawget(p, "PrimaryVictim") or rawget(p, "LastVictim")

	if typeof(model) == "Instance" and model:IsA("Model") and model.Parent then
		return model
	end

	local v11 = rawget(p, "Victims")

	if type(v11) == "table" then
		for model2 in pairs(v11) do
			if typeof(model2) == "Instance" and model2:IsA("Model") and model2.Parent then
				return model2
			end
		end
	end

	return nil
end

local function shouldrenderunderconditions(data, data2, caster, p, p2)
	if type(data) ~= "table" or type(data.evaluateEventFireConditions) ~= "function" or type(data.readEventFireConditions) ~= "function" then
		return true
	end

	local properties = data2.Properties

	if type(properties) ~= "table" then
		return true
	end

	local eventFireConditions = data.readEventFireConditions(properties)

	if type(eventFireConditions) ~= "table" or eventFireConditions.Enabled ~= true then
		return true
	end

	for _, v11 in ipairs(eventFireConditions.Conditions or {}) do
		local condition = v11.Condition

		if type(data.normalizeEventFireCondition) == "function" then
			condition = data.normalizeEventFireCondition(condition)
		end

		if condition and condition ~= "None" and v10[condition] ~= true then
			return true
		end
	end

	local eventFireConditions2 = data.evaluateEventFireConditions(data2, caster, p, p2, {
		WarnPrefix = "[HeadlessConditions]"
	})

	if eventFireConditions2 ~= true then
		local v11 = "headless skipped this block because a fire condition failed: " .. tostring(data2.EventType)
		warn(v11)
	end

	return eventFireConditions2 == true
end

local function fireEvent(data, data2, p)
	if not (data.alive and data.caster.Parent) then
		return
	end

	local _branch = data2.Properties and data2.Properties._branch or data2.Branch or ""

	if data.deactivatedBranches and data.deactivatedBranches[_branch] or data2.EventCategory ~= "Effects" or v8[data2.EventType] then
		return
	end

	local handler = resolveHandler(data2.EventType, data2.EventCategory)

	if not (handler and type(handler.onLivePlay) == "function") then
		return
	end

	local v11 = p or data.moveContext
	local properties = data2.Properties
	local v12 = (type(properties) ~= "table" or type(properties.BurstCount) ~= "number") and 1 or math.floor(properties.BurstCount) or 1
	local v13 = (type(properties) ~= "table" or type(properties.BurstInterval) ~= "number") and 0.1 or properties.BurstInterval or 0.1
	local v14 = (type(properties) ~= "table" or type(properties.BurstDelay) ~= "number") and 0 or properties.BurstDelay or 0
	local v15 = v12 < 1 and 1 or v12
	local v16 = v13 < 0 and 0 or v13
	local v17 = v14 < 0 and 0 or v14

	local function _emitOnce(burstI, burstN)
		if not (data.alive and data.caster.Parent) then
			return
		end

		if type(properties) == "table" then
			properties._burstI = burstI
			properties._burstN = burstN
		end

		local humanoidRootPart = data.caster and (data.caster:FindFirstChild("HumanoidRootPart") or data.caster.PrimaryPart)

		if humanoidRootPart then
			v11.StartRootCFrame = humanoidRootPart.CFrame
		end

		local __LiveAnchorModel = typeof(v11.__LiveAnchorModel) == "Instance" and v11.__LiveAnchorModel:IsA("Model") and v11.__LiveAnchorModel.Parent and v11.__LiveAnchorModel or nil
		local humanoidRootPart2 = __LiveAnchorModel and (__LiveAnchorModel:FindFirstChild("HumanoidRootPart") or __LiveAnchorModel.PrimaryPart)

		if humanoidRootPart2 then
			v11.CollisionPosition = humanoidRootPart2.Position
		end

		local __CMVFXMoveBind = data.caster:FindFirstChild("__CMVFXMoveBind")
		local __CMVFXVictimTargets = __CMVFXMoveBind and __CMVFXMoveBind:GetAttribute("RunToken") == data.runToken and __CMVFXMoveBind:FindFirstChild("__CMVFXVictimTargets")

		if __CMVFXVictimTargets then
			local victims = v11.Victims

			if type(victims) ~= "table" then
				victims = {}
				v11.Victims = victims
			end

			local v18 = -1
			local primaryVictim = nil

			for _, objectValue in ipairs(__CMVFXVictimTargets:GetChildren()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				local value = objectValue.Value

				if not (typeof(value) == "Instance" and value:IsA("Model") and value.Parent) then
					continue
				end

				victims[value] = true
				local hitOrder = objectValue:GetAttribute("HitOrder") or 0

				if not (v18 < hitOrder) then
					continue
				end

				primaryVictim = value
				v18 = hitOrder
			end

			if primaryVictim and (typeof(v11.PrimaryVictim) ~= "Instance" or not v11.PrimaryVictim.Parent) then
				v11.PrimaryVictim = primaryVictim
			end
		end

		if not (data2.Properties and data2.Properties._branch) then
			local _ = data2.Branch
		end

		local v18 = resolvegatevictim(v11)
		local v19 = getcoresforgate()

		if v19 and not shouldrenderunderconditions(v19, data2, data.caster, v18, v11) then
			return
		end

		local v20

		if v19 and type(v19.beginResolvedEventBlockVariantProperties) == "function" then
			v20 = v19.beginResolvedEventBlockVariantProperties(data2, data.caster, v18, v11, {
				WarnPrefix = "[HeadlessVariants]"
			})

			if type(v20) == "function" then
				local v21 = "headless applied a variant override to this block: " .. tostring(data2.EventType)
				warn(v21)
			end
		end

		local lastTime = os.clock()
		local _, _ = pcall(handler.onLivePlay, data.caster, data2, v11)

		if type(v20) == "function" then
			v20()
		end

		local _ = (os.clock() - lastTime) * 1000 > 8
	end

	if v15 <= 1 or handler.Gated then
		_emitOnce(nil, nil)
		return
	end

	local thread = task.spawn(function()
		if v17 > 0 then
			task.wait(v17 / data.tempo)
		end

		for i = 1, v15 do
			if data.alive and data.caster.Parent then
				_emitOnce(i, v15)

				if i < v15 and v16 > 0 then
					task.wait(v16 / data.tempo)
				end
			else
				break
			end
		end

		if type(properties) == "table" then
			properties._burstI = nil
			properties._burstN = nil
		end
	end)
	table.insert(data.threads, thread)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _rootPos(model)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return nil
	end

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position or nil
end

local function buildBranchCtx(data, data2, activeBranch)
	local moveContext = data.moveContext
	local result = {}

	for k, v11 in pairs(moveContext) do
		result[k] = v11
	end

	result._parentMoveContext = moveContext
	result.ActiveBranch = activeBranch
	local projectileVfxId

	if data2 then
		projectileVfxId = data2.ProjectileVfxId or nil
	end

	result.ProjectileVfxId = projectileVfxId
	local forcedCollisionPosition = data2 and data2.ForcedCollisionPosition
	local v12

	if data2 then
		if data2.IsProjectile == true and data2.IsExplosion ~= true then
			v12 = typeof(forcedCollisionPosition) ~= "Vector3"
		else
			v12 = false
		end
	else
		v12 = data2
	end

	local v13 = data2 and data2.IsExplosion == true and data2.IsProjectile == true and true or false
	local v14 = typeof(forcedCollisionPosition) == "Vector3" or v13
	local victim = data2 and data2.Victim or moveContext.PrimaryVictim
	local liveAnchorModel

	if typeof(victim) == "Instance" and victim:IsA("Model") and victim then
		liveAnchorModel = victim
	end

	if v12 then
		result.IsExplosion = false
		result.ProjectileStateKey = data2.ProjectileStateKey
		result.__ProjectileFollowBranch = true
	elseif v14 then
		result.IsExplosion = true

		if typeof(forcedCollisionPosition) == "Vector3" then
			result.CollisionPosition = forcedCollisionPosition
		else
			local collisionPosition = _rootPos(victim) -- equivalent call inferred; original call site unknown

			if not collisionPosition then
				local v17 = _rootPos(data.caster) -- equivalent call inferred; original call site unknown
				collisionPosition = v17 or createVector(0, 0, 0)
			end

			result.CollisionPosition = collisionPosition
		end

		result.__LiveAnchorModel = nil
	else
		result.IsExplosion = false
		result.__LiveAnchorModel = liveAnchorModel
	end

	if data2 and data2.Victim and typeof(data2.Victim) == "Instance" and data2.Victim:IsA("Model") then
		result.PrimaryVictim = data2.Victim
		result.AllVictims = { data2.Victim }
	end

	return result
end

local function scheduleEvents(data, list, value, p, p2, value2)
	if not list or #list == 0 then
		return
	end

	local v11

	if not (value2 == nil or value2 == "") then
		v11 = buildBranchCtx(data, p2, value2) or nil
	end

	for _, v12 in ipairs(list) do
		if v11 and typeof(v11.CollisionPosition) == "Vector3" then
			local v13 = {}

			for k, v14 in pairs(v12) do
				v13[k] = v14
			end

			if type(v12.Data) == "table" then
				local v14 = {}

				for k, v15 in pairs(v12.Data) do
					v14[k] = v15
				end

				v13.Data = v14
			end

			v12 = v13
		end

		local v13 = math.max(
			0,
			p + ((tonumber(v12.Time) or 0) - (value or 0)) / data.tempo - Workspace:GetServerTimeNow()
		)

		if v11 and typeof(v11.CollisionPosition) == "Vector3" then
			if type(v12.Data) ~= "table" then
				v12.Data = {}
			end

			v12.Data.__ForcedCollisionPosition = v11.CollisionPosition

			if p2 and p2.ProxyCF then
				v12.Data.__ForcedCollisionCF = p2.ProxyCF
			end
		elseif v11 and type(v12.Data) == "table" then
			v12.Data.__ForcedCollisionPosition = nil
			v12.Data.__ForcedCollisionCF = nil
		end

		if v13 <= 0.005 then
			task.spawn(fireEvent, data, v12, v11)
		else
			local thread = task.delay(v13, fireEvent, data, v12, v11)
			table.insert(data.threads, thread)

			if data.branchThreads then
				local v14 = value2 or ""
				local threads = data.branchThreads[v14]

				if not threads then
					threads = {}
					data.branchThreads[v14] = threads
				end

				table.insert(threads, thread)
			end
		end
	end
end

local function splitByBranch(data)
	local result = {}
	local result2 = {}

	for _, v11 in ipairs(data) do
		if type(v11) ~= "table" then
			continue
		end

		local branch = v11.Branch

		if (branch == nil or branch == "") and type(v11.Properties) == "table" then
			branch = v11.Properties._branch
		end

		if type(branch) ~= "string" or branch == "" then
			branch = nil
		end

		if branch == nil then
			table.insert(result2, v11)
		else
			local v12 = result[branch]

			if not v12 then
				v12 = {}
				result[branch] = v12
			end

			table.insert(v12, v11)
		end
	end

	return result2, result
end

function HeadlessPlayback.start(p, model, primaryVictim, p3, p4, serverTimeNow, p5)
	if type(p) ~= "table" or type(p.Data) ~= "table" then
		return
	end

	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return
	end

	_ensureClientSharedHelpers()
	_prewarmGeneratedParticles(p)
	_prewarmCompositePresets(p)
	local v11 = tonumber(p3) or 1
	local v12 = v11 <= 0 and 1 or v11

	if type(serverTimeNow) ~= "number" then
		serverTimeNow = Workspace:GetServerTimeNow()
	end

	local v13 = tostring(p5 or "headless_" .. tostring((math.floor(os.clock() * 1000))))

	if v7[v13] then
		HeadlessPlayback.stop(v13, true)
	end

	local folder = Instance.new("Folder")
	folder.Name = "__cmvfxrun_" .. v13
	folder.Parent = Workspace.Thrown
	local defaultEvents, branchEvents = splitByBranch(p.Data)
	local _ = Players.LocalPlayer
	local count = 0

	for _, v16 in ipairs(p.Data) do
		if not (type(v16) == "table" and tostring(v16.EventCategory) == "Effects") then
			continue
		end

		count += 1
	end

	local moveContext = {
		__VfxContainer = folder,
		__VfxCancels = {},
		MoveName = type(p4) ~= "table" and "<headless>" or p4.MoveName or "<headless>",
		MoveTempoScale = v12,
		MoveEffectIntensity = type(p4) ~= "table" and 1 or tonumber(p4.EffectIntensity) or 1,
		PrimaryVictim = primaryVictim,
		AllVictims = primaryVictim and { primaryVictim } or {},
		__MoveRunToken = v13,
		Cancelled = false,
		Intcheck = {
			interrupted = false,
			_closed = false
		},
		Add = function(p6)
			return p6
		end,
		__MoveEditorReplicatedLiveParticle = true,
		StartRootCFrame = 0,
		__EntryLocalAnimPayload = 0
	}
	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	moveContext.StartRootCFrame = humanoidRootPart and humanoidRootPart.CFrame or nil
	local metadata

	if type(p.Metadata) == "table" then
		metadata = p.Metadata or nil
	end

	local entryLocalAnimV1 = metadata and metadata.EntryLocalAnimV1 or nil

	if type(entryLocalAnimV1) ~= "string" or entryLocalAnimV1 == "" or not entryLocalAnimV1 then
		entryLocalAnimV1 = nil
	end

	moveContext.__EntryLocalAnimPayload = entryLocalAnimV1
	local v17 = {
		container = folder,
		caster = model,
		tempo = v12,
		serverT0 = serverTimeNow,
		runToken = v13,
		defaultEvents = defaultEvents,
		branchEvents = branchEvents,
		moveContext = moveContext,
		threads = {},
		alive = true,
		activatedBranches = {},
		branchThreads = {},
		deactivatedBranches = {}
	}
	v7[v13] = v17
	local v18 = {}

	for k, v19 in pairs(branchEvents) do
		table.insert(v18, k .. "(" .. #v19 .. ")")
	end

	scheduleEvents(v17, defaultEvents, 0, serverTimeNow, nil, "")
	local v19 = 0

	for _, v20 in ipairs(p.Data) do
		local v21 = (tonumber(v20.Time) or 0) + (tonumber(v20.Duration) or 0)

		if v19 < v21 then
			v19 = v21
		end
	end

	task.delay(v19 / v12 + 30, function()
		if v7[v13] == v17 then
			HeadlessPlayback.stop(v13)
		end
	end)
end

local function deactivateClientBranch(state, p)
	if not state then
		return
	end

	state.deactivatedBranches = state.deactivatedBranches or {}

	if state.deactivatedBranches[p] then
		return
	end

	state.deactivatedBranches[p] = true
	local v11 = state.branchThreads and state.branchThreads[p]
	local count = 0

	if type(v11) == "table" then
		for _, v12 in ipairs(v11) do
			pcall(task.cancel, v12)
			count += 1
		end

		state.branchThreads[p] = nil
	end
end

function HeadlessPlayback.activateBranch(p, activeBranch, p3, p4, value, list, p5)
	local v11 = v7[tostring(p)]

	if not (v11 and v11.alive) then
		return
	end

	if type(list) == "table" then
		local v12 = {
			[activeBranch] = true
		}

		for _, v13 in ipairs(list) do
			v12[v13] = true
		end

		local v13 = {}

		for k in pairs(v12) do
			v13[#v13 + 1] = k == "" and "<default>" or k
		end

		if not v12[""] then
			deactivateClientBranch(v11, "")
		end

		for k in pairs(v11.activatedBranches) do
			if not v12[k] then
				deactivateClientBranch(v11, k)
			end
		end
	end

	local branchEvent = v11.branchEvents[activeBranch]

	if not branchEvent or #branchEvent == 0 then
		return
	end

	if typeof(p4 and p4.ForcedCollisionPosition) == "Vector3" or p4 and p4.IsExplosion == true then
		local v12 = activeBranch .. "#" .. tostring(p5 or p3)
		v11.activatedExplodeKeys = v11.activatedExplodeKeys or {}

		if v11.activatedExplodeKeys[v12] then
			return
		else
			v11.activatedExplodeKeys[v12] = true
		end
	else
		local v12 = activeBranch .. "#" .. tostring(p5 or p3)
		v11.activatedBranchKeys = v11.activatedBranchKeys or {}

		if v11.activatedBranchKeys[v12] then
			return
		end

		v11.activatedBranchKeys[v12] = true
		v11.activatedBranches[activeBranch] = true
	end

	local v12 = 1e999

	for _, v13 in ipairs(branchEvent) do
		local time = tonumber(v13.Time) or 0

		if time < v12 then
			v12 = time
		end
	end

	local v13 = v12 == 1e999 and 0 or v12

	if type(value) == "number" then
		v13 = value
	end

	local v14 = math.max(tonumber(p3) or 0, Workspace:GetServerTimeNow())

	if p4 and p4.ForcedCollisionPosition then
		local forcedCollisionPosition = p4.ForcedCollisionPosition
		string.format(
			" pos=(%.1f,%.1f,%.1f)",
			forcedCollisionPosition.X,
			forcedCollisionPosition.Y,
			forcedCollisionPosition.Z
		)
	end

	for _, v15 in ipairs(branchEvent) do
		local v16 = type(v15.Properties) ~= "table" and {} or v15.Properties or {}
		local v17 = {}

		if type(v15.Data) == "table" then
			for k, v19 in pairs(v15.Data) do
				table.insert(v17, tostring(k) .. "=" .. tostring(v19))

				if #v17 >= 16 then
					break
				end
			end
		end

		local v18 = {}

		for k, v19 in pairs(v16) do
			local v20 = tostring(v19)

			if #v20 > 60 then
				v20 = v20:sub(1, 60) .. "..."
			end

			table.insert(v18, tostring(k) .. "=" .. v20)

			if #v18 >= 24 then
				break
			end
		end

		local presetName = v16.PresetName or v16.ParticleName or v16.Name or ""

		if type(presetName) == "string" and string.find(presetName, "__MergedPreset_") then
		end
	end

	scheduleEvents(v11, branchEvent, v13, v14, p4, activeBranch)
end

function HeadlessPlayback.stop(p, p2)
	local v11 = v7[tostring(p)]

	if not v11 then
		return
	end

	v11.alive = false

	for _, thread in ipairs(v11.threads) do
		pcall(task.cancel, thread)
	end

	v7[tostring(p)] = nil

	if p2 and type(v11.moveContext) == "table" and type(v11.moveContext.__VfxCancels) == "table" then
		for _, callback in ipairs(v11.moveContext.__VfxCancels) do
			pcall(callback)
		end

		v11.moveContext.__VfxCancels = {}
	end

	local container = v11.container

	if typeof(container) == "Instance" then
		if p2 then
			if container.Parent then
				container:Destroy()
			end
		else
			task.spawn(function()
				local v12 = os.clock() + 30

				while container.Parent and #container:GetDescendants() > 0 and os.clock() < v12 do
					task.wait(0.5)
				end

				if container.Parent then
					container:Destroy()
				end
			end)
		end
	end
end

function HeadlessPlayback.isActive(p)
	return v7[tostring(p)] ~= nil
end

return HeadlessPlayback