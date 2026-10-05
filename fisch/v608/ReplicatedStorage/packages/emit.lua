local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local logger = require(script.mod.logger)
local utility = require(script.mod.utility)
local beam = require(script.effects.beam)
local spin = require(script.effects.spin)
local mesh = require(script.effects.mesh)
local bezier = require(script.effects.bezier)
local screen = require(script.effects.screen)
local particle = require(script.effects.particle)
local camera_shake = require(script.effects.camera_shake)
local tween_property = require(script.effects.tween_property)
local shockwave_ring = require(script.effects.shockwave_ring)
local shockwave_line = require(script.effects.shockwave_line)
local shockwave_debris = require(script.effects.shockwave_debris)
local Promise = require(script.pkg.Promise)
local ObjectCache = require(script.obj.ObjectCache)
local plugin = script:FindFirstAncestorOfClass("Plugin")
local v = RunService:IsServer() or plugin
local Emit = {
	scope = {},
	setup = false
}

local function assembleMeshVFX(part, list)
	if not Emit.setup then
		logger.error("API not initialized")
	end

	local ranomId = utility.getRanomId()

	if part:IsA("Part") then
		local v2 = Emit.caches.shared_part:get(ranomId)
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
			Emit.caches.shared_part:free(ranomId)
		end)
		return v2
	else
		local clone = part:Clone()
		clone.Archivable = false
		clone.Locked = true
		clone.Parent = workspace.Terrain
		table.insert(list, clone)
		return clone
	end
end

function Emit.init(_)
	if Emit.setup then
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

	Emit.setup = true

	if RunService:IsServer() and not plugin then
		return
	end

	shared.vfx = Emit
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Locked = true
	local folder = Instance.new("Folder")
	folder.Name = "DO_NOT_REMOVE_ForgeSharedPartCache"
	folder.Archivable = false
	folder.Parent = workspace.Terrain
	utility.protectParent(Emit.scope, folder)
	local shared_part = ObjectCache.new(part, folder, {
		size = 150,
		on_free = function(p)
			local value = p.value
			value.Transparency = 1
			value.Anchored = true
			value.CanQuery = false
			value.CanCollide = false
			value.CollisionGroup = "ForgeMouseIgnore"
			value.AssemblyLinearVelocity = createVector(0, 0, 0)
			value.AssemblyAngularVelocity = createVector(0, 0, 0)
			value:ClearAllChildren()
		end
	})
	Emit.caches = {
		shared_part = shared_part
	}
	table.insert(Emit.scope, function()
		shared_part:destroy()
	end)
	camera_shake.init()
	bezier.init(shared_part)
	shockwave_ring.init(shared_part)
	shockwave_line.init(shared_part)
	shockwave_debris.init(shared_part)
	local decal = Instance.new("Decal")
	local part2 = Instance.new("Part")
	part2.Name = "DO_NOT_REMOVE_ForgeTextureCache"
	part2.Transparency = 1
	part2.Size = createVector(0, 0, 0)
	part2.Archivable = false
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.Locked = true
	part2.Parent = workspace.Terrain
	utility.protectParent(Emit.scope, part2)
	local v3 = ObjectCache.new(decal, part2, {
		size = 360,
		on_free = function(p)
			p.value.Texture = ""
		end
	})
	local v4 = {}

	local function loadTextures(folder2)
		if folder2:IsDescendantOf(workspace.Terrain) then
			return
		end

		if utility.isMeshVFX(folder2) then
			local start = folder2:FindFirstChild("Start")

			if not (start and start:IsA("BasePart")) then
				return
			end

			local v5 = {}
			local v6 = {}
			table.insert(v5, v6)

			local function refresh()
				utility.cleanupScope(v6)
				local meshDecals, v7 = utility.getMeshDecals(folder2, start)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function add(texture)
					if typeof(texture) == "Instance" then
						texture = texture.Texture or texture
					end

					if texture == "" then
						return
					end

					local get = v3:get(texture)
					get.Texture = texture
					table.insert(v6, function()
						v3:free(texture)
					end)
				end

				for _, texture in meshDecals do
					if typeof(texture) == "Instance" then
						texture = texture.Texture or texture
					end

					if texture == "" then
						continue
					end

					local get = v3:get(texture)
					get.Texture = texture
					local v8 = texture
					table.insert(v6, function()
						v3:free(v8)
					end)
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
						add(`{v9 and "rbxtemp://" or "rbxassetid://"}{v10}`) -- equivalent call inferred; original call site unknown
					end
				end
			end

			refresh()

			if plugin then
				local reboundfn = utility.reboundfn(1, refresh)
				table.insert(v5, start.DescendantAdded:Connect(reboundfn))
				table.insert(v5, start.DescendantRemoving:Connect(reboundfn))
			end

			v4[folder2] = v5
		else
			local v5 = {}
			local v6 = {}
			table.insert(v5, v6)

			local function refresh()
				utility.cleanupScope(v6)

				local function check(emitter)
					if not emitter:IsA("ParticleEmitter") then
						return
					end

					local texture = emitter.Texture

					if texture == "" then
						return
					end

					local get = v3:get(texture)
					get.Texture = texture
					table.insert(v6, function()
						v3:free(texture)
					end)
				end

				check(folder2)

				for _, descendant in folder2:GetDescendants() do
					check(descendant)
				end
			end

			refresh()

			if plugin then
				local reboundfn = utility.reboundfn(1, refresh)
				table.insert(v5, folder2.DescendantAdded:Connect(reboundfn))
				table.insert(v5, folder2.DescendantRemoving:Connect(reboundfn))
			end

			v4[folder2] = v5
		end
	end

	for _, v5 in CollectionService:GetTagged(utility.TEXTURE_LOAD_TAG) do
		loadTextures(v5)
	end

	CollectionService:GetInstanceAddedSignal(utility.TEXTURE_LOAD_TAG):Connect(loadTextures)
	CollectionService:GetInstanceRemovedSignal(utility.TEXTURE_LOAD_TAG):Connect(function(p)
		local v5 = v4[p]

		if v5 then
			utility.cleanupScope(v5)
			v4[p] = nil
		end
	end)
	table.insert(Emit.scope, function()
		v3:destroy()

		for _, v5 in v4 do
			utility.cleanupScope(v5)
		end
	end)
	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeEnabledEffect(p)
		local v6 = v5[p]

		if v6 then
			utility.cleanupScope(v6)
		end

		v5[p] = nil
	end

	local addEnabledEffect

	addEnabledEffect = function(instance)
		local meshVFX = utility.isMeshVFX(instance)
		local hasTag = instance:HasTag(utility.BEZIER_TAG)

		if not (meshVFX or hasTag) then
			return
		end

		local v6 = {}
		local connections = {}
		table.insert(v6, connections)
		v5[instance] = v6
		table.insert(v6, instance.AncestryChanged:Connect(function()
			if instance:IsDescendantOf(workspace) or instance.Parent and instance.Parent:HasTag("AllowEmitting") then
				if not v5[instance] then
					addEnabledEffect(instance)
				end
			else
				removeEnabledEffect(instance) -- equivalent call inferred; original call site unknown
			end
		end))

		if not instance:IsDescendantOf(workspace) then
			local v7

			if instance.Parent then
				v7 = not instance.Parent:HasTag("AllowEmitting")
			else
				v7 = false
			end

			if v7 then
				return
			end
		end

		local function onEnabled()
			if not utility.getAttribute(instance, "Enabled", true) then
				utility.cleanupScope(connections)
				return
			end

			local now = 0
			table.insert(connections, RunService.RenderStepped:Connect(function()
				local attribute = utility.getAttribute(instance, "Rate", 5)
				local speedOverride = instance:GetAttribute("SpeedOverride") or 1

				if speedOverride == 0 or os.clock() - now <= 1 / attribute / speedOverride then
					return
				end

				local clones = {
					depth = 0
				}

				-- equivalent calls inferred from this helper; original call sites unknown
				local function cleanup()
					utility.cleanupScope(clones)
				end

				table.insert(Emit.scope, cleanup)

				if meshVFX then
					local start = instance:FindFirstChild("Start")

					if not start then
						instance:RemoveTag(utility.ENABLED_VFX_TAG)
						return
					end

					now = os.clock()

					for _ = 1, utility.getAttribute(instance, "EmitCount", 1) do
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
				elseif hasTag then
					local part3 = instance:FindFirstChildOfClass("Part")

					if not part3 then
						return
					end

					now = os.clock()
					local clone = part3:Clone()
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

				local index = table.find(Emit.scope, cleanup)

				if index then
					table.remove(Emit.scope, index)
				end

				cleanup() -- equivalent call inferred; original call site unknown
			end))
		end

		table.insert(v6, instance:GetAttributeChangedSignal("Enabled"):Connect(onEnabled))
		onEnabled()
	end

	for _, v6 in CollectionService:GetTagged(utility.ENABLED_VFX_TAG) do
		addEnabledEffect(v6)
	end

	CollectionService:GetInstanceAddedSignal(utility.ENABLED_VFX_TAG):Connect(addEnabledEffect)
	CollectionService:GetInstanceRemovedSignal(utility.ENABLED_VFX_TAG):Connect(removeEnabledEffect)
	table.insert(Emit.scope, function()
		for _, v6 in v5 do
			utility.cleanupScope(v6)
		end
	end)
end

function Emit.deinit()
	if not Emit.setup then
		return
	end

	Emit.setup = false
	shared.vfx = nil

	if RunService:IsServer() and not plugin then
		return
	end

	utility.cleanupScope(Emit.scope)
	bezier.deinit()
	camera_shake.deinit()
	shockwave_ring.deinit()
	shockwave_line.deinit()
	shockwave_debris.deinit()
end

function Emit.emit(value, ...)
	if not Emit.setup then
		logger.error("not initialized")
	end

	local v2 = {}
	local v3 = {}
	local v4 = 1

	local function emit(part, depth: number)
		return Promise.new(function(callback)
			local function run()
				local v5 = {
					depth = depth
				}

				if part:IsA("ParticleEmitter") then
					if part:IsDescendantOf(workspace) then
						utility.try(
							`failed to emit particle '{part:GetFullName()}' with error: %s`,
							particle.emit,
							part,
							part,
							v5,
							v4
						)
						utility.cleanupScope(v5)
					else
						local particleAncestry, v6 = utility.cloneParticleAncestry(part, v3)

						if not particleAncestry then
							return
						end

						table.insert(v5, v6)
						local clone = part:Clone()
						clone.Archivable = false
						clone.Parent = particleAncestry

						if not v2[v6] then
							v6.Parent = workspace.Terrain
						end

						if v2[v6] then
							v2[v6] += 1
						else
							v2[v6] = 1
						end

						utility.try(
							`failed to emit particle '{part:GetFullName()}' with error: %s`,
							particle.emit,
							part,
							clone,
							v5,
							v4
						)
						v2[v6] -= 1

						if v2[v6] <= 0 then
							utility.cleanupScope(v5)
						end
					end
				elseif part:IsA("Beam") then
					local clone = part:Clone()
					clone.Archivable = false
					clone.Parent = workspace.Terrain
					table.insert(v5, clone)
					utility.try(
						`failed to emit beam '{part:GetFullName()}' with error: %s`,
						beam.emit,
						part,
						clone,
						v5,
						v4
					)
					utility.cleanupScope(v5)
				elseif part:IsA("Trail") then
					part.Enabled = true
				elseif part:HasTag(utility.BEZIER_TAG) then
					local part2 = part:FindFirstChildOfClass("Part")

					if not part2 then
						return
					end

					if part:GetAttribute("Enabled") then
						part:SetAttribute("Enabled", false)
					end

					local clone = part2:Clone()
					clone.Locked = true
					table.insert(v5, clone)
					utility.try(
						`failed to emit bezier '{part:GetFullName()}' with error: %s`,
						bezier.emit,
						part,
						clone,
						v5
					)
					utility.cleanupScope(v5)
				elseif utility.isMeshVFX(part) then
					local start = part:FindFirstChild("Start")

					if not start then
						return
					end

					if part:GetAttribute("Enabled") then
						part:SetAttribute("Enabled", false)
					end

					local v6 = {}

					for _ = 1, utility.getAttribute(part, "EmitCount", 1) do
						table.insert(v6, Promise.new(function(callback2)
							utility.try(
								`failed to emit mesh '{part:GetFullName()}' with error: %s`,
								mesh.emit,
								part,
								assembleMeshVFX(start, v5),
								v5,
								v4
							)
							callback2()
						end))
					end

					Promise.all(v6):await()
					utility.cleanupScope(v5)
				elseif part:IsA("Model") then
					if utility.lock(part) then
						return
					end

					utility.try(
						`failed to emit spinning model '{part:GetFullName()}' with error: %s`,
						spin.emit,
						part,
						v5
					)
					utility.cleanupScope(v5)
					utility.unlock(part)
				elseif part:IsA("RayValue") then
					if part:HasTag(utility.SCREENSHAKE_TAG) then
						utility.try(
							`failed to emit camera shake '{part:GetFullName()}' with error: %s`,
							camera_shake.emit,
							part,
							v5
						)
						utility.cleanupScope(v5)
					elseif part.Parent and not utility.lock(part) then
						utility.try(
							`failed to emit tween property '{part:GetFullName()}' with error: %s`,
							tween_property.emit,
							part.Parent,
							part,
							v5
						)
						utility.unlock(part)
						utility.cleanupScope(v5)
					else
						return
					end
				end

				local v6 = part:IsA("Part") and utility.findFirstClassWithTag(part, "Attachment", utility.SHOCKWAVE_TAG)

				if v6 then
					local name = part.Parent.Name

					if name == "Rings" then
						utility.try(
							`failed to emit shockwave ring '{part:GetFullName()}' with error: %s`,
							shockwave_ring.emit,
							v6,
							part,
							v5
						)
						utility.cleanupScope(v5)
					elseif name == "Debris" then
						utility.try(
							`failed to emit shockwave debris '{part:GetFullName()}' with error: %s`,
							shockwave_debris.emit,
							v6,
							part,
							v5
						)
						utility.cleanupScope(v5)
					elseif name == "Lines" then
						utility.try(
							`failed to emit shockwave line '{part:GetFullName()}' with error: %s`,
							shockwave_line.emit,
							v6,
							part,
							v5
						)
						utility.cleanupScope(v5)
					end
				end
			end

			run()
			callback()
		end)
	end

	local v5 = { ... }

	if typeof(value) == "number" then
		v4 = value
	else
		table.insert(v5, value)
	end

	local v6 = {}
	local emitAll

	emitAll = function(depth: number, items, list)
		for _, part in items do
			if part:IsA("BasePart") and part:GetAttribute("Enabled") and not utility.findFirstClassWithTag(
				part,
				"Attachment",
				utility.SHOCKWAVE_TAG
			) then
				if not utility.lock(part) then
					local model = part:FindFirstAncestorOfClass("Model")

					if not model or model:GetAttribute("SpinRotation") == createVector(0, 0, 0) and model:GetAttribute("Scale_Start") == 1 and model:GetAttribute("Scale_End") == 1 then
						local thread = coroutine.running()
						local v7 = {
							depth = depth
						}

						if utility.try(
							`failed to emit screen effect '{part:GetFullName()}' with error: %s`,
							screen.emit,
							part,
							v7
						) then
							if #part:GetDescendants() == 0 then
								utility.cleanupScope(v7)
								break
							end

							local v8 = {}
							emitAll(depth + 1, part:GetChildren(), v8)
							local v9 = part
							local v10 = thread
							local v11 = v7
							table.insert(v6, Promise.all(v8):finally(function()
								utility.unlock(v9, v10)
								utility.cleanupScope(v11)
							end))
						end
					end
				end
			else
				table.insert(list, emit(part, depth))

				if not (part:HasTag(utility.BEZIER_TAG) or utility.isMeshVFX(part) or part:IsA("BasePart") and utility.findFirstClassWithTag(
					part,
					"Attachment",
					utility.SHOCKWAVE_TAG
				)) then
					emitAll(depth + 1, part:GetChildren(), list)
				end
			end
		end
	end

	emitAll(0, v5, v6)
	return {
		Finished = Promise.all(v6)
	}
end

return Emit