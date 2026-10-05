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
local Spikes = require(script.Parent.Modules.Spikes)
local FX = require(ReplicatedStorage.FX)
local f_Un = FX:WaitForChild("YetiEffects").F_Un

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
		local clone = f_Un.Part.dash:Clone()
		Util.SetParentOverrideWithColor(clone, root, player, "YetiFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1.35)
		Util.Sound:Play("YETI_UNTSFM_F_ArcticTackle_Dash_04", root)
		local clone2 = f_Un.Part.dashloop:Clone()
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

		if player2 == game.Players.LocalPlayer then
			task.spawn(function()
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

		for _ = 1, 8 do
			emitAll(clone2)
			task.wait(0.025)
		end
	elseif stage == 2 then
		local clone = f_Un.Hands.FreezeR:Clone()
		local clone2 = f_Un.Hands.FreezeR2:Clone()
		local player2 = instance.Player
		local root = instance.Root
		local victimChar = instance.victimChar
		local userChar = instance.userChar
		local humanoid = instance.Humanoid
		local victimHumanoid = instance.VictimHumanoid
		local caughtRoot = instance.caughtRoot
		local rightHand = instance.rightHand
		Util.SetParentOverrideWithColor(clone, rightHand, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, rightHand, player, "YetiFruitVFXColor")
		clone.Trail.Attachment0 = clone
		clone.Trail.Attachment1 = clone2
		Util.Debris:AddItem(clone, 1)
		Util.Debris:AddItem(clone2, 1)
		Util.Sound:Play("YETI_UNTSFM_F_ArcticTackle_Connect_01", root)

		local function CAMERAHIT(fieldOfView)
			local clone3 = script.DOF:Clone()
			Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FarIntensity = 0,
				FocusDistance = 0,
				InFocusRadius = 0,
				NearIntensity = 0
			}):Play()
			Util.Debris:AddItem(clone3, 0.5)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.043, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = fieldOfView
				}
			):Play()
			task.wait(0.043)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FieldOfView = 70
				}
			):Play()
		end

		local fn = player2 ~= game.Players.LocalPlayer and game.Players.LocalPlayer.Character ~= victimChar and function() end or CAMERAHIT
		task.spawn(function()
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < instance.dur and userChar and victimChar and root and rightHand and caughtRoot and not caughtRoot:FindFirstChild("CompletedThrow") and not caughtRoot.Parent:FindFirstChild("AntiMover") and not (humanoid.Health <= 0) and victimHumanoid and not (victimHumanoid.Health <= 0) do
				caughtRoot.CFrame = rightHand.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(1.5707963267948966, 0, 0)
				task.wait()
			end
		end)
		task.spawn(function()
			if instance.rayData[1] then
				local v = instance.rayData[2]
				local vector2 = instance.rayData[3]
				local v2 = vector2 * 0.1
				local _ = root.Parent:FindFirstChild("RightHand").CFrame
				local clone3 = f_Un.CracksGround:Clone()
				local cframe = CFrame.new(Vector3.new(), vector2:Cross(createVector(0, 1, 0)), vector2)
				clone3.CFrame = CFrame.new(v + v2) * cframe
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 4.3)
				task.spawn(function()
					task.wait(0.317)
					local clone4 = f_Un.Hand.Push1:Clone()
					Util.SetParentOverrideWithColor(clone4, root, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					emitAll(clone4)
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
				end)
				task.spawn(function()
					task.wait(1.017)
					local clone4 = f_Un.Hand.Push2:Clone()
					Util.SetParentOverrideWithColor(clone4, root, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					emitAll(clone4)
					task.wait(0.05)
					fn(105)
					Util.CameraShaker:ShakeOnce(6, 9, 0.15, 0.7, createVector(1, 1, 1), createVector(1, 1, 1))
				end)
				task.spawn(function()
					task.wait(1.45)
					local clone4 = f_Un.Hand.swing:Clone()
					Util.SetParentOverrideWithColor(clone4, root, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					emitAll(clone4)
					task.wait(0.075)
					Util.CameraShaker:ShakeOnce(
						5,
						8,
						0.45,
						0.6,
						createVector(0.4, 0.4, 0.4),
						createVector(0.4, 0.4, 0.4)
					)
				end)
				task.wait(0.367)
				emitAll(clone3.Smash1)
				Spikes.Ring(player, 15, 1, clone3, nil, 9, 3.5, 9, 2, nil, _WorldOrigin)
				task.wait(0.7)
				emitAll(clone3.Smash2)
				Spikes.Ring(player, 15, 1, clone3, nil, 14, 7.3, 9, 2, nil, _WorldOrigin)
				task.wait(0.605)
				local folder = Instance.new("Folder")
				folder.Name = "CompletedThrow"
				Util.SetParentOverrideWithColor(folder, caughtRoot, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(folder, 0.5)
				local cframe2 = CFrame.lookAt(root.Position, instance.MousePosVal.Value)
				local part = Instance.new("Part")
				part.Size = createVector(2, 2, 1)
				part.CFrame = cframe2
				part.Transparency = 1
				part.Anchored = true
				part.CanCollide = false
				Util.SetParentOverrideWithColor(part, workspace._WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(part, 2)

				for _, attachment in pairs(f_Un.Throw:GetChildren()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					local clone4 = attachment:Clone()
					Util.SetParentOverrideWithColor(clone4, part, player, "YetiFruitVFXColor")
					emitAll(clone4)
					Util.Debris:AddItem(clone4, 2.5)
				end

				task.spawn(function()
					for _ = 1, 15 do
						local clone4 = f_Un.IceWind:Clone()
						clone4.CFrame = cframe2 * CFrame.Angles(
							math.rad(math.random(-450, 450) / 10),
							math.rad(math.random(-450, 450) / 10),
							(math.rad(math.random(-2, 2) / 10))
						)
						clone4.Position = root.position
						clone4.Anchored = false
						Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
						local v3 = math.random(2, 5) / 5
						local v4 = math.random(20, 40) / 5

						if math.random(2) == 1 then
							v4 *= -1
						end

						for _, attachment in pairs(clone4:GetDescendants()) do
							if not attachment:IsA("Attachment") then
								continue
							end

							attachment.Position = Vector3.new(0, attachment.Name == "Top" and v3 or -v3, 0)
							attachment.Position += Vector3.new(0, v4, 0)
						end

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
						bodyVelocity.Velocity = clone4.CFrame.LookVector * math.random(160, 290)
						Util.SetParentOverrideWithColor(bodyVelocity, clone4, player, "YetiFruitVFXColor")
						local v5 = math.random(12, 21) / 1.5
						clone4.RotVelocity = clone4.CFrame.LookVector * v5
						coroutine.resume(coroutine.create(function()
							task.wait(math.random(20, 60) / 100)
							clone4.Anchored = true
							Util.Debris:AddItem(clone4, 1.5)
						end))
					end
				end)
				task.wait(0.125)
				fn(105)

				if player2 == game.Players.LocalPlayer or game.Players.LocalPlayer.Character == caughtRoot.Parent then
					Util.CameraShaker:ShakeOnce(3, 5, 0.15, 1, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
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
		local clone = f_Un.Hands.FreezeR:Clone()
		local clone2 = f_Un.Hands.FreezeR2:Clone()
		Util.SetParentOverrideWithColor(clone, root.Parent.RightHand, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, root.Parent.RightHand, player, "YetiFruitVFXColor")
		clone.Trail.Attachment0 = clone
		clone.Trail.Attachment1 = clone2
		Util.Debris:AddItem(clone, 0.6)
		Util.Debris:AddItem(clone2, 0.6)
		Util.Sound:Play("YETI_UNTSFM_F_ArcticTackle_AirGrab_01_V2", root)

		local function CAMERAHIT(fieldOfView)
			local clone3 = script.DOF:Clone()
			Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FarIntensity = 0,
				FocusDistance = 0,
				InFocusRadius = 0,
				NearIntensity = 0
			}):Play()
			Util.Debris:AddItem(clone3, 0.5)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.043, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = fieldOfView
				}
			):Play()
			task.wait(0.043)
			TweenService:Create(
				workspace.Camera,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FieldOfView = 70
				}
			):Play()
		end

		local fn = player2 ~= game.Players.LocalPlayer and game.Players.LocalPlayer.Character ~= caughtRoot.Parent and function() end or CAMERAHIT
		task.spawn(function()
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < instance.dur and userChar and victimChar and root and rightHand and caughtRoot and not caughtRoot:FindFirstChild("CompletedThrow") and not caughtRoot.Parent:FindFirstChild("AntiMover") and not (humanoid.Health <= 0) and victimHumanoid and not (victimHumanoid.Health <= 0) do
				caughtRoot.CFrame = rightHand.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(1.5707963267948966, 0, 0)
				task.wait()
			end
		end)
		task.spawn(function()
			task.wait(0.317)
			local clone3 = f_Un.Hand.swing:Clone()
			Util.SetParentOverrideWithColor(clone3, root, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone3, 2)
			emitAll(clone3)
			task.spawn(function()
				local clone4 = f_Un.WindSwirlStart:Clone()
				clone4.CFrame = root.CFrame * CFrame.Angles(
					0.017575465567582896,
					1.5707963267948966,
					0.010402162341886203
				)
				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone4, 2)
				TweenService:Create(
					clone4.Mesh,
					TweenInfo.new(0.234, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Scale = createVector(6, 14, 6.5)
					}
				):Play()
				task.spawn(function()
					TweenService:Create(clone4, TweenInfo.new(0.234, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						CFrame = clone4.CFrame * CFrame.Angles(0, -5.1487212933832724, 0)
					}):Play()
					task.wait(0.1)
					TweenService:Create(
						clone4.Decal,
						TweenInfo.new(0.233, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end)
			task.wait(0.075)

			if player2 == game.Players.LocalPlayer or game.Players.LocalPlayer.Character == caughtRoot.Parent then
				Util.CameraShaker:ShakeOnce(5, 8, 0.45, 0.6, createVector(0.4, 0.4, 0.4), createVector(0.4, 0.4, 0.4))
			end
		end)
		task.wait(0.633)
		local cframe = CFrame.lookAt(root.Position, instance.MousePosVal.Value)
		local part = Instance.new("Part")
		part.Size = createVector(2, 2, 1)
		part.CFrame = cframe
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		Util.SetParentOverrideWithColor(part, workspace._WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(part, 2)

		for _, attachment in pairs(f_Un.Throw:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone3 = attachment:Clone()
			Util.SetParentOverrideWithColor(clone3, part, player, "YetiFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 2.5)
		end

		local folder = Instance.new("Folder")
		folder.Name = "CompletedThrow"
		Util.SetParentOverrideWithColor(folder, caughtRoot, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(folder, 0.5)
		task.spawn(function()
			for _ = 1, 15 do
				local clone3 = f_Un.IceWind:Clone()
				clone3.CFrame = cframe * CFrame.Angles(
					math.rad(math.random(-450, 450) / 10),
					math.rad(math.random(-450, 450) / 10),
					(math.rad(math.random(-2, 2) / 10))
				)
				clone3.Position = root.position
				clone3.Anchored = false
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				local v = math.random(2, 5) / 5
				local v2 = math.random(20, 40) / 5

				if math.random(2) == 1 then
					v2 *= -1
				end

				for _, attachment in pairs(clone3:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v or -v, 0)
					attachment.Position += Vector3.new(0, v2, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(160, 290)
				Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
				local v3 = math.random(12, 21) / 1.5
				clone3.RotVelocity = clone3.CFrame.LookVector * v3
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(20, 60) / 100)
					clone3.Anchored = true
					Util.Debris:AddItem(clone3, 1.5)
				end))
			end
		end)
		fn(105)

		if player2 == game.Players.LocalPlayer or game.Players.LocalPlayer.Character == caughtRoot.Parent then
			Util.CameraShaker:ShakeOnce(3, 5, 0.15, 1, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end
	elseif stage == 5 then
		local root = instance.Root
		local holding = instance.Holding

		if not (holding or holding.Value) then
			return
		end

		local v = Util.Sound:Play("YETI_UNTSFM_F_ArcticTackle_Hold_01_V2", root)
		local clones = {}
		local clone = f_Un.FHold:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = root
		motor6D.Part1 = clone
		Util.SetParentOverrideWithColor(motor6D, clone, player, "YetiFruitVFXColor")

		local function enableAll(folder, enabled: boolean)
			for _, effect in folder:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = enabled
				end
			end
		end

		enableAll(clone, true)
		table.insert(clones, clone)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		task.wait(0.05)
		enableAll(clone, false)

		for _, folder in pairs(clones) do
			if folder:IsDescendantOf(workspace) then
				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			local v2 = folder
			task.spawn(function()
				task.wait(1)
				v2:Destroy()
			end)
		end
	end
end