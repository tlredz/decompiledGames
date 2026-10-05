local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):Inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):Inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("PortalEffects").Portal
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	local player = data.player
	local origin = data.origin
	local lookDir = data.lookDir
	local lastsFor = data.lastsFor
	local delayPortalSpawnBy = data.delayPortalSpawnBy

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1e999 then
		return
	end

	local v = lastsFor + 5
	local portalTemplateC = FX:WaitForChild("PortalEffects"):WaitForChild("PortalTemplateC")
	local RenderSteppedLoopFor = require(script.Parent:WaitForChild("RenderSteppedLoopFor"))
	local renderSteppedLoopFor = RenderSteppedLoopFor.RenderSteppedLoopFor
	local RenderSteppedLoopFor2 = require(script.Parent:WaitForChild("RenderSteppedLoopFor"))
	local awaitRenderSteppedLoopFor = RenderSteppedLoopFor2.AwaitRenderSteppedLoopFor
	local lightningBolt2 = Util.LightningBolt2
	game:GetService("RunService")
	game:GetService("ReplicatedStorage")
	game:GetService("UserInputService")
	game:GetService("GuiService")
	local VisualHelper = require(script:WaitForChild("VisualHelper"))
	local _ = Workspace.CurrentCamera
	local Players2 = game:GetService("Players")
	local localPlayer = Players2.LocalPlayer
	local clone = portalTemplateC:Clone()
	Util.Sound:Play("Portal_C_Portal_Spawn_In_01", origin)
	local v2 = Util.Sound:Play("Portal_C_Portal_Idle_01", origin)

	if data.targetPos then
		clone:AddTag("NearbyLoDFocus")
		clone:SetAttribute("FocusPosition", data.targetPos)
		Util.Sound:Play("Portal_C_Portal_Spawn_In_01", data.targetPos)
	end

	task.delay(1, function()
		if v2 then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(v2, TweenInfo.new(1), {
				Volume = 1
			}):Play()
		end
	end)
	clone:PivotTo(CFrame.lookAt(createVector(0, 0, 0), lookDir) + origin)
	local pivot = clone.Model:GetPivot()
	clone.Model:Destroy()
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone, v)
	local random = Random.new()
	local front = clone.Surfaces.Front
	local clone2 = front:Clone()
	clone2.Name = "Back"
	clone2.Face = Enum.NormalId.Back
	clone2.TopLayer.Face = clone2.Face
	clone2.Adornee = front.Adornee
	Util.SetParentOverrideWithColor(clone2, front.Parent, player, "PortalFruitVFXColor")
	local v3 = {}
	task.delay(delayPortalSpawnBy * 0.8, function()
		local clone3 = portalTemplateC.Model:Clone()
		clone3:PivotTo(pivot)
		local clone4 = clone3:Clone()
		clone4:PivotTo(clone3:GetPivot() * CFrame.Angles(0, 3.141592653589793, 0))
		local v4 = { clone3, clone4 }
		local ViewportWindow = require(script:WaitForChild("ViewportWindow"))

		for _, v5 in v4 do
			local v6 = ViewportWindow.FromPart(
				clone,
				Enum.NormalId[v5 == clone3 and "Front" or "Back"],
				localPlayer.PlayerGui,
				4,
				0,
				createVector(0, 0, 0)
			)
			task.delay(v, function()
				v6:Destroy()
			end)
			v6.ViewportFrame.Parent.Brightness = 25
			Util.SetParentOverrideWithColor(v5, v6.ViewportFrame, player, "PortalFruitVFXColor")
			destroyAfter(v5, v)
			table.insert(v3, v6)
			local v8 = v6
			renderSteppedLoopFor(0.4, function(p: number, p2: number, p3: number)
				v8.ViewportFrame.Parent.Brightness = math.lerp(50, 4, p3)
			end)
		end

		local Textures = require(script:WaitForChild("Textures"))
		local total = 0
		local postSimulationConnection = nil
		local RunService = game:GetService("RunService")
		postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			if not clone:IsDescendantOf(Workspace) then
				postSimulationConnection:Disconnect()
				return
			end

			total += dt
			local v5 = math.floor(total / 0.022222222222222223)

			for _, v6 in v4 do
				for _, part in v6:GetChildren() do
					local texture = Textures[part.Name]

					if not texture then
						continue
					end

					if part:IsA("MeshPart") then
						part.TextureID = texture[v5 % #texture + 1]
					elseif part.Name == "Portal" then
						part.Mesh.TextureId = texture[v5 % #texture + 1]
					end
				end
			end
		end)
	end)
	VisualHelper:Tween(clone.Trails, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Orientation = clone.Trails.Orientation - createVector(0, 0, 360)
	})

	for _, child in clone.Storm:GetChildren() do
		VisualHelper:Tween(
			child,
			TweenInfo.new(random:NextNumber(2.5, 4), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Orientation = child.Orientation + Vector3.new(0, 360 * (child.Name == "Mid" and -1 or 1))
			}
		)
	end

	local function setParticleTransparency(particle_6, value: number)
		if particle_6:GetAttribute("OriginalTransparency") == nil then
			particle_6:SetAttribute("OriginalTransparency", particle_6.Transparency)
		end

		local v4 = math.clamp(value, 0, 1)
		local originalTransparency = particle_6:GetAttribute("OriginalTransparency")
		local numberSequenceKeypoints = {}

		for _, keypoint in ipairs(originalTransparency.Keypoints) do
			local time2 = keypoint.Time
			local v5 = math.lerp(keypoint.Value, 1, v4)
			local envelope = keypoint.Envelope
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(time2, v5, envelope))
		end

		particle_6.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end

	renderSteppedLoopFor(delayPortalSpawnBy, function(_: number, _: number, p: number)
		clone.Light.Particle_6.RotSpeed = NumberRange.new((math.lerp(0, -1400, p ^ 4)))
		setParticleTransparency(clone.Light.Particle_6, (1 - p) ^ 0.2)
	end)
	local TweenService = game:GetService("TweenService")
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1

	local function fadeInOut(folder, p, duration)
		local changedConnection = numberValue.Changed:Connect(function()
			local value = numberValue.Value

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("ImageLabel") then
					local initialTransparency = descendant:GetAttribute("InitialTransparency") or 0
					descendant.ImageTransparency = initialTransparency + (1 - initialTransparency) * value
				elseif descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") then
					if descendant.Parent ~= clone.Light and descendant.Parent ~= clone.AuraAttachment then
						local initialTransparency = descendant:GetAttribute("InitialTransparency") or NumberSequence.new(0)
						local numberSequenceKeypoints = {}

						for i, keypoint in ipairs(initialTransparency.Keypoints) do
							numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
								keypoint.Time,
								keypoint.Value + (1 - keypoint.Value) * value,
								keypoint.Envelope
							)
						end

						descendant.Transparency = NumberSequence.new(numberSequenceKeypoints)
					end
				elseif descendant:IsA("PointLight") then
					local initialBrightness = descendant:GetAttribute("InitialBrightness") or 0
					local initialRange = descendant:GetAttribute("InitialRange") or 0
					descendant.Brightness = math.lerp(initialBrightness, 0, value)
					descendant.Range = math.lerp(initialRange, 0, value)
				end
			end
		end)
		local tween = TweenService:Create(numberValue, TweenInfo.new(duration), {
			Value = p
		})
		tween:Play()
		tween.Completed:Once(function()
			changedConnection:Disconnect()
		end)
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ImageLabel") then
			descendant:SetAttribute("InitialTransparency", descendant.ImageTransparency)
			descendant.ImageTransparency = 1
		elseif descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") then
			if descendant.Parent ~= clone.Light then
				descendant:SetAttribute("InitialTransparency", descendant.Transparency)
				descendant.Transparency = NumberSequence.new(1)
			end
		elseif descendant:IsA("PointLight") then
			descendant:SetAttribute("InitialBrightness", descendant.Brightness)
			descendant:SetAttribute("InitialRange", descendant.Range)
			descendant.Brightness = 0
			descendant.Range = 0
		end
	end

	task.spawn(function()
		fadeInOut(clone, 0, delayPortalSpawnBy * 0.5)
	end)
	local v4 = {}
	task.spawn(function()
		local DrawTriangle = require(script:WaitForChild("DrawTriangle"))
		local Triangulate = require(script:WaitForChild("Triangulate"))
		local random2 = Random.new()

		local function generateNGon(p: number, p2: number)
			local vectors = {}

			for i = 0, p - 1 do
				local v5 = 6.283185307179586 * i / p
				table.insert(vectors, Vector2.new(math.cos(v5) * p2, math.sin(v5) * p2))
			end

			return vectors
		end

		local function autoMinDist(p: number, p2: number)
			return p * math.sqrt(3.6275987284684357 / p2)
		end

		local function poissonDiskInCircle(p: number, p2: number, p3: number)
			local v5 = p2 / 1.4142135623730951
			local v6 = math.ceil(p * 2 / v5)
			local v7 = table.create(v6)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function putInGrid(point: Vector2)
				local v8 = math.floor((point.X + p) / v5)
				local v9 = math.floor((point.Y + p) / v5)
				v7[v8] = v7[v8] or {}
				v7[v8][v9] = point
				return v8, v9
			end

			local function inNeighbourhood(point: Vector2, p4: number, p5: number)
				for i = p4 - 2, p4 + 2 do
					local v8 = v7[i]

					if not v8 then
						continue
					end

					for i2 = p5 - 2, p5 + 2 do
						local v9 = v8[i2]

						if v9 and (v9 - point).Magnitude < p2 then
							return true
						end
					end
				end

				return false
			end

			local result = {}
			local v8 = {}
			local vector2

			repeat
				vector2 = Vector2.new(random2:NextNumber(-p, p), random2:NextNumber(-p, p))
			until vector2.Magnitude <= p

			table.insert(result, vector2)
			table.insert(v8, vector2)
			local _, _ = putInGrid(vector2) -- equivalent call inferred; original call site unknown

			while #v8 > 0 do
				local integer = random2:NextInteger(1, #v8)
				local v9 = v8[integer]
				local v10 = false

				for _ = 1, p3 do
					local number = random2:NextNumber(p2, p2 * 2)
					local v11 = random2:NextNumber() * 2 * 3.141592653589793
					local v12 = v9 + Vector2.new(math.cos(v11) * number, math.sin(v11) * number)

					if not (v12.Magnitude <= p) then
						continue
					end

					if inNeighbourhood(v12, math.floor((v12.X + p) / v5), math.floor((v12.Y + p) / v5)) then
						continue
					end

					table.insert(result, v12)
					table.insert(v8, v12)
					local _, _ = putInGrid(v12) -- equivalent call inferred; original call site unknown
					v10 = true
					break
				end

				if not v10 then
					table.remove(v8, integer)
				end
			end

			return result
		end

		local v5 = {}

		for _, v6 in ipairs((generateNGon(14, 3.77))) do
			table.insert(v5, v6)
		end

		for _, v6 in ipairs((poissonDiskInCircle(3.675478228925475, 1.3472295283178621, 10))) do
			table.insert(v5, v6)
		end

		local triangulate = Triangulate(v5)
		local pivot2 = clone:GetPivot()

		for _, v7 in ipairs(triangulate) do
			local v8 = v7[1]
			local v9 = v7[2]
			local v10 = v7[3]
			local pointToWorldSpace, v11, v12 = pivot2:PointToWorldSpace(
				Vector3.new(v8.X, v8.Y * 1.4, 0),
				Vector3.new(v9.X, v9.Y * 1.4, 0),
				(Vector3.new(v10.X, v10.Y * 1.4, 0))
			)
			local model = Instance.new("Model")
			Util.SetParentOverrideWithColor(model, _WorldOrigin, player, "PortalFruitVFXColor")
			destroyAfter(model, v)
			local v13, v14 = DrawTriangle(pointToWorldSpace, v11, v12, 0.35, model)
			local lerped = Util.WrapColor3Constructor(Color3.new(0.403922, 0.415686, 1), player, "PortalFruitVFXColor"):Lerp(
				Util.WrapColor3Constructor(Color3.new(0.329412, 0.364706, 1), player, "PortalFruitVFXColor"),
				math.random()
			)
			v13.Color = lerped
			v14.Color = lerped
			local neon = Enum.Material.Neon
			local neon2 = Enum.Material.Neon
			v13.Material = neon
			v14.Material = neon2
			v13.Transparency = 1
			v14.Transparency = 1
			table.insert(v4, model)
			model:SetAttribute("InitialPivot", model:GetPivot())
		end

		local function cubicBezier(p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
			local v7 = 1 - p
			local v8 = v7 * v7
			local v9 = p * p
			return v8 * v7 * vector2 + v8 * 3 * p * vector3 + v7 * 3 * v9 * vector4 + v9 * p * vector5
		end

		local function shuffle(list)
			for i = #list, 2, -1 do
				local v7 = math.random(i)
				local v8 = list[v7]
				local v9 = list[i]
				list[i] = v8
				list[v7] = v9
			end

			return list
		end

		shuffle(v4)
		local v7 = time() + delayPortalSpawnBy
		task.spawn(function()
			for _, v8 in ipairs(v4) do
				local w1 = v8.w1
				local w2 = v8.w2
				w1.Transparency = 0
				w2.Transparency = 0
				local pivot3 = v8:GetPivot()
				local v9 = pivot3 * (CFrame.Angles(
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793
				) * CFrame.new(createVector(1, 1, 1) * (14 + 2 * math.random())))
				local unitVector = random2:NextUnitVector()
				local v10 = math.max(0, v7 - time())
				local v13 = v8
				local v15 = v8
				local v16 = pivot3
				renderSteppedLoopFor(math.max(0, v10 * 0.5), function(p: number, p2: number, p3: number)
					local position = v9.Position
					local position2 = pivot3.Position
					local v17 = position2 + lookDir * 7
					local v18 = position2 + lookDir * 7
					local lerped = v9.Rotation:Lerp(pivot3.Rotation, p3 ^ 2)
					local v20 = 1 - p3
					local v21 = v20 * v20
					local v22 = p3 * p3
					v13:PivotTo(lerped + (v21 * v20 * position + v21 * 3 * p3 * v17 + v20 * 3 * v22 * v18 + v22 * p3 * position2))
					v13:PivotTo(v13:GetPivot().Rotation * CFrame.fromAxisAngle(unitVector, 12.566370614359172 * p3) + v13:GetPivot().Position)
				end, function()
					v15:PivotTo(v16)
				end)
				task.wait(v10 * 0.8 / #v4)
			end
		end)
		task.delay(delayPortalSpawnBy, function()
			for _, v8 in ipairs(v4) do
				local w1 = v8:FindFirstChild("w1")
				local w2 = v8:FindFirstChild("w2")

				if not (w1 and w2) then
					continue
				end

				local pivot3 = v8:GetPivot()
				local v9 = pivot3 * (CFrame.Angles(
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793
				) * CFrame.new(createVector(2.7, 2.7, 2.7) * (4 + 2 * math.random())))
				local v11 = random2:NextUnitVector()
				local v12 = v8
				local v13 = v8
				renderSteppedLoopFor(1, function(p: number, p2: number, transparency: number)
					v12:PivotTo(pivot3.Rotation * CFrame.fromAxisAngle(v11, 12.566370614359172 * transparency) + v12:GetPivot().Position)
					local w12 = v12.w1
					local w22 = v12.w2
					w12.Transparency = transparency
					w22.Transparency = transparency
				end, function()
					local w12 = v13.w1
					local w22 = v13.w2
					w12.Transparency = 1
					w22.Transparency = 1
					v13:PivotTo(v9)
				end)
			end
		end)
	end)

	local function lightningStrike(worldPosition: Vector3, worldPosition2: Vector3, p: number, value: number)
		local v5 = {
			WorldPosition = worldPosition,
			WorldAxis = Vector3.new()
		}
		local v6 = {
			WorldPosition = worldPosition2,
			WorldAxis = Vector3.new()
		}
		local v7 = lightningBolt2.new(v5, v6, value or 20)
		v7.MaxRadius = 2
		v7.MinThicknessMultiplier = 0.5
		v7.MaxThicknessMultiplier = 1
		v7.Thickness = 0.2
		v7.PulseSpeed = 100
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Color = script:WaitForChild("Configuration"):GetAttribute("LightningColor")
		Util.ColorShiftObjectDescendants(particleEmitter, player, "PortalFruitVFXColor")
		v7.Color = particleEmitter.Color
		v7.ColorOffsetSpeed = 0
		v7._ColorRanNum = 0
		v7.AnimationSpeed = 25
		particleEmitter:Destroy()
		renderSteppedLoopFor(p, function(p2)
			v7.Thickness = 0.2 * ((0.5 + 0.5 / p2) * math.sin(34.4 * p2) ^ 2)
		end, function()
			v7:Destroy()
		end)
	end

	task.spawn(function()
		local v5 = time()
		local random2 = Random.new()
		local v6 = lastsFor * 0.9
		task.wait(0.2)

		while time() - v5 < v6 do
			task.wait(random2:NextNumber(0.05, 0.2))
			local rightVector = clone.CFrame.RightVector
			local upVector = clone.CFrame.UpVector
			local v7 = 6.283185307179586 * random2:NextNumber()
			local v8 = origin + rightVector * (math.cos(v7) * 3.77) + upVector * (math.sin(v7) * 5.278)
			local unit = (rightVector * (math.cos(v7) * 3.77) + upVector * (math.sin(v7) * 5.278)).Unit
			lightningStrike(v8, v8 + random2:NextNumber(9, 14) * unit, 0.2)
		end
	end)
	task.delay(lastsFor, function()
		task.spawn(function()
			fadeInOut(clone, 1, delayPortalSpawnBy * 0.5)
			renderSteppedLoopFor(delayPortalSpawnBy, function(_: number, _: number, p: number)
				if clone:FindFirstChild("Light") then
					clone.Light.Particle_6.TimeScale = math.lerp(1, 0.2, p)
					setParticleTransparency(clone.Light.Particle_6, p ^ 0.5)
				end
			end, function()
				if clone:FindFirstChild("Light") then
					clone.Light:Destroy()
				end

				if clone:FindFirstChild("Trails") then
					clone.Trails:Destroy()
				end
			end)
		end)
		local random2 = Random.new()

		for _, v5 in v3 do
			local v6 = v5
			renderSteppedLoopFor(0.4, function(p: number, p2: number, p3: number)
				if v6.ViewportFrame == nil then
					return
				end

				v6.ViewportFrame.Parent.Brightness = math.lerp(4, 50, p3)
			end)
		end

		task.delay(0.2, function()
			for _, v5 in ipairs(v4) do
				local w1 = v5:FindFirstChild("w1")
				local w2 = v5:FindFirstChild("w2")

				if not (w1 and w2) then
					continue
				end

				local initialPivot = v5:GetAttribute("InitialPivot")
				local v6 = initialPivot * (CFrame.Angles(
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793,
					2 * math.random() * 3.141592653589793
				) * CFrame.new(createVector(2.7, 2.7, 2.7) * (4 + 2 * math.random())))
				local unitVector = random2:NextUnitVector()
				v5:PivotTo(initialPivot)
				local v7 = w1
				local v8 = w2
				local v9 = v5
				task.spawn(function()
					awaitRenderSteppedLoopFor(0.2, function(p: number, p2: number, p3: number)
						local v13 = v7
						local v14 = v8
						local transparency = 1 - p3
						local transparency2 = 1 - p3
						v13.Transparency = transparency
						v14.Transparency = transparency2
					end, function()
						local v13 = v8
						v7.Transparency = 0
						v13.Transparency = 0

						for k, v14 in v3 do
							v14:Destroy()
						end
					end)
					awaitRenderSteppedLoopFor(1, function(p: number, p2: number, transparency: number)
						v9:PivotTo(initialPivot:Lerp(v6, transparency ^ 0.5))
						v9:PivotTo(initialPivot.Rotation * CFrame.fromAxisAngle(
							unitVector,
							12.566370614359172 * transparency
						) + v9:GetPivot().Position)
						local v14 = v8
						v7.Transparency = transparency
						v14.Transparency = transparency
					end, function()
						local v13 = v8
						v7.Transparency = 1
						v13.Transparency = 1
						v9:PivotTo(v6)
					end)
				end)
			end

			task.wait(4)
			table.clear(v4)
		end)
	end)
	task.delay(delayPortalSpawnBy, function()
		clone.AuraAttachment.Aura:Emit(1)
	end)
	task.delay(delayPortalSpawnBy * 1.2, function()
		clone.AuraAttachment.Aura:Emit(1)
		task.wait(clone.AuraAttachment.Aura.Lifetime.Max * 0.7)
		clone.AuraAttachment.Aura.TimeScale = 0
	end)
	task.delay(lastsFor + 2, function()
		clone.AuraAttachment.Aura:Clear()
	end)
	task.delay(delayPortalSpawnBy, function()
		renderSteppedLoopFor(delayPortalSpawnBy * 0.5, function(_, _, p)
			for _, emitter in ipairs(clone.AuraAttachment:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if not emitter:GetAttribute("InitialTransparency") then
					emitter:SetAttribute("InitialTransparency", emitter.Transparency)
				end

				local initialTransparency = emitter:GetAttribute("InitialTransparency")
				local numberSequenceKeypoints = {}

				for i, keypoint in ipairs(initialTransparency.Keypoints) do
					local v5 = math.lerp(1, keypoint.Value, p)
					numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, v5, keypoint.Envelope)
				end

				emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
			end
		end)
	end)
	task.delay(lastsFor - 0.5, function()
		if v2 then
			Util.Sound:FadeOut(v2, 0.3)
		end

		Util.Sound:Play("Portal_C_Portal_Disappear_01", clone.Position)
		renderSteppedLoopFor(delayPortalSpawnBy * 0.5, function(_, _, p)
			for _, emitter in ipairs(clone.AuraAttachment:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if not emitter:GetAttribute("InitialTransparency") then
					emitter:SetAttribute("InitialTransparency", emitter.Transparency)
				end

				local initialTransparency = emitter:GetAttribute("InitialTransparency")
				local numberSequenceKeypoints = {}

				for i, keypoint in ipairs(initialTransparency.Keypoints) do
					local v5 = math.lerp(keypoint.Value, 1, p)
					numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, v5, keypoint.Envelope)
				end

				emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
			end
		end)
	end)
end