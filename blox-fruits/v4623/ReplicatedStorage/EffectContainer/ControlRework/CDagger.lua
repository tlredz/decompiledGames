local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cDagger = FX:WaitForChild("ControlRework").CDagger
local _WorldOrigin = workspace._WorldOrigin
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local Textures = require(shared.Textures)
local Rocks = require(shared.Rocks)
require(shared:WaitForChild("ObjectClass"))
local random = Random.new()
local SliceExplosionClass = require(shared:WaitForChild("SliceExplosionClass"))
local maid = Util.Maid
local lightningBoltShafi = Util.LightningBoltShafi

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local cameraShaker = Util.CameraShaker
local info = {
	{
		Angle = 90,
		Rotation = 95,
		Scale = 5,
		RayDirection = -1,
		NoBolts = true,
		NoHexTrail = true
	},
	{
		Angle = 45,
		Rotation = 100,
		Scale = 8,
		RayDirection = -1,
		NoBolts = true
	},
	{
		Angle = -45,
		Rotation = -100,
		Scale = 10,
		RayDirection = 1
	}
}

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

function Debris(instance, duration: number)
	if not instance then
		return
	end

	if duration > 0 then
		return task.delay(duration, instance.Destroy, instance)
	end

	if instance then
		instance:Destroy()
	end
end

local function Slash(cFrame: CFrame, rotation: number?, flag: boolean?, scale: number?, p, player, p2)
	local v2 = p2 or cDagger.Phase1.Slash:Clone()

	if not p2 then
		v2:ScaleTo(scale or 1.65)
		VisualHelper:ThinEmitBursts(v2)
	end

	local slash = v2.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, p, player, "ControlFruitVFXColor")
	VisualHelper:Tween(slash.Winds, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Orientation = createVector(0, 360, 0)
	})

	for _, child in slash.Winds:GetChildren() do
		child.Beam.Enabled = true
		VisualHelper:Tween(child.Beam, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, emitter in slash.Slash:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Rotation = NumberRange.new(rotation or 0)
		VisualHelper:Emit(emitter)
	end

	VisualHelper:EmitAll(slash, true)
	local slashBeam = slash.SlashBeam
	slashBeam.Orientation = createVector(0, 180, 0)

	if flag then
		local beamsFlipBook = VisualHelper.BeamsFlipBook.new(8, 60)
		beamsFlipBook:Insert(slashBeam.BeamThunder)
		beamsFlipBook:Play()
		task.delay(1, beamsFlipBook.Destroy, beamsFlipBook)
	end

	VisualHelper:Tween(slashBeam, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Orientation = slashBeam.Orientation - createVector(0, 180, 0)
	})

	for _, child in slashBeam.Beams:GetChildren() do
		child.Enabled = true
		child.Width0 *= 2
		child.Width1 *= 2
		VisualHelper:Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:Tween(slash.PointLight, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	Debris(slash, 2)
	return slash
end

local v2 = #info * 14
local v3 = {}

local function DestroyPreparedRoomEffects(p)
	for _, sliceExplosion in p.SliceExplosions do
		sliceExplosion:Destroy()
	end

	table.clear(p.SliceExplosions)

	for k, v4 in p do
		if k ~= "SliceExplosions" then
			v4:Destroy()
		end
	end
end

local function NewPreparedRoomEffects()
	local v4 = { cDagger.Phase1.CameraEffects, cDagger.Phase1.BoltExplosion, cDagger.Phase1.StormBeamPattern }

	for k, v5 in info do
		local scale = v5.Scale
		table.insert(v4, {
			Template = cDagger.Phase1.Slash,
			Prepare = function(instance)
				instance:ScaleTo(scale)
				VisualHelper:ThinEmitBursts(instance)
			end
		})
		local scale2 = scale
		table.insert(v4, {
			Template = cDagger.Phase1.SlashMove,
			Prepare = function(instance)
				instance:ScaleTo(scale2 / 2.5)
				VisualHelper:CapEmitterRates(instance, 15, true)
			end
		})
		local v8 = k
		table.insert(v4, {
			Template = cDagger.Phase1.MiniSlash,
			Prepare = function(instance)
				instance:ScaleTo(instance:GetScale() + v8 * 0.2)
			end
		})
		local v9 = k
		table.insert(v4, {
			Template = cDagger.Phase1.FloorImpact,
			Prepare = function(instance)
				instance:ScaleTo(instance:GetScale() + v9)
				VisualHelper:ThinEmitBursts(instance)
			end
		})
	end

	table.insert(v4, cDagger.Phase1.FloorSpawnEnd)
	local v5 = {}

	for _ = 1, #info do
		table.insert(v5, {
			Template = cDagger.Phase3.GroundSlashModel,
			Prepare = function(instance)
				VisualHelper:CapEmitterRates(instance, 15, true)
				instance:ScaleTo(1)
			end
		})
		table.insert(v5, {
			Template = cDagger.Phase3.SlashAuraModel,
			Prepare = function(instance)
				instance:ScaleTo(1)
			end
		})
		table.insert(v5, {
			Template = cDagger.Phase3.GroundAura,
			Prepare = function(p)
				VisualHelper:CapEmitterRates(p, 40, true)
			end
		})
		table.insert(v5, {
			Template = cDagger.Phase3.GridModel,
			Prepare = function(instance)
				instance:ScaleTo(0.1)
			end
		})
	end

	local v6 = {}

	for i = 1, #info - 1 do
		table.insert(v6, {
			Template = cDagger.Phase3.GroundAura,
			Prepare = function(p)
				VisualHelper:CapEmitterRates(p, 40, true)
			end
		})
		local v8 = i * 0.5 + 1
		table.insert(v6, {
			Template = cDagger.Phase3.GridModel,
			Prepare = function(instance)
				instance:ScaleTo(v8 * 0.1)
			end
		})
	end

	local v7 = table.create(v2)
	local hexTrailSpecsMoves = table.create(v2)
	local ironSingleSparks = table.create(v2)
	local random2 = Random.new()

	for _ = 1, v2 do
		table.insert(v7, {
			Template = cDagger.Phase1.SliceGround,
			Prepare = function(instance)
				instance:ScaleTo(random2:NextNumber(1.55, 3))
			end
		})
		table.insert(hexTrailSpecsMoves, cDagger.Phase1.Vault.HexTrailSpecsMove)
		table.insert(ironSingleSparks, cDagger.Phase1.IronSingleSpark)
	end

	local v8 = {
		Release = PrepareClonedInstances.new(v4),
		InitialExplosions = PrepareClonedInstances.new(v5),
		Growths = PrepareClonedInstances.new(v6),
		MovingGroundSlices = PrepareClonedInstances.new(v7),
		MovingTrails = PrepareClonedInstances.new(hexTrailSpecsMoves),
		MovingSparks = PrepareClonedInstances.new(ironSingleSparks),
		SliceExplosions = {}
	}

	for _, v9 in info do
		v8.SliceExplosions[v9.Scale] = SliceExplosionClass.Prepare(v9.Scale * 0.065 + 0.7)
	end

	return v8
end

local function PrepareRoomEffects(instance)
	local v4 = v3[instance]

	if v4 then
		return v4
	end

	local newPreparedRoomEffects = NewPreparedRoomEffects()
	v3[instance] = newPreparedRoomEffects
	instance.Destroying:Once(function()
		if v3[instance] ~= newPreparedRoomEffects then
			return
		end

		v3[instance] = nil
		DestroyPreparedRoomEffects(newPreparedRoomEffects)
	end)
	return newPreparedRoomEffects
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleasePreparedRoomEffects(p, p2)
	if v3[p] == p2 then
		v3[p] = nil
	end

	DestroyPreparedRoomEffects(p2)
end

local function NewBolt(attachment, attachment2, value: number?, p, model, player)
	local v4 = lightningBoltShafi.new(attachment, attachment2, value or 35, 0.7 * p, model)
	local curveSize = -math.random(5, 7)
	local curveSize2 = math.random(5, 7)
	v4.CurveSize0 = curveSize
	v4.CurveSize1 = curveSize2
	v4.MinRadius = 1
	v4.MaxRadius = 3
	v4.Frequency = 0.5
	v4.AnimationSpeed = math.random(5, 9)
	local maxThicknessMultiplier = 0.3 + math.random() * 0.75
	v4.MinThicknessMultiplier = 0.1
	v4.MaxThicknessMultiplier = maxThicknessMultiplier
	v4.MinTransparency = 0
	v4.MaxTransparency = 1
	v4.PulseSpeed = 40
	v4.PulseLength = 1000000
	v4.FadeLength = 0.2
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
	})

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
	end

	v4.Color = colorSequence
	v4.ContractFrom = 0.5
	v4.ColorOffsetSpeed = 3
	return v4
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder_2 = Instance.new("Folder", player.Player)
		folder_2.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage
	local player2 = player.Player
	local root = player.Root
	local character = player.Character

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local model = Instance.new("Model")
		model.Name = player2.Name .. "_DaggerCFolder"
		model.Parent = _WorldOrigin
		local v4 = v3[model]

		if not v4 then
			v4 = NewPreparedRoomEffects()
			v3[model] = v4
			model.Destroying:Once(function()
				if v3[model] ~= v4 then
					return
				end

				v3[model] = nil
				DestroyPreparedRoomEffects(v4)
			end)
		end

		Util.Sound:Play("C_BladeThrow_Activate_Transformed_01", root)
		local v5 = Util.Sound:Play("C_BladeThrow_Charging_Held_01", root)
		TweenService:Create(v5, TweenInfo.new(1), {
			Volume = 1
		}):Play()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

		if player2 == game.Players.LocalPlayer then
			cameraShaker:Shake("Fast")
			VisualHelper:Tween(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				FieldOfView = 76
			})
		end

		local clone = cDagger.Phase0.ShaderScreen:Clone()
		clone.Name = "DaggerCScreen"
		clone.Image.ImageTransparency = 1
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local v6

		if player.Player == game.Players.LocalPlayer then
			v6 = player.Player:FindFirstChild("PlayerGui") or model
		else
			v6 = model
		end

		setParentOverrideWithColor(clone, v6, player2, "ControlFruitVFXColor")
		VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.86
		})
		local random2 = Random.new()
		local clone2 = cDagger.Phase0.DoubleNeonEye:Clone()
		clone2.Anchored = false
		clone2.Weld.Part0 = character.Head
		Util.SetParentOverrideWithColor(clone2, model, player2, "ControlFruitVFXColor")
		VisualHelper:SetEnableAll(clone2, true)
		local clone3 = cDagger.Phase0.FloorSpawn:Clone()
		clone3.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")
		VisualHelper:Tween(clone3.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Orientation = clone3.CircleWinds.Orientation + createVector(0, 180, 0)
		})
		VisualHelper:EmitAll(clone3)
		clone3.PointLight.Enabled = true
		VisualHelper:Tween(clone3.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 0
		})

		for _, child in clone3.CircleWinds:GetChildren() do
			local beam = child.Beam
			local width = beam.Width0 / 2
			local width2 = beam.Width1 / 2
			beam.Width0 = width
			beam.Width1 = width2
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(clone3, 2.15)
		local clone4 = cDagger.Phase0.NeonRotation:Clone()
		clone4:ScaleTo(1.2)
		clone4.Main.Anchored = false
		clone4.Main.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone4, model, player2, "ControlFruitVFXColor")
		clone4.Main.Layers.Orientation = createVector(0, 1, 0) * random2:NextNumber(-360, 360)

		for i, child in clone4.Main.Layers:GetChildren() do
			child.Orientation *= 1.5
			child.Position *= 1.5
			local beam = child.Beam
			local width = beam.Width0 / 2
			local width2 = beam.Width1 / 2
			beam.Width0 = width
			beam.Width1 = width2
			beam.Enabled = true
			local number = random2:NextNumber(0.17, 0.25)
			VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
				Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
			})
			VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(clone4, 2)
		local clone5 = cDagger.Phase0.Handle:Clone()
		clone5.Anchored = false
		clone5.Weld.Part1 = root
		Util.SetParentOverrideWithColor(clone5, model, player2, "ControlFruitVFXColor")
		VisualHelper:Tween(clone5.Beams, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = clone5.Beams.Orientation - createVector(0, 360, 0)
		})
		VisualHelper:SetEnableAll(clone5, true)
		tick()

		repeat
			task.wait()
		until not (holding and holding.Value)

		if v5 then
			Util.Sound:FadeOut(v5, 0.2)
		end

		task.delay(2, function()
			pcall(function()
				if model:IsDescendantOf(workspace) and model.Name ~= "Destroying" then
					model.Name = "Destroying"
					Util.Debris:AddItem(model, 5)
					VisualHelper:SetEnableAll(model.Handle, false)
					Debris(model.Handle, 1.5)
					VisualHelper:SetEnableAll(model.DoubleNeonEye, false)
					Debris(model.DoubleNeonEye, 1)
					ReleasePreparedRoomEffects(model, v4) -- equivalent call inferred; original call site unknown
				end
			end)
		end)
		Util.Debris:AddItem(clone, 20)
	elseif stage == 2 then
		local proxyFolder = player.ProxyFolder

		if not proxyFolder then
			return
		end

		local _ = player.MousePos
		local daggerCScreen = player2.PlayerGui:FindFirstChild("DaggerCScreen")
		local child = _WorldOrigin:FindFirstChild(player2.Name .. "_DaggerCFolder")

		if not child then
			return
		end

		local v4 = v3[child]

		if not v4 then
			v4 = NewPreparedRoomEffects()
			v3[child] = v4
			child.Destroying:Once(function()
				if v3[child] ~= v4 then
					return
				end

				v3[child] = nil
				DestroyPreparedRoomEffects(v4)
			end)
		end

		local release = v4.Release
		child.Name = "Destroying"
		Util.Debris:AddItem(child, 15)
		local v5 = release:Take()

		if game.Players.LocalPlayer == player2 then
			Util.SetParentOverrideWithColor(v5, currentCamera, player2, "ControlFruitVFXColor")
		end

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(v5, true)
			VisualHelper:EmitAll(v5)
		end

		local v6 = release:Take()
		Util.SetParentOverrideWithColor(v6, child, player2, "ControlFruitVFXColor")
		local v7 = release:Take()
		v7:PivotTo(CFrame.new(root.Position))
		Util.SetParentOverrideWithColor(v7, child, player2, "ControlFruitVFXColor")

		for _, attachment in v7.Main:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end

			attachment.Orientation *= 1.15
			local beam = attachment.Beam
			beam.Brightness *= 1.75
			beam.Enabled = true
			VisualHelper:Tween(attachment, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				Orientation = attachment.Orientation + createVector(0, 515, 0)
			})
			VisualHelper:Tween(beam, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = beam.Width0 * 0.85,
				Width1 = beam.Width1 * 0.85
			})
		end

		VisualHelper:TweenScale(v7, TweenInfo.new(0.7, Enum.EasingStyle.Sine), v7:GetScale() + 0.5)
		Debris(v7, 0.7)
		local v8 = {
			Info = info,
			Processing = {},
			Connection = nil,
			Loaded = false,
			Destroyed = false,
			Finished = false
		}
		local v9 = {}

		local function TryFinishSlashProcessing()
			local processing = v8.Processing

			if v8.Finished or v8.Destroyed or not v8.Loaded or not processing or next(processing) then
				return
			end

			v8.Finished = true

			if v8.Connection then
				v8.Connection:Disconnect()
				v8.Connection = nil
			end

			v5:Destroy()
			VisualHelper:Tween(currentCamera, TweenInfo.new(5, Enum.EasingStyle.Sine), {
				FieldOfView = 70
			})

			if daggerCScreen and daggerCScreen.Parent then
				VisualHelper:Tween(daggerCScreen.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					ImageTransparency = 1
				})
				Debris(daggerCScreen, 0.5)
			end

			Debris(child, 5)
			ReleasePreparedRoomEffects(child, v4) -- equivalent call inferred; original call site unknown
			table.clear(v8)
		end

		local function RemoveProcessingSlash(instance)
			local v10 = v8.Processing[instance]

			if not v10 then
				return
			end

			v8.Processing[instance] = nil
			local smokes = v10.Smokes
			VisualHelper:SetEnableAll(smokes, false)
			Debris(smokes, 4)

			if instance:FindFirstChild("Main") then
				local clone = cDagger.Phase1.Vault.EndStar:Clone()
				clone.CFrame = instance:GetPivot()
				Util.SetParentOverrideWithColor(clone, workspace.Terrain, player2, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone)
				Debris(clone, 1)
			end

			v10.Maid:DoCleaning()
			instance:Destroy()
			TryFinishSlashProcessing()
		end

		local total = 1
		local folder = nil
		local folder2 = nil
		v8.Connection = RunService.Heartbeat:Connect(function(dt)
			local DELAY_DURATION = 1.75
			v5.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.15) * CFrame.Angles(0, 1.5707963267948966, 0)
			local serverTimeNow = workspace:GetServerTimeNow()

			for k, v10 in v8.Processing do
				local main = k:FindFirstChild("Main")
				local groundPart = k:FindFirstChild("GroundPart")

				if main and groundPart then
					main.CFrame *= CFrame.new(0, 0, -v10.Speed * dt)
					local slashProxy = v10.SlashProxy
					local v11 = serverTimeNow - v10.SpawnTime
					local v12 = main.Size.X / 2 + 1.5
					local rayCast = MathHelper:RayCast(
						main.Position,
						main.CFrame.RightVector * (v12 * v10.RayDirection),
						{ workspace.Characters, workspace.Enemies }
					)

					if rayCast and rayCast.Normal.Y < 0.75 then
						rayCast = nil
					end

					v10.DebrisTime += dt

					if v10.DebrisTime > 0.15 then
						v10.DebrisTime = 0
						v10.IsRockTime = not v10.IsRockTime
						cameraShaker:Shake("Regular Explosion Super Smooth")
						local v13 = 0.15 + math.random() * 0.35
						local position = main.Position + Vector3.new(
							math.random(-35, 35),
							math.random(35),
							math.random(-35, 35)
						)
						local v15 = main.CFrame * CFrame.new(
							math.random(-35, 35),
							math.random(-35, 35),
							(main.Size.Z + 35) * 1.6
						).Position
						local v16 = v4.MovingTrails:Take()
						v16.Position = position
						Util.SetParentOverrideWithColor(v16, workspace.Terrain, player2, "ControlFruitVFXColor")
						Debris(v16, v13 + 0.5)
						local magnitude = (position - v15).Magnitude
						local cframe = CFrame.lookAt(position, v15)
						local v21 = cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.25).Position
						local v22 = cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.75).Position
						VisualHelper:TweenNumberValue(1, TweenInfo.new(v13, Enum.EasingStyle.Sine), function(p: number)
							v16.Position = MathHelper:CubicBezier(p, position, v21, v22, v15)
						end)

						if rayCast then
							local cframe2 = CFrame.new(rayCast.Position)

							if v10.IsRockTime then
								Rocks:AirRocks(
									cframe2,
									Vector3.new(1, random:NextNumber(0.6, 1), random:NextNumber(1, 1.5)) * random:NextNumber(
										1.7,
										2.2
									),
									true,
									math.random(25, 115),
									random:NextNumber(0.5, 1),
									1.5 + math.random() * 0.5,
									false,
									rayCast.Instance.Color,
									rayCast.Instance.Material
								)
							end

							local v24 = v4.MovingGroundSlices:Take()
							v24:PivotTo(CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
								-1.5707963267948966,
								math.rad((math.random(360))),
								0
							) * CFrame.new(math.random(-5, 5), 0, 0))
							Util.SetParentOverrideWithColor(v24, child, player2, "ControlFruitVFXColor")
							VisualHelper:EmitAll(v24)
							local size = v24.SliceGround.Size
							v24.SliceGround.Size = createVector(0, 0, 0)
							VisualHelper:Tween(v24.SliceGround, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
								Size = size
							})
							task.delay(0.3, function()
								VisualHelper:Tween(v24.SliceGround.Decal, TweenInfo.new(0.25), {
									Color3 = Color3.fromRGB()
								})
								VisualHelper:Tween(v24.SliceGround, TweenInfo.new(0.3), {
									Size = Vector3.new(0, 0, v24.SliceGround.Size.Z)
								})
								task.wait(0.3)
								v24:Destroy()
							end)
							local airRocks = Rocks:AirRocks(
								cframe2,
								cDagger.Phase1.IronSingleSpark.Size,
								true,
								math.random(50, 115),
								2,
								0,
								20,
								false,
								false,
								v4.MovingSparks:Take(),
								function(instance)
									instance.Anchored = true
									instance.Main.Trail.Enabled = false
									task.wait(2)
									instance:Destroy()
								end
							)
							VisualHelper:EmitAll(airRocks.Main)
							VisualHelper:Tween(airRocks.Main.PointLight, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {
								Brightness = 0
							})
						end
					end

					local smokes = v10.Smokes

					if rayCast then
						local _, v13 = CFrame.lookAt(
							v10.Origin,
							(Vector3.new(rayCast.Position.X, v10.Origin.Y, rayCast.Position.Z))
						):ToEulerAnglesYXZ()
						groundPart.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.15, 0)) * CFrame.Angles(
							0,
							v13,
							0
						)
						smokes.CFrame = groundPart.CFrame

						if not v10.GroundPartEnabled then
							v10.GroundPartEnabled = true
							VisualHelper:SetEnableAll(groundPart, v10.GroundPartEnabled)
							VisualHelper:SetEnableAll(smokes, v10.GroundPartEnabled)
						end
					elseif v10.GroundPartEnabled then
						v10.GroundPartEnabled = false
						VisualHelper:SetEnableAll(groundPart, v10.GroundPartEnabled)
						VisualHelper:SetEnableAll(smokes, v10.GroundPartEnabled)
					end

					local growthHandled = v10.GrowthHandled
					local explosionHandled = v10.ExplosionHandled
					local grow = slashProxy:GetAttribute("Grow")

					for _, v13 in SliceExplosionClass.Stored do
						if growthHandled or grow == nil or v13.Proxy:GetAttribute("Id") ~= grow then
							continue
						end

						v10.GrowthHandled = true
						growthHandled = true

						if not v13:Grow() then
							continue
						end

						for _, v14 in pairs(v9) do
							if v14:GetAttribute("Id") ~= v13.Proxy:GetAttribute("Id") then
								continue
							end

							v14.RollOffMinDistance += 50
							v14.Volume += 0.4
						end

						total += 0.5

						if folder ~= nil then
							folder:ScaleTo(total)
							Util.Sound:Play(
								"C_BladeThrowInside_Impact_0" .. tostring(math.random(1, 3)),
								folder.PrimaryPart.Position,
								total * 25
							)
							local folder3 = v4.Growths:Take()
							folder3.CFrame = folder.PrimaryPart.CFrame
							Util.SetParentOverrideWithColor(folder3, child, player2, "ControlFruitVFXColor")
							folder3:SetAttribute("Changed", false)

							for _, emitter in pairs(folder3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v14 = emitter
								local v15 = folder3
								task.spawn(function()
									v14.Enabled = true
									task.wait(0.25)

									if v15:GetAttribute("Changed") == true then
										return
									end

									v14.Enabled = false
								end)
							end

							local folder4 = v4.Growths:Take()
							task.spawn(function()
								folder4:PivotTo(folder.PrimaryPart.CFrame * CFrame.new(0, 30, 0))
								local v15 = total * 0.1

								if math.abs(folder4:GetScale() - v15) > 0.0001 then
									folder4:ScaleTo(v15)
								end

								Util.SetParentOverrideWithColor(folder4, child, player2, "ControlFruitVFXColor")

								for i, emitter in pairs(folder4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter:Emit(1)
									end
								end

								for i = folder4:GetScale(), total * 5, 0.75 do
									folder4:ScaleTo(i / 10)
									task.wait(0.0075)
								end

								task.wait(0.001)

								for i, emitter in pairs(folder4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							local v15 = total * 150
							folder3.Aura2.Size = createVector(5, 1, 5)
							TweenService:Create(
								folder3.Aura2,
								TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(v15, 1, v15)
								}
							):Play()
						end

						if folder2 ~= nil then
							folder2:ScaleTo(total)
						end
					end

					local exploded = slashProxy:GetAttribute("Exploded")

					if exploded and not (explosionHandled or growthHandled) then
						v10.ExplosionHandled = true
						explosionHandled = true
						main.CFrame = exploded
						local position = main.Position
						local v13 = Util.Sound:Play("C_Bladestorm_Active_Loop_01", position)
						v13:SetAttribute("Id", slashProxy:GetAttribute("Id"))
						table.insert(v9, v13)
						local rayCast2 = MathHelper:RayCast(
							main.Position,
							main.CFrame.LookVector * 20,
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
							Enum.RaycastFilterType.Exclude
						)
						local cframe = rayCast2 and CFrame.new(rayCast2.Position + createVector(0, 0.1, 0)) or CFrame.new(main.Position)
						folder = v4.InitialExplosions:Take()
						folder:PivotTo(cframe)

						if math.abs(folder:GetScale() - total) > 0.0001 then
							folder:ScaleTo(total)
						end

						Util.SetParentOverrideWithColor(folder, child, player2, "ControlFruitVFXColor")
						task.delay(DELAY_DURATION, function()
							if v13 then
								Util.Sound:FadeOut(v13, 0.4)
							end

							Util.Sound:Play(
								"C_BladeStorm_Disappear_0" .. tostring(math.random(1, 4)),
								position,
								20 * folder:GetScale()
							)
						end)

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = true
							local v16 = emitter
							task.delay(DELAY_DURATION, function()
								v16.Enabled = false
							end)
						end

						local sliceExplosion = v4.SliceExplosions[v10.Scale]
						v4.SliceExplosions[v10.Scale] = nil
						SliceExplosionClass.new(
							nil,
							child,
							player2,
							cframe,
							0.7 + v10.Scale * 0.065,
							nil,
							slashProxy,
							sliceExplosion
						)
						folder2 = v4.InitialExplosions:Take()
						folder2:PivotTo(CFrame.new(main.Position))

						if math.abs(folder2:GetScale() - total) > 0.0001 then
							folder2:ScaleTo(total)
						end

						Util.SetParentOverrideWithColor(folder2, child, player2, "ControlFruitVFXColor")

						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = true
							local v16 = emitter
							task.delay(DELAY_DURATION, function()
								v16.Enabled = false
							end)
						end

						local folder3 = v4.InitialExplosions:Take()
						folder3.CFrame = cframe
						Util.SetParentOverrideWithColor(folder3, child, player2, "ControlFruitVFXColor")
						folder3:SetAttribute("Changed", false)

						for _, emitter in pairs(folder3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v16 = emitter
							local v17 = folder3
							task.spawn(function()
								v16.Enabled = true
								task.wait(0.25)

								if v17:GetAttribute("Changed") == true then
									return
								end

								v16.Enabled = false
							end)
						end

						local folder4 = v4.InitialExplosions:Take()
						task.spawn(function()
							folder4:PivotTo(cframe * CFrame.new(0, 30, 0))
							local v18 = total * 0.1

							if math.abs(folder4:GetScale() - v18) > 0.0001 then
								folder4:ScaleTo(v18)
							end

							Util.SetParentOverrideWithColor(folder4, child, player2, "ControlFruitVFXColor")

							for i, emitter in pairs(folder4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(1)
								end
							end

							for i = folder4:GetScale(), total * 5, 0.75 do
								folder4:ScaleTo(i / 10)
								task.wait(0.0075)
							end

							task.wait(0.001)

							for i, emitter in pairs(folder4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						local v18 = total * 150
						folder3.Aura2.Size = createVector(5, 1, 5)
						TweenService:Create(
							folder3.Aura2,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(v18, 1, v18)
							}
						):Play()
						local _ = main.Position
					end

					if not slashProxy:IsDescendantOf(workspace) or explosionHandled or growthHandled or not (v11 < 2) then
						RemoveProcessingSlash(k)
					end
				else
					RemoveProcessingSlash(k)
				end
			end
		end)
		child.Destroying:Once(function()
			v8.Destroyed = true

			if v8.Connection then
				v8.Connection:Disconnect()
				v8.Connection = nil
			end

			local processing = v8.Processing

			if processing then
				for k, v10 in processing do
					VisualHelper:SetEnableAll(v10.Smokes, false)
					Debris(v10.Smokes, 4)
					v10.Maid:DoCleaning()
					k:Destroy()
				end

				table.clear(processing)
			end

			v5:Destroy()
		end)

		for k, v11 in v8.Info do
			if v8.Destroyed then
				break
			end

			cameraShaker:Shake("Regular Explosion Smooth")
			local v12 = Util.Sound:Play("C_Blade_Release_Inside_0" .. tostring(k), root.Position)
			v12.RollOffMinDistance *= k
			task.wait(0.1)

			if v8.Destroyed then
				break
			end

			if not proxyFolder:FindFirstChild("Slash_" .. tostring(k)) then
				repeat
					task.wait()
				until v8.Destroyed or proxyFolder:FindFirstChild("Slash_" .. tostring(k)) or not proxyFolder:IsDescendantOf(workspace)
			end

			if v8.Destroyed then
				break
			end

			local child2 = proxyFolder:FindFirstChild("Slash_" .. tostring(k))

			if not child2 then
				child:Destroy()
				return
			end

			local v13 = child2.Value * CFrame.new(0, 0, 5)
			local v14 = release:Take()
			local slash = Slash(
				child2.Value * CFrame.Angles(0, 0, (math.rad(v11.Angle))),
				v11.Rotation,
				true,
				v11.Scale,
				nil,
				player2,
				v14
			)
			local maid2 = maid.new()
			local v16 = release:Take()
			v16:PivotTo(slash.CFrame * CFrame.new(0, 0, -3 + k * 0.5))
			Util.SetParentOverrideWithColor(v16, child, player2, "ControlFruitVFXColor")
			local frontWinds = v16.Main.Smash.FrontWinds
			frontWinds.Parent = workspace.Terrain
			frontWinds.CFrame = root.CFrame * CFrame.new(0, 0, -5)
			VisualHelper:Tween(frontWinds, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
				CFrame = frontWinds.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			})

			for _, child3 in frontWinds:GetChildren() do
				local beamMain = child3.BeamMain
				beamMain.Enabled = true
				VisualHelper:Tween(beamMain, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			Debris(frontWinds, 0.15)
			local charge = v16.Main.Charge
			local windStorm = charge.WindStorm
			VisualHelper:Tween(windStorm, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Orientation = windStorm.Orientation - createVector(0, 360, 0)
			})
			local hexTrail = charge.TrailsBeam.Point1.HexTrail

			if v11.NoBolts then
				v16.Main.Bolts:Destroy()
			end

			if v11.NoHexTrails then
				hexTrail:Destroy()
			else
				local hexTrail2 = hexTrail
				maid2:GiveTask(task.spawn(function()
					while true do
						for k2, texture in Textures.HexTrailBeam do
							hexTrail2.Texture = texture
							task.wait(0.041666666666666664)
						end
					end
				end))
			end

			local beam = charge.TrailsBeam.Point3.Beam
			maid2:GiveTask(task.spawn(function()
				while true do
					for k2, texture in Textures.WindBeam do
						beam.Texture = texture
						task.wait(0.02)
					end
				end
			end))
			local maid3 = maid2
			maid2:GiveTask(task.spawn(function()
				for i = 1, 7 do
					local v20 = 0.3 + math.random() * 0.3
					local position = v13.Position + Vector3.new(
						math.random(-32, 32),
						math.random(21.333333333333332),
						math.random(-32, 32)
					)
					local clone = cDagger.Phase1.Vault.HexTrailSpecs3:Clone()
					clone.Position = position
					Util.SetParentOverrideWithColor(clone, workspace.Terrain, player2, "ControlFruitVFXColor")
					Debris(clone, v20 + 0.5)
					local cframe = CFrame.new(math.random(-65, 65), math.random(-65, 65), 0)
					local cframe2 = CFrame.new(math.random(-65, 65), math.random(-65, 65), 0)
					local v22 = Vector3.new(math.random(-6, 6), math.random(35), math.random(-6, 6))
					maid3:GiveTask(VisualHelper:TweenNumberValue(
						1,
						TweenInfo.new(v20, Enum.EasingStyle.Sine),
						function(p: number)
							local v27 = v16.Main.Position + v22
							local magnitude = (position - v27).Magnitude
							local cframe3 = CFrame.lookAt(position, v27)
							clone.Position = MathHelper:CubicBezier(
								p,
								position,
								cframe3 * CFrame.new(0, 0, -magnitude * 0.25) * cframe.Position,
								cframe3 * CFrame.new(0, 0, -magnitude * 0.75) * cframe2.Position,
								v27
							)
						end
					))
					task.wait(0.015)
				end
			end))
			local smokes = v16.GroundPart.Smokes
			smokes.Parent = workspace.Terrain
			v8.Processing[v16] = {
				SpawnTime = workspace:GetServerTimeNow(),
				Speed = player.Speed,
				DebrisTime = 0,
				Scale = v11.Scale,
				RayDirection = v11.RayDirection,
				Smokes = smokes,
				Origin = slash.Position,
				Maid = maid2,
				SlashProxy = child2,
				GrowthHandled = false,
				ExplosionHandled = false
			}
			local v20 = release:Take()
			v20:PivotTo(root.CFrame * CFrame.Angles(0, 0, (math.rad(v11.Rotation * 2))))
			Util.SetParentOverrideWithColor(v20, child, player2, "ControlFruitVFXColor")
			VisualHelper:Tween(v20.Main.Winds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Orientation = createVector(0, 360, 0)
			})

			for _, child3 in v20.Main.Winds:GetChildren() do
				child3.Beam.Enabled = true
				VisualHelper:Tween(child3.Beam, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			VisualHelper:EmitAll(v20)
			Debris(v20, 1)
			local v21 = release:Take()
			v21:PivotTo(root.CFrame * CFrame.new(0, -2.8, 0))
			Util.SetParentOverrideWithColor(v21, child, player2, "ControlFruitVFXColor")
			VisualHelper:Tween(v21.Main.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Orientation = v21.Main.CircleWinds.Orientation + createVector(0, 180, 0)
			})
			VisualHelper:EmitAll(v21)
			v21.Main.PointLight.Enabled = true
			VisualHelper:Tween(v21.Main.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Brightness = 0
			})

			for _, child3 in v21.Main.CircleWinds:GetChildren() do
				local beam2 = child3.Beam
				beam2.Brightness *= 0.35
				beam2.Enabled = true
				VisualHelper:Tween(beam2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			Debris(v21, 2.15)
			local _WorldOrigin2 = workspace._WorldOrigin
			local v22 = root.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(25, 35)
			)
			local rayCast = MathHelper:RayCast(
				v22.Position,
				v22.UpVector * -10,
				{ _WorldOrigin2 },
				Enum.RaycastFilterType.Include
			)

			if rayCast then
				v6.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.05, 0))
				VisualHelper:EmitAll(v6)
			end

			for _ = 1, 3 do
				local v23 = 0.12 + math.random(3) * 0.065
				local position = root.Position
				local v24 = root.Position + Vector3.new(math.random(-25, 25), math.random(17.5), math.random(-25, 25))
				local clone = cDagger.Phase1.Vault.HexTrailSpecs5:Clone()
				clone.Position = position
				Util.SetParentOverrideWithColor(clone, workspace.Terrain, player2, "ControlFruitVFXColor")
				Debris(clone, v23 + 0.5)
				local magnitude = (position - v24).Magnitude
				local cframe = CFrame.lookAt(position, v24)
				local v29 = cframe * CFrame.new(math.random(-45, 45), math.random(-45, 45), -magnitude * 0.25).Position
				local v30 = cframe * CFrame.new(math.random(-45, 45), math.random(-45, 45), -magnitude * 0.75).Position
				VisualHelper:TweenNumberValue(1, TweenInfo.new(v23, Enum.EasingStyle.Sine), function(p: number)
					clone.Position = MathHelper:CubicBezier(p, position, v29, v30, v24)
				end)
			end
		end

		if v8.Destroyed then
			return
		end

		local v11 = release:Take()
		v11.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		Util.SetParentOverrideWithColor(v11, child, player2, "ControlFruitVFXColor")
		VisualHelper:EmitAll(v11)
		v11.PointLight.Enabled = true
		VisualHelper:Tween(v11.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 0
		})
		Debris(v11, 2.15)
		VisualHelper:SetEnableAll(child.Handle, false)
		Debris(child.Handle, 1.5)
		VisualHelper:SetEnableAll(child.DoubleNeonEye, false)
		Debris(child.DoubleNeonEye, 1)
		v8.Loaded = true
		TryFinishSlashProcessing()
	elseif stage == 3 then
		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Debris:AddItem(model, 5)
		local enemyChar = player.EnemyChar

		if enemyChar then
			local humanoidRootPart = enemyChar.HumanoidRootPart
			Util.Sound:Play("C_NPC_TimeBomb_Explode_0" .. tostring(math.random(1, 2)), humanoidRootPart)
			local clone = cDagger.Phase2.BoltMark:Clone()
			clone.Anchored = false
			clone.Weld.Part1 = humanoidRootPart
			Util.SetParentOverrideWithColor(clone, model, player2, "ControlFruitVFXColor")
			VisualHelper:Tween(
				clone.Beams,
				TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = clone.Beams.Orientation - createVector(0, 360, 0)
				}
			)
			local main = clone.MarkGUI.Main
			VisualHelper:Tween(
				main.IconB,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 0.8,
					Size = UDim2.fromScale(0.85, 0.85)
				}
			)
			VisualHelper:Tween(
				main.IconC,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 1,
					Size = UDim2.fromScale(1, 1)
				}
			)

			local function Release(_: boolean?)
				clone.Parent = model
				VisualHelper:Tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new()
				})
				task.wait(0.325)

				for _ = 1, 5 do
					VisualHelper:EmitAll(clone.Flash)
					task.wait(0.15)
				end

				Debris(clone, 1)
				VisualHelper:EmitAll(clone.Flash)
				VisualHelper:SetEnableAll(clone, false)
				VisualHelper:ImpactFrame(0, 0.15, 6, 0.045, -0.25, -0.25, 0.25)
				cameraShaker:Shake("Regular Explosion Smooth")
				local clone2 = cDagger.Phase2.TargetExplosion:Clone()
				VisualHelper:ThinEmitBursts(clone2)
				clone2.CFrame = humanoidRootPart.CFrame
				Util.SetParentOverrideWithColor(clone2, model, player2, "ControlFruitVFXColor")
				local beams = clone2.Beams
				VisualHelper:Tween(beams, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
					Orientation = beams.Orientation + createVector(0, 360, 0)
				})
				task.delay(0.1, function()
					for _, beam in beams:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Enabled = true
						VisualHelper:Tween(beam, TweenInfo.new(0.1 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					for i = 1, 15 do
						local v4 = 0.35 + math.random(5) * 0.03 - i * 0.05
						local v5 = clone2.Position + Vector3.new(
							math.random(-95, 95),
							math.random(-95, 95),
							math.random(-95, 95)
						)
						local position = clone2.Position
						local clone3 = cDagger.Phase2.Vault.HexTrailSpecsMove3:Clone()
						Util.SetParentOverrideWithColor(clone3, workspace.Terrain, player2, "ControlFruitVFXColor")
						clone3.Position = position
						Debris(clone3, v4 + 0.5)
						local magnitude = (position - v5).Magnitude
						local cframe = CFrame.lookAt(position, v5)
						local v10 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.25).Position
						local v11 = cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude * 0.75).Position
						VisualHelper:TweenNumberValue(1, TweenInfo.new(v4, Enum.EasingStyle.Sine), function(p: number)
							clone3.Position = MathHelper:CubicBezier(p, position, v10, v11, v5)
						end)
						task.wait(0.015)
					end
				end)

				for _ = 1, 6 do
					local clone3 = cDagger.Phase2.Vault.EndSingleSpark:Clone()
					clone3.CFrame = clone2.CFrame * CFrame.Angles(
						math.rad((math.random(-45, 45))),
						math.rad((math.random(360))),
						0
					)
					Util.SetParentOverrideWithColor(clone3, workspace.Terrain, player2, "ControlFruitVFXColor")
					VisualHelper:EmitAll(clone3)
					Debris(clone3, 1.5)
					VisualHelper:Tween(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
						CFrame = clone3.CFrame * CFrame.new(0, 0, math.random(40, 100))
					})
				end

				local attachment = Instance.new("Attachment", humanoidRootPart)
				Debris(attachment, 1.5)

				for _ = 1, 5 do
					local position = CFrame.new(clone2.Position) * CFrame.Angles(
						math.random() * 3.141592653589793,
						math.random() * 3.141592653589793 * 2,
						0
					) * CFrame.new(0, 0, -math.random(55, 80)).Position
					local attachment2 = Instance.new("Attachment", workspace.Terrain)
					attachment2.Position = position
					Debris(NewBolt(attachment, attachment2, 10, math.random(10, 30) / 10, model, player2), 0.3)
					Debris(attachment2, 0.5)
				end

				VisualHelper:EmitAll(clone2)
			end

			task.wait(player.Delay)
			Release(true)
		end
	end
end