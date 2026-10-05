local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local cameraShaker = Util.CameraShaker
CustomCollisions.new("Rocks")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Creation").X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(p, child, data)
	task.spawn(function()
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local currentRock = data.CurrentRock
		local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
		local v2 = {}

		for _ = 1, amount do
			local v3 = size * math.random(25, 35) / 10
			local v4 = size * math.random(25, 45) / 10
			local v5 = size * math.random(15, 35) / 10
			local clone = currentRock:Clone()
			clone.Size = Vector3.new(v3, v4, v5) + Vector3.new(
				0,
				math.random(-v4 / 3, v4 / 3),
				math.random(-v5 / 3, v5 / 3)
			)
			clone.Parent = child
			table.insert(v2, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			v2 = nil
		end)

		local function GetXAndYPosition(p2, p3)
			return math.cos(p2) * p3, math.sin(p2) * p3
		end

		local v3 = 360 / #v2
		local total = 0

		for _, v4 in pairs(v2) do
			total += v3
			local cFrame = v * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
			v4.CFrame = cFrame

			if math.random(1, 5) < 2 then
				v4.CFrame = cFrame * CFrame.new(0, 0, v4.Size.Y / 5 * math.random(5, 15) / 5)
			end

			local ray = Ray.new(v4.Position, v4.CFrame.UpVector * -20)
			local part, position = workspace:FindPartOnRayWithIgnoreList(ray, { child })

			if part then
				v4.Position = position
				v4.CFrame *= CFrame.new(0, math.random(-v4.Size.Z, -v4.Size.Z / 2) / 7, 0)
				local cframe = CFrame.Angles(130, math.rad(math.random(-5, 5) / 3), (math.rad(math.random(-5, 5) / 3)))
				v4.CFrame *= cframe
				v4.Material = part.Material
				v4.Color = part.Color
				local tween = TweenService:Create(
					v4,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = v4.Size
					}
				)
				v4.Size = createVector(0, 0, 0)
				tween:Play()
				local v8 = v4
				task.spawn(function()
					wait(duration + math.random(10, 50) / 100)
					TweenService:Create(
						v8,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
				end)
			else
				v4:Destroy()
				v2[v4] = nil
			end
		end
	end)
end

return function(player)
	local origin = player.Origin

	if player.Stage > 0 and player.Stage ~= 8 and (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if stage == 0 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			return
		end

		child.Name = "DESTROYING"
		Util.Debris:AddItem(child, 5)
	elseif stage == 1 then
		local holding = player.Holding

		if not holding then
			return
		end

		if workspace._WorldOrigin:FindFirstChild(player.ProxyName) then
			workspace._WorldOrigin:FindFirstChild(player.ProxyName):Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		folder.Name = player.ProxyName
		folder:SetAttribute("Stage", 1)
		Util.Debris:AddItem(folder, 30)
		local root = player.Root
		local cFrame = root.CFrame * CFrame.new(15, 3, 3)
		local clone = X.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		Util.Sound:Play("CreationFruit_X_HandSpawn_01", cFrame.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		task.wait(0.05)
		local clone2 = X.Phase1.Hand:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder
		local creationHandSummon = Util.Anims:Get(clone2["barrier hand"], "CreationHandSummon")
		creationHandSummon.Priority = Enum.AnimationPriority.Action2
		creationHandSummon:Play(0)
		local clone3 = X.Phase1.PositionPart:Clone()
		clone3.Parent = clone2
		clone3.Attachment0.Parent = clone2
		clone3.AlignPosition.Enabled = true
		clone3.Position = root.Position
		clone3.AlignPosition.Position = root.CFrame * CFrame.new(15, 3, 3).Position
		clone3.AlignOrientation.CFrame = root.CFrame
		clone2.Anchored = false
		local _ = tick() + 0.25
		local creationHandIdle = Util.Anims:Get(clone2["barrier hand"], "CreationHandIdle")
		creationHandIdle.Priority = Enum.AnimationPriority.Action
		creationHandIdle:Play()
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(math.random(400, 600), math.random(400, 600), math.random(400, 600))
		highlight.OutlineColor = Color3.fromRGB(
			math.random(400, 600) * 0.75,
			math.random(400, 600) * 0.75,
			math.random(400, 600) * 0.75
		)
		highlight.Parent = clone2["barrier hand"]
		highlight.Adornee = clone2["barrier hand"]
		local tween = TweenService:Create(
			highlight,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				OutlineTransparency = 1,
				FillTransparency = 1
			}
		)
		tween.Completed:Connect(function()
			highlight:Destroy()
		end)
		tween:Play()
		local clone4 = X.Phase1.HoldAura:Clone()
		clone4.CFrame = root.Parent.RightLowerArm.CFrame
		clone4.Parent = folder
		clone4.Weld.Part1 = root.Parent.RightLowerArm
		clone4.Anchored = false
		clone4.Massless = true
		local v2 = Util.Sound:Play("CreationFruit_X_Player_Hand_Sparkle_01", clone4)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			emitter.Enabled = true
		end

		while holding and holding.Value and folder:GetAttribute("Stage") == 1 do
			clone3.Position = root.Position
			clone3.AlignPosition.Position = root.CFrame * CFrame.new(15, 3, 3).Position
			clone3.AlignOrientation.CFrame = root.CFrame
			task.wait()
		end

		if creationHandIdle then
			creationHandIdle:Stop()
		end

		repeat
			task.wait(0.05)
		until folder.Name ~= player.ProxyName

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 2nd stage release.")
			return
		end

		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing!")
			return
		end

		local positionPart = hand.PositionPart

		if child:GetAttribute("Stage") == 1 then
			child:SetAttribute("Stage", 2)
			Util.Debris:AddItem(child, 8)
			positionPart.AlignPosition.Enabled = false
			positionPart.CFrame = player.StartCFrame
			hand.Anchored = true
			player.Character:SetAttribute("HandStatus", "CreationR15Slap")
			local creationHandSlap = Util.Anims:Get(hand["barrier hand"], "CreationHandSlap")
			creationHandSlap.Priority = Enum.AnimationPriority.Action3
			creationHandSlap:Play()
			creationHandSlap:AdjustSpeed(1.3)
			Util.Sound:Play("CreationFruit_X_HandSwipe_01", player.Character.HumanoidRootPart.Position)
			TweenService:Create(hand, TweenInfo.new(0.07692307692307693), {
				CFrame = player.StartCFrame * CFrame.new(25, 3, 3)
			}):Play()
			task.wait(0.3846153846153846)
			hand.Anchored = false
			local swipeSpeed = player.SwipeSpeed
			local clone = X.Phase2.HandSwipe:Clone()
			clone.CFrame = hand.CFrame
			clone.Parent = child
			clone.Anchored = false
			clone.Weld.Part1 = hand
			local effectsByEffect = {}

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = true
					effectsByEffect[effect] = effect
				elseif effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			task.spawn(function()
				local lastTime = tick()

				while true do
					for _, v in pairs(effectsByEffect) do
						v:Emit(1)
					end

					task.wait(0.05)
					local v = tick() - lastTime

					if not (swipeSpeed - 0.05 <= v) then
						continue
					end

					clone.Weld.Enabled = false
					clone.Anchored = true

					for _, v2 in pairs(effectsByEffect) do
						v2.Enabled = false
					end

					break
				end
			end)
			local motor6D = positionPart.Motor6D
			motor6D.C1 = positionPart.CFrame:ToObjectSpace(hand.CFrame)
			motor6D.Part0 = hand
			motor6D.Part1 = positionPart
			motor6D.Enabled = true
			TweenService:Create(
				positionPart,
				TweenInfo.new(swipeSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = positionPart.CFrame * CFrame.new(-20, -3, 10) * CFrame.Angles(
						0.3490658503988659,
						3.12413936106985,
						0
					)
				}
			):Play()
			local v = {}

			for _ = 1, 5 do
				local clone2 = X.Phase2.SpinTrail:Clone()
				clone2.CFrame = hand.CFrame
				clone2.Parent = child
				clone2.Anchored = false
				clone2.Weld.Part1 = hand

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				clone2.SpinTrail2.WeldConstraint.Enabled = false
				clone2.SpinTrail2.CFrame = clone2.CFrame * CFrame.new(
					math.random(-10, 10) / 2,
					math.random(-10, 10) / 2,
					math.random(-10, 10) / 15
				)
				clone2.SpinTrail2.WeldConstraint.Enabled = true
				clone2.Weld.C0 = clone2.Weld.C0
				local v2 = math.random(1, 3)

				if v2 == 1 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(74, 248, 100), Color3.fromRGB(255, 196, 93))
				elseif v2 == 2 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(94, 68, 221), Color3.fromRGB(89, 169, 255))
				elseif v2 == 3 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(193, 63, 182), Color3.fromRGB(158, 255, 105))
				end

				local v3 = math.random(7, 15) / 1.5
				clone2.SpinTrail2.Attach0.Position = Vector3.new(v3, 0, 0)
				clone2.SpinTrail2.Attach1.Position = Vector3.new(-v3, 0, 0)
				clone2.Trail.Lifetime = math.random(15, 25) / 100
				v[clone2] = math.random(14, 17)
			end

			task.wait(swipeSpeed)

			for k, _ in pairs(v) do
				k.Weld.Enabled = false
				k.Anchored = true
				k.Trail.Enabled = false
			end

			task.wait(0.15384615384615385)
		end
	elseif stage == 3 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		child:SetAttribute("Stage", 3)
		local _ = hand.PositionPart
		local direction = player.Direction
		local _ = player.Root
		local _ = player.VictimChar
		local _ = player.Character
		local _ = player.Humanoid
		local _ = player.VictimHumanoid
		local distance = player.Distance
		local timeUntilEndPoint = player.TimeUntilEndPoint
		hand.CFrame = direction
		player.Character:SetAttribute("HandStatus", "CreationR15LaunchLoop")
		local creationHandLaunchLoop = Util.Anims:Get(hand["barrier hand"], "CreationHandLaunchLoop")
		creationHandLaunchLoop.Looped = true
		creationHandLaunchLoop:Play()
		TweenService:Create(hand, TweenInfo.new(timeUntilEndPoint), {
			CFrame = direction * CFrame.new(0, 0, -distance)
		}):Play()
		Util.Sound:Play("CreationFruit_X_HandSwipe_Launch", hand.Position)
		local clone = X.Phase2.HandSwipe:Clone()
		clone.CFrame = hand.CFrame
		clone.Parent = child
		clone.Anchored = false
		clone.Weld.Part1 = hand
		clone.Weld.C0 = CFrame.new(0, -5, 0)
		local effectsByEffect = {}

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				effectsByEffect[effect] = effect
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(timeUntilEndPoint)

			if creationHandLaunchLoop then
				creationHandLaunchLoop:Stop()
			end
		end)
		task.spawn(function()
			local lastTime = tick()

			while true do
				for _, v in pairs(effectsByEffect) do
					v:Emit(1)
				end

				task.wait(0.05)
				local v = tick() - lastTime

				if not (timeUntilEndPoint / 1.35 <= v) then
					continue
				end

				clone.Weld.Enabled = false
				clone.Anchored = true

				for _, v2 in pairs(effectsByEffect) do
					v2.Enabled = false
				end

				break
			end
		end)
		task.wait(timeUntilEndPoint / 1.25)

		if not player.VictimRoot then
			hand.Anchored = true
			hand.CFrame = direction * CFrame.new(0, 0, -distance)
			task.wait(0.025)
			local clone2 = X.Phase3.EndImpact:Clone()
			clone2.CFrame = hand.CFrame * CFrame.new(0, 6, 0)
			clone2.Parent = child

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				task.spawn(function()
					if v:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v:GetAttribute("EmitDelay"))
					end

					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			hand:Destroy()
		end
	elseif stage == 4 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		local positionPart = hand.PositionPart
		local grabProxy = player.GrabProxy

		if not grabProxy then
			return
		end

		child:SetAttribute("Stage", 4)
		local root = player.Root
		local victimChar = player.VictimChar
		local character = player.Character
		local humanoid = player.Humanoid
		local victimHumanoid = player.VictimHumanoid
		local _ = player.Holding
		local victimRoot = player.VictimRoot
		local barrierhand = hand:FindFirstChild("barrier hand")

		if not barrierhand then
			return
		end

		Util.Sound:Play("CreationFruit_X_HandSwipe_Grab_NPC_03", victimRoot.Position)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < player.MaxHoldTime and character and victimChar and root and player.VictimRoot and grabProxy:IsDescendantOf(workspace) and not grabProxy:GetAttribute("Release") and not (humanoid.Health <= 0) and victimHumanoid and not (victimHumanoid.Health <= 0) do
				victimRoot.Parent:PivotTo(barrierhand.PrimaryPart.CFrame * CFrame.new(0, 14, 0))
				local RunService = game:GetService("RunService")
				RunService.PostSimulation:Wait()
			end
		end)
		positionPart.AlignOrientation.Enabled = false
		positionPart.AlignPosition.Enabled = false
		hand.Anchored = true
		player.Character:SetAttribute("HandStatus", "CreationR15GrabbedLoop")
		local creationHandGrabbedLoop = Util.Anims:Get(hand["barrier hand"], "CreationHandGrabbedLoop")
		creationHandGrabbedLoop:Play()
		local spring = Util.Spring.new(1, 3, hand.Position)
		local v = Util.Sound:Play("CreationFruit_X_HandHoldingTarget_Flying_01", hand)
		local lastTime = nil

		while true do
			local v2 = task.wait()

			if not grabProxy:IsDescendantOf(workspace) then
				break
			end

			if grabProxy:GetAttribute("Release") then
				if lastTime then
					if tick() - lastTime > 1 then
						break
					end
				else
					lastTime = tick()
				end
			end

			if not player.ProxyVal then
				break
			end

			spring:SetGoal(player.ProxyVal.Value.Position)
			spring:Update(v2)
			hand.CFrame = CFrame.new(spring:GetPosition()) * hand.CFrame:Lerp(player.ProxyVal.Value, v2 * 10).Rotation
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		if creationHandGrabbedLoop then
			creationHandGrabbedLoop:Stop()
		end
	elseif stage == 5 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		Util.Debris:AddItem(child, 5)
		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		hand.Anchored = true
		hand.CFrame = player.GrabProxy:GetAttribute("Release")
		player.Character:SetAttribute("HandStatus", "CreationR15Slam")
		local creationHandSlam = Util.Anims:Get(hand["barrier hand"], "CreationHandSlam")
		creationHandSlam.Priority = Enum.AnimationPriority.Action4
		creationHandSlam:Play()
		creationHandSlam:AdjustSpeed(1.5)
		local v = {
			Position = player.Origin,
			Instance = player.Ground,
			Normal = player.GroundNor
		}
		local cFrame = AlignCFrame(CFrame.new(v.Position), v.Normal) + v.Normal * 0.01
		local clone = X.Phase3.HitImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = child
		Util.Sound:Play("CreationFruit_X_Ground_Smash_07", cFrame.Position)
		task.delay(0.1, function()
			if (currentCamera.CFrame.p - clone.Position).Magnitude <= 90 then
				cameraShaker:ShakeOnce(8, 4, 0.1, 0.5)
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Lines") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount") / 2)
				end)
			end
		end)
		task.wait(0.41133333333333333)

		if (currentCamera.CFrame.p - clone.Position).Magnitude <= 110 then
			cameraShaker:ShakeOnce(12, 16, 0.1, 1.25)

			if (currentCamera.CFrame.p - clone.Position).Magnitude <= 90 then
				local Effect = require(game.ReplicatedStorage.Effect)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Color3.fromRGB(113, 44, 162),
					Brightness = 1,
					Contrast = 1,
					Saturation = -1,
					FadeIn = 0,
					FadeOut = 0.3,
					Lifetime = 0
				})
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount") / 2)
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = X.Phase1.HitImpact:Clone()
		clone2.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Parent = child

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		RockCrater(v, child, {
			Radius = 25,
			Size = 2.25,
			Duration = 1.25,
			Amount = 15,
			CurrentRock = X.Phase3.CraterRock
		}) -- equivalent call inferred; original call site unknown
		task.wait(0.5)
		local clone3 = X.Phase3.EndImpact:Clone()
		clone3.CFrame = hand.CFrame
		clone3.Parent = child

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		hand:Destroy()
	elseif stage == 6 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		Util.Debris:AddItem(child, 10)
		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		local grabProxy = player.GrabProxy
		local _ = player.VictimRoot
		local release = grabProxy:GetAttribute("Release")
		hand.CFrame = release
		Util.Sound:Play("CreationFruit_X_Hand_Punch_05", release.Position)
		player.Character:SetAttribute("HandStatus", "CreationR15Punch")
		local creationHandPunch = Util.Anims:Get(hand["barrier hand"], "CreationHandPunch")
		creationHandPunch.Priority = Enum.AnimationPriority.Action4
		creationHandPunch:Play()
		creationHandPunch:AdjustSpeed(1.5)
		task.wait(0.39999999999999997)
		local clone = X.Phase1.HitImpact:Clone()
		clone.CFrame = release * CFrame.new(0, 3, -15) * CFrame.Angles(0, 3.141592653589793, 0)
		clone.Parent = child

		if (currentCamera.CFrame.p - clone.Position).Magnitude <= 110 then
			cameraShaker:ShakeOnce(12, 16, 0.1, 1.2)

			if (currentCamera.CFrame.p - clone.Position).Magnitude <= 90 then
				local Effect = require(game.ReplicatedStorage.Effect)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Color3.fromRGB(113, 44, 162),
					Brightness = 1,
					Contrast = 1,
					Saturation = -1,
					FadeIn = 0,
					FadeOut = 0.3,
					Lifetime = 0
				})
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = X.Phase3.ThrowImpact:Clone()
		clone2.CFrame = release * CFrame.new(0, 3, -15)
		clone2.Parent = child

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		task.wait(0.5)
		local clone3 = X.Phase3.EndImpact:Clone()
		clone3.CFrame = release * CFrame.new(0, 3, -15)
		clone3.Parent = child

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		hand:Destroy()
	elseif stage == 7 then
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 5)
		local v = {
			Color3.fromRGB(255, 58, 127),
			Color3.fromRGB(87, 255, 185),
			Color3.fromRGB(84, 69, 255),
			Color3.fromRGB(142, 49, 255),
			Color3.fromRGB(85, 167, 255)
		}
		local v2 = player.HitCFrame * CFrame.Angles(0, 3.141592653589793, 0)
		local clone = X.Phase3.ObjectHitImpact:Clone()
		clone.CFrame = v2 * CFrame.new(0, 0, 1.5)
		clone.Parent = folder
		local parent = player.Root.Parent
		local Players = game:GetService("Players")

		if parent == Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Color3.fromRGB(113, 44, 162),
				Brightness = 1,
				Contrast = 1,
				Saturation = -1,
				FadeIn = 0,
				FadeOut = 0.3,
				Lifetime = 0
			})
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
			local v3 = v[math.random(1, #v)]
			emitter.Color = ColorSequence.new(v3, v3)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	elseif stage == 8 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		Util.Debris:AddItem(child, 10)
		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		task.wait(player.SwipeSpeed)
		local clone = X.Phase3.EndImpact:Clone()
		clone.CFrame = hand.CFrame
		clone.Parent = child

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		hand:Destroy()
	elseif stage == 9 then
		local child = workspace._WorldOrigin:FindFirstChild(player.ProxyName)

		if not child then
			warn("CREATION X: Hand was destroyed prior to 3rd stage release.")
			return
		end

		Util.Debris:AddItem(child, 10)
		local hand = child:WaitForChild("Hand", 0.1)

		if not hand then
			warn("CREATION X: Hand part is missing in:" .. player.ProxyName)
			return
		end

		local barrierhand = hand:FindFirstChild("barrier hand")

		if not barrierhand then
			return
		end

		local lastTime = tick()

		while tick() - lastTime < player.SwipeSpeed and player.VictimRoot do
			player.VictimRoot.CFrame = CFrame.new(barrierhand.RootPart.Bone["Bone.001"]["Bone.015"].WorldPosition) * barrierhand.PrimaryPart.CFrame.Rotation
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end
	end
end