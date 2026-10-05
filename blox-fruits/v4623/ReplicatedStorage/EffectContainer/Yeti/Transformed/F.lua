local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local Spikes = require(script.Parent.Parent.Modules.Spikes)
local Beziers = require(script.Parent.Parent.Modules.Beziers)
local FX = require(ReplicatedStorage.FX)
local f_Tr = FX:WaitForChild("YetiEffects").F_Tr
Util.ResizeModel(f_Tr.CracksGround, 2)

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

local function mockRootPart(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

local function debrisPart(player, data, p, vector2, p2, p3, p4, p5)
	for _ = 1, p5 do
		local v = math.random(13, 21) / 10
		local clone = f_Tr.DebrisIce:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.Material = data.Material
		clone.Transparency = data.Transparency
		clone.Reflectance = data.Reflectance
		clone.Color = data.Color
		clone.Size = Vector3.new(v, v, v)
		clone.CFrame = CFrame.new(p, p + vector2) * CFrame.Angles(
			math.rad((math.random(-53, 53))),
			math.rad((math.random(-53, 53))),
			(math.rad((math.random(-53, 53))))
		)
		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		clone.Velocity = clone.CFrame.lookVector.Unit * Vector3.new(
			math.random(-p2, p2),
			math.random(p3, p4),
			math.random(-p2, p2)
		)
		clone.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
		task.spawn(function()
			task.wait(math.random(1.75, 2.65))
			emitAll(clone.EmitSmaller)
			TweenService:Create(clone, TweenInfo.new(0.4), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		return clone
	end
end

return function(instance)
	local player = instance.player
	local origin = instance.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local stage = instance.Stage

	if stage == 1 then
		local player2 = instance.Player
		local root = instance.Root
		local _ = instance.timeUntilReachedEndPoint
		local _ = instance.endPoint
		local startCFrame = instance.StartCFrame
		local clone = f_Tr.Part.dash:Clone()
		Util.SetParentOverrideWithColor(clone, root, player, "YetiFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1.35)
		Util.Sound:Play("YETI_TNSFM_F_ArcticTackle_Dash_03", root)
		local clone2 = f_Tr.Part.dashloop:Clone()
		Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone2, 1.35)
		local endPoint = instance.endPoint
		local timeUntilReachedEndPoint = instance.timeUntilReachedEndPoint or 0.2
		local magnitude = (startCFrame.Position - endPoint).Magnitude
		task.spawn(function()
			root.Anchored = true
			local cFrame = CFrame.new(instance.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime = os.clock()

			while os.clock() - lastTime < timeUntilReachedEndPoint do
				local v2 = (os.clock() - lastTime) / timeUntilReachedEndPoint
				root.CFrame = cFrame * CFrame.new(0, 0, magnitude * (1 - v2 ^ 0.5))
				RunService.PreSimulation:Wait()
			end

			root.CFrame = cFrame
			root.Anchored = false
		end)
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(11, 9, 0.15, 0.9, createVector(0.8, 0.8, 0.8), createVector(0.8, 0.8, 0.8))
				local clone3 = script.DOF:Clone()
				Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
				TweenService:Create(clone3, TweenInfo.new(0.433, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				Util.Debris:AddItem(clone3, 0.5)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						FieldOfView = 35
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 105
					}
				):Play()
				task.wait(0.035)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		task.spawn(function()
			for _ = 1, 9 do
				task.spawn(function()
					for _ = 1, 2 do
						local clone3 = f_Tr.partfly2:Clone()
						clone3.CFrame = root.CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-1.5, 15),
							math.random(-15, 15)
						)
						Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
						Util.Debris:AddItem(clone3, 2)
						local v = math.random(11, 16) / 100
						Beziers.Interpolate(
							"Cubic",
							v,
							100,
							v,
							nil,
							clone3.CFrame,
							clone3.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							clone3.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							root.CFrame,
							clone3,
							"CFrame"
						)
					end
				end)
				task.wait(0.0075)
			end
		end)
		local yetiRig = root.Parent.YetiRig.YetiRig
		emitAll(yetiRig.DashSmoke)

		for _ = 1, 6 do
			emitAll(clone2)
			task.wait(0.0175)
		end

		emitAll(yetiRig.DashSmoke)
	elseif stage == 2 then
		local player2 = instance.Player
		local root = instance.Root
		local victimChar = instance.victimChar
		local userChar = instance.userChar
		local humanoid = instance.Humanoid
		local victimHumanoid = instance.VictimHumanoid
		local caughtRoot = instance.caughtRoot
		local rightHand = instance.rightHand

		local function CAMERAHIT(fieldOfView)
			local clone = script.DOF:Clone()
			Util.SetParentOverrideWithColor(clone, game.Lighting, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone, 0.5)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FarIntensity = 0,
				FocusDistance = 0,
				InFocusRadius = 0,
				NearIntensity = 0
			}):Play()
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.083, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					FieldOfView = fieldOfView
				}
			):Play()
			task.wait(0.083)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FieldOfView = 70
				}
			):Play()
		end

		local fn = player2 ~= game.Players.LocalPlayer and game.Players.LocalPlayer.Character ~= victimChar and function() end or CAMERAHIT
		Util.Sound:Play("YETI_TNSFM_F_ArcticTackle_ConnectGround_01", root)
		task.spawn(function()
			if instance.Rig then
				local lastTime = tick()
				tick()
				tick()
				local hand2R = instance.Rig.RootPart:FindFirstChild("Hand2.R", true)

				if hand2R then
					local worldCFrame = hand2R.WorldCFrame
					local part = Instance.new("Part")
					part.Name = "Mock" .. part.Name
					part.Anchored = true
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
					part.Transparency = 1
					part.CFrame = worldCFrame
					part.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(part, instance.dur + 1)

					while tick() - lastTime < instance.dur and userChar and victimChar and root and rightHand and caughtRoot and not caughtRoot:FindFirstChild("CompletedThrow") and not caughtRoot.Parent:FindFirstChild("AntiMover") and not (humanoid.Health <= 0) and victimHumanoid and not (victimHumanoid.Health <= 0) do
						part.CFrame = hand2R.WorldCFrame
						caughtRoot.CFrame = part.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
						task.wait()
					end
				end
			end
		end)
		task.spawn(function()
			local DISTANCE_THRESHOLD = 210

			if instance.rayData[1] then
				local v = instance.rayData[2]
				local vector2 = instance.rayData[3]
				local v2 = vector2 * 0.1
				local _ = root.Parent:FindFirstChild("RightHand").CFrame
				local clone = f_Tr.CracksGround:Clone()
				local cframe = CFrame.new(Vector3.new(), vector2:Cross(createVector(0, 1, 0)), vector2)
				clone.CFrame = CFrame.new(v + v2) * cframe

				if player:GetAttribute("RedYeti") then
					for _, emitter in ipairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new(Color3.new(1, 0, 0))

						if emitter.Orientation == Enum.ParticleOrientation.VelocityPerpendicular then
							emitter.LightEmission = math.min(0.2, emitter.LightEmission)
						end
					end

					clone.Parent = _WorldOrigin
				else
					Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
				end

				Util.Debris:AddItem(clone, 8.3)
				task.spawn(function()
					task.wait(0.3)
					local cframe2, _ = CFrame.new(v)
					local clone2 = f_Tr.Hit1:Clone()
					clone2.CFrame = cframe2
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 3.5)
					emitAll(clone2)
					task.wait(0.05)
					fn(85)
					Util.CameraShaker:ShakeOnce(
						3,
						5,
						0.15,
						0.5,
						createVector(0.8, 0.8, 0.8),
						createVector(0.8, 0.8, 0.8)
					)
					task.spawn(function()
						local rayMap, _ = Util.RayMap(clone.Position + createVector(0, 1, 0), createVector(0, -15, 0))

						if rayMap then
							for _ = 1, 5 do
								debrisPart(player, rayMap, v, vector2, 95, 50, 90, 15)
							end
						end
					end)
				end)
				task.spawn(function()
					task.wait(0.825)
					local cframe2, _ = CFrame.new(v)
					local clone2 = f_Tr.Hit1:Clone()
					clone2.CFrame = cframe2
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 3.5)
					emitAll(clone2)
					task.wait(0.05)
					fn(105)
					Util.CameraShaker:ShakeOnce(6, 9, 0.15, 0.7, createVector(1, 1, 1), createVector(1, 1, 1))
					task.spawn(function()
						local ray, _ = Util.Ray(clone.Position + createVector(0, 1, 0), createVector(0, -15, 0))

						if ray then
							for _ = 1, 5 do
								debrisPart(player, ray, v, vector2, 145, 80, 120, 15)
							end
						end
					end)
				end)
				task.wait(0.35)

				if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
					Util.CameraShaker:ShakeOnce(9, 12, 0.01, 0.45)
				end

				emitAll(clone.Smash1)
				Spikes.Ring(player, 14, 2, clone, nil, 12, 9, 12, 3.4, nil, _WorldOrigin)
				task.wait(0.525)

				if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
					Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.45)
				end

				emitAll(clone.Smash2)
				Spikes.Ring(player, 10, 1, clone, nil, 18, 3.6, 12, 4, nil, _WorldOrigin)
				Spikes.Ring(player, 12, 2, clone, nil, 9, 7, 18, 3.4, nil, _WorldOrigin)
				task.wait(0.45799999999999996)
				local clone2 = f_Tr.swinguntran.swing:Clone()
				Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
				emitAll(clone2)
				Util.Debris:AddItem(clone2, 2.2)
				task.wait(-0.516)
				local folder = Instance.new("Folder")
				folder.Name = "CompletedThrow"
				Util.SetParentOverrideWithColor(folder, caughtRoot, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(folder, 0.5)
				local cframe2 = CFrame.lookAt(root.Position, instance.MousePosVal.Value)
				local part = Instance.new("Part")
				part.CanTouch = false
				part.CanQuery = false
				part.CanCollide = false
				part.Anchored = true
				part.Transparency = 1
				part.CFrame = cframe2
				Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(part, 3)

				for _, attachment in pairs(f_Tr.swingup.swingup:GetChildren()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					local clone3 = attachment:Clone()
					Util.SetParentOverrideWithColor(clone3, part, player, "YetiFruitVFXColor")
					emitAll(clone3)
					Util.Debris:AddItem(clone3, 2.5)
				end

				task.spawn(function()
					task.wait(0.2)

					for _ = 1, 19 do
						local clone3 = f_Tr.IceWind:Clone()
						clone3.CFrame = part.CFrame * CFrame.Angles(
							math.rad(math.random(-450, 450) / 10),
							math.rad(math.random(-450, 450) / 10),
							(math.rad(math.random(-2, 2) / 10))
						)
						clone3.Position = part.position
						clone3.Anchored = false
						Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
						local v3 = math.random(2, 10) / 5
						local v4 = math.random(20, 40) / 5

						if math.random(2) == 1 then
							v4 *= -1
						end

						for _, attachment in pairs(clone3:GetDescendants()) do
							if not attachment:IsA("Attachment") then
								continue
							end

							attachment.Position = Vector3.new(0, attachment.Name == "Top" and v3 or -v3, 0)
							attachment.Position += Vector3.new(0, v4, 0)
						end

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
						bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(160, 490)
						Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
						local v5 = math.random(22, 41) / 1.5
						clone3.RotVelocity = clone3.CFrame.LookVector * v5
						coroutine.resume(coroutine.create(function()
							task.wait(math.random(70, 100) / 100)
							clone3.Anchored = true
							Util.Debris:AddItem(clone3, 1.5)
						end))
					end
				end)
				task.wait(0.125)
				fn(110)

				if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
					Util.CameraShaker:ShakeOnce(
						15,
						16,
						0.15,
						1,
						createVector(1.2, 1.2, 1.2),
						createVector(0.7, 0.7, 0.7)
					)
				end
			end
		end)
	elseif stage == 3 then
		local player2 = instance.Player
		local root = instance.Root
		local victimChar = instance.victimChar
		local userChar = instance.userChar
		local humanoid = instance.Humanoid
		local victimHumanoid = instance.VictimHumanoid
		local caughtRoot = instance.caughtRoot
		local rightHand = instance.rightHand

		if not instance.Rig then
			return
		end

		local function CAMERAHIT(fieldOfView)
			local clone = script.DOF:Clone()
			Util.SetParentOverrideWithColor(clone, game.Lighting, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone, 1)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FarIntensity = 0,
				FocusDistance = 0,
				InFocusRadius = 0,
				NearIntensity = 0
			}):Play()
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.083, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					FieldOfView = fieldOfView
				}
			):Play()
			task.wait(0.083)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FieldOfView = 70
				}
			):Play()
		end

		local fn = player2 ~= game.Players.LocalPlayer and game.Players.LocalPlayer.Character ~= victimChar and function() end or CAMERAHIT
		local hand2R = instance.Rig.RootPart:FindFirstChild("Hand2.R", true)
		local worldCFrame = hand2R.WorldCFrame
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = worldCFrame
		part.Parent = workspace._WorldOrigin
		part.Size = createVector(8, 8, 8)
		Util.Debris:AddItem(part, instance.dur + 1)

		for _, attachment in pairs(f_Tr.Hand:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone = attachment:Clone()
			Util.SetParentOverrideWithColor(clone, part, player, "YetiFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 0.5)
		end

		task.spawn(function()
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < instance.dur and userChar and victimChar and root and rightHand and caughtRoot and not caughtRoot:FindFirstChild("CompletedThrow") and not caughtRoot.Parent:FindFirstChild("AntiMover") and not (humanoid.Health <= 0) and victimHumanoid and not (victimHumanoid.Health <= 0) do
				part.CFrame = hand2R.WorldCFrame
				caughtRoot.CFrame = part.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				task.wait()
			end
		end)
		Util.Sound:Play("YETI_TNSFM_F_ArcticTackle_ConnectAir_01", root)
		local size = createVector(1, 1, 1) * caughtRoot.Size.Y * 5 + createVector(1, 1, 1)
		local clone = f_Tr.Freeze:Clone()
		clone.CFrame = caughtRoot.CFrame
		clone.Size = size
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = caughtRoot
		motor6D.Part1 = clone
		Util.SetParentOverrideWithColor(motor6D, clone, player, "YetiFruitVFXColor")
		local clone2 = f_Tr.Hand.Aura:Clone()
		Util.SetParentOverrideWithColor(clone2, root.Parent:FindFirstChild("RightHand"), player, "YetiFruitVFXColor")
		clone2.HandAuraBright.Enabled = true
		clone2.HandAuraDark.Enabled = true
		Util.Debris:AddItem(clone2, 2)
		task.wait(0.617)
		clone2.HandAuraBright.Enabled = false
		clone2.HandAuraDark.Enabled = false
		root.Anchored = true
		local quad = Util.Tween.ease.inout.quad
		local v2 = CFrame.new(instance.UpCFrame.p) * (root.CFrame - root.Position)
		local cframe = CFrame.lookAt(v2.p, v2.p + v2.LookVector * createVector(1, 0, 1))
		local magnitude = (root.Position - cframe.Position).Magnitude
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.3 do
			local v3 = quad(math.clamp((os.clock() - lastTime) / 0.3, 0, 1), 0, 1, 1)
			root.CFrame = cframe * CFrame.new(0, -magnitude * (1 - v3), 0)
			RunService.PreSimulation:Wait()
		end

		root.CFrame = cframe
		root.Anchored = false

		if instance.rayData[1] then
			local v3 = CFrame.new(instance.EndCFrame.p) * (root.CFrame - root.Position)
			local cframe2 = CFrame.lookAt(v3.p, v3.p + v3.LookVector * createVector(1, 0, 1))
			task.spawn(function()
				root.Anchored = true
				local magnitude2 = (root.Position - cframe2.Position).Magnitude
				local lastTime2 = os.clock()

				while os.clock() - lastTime2 < 0.3 do
					local v4 = (os.clock() - lastTime2) / 0.3
					root.CFrame = cframe2 * CFrame.new(0, magnitude2 * (1 - v4 ^ 4), 0)
					RunService.PreSimulation:Wait()
				end

				root.CFrame = cframe2
				root.Anchored = false
			end)
			task.spawn(function()
				local clone3 = f_Tr.FALLBLUE:Clone()
				clone3.CFrame = root.CFrame
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 3)
				TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					CFrame = cframe2
				}):Play()
				task.spawn(function()
					for _ = 1, 9 do
						emitAll(clone3)
						task.wait(0.025)
					end
				end)
			end)
			task.wait(0.3)
			clone:Destroy()
			local ray = Util.Ray
			local v4 = root.Position + createVector(0, 2, 0)
			local v5 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
			local v6, v7, _ = ray(v4, createVector(-0, -100, -0), v5, false)

			if v6 ~= nil then
				local cframe3 = CFrame.new(v7)
				local clone3 = f_Tr.SmashMeteor:Clone()
				clone3.CFrame = cframe3
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 3.5)
				emitAll(clone3)
				Spikes.Ring(player, 14, 2, clone3, nil, 12, 9, 12, 3.4, nil, _WorldOrigin)
			end

			if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < 210 then
				Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.75)
			end

			task.wait(0.6)
		else
			clone:Destroy()
		end

		if caughtRoot then
			local folder = Instance.new("Folder")
			folder.Name = "CompletedThrow"
			Util.SetParentOverrideWithColor(folder, caughtRoot, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(folder, 0.5)
		end

		local cframe2 = CFrame.lookAt(root.Position, instance.MousePosVal.Value)

		if instance.skipSlam then
			cframe2 = CFrame.lookAt(root.Position, root.Position - createVector(0, 1, 0))
		end

		local part2 = Instance.new("Part")
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CanCollide = false
		part2.Anchored = true
		part2.Transparency = 1
		part2.CFrame = cframe2
		Util.SetParentOverrideWithColor(part2, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(part2, 3)

		for _, attachment in pairs(f_Tr.swingup.swingup:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone3 = attachment:Clone()
			Util.SetParentOverrideWithColor(clone3, part2, player, "YetiFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 2.5)
		end

		task.spawn(function()
			task.wait(0.2)

			for _ = 1, 19 do
				local clone3 = f_Tr.IceWind:Clone()
				clone3.CFrame = part2.CFrame * CFrame.Angles(
					math.rad(math.random(-450, 450) / 10),
					math.rad(math.random(-450, 450) / 10),
					(math.rad(math.random(-2, 2) / 10))
				)
				clone3.Position = part2.position
				clone3.Anchored = false
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				local v3 = math.random(2, 10) / 5
				local v4 = math.random(20, 40) / 5

				if math.random(2) == 1 then
					v4 *= -1
				end

				for _, attachment in pairs(clone3:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v3 or -v3, 0)
					attachment.Position += Vector3.new(0, v4, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(160, 490)
				Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
				local v5 = math.random(22, 41) / 1.5
				clone3.RotVelocity = clone3.CFrame.LookVector * v5
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(70, 100) / 100)
					clone3.Anchored = true
					Util.Debris:AddItem(clone3, 1.5)
				end))
			end
		end)
		fn(110)

		if player2 == game.Players.LocalPlayer or victimChar == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(15, 16, 0.15, 1.3, createVector(1.2, 1.2, 1.2), createVector(0.7, 0.7, 0.7))
		end
	elseif stage == 5 then
		local root = instance.Root
		local holding = instance.Holding

		if not (holding or holding.Value) then
			return
		end

		local function enableAll(folder, enabled: boolean)
			for _, effect in folder:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = enabled
				end
			end
		end

		local fCharge = root.Parent.YetiRig:FindFirstChild("YetiRig").FCharge
		local v = Util.Sound:Play("YETI_TNSFM_F_ArcticTackle_Hold_01_V2", root)
		task.spawn(function()
			task.wait(0.1)
			emitAll(fCharge["Hand2.L"].Impact3)
			emitAll(fCharge.Front2.Impact3)
		end)
		enableAll(fCharge.Front1, true)
		enableAll(fCharge["Hand2.L"].ForceSmoke, true)
		enableAll(fCharge["Hand2.R"].ForceSmoke, true)
		enableAll(fCharge.eyeL, true)
		enableAll(fCharge.eyeR, true)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.075
					task.spawn(function()
						local clone = f_Tr.partfly:Clone()
						clone.CFrame = fCharge["Hand2.R"].CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-1.5, 15),
							math.random(-15, 15)
						)
						Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
						Util.Debris:AddItem(clone, 2)
						local v2 = math.random(12, 23) / 100
						Beziers.Interpolate(
							"Cubic",
							v2,
							100,
							v2,
							nil,
							clone.CFrame,
							clone.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							clone.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							fCharge["Hand2.R"].CFrame,
							clone,
							"CFrame"
						)
					end)
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		task.wait(0.05)
		enableAll(fCharge.Front1, false)
		enableAll(fCharge["Hand2.L"].ForceSmoke, false)
		enableAll(fCharge["Hand2.R"].ForceSmoke, false)
		enableAll(fCharge.eyeL, false)
		enableAll(fCharge.eyeR, false)
	end
end