local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Flash = require(ReplicatedStorage.Client.UI.VFX.Flash)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local Shake = require(ReplicatedStorage.Client.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local riftTradeIn = ReplicatedStorage.Assets.VFX.RiftTradeIn
local sounds = ReplicatedStorage.Assets.Sounds
local v = { -74, 10, 66 }
local v2 = { 11.2, 10.2, 12 }
local v3 = { -3.2, 3.6, 0.2 }
local color = Color3.fromRGB(214, 168, 255)
local color2 = Color3.fromRGB(196, 130, 255)
local flag = false

local function soundOf(childName: string)
	local sound = sounds:FindFirstChild(childName) or sounds:FindFirstChild(childName, true)

	if sound == nil then
		return nil
	end

	if sound:IsA("Sound") then
		return sound
	end

	return sound:FindFirstChildWhichIsA("Sound")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cue(childName: string, vector2: Vector3, volume: number?, playbackSpeed: number?)
	local sound = sounds:FindFirstChild(childName) or sounds:FindFirstChild(childName, true)

	if sound == nil then
		sound = nil
	elseif not sound:IsA("Sound") then
		sound = sound:FindFirstChildWhichIsA("Sound")
	end

	if sound then
		Audio.Play(sound, vector2, {
			Volume = volume,
			PlaybackSpeed = playbackSpeed
		})
	end
end

local function debris()
	return (Workspace:WaitForChild("Transient"))
end

local function driveNumber(maid, p: number, p2: number, tweenInfo, fn)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	maid:Add(numberValue)
	maid:Connect(numberValue.Changed, fn)
	fn(p)
	TweenService:Create(numberValue, tweenInfo, {
		Value = p2
	}):Play()
	return numberValue
end

local function isPortalFace(p)
	return p.Name:find("VoidPortal_Plane", 1, true) ~= nil and p.Size.Y > p.Size.Z
end

local function heartOf(folder)
	local v5 = createVector(0, 0, 0)
	local count = 0

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local v6

		if part.Name:find("VoidPortal_Plane", 1, true) == nil then
			v6 = false
		else
			v6 = part.Size.Y > part.Size.Z
		end

		if not v6 then
			continue
		end

		v5 += part.Position
		count += 1
	end

	if count > 0 then
		return v5 / count
	end

	return nil
end

local function flatDiscBottom(folder)
	local v5 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name:find("VoidPortal_Plane", 1, true) ~= nil) then
			continue
		end

		local v6

		if part.Name:find("VoidPortal_Plane", 1, true) == nil then
			v6 = false
		else
			v6 = part.Size.Y > part.Size.Z
		end

		if v6 then
			continue
		end

		local v7 = part.Position.Y - part.Size.Y * 0.5

		if v5 == nil or v7 < v5 then
			v5 = v7
		end
	end

	return v5
end

local function normalizeGhost(instance)
	instance.PrimaryPart = nil
	local boundingBox, v5 = instance:GetBoundingBox()
	instance.WorldPivot = boundingBox
	local v6 = math.max(v5.X, v5.Y, v5.Z)
	local selected = not (v6 > 0.01) and 1 or math.clamp(6.5 / v6, 0.05, 6)
	instance:ScaleTo(selected)
	local _, v8 = instance:GetBoundingBox()
	return selected, v8.Y * 0.5
end

local function freeze(part)
	if part:IsA("BasePart") then
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	for _, part2 in part:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
	end
end

local function spawnPhase(maid, childName: string, pivot: CFrame, vector2: Vector3, p: number?)
	local clone = riftTradeIn:FindFirstChild(childName):Clone()
	freeze(clone)
	clone:PivotTo(pivot)
	local v5 = heartOf(clone)

	if v5 then
		clone:PivotTo(clone:GetPivot() + (vector2 - v5))
	end

	local v6 = p and flatDiscBottom(clone)

	if v6 then
		local v7 = math.clamp(p - v6, -4, 4)
		clone:PivotTo(clone:GetPivot() + Vector3.new(0, v7, 0))
	end

	clone.Parent = Workspace:WaitForChild("Transient")
	maid:Add(clone)
	return clone
end

local function setRiftShown(folder, flag2: boolean, enabledsByDescendant)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = flag2 and 0 or 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") then
			if flag2 then
				descendant.Enabled = enabledsByDescendant[descendant] == nil or enabledsByDescendant[descendant]
			else
				descendant.Enabled = false
			end
		end
	end
end

local function ghostFor(p)
	local success, result = pcall(function()
		return ItemDisplay.CreateActiveModel(nil, p, true)
	end)

	if success and result then
		return result
	end

	local model = Instance.new("Model")
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(2.4, 2.4, 2.4)
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Anchored = true
	part.CanCollide = false
	part.Parent = model
	model.PrimaryPart = part
	return model
end

local function neonSurge(_, folder)
	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Material == Enum.Material.Neon) then
			continue
		end

		local color3 = part.Color
		TweenService:Create(part, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = color
		}):Play()
		local v5 = part
		task.delay(0.22, function()
			if v5.Parent then
				TweenService:Create(v5, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = color3
				}):Play()
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return vector2:Lerp(vector3, p):Lerp(vector3:Lerp(vector4, p), p)
end

local function groundBurst(maid, position: Vector3)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local particles = assets and assets:FindFirstChild("Particles")
	local bigHitGroundAttach = particles and particles:FindFirstChild("BigHitGroundAttach")

	if bigHitGroundAttach == nil then
		return
	end

	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Parent = Workspace:WaitForChild("Transient")
	maid:Add(part)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local clone = bigHitGroundAttach:Clone()

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Parent = attachment
		end
	end

	if clone:IsA("ParticleEmitter") then
		clone.Parent = attachment
	else
		clone:Destroy()
	end

	VFX.EmitTree(part, true)
end

local v4 = {
	IsPlaying = function()
		return flag
	end,
	Play = function(list, callback)
		if flag then
			callback()
			return
		end

		flag = true
		task.spawn(function()
			local v5 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function deliver()
				if not v5 then
					v5 = true
					task.spawn(callback)
				end
			end

			local maid = Trove.new()
			local oldRiftMachine = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Machines") and (Workspace.World.Machines:FindFirstChild("OldRiftMachine") or Workspace.World.Machines:FindFirstChild("RiftMachine"))
			local rift = oldRiftMachine and oldRiftMachine:FindFirstChild("Rift")

			if oldRiftMachine and rift and rift:IsA("Model") then
				local success, result = pcall(function()
					local pivot = rift:GetPivot()
					local v6 = heartOf(rift) or pivot:PointToWorldSpace(createVector(0, 10.04, 0))
					local v7 = flatDiscBottom(rift)
					local v8

					if v7 then
						v8 = v7 + 0.04
					end

					local v9 = pivot.LookVector * createVector(1, 0, 1)
					local unit = not (v9.Magnitude > 0.05) and createVector(0, 0, 1) or v9.Unit
					local enabledsByDescendant = {}

					for _, descendant in rift:GetDescendants() do
						if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light")) then
							continue
						end

						enabledsByDescendant[descendant] = descendant.Enabled
					end

					setRiftShown(rift, false, enabledsByDescendant)
					maid:Add(function()
						setRiftShown(rift, true, enabledsByDescendant)
					end)
					local v10 = spawnPhase(maid, "Phase1", pivot, v6, v8)
					VFX.EmitTree(v10, true)
					Shake.Play({
						Seconds = 0.7,
						Magnitude = 1.6
					})
					cue("ImpactBoom", v6, 0.9, 0.75) -- equivalent call inferred; original call site unknown
					cue("CinematicRiser", v6, 0.6, nil) -- equivalent call inferred; original call site unknown
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local characters = { Workspace:WaitForChild("Transient"), rift }
					local character = Players.LocalPlayer.Character

					if character then
						table.insert(characters, character)
					end

					raycastParams.FilterDescendantsInstances = characters
					local count = #list
					local v11 = {}

					for k, v12 in list do
						local v13, v14, v15

						if count <= #v then
							v13 = v[k]
							v14 = v2[k]
							v15 = v3[k]
						else
							v13 = (k - 1) * (160 / (count - 1)) + -80
							v14 = k % 3 * 0.7 + 8.4
							v15 = k * 2 % 5 + -2
						end

						local v16 = v6 + CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(v13))) * unit * v14 + Vector3.new(
							0,
							v15,
							0
						)
						local raycastResult = Workspace:Raycast(
							Vector3.new(v16.X, v6.Y + 14, v16.Z),
							createVector(0, -80, 0),
							raycastParams
						)
						local Y

						if raycastResult then
							Y = raycastResult.Position.Y
						else
							Y = v6.Y - 6
						end

						local model = ghostFor(v12)
						local ghost, v18 = normalizeGhost(model)
						local v19 = Y + v18 + 0.2
						local cframe = CFrame.lookAt(Vector3.new(v16.X, v19, v16.Z), (Vector3.new(v6.X, v19, v6.Z)))
						local cframe2 = CFrame.lookAt(v16, (Vector3.new(v6.X, v16.Y, v6.Z)))
						model:PivotTo(cframe)
						model.Parent = Workspace:WaitForChild("Transient")
						maid:Add(model)
						table.insert(v11, {
							model = model,
							fx = nil,
							hover = cframe2,
							state = "ground",
							bobPhase = k * 2.3,
							baseScale = ghost
						})
					end

					task.wait(0.55)
					local folder = spawnPhase(maid, "Phase2", pivot, v6, v8)
					Flash.Play({
						Attack = 0.06,
						Decay = 0.22,
						Tint = color2,
						Opacity = 0.45
					})
					v10:Destroy()
					VFX.EmitTree(folder, true)
					local worldPosition = heartOf(folder) or v6
					local basePart = folder:FindFirstChildWhichIsA("BasePart", true)
					local attachment

					if basePart then
						attachment = Instance.new("Attachment")
						attachment.Parent = basePart
						attachment.WorldPosition = worldPosition
					end

					for k, v13 in v11 do
						local clone = riftTradeIn:FindFirstChild("PetFX"):Clone()
						freeze(clone)
						clone.CFrame = v13.model:GetPivot()
						clone.Parent = Workspace:WaitForChild("Transient")
						maid:Add(clone)
						v13.fx = clone

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							if beam.Attachment1 == nil then
								local attachment2 = Instance.new("Attachment")
								attachment2.Parent = clone
								beam.Attachment1 = attachment2
							end

							if attachment then
								beam.Attachment0 = attachment
							end
						end

						task.delay(k * 0.08, function()
							if clone.Parent then
								VFX.EmitTree(clone, true)
							end
						end)
					end

					maid:Connect(RunService.Heartbeat, function()
						for _, v13 in v11 do
							if not (v13.state == "hover" and v13.model.Parent) then
								continue
							end

							local v14 = os.clock() * 2.4 + v13.bobPhase
							local cFrame = v13.hover * CFrame.new(math.cos(v14 * 0.7) * 0.18, math.sin(v14) * 0.45, 0)
							v13.model:PivotTo(cFrame)

							if v13.fx and v13.fx.Parent then
								v13.fx.CFrame = cFrame
							end
						end
					end)

					for k, v13 in v11 do
						local v14 = v13
						local v15 = k
						task.delay((k - 1) * 0.28, function()
							local model = v14.model

							if not model.Parent then
								return
							end

							local pivot2 = model:GetPivot()
							cue("MechaShake", v14.hover.Position, 0.35, v15 * 0.06 + 1.1) -- equivalent call inferred; original call site unknown
							driveNumber(
								maid,
								0,
								1,
								TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								function(p)
									if model.Parent and v14.state == "ground" then
										local lerped = pivot2:Lerp(v14.hover, p)
										model:PivotTo(lerped)

										if v14.fx and v14.fx.Parent then
											v14.fx.CFrame = lerped
										end
									end
								end
							)
							task.delay(0.9, function()
								if v14.state == "ground" then
									v14.state = "hover"
								end
							end)
						end)
					end

					task.wait((#v11 - 1) * 0.28 + 0.9 + 1.15)

					for k, v13 in v11 do
						local v14 = v13
						local v15 = k
						task.delay((k - 1) * 0.7, function()
							local model = v14.model

							if not model.Parent then
								return
							end

							v14.state = "pulling"
							local pivot2 = model:GetPivot()
							local v16 = pivot2.Position:Lerp(v6, 0.45) + createVector(0, 1.6, 0)

							if v14.fx then
								for i, beam in v14.fx:GetDescendants() do
									if beam:IsA("Beam") then
										TweenService:Create(
											beam,
											TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
											{
												Width0 = beam.Width0 * 0.25,
												Width1 = beam.Width1 * 0.25
											}
										):Play()
									end
								end
							end

							driveNumber(
								maid,
								0,
								1,
								TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								function(p)
									if model.Parent then
										local cFrame = CFrame.new(bezier(pivot2.Position, v16, v6, p)) * pivot2.Rotation
										model:PivotTo(cFrame)
										model:ScaleTo(v14.baseScale * math.max(1 - p * 0.7, 0.3))

										if v14.fx and v14.fx.Parent then
											v14.fx.CFrame = cFrame
										end
									end
								end
							)
							task.delay(0.85, function()
								cue("ImpactBoom", v6, 0.7, v15 * 0.12 + 0.9) -- equivalent call inferred; original call site unknown

								if folder.Parent then
									VFX.EmitTree(folder, 6)
								end

								if v14.fx then
									v14.fx:Destroy()
								end

								model:Destroy()
							end)
						end)
					end

					task.wait((#v11 - 1) * 0.7 + 0.85 + 0.35)
					local v13 = spawnPhase(maid, "Phase3", pivot, v6, v8)
					Flash.Play({
						Attack = 0.08,
						Decay = 0.3,
						Tint = color2,
						Opacity = 0.55
					})
					folder:Destroy()
					folder = v13
					VFX.EmitTree(folder, true)
					cue("CinematicRiser", v6, 0.85, 1.05) -- equivalent call inferred; original call site unknown
					Shake.Play({
						Seconds = 0.4,
						Magnitude = 2.8
					})
					driveNumber(
						maid,
						1,
						1.12,
						TweenInfo.new(2.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						function(p)
							if folder.Parent then
								folder:ScaleTo(p)
							end
						end
					)
					task.delay(1.54, function()
						if folder.Parent then
							neonSurge(maid, folder)
							VFX.EmitTree(folder, true)
						end
					end)
					task.wait(2.8)
					Flash.Play({
						Attack = 0.1,
						Decay = 0.55,
						Tint = Color3.new(1, 1, 1),
						Opacity = 0.9
					})
					Shake.Play({
						Seconds = 1,
						Magnitude = 2
					})
					cue("CinematicBoom", v6, 1, nil) -- equivalent call inferred; original call site unknown
					local v14 = spawnPhase(maid, "Phase4", pivot, v6, v8)
					local v15 = heartOf(v14) or v6
					local eggSpawn = v14:FindFirstChild("EggSpawn", true)
					local part

					if eggSpawn then
						part = Instance.new("Part")
						part.Size = createVector(1, 1, 1)
						part.CFrame = CFrame.new(v15)
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.CastShadow = false
						part.Transparency = 1
						part.Parent = Workspace:WaitForChild("Transient")
						maid:Add(part)
						eggSpawn.Parent = part

						if eggSpawn:IsA("Attachment") then
							eggSpawn.CFrame = CFrame.identity
						end
					end

					VFX.EmitTree(v14, true)

					for emitter, enabled in enabledsByDescendant do
						if emitter:IsA("ParticleEmitter") and emitter.Parent then
							emitter.Enabled = enabled
						end
					end

					task.wait(0.3)
					local clone = riftTradeIn:FindFirstChild("Egg"):Clone()
					freeze(clone)
					clone.Parent = Workspace:WaitForChild("Transient")
					maid:Add(clone)
					local v16 = nil
					local v17 = nil

					for _, part2 in clone:GetDescendants() do
						if not (part2:IsA("BasePart") and part2.Transparency < 0.95) then
							continue
						end

						local v18 = part2.Size * 0.5

						if v16 then
							v16 = v16:Min(part2.Position - v18)
						else
							v16 = part2.Position - v18
						end

						if v17 then
							v17 = v17:Max(part2.Position + v18)
						else
							v17 = part2.Position + v18
						end
					end

					local v18

					if v16 and v17 then
						clone.WorldPivot = CFrame.new((v16 + v17) * 0.5)
						v18 = (v17.Y - v16.Y) * 0.5
					else
						v18 = 2.4
					end

					cue("MechaHatch", v15, 0.9, 1.1) -- equivalent call inferred; original call site unknown

					if part then
						VFX.EmitTree(part, true)
					end

					folder:Destroy()
					folder = v14
					local character2 = Players.LocalPlayer.Character
					local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
					local v19

					if humanoidRootPart then
						v19 = (humanoidRootPart.Position - v15) * createVector(1, 0, 1)
					else
						v19 = unit
					end

					if v19.Magnitude > 0.05 then
						unit = v19.Unit
					end

					local v20 = math.clamp(v19.Magnitude * 0.7, 8, 14)
					local vector2 = Vector3.new(v15.X + unit.X * v20, v15.Y + 6, v15.Z + unit.Z * v20)
					local raycastResult = Workspace:Raycast(vector2, createVector(0, -90, 0), raycastParams)
					local position

					if raycastResult then
						position = raycastResult.Position
					else
						position = Vector3.new(vector2.X, pivot.Position.Y + 2.6, vector2.Z)
					end

					local v21 = position + Vector3.new(0, v18, 0)
					clone:PivotTo(CFrame.new(v15))
					clone:ScaleTo(0.45)
					local v22 = math.max(v15.Y, v21.Y) + 5
					local vector3 = Vector3.new(
						v15.X + unit.X * v20 * 0.55,
						v22 * 2 - (v15.Y + v21.Y) * 0.5,
						v15.Z + unit.Z * v20 * 0.55
					)
					local cross = (createVector(0, 1, 0)):Cross(unit)
					local v23 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
					driveNumber(
						maid,
						0,
						1,
						TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						function(p)
							if clone.Parent then
								local v24 = 1 - (1 - p) * (1 - p)
								clone:PivotTo(CFrame.new(bezier(v15, vector3, v21, v24)) * CFrame.fromAxisAngle(
									v23,
									12.566370614359172 * v24
								))
								clone:ScaleTo((math.min(0.45 + 0.55 * p * 2, 1)))
							end
						end
					)
					task.wait(0.9)

					if clone.Parent then
						clone:ScaleTo(1)
						clone:PivotTo(CFrame.new(v21))
					end

					cue("ChestLanding", v21, 1, nil) -- equivalent call inferred; original call site unknown
					groundBurst(maid, position)
					Shake.Play({
						Seconds = 1,
						Magnitude = 0.5
					})
					Flash.Play({
						Attack = 0.05,
						Decay = 0.2,
						Tint = color2,
						Opacity = 0.4
					})
					driveNumber(
						maid,
						0,
						1,
						TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						function(p)
							if clone.Parent then
								local v24 = 1 - p
								local v25 = math.sin(p * 3.141592653589793) * v24 * 1.4
								local v26 = math.sin(p * 3.141592653589793 * 4) * v24 * 0.20943951023931956
								clone:PivotTo(CFrame.new(v21 + Vector3.new(0, v25, 0)) * CFrame.Angles(0, 0, v26))
							end
						end
					)
					task.wait(0.4)

					if clone.Parent then
						clone:PivotTo(CFrame.new(v21))
					end

					task.wait(0.3)
					local position2 = clone:GetPivot().Position
					driveNumber(
						maid,
						0,
						1,
						TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						function(p)
							if not clone.Parent then
								return
							end

							local character3 = Players.LocalPlayer.Character
							local humanoidRootPart2 = character3 and character3:FindFirstChild("HumanoidRootPart")
							local v24

							if humanoidRootPart2 then
								v24 = humanoidRootPart2.Position + createVector(0, 1.5, 0)
							else
								v24 = position2
							end

							local v25 = (position2 + v24) * 0.5
							local magnitude = ((position2 - v24) * createVector(1, 0, 1)).Magnitude
							local vector4 = Vector3.new(
								v25.X,
								math.max(position2.Y, v24.Y) + magnitude * 0.5 + 2.5,
								v25.Z
							)
							local v26 = p * p
							local v27 = bezier(position2, vector4, v24, v26) -- equivalent call inferred; original call site unknown
							local vector5 = Vector3.new(v24.X, v27.Y, v24.Z)
							local v29

							if (v27 - vector5).Magnitude < 0.001 then
								v29 = CFrame.new(v27)
							else
								v29 = CFrame.lookAt(v27, vector5)
							end

							clone:PivotTo(v29)
							local v30 = math.clamp((p - 0.55) / 0.45, 0, 1)
							clone:ScaleTo((math.max(1 - v30 * v30 * v30, 0.01)))
						end
					)
					task.wait(0.6)
					local character3 = Players.LocalPlayer.Character
					local humanoidRootPart2 = character3 and character3:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						position2 = humanoidRootPart2.Position + createVector(0, 1, 0)
					end

					local clone2 = riftTradeIn:FindFirstChild("Aura"):Clone()
					freeze(clone2)
					clone2:PivotTo(CFrame.new(position2))
					clone2.Parent = Workspace:WaitForChild("Transient")
					maid:Add(clone2)

					for _, part2 in clone2:GetDescendants() do
						if part2:IsA("BasePart") then
							part2.LocalTransparencyModifier = 1
						end
					end

					VFX.EmitTree(clone2, true)
					cue("MechaShake", position2, 0.5, 1.35) -- equivalent call inferred; original call site unknown
					deliver() -- equivalent call inferred; original call site unknown
					task.wait(0.9)

					for _, descendant in folder:GetDescendants() do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						elseif descendant:IsA("BasePart") then
							TweenService:Create(
								descendant,
								TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									LocalTransparencyModifier = 1
								}
							):Play()
						end
					end

					for _, emitter in clone2:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, part2 in rift:GetDescendants() do
						if part2:IsA("BasePart") then
							TweenService:Create(
								part2,
								TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									LocalTransparencyModifier = 0
								}
							):Play()
						end
					end

					task.delay(0.66, function()
						for instance, enabled in enabledsByDescendant do
							if not ((instance:IsA("Beam") or instance:IsA("Light")) and instance.Parent) then
								continue
							end

							instance.Enabled = enabled
						end
					end)
					task.wait(2.5)
				end)
				maid:Clean()

				if not success then
					warn((`Rift sequence failed: {result}`))
				end

				deliver() -- equivalent call inferred; original call site unknown
				flag = false
			else
				deliver() -- equivalent call inferred; original call site unknown
				flag = false
			end
		end)
	end
}
return table.freeze(v4)