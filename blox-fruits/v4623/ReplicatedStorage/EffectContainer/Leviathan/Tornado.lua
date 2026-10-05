local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local tornado = FX:WaitForChild("Leviathan").Tornado
local parts = {}
return function(p)
	if p.ID == 3 then
		local v = parts
		parts = {}

		for _, v2 in pairs(v) do
			v2:Destroy()
		end
	else
		if (workspace.CurrentCamera.CFrame.Position - p.Part.CFrame.Position).Magnitude > 3000 then
			return
		end

		local clone = script.IcyTornado:Clone()
		clone.Parent = workspace._WorldOrigin
		clone:PivotTo(p.Part.CFrame)
		table.insert(parts, p.Part)

		local function HeartbeatLoopFor(p2, callback)
			local lastTime = os.clock()
			local heartbeatConnection = nil
			local RunService = game:GetService("RunService")
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if lastTime + p2 <= os.clock() then
					return heartbeatConnection:Disconnect()
				end

				callback(os.clock() - lastTime)
			end)
			return heartbeatConnection
		end

		local v = {}
		local children = clone.CylinderVerticalRig:GetChildren()
		local descendants = clone:GetDescendants()
		local SkinnedCylinder = require(script.Parent.SkinnedCylinder)

		local function fn()
			clone:PivotTo(p.Part.CFrame)
		end

		local lastTime = os.clock()
		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		local v2 = 123123
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if lastTime + v2 <= os.clock() then
				return heartbeatConnection:Disconnect()
			end

			fn(os.clock() - lastTime)
		end)
		v.MovementUpdate = heartbeatConnection

		-- equivalent calls inferred from this helper; original call sites unknown
		local function createFrameSkipper()
			local v3 = 1
			return function(p2)
				local v4 = 60 / p2
				v3 += 1

				if v4 <= v3 then
					v3 -= v4
					return false
				else
					return true
				end
			end
		end

		local function naturalSort(p2, p3)
			local function extractNumber(name)
				local match = name:match("(%d+%.?%d*)")

				if match == nil then
					warn("Warning: No number found in: " .. name)
					return 0
				end

				local v3 = select(2, match:gsub("%.", ""))

				if v3 > 1 then
					warn("Warning: More than one dot in number in: " .. name)
					match = match:gsub("%.", "", v3 - 1)
				end

				local match2 = name:match("(%d+)%D+%d+")

				if match2 ~= nil and not name:match("(%d+%.%d+)") then
					warn("Warning: Numbers separated by non-dot characters in: " .. name)
					match = match2
				end

				return (tonumber(match))
			end

			return extractNumber(p2.Name) < extractNumber(p3.Name)
		end

		table.sort(children, naturalSort)

		for i, bone in ipairs(children) do
			if not bone:IsA("Bone") then
				table.remove(children, i)
			end
		end

		local worldCFrames = {}

		for i, v3 in ipairs(children) do
			worldCFrames[i] = v3.WorldCFrame
		end

		local clones = {}

		for i, parent in ipairs(children) do
			if i % 2 ~= 0 then
				continue
			end

			local clone2 = tornado.ParticleEmitter:Clone()
			clone2.Enabled = false
			table.insert(clones, clone2)
			clone2.Parent = parent
		end

		for i, v3 in ipairs(clones) do
			v3.Rate = math.floor(20 * (1 - i / #clones))

			if i % 3 == 0 then
				v3.Orientation = Enum.ParticleOrientation.FacingCamera
				v3.LockedToPart = true
				v3.Speed = NumberRange.new(0)
				v3.RotSpeed = NumberRange.new(400)
				v3.ZOffset = -5
				v3.Color = ColorSequence.new(Color3.fromRGB(192, 228, 255))
			end

			if i % 3 == 0 then
				v3.Speed = NumberRange.new(0)
			end
		end

		clone.Ring.ParticleEmitter.Enabled = false
		local clones2 = {}
		local clone2 = clone.Ring:Clone()
		clone2.Parent = clone
		table.insert(clones2, clone2)
		local clone3 = clone.Ring:Clone()
		clone3.Parent = clone
		table.insert(clones2, clone3)
		local clone4 = clone.Ring:Clone()
		clone4.Parent = clone
		table.insert(clones2, clone4)
		clone.Ring:Destroy()
		clone.CylinderVerticalRig.Material = Enum.Material.Neon
		clone.CylinderVerticalRig.Color = Color3.fromRGB(108, 150, 157)
		local count = #children

		local function spaceCurve(p2, p3)
			return (Vector3.new(
				14 * p2 * math.cos(6.283185307179586 * p2 - p3),
				p2,
				14 * p2 * math.sin(6.283185307179586 * p2 - p3)
			))
		end

		local pivotPoint = clone.PivotPoint
		local v3 = 2 * (worldCFrames[count].Position - worldCFrames[1].Position).Y
		local v4 = 0
		local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
		local v5 = createVector(1, 1, 1) * (0 / 0)
		local v6 = math.random() * 7 * 10
		local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
		local v7 = 60
		local v8 = time()
		local RunService2 = game:GetService("RunService")
		v.verticalCylinderConnection = RunService2.Heartbeat:Connect(function()
			if frameSkipper(v7) then
				return
			end

			local v9 = (time() - v8) * 7 + v6
			local position = pivotPoint.Position

			if v4 > 0.1 then
				for i, v10 in ipairs(children) do
					local v11 = (i - 1) / (count - 1)
					local v12 = position + Vector3.new(1, v4, 1) * Vector3.new(
						14 * v11 * math.cos(6.283185307179586 * v11 - v9),
						v11,
						14 * v11 * math.sin(6.283185307179586 * v11 - v9)
					)
					local lookVector = (CFrame.lookAt(createVector(0, 0, 0), v12 - position) * CFrame.Angles(
						0.3490658503988659,
						0,
						0
					)).LookVector

					if lookVector == lookVector then
						v10.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), lookVector) * inverse + v12
					else
						v10.WorldCFrame = CFrame.Angles(0, v9, 0) + v12
					end
				end
			else
				for _, v10 in ipairs(children) do
					v10.WorldCFrame = CFrame.new(v5)
				end
			end

			for i = 1, 3 do
				clones2[i].CFrame = children[math.ceil(i * count / 3)].WorldCFrame * CFrame.Angles(0, v9, 0) * inverse
			end
		end)

		local function NoiseBetween(p2: number, p3: number, p4: number, p5: number, p6: number)
			return p5 + (p6 - p5) * (math.noise(p2, p3, p4) + 0.5)
		end

		if SkinnedCylinder.VERSION == nil or SkinnedCylinder.VERSION < 1.1 then
			error("SkinnedCylinder: This module needs to be updated with the latest version")
		end

		local v9 = SkinnedCylinder.new(
			clone,
			CFrame.new(pivotPoint.Position + createVector(-0, -20, -0)),
			createVector(20, 80, 20),
			workspace.Terrain,
			true
		)
		local maxX = v9.boneInstanceMap.maxX
		local maxY = v9.boneInstanceMap.maxY
		local boneInstanceMap = v9.boneInstanceMap
		local defaultBonePosMap = v9.defaultBonePosMap
		v9.cylinderPart.Color = Color3.fromRGB(117, 163, 163)
		v9.cylinderPart.Material = Enum.Material.Neon
		v9.cylinderPart.Transparency = 0
		local v10 = table.create(maxY, 0)

		for i in ipairs(v10) do
			v10[i] = (i - 1) / (maxY - 1)
		end

		for i = 1, defaultBonePosMap.maxY do
			for i2 = 1, defaultBonePosMap.maxX do
				local v11 = (i2 - 1) / (maxX - 1)
				local v12 = (i - 1) / (maxY - 1)
				local v13 = v11 * 2 * 3.141592653589793
				local v14 = v12 * 3.141592653589793 - 1.5707963267948966
				local vector2 = Vector3.new(math.cos(v14) * math.cos(v13), math.sin(v14), math.cos(v14) * math.sin(v13))
				defaultBonePosMap:set(i2, i, vector2)
				local get = boneInstanceMap:get(i2, i)
				get.WorldCFrame = CFrame.new(pivotPoint.Position + createVector(-0, -20, -0) + vector2)
			end
		end

		local function triangleWave(p2)
			return math.abs(p2 - math.floor(p2) - 0.5) * 4 - 1
		end

		local inverse2 = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
		local v11 = 0
		local v12 = math.random() * 8 * 10
		local frameSkipper2 = createFrameSkipper() -- equivalent call inferred; original call site unknown
		local v13 = 60

		local function fn2(p2, _, _)
			if frameSkipper2(v13) then
				return
			end

			local v14 = -p2 * 8 + v12

			for i = 1, maxY do
				local v15 = 1 - v10[i]
				local v16 = 0.5 * (maxX - 1) * 3.141592653589793 * v15 + v14
				local v17 = 0.1 + ((-1 + 2 * (math.noise(v16, 1.4, 2) + 0.5) + (-0.2 + 0.4 * (math.noise(v16, 1.4, 2) + 0.5))) / 1.2) ^ 2

				for i2 = 1, maxX do
					local v18 = boneInstanceMap:get(i2, i)
					local v19 = defaultBonePosMap:get(i2, i)
					local v20 = (i2 - 1) / (maxX - 1)
					local v21 = 0.5 * (maxX - 1) * 3.141592653589793 * v20 + 0 * v14
					local v22 = (v17 + ((-1 + 2 * (math.noise(v21, 1.4, 2) + 0.5) + (-0.2 + 0.4 * (math.noise(
						v21,
						1.4,
						2
					) + 0.5))) / 1.2) ^ 2) * v11
					v18.WorldCFrame = CFrame.new(v19 * v22 * createVector(1, 0.7, 1) + pivotPoint.Position + createVector(
						-0,
						-20,
						-0
					))
				end
			end
		end

		local lastTime2 = os.clock()
		local heartbeatConnection2 = nil
		local RunService3 = game:GetService("RunService")
		local v14 = 155111
		heartbeatConnection2 = RunService3.Heartbeat:Connect(function()
			if lastTime2 + v14 <= os.clock() then
				return heartbeatConnection2:Disconnect()
			end

			fn2(os.clock() - lastTime2)
		end)
		v.spikesConnection = heartbeatConnection2
		local spinParticles = clone.SpinParticles

		local function fn3(p2)
			spinParticles.CFrame = CFrame.Angles(0, p2, 0) * inverse2 + spinParticles.Position
		end

		local lastTime3 = os.clock()
		local heartbeatConnection3 = nil
		local RunService4 = game:GetService("RunService")
		local v15 = 155111
		heartbeatConnection3 = RunService4.Heartbeat:Connect(function()
			if lastTime3 + v15 <= os.clock() then
				return heartbeatConnection3:Disconnect()
			end

			fn3(os.clock() - lastTime3)
		end)
		v.spinParticlesConnection = heartbeatConnection3
		local v16 = math.clamp(clone.FadeInInterpolant.Value, 0, 1)
		v.fadeInChanged = clone.FadeInInterpolant:GetPropertyChangedSignal("Value"):Connect(function()
			local v17 = math.clamp(clone.FadeInInterpolant.Value, 0, 1)

			if v17 <= 0 then
				for _, effect in ipairs(descendants) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			elseif v17 >= 1 then
				for _, effect in ipairs(descendants) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					elseif effect:IsA("Beam") then
						effect.Enabled = true
						effect.Transparency = NumberSequence.new(0)
					end
				end
			else
				local v18 = 1 - v17

				for _, effect in ipairs(descendants) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					elseif effect:IsA("Beam") then
						effect.Enabled = true
						effect.Transparency = NumberSequence.new(v18)
					end
				end
			end

			if v16 <= 0.25 and v17 > 0.25 then
				clone.PivotPoint.Attachment.OuterRing:Emit(1)

				for _, v18 in ipairs(children) do
					local particleEmitter = v18:FindFirstChild("ParticleEmitter")

					if particleEmitter then
						particleEmitter.Enabled = true
					end
				end

				for _, v18 in ipairs(clones2) do
					local particleEmitter = v18:FindFirstChild("ParticleEmitter")

					if particleEmitter then
						particleEmitter.Enabled = true
					end
				end
			elseif v16 >= 0.25 and v17 < 0.25 then
				for _, v18 in ipairs(children) do
					local particleEmitter = v18:FindFirstChild("ParticleEmitter")

					if particleEmitter then
						particleEmitter.Enabled = false
					end
				end

				for _, v18 in ipairs(clones2) do
					local particleEmitter = v18:FindFirstChild("ParticleEmitter")

					if particleEmitter then
						particleEmitter.Enabled = false
					end
				end
			end

			v4 = v3 * v17
			v11 = v17 * 80
			v16 = v17
		end)
		clone.FadeInInterpolant.Value = 0
		local v17 = math.clamp(clone.LODInterpolant.Value, 0, 1)
		v.LODChanged = clone.LODInterpolant:GetPropertyChangedSignal("Value"):Connect(function()
			local v18 = math.clamp(clone.LODInterpolant.Value, 0, 1)
			local v19 = math.clamp(math.ceil((1 - v18) * 60), 1, 60)
			v7 = v19
			v13 = v19
			v17 = v18
		end)
		clone.LODInterpolant.Value = 0

		local function fn4()
			local v18 = math.clamp(
				((workspace.CurrentCamera.CFrame.Position - clone.PivotPoint.Position).Magnitude - 600) / 1400,
				0,
				1
			)
			clone.LODInterpolant.Value = v18
		end

		local lastTime4 = os.clock()
		local heartbeatConnection4 = nil
		local RunService5 = game:GetService("RunService")
		local v18 = 155111
		heartbeatConnection4 = RunService5.Heartbeat:Connect(function()
			if lastTime4 + v18 <= os.clock() then
				return heartbeatConnection4:Disconnect()
			end

			fn4(os.clock() - lastTime4)
		end)
		v.CameraLODUpdate = heartbeatConnection4
		local flag = false

		local function destroyTornado()
			if flag then
				return
			end

			flag = true

			for _, connection in pairs(v) do
				connection:Disconnect()
			end

			clone:Destroy()
			local index = table.find(parts, p.Part)

			if index then
				table.remove(parts, index)
			end
		end

		v.Destruction1 = p.Part:GetPropertyChangedSignal("Parent"):Connect(function()
			if not p.Part.Parent then
				destroyTornado()
			end
		end)
		v.Destruction2 = p.Part.Destroying:Connect(function()
			destroyTornado()
		end)
		task.wait(2)

		if flag then
			return
		end

		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(clone.FadeInInterpolant, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
			Value = 1
		})
		tween:Play()
		tween.Completed:Wait()

		if flag then
			return
		end

		task.wait(5)

		if flag then
			return
		end

		local tween2 = TweenService:Create(clone.FadeInInterpolant, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Value = 0
		})
		tween2:Play()
		tween2.Completed:Wait()

		if flag then
			return
		end

		task.wait(4)
		destroyTornado()
	end
end