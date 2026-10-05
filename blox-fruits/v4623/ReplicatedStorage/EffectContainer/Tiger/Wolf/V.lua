local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local RockRipple = require(script.Parent.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v4 = part.CFrame - position
		local v5 = position - v2
		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = v4 + v2 + v5 * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local function tweenBeamTransparency(instance, tweenInfo, p: number)
	if instance:GetAttribute("BeamTransparency") == nil then
		instance:SetAttribute("BeamTransparency", instance.Transparency == NumberSequence.new(1) and 1 or 0)
		instance:SetAttribute("OriginalBeamTransparencyNumberSequence", instance.Transparency)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance:GetAttribute("BeamTransparency")
	local changedConnection = numberValue.Changed:Connect(function(beamTransparency)
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(instance:GetAttribute("OriginalBeamTransparencyNumberSequence").Keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * beamTransparency
			)
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		instance:SetAttribute("BeamTransparency", beamTransparency)
	end)
	local v = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v:Play()
	v.Completed:Once(function()
		changedConnection:Disconnect()
		changedConnection = nil
		numberValue:Destroy()
		numberValue = nil
	end)
end

local function windRibbon(p, cFrame, p2, p3, p4, folder)
	Util.Debris:AddItem(folder, 2)
	folder.Part.Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor")
	folder.Part.CFrame = cFrame
	folder.Part.Transparency = 1
	local tween = TweenService:Create(
		folder.Part,
		TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = folder.Part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			),
			Size = folder.Part.Size * math.random(6, 8),
			Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor"),
			Transparency = 1
		}
	)
	Util.ResizeModel(folder, math.random(p2, p3), folder.Part.Position)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v = beam
			task.spawn(function()
				task.wait(0.15)
				tweenBeamTransparency(v, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder.Part.beam1.Beam
		local beam2 = folder.Part.beam2.Beam
		local beam3 = folder.Part.beam3.Beam
		local beam4 = folder.Part.beam4.Beam
		local beam5 = folder.Part.beam5.Beam
		local beam6 = folder.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		folder:Destroy()
	end)
	Util.SetParentOverrideWithColor(folder, p4, p, "LeopardFruitVFXColor")
	tween:Play()
end

local function lerp2(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function tweenClock(p: number, p2: number, p3: number)
	local lastTime = tick()

	while tick() - lastTime <= p3 do
		local v = math.min((tick() - lastTime) / p3, 1)
		Lighting.ClockTime = p + (p2 - p) * v
		RunService.RenderStepped:Wait()
	end
end

local function wrap24(p: number)
	local v = p % 24

	if v < 0 then
		return v + 24
	end

	return v
end

local function runLocalNightWarp(p: number, clockTime: number, value: number?)
	local v = value or 0.2
	task.spawn(function()
		local clockTime2 = Lighting.ClockTime
		local clockTime3 = Lighting.ClockTime
		tweenClock(clockTime2, clockTime, v)
		local v2 = math.max(0, p - 2 * v)

		if v2 > 0 then
			local lastTime = tick()

			while tick() - lastTime < v2 do
				Lighting.ClockTime = clockTime
				RunService.RenderStepped:Wait()
			end
		end

		tweenClock(clockTime, clockTime3, v)
		Lighting.ClockTime = clockTime3
	end)
end

local V = FX:WaitForChild("TigerEffects").V
local werewolfV = FX:WaitForChild("TigerEffects").WerewolfV
return function(data)
	local player = data.player
	local hrp = data.hrp
	local _ = data.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local transformTiger = V.TransformTiger
	local clone = transformTiger.Charge:Clone()
	transformTiger.Explode:Clone()
	local clone2 = transformTiger.Floor:Clone()
	transformTiger.FIRESHOCKSHOCK:Clone()
	local clone3 = V.head.EYETIGERL:Clone()
	local clone4 = V.head.EYETIGERR:Clone()
	local clone5 = V.head.POP:Clone()
	local clone6 = V.head.POP2:Clone()
	Util.Sound:Play("BF_TigerFt_TFM_V_WolfVersion_03_V3", hrp)

	if hrp.Parent == game.Players.LocalPlayer.Character then
		task.spawn(function()
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 96
				}
			):Play()
			task.wait(0.067)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.033, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 70
				}
			):Play()
			task.wait(0.033)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.433, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 62
				}
			):Play()
			task.wait(0.433)
			TweenService:Create(Workspace.Camera, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				FieldOfView = 30
			}):Play()
			task.wait(0.1)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.034, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 105
				}
			):Play()
			Util.CameraShaker:ShakeOnce(15, 12, 0.05, 0.7, createVector(2, 2, 2), createVector(2, 2, 2))
			task.wait(0.034)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			):Play()
		end)
	end

	Util.SetParentOverrideWithColor(clone3, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone4, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone5, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone6, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	emitAll(clone3)
	emitAll(clone4)
	emitAll(clone5)
	emitAll(clone5)
	emitAll(clone6)
	Util.Debris:AddItem(clone3, 2.5)
	Util.Debris:AddItem(clone4, 2.5)
	Util.Debris:AddItem(clone5, 2.5)
	Util.Debris:AddItem(clone6, 2.5)
	task.wait(0.1)
	clone2.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "LeopardFruitVFXColor")
	Util.Debris:AddItem(clone2, 4.5)
	emitAll(clone2)
	task.wait(0.1)
	clone.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
	Util.Debris:AddItem(clone, 2.5)
	task.spawn(function()
		for _ = 1, 5 do
			emitAll(clone)
			task.wait(0.045)
		end
	end)
	task.wait(0.4)
	task.spawn(function()
		task.wait(1.85)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Enabled == true then
				emitter.Enabled = false
			end
		end
	end)
	task.spawn(function()
		local TweenService2 = game:GetService("TweenService")

		local function tweenEmitterSize(beamSpark, p: number, duration: number, p2, p3)
			local value = beamSpark.Size.Keypoints[1].Value
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = value
			local changedConnection = numberValue.Changed:Connect(function()
				beamSpark.Size = NumberSequence.new(numberValue.Value)
			end)
			local tween = TweenService2:Create(numberValue, TweenInfo.new(duration, p2, p3), {
				Value = p
			})
			tween.Completed:Once(function()
				if changedConnection then
					changedConnection:Disconnect()
				end

				numberValue:Destroy()
			end)
			tween:Play()
			return tween
		end

		local clone7 = werewolfV:Clone()
		clone7:PivotTo(CFrame.lookAt(createVector(0, 0, 0), -hrp.CFrame.LookVector * createVector(1, 0.01, 1)) + hrp.Position)
		clone7.Parent = _WorldOrigin
		local primaryPart = clone7.PrimaryPart
		heartbeatLoopFor2(4, function()
			if hrp then
				clone7:PivotTo(CFrame.lookAt(createVector(0, 0, 0), -hrp.CFrame.LookVector * createVector(1, 0.01, 1)) + hrp.Position)
			end
		end)
		Util.DestroyAfter(clone7, 4)
		task.spawn(function()
			local LeftClickExplode = require(script:WaitForChild("LeftClickExplode"))
			LeftClickExplode({
				hrp = primaryPart,
				isForTransformation = true
			})
		end)
		primaryPart.Plasma:SetAttribute("Enabled", true)
		task.spawn(function()
			local Splash = require(script:WaitForChild("Splash"))
			Splash(primaryPart.Plasma)
		end)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Parent = game:GetService("Lighting")
		local wolfGenie = primaryPart:WaitForChild("WolfGenie")
		local v = { wolfGenie.RootPart:FindFirstChild("Eye1", true), wolfGenie.RootPart:FindFirstChild("Eye2", true) }
		local v2 = { primaryPart.Eye1, primaryPart.Eye2 }
		wolfGenie:ScaleTo(3.5)

		for i, v3 in ipairs(v2) do
			v3.WorldPosition = v[i].WorldPosition
		end

		for _, v3 in ipairs(v2) do
			local v4 = v3
			task.spawn(function()
				v4.BeamSpark.Enabled = true
				v4.BeamSpark.Size = NumberSequence.new(7)
				tweenEmitterSize(v4.BeamSpark, 14, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out).Completed:Wait()
				tweenEmitterSize(v4.BeamSpark, 3, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
			end)
			local v5 = v3
			task.delay(0.8, function()
				v5.BeamSpark.Enabled = false
			end)
		end

		primaryPart.SpotLight.Enabled = true

		if player == localPlayer then
			local v3 = 0.05 or 0.2
			local clockTime3 = 24
			local v5 = 1.2
			task.spawn(function()
				local clockTime = Lighting.ClockTime
				local clockTime2 = Lighting.ClockTime
				tweenClock(clockTime, clockTime3, v3)
				local v6 = math.max(0, v5 - 2 * v3)

				if v6 > 0 then
					local lastTime = tick()

					while tick() - lastTime < v6 do
						Lighting.ClockTime = clockTime3
						RunService.RenderStepped:Wait()
					end
				end

				tweenClock(clockTime3, clockTime2, v3)
				Lighting.ClockTime = clockTime2
			end)
		end

		local tigerRoarRig = Util.Anims:Get(wolfGenie, "TigerRoar_Rig")
		tigerRoarRig:Play(0)
		task.delay(tigerRoarRig.Length * 0.9, function()
			tigerRoarRig:AdjustSpeed(0)
		end)
		heartbeatLoopFor2(0.05, function(_: number, _: number, p: number)
			bloomEffect.Threshold = math.lerp(2, 0.5, p)
			bloomEffect.Size = math.lerp(24, 50, p)
			bloomEffect.Intensity = math.lerp(1, 5, p)
			primaryPart.Part.Transparency = math.lerp(1, 0, p)
			primaryPart.SpotLight.Range = math.lerp(0, 100, p)

			for _, child in ipairs(wolfGenie:GetChildren()) do
				if child:GetAttribute("TransparencyBool") then
					child.Transparency = math.lerp(1, 0.3, p)
				end
			end

			wolfGenie:ScaleTo((math.lerp(3.5, 5, p)))

			for i, v3 in ipairs(v2) do
				v3.WorldPosition = v[i].WorldPosition
			end
		end, function()
			heartbeatLoopFor2(1, function(_: number, _: number, p: number)
				local v3 = math.clamp(p * 5, 0, 1)
				bloomEffect.Threshold = math.lerp(0.5, 2, v3)
				bloomEffect.Size = math.lerp(50, 7, v3)
				bloomEffect.Intensity = math.lerp(5, 1, v3)
				primaryPart.Part.Transparency = math.lerp(0, 1, p)
				primaryPart.SpotLight.Range = math.lerp(100, 0, p ^ 2)

				for _, child in ipairs(wolfGenie:GetChildren()) do
					if child:GetAttribute("TransparencyBool") then
						child.Transparency = math.lerp(0.3, 1, p ^ 2)
					end
				end

				wolfGenie:ScaleTo((math.lerp(5, 9, p)))

				for i, v4 in ipairs(v2) do
					v4.WorldPosition = v[i].WorldPosition
				end
			end, function()
				primaryPart.Part.Transparency = 1
				primaryPart.SpotLight.Range = 0
				bloomEffect:Destroy()

				for _, child in ipairs(wolfGenie:GetChildren()) do
					if child:GetAttribute("TransparencyBool") then
						child.Transparency = 1
					end
				end

				for i, v3 in ipairs(v2) do
					v3.WorldPosition = v[i].WorldPosition
				end

				primaryPart.SpotLight.Enabled = false
			end)
		end)
		task.delay(0.4, function()
			primaryPart.Plasma:SetAttribute("Enabled", false)
		end)
	end)
	local ray = Util.Ray
	local v = hrp.Position + createVector(0, 2, 0)
	local v2 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v3, v4, v5 = ray(v, createVector(-0, -40, -0), v2, false)

	if v3 then
		local cframe = CFrame.new(v4)
		local clone7 = FX:WaitForChild("TigerEffects").V.VFloor:Clone()
		clone7.CFrame = cframe
		Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player, "LeopardFruitVFXColor")
		emitAll(clone7)
		Util.Debris:AddItem(clone7, 4.5)
		task.spawn(function()
			task.wait(0.1753)
			local clone8 = FX:WaitForChild("TigerEffects").V.VExpand:Clone()
			clone8.PrimaryPart.CFrame = CFrame.new(v4)
			Util.SetParentOverrideWithColor(clone8, _WorldOrigin, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone8, 3)
			emitAll(clone8)
		end)
		task.spawn(function()
			local part = Instance.new("Part")
			part.Name = "BAMPROCK"
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
			part.Anchored = true
			RockRipple.createRippleEffect(part, v4, 9, 5, 7, 3)
		end)
		local v6 = CFrame.new(v4, v4 + v5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local random = Random.new()

		for i = 1, 22 do
			local v8 = Rock2.new({
				Type = "Ground",
				FadeOut = { 0.25, 0.5 },
				FadeIn = { 0.25, 0.5 },
				Lifetime = { 1, 2.5 },
				Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
				Scale = { 2.75, 5.5 }
			})
			local unit = Vector3.new(
				math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
				random:NextNumber(0, 1) * 1.25,
				math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
			).Unit
			v8.Type = "Flying"
			v8:Spawn(v6 * CFrame.Angles(0, 6.283185307179586 * (i / 22), 0) * CFrame.new(0, 0, -33.75))
			v8:Eject({
				Velocity = 1.5 * Util.Misc.Physics.Velocity(
					Vector3.new(),
					unit * random:NextNumber(22, 88),
					Vector3.new(0, -Workspace.Gravity * random:NextNumber(0.25, 1), 0),
					0.25 + random:NextNumber(0, 2)
				),
				AngularVelocity = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				) * 2 * 3.141592653589793 * (1 / v8.Scale)
			})
		end

		task.spawn(function()
			local groundSpike = FX:WaitForChild("TigerEffects").GroundSpike
			local cFrame = cframe

			for i = 0, 17 do
				local number = random:NextNumber(i * 2 * 3.141592653589793 / 18, (i + 1) * 2 * 3.141592653589793 / 18)
				local v8 = math.random()
				local v9 = 24 + 30 * v8
				local clone8 = groundSpike:Clone()
				local v10 = 1.6 + 1.6 * v8
				ScaleModel(clone8, v10)
				local v11 = cFrame * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v9) * CFrame.Angles(
					-math.rad(20 + 25 * v8),
					0,
					0
				) * CFrame.new(0, -27 * v10, 0)
				clone8:PivotTo(v11)
				Util.SetParentOverrideWithColor(clone8, _WorldOrigin, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone8, 8)
				destroyAfter(clone8, 3)
				task.delay(random:NextNumber(0.3, 0.6), function()
					heartbeatLoopFor2(0.6, function(p, p2, p3)
						clone8.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(255 * (1 - p3), 128 * (1 - p3), 0),
							player,
							"LeopardFruitVFXColor"
						)
					end, function()
						clone8.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(0, 0, 0),
							player,
							"LeopardFruitVFXColor"
						)
					end)
				end)
				local v13 = clone8
				task.delay(random:NextNumber(1.6, 2), function()
					TweenService:Create(
						v13.lavaGradient,
						TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							CFrame = v13.lavaGradient.CFrame * CFrame.new(0, math.random(-45, -35), 0)
						}
					):Play()
				end)
				local v14 = clone8
				task.delay(random:NextNumber(0, 0.4), function()
					heartbeatLoopFor2(0.1, function(p, p2, p3)
						v14:PivotTo(v11 * CFrame.new(0, 27 * v10 * p3, 0))
					end)
				end)
			end
		end)
	end
end