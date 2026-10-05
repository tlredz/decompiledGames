require(script.Parent.TypeDefinitions)
local TypeMarshaller = require(script.Parent.TypeMarshaller)
local ActiveCast = {}
ActiveCast.__index = ActiveCast
ActiveCast.__type = "ActiveCast"
local RunService = game:GetService("RunService")
local Table = require(script.Parent.Table)
local v = nil

local function GetFastCastVisualizationContainer()
	local fastCastVisualizationObjects = workspace.Terrain:FindFirstChild("FastCastVisualizationObjects")

	if fastCastVisualizationObjects ~= nil then
		return fastCastVisualizationObjects
	end

	local folder = Instance.new("Folder")
	folder.Name = "FastCastVisualizationObjects"
	folder.Archivable = false
	folder.Parent = workspace.Terrain
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PrintDebug(p: string)
	if v.DebugLogging == true then
		print(p)
	end
end

function DbgVisualizeSegment(cFrame: CFrame, height: number)
	if v.VisualizeCasts ~= true then
		return nil
	end

	local coneHandleAdornment = Instance.new("ConeHandleAdornment")
	coneHandleAdornment.Adornee = workspace.Terrain
	coneHandleAdornment.CFrame = cFrame
	coneHandleAdornment.Height = height
	coneHandleAdornment.Color3 = Color3.new()
	coneHandleAdornment.Radius = 0.25
	coneHandleAdornment.Transparency = 0.5
	local parent = workspace.Terrain:FindFirstChild("FastCastVisualizationObjects")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "FastCastVisualizationObjects"
		parent.Archivable = false
		parent.Parent = workspace.Terrain
	end

	coneHandleAdornment.Parent = parent
	return coneHandleAdornment
end

function DbgVisualizeHit(cFrame: CFrame, flag: boolean)
	if v.VisualizeCasts ~= true then
		return nil
	end

	local sphereHandleAdornment = Instance.new("SphereHandleAdornment")
	sphereHandleAdornment.Adornee = workspace.Terrain
	sphereHandleAdornment.CFrame = cFrame
	sphereHandleAdornment.Radius = 0.4
	sphereHandleAdornment.Transparency = 0.25
	sphereHandleAdornment.Color3 = flag == false and Color3.new(0.2, 1, 0.5) or Color3.new(1, 0.2, 0.2)
	local parent = workspace.Terrain:FindFirstChild("FastCastVisualizationObjects")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "FastCastVisualizationObjects"
		parent.Archivable = false
		parent.Parent = workspace.Terrain
	end

	sphereHandleAdornment.Parent = parent
	return sphereHandleAdornment
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPositionAtTime(p: number, origin: Vector3, initialVelocity: Vector3, acceleration: Vector3)
	local vector = Vector3.new(acceleration.X * p ^ 2 / 2, acceleration.Y * p ^ 2 / 2, acceleration.Z * p ^ 2 / 2)
	return origin + initialVelocity * p + vector
end

local function GetVelocityAtTime(p: number, vector: Vector3, vector2: Vector3)
	return vector + vector2 * p
end

local function GetTrajectoryInfo(p, p2: number)
	assert(p.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	local trajectory = p.StateInfo.Trajectories[p2]
	local v2 = trajectory.EndTime - trajectory.StartTime
	local origin = trajectory.Origin
	local initialVelocity = trajectory.InitialVelocity
	local acceleration = trajectory.Acceleration
	local vector = Vector3.new(acceleration.X * v2 ^ 2 / 2, acceleration.Y * v2 ^ 2 / 2, acceleration.Z * v2 ^ 2 / 2)
	return { origin + initialVelocity * v2 + vector, initialVelocity + acceleration * v2 }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetLatestTrajectoryEndInfo(p)
	assert(p.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	return (GetTrajectoryInfo(p, #p.StateInfo.Trajectories))
end

local function CloneCastParams(data)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = data.CollisionGroup
	raycastParams.FilterType = data.FilterType
	raycastParams.FilterDescendantsInstances = data.FilterDescendantsInstances
	raycastParams.RespectCanCollide = data.RespectCanCollide
	raycastParams.IgnoreWater = data.IgnoreWater
	return raycastParams
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SendRayHit(object, raycastResult: RaycastResult, vector: Vector3, cosmeticBulletObject)
	object.Caster.RayHit:Fire(object, raycastResult, vector, cosmeticBulletObject)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SendRayPierced(object, raycastResult: RaycastResult, vector: Vector3, cosmeticBulletObject)
	object.Caster.RayPierced:Fire(object, raycastResult, vector, cosmeticBulletObject)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SendLengthChanged(object, vector: Vector3, unit: Vector3, magnitude: number, vector2: Vector3, cosmeticBulletObject)
	object.Caster.LengthChanged:Fire(object, vector, unit, magnitude, vector2, cosmeticBulletObject)
end

local function SimulateCast(object, p: number, flag: boolean)
	assert(object.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	PrintDebug("Casting for frame.") -- equivalent call inferred; original call site unknown
	local trajectory = object.StateInfo.Trajectories[#object.StateInfo.Trajectories]
	local origin = trajectory.Origin
	local v2 = object.StateInfo.TotalRuntime - trajectory.StartTime
	local initialVelocity = trajectory.InitialVelocity
	local acceleration = trajectory.Acceleration
	local positionAtTime = GetPositionAtTime(v2, origin, initialVelocity, acceleration) -- equivalent call inferred; original call site unknown
	local _ = initialVelocity + acceleration * v2
	local v4 = object.StateInfo.TotalRuntime - trajectory.StartTime
	object.StateInfo.TotalRuntime += p
	local v5 = object.StateInfo.TotalRuntime - trajectory.StartTime
	local positionAtTime2 = GetPositionAtTime(v5, origin, initialVelocity, acceleration) -- equivalent call inferred; original call site unknown
	local v7 = initialVelocity + acceleration * v5
	local v8 = (positionAtTime2 - positionAtTime).Unit * v7.Magnitude * p
	local worldRoot = object.RayInfo.WorldRoot
	local raycastResult = worldRoot:Raycast(positionAtTime, v8, object.RayInfo.Parameters)
	local air = Enum.Material.Air
	Vector3.new()
	local position, instance

	if raycastResult == nil then
		position = positionAtTime2
	else
		position = raycastResult.Position
		instance = raycastResult.Instance
		air = raycastResult.Material
		local _ = raycastResult.Normal
	end

	local magnitude = (position - positionAtTime).Magnitude
	SendLengthChanged(object, positionAtTime, v8.Unit, magnitude, v7, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
	object.StateInfo.DistanceCovered += magnitude
	local v9

	if p > 0 then
		v9 = DbgVisualizeSegment(CFrame.new(positionAtTime, positionAtTime + v8), magnitude)
	end

	if instance and instance ~= object.RayInfo.CosmeticBulletObject then
		tick()
		PrintDebug("Hit something, testing now.") -- equivalent call inferred; original call site unknown

		if object.RayInfo.CanPierceCallback ~= nil then
			if flag == false and object.StateInfo.IsActivelySimulatingPierce then
				object:Terminate()
				error("ERROR: The latest call to CanPierceCallback took too long to complete! This cast is going to suffer desyncs which WILL cause unexpected behavior and errors. Please fix your performance problems, or remove statements that yield (e.g. wait() calls)")
			end

			object.StateInfo.IsActivelySimulatingPierce = true
		end

		if object.RayInfo.CanPierceCallback == nil or object.RayInfo.CanPierceCallback ~= nil and object.RayInfo.CanPierceCallback(
			object,
			raycastResult,
			v7,
			object.RayInfo.CosmeticBulletObject
		) == false then
			PrintDebug("Piercing function is nil or it returned FALSE to not pierce this hit.") -- equivalent call inferred; original call site unknown
			object.StateInfo.IsActivelySimulatingPierce = false

			if object.StateInfo.HighFidelityBehavior == 2 and trajectory.Acceleration ~= Vector3.new() and object.StateInfo.HighFidelitySegmentSize ~= 0 then
				object.StateInfo.CancelHighResCast = false

				if object.StateInfo.IsActivelyResimulating then
					object:Terminate()
					error("Cascading cast lag encountered! The caster attempted to perform a high fidelity cast before the previous one completed, resulting in exponential cast lag. Consider increasing HighFidelitySegmentSize.")
				end

				object.StateInfo.IsActivelyResimulating = true
				PrintDebug("Hit was registered, but recalculation is on for physics based casts. Recalculating to verify a real hit...") -- equivalent call inferred; original call site unknown
				local v10 = math.floor(magnitude / object.StateInfo.HighFidelitySegmentSize)
				local _ = magnitude / v10
				local v11 = p / v10

				for i = 1, v10 do
					if object.StateInfo.CancelHighResCast then
						object.StateInfo.CancelHighResCast = false
						break
					end

					local positionAtTime3 = GetPositionAtTime(v4 + v11 * i, origin, initialVelocity, acceleration) -- equivalent call inferred; original call site unknown
					local v14 = initialVelocity + acceleration * (v4 + v11 * i)
					local raycastResult2 = worldRoot:Raycast(positionAtTime3, v14 * p, object.RayInfo.Parameters)
					local magnitude2 = (positionAtTime3 - (positionAtTime3 + v14)).Magnitude

					if raycastResult2 == nil then
						local v15 = DbgVisualizeSegment(CFrame.new(positionAtTime3, positionAtTime3 + v14), magnitude2)

						if v15 ~= nil then
							v15.Color3 = Color3.new(0.286275, 0.329412, 0.247059)
						end
					else
						local magnitude3 = (positionAtTime3 - raycastResult2.Position).Magnitude
						local v15 = DbgVisualizeSegment(CFrame.new(positionAtTime3, positionAtTime3 + v14), magnitude3)

						if v15 ~= nil then
							v15.Color3 = Color3.new(0.286275, 0.329412, 0.247059)
						end

						if object.RayInfo.CanPierceCallback == nil or object.RayInfo.CanPierceCallback ~= nil and object.RayInfo.CanPierceCallback(
							object,
							raycastResult2,
							v14,
							object.RayInfo.CosmeticBulletObject
						) == false then
							object.StateInfo.IsActivelyResimulating = false
							SendRayHit(object, raycastResult2, v14, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
							object:Terminate()
							local v16 = DbgVisualizeHit(CFrame.new(position), false)

							if v16 ~= nil then
								v16.Color3 = Color3.new(0.0588235, 0.87451, 1)
							end

							return
						else
							SendRayPierced(object, raycastResult2, v14, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
							local v16 = DbgVisualizeHit(CFrame.new(position), true)

							if v16 ~= nil then
								v16.Color3 = Color3.new(1, 0.113725, 0.588235)
							end

							if v15 ~= nil then
								v15.Color3 = Color3.new(0.305882, 0.243137, 0.329412)
							end
						end
					end
				end

				object.StateInfo.IsActivelyResimulating = false
			elseif object.StateInfo.HighFidelityBehavior == 1 or object.StateInfo.HighFidelityBehavior == 3 then
				PrintDebug("Hit was successful. Terminating.") -- equivalent call inferred; original call site unknown
				SendRayHit(object, raycastResult, v7, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
				object:Terminate()
				DbgVisualizeHit(CFrame.new(position), false)
				return
			else
				object:Terminate()
				error("Invalid value " .. object.StateInfo.HighFidelityBehavior .. " for HighFidelityBehavior.")
			end
		else
			PrintDebug("Piercing function returned TRUE to pierce this part.") -- equivalent call inferred; original call site unknown

			if v9 ~= nil then
				v9.Color3 = Color3.new(0.4, 0.05, 0.05)
			end

			DbgVisualizeHit(CFrame.new(position), true)
			local parameters = object.RayInfo.Parameters
			local filterDescendantsInstances = parameters.FilterDescendantsInstances
			local v10 = {}
			local count = 0
			local v11 = false

			while true do
				if raycastResult.Instance:IsA("Terrain") then
					if air == Enum.Material.Water then
						object:Terminate()
						error(
							"Do not add Water as a piercable material. If you need to pierce water, set cast.RayInfo.Parameters.IgnoreWater = true instead",
							0
						)
					end

					warn("WARNING: The pierce callback for this cast returned TRUE on Terrain! This can cause severely adverse effects.")
				end

				if parameters.FilterType == Enum.RaycastFilterType.Blacklist then
					local filterDescendantsInstances2 = parameters.FilterDescendantsInstances
					Table.insert(filterDescendantsInstances2, raycastResult.Instance)
					Table.insert(v10, raycastResult.Instance)
					parameters.FilterDescendantsInstances = filterDescendantsInstances2
				else
					local filterDescendantsInstances2 = parameters.FilterDescendantsInstances
					Table.removeObject(filterDescendantsInstances2, raycastResult.Instance)
					Table.insert(v10, raycastResult.Instance)
					parameters.FilterDescendantsInstances = filterDescendantsInstances2
				end

				SendRayPierced(object, raycastResult, v7, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
				raycastResult = worldRoot:Raycast(positionAtTime, v8, parameters)

				if raycastResult ~= nil then
					if count >= 100 then
						warn("WARNING: Exceeded maximum pierce test budget for a single ray segment (attempted to test the same segment " .. 100 .. " times!)")
					else
						count += 1

						if object.RayInfo.CanPierceCallback(
							object,
							raycastResult,
							v7,
							object.RayInfo.CosmeticBulletObject
						) ~= false then
							continue
						end

						v11 = true
					end
				end

				object.RayInfo.Parameters.FilterDescendantsInstances = filterDescendantsInstances
				object.StateInfo.IsActivelySimulatingPierce = false

				if not v11 then
					break
				end

				PrintDebug("Broke because the ray hit something solid (" .. tostring(raycastResult.Instance) .. ") while testing for a pierce. Terminating the cast.") -- equivalent call inferred; original call site unknown
				SendRayHit(object, raycastResult, v7, object.RayInfo.CosmeticBulletObject) -- equivalent call inferred; original call site unknown
				object:Terminate()
				DbgVisualizeHit(CFrame.new(raycastResult.Position), false)
				return
			end
		end
	end

	if object.StateInfo.DistanceCovered >= object.RayInfo.MaxDistance then
		object:Terminate()
		DbgVisualizeHit(CFrame.new(positionAtTime2), false)
	end
end

function ActiveCast.new(caster, vector: Vector3, vector2: Vector3, initialVelocity2, state)
	if TypeMarshaller(initialVelocity2) == "number" then
		initialVelocity2 = vector2.Unit * initialVelocity2
	end

	if state.HighFidelitySegmentSize <= 0 then
		error("Cannot set FastCastBehavior.HighFidelitySegmentSize <= 0!", 0)
	end

	local v2 = {
		Caster = caster,
		StateInfo = {
			UpdateConnection = nil,
			Paused = false,
			TotalRuntime = 0,
			DistanceCovered = 0,
			HighFidelitySegmentSize = state.HighFidelitySegmentSize,
			HighFidelityBehavior = state.HighFidelityBehavior,
			IsActivelySimulatingPierce = false,
			IsActivelyResimulating = false,
			CancelHighResCast = false,
			Trajectories = {
				{
					StartTime = 0,
					EndTime = -1,
					Origin = vector,
					InitialVelocity = initialVelocity2,
					Acceleration = state.Acceleration
				}
			}
		},
		RayInfo = {
			Parameters = state.RaycastParams,
			WorldRoot = workspace,
			MaxDistance = state.MaxDistance or 1000,
			CosmeticBulletObject = state.CosmeticBulletTemplate,
			CanPierceCallback = state.CanPierceFunction
		},
		UserData = {}
	}

	if v2.StateInfo.HighFidelityBehavior == 2 then
		v2.StateInfo.HighFidelityBehavior = 3
	end

	if v2.RayInfo.Parameters == nil then
		v2.RayInfo.Parameters = RaycastParams.new()
	else
		local rayInfo = v2.RayInfo
		local parameters = v2.RayInfo.Parameters
		local raycastParams = RaycastParams.new()
		raycastParams.CollisionGroup = parameters.CollisionGroup
		raycastParams.FilterType = parameters.FilterType
		raycastParams.FilterDescendantsInstances = parameters.FilterDescendantsInstances
		raycastParams.RespectCanCollide = parameters.RespectCanCollide
		raycastParams.IgnoreWater = parameters.IgnoreWater
		rayInfo.Parameters = raycastParams
	end

	if state.CosmeticBulletProvider == nil then
		if v2.RayInfo.CosmeticBulletObject ~= nil then
			v2.RayInfo.CosmeticBulletObject = v2.RayInfo.CosmeticBulletObject:Clone()
			v2.RayInfo.CosmeticBulletObject.CFrame = CFrame.new(vector, vector + vector2)
			v2.RayInfo.CosmeticBulletObject.Parent = state.CosmeticBulletContainer
		end
	elseif TypeMarshaller(state.CosmeticBulletProvider) == "PartCache" then
		if v2.RayInfo.CosmeticBulletObject ~= nil then
			warn("Do not define FastCastBehavior.CosmeticBulletTemplate and FastCastBehavior.CosmeticBulletProvider at the same time! The provider will be used, and CosmeticBulletTemplate will be set to nil.")
			v2.RayInfo.CosmeticBulletObject = nil
			state.CosmeticBulletTemplate = nil
		end

		v2.RayInfo.CosmeticBulletObject = state.CosmeticBulletProvider:GetPart()
		v2.RayInfo.CosmeticBulletObject.CFrame = CFrame.new(vector, vector + vector2)
	else
		warn("FastCastBehavior.CosmeticBulletProvider was not an instance of the PartCache module (an external/separate model)! Are you inputting an instance created via PartCache.new? If so, are you on the latest version of PartCache? Setting FastCastBehavior.CosmeticBulletProvider to nil.")
		state.CosmeticBulletProvider = nil
	end

	local renderStepped

	if RunService:IsClient() then
		renderStepped = RunService.RenderStepped
	else
		renderStepped = RunService.Heartbeat
	end

	setmetatable(v2, ActiveCast)
	v2.StateInfo.UpdateConnection = renderStepped:Connect(function(p3)
		if v2.StateInfo.Paused then
			return
		end

		PrintDebug("Casting for frame.") -- equivalent call inferred; original call site unknown
		local trajectory = v2.StateInfo.Trajectories[#v2.StateInfo.Trajectories]

		if v2.StateInfo.HighFidelityBehavior == 3 and trajectory.Acceleration ~= Vector3.new() and v2.StateInfo.HighFidelitySegmentSize > 0 then
			local lastTime = tick()

			if v2.StateInfo.IsActivelyResimulating then
				v2:Terminate()
				error("Cascading cast lag encountered! The caster attempted to perform a high fidelity cast before the previous one completed, resulting in exponential cast lag. Consider increasing HighFidelitySegmentSize.")
			end

			v2.StateInfo.IsActivelyResimulating = true
			local origin = trajectory.Origin
			local v3 = v2.StateInfo.TotalRuntime - trajectory.StartTime
			local initialVelocity = trajectory.InitialVelocity
			local acceleration = trajectory.Acceleration
			local positionAtTime = GetPositionAtTime(v3, origin, initialVelocity, acceleration) -- equivalent call inferred; original call site unknown
			local _ = initialVelocity + acceleration * v3
			local _ = v2.StateInfo.TotalRuntime - trajectory.StartTime
			v2.StateInfo.TotalRuntime += p3
			local v5 = v2.StateInfo.TotalRuntime - trajectory.StartTime
			local position = GetPositionAtTime(v5, origin, initialVelocity, acceleration) -- equivalent call inferred; original call site unknown
			local v6 = initialVelocity + acceleration * v5
			local v7 = (position - positionAtTime).Unit * v6.Magnitude * p3
			local raycastResult = v2.RayInfo.WorldRoot:Raycast(positionAtTime, v7, v2.RayInfo.Parameters)

			if raycastResult ~= nil then
				position = raycastResult.Position
			end

			local magnitude = (position - positionAtTime).Magnitude
			v2.StateInfo.TotalRuntime -= p3
			local v8 = math.floor(magnitude / v2.StateInfo.HighFidelitySegmentSize)
			local v9 = v8 == 0 and 1 or v8
			local v10 = p3 / v9

			for i = 1, v9 do
				if getmetatable(v2) == nil then
					return
				end

				if v2.StateInfo.CancelHighResCast then
					v2.StateInfo.CancelHighResCast = false
					break
				end

				PrintDebug("[" .. i .. "] Subcast of time increment " .. v10) -- equivalent call inferred; original call site unknown
				SimulateCast(v2, v10, true)
			end

			if getmetatable(v2) == nil then
				return
			end

			v2.StateInfo.IsActivelyResimulating = false

			if tick() - lastTime > 0.08 then
				warn("Extreme cast lag encountered! Consider increasing HighFidelitySegmentSize.")
			end
		else
			SimulateCast(v2, p3, false)
		end
	end)
	return v2
end

function ActiveCast.SetStaticFastCastReference(p)
	v = p
end

local function ModifyTransformation(p, initialVelocity: Vector3?, acceleration: Vector3?, origin: Vector3?)
	local trajectories = p.StateInfo.Trajectories
	local trajectory = trajectories[#trajectories]

	if trajectory.StartTime == p.StateInfo.TotalRuntime then
		if initialVelocity == nil then
			initialVelocity = trajectory.InitialVelocity
		end

		if acceleration == nil then
			acceleration = trajectory.Acceleration
		end

		if origin == nil then
			origin = trajectory.Origin
		end

		trajectory.Origin = origin
		trajectory.InitialVelocity = initialVelocity
		trajectory.Acceleration = acceleration
	else
		trajectory.EndTime = p.StateInfo.TotalRuntime
		local v2, v3 = unpack(GetLatestTrajectoryEndInfo(p))

		if initialVelocity == nil then
			initialVelocity = v3
		end

		if acceleration == nil then
			acceleration = trajectory.Acceleration
		end

		if origin == nil then
			origin = v2
		end

		Table.insert(p.StateInfo.Trajectories, {
			StartTime = p.StateInfo.TotalRuntime,
			EndTime = -1,
			Origin = origin,
			InitialVelocity = initialVelocity,
			Acceleration = acceleration
		})
		p.StateInfo.CancelHighResCast = true
	end
end

function ActiveCast:SetVelocity(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"SetVelocity",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	ModifyTransformation(self, vector, nil, nil)
end

function ActiveCast:SetAcceleration(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"SetAcceleration",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	ModifyTransformation(self, nil, vector, nil)
end

function ActiveCast:SetPosition(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"SetPosition",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	ModifyTransformation(self, nil, nil, vector)
end

function ActiveCast:GetVelocity()
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"GetVelocity",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	local trajectory = self.StateInfo.Trajectories[#self.StateInfo.Trajectories]
	local v2 = self.StateInfo.TotalRuntime - trajectory.StartTime
	return trajectory.InitialVelocity + trajectory.Acceleration * v2
end

function ActiveCast:GetAcceleration()
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"GetAcceleration",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	return self.StateInfo.Trajectories[#self.StateInfo.Trajectories].Acceleration
end

function ActiveCast:GetPosition()
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"GetPosition",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	local trajectory = self.StateInfo.Trajectories[#self.StateInfo.Trajectories]
	return GetPositionAtTime(
		self.StateInfo.TotalRuntime - trajectory.StartTime,
		trajectory.Origin,
		trajectory.InitialVelocity,
		trajectory.Acceleration
	)
end

function ActiveCast:AddVelocity(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"AddVelocity",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	self:SetVelocity(self:GetVelocity() + vector)
end

function ActiveCast:AddAcceleration(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"AddAcceleration",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	self:SetAcceleration(self:GetAcceleration() + vector)
end

function ActiveCast:AddPosition(vector: Vector3)
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"AddPosition",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	self:SetPosition(self:GetPosition() + vector)
end

function ActiveCast.Pause(p)
	assert(
		getmetatable(p) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Pause",
			"ActiveCast.new(...)"
		)
	)
	assert(p.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	p.StateInfo.Paused = true
end

function ActiveCast.Resume(p)
	assert(
		getmetatable(p) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Resume",
			"ActiveCast.new(...)"
		)
	)
	assert(p.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	p.StateInfo.Paused = false
end

function ActiveCast:Terminate()
	assert(
		getmetatable(self) == ActiveCast,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Terminate",
			"ActiveCast.new(...)"
		)
	)
	assert(self.StateInfo.UpdateConnection ~= nil, "This ActiveCast has been terminated. It can no longer be used.")
	local trajectories = self.StateInfo.Trajectories
	trajectories[#trajectories].EndTime = self.StateInfo.TotalRuntime
	self.StateInfo.UpdateConnection:Disconnect()
	self.Caster.CastTerminating:FireSync(self)
	self.StateInfo.UpdateConnection = nil
	self.Caster = nil
	self.StateInfo = nil
	self.RayInfo = nil
	self.UserData = nil
	setmetatable(self, nil)
end

return ActiveCast