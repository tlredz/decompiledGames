local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
game:GetService("ContentProvider")
local logger = require(script.mod.logger)
local utility = require(script.mod.utility)
local beam = require(script.effects.beam)
local spin = require(script.effects.spin)
local mesh = require(script.effects.mesh)
local bezier = require(script.effects.bezier)
local screen = require(script.effects.screen)
local particle = require(script.effects.particle)
local tween_property = require(script.effects.tween_property)
local shockwave_ring = require(script.effects.shockwave_ring)
local shockwave_line = require(script.effects.shockwave_line)
local shockwave_debris = require(script.effects.shockwave_debris)
local Promise = require(script.pkg.Promise)
local plugin = script:FindFirstAncestorOfClass("Plugin")
local v = RunService:IsServer() or plugin
local EmitModule = {
	scope = {},
	setup = false,
	cullingEnabled = false
}

function EmitModule.setCulling(flag: boolean)
	EmitModule.cullingEnabled = flag == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cullingActive()
	return EmitModule.cullingEnabled == true and shared.vfxDisableCulling ~= true
end

local function assembleMeshVFX(part, list)
	if not EmitModule.setup then
		logger.error("API not initialized")
	end

	local ranomId = utility.getRanomId()

	if part:IsA("Part") then
		local v2 = EmitModule.caches.shared_part:get(ranomId)
		v2.CFrame = part.CFrame
		local _getReal = v2._getReal()
		utility.copyProperties(part, _getReal, utility.COPY_PART_PROPERTIES)
		utility.copyProperties(part, _getReal, utility.COPY_EXTENDED_PART_PROPERTIES)
		local clone = part:Clone()

		for _, child in clone:GetChildren() do
			child.Parent = _getReal
		end

		clone:Destroy()
		table.insert(list, function()
			EmitModule.caches.shared_part:free(ranomId)
		end)
		return v2
	else
		local clone = part:Clone()
		clone.Archivable = false
		clone.Locked = true
		clone.Parent = workspace:FindFirstChild("Thrown") or workspace
		game.Debris:AddItem(clone, 8)
		table.insert(list, clone)
		return clone
	end
end

local v2 = table.create(64)
local v3 = table.create(64)
local v4 = false
local thread = coroutine.create(function()
	while true do
		local count = #v2
		local count2 = 0

		for i = 1, count do
			local v5 = v2[i]

			if not (v5 and v5.Parent) then
				continue
			end

			count2 += 1
			v2[count2] = v5
			v3[count2] = v3[i]
		end

		for i = count2 + 1, count do
			v2[i] = nil
			v3[i] = nil
		end

		if count2 > 0 then
			pcall(workspace.BulkMoveTo, workspace, v2, v3, Enum.BulkMoveMode.FireCFrameChanged)
		end

		table.clear(v2)
		table.clear(v3)
		v4 = false
		coroutine.yield()
	end
end)
local object = setmetatable({}, {
	__mode = "k"
})

local function makeAbstr(p)
	local v5 = object[p]

	if v5 then
		return v5
	end

	local self = setmetatable({
		_getReal = function()
			return p
		end
	}, {
		__newindex = function(_, p2, p3)
			if p2 == "CFrame" then
				table.insert(v2, p)
				table.insert(v3, p3)

				if not v4 then
					v4 = true
					task.defer(thread)
				end
			else
				p[p2] = p3
			end
		end,
		__index = function(_, p2)
			local v6 = p[p2]

			if typeof(v6) == "function" then
				return function(_, ...)
					return v6(p, ...)
				end
			end

			return v6
		end
	})
	object[p] = self
	return self
end

local function createPartCache(part)
	local v5 = {}
	return {
		get = function(self, p)
			local v6 = v5[p]

			if v6 then
				return (makeAbstr(v6))
			end

			local clone = part:Clone()
			clone.Archivable = false
			clone.Parent = workspace:FindFirstChild("Thrown") or workspace
			v5[p] = clone
			return (makeAbstr(clone))
		end,
		free = function(self, p)
			local v6 = v5[p]

			if not v6 then
				return
			end

			v5[p] = nil
			v6:Destroy()
		end,
		destroy = function(self)
			for k, v6 in v5 do
				v6:Destroy()
				v5[k] = nil
			end
		end
	}
end

function EmitModule.init(_)
	if EmitModule.setup then
		return
	end

	if v then
		task.spawn(function()
			local count = 0

			while true do
				count += 1
				local success, result = pcall(utility.setCollisionGroups, utility.COLLISION_GROUPS)

				if not success then
					task.wait(count)
				end

				if not (success or count >= 5) then
					continue
				end

				if not success then
					logger.warn((`couldn't register necessary collision groups after {count} tries with the last error being: {result}`))
				end

				break
			end
		end)
	end

	EmitModule.setup = true

	if RunService:IsServer() and not plugin then
		return
	end

	shared.vfx = EmitModule
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Locked = true
	part.CollisionGroup = "ForgeMouseIgnore"
	local partCache = createPartCache(part)
	EmitModule.caches = {
		shared_part = partCache
	}
	table.insert(EmitModule.scope, function()
		partCache:destroy()
	end)
	bezier.init(partCache)
	shockwave_ring.init(partCache)
	shockwave_line.init(partCache)
	shockwave_debris.init(partCache)
	local v5 = {}
	local v6 = {}

	local function preload(p: string)
		if p == "" or v5[p] then
			return
		end

		v5[p] = true
	end

	local function loadTextures(folder)
		if folder:IsDescendantOf(workspace.Terrain) then
			return
		end

		if utility.isMeshVFX(folder) then
			local start = folder:FindFirstChild("Start")

			if not (start and start:IsA("BasePart")) then
				return
			end

			local connections = {}

			local function refresh()
				local meshDecals, v7 = utility.getMeshDecals(folder, start)

				local function add(texture)
					if typeof(texture) == "Instance" then
						texture = texture.Texture or texture
					end

					if texture ~= "" then
						if v5[texture] then
							return
						else
							v5[texture] = true
						end
					end
				end

				for _, texture in meshDecals do
					if typeof(texture) == "Instance" then
						texture = texture.Texture or texture
					end

					if texture == "" or v5[texture] then
						continue
					end

					v5[texture] = true
				end

				for k, v8 in v7 do
					local v9 = false

					if plugin then
						for _, v11 in CollectionService:GetTags(k) do
							if not v11:match("^_local_flipbook_") then
								continue
							end

							v9 = true
							break
						end
					end

					for _, v10 in v8 do
						local texture = `{v9 and "rbxtemp://" or "rbxassetid://"}{v10}`

						if typeof(texture) == "Instance" then
							texture = texture.Texture or texture
						end

						if texture == "" or v5[texture] then
							continue
						end

						v5[texture] = true
					end
				end
			end

			refresh()

			if plugin then
				local reboundfn = utility.reboundfn(1, refresh)
				table.insert(connections, start.DescendantAdded:Connect(reboundfn))
				table.insert(connections, start.DescendantRemoving:Connect(reboundfn))
			end

			v6[folder] = connections
		else
			local connections = {}

			local function refresh()
				local function check(emitter)
					if not emitter:IsA("ParticleEmitter") then
						return
					end

					local texture = emitter.Texture

					if texture ~= "" then
						if v5[texture] then
							return
						else
							v5[texture] = true
						end
					end
				end

				local emitter = folder

				if emitter:IsA("ParticleEmitter") then
					local texture = emitter.Texture

					if texture ~= "" and not v5[texture] then
						v5[texture] = true
					end
				end

				for _, emitter2 in folder:GetDescendants() do
					if not emitter2:IsA("ParticleEmitter") then
						continue
					end

					local texture = emitter2.Texture

					if texture == "" or v5[texture] then
						continue
					end

					v5[texture] = true
				end
			end

			refresh()

			if plugin then
				local reboundfn = utility.reboundfn(1, refresh)
				table.insert(connections, folder.DescendantAdded:Connect(reboundfn))
				table.insert(connections, folder.DescendantRemoving:Connect(reboundfn))
			end

			v6[folder] = connections
		end
	end

	for _, v7 in CollectionService:GetTagged(utility.TEXTURE_LOAD_TAG) do
		loadTextures(v7)
	end

	CollectionService:GetInstanceAddedSignal(utility.TEXTURE_LOAD_TAG):Connect(loadTextures)
	CollectionService:GetInstanceRemovedSignal(utility.TEXTURE_LOAD_TAG):Connect(function(p)
		local v7 = v6[p]

		if v7 then
			utility.cleanupScope(v7)
			v6[p] = nil
		end
	end)
	table.insert(EmitModule.scope, function()
		for _, v7 in v6 do
			utility.cleanupScope(v7)
		end
	end)
	local v7 = {}
	local v8 = {}
	local v9 = 0
	local heartbeatConnection = nil

	local function tickEntry(instance, state, now)
		if state.speed == 0 or now - state.last <= 1 / state.rate / state.speed then
			return
		end

		state.last = now
		local clones = {
			depth = 0
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanup()
			utility.cleanupScope(clones)
		end

		table.insert(EmitModule.scope, cleanup)

		if state.isMesh then
			local start = instance:FindFirstChild("Start")

			if start then
				for _ = 1, state.emitCount do
					utility.try(
						`failed to emit mesh '{instance:GetFullName()}' with error: %s`,
						mesh.emit,
						instance,
						assembleMeshVFX(start, clones),
						clones,
						1,
						true
					)
				end
			else
				instance:RemoveTag(utility.ENABLED_VFX_TAG)
			end
		elseif state.isBezier then
			local part2 = instance:FindFirstChildOfClass("Part")

			if part2 then
				local clone = part2:Clone()
				clone.Locked = true
				table.insert(clones, clone)
				utility.try(
					`failed to emit bezier '{instance:GetFullName()}' with error: %s`,
					bezier.emit,
					instance,
					clone,
					clones,
					true
				)
			end
		end

		local index = table.find(EmitModule.scope, cleanup)

		if index then
			table.remove(EmitModule.scope, index)
		end

		cleanup() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ensureMaster()
		if heartbeatConnection or v9 == 0 then
			return
		end

		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v10 in pairs(v8) do
				if v10.enabled then
					tickEntry(k, v10, now)
				end
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function maybeStopMaster()
		if heartbeatConnection and v9 == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeEnabledEffect(p)
		local v10 = v7[p]

		if v10 then
			utility.cleanupScope(v10)
		end

		v7[p] = nil
		local v11 = v8[p]

		if v11 and v11.enabled then
			v9 -= 1
		end

		v8[p] = nil
		maybeStopMaster() -- equivalent call inferred; original call site unknown
	end

	local addEnabledEffect

	addEnabledEffect = function(instance)
		local meshVFX = utility.isMeshVFX(instance)
		local hasTag = instance:HasTag(utility.BEZIER_TAG)

		if not (meshVFX or hasTag) then
			return
		end

		local connections = {}
		v7[instance] = connections
		table.insert(connections, instance.AncestryChanged:Connect(function()
			if instance:IsDescendantOf(workspace) or instance.Parent and instance.Parent:HasTag("AllowEmitting") then
				if not v7[instance] then
					addEnabledEffect(instance)
				end
			else
				removeEnabledEffect(instance) -- equivalent call inferred; original call site unknown
			end
		end))

		if not instance:IsDescendantOf(workspace) then
			local v10

			if instance.Parent then
				v10 = not instance.Parent:HasTag("AllowEmitting")
			else
				v10 = false
			end

			if v10 then
				return
			end
		end

		local v10 = {
			isMesh = meshVFX,
			isBezier = hasTag,
			last = 0,
			rate = utility.getAttribute(instance, "Rate", 5),
			speed = instance:GetAttribute("SpeedOverride") or 1,
			enabled = utility.getAttribute(instance, "Enabled", true),
			emitCount = utility.getAttribute(instance, "EmitCount", 1)
		}
		v8[instance] = v10

		if v10.enabled then
			v9 += 1

			if not heartbeatConnection and v9 ~= 0 then
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local now = os.clock()

					for k, v11 in pairs(v8) do
						if v11.enabled then
							tickEntry(k, v11, now)
						end
					end
				end)
			end
		end

		table.insert(connections, instance:GetAttributeChangedSignal("Rate"):Connect(function()
			v10.rate = utility.getAttribute(instance, "Rate", 5)
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("SpeedOverride"):Connect(function()
			v10.speed = instance:GetAttribute("SpeedOverride") or 1
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("EmitCount"):Connect(function()
			v10.emitCount = utility.getAttribute(instance, "EmitCount", 1)
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("Enabled"):Connect(function()
			local attribute = utility.getAttribute(instance, "Enabled", true)

			if attribute and not v10.enabled then
				v10.enabled = true
				v9 += 1
				ensureMaster() -- equivalent call inferred; original call site unknown
			elseif not attribute and v10.enabled then
				v10.enabled = false
				v9 -= 1
				maybeStopMaster() -- equivalent call inferred; original call site unknown
			end
		end))
	end

	for _, v10 in CollectionService:GetTagged(utility.ENABLED_VFX_TAG) do
		addEnabledEffect(v10)
	end

	CollectionService:GetInstanceAddedSignal(utility.ENABLED_VFX_TAG):Connect(addEnabledEffect)
	CollectionService:GetInstanceRemovedSignal(utility.ENABLED_VFX_TAG):Connect(removeEnabledEffect)
	table.insert(EmitModule.scope, function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		for _, v10 in v7 do
			utility.cleanupScope(v10)
		end
	end)
end

function EmitModule.deinit()
	if not EmitModule.setup then
		return
	end

	EmitModule.setup = false
	shared.vfx = nil

	if RunService:IsServer() and not plugin then
		return
	end

	utility.cleanupScope(EmitModule.scope)
	bezier.deinit()
	shockwave_ring.deinit()
	shockwave_line.deinit()
	shockwave_debris.deinit()
end

function EmitModule:emit(...)
	if not EmitModule.setup then
		logger.error("not initialized")
	end

	if not RunService:IsServer() then
		local v5 = cullingActive() -- equivalent call inferred; original call site unknown

		if v5 and shared.cull and shared.cull.work then
			local position = nil
			local instance

			if typeof(self) == "table" and type(self._getReal) == "function" then
				instance = self._getReal()
			else
				instance = self
			end

			if typeof(instance) == "Instance" then
				if instance:IsA("BasePart") then
					position = instance.Position
				elseif instance:IsA("Attachment") then
					position = instance.WorldPosition
				elseif instance:IsA("Model") then
					if instance.PrimaryPart then
						position = instance.PrimaryPart.Position
					else
						local _CullAnchor = instance:FindFirstChild("_CullAnchor")

						if _CullAnchor and _CullAnchor:IsA("BasePart") then
							position = _CullAnchor.Position
						else
							local basePart = instance:FindFirstChildWhichIsA("BasePart", true) or instance:FindFirstChildWhichIsA(
								"Attachment",
								true
							)

							if basePart then
								position = basePart:IsA("BasePart") and basePart.Position or basePart.WorldPosition
							end
						end
					end
				elseif instance:IsA("Folder") or instance:IsA("Configuration") then
					local _CullAnchor = instance:FindFirstChild("_CullAnchor")

					if _CullAnchor and _CullAnchor:IsA("BasePart") then
						position = _CullAnchor.Position
					else
						local basePart = instance:FindFirstChildWhichIsA("BasePart", true) or instance:FindFirstChildWhichIsA(
							"Attachment",
							true
						)

						if basePart then
							position = basePart:IsA("BasePart") and basePart.Position or basePart.WorldPosition
						end
					end
				end
			end

			if position then
				local currentCamera = workspace.CurrentCamera
				local vector2 = currentCamera.CFrame.Position - position
				math.sqrt((vector2:Dot(vector2)))
				local _, _ = currentCamera:WorldToViewportPoint(position)

				if typeof(instance) ~= "Instance" or not instance:GetFullName() then
					typeof(instance)
				end

				if not shared.cull.work(position) then
					return {
						Finished = Promise.resolve()
					}
				end
			else
				local typeName = typeof(self)

				if typeName ~= "Instance" and typeName == "table" then
					local _ = self[1]
				end
			end
		end
	end

	local v5 = {}
	local v6 = {}
	local v7 = 1

	local function emit(instance, depth: number)
		return Promise.new(function(callback)
			local function run()
				local v8 = {
					depth = depth
				}

				if instance:IsA("ParticleEmitter") then
					if instance.Texture == "" then
						return
					end

					if instance:IsDescendantOf(workspace) then
						utility.try(
							`failed to emit particle '{instance:GetFullName()}' with error: %s`,
							particle.emit,
							instance,
							instance,
							v8,
							v7
						)
						utility.cleanupScope(v8)
					else
						local particleAncestry, v9 = utility.cloneParticleAncestry(instance, v6)

						if not particleAncestry then
							return
						end

						table.insert(v8, v9)
						local clone = instance:Clone()
						clone.Archivable = false
						clone.Parent = particleAncestry
						game.Debris:AddItem(clone, 30)

						if not v5[v9] then
							v9.Parent = workspace:FindFirstChild("Thrown") or workspace
						end

						if v5[v9] then
							v5[v9] += 1
						else
							v5[v9] = 1
						end

						utility.try(
							`failed to emit particle '{instance:GetFullName()}' with error: %s`,
							particle.emit,
							instance,
							clone,
							v8,
							v7
						)
						v5[v9] -= 1

						if v5[v9] <= 0 then
							utility.cleanupScope(v8)
						end
					end
				elseif instance:IsA("Beam") then
					local clone = instance:Clone()
					clone.Archivable = false
					clone.Parent = workspace:FindFirstChild("Thrown") or workspace
					game.Debris:AddItem(clone, 30)
					table.insert(v8, clone)
					utility.try(
						`failed to emit beam '{instance:GetFullName()}' with error: %s`,
						beam.emit,
						instance,
						clone,
						v8,
						v7
					)
					utility.cleanupScope(v8)
				elseif instance:IsA("Trail") then
					instance.Enabled = true
				elseif instance:HasTag(utility.BEZIER_TAG) then
					local part = instance:FindFirstChildOfClass("Part")

					if not part then
						return
					end

					if instance:GetAttribute("Enabled") then
						instance:SetAttribute("Enabled", false)
					end

					local clone = part:Clone()
					clone.Locked = true
					table.insert(v8, clone)
					utility.try(
						`failed to emit bezier '{instance:GetFullName()}' with error: %s`,
						bezier.emit,
						instance,
						clone,
						v8
					)
					utility.cleanupScope(v8)
				elseif utility.isMeshVFX(instance) then
					local start = instance:FindFirstChild("Start")

					if not start then
						return
					end

					if instance:GetAttribute("Enabled") then
						instance:SetAttribute("Enabled", false)
					end

					local v9 = {}

					for _ = 1, utility.getAttribute(instance, "EmitCount", 1) do
						table.insert(v9, Promise.new(function(callback2)
							utility.try(
								`failed to emit mesh '{instance:GetFullName()}' with error: %s`,
								mesh.emit,
								instance,
								assembleMeshVFX(start, v8),
								v8,
								v7
							)
							callback2()
						end))
					end

					Promise.all(v9):await()
					utility.cleanupScope(v8)
				elseif instance:IsA("Model") then
					if utility.lock(instance) then
						return
					end

					utility.try(
						`failed to emit spinning model '{instance:GetFullName()}' with error: %s`,
						spin.emit,
						instance,
						v8
					)
					utility.cleanupScope(v8)
					utility.unlock(instance)
				elseif instance:IsA("RayValue") then
					if instance:HasTag(utility.SCREENSHAKE_TAG) then
						utility.cleanupScope(v8)
					elseif instance.Parent and not utility.lock(instance) then
						utility.try(
							`failed to emit tween property '{instance:GetFullName()}' with error: %s`,
							tween_property.emit,
							instance.Parent,
							instance,
							v8
						)
						utility.unlock(instance)
						utility.cleanupScope(v8)
					else
						return
					end
				end

				local v9 = instance:IsA("Part") and utility.findFirstClassWithTag(
					instance,
					"Attachment",
					utility.SHOCKWAVE_TAG
				)

				if v9 then
					local name = instance.Parent.Name

					if name == "Rings" then
						utility.try(
							`failed to emit shockwave ring '{instance:GetFullName()}' with error: %s`,
							shockwave_ring.emit,
							v9,
							instance,
							v8
						)
						utility.cleanupScope(v8)
					elseif name == "Debris" then
						utility.try(
							`failed to emit shockwave debris '{instance:GetFullName()}' with error: %s`,
							shockwave_debris.emit,
							v9,
							instance,
							v8
						)
						utility.cleanupScope(v8)
					elseif name == "Lines" then
						utility.try(
							`failed to emit shockwave line '{instance:GetFullName()}' with error: %s`,
							shockwave_line.emit,
							v9,
							instance,
							v8
						)
						utility.cleanupScope(v8)
					end
				end
			end

			run()
			callback()
		end)
	end

	local v8 = { ... }

	if typeof(self) == "number" then
		v7 = self
	else
		table.insert(v8, self)
	end

	local v9 = {}
	local emitAll

	emitAll = function(depth: number, items, list)
		for _, instance in items do
			if instance:IsA("BasePart") and instance:GetAttribute("Enabled") and not utility.findFirstClassWithTag(
				instance,
				"Attachment",
				utility.SHOCKWAVE_TAG
			) then
				if not utility.lock(instance) then
					local model = instance:FindFirstAncestorOfClass("Model")

					if not model or model:GetAttribute("SpinRotation") == createVector(0, 0, 0) and model:GetAttribute("Scale_Start") == 1 and model:GetAttribute("Scale_End") == 1 then
						local thread2 = coroutine.running()
						local v10 = {
							depth = depth
						}

						if utility.try(
							`failed to emit screen effect '{instance:GetFullName()}' with error: %s`,
							screen.emit,
							instance,
							v10
						) then
							if #instance:GetDescendants() == 0 then
								utility.cleanupScope(v10)
								break
							end

							local v11 = {}
							emitAll(depth + 1, instance:GetChildren(), v11)
							local v12 = instance
							local v13 = thread2
							local v14 = v10
							table.insert(v9, Promise.all(v11):finally(function()
								utility.unlock(v12, v13)
								utility.cleanupScope(v14)
							end))
						end
					end
				end
			else
				table.insert(list, emit(instance, depth))

				if not (instance:HasTag(utility.BEZIER_TAG) or utility.isMeshVFX(instance) or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("ParticleEmitter") or instance:IsA("BasePart") and utility.findFirstClassWithTag(
					instance,
					"Attachment",
					utility.SHOCKWAVE_TAG
				)) then
					emitAll(depth + 1, instance:GetChildren(), list)
				end
			end
		end
	end

	emitAll(0, v8, v9)
	return {
		Finished = Promise.all(v9)
	}
end

return EmitModule