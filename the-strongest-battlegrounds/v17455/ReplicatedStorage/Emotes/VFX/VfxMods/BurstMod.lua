local createVector = vector.create
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local random = Random.new()
local _ = {
	raycastDownMax = 1000,
	radiusMin = 6,
	radiusMax = 18,
	arcHeightMin = 6,
	arcHeightMax = 14,
	durationMin = 0.45,
	durationMax = 0.95,
	sizeMin = 0.6,
	sizeMax = 2,
	transparency = 0,
	canCollideInFlight = false,
	canCollideOnLand = true,
	anchorOnLand = true,
	randomSpawnOrientation = true,
	spinDuringFlight = true,
	spinSpeedMin = 2,
	spinSpeedMax = 6,
	copyFloorAppearance = true,
	cleanupAfter = 8,
	maxFlightSeconds = 2.5,
	ghostThroughOnLand = false,
	ghostDistanceMin = nil,
	ghostDistanceMax = nil,
	ghostSecondsMin = 0.25,
	ghostSecondsMax = 0.6,
	ghostSpeedMin = nil,
	ghostSpeedMax = nil
}

-- equivalent calls inferred from this helper; original call sites unknown
local function choose(p: number, p2: number)
	return random:NextNumber(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unitXZ(vector2: Vector3)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)
	local magnitude = vector3.Magnitude
	return magnitude > 1e-6 and vector3 / magnitude or createVector(1, 0, 0)
end

local function quadBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v = 1 - p
	return vector2 * (v * v) + vector3 * (v * 2 * p) + vector4 * (p * p)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function quadBezierDeriv(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return (1 - p) * 2 * (vector3 - vector2) + p * 2 * (vector4 - vector3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rayDown(origin: Vector3, raycastDownMax: number, raycastParams)
	return workspace:Raycast(origin, Vector3.new(0, -raycastDownMax, 0), raycastParams)
end

local function rayDownAround(vector2: Vector3, p: number, p2: number, p3)
	return workspace:Raycast(vector2 + Vector3.new(0, p, 0), Vector3.new(0, -p - p2, 0), p3)
end

local function ensureTrail(folder)
	local trails = {}

	for _, trail in ipairs(folder:GetDescendants()) do
		if trail:IsA("Trail") then
			table.insert(trails, trail)
		end
	end

	if #trails == 0 then
		return
	end

	local attachment = folder:FindFirstChild("TrailAttachment0")
	local attachment2 = folder:FindFirstChild("TrailAttachment1")

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "TrailAttachment0"
		attachment.Parent = folder
	end

	if not attachment2 then
		attachment2 = Instance.new("Attachment")
		attachment2.Name = "TrailAttachment1"
		attachment2.Parent = folder
	end

	local v3 = folder.Size * 0.5
	attachment.Position = Vector3.new(0, v3.Y - 0.01, 0)
	attachment2.Position = Vector3.new(0, -v3.Y + 0.01, 0)

	for _, v4 in ipairs(trails) do
		if not v4.Attachment0 then
			v4.Attachment0 = attachment
		end

		if not v4.Attachment1 then
			v4.Attachment1 = attachment2
		end
	end
end

local function cloneOrBuild(templatePart, p: number, transparency: number, collisionGroup: string?)
	local v

	if templatePart then
		v = templatePart:Clone()
		v.Parent = workspace.Thrown
		v.Size = Vector3.new(p, p, p)
	else
		v = Instance.new("Part")
		v.Shape = Enum.PartType.Block
		v.Size = Vector3.new(p, p, p)
		v.TopSurface = Enum.SurfaceType.Smooth
		v.BottomSurface = Enum.SurfaceType.Smooth
		v.Name = "VFX_Cube"
		v.Parent = workspace.Thrown
	end

	game.Debris:AddItem(v, 25)
	v.Transparency = transparency
	v.Anchored = true
	v.CanCollide = false

	if collisionGroup then
		v.CollisionGroup = collisionGroup
	end

	ensureTrail(v)
	return v
end

local function outwardLanding(vector2: Vector3, vector3: Vector3, radiusMin: number, p: number, raycastDownMax: number, raycastParams)
	local v2 = unitXZ(vector2 - vector3) -- equivalent call inferred; original call site unknown
	local number = random:NextNumber(-3.141592653589793, 3.141592653589793)
	local unit = CFrame.fromAxisAngle(createVector(0, 1, 0), number):VectorToWorldSpace(v2).Unit
	local v3 = vector2 + (unit.Magnitude < 1e-6 and createVector(1, 0, 0) or unit) * random:NextNumber(radiusMin, p)
	local raycastResult = workspace:Raycast(
		v3 + createVector(0, 120, 0),
		Vector3.new(0, -120 - raycastDownMax, 0),
		raycastParams
	)

	if raycastResult then
		return raycastResult.Position, raycastResult.Normal, raycastResult.Instance
	end

	return v3, createVector(0, 1, 0), nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function controlPoint(vector2: Vector3, vector3: Vector3, p: number)
	return (vector2 + vector3) * 0.5 + Vector3.new(0, p, 0)
end

local function randomOrientation()
	return CFrame.fromEulerAnglesXYZ(
		random:NextNumber(-3.141592653589793, 3.141592653589793),
		random:NextNumber(-3.141592653589793, 3.141592653589793),
		choose(-3.141592653589793, 3.141592653589793)
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotationOnly(cFrame: CFrame)
	return CFrame.fromMatrix(createVector(0, 0, 0), cFrame.XVector, cFrame.YVector, cFrame.ZVector)
end

local function isValidPart(instance)
	return instance ~= nil and instance.Parent ~= nil and instance:IsDescendantOf(workspace)
end

local function startGhostVelocity(p, vector2: Vector3, vector3: Vector3, magnitude: number, vector4: Vector3, data)
	local unit = vector3.Magnitude > 1e-6 and vector3.Unit or createVector(-0, -1, -0)
	local _ = vector4.Magnitude > 0 and vector4.Unit
	local ghostDistMode

	if data.ghostDistanceMin == nil then
		ghostDistMode = false
	else
		ghostDistMode = data.ghostDistanceMax ~= nil
	end

	p.ghostDistMode = ghostDistMode

	if ghostDistMode then
		local v2 = math.max(0.01, data.ghostDistanceMin)
		p.ghostRemainingDist = random:NextNumber(v2, (math.max(v2, data.ghostDistanceMax)))
	else
		local ghostSecondsMin = data.ghostSecondsMin or 0.25
		p.ghostSecondsLeft = random:NextNumber(
			ghostSecondsMin,
			(math.max(ghostSecondsMin + 0.001, data.ghostSecondsMax or 0.6))
		)
		local ghostSpeedMin = data.ghostSpeedMin
		local ghostSpeedMax = data.ghostSpeedMax

		if ghostSpeedMin == nil or ghostSpeedMax == nil then
			p.ghostSpeed = math.clamp(magnitude, 0.01, 500)
		else
			p.ghostSpeed = random:NextNumber(ghostSpeedMin, (math.max(ghostSpeedMin, ghostSpeedMax)))
		end
	end

	p.phase = "ghost"
	p.part.CanCollide = false
	p.ghostDir = unit
	local v2 = vector2 + unit * 0.03
	local part = p.part
	local cframe = CFrame.new(v2)
	local cFrame = p.part.CFrame
	part.CFrame = cframe * CFrame.fromMatrix(createVector(0, 0, 0), cFrame.XVector, cFrame.YVector, cFrame.ZVector)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishShard(state)
	state.part.Anchored = state.anchorOnLand
	state.part.CanCollide = state.canCollideOnLand
	state.phase = "done"
end

local function spawnBurst(data)
	print("SPAWNIN G BURST")
	local raycastDownMax = data.raycastDownMax or 1000
	local radiusMin = data.radiusMin or 6
	local v = math.max(data.radiusMax or 18, radiusMin + 0.01)
	local arcHeightMin = data.arcHeightMin or 6
	local v2 = math.max(data.arcHeightMax or 14, arcHeightMin + 0.01)
	local durationMin = data.durationMin or 0.45
	local v3 = math.max(data.durationMax or 0.95, durationMin + 0.01)
	local sizeMin = data.sizeMin or 0.6
	local v4 = math.max(data.sizeMax or 2, sizeMin + 0.01)
	local transparency = data.transparency or 0
	local canCollideInFlight

	if data.canCollideInFlight == nil then
		canCollideInFlight = false
	else
		canCollideInFlight = data.canCollideInFlight or false
	end

	local canCollideOnLand = data.canCollideOnLand == nil or (data.canCollideOnLand or true)
	local anchorOnLand = data.anchorOnLand == nil or (data.anchorOnLand or true)
	local v7 = data.randomSpawnOrientation == nil or (data.randomSpawnOrientation or true)
	local spinDuring = data.spinDuringFlight == nil or (data.spinDuringFlight or true)
	local spinSpeedMin = data.spinSpeedMin or 2
	local v9 = math.max(data.spinSpeedMax or 6, spinSpeedMin + 0.001)
	local v10 = data.copyFloorAppearance == nil or (data.copyFloorAppearance or true)
	local cleanupAfter = data.cleanupAfter or 8
	local maxFlightSeconds = data.maxFlightSeconds or 2.5
	local ghostThroughOnLand

	if data.ghostThroughOnLand == nil then
		ghostThroughOnLand = false
	else
		ghostThroughOnLand = data.ghostThroughOnLand or false
	end

	local v11 = math.max(0, (math.floor(data.amount)))

	if v11 == 0 then
		return
	end

	local origin = data.origin
	local raycastParams = data.raycastParams
	local v12 = rayDown(origin, raycastDownMax, raycastParams) -- equivalent call inferred; original call site unknown

	if not v12 then
		return
	end

	local v13 = v12.Position + v12.Normal * 0.05
	local vector2 = Vector3.new(origin.X, v13.Y, origin.Z)
	local v14 = {}

	for _ = 1, v11 do
		local v15 = choose(sizeMin, v4) -- equivalent call inferred; original call site unknown
		local folder = cloneOrBuild(data.templatePart, v15, transparency, data.collisionGroup)
		folder.CanCollide = canCollideInFlight
		local landTarget, landNormal, landHit = outwardLanding(
			v13,
			vector2,
			radiusMin,
			v,
			raycastDownMax,
			raycastParams
		)
		local v19 = v13 + Vector3.new(0, random:NextNumber(1.5, 3), 0)
		local v20 = choose(arcHeightMin, v2) -- equivalent call inferred; original call site unknown
		local v21 = controlPoint(v19, landTarget, v20) -- equivalent call inferred; original call site unknown
		local tSpeed = 1 / math.max(0.004166666666666667, (random:NextNumber(durationMin, v3)))
		folder.CFrame = v7 and CFrame.fromEulerAnglesXYZ(
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			choose(-3.141592653589793, 3.141592653589793)
		) + v19 or CFrame.new(v19)

		if v10 then
			local instance

			if v12.Instance and v12.Instance:IsA("BasePart") then
				instance = v12.Instance or nil
			end

			if instance then
				if instance.Material == Enum.Material.Grass then
					folder.Material = game.Workspace.Preload.Dirt.Material
					folder.Color = game.Workspace.Preload.Dirt.Color
				else
					folder.Material = instance.Material
					folder.Color = instance.Color
				end
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Color = ColorSequence.new(folder.Color)
				end
			end
		end

		table.insert(v14, {
			part = folder,
			p0 = v19,
			p1 = v21,
			p2 = landTarget,
			t = 0,
			tSpeed = tSpeed,
			spin = Vector3.new(
				random:NextNumber(spinSpeedMin, v9) * (random:NextNumber() < 0.5 and -1 or 1),
				random:NextNumber(spinSpeedMin, v9) * (random:NextNumber() < 0.5 and -1 or 1),
				random:NextNumber(spinSpeedMin, v9) * (random:NextNumber() < 0.5 and -1 or 1)
			),
			spinDuring = spinDuring,
			elapsed = 0,
			onLand = data.onLand,
			canCollideOnLand = canCollideOnLand,
			anchorOnLand = anchorOnLand,
			landTarget = landTarget,
			landNormal = landNormal,
			landHit = landHit,
			cleanupAfter = cleanupAfter,
			ghostEnabled = ghostThroughOnLand,
			ghostDistMode = false,
			ghostRemainingDist = 0,
			ghostSecondsLeft = 0,
			ghostSpeed = 0,
			ghostDir = createVector(-0, -1, -0),
			phase = "air"
		})
	end

	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if #v14 == 0 then
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		else
			for i = #v14, 1, -1 do
				local v15 = v14[i]
				local part = v15.part
				local v16

				if part == nil or part.Parent == nil then
					v16 = false
				else
					v16 = part:IsDescendantOf(workspace)
				end

				if v16 then
					local v17 = v15
					local v18 = i
					local success, result = pcall(function()
						local DISTANCE_THRESHOLD = 0

						-- [DEDUP] synthesized from 3 duplicated terminal regions
						local function deduplicatedTail()
							if v17.cleanupAfter and v17.cleanupAfter > 0 then
								Debris:AddItem(v17.part, v17.cleanupAfter)
							end

							table.remove(v14, v18)
						end

						if v17.phase == "air" then
							v17.elapsed += dt
							v17.t += v17.tSpeed * dt
							local v21 = math.clamp(v17.t, 0, 1)
							local p0 = v17.p0
							local p1 = v17.p1
							local p2 = v17.p2
							local v22 = 1 - v21
							local landTarget = p0 * (v22 * v22) + p1 * (v22 * 2 * v21) + p2 * (v21 * v21)

							if landTarget ~= landTarget then
								landTarget = v17.landTarget
								v21 = 1
							end

							local v23 = rotationOnly(v17.part.CFrame) -- equivalent call inferred; original call site unknown

							if v17.spinDuring and v17.spin.Magnitude > DISTANCE_THRESHOLD then
								v23 = v23 * CFrame.fromAxisAngle(createVector(1, 0, 0), v17.spin.X * dt) * CFrame.fromAxisAngle(
									createVector(0, 1, 0),
									v17.spin.Y * dt
								) * CFrame.fromAxisAngle(createVector(0, 0, 1), v17.spin.Z * dt)
							end

							v17.part.CFrame = CFrame.new(landTarget) * v23

							if v21 >= 0.6 then
								local v24 = landTarget + createVector(0, 2, 0)
								local raycastResult = workspace:Raycast(v24, createVector(0, -6, 0), raycastParams)

								if raycastResult and (landTarget.Y - raycastResult.Position.Y <= v17.part.Size.Y * 0.5 + 0.08 or v21 >= 1) then
									if data.copyFloorAppearance ~= false and raycastResult.Instance and raycastResult.Instance:IsA("BasePart") then
										local instance = raycastResult.Instance
										v17.part.Material = instance.Material
										v17.part.Color = instance.Color
									end

									if v17.onLand then
										task.spawn(function()
											local success2, result2 = pcall(
												v17.onLand,
												v17.part,
												raycastResult.Position,
												raycastResult.Normal,
												raycastResult.Instance
											)

											if not success2 then
												warn("BezierBurst onLand error: ", result2)
											end
										end)
									end

									if v17.ghostEnabled then
										local v26 = quadBezierDeriv(v17.p0, v17.p1, v17.p2, v21) * v17.tSpeed
										local magnitude = v26.Magnitude
										local v27 = not (magnitude > 1e-6) and createVector(-0, -1, -0) or v26 / magnitude or createVector(
											-0,
											-1,
											-0
										)
										startGhostVelocity(
											v17,
											raycastResult.Position,
											v27,
											magnitude,
											raycastResult.Normal,
											data
										)
										return
									else
										local v26 = raycastResult.Position + raycastResult.Normal * (v17.part.Size.Y * 0.5 + 0.02)
										local part2 = v17.part
										local cframe = CFrame.new(v26)
										local cFrame2 = v17.part.CFrame
										part2.CFrame = cframe * CFrame.fromMatrix(
											createVector(0, 0, 0),
											cFrame2.XVector,
											cFrame2.YVector,
											cFrame2.ZVector
										)
										finishShard(v17) -- equivalent call inferred; original call site unknown
										return deduplicatedTail()
									end
								end
							end

							if not (v21 >= 1) and not (maxFlightSeconds <= v17.elapsed) then
								return
							end

							if v17.onLand then
								task.spawn(function()
									local success2, result2 = pcall(
										v17.onLand,
										v17.part,
										v17.landTarget,
										v17.landNormal,
										v17.landHit
									)

									if not success2 then
										warn("BezierBurst onLand error: ", result2)
									end
								end)
							end

							if v17.ghostEnabled then
								local v25 = quadBezierDeriv(v17.p0, v17.p1, v17.p2, v21 >= 1 and 1 or v21) * v17.tSpeed
								local magnitude = v25.Magnitude
								local v26 = not (magnitude > 1e-6) and createVector(-0, -1, -0) or v25 / magnitude or createVector(
									-0,
									-1,
									-0
								)
								startGhostVelocity(
									v17,
									v17.landTarget,
									v26,
									magnitude,
									v17.landNormal.Magnitude > DISTANCE_THRESHOLD and v17.landNormal or createVector(
										0,
										1,
										0
									),
									data
								)
							else
								local v24 = v17.landTarget + v17.landNormal * (v17.part.Size.Y * 0.5 + 0.02)
								local part2 = v17.part
								local cframe = CFrame.new(v24)
								local cFrame2 = v17.part.CFrame
								part2.CFrame = cframe * CFrame.fromMatrix(
									createVector(0, 0, 0),
									cFrame2.XVector,
									cFrame2.YVector,
									cFrame2.ZVector
								)
								finishShard(v17) -- equivalent call inferred; original call site unknown
								return deduplicatedTail()
							end
						elseif v17.phase == "ghost" then
							local v19 = rotationOnly(v17.part.CFrame) -- equivalent call inferred; original call site unknown

							if v17.spinDuring and v17.spin.Magnitude > DISTANCE_THRESHOLD then
								v19 = v19 * CFrame.fromAxisAngle(createVector(1, 0, 0), v17.spin.X * dt) * CFrame.fromAxisAngle(
									createVector(0, 1, 0),
									v17.spin.Y * dt
								) * CFrame.fromAxisAngle(createVector(0, 0, 1), v17.spin.Z * dt)
							end

							local position = v17.part.Position

							if v17.ghostDistMode then
								local v20 = math.max(0.01, v17.ghostSpeed > 0 and v17.ghostSpeed or 60)
								local v21 = math.min(v17.ghostRemainingDist, v20 * dt)
								v17.ghostRemainingDist -= v21
								local v23 = position + v17.ghostDir * v21
								v17.part.CFrame = CFrame.new(v23) * v19

								if v17.ghostRemainingDist <= 0 then
									finishShard(v17) -- equivalent call inferred; original call site unknown
									return deduplicatedTail()
								end
							else
								local v20 = (v17.ghostSpeed > 0 and v17.ghostSpeed or 60) * dt
								v17.ghostSecondsLeft -= dt
								local v22 = position + v17.ghostDir * v20
								v17.part.CFrame = CFrame.new(v22) * v19

								if v17.ghostSecondsLeft <= 0 then
									finishShard(v17) -- equivalent call inferred; original call site unknown

									if v17.cleanupAfter and v17.cleanupAfter > 0 then
										Debris:AddItem(v17.part, v17.cleanupAfter)
									end

									table.remove(v14, v18)
								end
							end
						end
					end)

					if not success then
						warn("BezierBurst flight error: ", result)
						local part2

						if v14[i] then
							part2 = v14[i].part or nil
						end

						local v19

						if part2 == nil or part2.Parent == nil then
							v19 = false
						else
							v19 = part2:IsDescendantOf(workspace)
						end

						if v19 then
							part2.Anchored = true
							part2.CanCollide = true
							Debris:AddItem(part2, 2)
						end

						table.remove(v14, i)
					end
				else
					table.remove(v14, i)
				end
			end
		end
	end)
end

return {
	Spawn = spawnBurst
}