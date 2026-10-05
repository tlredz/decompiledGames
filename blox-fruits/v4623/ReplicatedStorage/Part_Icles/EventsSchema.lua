local TypeRegistry = require(script.Parent.TypeRegistry)
local EventsSchema = {}
local v = {
	"OnEmit",
	"OnDeath",
	"OnDestruction",
	"OnHit"
}
EventsSchema.EVENT_NAMES = v
EventsSchema.EVENTS_FOLDER_NAME = "Events"
local v2 = {
	AtPosition = true,
	AtSource = true,
	AtTarget = true,
	AtCFrame = true
}
EventsSchema.EMIT_MODES = v2
local v3 = {
	Off = true,
	Kill = true,
	Stop = true,
	Bounce = true
}
EventsSchema.COLLISION_MODES = v3

-- equivalent calls inferred from this helper; original call sites unknown
local function clampDepthValue(chainDepthLimit)
	local v4 = tonumber(chainDepthLimit)

	if v4 then
		return (math.clamp(math.floor(v4), 1, 32))
	end

	return 4
end

EventsSchema.clampChainDepth = clampDepthValue

function EventsSchema.safeEmitMode(value)
	if type(value) == "string" and v2[value] then
		return value
	end

	return "AtPosition"
end

function EventsSchema.safeCollisionMode(value)
	if type(value) == "string" and v3[value] then
		return value
	end

	return "Off"
end

function EventsSchema.clampUnit(p, p2, p3, p4)
	local v4 = tonumber(p)

	if not v4 then
		return p4
	end

	if v4 < p2 then
		return p2
	end

	if p3 < v4 then
		return p3
	end

	return v4
end

local v4 = {
	Part = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = true
	},
	Beam = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Attachment = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = true
	},
	Model = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = true
	},
	PointLight = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Highlight = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	TrailEmitter = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Atmosphere = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Blur = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Bloom = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	ColorCorrection = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	ImageLabel = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Lightning = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = true
	},
	CameraShake = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	},
	Rocks = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = true
	},
	Rope = {
		OnEmit = true,
		OnDeath = true,
		OnDestruction = true,
		OnHit = false
	}
}
local v5 = {
	Enabled = false,
	EmitMode = "AtPosition",
	ScriptEnabled = false,
	ChainDepthLimit = 4,
	Collision = "Off",
	Bounciness = 0.7,
	Friction = 0.2,
	Spin = 0.5,
	HitCheckInterval = 0,
	CollisionGroup = ""
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfig(p)
	if not p then
		return nil
	end

	local typeFor = TypeRegistry.getTypeFor(p)

	if typeFor and not typeFor.directAccess then
		return TypeRegistry.getConfig(p)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTypeName(p)
	local _, v6 = TypeRegistry.getTypeFor(p)
	return v6
end

function EventsSchema.read(p)
	local config = getConfig(p) -- equivalent call inferred; original call site unknown

	if not config then
		return nil
	end

	local events = config:FindFirstChild("Events")

	if events and events:IsA("Folder") then
		return events
	end

	return nil
end

function EventsSchema.isValidForItem(p, p2)
	local typeName = getTypeName(p) -- equivalent call inferred; original call site unknown

	if typeName then
		return EventsSchema.isValidForTypeName(typeName, p2)
	end

	return false
end

function EventsSchema.isValidForTypeName(p, p2)
	local v6 = v4[p]
	return v6 and v6[p2] == true and true or false
end

function EventsSchema.readEvent(p, childName)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return nil
	end

	local configuration = v6:FindFirstChild(childName)

	if configuration and configuration:IsA("Configuration") then
		return configuration
	end

	return nil
end

function EventsSchema.ensureExcludeListFolder(parent)
	if not parent then
		return nil
	end

	local v6 = parent:FindFirstChild("ExcludeList")

	if not v6 then
		v6 = Instance.new("Folder")
		v6.Name = "ExcludeList"
		v6.Parent = parent
	end

	return v6
end

function EventsSchema.readEnabled(p)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return nil
	end

	local result = nil

	for _, childName in ipairs(v) do
		if not EventsSchema.isValidForItem(p, childName) then
			continue
		end

		local configuration = v6:FindFirstChild(childName)

		if not configuration or not configuration:IsA("Configuration") or configuration:GetAttribute("Enabled") ~= true or configuration:GetAttribute("ImportedUntrusted") then
			continue
		end

		local emitTarget = configuration:FindFirstChild("EmitTarget")
		local scriptEnabled = configuration:GetAttribute("ScriptEnabled") == true
		local module

		if scriptEnabled then
			module = configuration:FindFirstChild("Module") or nil
		end

		if module and not module:IsA("ModuleScript") then
			module = nil
		end

		result = result or {}
		local emitMode = configuration:GetAttribute("EmitMode")
		local v7 = {
			Enabled = true,
			EventName = childName,
			EmitMode = (type(emitMode) ~= "string" or not v2[emitMode]) and "AtPosition" or emitMode,
			ScriptEnabled = scriptEnabled,
			ChainDepthLimit = clampDepthValue(configuration:GetAttribute("ChainDepthLimit")),
			EmitTarget = emitTarget and emitTarget:IsA("ObjectValue") and emitTarget.Value or nil,
			Module = module,
			Collision = 0,
			Bounciness = 0,
			Friction = 0,
			Spin = 0,
			HitCheckInterval = 0
		}
		local collision = configuration:GetAttribute("Collision")
		v7.Collision = (type(collision) ~= "string" or not v3[collision]) and "Off" or collision
		local bounciness = tonumber((configuration:GetAttribute("Bounciness")))
		v7.Bounciness = not bounciness and 0.7 or bounciness < 0 and 0 or bounciness > 1 and 1 or bounciness
		local friction = tonumber((configuration:GetAttribute("Friction")))
		v7.Friction = not friction and 0.2 or friction < 0 and 0 or friction > 1 and 1 or friction
		local spin = tonumber((configuration:GetAttribute("Spin")))
		v7.Spin = not spin and 0.5 or spin < 0 and 0 or spin > 2 and 2 or spin
		local hitCheckInterval = tonumber((configuration:GetAttribute("HitCheckInterval")))
		v7.HitCheckInterval = not hitCheckInterval and 0 or hitCheckInterval < 0 and 0 or hitCheckInterval > 0.5 and 0.5 or hitCheckInterval
		result[childName] = v7
	end

	return result
end

function EventsSchema.ensure(p)
	local config = getConfig(p) -- equivalent call inferred; original call site unknown

	if not config then
		return nil
	end

	local events = config:FindFirstChild("Events")

	if events and events:IsA("Folder") then
		return events
	end

	if events then
		events:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "Events"
	folder.Parent = config
	return folder
end

function EventsSchema.ensureEvent(p, name)
	if not EventsSchema.isValidForItem(p, name) then
		return nil
	end

	local parent = EventsSchema.ensure(p)

	if not parent then
		return nil
	end

	local configuration = parent:FindFirstChild(name)

	if configuration and configuration:IsA("Configuration") then
		return configuration
	end

	if configuration then
		configuration:Destroy()
	end

	local configuration2 = Instance.new("Configuration")
	configuration2.Name = name

	for k, v7 in pairs(v5) do
		configuration2:SetAttribute(k, v7)
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "EmitTarget"
	objectValue.Value = nil
	objectValue.Parent = configuration2
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = "Module"
	moduleScript.Source = [=[
--[[
	Part-Icles event handler.

	Source emitters supported: Part / Beam / PointLight / Attachment / Model /
	Highlight / TrailEmitter / Blur / Bloom / ColorCorrection / Atmosphere /
	ImageLabel.

	Raw ParticleEmitters and raw Trails are NOT supported as event SOURCES (they
	have no event-binding UI). As event TARGETS they ARE supported: a raw PE
	target gets wrapped in a holder Part at the emit-position; a raw Trail target
	emits in-place (the position override is ignored).
]]
-- ============================================================================
--  READ ONLY  (data fields  -  writing has no engine effect)
-- ============================================================================
--   Shared (every event scope)
--     payload.Source                            -- the source emitter Instance
--     payload.Particle, payload.RenderTemplate  -- the live emitted clone (RenderTemplate is a legacy alias)
--     payload.WorldCFrame                       -- world-space CFrame (nil for screen types)
--     payload.WorldPosition                     -- world position (nil for screen types)
--     payload.StartTime                         -- os.clock() at spawn
--     payload.LifeTime                          -- configured lifetime in seconds (use SetLifetime to change)
--     payload.LifeProgress                      -- t in [0, 1] of life elapsed (clamped)
--     payload.TimeRemaining                     -- seconds until natural death (max(0, LifeTime - elapsed))
--     payload.SpeedMultiplier                   -- current bounce-attenuated speed scalar (1 by default)
--     payload.ChainDepth                        -- depth of this event in the cross-emitter chain (0 = root)
--
--   OnEmit only
--     payload.EmitPosition                      -- Vector3 (alias for WorldPosition in OnEmit scope)
--     payload.EmitIndex                         -- 1-based batch index
--     payload.EmitCount                         -- batch size when emitted via burst (nil otherwise)
--
--   OnHit only
--     payload.HitPosition                       -- Vector3
--     payload.HitNormal                         -- Vector3
--     payload.HitInstance, payload.Other        -- the hit Instance (Other is an alias)
--
--   OnDeath only
--     payload.DeathPosition                     -- Vector3 (alias for WorldPosition in OnDeath scope)
--     payload.Age                               -- particle age in seconds
--
--   OnDestruction only
--     payload.DeathPosition                     -- Vector3 (alias for WorldPosition in OnDestruction scope)
--     payload.LingerElapsed                     -- seconds elapsed since linger started
--
-- ============================================================================
--  MUTATORS  (functions  -  call to change the live particle's state)
--             All mutators are available in every event scope.
-- ============================================================================
--   Emission control
--     payload.Emit(target, mode)         -- mode = "AtPosition"|"AtSource"|"AtTarget"|"AtCFrame"
--     payload.Kill()                     -- destroy/disable particle; Animate-mode-aware
--     payload.Resurrect()                -- undo a Kill (clears _killedManually + _forceDead)
--
--   Graph-channel override (auto-skip future graph writes on that channel)
--     payload.SetColor(color3)
--     payload.SetTransparency(scalar)
--     payload.SetSize(size)              -- BasePart.Size (Vector3) / Model ScaleTo / ImageLabel UDim2
--
--   Graph-channel skip (manual gate; no value write)
--     payload.SetSkipColor(bool)
--     payload.SetSkipTransparency(bool)
--     payload.SetSkipSize(bool)          -- Part only for now
--
--   Lifecycle
--     payload.SetLifetime(seconds)       -- set NEW total LifeTime; <=0.001 = instant kill next frame
--     payload.FreezeTime(bool)           -- toggle effective-elapsed advance (true = paused)
--     payload.Pause(seconds)             -- temporary FreezeTime; auto-clears after duration
--
--   Spatial / kinematic
--     payload.Teleport(cframe)           -- write VisualPart to a new CFrame (Part/Attachment/Model only)
--     payload.SetVelocity(vec3)          -- replace BaseDirection (unit) + speed override (magnitude)
--     payload.SetSpeedMultiplier(scalar) -- multiplicative scalar applied per-step
--     payload.AddSpin(vec3)              -- add angular velocity to pData._spinRate
--     payload.AddImpulse(vec3)           -- kick pData._accelVel (acceleration-velocity accumulator)
return function(payload)
	-- your code here
end
]=]
	moduleScript.Parent = configuration2
	configuration2.Parent = parent
	return configuration2
end

function EventsSchema.setEnabled(p, p2, p3)
	if p3 then
		local event = EventsSchema.ensureEvent(p, p2)

		if not event then
			return nil
		end

		event:SetAttribute("Enabled", true)
		return event
	else
		local event = EventsSchema.readEvent(p, p2)

		if not event then
			return nil
		end

		event:SetAttribute("Enabled", false)
		return event
	end
end

function EventsSchema.trustEvent(p, p2)
	local event = EventsSchema.readEvent(p, p2)

	if not (event and event:GetAttribute("ImportedUntrusted")) then
		return false
	end

	event:SetAttribute("ImportedUntrusted", nil)
	return true
end

function EventsSchema.trustAllEvents(p)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return false
	end

	local v7 = false

	for _, configuration in ipairs(v6:GetChildren()) do
		if not (configuration:IsA("Configuration") and configuration:GetAttribute("ImportedUntrusted")) then
			continue
		end

		configuration:SetAttribute("ImportedUntrusted", nil)
		v7 = true
	end

	return v7
end

function EventsSchema.stampImportedUntrusted(p)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return false
	end

	local v7 = false

	for _, configuration in ipairs(v6:GetChildren()) do
		if not configuration:IsA("Configuration") then
			continue
		end

		configuration:SetAttribute("ImportedUntrusted", true)
		configuration:SetAttribute("Enabled", false)
		v7 = true
	end

	return v7
end

function EventsSchema.deleteEvent(p, p2)
	local event = EventsSchema.readEvent(p, p2)

	if not event then
		return false
	end

	event:Destroy()
	local v6 = EventsSchema.read(p)

	if v6 and #v6:GetChildren() == 0 then
		v6:Destroy()
	end

	return true
end

function EventsSchema.sanitize(p)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return false
	end

	local v7 = {}
	local v8 = false

	for _, v9 in ipairs(v) do
		v7[v9] = true
	end

	for _, configuration in ipairs(v6:GetChildren()) do
		if configuration:IsA("Configuration") and v7[configuration.Name] and EventsSchema.isValidForItem(
			p,
			configuration.Name
		) then
			for attributeName, v9 in pairs(v5) do
				if configuration:GetAttribute(attributeName) ~= nil then
					continue
				end

				configuration:SetAttribute(attributeName, v9)
				v8 = true
			end

			local chainDepthLimit = configuration:GetAttribute("ChainDepthLimit")
			local v9 = clampDepthValue(chainDepthLimit) -- equivalent call inferred; original call site unknown

			if chainDepthLimit ~= v9 then
				configuration:SetAttribute("ChainDepthLimit", v9)
				v8 = true
			end

			local emitMode = configuration:GetAttribute("EmitMode")
			local v10 = (type(emitMode) ~= "string" or not v2[emitMode]) and "AtPosition" or emitMode

			if emitMode ~= v10 then
				configuration:SetAttribute("EmitMode", v10)
				v8 = true
			end

			local collision = configuration:GetAttribute("Collision")
			local v11 = (type(collision) ~= "string" or not v3[collision]) and "Off" or collision

			if collision ~= v11 then
				configuration:SetAttribute("Collision", v11)
				v8 = true
			end

			for _, v12 in ipairs({
				{
					name = "Bounciness",
					lo = 0,
					hi = 1,
					default = 0.7
				},
				{
					name = "Friction",
					lo = 0,
					hi = 1,
					default = 0.2
				},
				{
					name = "Spin",
					lo = 0,
					hi = 2,
					default = 0.5
				},
				{
					name = "HitCheckInterval",
					lo = 0,
					hi = 0.5,
					default = 0
				}
			}) do
				local attribute = configuration:GetAttribute(v12.name)
				local lo = v12.lo
				local hi = v12.hi
				local default = v12.default
				local v13 = tonumber(attribute)

				if v13 then
					if v13 < lo then
						v13 = lo
					elseif hi < v13 then
						v13 = hi
					end
				else
					v13 = default
				end

				if attribute == v13 then
					continue
				end

				configuration:SetAttribute(v12.name, v13)
				v8 = true
			end

			local emitTarget = configuration:FindFirstChild("EmitTarget")

			if not (emitTarget and emitTarget:IsA("ObjectValue")) then
				if emitTarget then
					emitTarget:Destroy()
				end

				local objectValue = Instance.new("ObjectValue")
				objectValue.Name = "EmitTarget"
				objectValue.Parent = configuration
				v8 = true
			end

			local module = configuration:FindFirstChild("Module")

			if not (module and module:IsA("ModuleScript")) then
				if module then
					module:Destroy()
				end

				local moduleScript = Instance.new("ModuleScript")
				moduleScript.Name = "Module"
				moduleScript.Source = [=[
--[[
	Part-Icles event handler.

	Source emitters supported: Part / Beam / PointLight / Attachment / Model /
	Highlight / TrailEmitter / Blur / Bloom / ColorCorrection / Atmosphere /
	ImageLabel.

	Raw ParticleEmitters and raw Trails are NOT supported as event SOURCES (they
	have no event-binding UI). As event TARGETS they ARE supported: a raw PE
	target gets wrapped in a holder Part at the emit-position; a raw Trail target
	emits in-place (the position override is ignored).
]]
-- ============================================================================
--  READ ONLY  (data fields  -  writing has no engine effect)
-- ============================================================================
--   Shared (every event scope)
--     payload.Source                            -- the source emitter Instance
--     payload.Particle, payload.RenderTemplate  -- the live emitted clone (RenderTemplate is a legacy alias)
--     payload.WorldCFrame                       -- world-space CFrame (nil for screen types)
--     payload.WorldPosition                     -- world position (nil for screen types)
--     payload.StartTime                         -- os.clock() at spawn
--     payload.LifeTime                          -- configured lifetime in seconds (use SetLifetime to change)
--     payload.LifeProgress                      -- t in [0, 1] of life elapsed (clamped)
--     payload.TimeRemaining                     -- seconds until natural death (max(0, LifeTime - elapsed))
--     payload.SpeedMultiplier                   -- current bounce-attenuated speed scalar (1 by default)
--     payload.ChainDepth                        -- depth of this event in the cross-emitter chain (0 = root)
--
--   OnEmit only
--     payload.EmitPosition                      -- Vector3 (alias for WorldPosition in OnEmit scope)
--     payload.EmitIndex                         -- 1-based batch index
--     payload.EmitCount                         -- batch size when emitted via burst (nil otherwise)
--
--   OnHit only
--     payload.HitPosition                       -- Vector3
--     payload.HitNormal                         -- Vector3
--     payload.HitInstance, payload.Other        -- the hit Instance (Other is an alias)
--
--   OnDeath only
--     payload.DeathPosition                     -- Vector3 (alias for WorldPosition in OnDeath scope)
--     payload.Age                               -- particle age in seconds
--
--   OnDestruction only
--     payload.DeathPosition                     -- Vector3 (alias for WorldPosition in OnDestruction scope)
--     payload.LingerElapsed                     -- seconds elapsed since linger started
--
-- ============================================================================
--  MUTATORS  (functions  -  call to change the live particle's state)
--             All mutators are available in every event scope.
-- ============================================================================
--   Emission control
--     payload.Emit(target, mode)         -- mode = "AtPosition"|"AtSource"|"AtTarget"|"AtCFrame"
--     payload.Kill()                     -- destroy/disable particle; Animate-mode-aware
--     payload.Resurrect()                -- undo a Kill (clears _killedManually + _forceDead)
--
--   Graph-channel override (auto-skip future graph writes on that channel)
--     payload.SetColor(color3)
--     payload.SetTransparency(scalar)
--     payload.SetSize(size)              -- BasePart.Size (Vector3) / Model ScaleTo / ImageLabel UDim2
--
--   Graph-channel skip (manual gate; no value write)
--     payload.SetSkipColor(bool)
--     payload.SetSkipTransparency(bool)
--     payload.SetSkipSize(bool)          -- Part only for now
--
--   Lifecycle
--     payload.SetLifetime(seconds)       -- set NEW total LifeTime; <=0.001 = instant kill next frame
--     payload.FreezeTime(bool)           -- toggle effective-elapsed advance (true = paused)
--     payload.Pause(seconds)             -- temporary FreezeTime; auto-clears after duration
--
--   Spatial / kinematic
--     payload.Teleport(cframe)           -- write VisualPart to a new CFrame (Part/Attachment/Model only)
--     payload.SetVelocity(vec3)          -- replace BaseDirection (unit) + speed override (magnitude)
--     payload.SetSpeedMultiplier(scalar) -- multiplicative scalar applied per-step
--     payload.AddSpin(vec3)              -- add angular velocity to pData._spinRate
--     payload.AddImpulse(vec3)           -- kick pData._accelVel (acceleration-velocity accumulator)
return function(payload)
	-- your code here
end
]=]
				moduleScript.Parent = configuration
				v8 = true
			end

			for _, child in ipairs(configuration:GetChildren()) do
				if child.Name ~= "_CompiledEventModule" then
					continue
				end

				child:Destroy()
				v8 = true
			end

			continue
		end

		configuration:Destroy()
		v8 = true
	end

	if #v6:GetChildren() == 0 then
		v6:Destroy()
		return true
	end

	return v8
end

function EventsSchema.snapshot(p)
	local v6 = EventsSchema.read(p)

	if not v6 then
		return nil
	end

	local result = nil

	for _, childName in ipairs(v) do
		local configuration = v6:FindFirstChild(childName)

		if not (configuration and configuration:IsA("Configuration")) then
			continue
		end

		result = result or {}
		local v7 = {
			Enabled = configuration:GetAttribute("Enabled"),
			EmitMode = configuration:GetAttribute("EmitMode"),
			ScriptEnabled = configuration:GetAttribute("ScriptEnabled"),
			ChainDepthLimit = configuration:GetAttribute("ChainDepthLimit"),
			Collision = configuration:GetAttribute("Collision"),
			Bounciness = configuration:GetAttribute("Bounciness"),
			Friction = configuration:GetAttribute("Friction"),
			Spin = configuration:GetAttribute("Spin"),
			HitCheckInterval = configuration:GetAttribute("HitCheckInterval"),
			ImportedUntrusted = configuration:GetAttribute("ImportedUntrusted") == true
		}
		local emitTarget = configuration:FindFirstChild("EmitTarget")

		if emitTarget and emitTarget:IsA("ObjectValue") then
			v7.EmitTargetPresent = true
			v7.EmitTargetValue = emitTarget.Value
			v7.EmitTargetPath = emitTarget.Value and emitTarget.Value:GetFullName() or nil
		end

		local module = configuration:FindFirstChild("Module")

		if module and module:IsA("ModuleScript") then
			v7.ModuleSource = module.Source
		end

		result[childName] = v7
	end

	return result
end

function EventsSchema.apply(p, items)
	if not items then
		return false
	end

	local v6 = false

	for k, item in pairs(items) do
		if not EventsSchema.isValidForItem(p, k) then
			continue
		end

		local event = EventsSchema.ensureEvent(p, k)

		if not event then
			continue
		end

		if item.Enabled ~= nil then
			event:SetAttribute("Enabled", item.Enabled == true)
		end

		if item.EmitMode ~= nil then
			local emitMode = item.EmitMode
			event:SetAttribute(
				"EmitMode",
				(type(emitMode) ~= "string" or not v2[emitMode]) and "AtPosition" or emitMode
			)
		end

		if item.ScriptEnabled ~= nil then
			event:SetAttribute("ScriptEnabled", item.ScriptEnabled == true)
		end

		if item.ChainDepthLimit ~= nil then
			event:SetAttribute("ChainDepthLimit", clampDepthValue(item.ChainDepthLimit))
		end

		if item.Collision ~= nil then
			local collision = item.Collision
			event:SetAttribute("Collision", (type(collision) ~= "string" or not v3[collision]) and "Off" or collision)
		end

		if item.Bounciness ~= nil then
			local bounciness = tonumber(item.Bounciness)
			event:SetAttribute(
				"Bounciness",
				not bounciness and 0.7 or bounciness < 0 and 0 or bounciness > 1 and 1 or bounciness
			)
		end

		if item.Friction ~= nil then
			local friction = tonumber(item.Friction)
			event:SetAttribute("Friction", not friction and 0.2 or friction < 0 and 0 or friction > 1 and 1 or friction)
		end

		if item.Spin ~= nil then
			local spin = tonumber(item.Spin)
			event:SetAttribute("Spin", not spin and 0.5 or spin < 0 and 0 or spin > 2 and 2 or spin)
		end

		if item.HitCheckInterval ~= nil then
			local hitCheckInterval = tonumber(item.HitCheckInterval)
			event:SetAttribute(
				"HitCheckInterval",
				not hitCheckInterval and 0 or hitCheckInterval < 0 and 0 or hitCheckInterval > 0.5 and 0.5 or hitCheckInterval
			)
		end

		if item.ImportedUntrusted == true then
			event:SetAttribute("ImportedUntrusted", true)
		else
			event:SetAttribute("ImportedUntrusted", nil)
		end

		local emitTarget = event:FindFirstChild("EmitTarget")

		if emitTarget and emitTarget:IsA("ObjectValue") and item.EmitTargetPresent then
			emitTarget.Value = item.EmitTargetValue
		end

		local module = event:FindFirstChild("Module")

		if module and module:IsA("ModuleScript") and item.ModuleSource ~= nil then
			module.Source = item.ModuleSource
		end

		v6 = true
	end

	return v6
end

return EventsSchema