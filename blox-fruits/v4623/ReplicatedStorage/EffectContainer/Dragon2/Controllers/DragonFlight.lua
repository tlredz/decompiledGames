local createVector = vector.create
local v = nil
xpcall(function()
	local Anims = require(game.ServerStorage.Game.ReplicatedStorage.Util.Anims)
	v = Anims
end, function()
	local Anims = require(game.ReplicatedStorage:WaitForChild("Util").Anims)
	v = Anims
end)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage:WaitForChild("FX"))
local dragonFlight = nil

local function getFlightFx()
	if not dragonFlight then
		dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
	end

	return dragonFlight
end

local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p, unit2, v2, unit3)
end

local function LandImpactRocks(_WorldOrigin, _, p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function RockCrater(p2, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local cframe = AlignCFrame(CFrame.new(p2.Position), p2.Normal) + p2.Normal * 0.05
			local v2 = {}

			for _ = 1, amount do
				local v3 = size * math.random(15, 20) / 10
				local v4 = size * math.random(10, 20) / 10
				local v5 = size * math.random(10, 30) / 10
				local clone = rockType:Clone()
				clone.Size = Vector3.new(v3, v4, v5) + Vector3.new(
					0,
					math.random(-v4 / 3, v4 / 3),
					math.random(-v5 / 3, v5 / 3)
				)
				clone.Parent = parent
				table.insert(v2, clone)
			end

			task.spawn(function()
				task.wait(duration * 2)

				for _, v3 in pairs(v2) do
					v3:Destroy()
				end

				v2 = {}
			end)

			local function GetXAndYPosition(p3, p4)
				return math.cos(p3) * p4, math.sin(p3) * p4
			end

			for k, v3 in pairs(v2) do
				local v4 = k * (6.283185307179586 / #v2)
				local v5 = math.cos(v4) * radius
				local v6 = math.sin(v4) * radius
				local _ = cframe:ToObjectSpace(v3.CFrame).Y
				local position = (cframe * CFrame.new(v5, 0, v6)).Position
				v3.CFrame = CFrame.new(position + createVector(0, 0.1, 0), cframe.Position)

				if math.random(1, 5) < 2 then
					v3.CFrame = CFrame.new(v3.Position, cframe.Position) * CFrame.new(
						0,
						0,
						v3.Size.Z * math.random(5, 15) / 10
					)
				end

				local ray = Ray.new(v3.Position + createVector(0, 1, 0), createVector(-0, -20, -0))
				local part, v8 = workspace:FindPartOnRayWithIgnoreList(ray, { parent })

				if part then
					v3.Position = v8 + Vector3.new(0, -v3.Size.Y * math.random(5, 6) / 10, 0)
					v3.CFrame = CFrame.new(
						v3.Position,
						cframe.Position + Vector3.new(0, math.random(-55, -45) + v3.Size.Y / 2, 0)
					) * CFrame.Angles(0, 0, (math.rad((math.random(-5, 5)))))
					v3.Material = part.Material
					v3.Color = part.Color
				else
					v3:Destroy()
					v2[v3] = nil
				end

				TweenService:Create(
					v3,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
					{
						Position = v3.Position + Vector3.new(0, v3.Size.Y * math.random(3, 5) / 10, 0)
					}
				):Play()
				local v9 = v3
				local v10 = v3
				task.spawn(function()
					wait(duration + math.random(10, 50) / 100)
					local tween = TweenService:Create(
						v9,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v9.Position + Vector3.new(
								math.random(-1, 1),
								-v9.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v9:Destroy()
					v2[v9] = nil
				end)
			end
		end)
	end

	local function GroundFlyRocks(data, parent, data2, fn)
		local cframe = CFrame.new(data.Position)
		local material = data.Material
		local color = data.Instance.Color
		local rockType = data2.RockType
		local rockAmount = data2.RockAmount
		local rockSize = data2.RockSize
		local positionOffset = data2.PositionOffset
		local rockRotationAmount = data2.RockRotationAmount
		local rockRotationSpeed = data2.RockRotationSpeed
		local rockRotationPower = data2.RockRotationPower
		local duration = data2.Duration

		for _ = 1, rockAmount do
			task.spawn(function()
				task.wait(math.random(0, 5) / 100)
				local clone = rockType:Clone()
				clone.Position = cframe.Position + Vector3.new(
					math.random(-positionOffset, positionOffset),
					math.random(1, positionOffset / 10),
					math.random(-positionOffset, positionOffset)
				)
				clone.Size = Vector3.new(
					math.random(rockSize / 2, rockSize),
					math.random(rockSize / 2, rockSize),
					math.random(rockSize / 2, rockSize)
				)
				clone.Material = material
				clone.Color = color
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				task.spawn(function()
					task.wait(duration + math.random(10, 50) / 100)
					TweenService:Create(
						clone,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
				end)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Parent = clone
				fn(bodyVelocity, clone)
				clone.Attachment0.Orientation = createVector(0, 0, 0)
				local v2 = math.random(-rockRotationPower, rockRotationPower)
				local v3 = math.random(-rockRotationPower, rockRotationPower)
				local v4 = math.random(-rockRotationPower, rockRotationPower)
				local v5 = v2 / rockRotationAmount
				local v6 = v3 / rockRotationAmount
				local v7 = v4 / rockRotationAmount
				task.spawn(function()
					for _ = 1, rockRotationAmount do
						if clone:FindFirstChild("Attachment0") == nil then
							return
						end

						v2 = math.clamp(v2 - v5, 0, rockRotationPower * 1.5)
						v3 = math.clamp(v3 - v6, 0, rockRotationPower * 1.5)
						v4 = math.clamp(v4 - v7, 0, rockRotationPower * 1.5)
						local tween = TweenService:Create(
							clone.Attachment0,
							TweenInfo.new(rockRotationSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone.Attachment0.CFrame * CFrame.Angles(
									math.rad(v2),
									math.rad(v3),
									(math.rad(v4))
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						tween:Destroy()
					end

					clone.AlignOrientation:Destroy()
				end)
			end)
		end
	end

	if not dragonFlight then
		dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
	end

	local v2 = {
		Radius = 100,
		Size = 14,
		Duration = 3.5,
		Amount = 13,
		RockType = dragonFlight.Assets.CraterRock
	}

	if not dragonFlight then
		dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
	end

	local v3 = {
		RockAmount = 13,
		RockSize = 10.5,
		PositionOffset = 125,
		RockRotationAmount = 7,
		RockRotationSpeed = 0.15,
		RockRotationPower = 100,
		Duration = 1.15,
		RockType = dragonFlight.Assets.FlyRock
	}
	RockCrater(p, _WorldOrigin, v2) -- equivalent call inferred; original call site unknown
	GroundFlyRocks(p, _WorldOrigin, v3, function(instance, p2)
		instance.MaxForce = createVector(70000000, 70000000, 70000000)
		instance.P = 15000
		local v4 = math.random(70, 150)
		instance.Velocity = CFrame.new(
			p2.Position,
			p2.Position + Vector3.new(math.random(-25, 25) * 3, 250, math.random(-25, 25) * 3)
		).LookVector * v4
		task.delay(0.1, function()
			task.wait(math.random(0, 10) / 100)
			instance:Destroy()
			task.wait(0.35)
			p2.CanCollide = true
		end)
	end)
end

local FlightTransitionWind2 = require(script.FlightTransitionWind2)

if isServer then
	script.Remote.OnServerEvent:Connect(function(player, flying)
		if not player.Character then
			return
		end

		local westernDragonRig = player.Character:FindFirstChild("WesternDragonRig")

		if not (westernDragonRig and typeof(flying) == "boolean") then
			return
		end

		westernDragonRig:SetAttribute("Flying", flying)
	end)
	return {}
end

local _ = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService2 = game:GetService("RunService")
local DragonFlight = {}
local v2 = {}
game:GetService("ContentProvider")
local v3 = {
	Default = {
		Walk = "WesternDragon_Walk",
		Jump = "WesternDragon_Jump",
		Fall = "WesternDragon_Fall",
		Idle = "WesternDragon_Idle"
	},
	Flying = {
		Idle = "WesternDragon_Fly_Idle",
		Tail = "WesternDragon_Fly_Tail",
		FlyUp = "WesternDragon_Fly_JumpBoost_NOSOUND",
		Flap = "WesternDragon_Fly_Flap",
		Dive = "WesternDragon_Fly_Dive",
		Glide = "WesternDragon_Fly_Glide",
		Boost = "WesternDragon_Fly_Boost",
		Stop = "WesternDragon_Fly_Stop",
		Right = "WesternDragon_Fly_Right2",
		Left = "WesternDragon_Fly_Left2",
		Land = "WesternDragon_Fly_Land",
		Wind1 = "WesternDragon_Fly_Wind12"
	}
}
task.spawn(function()
	for _, v4 in pairs(v3.Default) do
		Util.Anims:Preload(v4)
	end

	for _, v4 in pairs(v3.Flying) do
		Util.Anims:Preload(v4)
	end
end)

local function SetupRig(instance, instance2)
	local v4 = instance == game.Players.LocalPlayer.Character
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)
	local maid = v2[playerFromCharacter][2]
	maid:DoCleaning()
	maid:GiveTask(instance2.AncestryChanged:Connect(function(_, parent)
		if not parent then
			maid:DoCleaning()
		end
	end))
	local v5, v6

	if v4 then
		v5 = v:Build(instance2:WaitForChild("Rig"))
		task.wait(0.1)
		v6 = {
			Default = {
				Walk = v5:GetAwaited("WesternDragon_Walk"),
				Jump = v5:GetAwaited("WesternDragon_Jump"),
				Fall = v5:GetAwaited("WesternDragon_Fall"),
				Idle = v5:GetAwaited("WesternDragon_Idle")
			},
			Flying = {
				Idle = v5:GetAwaited("WesternDragon_Fly_Idle"),
				Tail = v5:GetAwaited("WesternDragon_Fly_Tail2"),
				FlyUp = v5:GetAwaited("WesternDragon_Fly_JumpBoost"),
				Flap = v5:GetAwaited("WesternDragon_Fly_Flap"),
				Dive = v5:GetAwaited("WesternDragon_Fly_Dive"),
				Glide = v5:GetAwaited("WesternDragon_Fly_Glide"),
				Boost = v5:GetAwaited("WesternDragon_Fly_Boost"),
				Stop = v5:GetAwaited("WesternDragon_Fly_Stop"),
				Right = v5:GetAwaited("WesternDragon_Fly_Right2"),
				Left = v5:GetAwaited("WesternDragon_Fly_Left2"),
				Land = v5:GetAwaited("WesternDragon_Fly_Land"),
				Wind1 = v5:GetAwaited("WesternDragon_Fly_Wind12")
			}
		}
		maid:GiveTask(v6.Default.Walk:GetMarkerReachedSignal("Footstep"):Connect(function()
			Util.Sound:Play("BF_WD_Western_Walking_Steps_0" .. tostring(math.random(1, 4)), instance.PrimaryPart)
		end))
		maid:GiveTask(v6.Default.Walk:GetMarkerReachedSignal("Clawstep"):Connect(function()
			Util.Sound:Play("BF_WD_Western_Walking_Steps_0" .. tostring(math.random(5, 8)), instance.PrimaryPart)
		end))
		local busy = instance:WaitForChild("Busy")
		local stun = instance:WaitForChild("Stun")
		maid:GiveTask(v6.Flying.Idle:GetMarkerReachedSignal("Wingflap"):Connect(function()
			if not busy.Value and stun.Value <= 0 or instance:GetAttribute("CastingFlamethrower") then
				Util.Sound:Play(
					"BF_Dragon_WingFlaps_HeavyLarge_02_V2",
					instance.PrimaryPart,
					nil,
					math.random(12, 14) / 10
				)
			end
		end))
		maid:GiveTask(v6.Flying.Flap:GetMarkerReachedSignal("Wingflap"):Connect(function()
			if not busy.Value and stun.Value <= 0 or instance:GetAttribute("CastingFlamethrower") then
				Util.Sound:Play("BF_Dragon_WingFlaps_HeavyLarge_02_V2", instance.PrimaryPart)
			end
		end))
		maid:GiveTask(v6.Flying.Boost:GetMarkerReachedSignal("Wingflap"):Connect(function()
			if not busy.Value and stun.Value <= 0 or instance:GetAttribute("CastingFlamethrower") then
				Util.Sound:Play("BF_Dragon_WingFlaps_HeavyLarge_02_V2", instance.PrimaryPart)
			end
		end))

		for k, v7 in pairs(v6.Flying) do
			v7.Priority = Enum.AnimationPriority.Action

			if k:match("Wind") then
				v7.Priority = Enum.AnimationPriority.Action3
			end
		end
	else
		v6 = nil
		v5 = nil
	end

	local bodyMover = Util.BodyMover.new(instance, {
		BypassAntiMover = true
	})
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local busy = instance:WaitForChild("Busy")
	local stun = instance:WaitForChild("Stun")

	if v4 then
		maid:GiveTask(function()
			humanoid.AutoRotate = true
		end)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local flight = {
		Velocity = 0,
		VelocityLocked = false,
		Enabled = false,
		Landing = false,
		BodyGyro = false,
		BodyVelocity = false,
		GlidedFor = 0,
		LastBoost = 0
	}

	local function CheckForGround(p, value)
		local v8 = p or createVector(0, 0, 0)
		local v9 = math.min(100, humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight) + (math.clamp(
			flight.Velocity / 5,
			0,
			30
		) + 10 + (value or 0))
		local raycastResult = workspace:Raycast(humanoidRootPart.Position + v8, Vector3.new(0, -v9, 0), raycastParams)
		local raycastResult2 = workspace:Raycast(
			humanoidRootPart.Position + v8,
			Vector3.new(0, -(v9 + 30), 0),
			raycastParams
		)
		return
			raycastResult ~= nil,
			raycastResult,
			raycastResult and v9 - math.abs(raycastResult.Position.Y - humanoidRootPart.Position.Y),
			raycastResult2 ~= nil and raycastResult2.Instance.Name ~= "WaterBase-Plane"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function IsBusy(p)
		if p then
			return busy.Value
		end

		return busy.Value or stun.Value > 0
	end

	local function StateChanged(_, p)
		if not v4 then
			return
		end

		if p == Enum.HumanoidStateType.PlatformStanding then
			v6.Default.Idle:Stop()
			v6.Default.Walk:Stop()
			v6.Default.Fall:Stop()
			v6.Default.Jump:Stop()
		else
			if not v6.Default.Idle.IsPlaying then
				v6.Default.Idle:Play()
			end

			if p == Enum.HumanoidStateType.Jumping then
				v6.Default.Walk:Stop()
				v6.Default.Fall:Stop()
				v6.Default.Jump:Play()
			elseif p == Enum.HumanoidStateType.Freefall then
				v6.Default.Walk:Stop()

				if not CheckForGround() then
					v6.Default.Fall:Play()
				end
			elseif p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.Running then
				v6.Default.Fall:Stop()
				v6.Default.Jump:Stop()
			end
		end
	end

	maid:GiveTask(humanoid.StateChanged:Connect(StateChanged))
	local clone = nil
	local emittersByEmitter = {}
	local currentCamera = workspace.CurrentCamera
	local clone2

	if v4 then
		if not dragonFlight then
			dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
		end

		clone2 = dragonFlight.Assets.Phase1.CameraFocus:Clone()
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, playerFromCharacter, "DragonFruitVFXColor")
		maid:GiveTask(clone2)
		DragonFlight.Flight = flight
	else
		clone2 = nil
	end

	local v8 = false
	local renderSteppedConnection = nil
	local clone3 = nil
	local clone4 = nil
	local v9 = false
	local v10 = false
	local emittersByEmitter2 = {}
	local emitters = {}
	local emittersByEmitter3 = {}
	local v11 = nil
	local v12 = false

	if not dragonFlight then
		dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
	end

	local clone5 = dragonFlight.Extra.GroundBurn:Clone()
	Util.SetParentOverrideWithColor(clone5, instance2, playerFromCharacter, "DragonFruitVFXColor", true)
	Util.SyncColorsOnChange(clone5, playerFromCharacter, "DragonFruitVFXColor")
	local v13 = Util.Sound:Play("BF_Western_Transformed_Idle_01_V2", clone5)
	local particle_1 = clone5.GroundBurn2.Particle_1
	local rate = particle_1.Rate
	local particle_2 = clone5.GroundBurn2.Particle_2
	local rate2 = particle_2.Rate
	local emittersByEmitter4 = {}
	local v14 = false

	for _, emitter in pairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter4[emitter] = emitter
		emitter.Enabled = false
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.IgnoreWater = false
	raycastParams2.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

	local function EnableFlight()
		local WAIT_INTERVAL = 0.5

		if flight.Enabled or flight.Landing then
			return
		end

		flight.Enabled = true

		if v4 then
			_G.DragonHack1 = true
			script.Remote:FireServer(true)

			for _, v15 in pairs(v6.Default) do
				v15:Stop()
			end

			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
			humanoid.Jump = false
			humanoid.PlatformStand = true
			humanoid.AutoRotate = false

			if not flight.BodyGyro then
				flight.BodyGyro = bodyMover:Create("BodyGyro", {
					P = 25000,
					D = 1500,
					Priority = 9,
					MaxTorque = createVector(10000000, 10000000, 10000000),
					CFrame = humanoidRootPart.CFrame
				})
			end

			if not flight.BodyVelocity then
				flight.BodyVelocity = bodyMover:Create("BodyVelocity", {
					P = 150000,
					MaxForce = createVector(1000000000, 1000000000, 1000000000),
					Velocity = createVector(0, 0, 0),
					Priority = 9
				})
			end

			v6.Flying.Wind1:Play(0.1, 0.7, 2)
		end

		if not dragonFlight then
			dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
		end

		clone3 = dragonFlight.Assets.Phase1.GroundRocks:Clone()
		clone3.Parent = workspace.Terrain

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emittersByEmitter2[emitter] = emitter
			emitter:SetAttribute("PrimeRate", emitter.Rate)
		end

		if v14 == true then
			v14 = false
			TweenService:Create(v13, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()

			for _, v15 in pairs(emittersByEmitter4) do
				v15.Enabled = false
			end
		end

		if not dragonFlight then
			dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
		end

		clone4 = dragonFlight.Assets.Effect:Clone()
		clone4:ScaleTo(12.5)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			table.insert(emitters, emitter)
		end

		if not dragonFlight then
			dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
		end

		clone = dragonFlight.Assets.Phase1.Flight:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Anchored = false
		clone.Weld.Part0 = humanoidRootPart

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emittersByEmitter3[emitter] = emitter

			if emitter:IsDescendantOf(clone.WindAuraModel.WindAura.FallAura) then
				emittersByEmitter[emitter] = emitter
			end

			emitter.Enabled = false
		end

		if v4 then
			local westernDragonFlyJumpBoost = v5:Get("WesternDragon_Fly_JumpBoost")

			if westernDragonFlyJumpBoost and westernDragonFlyJumpBoost.IsPlaying then
				local timeOfKeyframe = westernDragonFlyJumpBoost:GetTimeOfKeyframe("Takeoff")

				if timeOfKeyframe and westernDragonFlyJumpBoost.TimePosition < timeOfKeyframe then
					westernDragonFlyJumpBoost:GetMarkerReachedSignal("Takeoffed"):Wait()
				else
					task.wait(WAIT_INTERVAL)
				end
			else
				task.wait(WAIT_INTERVAL)
			end
		else
			task.wait(WAIT_INTERVAL)
		end

		if not (busy.Value or stun.Value > 0) then
			local _, v15 = CheckForGround(-humanoidRootPart.CFrame.LookVector * 100 / 3)

			if v15 then
				if not dragonFlight then
					dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
				end

				local clone6 = dragonFlight.Assets.Phase1.StartImpact:Clone()
				clone6.CFrame = CFrame.lookAt(
					v15.Position + createVector(0, 1, 0) * (clone6.Size.Y / 2 + 0.2),
					v15.Normal
				)
				Util.SetParentOverrideWithColor(
					clone6,
					workspace._WorldOrigin,
					playerFromCharacter,
					"DragonFruitVFXColor"
				)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v16 = emitter
					task.spawn(function()
						if v16:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v16:GetAttribute("EmitDelay"))
						end

						v16:Emit(v16:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
				task.spawn(function()
					task.wait(1)
					clone6:Destroy()
				end)
			end

			task.spawn(function()
				if not dragonFlight then
					dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
				end

				local clone6 = dragonFlight.Assets.Phase1.RiseAura:Clone()
				clone6.CFrame = humanoidRootPart.CFrame
				Util.SetParentOverrideWithColor(
					clone6,
					workspace._WorldOrigin,
					playerFromCharacter,
					"DragonFruitVFXColor"
				)
				clone6.Anchored = false
				clone6.Weld.Part1 = humanoidRootPart
				clone6.Weld.C1 = CFrame.new(0, 85, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
				Util.Sound:Play("BF_WD_Western_Takeoff_01", humanoidRootPart)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					emitter:Emit(3)
				end

				task.wait(0.3)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(1)
				clone6:Destroy()
			end)
		end
	end

	local function DisableFlight()
		if not flight.Enabled or flight.Landing or flight.VelocityLocked and v4 then
			return
		end

		if v11 then
			Util.Sound:FadeOut(v11, 0.3)
		end

		flight.Landing = true
		flight.Enabled = false
		local busy2 = IsBusy(true) -- equivalent call inferred; original call site unknown

		if v4 then
			_G.DragonHack1 = false
			script.Remote:FireServer(false)
			flight.VelocityLocked = createVector(0, 0, 0)

			if flight.BodyGyro then
				flight.BodyGyro:Set(CFrame.new(
					createVector(0, 0, 0),
					humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
				) + humanoidRootPart.Position)
			end

			if flight.BodyVelocity and not busy.Value then
				flight.BodyVelocity:Set(createVector(-0, -80, -0))
			end

			for k, v16 in pairs(v6.Flying) do
				if k ~= "Land" then
					v16:Stop(0.3)
				end
			end

			v6.Flying.Land:Play(0.3, nil, 0.5)
		end

		if clone:FindFirstChild("Weld") then
			clone.Weld.Enabled = false
		end

		clone.Anchored = true

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.spawn(function()
			local v16 = clone
			task.wait(1)
			v16:Destroy()
		end)
		task.wait(0.25)
		local success, result = pcall(function()
			if not (busy2 or busy.Value or stun.Value > 0) then
				task.delay(0.2, function()
					local _, v16 = CheckForGround(-humanoidRootPart.CFrame.LookVector * 100 / 3, 30)

					if v16 and v16.Instance.Name ~= "WaterBase-Plane" then
						local cFrame = AlignCFrame(
							CFrame.lookAt(createVector(0, 0, 0), humanoidRootPart.CFrame.LookVector) + v16.Position,
							v16.Normal
						) + v16.Normal * 0.05
						Util.Sound:Play("BF_WD_Western_Landing_01", humanoidRootPart)

						if not dragonFlight then
							dragonFlight = FX:WaitForChild("Dragon2").Controllers.DragonFlight
						end

						local clone6 = dragonFlight.Assets.Phase1.LandImpact:Clone()
						clone6.CFrame = cFrame
						Util.SetParentOverrideWithColor(
							clone6,
							workspace._WorldOrigin,
							playerFromCharacter,
							"DragonFruitVFXColor"
						)

						for _, emitter in pairs(clone6:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v18 = emitter
							task.spawn(function()
								if v18:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v18:GetAttribute("EmitDelay"))
								end

								v18:Emit(v18:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
						FlightTransitionWind2({
							player = playerFromCharacter,
							hrp = humanoidRootPart,
							dragonPart = humanoidRootPart,
							lookVector = CFrame.new(cFrame.Position, cFrame.Position + createVector(0, -150, 0)).LookVector
						})
						task.spawn(function()
							task.wait(1)
							clone6:Destroy()
						end)
						task.delay(0.05, function()
							LandImpactRocks(workspace._WorldOrigin, cFrame, v16)
						end)
					end
				end)
			end

			task.spawn(function()
				for _, v16 in pairs(emitters) do
					v16.Enabled = false
				end

				local v16 = clone3
				local v17 = clone4
				task.wait(1)
				v16:Destroy()
				v17:Destroy()
			end)

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if clone2 then
				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			for _, v16 in pairs(emittersByEmitter2) do
				v16.Enabled = false
			end

			emittersByEmitter2 = {}
		end)

		if not success then
			warn(result)
		end

		humanoid.PlatformStand = false
		humanoid.Jump = false
		humanoidRootPart.Velocity *= createVector(0.3, 1, 0.3)

		if flight.BodyVelocity then
			flight.BodyVelocity:Destroy()
			flight.BodyVelocity = false
		end

		task.wait(0.4)

		if flight.BodyGyro then
			flight.BodyGyro:Destroy()
			flight.BodyGyro = false
		end

		flight.VelocityLocked = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
		humanoid.AutoRotate = true
		flight.Landing = false
	end

	maid:GiveTask(function()
		task.spawn(function()
			for _, v15 in pairs(emitters) do
				v15.Enabled = false
			end

			if clone3 then
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			local v15 = clone3
			local v16 = clone4
			task.wait(1)

			if v15 then
				v15:Destroy()
			end

			if v16 then
				v16:Destroy()
			end
		end)
		task.spawn(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			if clone2 then
				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Util.Debris:AddItem(clone2, 1)
			end
		end)
		task.spawn(function()
			local v15 = clone
			task.wait(1)

			if v15 then
				v15:Destroy()
			end
		end)
		humanoid.PlatformStand = false
		humanoid.Jump = false
		humanoidRootPart.Velocity *= createVector(0.3, 1, 0.3)

		if flight.BodyVelocity then
			flight.BodyVelocity:Destroy()
			flight.BodyVelocity = false
		end

		if flight.BodyGyro then
			flight.BodyGyro:Destroy()
			flight.BodyGyro = false
		end

		flight.VelocityLocked = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
		humanoid.AutoRotate = true
		flight.Landing = false
	end)
	maid:GiveTask(DisableFlight)

	if not v4 then
		maid:GiveTask(instance2:GetAttributeChangedSignal("Flying"):Connect(function()
			if instance2:GetAttribute("Flying") then
				EnableFlight()
			else
				DisableFlight()
			end
		end))

		if instance2:GetAttribute("Flying") then
			task.spawn(EnableFlight)
		end
	end

	if v4 then
		maid:GiveTask(UserInputService.JumpRequest:Connect(function()
			if not (flight.Enabled or flight.VelocityLocked) then
				local state = humanoid:GetState()

				if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
					flight.VelocityLocked = (humanoidRootPart.CFrame.LookVector + createVector(0, 10, 0)).Unit
					flight.Velocity = 0
					v6.Flying.FlyUp:Play()
					task.spawn(EnableFlight)
					local lastTime = os.clock()

					while task.wait() do
						local v15 = os.clock() - lastTime

						if v15 < 0.46 then
							continue
						end

						if v15 < 0.76 then
							local v16 = v15 - 0.46
							flight.Velocity = math.pow(v16 / 0.3, 2) * 180
						elseif v15 < 0.96 then
							local v16 = v15 - 0.76
							flight.Velocity = 180 - math.pow(v16 / 0.19999999999999996, 2) * 80
						elseif v15 < 1.26 then
							local v16 = v15 - 0.96
							flight.Velocity = 180
							flight.VelocityLocked = (humanoidRootPart.CFrame.LookVector - createVector(0, 10, 0)).Unit:Lerp(
								humanoidRootPart.CFrame.LookVector,
								(math.clamp(0.5 + v16 / 0.30000000000000004, 0, 1))
							)
						elseif v15 >= 1.26 then
							break
						end
					end

					flight.Velocity = 180
					flight.VelocityLocked = false
				end
			end
		end))
	end

	local v15 = 0
	local v16 = 0
	local v17 = nil
	maid:GiveTask(function()
		if v4 then
			_G.DragonHack1 = false
		end
	end)
	game.Players:GetPlayerFromCharacter(instance)
	maid:GiveTask(RunService2.Heartbeat:Connect(function(dt)
		local v18 = math.min(dt, 2)

		if not (instance2 and instance2.Parent) then
			maid:DoCleaning()
			return
		end

		local v19 = (busy.Value or stun.Value > 0) and true or false

		if not flight.Enabled then
			v16 = 0
			v15 = 0
			v17 = nil
			local v20 = math.clamp(humanoidRootPart.Velocity.Magnitude / 50, 0.4, 2.6)
			particle_1.Rate = rate * v20 * 1.5
			particle_2.Rate = rate2 * v20 * 1.5
			local raycastResult = workspace:Raycast(
				humanoidRootPart.CFrame * CFrame.new(0, 0, 25).Position + createVector(0, 1, 0),
				createVector(-0, -50, -0),
				raycastParams2
			)

			if raycastResult then
				clone5.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * (0.01 + clone5.Size.Y / 2)

				if v14 == false then
					v14 = true
					TweenService:Create(v13, TweenInfo.new(0.5), {
						Volume = 0.22
					}):Play()

					for _, v21 in pairs(emittersByEmitter4) do
						v21.Enabled = true
					end
				end
			elseif v14 == true then
				v14 = false
				TweenService:Create(v13, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()

				for _, v21 in pairs(emittersByEmitter4) do
					v21.Enabled = false
				end
			end
		end

		if not flight.Enabled and v4 then
			if not v6.Default.Idle.IsPlaying then
				v6.Default.Idle:Play(0.3)
			end

			local state = humanoid:GetState()

			if (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed) and humanoidRootPart.Position.Y > 17 then
				local v20 = math.min((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude, humanoid.WalkSpeed)

				if v6.Default.Walk.IsPlaying then
					if v20 > 1.1 then
						v6.Default.Walk:AdjustSpeed(v20 / 160)
					else
						v6.Default.Walk:Stop(0.3)
					end
				elseif v20 > 1.1 then
					v6.Default.Walk:Play(0.3, 1, v20 / 160)
				end
			elseif humanoidRootPart.Position.Y > -2 and (not CheckForGround() or humanoidRootPart.Position.Y < 17) then
				flight.Velocity = math.min(humanoidRootPart.Velocity.Magnitude * 5, 120)
				EnableFlight()
			end
		end

		if not flight.Enabled or flight.Landing then
			return
		end

		if not v4 then
			flight.VelocityLocked = humanoidRootPart.Velocity
			flight.Velocity = flight.VelocityLocked.Magnitude
		end

		local _, v20, v21, v22 = CheckForGround()
		local currentCamera2 = workspace.CurrentCamera
		local vectorToObjectSpace = CFrame.lookAt(
			createVector(0, 0, 0),
			currentCamera2.CFrame.LookVector * createVector(1, 0.001, 1)
		):VectorToObjectSpace(humanoid.MoveDirection)
		local lookVector = currentCamera2.CFrame:VectorToWorldSpace(vectorToObjectSpace)
		local v23 = lookVector.Magnitude > 0.1

		if busy.Value and not instance:GetAttribute("CastingFlamethrower") then
			v23 = false
		end

		if not v23 then
			lookVector = humanoidRootPart.CFrame.LookVector
		end

		local v24 = v23 and not flight.VelocityLocked and 1 or flight.VelocityLocked and 1 or 0
		local v25 = humanoid.MoveDirection.Magnitude <= 0.01

		if v22 and (flight.Velocity < 20 or v25) and not flight.VelocityLocked and v4 then
			return DisableFlight()
		end

		local v26 = 50 + flight.Velocity * v18 * 10
		local raycastResult = workspace:Raycast(humanoidRootPart.Position, lookVector * v26, raycastParams)

		if v24 >= 0 and flight.Velocity > 20 then
			local normal

			if raycastResult then
				normal = raycastResult.Normal
			end

			if v20 and lookVector:Dot(v20.Normal) < 0 then
				normal = v20.Normal
			end

			if normal then
				local v27 = CFrame.new(createVector(0, 0, 0), lookVector) + humanoidRootPart.Position
				lookVector = Util.Misc.AlignCFrame(v27, normal).LookVector
			end
		end

		local v27 = math.asin(humanoidRootPart.CFrame.LookVector.Y) * 57.29577951308232 - 10
		local velocityLocked = flight.VelocityLocked or lookVector
		local velocity = flight.Velocity

		if math.clamp(200 / flight.Velocity, 1, 600) > 2.15 or busy.Value then
			if v12 == true then
				v12 = false

				if v11 then
					Util.Sound:FadeOut(v11, 1)
				end

				for _, v28 in pairs(emittersByEmitter3) do
					v28.Enabled = false
				end
			end
		elseif v12 == false and not (busy.Value or stun.Value > 0) then
			v12 = true
			v11 = Util.Sound:Play("WesternDragon_WindLoop", humanoidRootPart)

			for _, v28 in pairs(emittersByEmitter3) do
				if not (clone:FindFirstChild("WindAuraModel") and clone.WindAuraModel:FindFirstChild("WindAura") and clone.WindAuraModel.WindAura:FindFirstChild("FallAura")) then
					continue
				end

				if v28:IsDescendantOf(clone.WindAuraModel.WindAura.FallAura) then
					continue
				end

				v28.Enabled = true
			end
		end

		local v28 = not busy.Value and 1 or instance:GetAttribute("DragonFlightModifier") or 1

		if v24 == 0 and not (flight.Velocity > 0) then
			if v24 == 0 and v4 and flight.Velocity > 160 then
				if not flight.VelocityLocked then
					flight.Velocity += -90 * v18 * v28
				end
			elseif v24 == 0 and v4 and flight.Velocity < 160 then
				local _ = v6.Flying.Stop.IsPlaying

				if not flight.VelocityLocked then
					flight.Velocity += -math.max(180, flight.Velocity) * v18 * v28
				end
			end
		else
			local raycastResult2 = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 1, 0),
				createVector(-0, -125, -0),
				raycastParams2
			)

			if flight.Velocity > 25 and raycastResult2 then
				local v29 = math.clamp(150 / (flight.Velocity / 2), 1, 6)

				for _, v30 in pairs(emittersByEmitter2) do
					v30.Rate = math.min(v30:GetAttribute("PrimeRate") / v29)
				end

				if raycastResult2.Instance.Name == "WaterBase-Plane" then
					if raycastResult2.Instance.Name == "WaterBase-Plane" then
						if v9 == true then
							v9 = false

							for _, v30 in pairs(emittersByEmitter2) do
								v30.Enabled = false
							end
						end

						if v10 == false then
							v10 = true

							for _, v30 in pairs(emitters) do
								v30.Enabled = true
							end
						end

						local v30 = humanoidRootPart.CFrame + createVector(0, 1, 0) * (-humanoidRootPart.Position.Y - 3.3)
						clone4:SetPrimaryPartCFrame(CFrame.lookAt(
							v30.Position,
							v30.Position + v30.LookVector * createVector(1, 0, 1)
						))
					end
				else
					clone3.CFrame = AlignCFrame(CFrame.new(raycastResult2.Position), raycastResult2.Normal) + raycastResult2.Normal * 0.05
					clone3.CFrame = CFrame.new(clone3.Position, clone3.Position + humanoidRootPart.CFrame.LookVector)

					if v9 == false then
						v9 = true

						for _, v30 in pairs(emittersByEmitter2) do
							v30.Enabled = true

							if v30:GetAttribute("Color") then
								v30.Color = ColorSequence.new(
									raycastResult2.Instance.Color,
									raycastResult2.Instance.Color
								)
							end
						end
					end

					if v10 == true then
						v10 = false

						for _, v30 in pairs(emitters) do
							v30.Enabled = false
						end
					end
				end
			else
				if v9 == true then
					v9 = false

					for _, v29 in pairs(emittersByEmitter2) do
						v29.Enabled = false
					end
				end

				if v10 == true then
					v10 = false

					for _, v29 in pairs(emitters) do
						v29.Enabled = false
					end
				end
			end

			if not flight.VelocityLocked then
				if flight.Velocity <= 0 then
					flight.Velocity = 0
					flight.WasStopped = os.clock()
				end

				if v24 > 0 then
					if v27 > -10 then
						flight.Velocity += -50 * (v27 + 15) / 90 * v18 * v28

						if flight.Velocity < 100 and velocity >= 100 then
							flight.Velocity = 100
						end
					else
						local v29 = flight.Velocity < 100 and -90 or v27

						if flight.Velocity < 250 and v27 <= -30 or flight.Velocity < 220 then
							flight.Velocity += 90 * (v29 / 50) ^ 2 * v18 * v28
						end
					end
				end

				if v19 then
					flight.Velocity -= math.max(flight.Velocity * 0.75, 40) * v18 * v28
				end

				if v24 == 0 or not (flight.Velocity < 60) then
					if v24 == 0 and flight.Velocity > 160 then
						flight.Velocity += -90 * v18
					elseif v24 == 0 and flight.Velocity < 160 then
						local _ = v6.Flying.Stop.IsPlaying

						if not flight.VelocityLocked then
							flight.Velocity += -math.max(180, flight.Velocity) * v18 * v28
						end
					end
				else
					flight.Velocity = 60
				end
			end
		end

		if flight.Velocity > 110 and not flight.VelocityLocked then
			if v27 > -70 and flight.Velocity <= 110 then
				local v29 = (flight.Velocity - 220) / 5 * v18
				flight.Velocity -= v29
			elseif v27 > -40 and flight.Velocity > 110 then
				local v29 = (flight.Velocity - 110) / 3 * v18
				flight.Velocity -= v29
			elseif v27 > -10 and flight.Velocity > 135 then
				local v29 = (flight.Velocity - 135) / 8 * v18
				flight.Velocity -= v29
			elseif flight.Velocity > 220 then
				local v29 = (flight.Velocity - 220) / 5 * v18
				flight.Velocity -= v29
			end
		end

		local function Play(p, value, value2)
			for _, v29 in pairs({
				"Idle",
				"Glide",
				"Boost",
				"Flap",
				"Dive",
				"Stop",
				"FlyUp"
			}) do
				if p ~= v29 and v6.Flying[v29].IsPlaying then
					v6.Flying[v29]:Stop(0.5)
				end
			end

			if not v6.Flying[p].IsPlaying then
				v6.Flying[p]:Play(0.3, value or 1.5, value2 or 1)

				if p == "Idle" then
					v6.Flying.Idle.TimePosition = (v6.Flying.Flap.TimePosition + v6.Flying.Idle.Length / 2) % v6.Flying.Idle.Length
				elseif p == "Flap" then
					v6.Flying.Flap.TimePosition = (v6.Flying.Idle.TimePosition - v6.Flying.Flap.Length / 2) % v6.Flying.Flap.Length
				end
			end

			if p == "Dive" then
				if v8 == false and not (busy.Value or stun.Value > 0) then
					v8 = true

					for _, v29 in pairs(emittersByEmitter) do
						v29.Enabled = true
					end

					renderSteppedConnection = RunService2.RenderStepped:Connect(function()
						clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
					end)

					if v11 then
						TweenService:Create(v11, TweenInfo.new(0.5), {
							PlaybackSpeed = 1.4
						}):Play()
					end

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			elseif v8 == true then
				v8 = false

				for _, v29 in pairs(emittersByEmitter) do
					v29.Enabled = false
				end

				if v11 then
					TweenService:Create(v11, TweenInfo.new(0.5), {
						PlaybackSpeed = 1
					}):Play()
				end

				renderSteppedConnection:Disconnect()

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end

		if not flight.VelocityLocked then
			local glidedFor = flight.GlidedFor

			if v25 and flight.Velocity < 100 and flight.Velocity > 0 then
				Play("Idle", 1.2, 0.65)
			elseif flight.Velocity <= 0 then
				Play("Idle", 1.2, 0.65)
			elseif flight.Velocity > 240 and v27 < -40 or v27 < -60 and flight.Velocity > 20 and velocity <= flight.Velocity then
				Play("Dive")
			elseif velocity <= flight.Velocity and v27 > 0 or v27 > 20 or flight.Velocity < 50 and flight.Velocity > 0 then
				Play("Flap", nil, 1)
			elseif flight.Velocity >= 140 and v27 < 5 then
				Play("Glide")
				glidedFor += v18
			elseif flight.Velocity > 0 then
				Play("Flap", nil, 1)
			else
				Play("Idle", 1.2, 0.65)
			end

			flight.GlidedFor = glidedFor

			if not v6.Flying.Wind1.IsPlaying then
				v6.Flying.Wind1:Play(0.3)
			end

			v6.Flying.Wind1:AdjustSpeed(flight.Velocity / 100 * 2.4)
			v6.Flying.Wind1:AdjustWeight(math.min(flight.Velocity / 220, 1) * 0.2 + 0.2, 0.3)

			if v4 then
				if flight.Velocity > 0 then
					local v29 = math.clamp(humanoidRootPart.AssemblyAngularVelocity.Y, -11, 11) / 11 * 0.6981317007977318
					local v30 = CFrame.lookAt(
						humanoidRootPart.Position,
						humanoidRootPart.Position + velocityLocked,
						createVector(0, 1, 0)
					) * CFrame.Angles(
						0,
						0,
						not (math.abs(v29 * 2) > 0.2617993877991494) and 0 or (v29 * 2 - math.sign(v29) * 0.2617993877991494) * 0.6
					)
					flight.BodyGyro:Set(v30)
				elseif velocity > 0 then
					local lookVector2 = flight.BodyGyro.Values.CFrame.LookVector
					local v29 = math.atan2(lookVector2.X, lookVector2.Z) + 3.141592653589793
					flight.BodyGyro:Set(CFrame.Angles(0, v29, 0))
				end
			end

			if busy.Value or stun.Value > 0 then
				flight.Velocity *= math.pow(0.98, v18)
				flight.Velocity -= 30 * v18 * v28

				if v4 and not instance:GetAttribute("CastingFlamethrower") then
					flight.BodyGyro:Set(humanoidRootPart.CFrame)
				end
			else
				humanoid.AutoRotate = not flight.Enabled
			end
		end

		if flight.Velocity <= 0 and not flight.VelocityLocked then
			flight.Velocity = 0
			flight.WasStopped = os.clock()
		end

		if v4 then
			local velocity2 = flight.Velocity
			local stun2 = instance:FindFirstChild("Stun")

			if stun2 and stun2.Value > 0 then
				velocity2 *= 0.5
			end

			local v29 = velocity2 * 0.93
			flight.BodyVelocity:Set((flight.VelocityLocked or humanoidRootPart.CFrame.LookVector) * v29 * 1.666 + createVector(
				0,
				1,
				0
			) * (v21 or 0) * 6)
			humanoidRootPart.Velocity = (flight.VelocityLocked or humanoidRootPart.CFrame.LookVector) * v29 * 1.666 + createVector(
				0,
				1,
				0
			) * (v21 or 0) * 6
		end
	end))
end

local function CharacterAdded(instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not v2[playerFromCharacter] then
		v2[playerFromCharacter] = { Util.Maid.new(), Util.Maid.new() }
	end

	local v4 = v2[playerFromCharacter][1]
	v2[playerFromCharacter][2]:DoCleaning()
	v4.CharacterConnection = instance.ChildAdded:Connect(function(child)
		if child.Name ~= "WesternDragonRig" then
			return
		end

		SetupRig(instance, child)
	end)

	if instance:FindFirstChild("WesternDragonRig") then
		SetupRig(instance, instance.WesternDragonRig)
	end
end

local function PlayerAdded(player)
	if not v2[player] then
		v2[player] = { Util.Maid.new(), Util.Maid.new() }
	end

	v2[player][1]:GiveTask(player.CharacterAdded:Connect(CharacterAdded))

	if player.Character then
		task.spawn(CharacterAdded, player.Character)
	end
end

game.Players.PlayerAdded:Connect(PlayerAdded)

for _, v4 in pairs(game.Players:GetPlayers()) do
	task.spawn(PlayerAdded, v4)
end

game.Players.PlayerRemoving:Connect(function(player)
	if v2[player] then
		v2[player][1]:DoCleaning()
		v2[player][2]:DoCleaning()
		v2[player] = nil
	end
end)
return DragonFlight