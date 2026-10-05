local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace._WorldOrigin
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
local HexsStormClass = require(shared.HexsStormClass)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
local PreAnimations = require(script:WaitForChild("PreAnimations"))
local cameraShaker = Util.CameraShaker
local domain_Katsuo = FX:WaitForChild("ControlRework").Domain_Katsuo
local z_Katsuo = FX:WaitForChild("ControlRework").Z_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local _ = FX:WaitForChild("ControlRework").F_Katsuo
local v_Katsuo = FX:WaitForChild("ControlRework").V_Katsuo
local Dome = require(game.ReplicatedStorage.EffectContainer:WaitForChild("ControlRework"):WaitForChild("Domain"):WaitForChild("Dome"))
local v = { "Left", "Right" }
local random = Random.new()
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyPreparedVState(state)
	if state.Destroyed then
		return
	end

	state.Destroyed = true
	state.GroundCubes:Destroy()
	state.IndicatorBursts:Destroy()
end

local function NewPreparedVState()
	local random2 = Random.new()
	local v3 = {}

	for i = 1, 10 do
		local v4 = i / 10

		for _ = 1, math.max(7, (math.floor(v4 * 16))) do
			local v6 = math.max(v4 * 1.5, 0.35) - random2:NextNumber(0, 0.05)
			table.insert(v3, {
				Template = ObjectClass.TemplateModel,
				Prepare = function(instance)
					instance.Main.BodyPattern:Destroy()
					instance.Main.Bolts:Destroy()
					instance.Main.Outline:Destroy()
					instance:ScaleTo(v6)
				end
			})
		end
	end

	local v4 = {}

	for i = 1, 12 do
		local v5 = i % 4 == 0 and 2 or 1
		table.insert(v4, {
			Template = ObjectClass.TemplateModel,
			Prepare = function(instance)
				instance:ScaleTo(v5)
			end
		})
		local v7 = v5
		table.insert(v4, {
			Template = v_Katsuo.PushExplosionFast,
			Prepare = function(instance)
				instance:ScaleTo(v7 * 3)
				VisualHelper:ThinEmitBursts(instance)
			end
		})
		table.insert(v4, c_Katsuo.BallNeon)
	end

	return {
		GroundCubes = PrepareClonedInstances.new(v3),
		IndicatorBursts = PrepareClonedInstances.new(v4),
		Destroyed = false
	}
end

local function BeginPreparingVState(p)
	local ownerName = VisualHelper:OwnerName(p)
	local v3 = v2[ownerName]

	if v3 and not v3.Destroyed then
		v3.Destroyed = true
		v3.GroundCubes:Destroy()
		v3.IndicatorBursts:Destroy()
	end

	local newPreparedVState = NewPreparedVState()
	v2[ownerName] = newPreparedVState
	return newPreparedVState
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClaimPreparedVState(player)
	local ownerName = VisualHelper:OwnerName(player)
	local v3 = v2[ownerName]
	v2[ownerName] = nil
	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DiscardPreparedVState(player, state)
	local ownerName = VisualHelper:OwnerName(player)

	if v2[ownerName] ~= state then
		return
	end

	v2[ownerName] = nil
	DestroyPreparedVState(state) -- equivalent call inferred; original call site unknown
end

local function Debris(instance, duration: number)
	if not instance then
		return
	end

	if duration and duration > 0 then
		return task.delay(duration, instance.Destroy, instance)
	end

	instance:Destroy()
end

local function ComputeTrailWorldCFrame(vector2: Vector3, p: number, p2: number)
	return CFrame.new(vector2 + Vector3.new(0, math.noise(p * 0.01, p2 * 0.1) * 17)) * CFrame.Angles(0, math.rad(p), 0) * CFrame.new(
		0,
		0,
		p2
	)
end

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local function EmitAuraExplosion(cframe: CFrame, p: number, player)
	local clone = v_Katsuo.AuraExplosion:Clone()
	clone:ScaleTo(p)
	VisualHelper:ThinEmitBursts(clone)
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
	clone.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)
	local pointLight = clone.Main.PointLight
	pointLight.Enabled = true
	VisualHelper:Tween(pointLight, TweenInfo.new(0.3), {
		Brightness = 0
	})

	if not MathHelper:GroundRayCast(cframe) then
		clone.Main.SmokeRotation:Destroy()
	end

	for i, child in clone.Main.Layers:GetChildren() do
		child.Orientation *= 1.5
		local beam = child.Beam
		beam.Enabled = true
		local number = random:NextNumber(0.17, 0.25)
		VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
			Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
		})
		VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, child in clone.Main.CircleWinds:GetChildren() do
		local beam = child.Beam
		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:EmitAll(clone)

	if not clone then
		return
	end

	task.delay(2, clone.Destroy, clone)
end

local function EmitFloor(cFrame: CFrame, player)
	local clone = v_Katsuo.FloorSpawnEnd:Clone()
	clone.CFrame = cFrame
	VisualHelper:ThinEmitBursts(clone)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	clone.PointLight.Enabled = true
	VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Brightness = 0
	})

	if not clone then
		return
	end

	task.delay(2.15, clone.Destroy, clone)
end

local function DarkSlash(cFrame: CFrame, value: number?, flag: boolean?, value2: number?, player)
	local clone = v_Katsuo.DarkSlash:Clone()
	clone:ScaleTo(value2 or 1.65)
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, workspace.Terrain, player, "ControlFruitVFXColor")
	VisualHelper:Tween(slash.Winds, TweenInfo.new(0.17, Enum.EasingStyle.Sine), {
		Orientation = createVector(0, 360, 0)
	})

	for _, child in slash.Winds:GetChildren() do
		child.Beam.Enabled = true
		VisualHelper:Tween(child.Beam, TweenInfo.new(0.17, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, emitter in slash.Slash:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Rotation = NumberRange.new(value or 0)
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

	VisualHelper:Tween(slashBeam, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Orientation = slashBeam.Orientation + createVector(0, 180, 0)
	})

	for _, child in slashBeam.Beams:GetChildren() do
		child.Enabled = true
		child.Width0 *= 2
		child.Width1 *= 2
		VisualHelper:Tween(child, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:Tween(slash.PointLight, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Brightness = 0
	})

	if slash then
		task.delay(2, slash.Destroy, slash)
	end

	local staticSlash = slash.StaticSlash
	staticSlash.Beam.Enabled = true
	task.delay(0.025, function()
		staticSlash:Destroy()
	end)
	return slash
end

local function StormBeamPattern(cFrame: CFrame, value: number?, player)
	cameraShaker:Shake("Pilar Hard")
	local clone = z_Katsuo.StormBeamPattern:Clone()
	clone:ScaleTo(clone:GetScale() * 0.615)
	clone:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")

	for _, attachment in clone.Main:GetChildren() do
		if not attachment:IsA("Attachment") then
			continue
		end

		local beam = attachment.Beam
		local colorSequence = ColorSequence.new(Color3.fromRGB(135, 65, 255))

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
		end

		beam.Color = colorSequence
		beam.Enabled = true
		VisualHelper:Tween(attachment, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			Orientation = attachment.Orientation + createVector(0, 520, 0)
		})
		VisualHelper:Tween(beam, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			Brightness = 0,
			Width0 = beam.Width0 * 0.5,
			Width1 = beam.Width1 * 0.5
		})
	end

	VisualHelper:TweenScale(clone, TweenInfo.new(0.8, Enum.EasingStyle.Sine), clone:GetScale() + (value or 1.75))

	if not clone then
		return
	end

	task.delay(1, clone.Destroy, clone)
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		Instance.new("Folder", player.Player).Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding or holding.Value) then
			return
		end

		local roomFolder = player.RoomFolder

		if not roomFolder then
			return
		end

		local dome = Dome({
			Stage = "FromPlayer",
			Player = player.Player
		})

		if dome then
			dome:SetMaxTransparency(0.5)
			dome:UpdateColor(Color3.fromRGB(167, 79, 255), createVector(0.55, 0.2, 1), 1)
		end

		local waitScheduler = Util.WaitScheduler.new()
		local position = roomFolder:GetAttribute("CFrame").Position
		local character = player.Character
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local _ = humanoidRootPart.CFrame
		local player2 = player.Player
		Util.Sound:Play("DomanExpansion_Activate_01", humanoidRootPart)
		local v4 = Util.Sound:Play("DomainExpansion_Held_Normal_01", humanoidRootPart)
		task.delay(0.1, function()
			TweenService:Create(v4, TweenInfo.new(0.6), {
				Volume = 1
			}):Play()
		end)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v5 = roomFolder:GetAttribute("Radius") * 0.8
		local clones = {}
		local part = Instance.new("Part")
		part.Name = "ControlVIndicators" .. VisualHelper:OwnerName(player2)
		part.CFrame = CFrame.identity
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		local ownerName = VisualHelper:OwnerName(player.Player)
		local v6 = v2[ownerName]

		if v6 and not v6.Destroyed then
			v6.Destroyed = true
			v6.GroundCubes:Destroy()
			v6.IndicatorBursts:Destroy()
		end

		local newPreparedVState = NewPreparedVState()
		v2[ownerName] = newPreparedVState
		part.Destroying:Once(function()
			DiscardPreparedVState(player.Player, newPreparedVState) -- equivalent call inferred; original call site unknown
		end)

		for i = 1, 12 do
			local v8 = i % 2 == 0
			local v9 = v8 and random:NextNumber(0.38, 0.5) or random:NextNumber(0.88, 1)
			local position2 = (CFrame.new(position) * CFrame.Angles(0, i / 12 * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-v5 * v9
			)).Position
			local v12 = { workspace.Map }
			local rayCast = MathHelper:RayCast(
				position2,
				createVector(-0, -50, -0),
				v12,
				Enum.RaycastFilterType.Include
			)

			if not rayCast then
				continue
			end

			local clone = v_Katsuo.Vault.Indicator:Clone()
			clone.WorldCFrame = CFrame.new(rayCast.Position + createVector(0, 0.1, 0))
			clone:SetAttribute("OnTop", v8)
			Util.SetParentOverrideWithColor(clone, part, player.Player, "ControlFruitVFXColor")
			local billboardGui = clone.Icon.BillboardGui
			billboardGui.Image.Size = UDim2.new()
			task.delay(0.0625 + math.random(3) * 0.065, function()
				VisualHelper:Tween(billboardGui.Image, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
					Size = UDim2.fromScale(1, 1)
				})
				VisualHelper:EmitAll(clone.Emit)
			end)
			table.insert(clones, clone)
		end

		part.Parent = workspace._WorldOrigin
		local clones2 = {}

		for _, v8 in v do
			local clone = v_Katsuo.DaggerSpiral:Clone()
			clone.Size = createVector(0, 0, 0)
			clone.Light.PointLight.Enabled = false
			Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			local weld = clone.Weld
			weld.Part0 = character[v8 .. "Hand"]

			if v8 == "Right" then
				weld.C1 = CFrame.new(0, -weld.C1.Position.Y, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			end

			table.insert(clones2, clone)
		end

		waitScheduler:wait(0.05)

		for _, v8 in clones2 do
			v8.Light.PointLight.Enabled = true
			VisualHelper:Tween(v8, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = domain_Katsuo.DaggerSpiral.Size
			})
			VisualHelper:EmitAll(v8.Init)
			local v9 = v8
			task.delay(0.03, function()
				local windStorm = v9.Charge.WindStorm
				VisualHelper:Tween(
					windStorm,
					TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
					{
						Orientation = windStorm.Orientation - createVector(0, 360, 0)
					}
				)
				local storm = v9.Charge.Storm
				VisualHelper:Tween(storm, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
					Orientation = storm.Orientation - createVector(0, 360, 0)
				})
				VisualHelper:SetEnableAll(v9.Charge, true)
			end)
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			for _, v8 in clones2 do
				for _, child in v8.Surfaces:GetChildren() do
					for _, child2 in child:GetChildren() do
						child2.Rotation += child2:GetAttribute("RotationSpeed") * 12.5 * dt
					end
				end
			end
		end)
		cameraShaker:Shake("Fast")
		local clone = domain_Katsuo.ShaderScreen:Clone()
		clone.Name = "DomainVShaderScreen"
		clone.Image.ImageTransparency = 1
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local v8

		if player.Player == game.Players.LocalPlayer then
			v8 = player.Player:FindFirstChild("PlayerGui") or model
		else
			v8 = model
		end

		setParentOverrideWithColor(clone, v8, player.Player, "ControlFruitVFXColor")
		local image = clone.Image
		local player4 = player.Player
		local color = Color3.fromRGB(191, 88, 255)

		if typeof(player4) == "Instance" and player4:IsA("Player") and player4.Parent then
			color = Util.WrapColor3Constructor(color, player4, "ControlFruitVFXColor")
		end

		image.ImageColor3 = color
		VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.85
		})
		EmitFloor(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), player.Player)
		cameraShaker:Shake("Fast Hard")
		local clone2 = v_Katsuo.UpStarCollide:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 5, 0)
		Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		VisualHelper:EmitAll(clone2)

		if clone2 then
			task.delay(1.5, clone2.Destroy, clone2)
		end

		local trails = clone2.Trails
		VisualHelper:Tween(trails, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Orientation = trails.Orientation + createVector(0, 560, 0)
		})

		for _, child in trails:GetChildren() do
			VisualHelper:Tween(child, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
				Position = createVector(0, 0, 0)
			})
		end

		EmitFloor(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), player.Player)
		cameraShaker:Shake("Fast Hard")
		waitScheduler:wait(0.05)
		EmitFloor(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), player.Player)
		waitScheduler:wait(0.1)
		heartbeatConnection:Disconnect()

		for _, v9 in clones2 do
			for _, weld in v9:GetChildren() do
				if weld:IsA("Weld") or weld.Name == "Init" or weld.Name == "GroundPart" then
					continue
				end

				weld:Destroy()
			end

			VisualHelper:EmitAll(v9.Init)

			if v9 then
				task.delay(1, v9.Destroy, v9)
			end
		end

		local clone3 = v_Katsuo.FloorHandleBase:Clone()
		VisualHelper:CapEmitterRates(clone3, 15)
		clone3.Main.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone3, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		local init = clone3.Main.Init
		local explosionSmash = clone3.Main.ExplosionSmash
		local clone4 = v_Katsuo.FloorHandle:Clone()
		VisualHelper:CapEmitterRates(clone4, 15, true)
		clone4:PivotTo(CFrame.new(humanoidRootPart.Position - createVector(0, 2.8, 0)))
		Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		local v9 = 0.15
		clone4:ScaleTo(0.45)

		local function ScaleHandlesTo(p: number)
			clone3:ScaleTo(p * 1.2)
			init.Position = createVector(0, 5, 0)

			if not explosionSmash then
				return
			end

			explosionSmash.Position = createVector(0, 2.2, 0)

			if p < 0.6 then
				return
			end

			VisualHelper:TweenScale(clone4, TweenInfo.new(0.17, Enum.EasingStyle.Back), 1)
			EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 6, player.Player)
			StormBeamPattern(humanoidRootPart.CFrame, nil, player.Player)
			VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
				FieldOfView = 72
			})

			if MathHelper:GroundRayCast(character) then
				local position2 = humanoidRootPart.Position
				local v11 = { workspace.Terrain }
				Rocks:CircleRocks(position2, 12, 37.5, createVector(7.5, 1.25, 2.5), 0, v11)
				local position3 = humanoidRootPart.Position
				local v13 = { workspace.Terrain }
				Rocks:CircleRocks(position3, 8, 45, createVector(5.5, 1.5, 5.5), 0, v13)
				local position4 = humanoidRootPart.Position
				local v15 = { workspace.Terrain }
				Rocks:CircleRocks(position4, 6, 55.00000000000001, createVector(5.5, 1.5, 4), 0, v15)
			end

			for _, v10 in { explosionSmash.CircleBeamFlash.Beam1, explosionSmash.CircleBeamFlash.Beam2 } do
				v10.Enabled = true
				VisualHelper:Tween(v10, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			VisualHelper:Tween(explosionSmash.Winds, TweenInfo.new(0.45, Enum.EasingStyle.Linear), {
				Orientation = explosionSmash.Winds.Orientation + createVector(0, 750, 0)
			})

			for _, child in explosionSmash.Winds:GetChildren() do
				local beamMain = child.BeamMain
				beamMain.Enabled = true
				VisualHelper:Tween(beamMain, TweenInfo.new(0.35 + math.random(3) * 0.055, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			local v10 = explosionSmash

			if v10 then
				task.delay(1, v10.Destroy, v10)
			end

			explosionSmash = nil
		end

		ScaleHandlesTo(v9)
		VisualHelper:SetEnableAll(clone3.Main, true, true)
		VisualHelper:SetEnableAll(init.Sinal, true)
		VisualHelper:EmitAll(init)
		VisualHelper:SetEnableAll(clone4, true)

		if not MathHelper:GroundRayCast(character) then
			clone4.Main.Main:Destroy()
		end

		local main = clone4.Main
		local model2 = Instance.new("Model", workspace.Terrain)
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.Adornee = model2
		highlight.Parent = model2

		local function Pulse()
			local clone5 = v_Katsuo.Ball:Clone()
			clone5.CFrame = init.Sinal.WorldCFrame
			clone5.Size = createVector(15, 15, 15) * v9
			Util.SetParentOverrideWithColor(clone5, model2, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Size = createVector(55, 55, 55) * v9,
				Transparency = 1
			})

			if clone5 then
				task.delay(0.1, clone5.Destroy, clone5)
			end

			VisualHelper:EmitAll(init.Pulse)
		end

		Pulse()
		VisualHelper:Tween(main.Beams, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = main.Beams.Orientation - createVector(0, 360, 0)
		})
		local circleBeam = main.CircleBeam
		VisualHelper:Tween(circleBeam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = circleBeam.Position + createVector(0, 17, 0)
		})

		for _, child in circleBeam.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = 0,
				Width1 = 0
			})
		end

		for _, child in main.AirBeams:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			local brightness = beam.Brightness * 1.15
			beam.Brightness = 0
			VisualHelper:Tween(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
			VisualHelper:Tween(
				child,
				TweenInfo.new(random:NextNumber(0.2, 0.4), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = child.Orientation + Vector3.new(0, math.sign(beam.TextureSpeed) * 360)
				}
			)
		end

		for i, attachment in clone4.StormBeamPattern.Main:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end

			local v10 = i % 2 == 0 and 1 or -1
			local beam = attachment.Beam
			beam.Width0 *= 0.5
			beam.Width1 *= 0.5
			beam.Enabled = true
			local brightness = beam.Brightness * 0.2
			beam.Brightness = 0
			VisualHelper:Tween(
				attachment,
				TweenInfo.new(random:NextNumber(0.6, 1), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = attachment.Orientation + Vector3.new(0, 360 * v10)
				}
			)
			VisualHelper:Tween(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
		end

		VisualHelper:Tween(clone4.Ball.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(clone4.Ball.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Scale = clone4.Ball.Mesh.Scale * 1.3
		})
		local stormBall = clone4.StormBall
		stormBall.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 5, 0)
		VisualHelper:Tween(stormBall, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			CFrame = stormBall.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
		})
		VisualHelper:Tween(stormBall.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(stormBall.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Scale = stormBall.Mesh.Scale * 2.5
		})

		if stormBall then
			task.delay(1, stormBall.Destroy, stormBall)
		end

		EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 6, player.Player)
		StormBeamPattern(humanoidRootPart.CFrame, nil, player.Player)
		VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			FieldOfView = 65
		})
		local v10 = HexsStormClass.new(character.Head, true)
		v10.YFactor = 10

		for i = -1, 1, 0.2 do
			v10:AddHex("Dagger", i, random:NextNumber(55, 60), i * 360, random:NextNumber(50, 250)).Instance.Size *= random:NextNumber(
				2,
				3.25
			)
		end

		local position2 = humanoidRootPart.Position
		local v11 = {}

		for i = 1, 4 do
			local angle = i * 90 + random:NextNumber(-30, 30)
			local number = random:NextNumber(40, 55)
			local clone5 = v_Katsuo.Vault.NeonTrail:Clone()
			clone5.WorldCFrame = ComputeTrailWorldCFrame(position2, angle, number)
			Util.SetParentOverrideWithColor(clone5, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			v11[clone5] = {
				Angle = angle,
				Area = number,
				Speed = random:NextNumber(400, 750) * (i % 2 == 0 and -1 or 1),
				Center = position2 + Vector3.new(0, i / 4 * 30)
			}
		end

		local clone5 = v_Katsuo.Vault.RockSmoke:Clone()
		Util.SetParentOverrideWithColor(clone5, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		local v12 = {
			Rate = 8,
			AnimationSpeed = 1.5,
			MinRange = 35,
			MaxRange = 42,
			Templates = z_Katsuo.Rocks:GetChildren(),
			RockSmoke = clone5
		}
		local clone6 = v_Katsuo.CameraEffects:Clone()
		Util.SetParentOverrideWithColor(clone6, currentCamera, player.Player, "ControlFruitVFXColor")

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(clone6, true)
			VisualHelper:EmitAll(clone6)
		end

		local total = 0
		local total2 = 0
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			clone6.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)

			if total2 < 0.06 then
				return
			end

			total2 = 0
			local v13 = 0.1 + math.random(5) * 0.03
			local worldPosition2 = init.WorldPosition + Vector3.new(
				math.random(-70, 70),
				math.random(-70, 70),
				math.random(-70, 70)
			)
			local worldPosition = init.WorldPosition
			local clone7 = v_Katsuo.Vault.HexTrail:Clone()
			Util.SetParentOverrideWithColor(clone7, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			clone7.WorldPosition = worldPosition2
			local v15 = v13 + 0.5

			if clone7 then
				if v15 and v15 > 0 then
					task.delay(v15, clone7.Destroy, clone7)
				else
					clone7:Destroy()
				end
			end

			local magnitude = (worldPosition2 - worldPosition).Magnitude
			local cframe = CFrame.lookAt(worldPosition2, worldPosition)
			VisualHelper:MoveAlongBezierTrail(
				clone7,
				v13,
				worldPosition2,
				cframe * CFrame.new(math.random(-105, 105), math.random(-105, 105), -magnitude * 0.25).Position,
				cframe * CFrame.new(math.random(-105, 105), math.random(-105, 105), -magnitude * 0.75).Position,
				worldPosition
			)
		end)
		local total3 = 0

		for k in v10.Data do
			VisualHelper:Tween(k, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Position = humanoidRootPart.Position,
				Size = createVector(0, 0, 0),
				Orientation = k.Orientation + Vector3.new(math.random(360), math.random(360), math.random(360))
			})
		end

		EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 4.6, player.Player)
		cameraShaker:Shake("Fast Hard")
		clone4:ScaleTo(clone4:GetScale() * 0.7)

		if MathHelper:GroundRayCast(character) then
			Rocks:JoinRocks(
				CFrame.new(humanoidRootPart.Position),
				30,
				50 * v9,
				v9 * 1.5,
				0.1,
				1.6,
				{ workspace.Terrain }
			)
		end

		Pulse()

		for _, v13 in {
			1.85,
			0.6,
			2.5,
			0.7,
			1.3,
			0.5,
			0.7
		} do
			VisualHelper:ObjectScaleTo(init.Sinal, v13 + (1 - v9) * 0.22 + 0.001)
			waitScheduler:wait(0.003)
		end

		if MathHelper:GroundRayCast(character) then
			Rocks:JoinRocks(
				CFrame.new(humanoidRootPart.Position),
				20,
				v9 * 30,
				v9 * 1.5,
				0.1,
				1.6,
				{ workspace.Terrain }
			)
		end

		EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 4.6, player.Player)
		StormBeamPattern(humanoidRootPart.CFrame, nil, player.Player)
		VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			FieldOfView = 70
		})
		cameraShaker:Shake("Fast")
		local flag = false

		while holding and holding.Value or total < 0.06 do
			local v13 = RunService.RenderStepped:Wait()
			total += v13
			total2 += v13

			if flag then
				clone6.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)

				for k, v14 in v11 do
					v14.Angle += v14.Speed * v13
					k.WorldCFrame = ComputeTrailWorldCFrame(v14.Center, v14.Angle, v14.Area * v9)
				end

				v10:Update(v13)

				if not (total2 < 1 / v12.Rate) then
					total2 = 0
					cameraShaker:Shake("Fast")
					local clone7 = v_Katsuo.Ball:Clone()
					clone7.CFrame = init.Sinal.WorldCFrame
					clone7.Size = createVector(15, 15, 15) * v9
					Util.SetParentOverrideWithColor(clone7, model2, player.Player, "ControlFruitVFXColor")
					VisualHelper:Tween(clone7, TweenInfo.new(0.085, Enum.EasingStyle.Sine), {
						Size = createVector(55, 55, 55) * v9,
						Transparency = 1
					})

					if clone7 then
						task.delay(0.085, clone7.Destroy, clone7)
					end

					total3 += 25
					local v14 = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(total3 + math.random(-180, 180)), 0) * CFrame.new(
						0,
						0,
						math.random(v12.MinRange, v12.MaxRange) * v9
					)
					local rayCast = MathHelper:RayCast(
						v14.Position,
						v14.UpVector * -25,
						{ workspace.Map },
						Enum.RaycastFilterType.Include
					)

					if rayCast then
						local cframe = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal)
						local clone8 = v12.Templates[math.random(#v12.Templates)]:Clone()
						local primaryPart = clone8.PrimaryPart
						local cframe2 = CFrame.Angles(
							-1.5707963267948966,
							math.rad((math.random(360))),
							(math.rad((math.random(-10, 10))))
						)
						local v15 = primaryPart.Size.Y * 1.2
						clone8:ScaleTo(0.3 + math.random() * 1.5)
						clone8:PivotTo(cframe * CFrame.new(0, 0, v15) * cframe2)
						primaryPart.Lines:Destroy()
						primaryPart.Lines2:Destroy()
						local outline = primaryPart.Outline
						local player5 = player.Player
						local color2 = Color3.fromRGB(141, 126, 255)

						if typeof(player5) == "Instance" and player5:IsA("Player") and player5.Parent then
							color2 = Util.WrapColor3Constructor(color2, player5, "ControlFruitVFXColor")
						end

						outline.Color = color2

						for _, decal in primaryPart.Gradient:GetChildren() do
							if not decal:IsA("Decal") then
								continue
							end

							local player6 = player.Player
							local color3 = Color3.fromRGB(354, 270, 2255)

							if typeof(player6) == "Instance" and player6:IsA("Player") and player6.Parent then
								color3 = Util.WrapColor3Constructor(color3, player6, "ControlFruitVFXColor")
							end

							decal.Color3 = color3
							decal.Transparency *= 1.1
						end

						clone8.Parent = workspace.Terrain
						local v16 = primaryPart.Size.Y - math.random(1, 2)
						local v17 = cframe2 * CFrame.Angles(0, 0.6108652381980153, 0.4363323129985824)
						VisualHelper:Tween(
							primaryPart,
							TweenInfo.new(0.5 / v12.AnimationSpeed, Enum.EasingStyle.Linear),
							{
								CFrame = cframe * CFrame.new(0, 0, -v16) * v17
							}
						)
						task.delay(0.15 / v12.AnimationSpeed, function()
							v12.RockSmoke.WorldCFrame = cframe
							VisualHelper:EmitAll(v12.RockSmoke)
							v16 += math.random(5, 15)
							v17 *= CFrame.Angles(0, 0.6108652381980153, 0.3490658503988659)
							VisualHelper:Tween(
								primaryPart,
								TweenInfo.new(0.25 / v12.AnimationSpeed, Enum.EasingStyle.Linear),
								{
									CFrame = cframe * CFrame.new(0, 0, -v16) * v17
								}
							)
							task.wait(0.25 / v12.AnimationSpeed)
							v16 += math.random(8, 13)
							v17 *= CFrame.Angles(0, 0.6108652381980153, 0.3490658503988659)
							VisualHelper:Tween(
								primaryPart,
								TweenInfo.new(1 / v12.AnimationSpeed, Enum.EasingStyle.Linear),
								{
									CFrame = cframe * CFrame.new(0, 0, -v16) * v17
								}
							)
							VisualHelper:TweenScale(
								clone8,
								TweenInfo.new(
									0.5 / v12.AnimationSpeed,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out,
									0,
									false,
									0.5 / v12.AnimationSpeed
								),
								0.01
							)
							task.wait(1 / v12.AnimationSpeed)
							clone8:Destroy()
						end)
					end
				end
			elseif character:FindFirstChild("ControlVUltTransition") then
				flag = true
				DiscardPreparedVState(player.Player, newPreparedVState) -- equivalent call inferred; original call site unknown

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
					Util.Sound:Play("DomainExpansion_Held_IncreasePower_Activation_01", humanoidRootPart)
					v4 = Util.Sound:Play("DomainExpansion_Held_Strong_01", humanoidRootPart)
				end

				v9 = 1
				ScaleHandlesTo(v9)
			end
		end

		if v4 then
			Util.Sound:FadeOut(v4, 0.2)
		end

		for k in v11 do
			k:Destroy()
			v11[k] = nil
		end

		renderSteppedConnection:Disconnect()
		local renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			clone6.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)

			if total2 < 0.15 then
				return
			end

			total2 = 0
			cameraShaker:Shake("Fast Hard")
		end)
		v10:Destroy()
		v12.RockSmoke:Destroy()
		clone4:Destroy()
		model2:Destroy()
		init.Sinal:Destroy()
		VisualHelper:SetEnableAll(clone3.Main, false, true)

		if clone3 then
			task.delay(3, clone3.Destroy, clone3)
		end

		task.wait(2)
		clone6:Destroy()
		renderSteppedConnection2:Disconnect()
		Util.Debris:AddItem(model, 10)
		local child = workspace._WorldOrigin:FindFirstChild("ControlVIndicators" .. VisualHelper:OwnerName(player2))

		if not child then
			local v13 = not character:GetAttribute("RunningControlUltimate") and Dome({
				Stage = "FromPlayer",
				Player = player.Player
			})

			if v13 then
				v13:SetMaxTransparency()
				v13:UpdateColor(nil, nil, 1)
			end

			for _, v14 in clones do
				if not v14.Parent then
					continue
				end

				VisualHelper:Tween(
					v14.Icon.BillboardGui.Image,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = UDim2.new()
					}
				)

				if v14 then
					task.delay(0.5, v14.Destroy, v14)
				end
			end
		end

		if child then
			task.delay(7, child.Destroy, child)
		end

		if clone and clone.Parent then
			VisualHelper:Tween(clone.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				ImageTransparency = 1
			})

			if clone then
				task.delay(0.5, clone.Destroy, clone)
			end
		end
	elseif stage == 2 then
		local player2 = player.Player
		local character = player.Character
		local root = player.Root
		local startCFrame = player.StartCFrame
		local roomFolder = player.RoomFolder

		if not roomFolder then
			return
		end

		local v3 = currentCamera
		local flag

		if player.Player == game.Players.LocalPlayer or game.Players.LocalPlayer.Character == player.Target then
			flag = true
		else
			v3 = Instance.new("Camera")
			flag = false
		end

		local position = roomFolder:GetAttribute("CFrame").Position
		local v4 = roomFolder:GetAttribute("Radius") * 2
		local v5 = v4 / 2

		local function OutOfLimit(vector2: Vector3)
			if not roomFolder then
				return
			end

			local position2 = position
			local magnitude = (vector2 - Vector3.new(position2.X, vector2.Y, position2.Z)).Magnitude
			return v4 / 2 < magnitude
		end

		local v6 = ClaimPreparedVState(player2) or NewPreparedVState()
		local child = workspace._WorldOrigin:WaitForChild("ControlVIndicators" .. VisualHelper:OwnerName(player2), 2)

		if child then
			Util.Debris:AddItem(child, 10)
			child.Destroying:Once(function()
				DestroyPreparedVState(v6) -- equivalent call inferred; original call site unknown
			end)
			local children = child:GetChildren()
			local _ = v5 * 0.8
			local clone = v_Katsuo.Floor:Clone()
			VisualHelper:CapEmitterRates(clone, 10, true)
			clone.Position = root.Position
			Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			Util.Sound:Play("DomainExpansion_InitialDash_01", root)
			local waitScheduler = Util.WaitScheduler.new()

			for i = 1, 10 do
				local v7 = i / 10
				local v8 = 205 * v7
				local v9 = math.max(7, (math.floor(v7 * 16)))

				for i2 = 1, v9 do
					if v6.Destroyed then
						return
					end

					local v10 = v6.GroundCubes:Take()
					local v11 = i2 / v9 * 3.141592653589793 * 2
					local v12 = CFrame.new(startCFrame.Position) * CFrame.Angles(
						0,
						v11 + math.rad((math.random(-40, 40))),
						0
					) * CFrame.new(0, 10, -v8)
					local position2 = v12.Position
					local v13

					if roomFolder then
						local magnitude = (position2 - Vector3.new(position.X, position2.Y, position.Z)).Magnitude
						v13 = v4 / 2 < magnitude
					end

					if v13 then
						v10:Destroy()
					else
						local position3 = v12.Position
						local v15 = { workspace.Map }
						local rayCast = MathHelper:RayCast(
							position3,
							createVector(-0, -20, -0),
							v15,
							Enum.RaycastFilterType.Include
						)

						if rayCast and not (rayCast.Normal.Y < 0.8) then
							local v16 = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
								math.rad((math.random(-2, 2))),
								math.rad((math.random(-5, 5))),
								0
							)
							math.random()
							local main = v10.Main
							local v17 = v10.Main.Size.Y / 2
							v10:PivotTo(v16 * CFrame.new(0, 0, v17 + 3))
							Util.SetParentOverrideWithColor(
								v10,
								workspace.Terrain,
								player.Player,
								"ControlFruitVFXColor"
							)
							ObjectClass:ApplyModelColor(
								v10,
								RecolorControlColor(player.Player, Color3.fromRGB(127, 76, 255))
							)
							local v18 = i * 0.05 + 0.125 + (0.2 + math.random() * 0.25)
							local tweenInfo = TweenInfo.new(
								0.325,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.Out,
								0,
								true
							)
							local v19 = v10
							task.delay(v18, function()
								if not v19.Parent then
									return
								end

								VisualHelper:Tween(main, tweenInfo, {
									CFrame = v16 * CFrame.new(0, 0, -v17 * 0.7)
								})
							end)
							local v24 = (tweenInfo.Time + v18) * 2 + 0.5

							if v10 then
								if v24 and v24 > 0 then
									task.delay(v24, v10.Destroy, v10)
								else
									v10:Destroy()
								end
							end
						else
							v10:Destroy()
						end
					end
				end

				waitScheduler:wait(0.01)
			end

			v6.GroundCubes:Destroy()
			local v7 = {}
			task.delay(0.45, function()
				local DELAY_DURATION = 0.5
				EmitAuraExplosion(root.CFrame * CFrame.new(0, -2.8, 0), 18, player.Player)
				local waitScheduler2 = Util.WaitScheduler.new()

				for k, v8 in children do
					if v6.Destroyed then
						return
					end

					local clone2, clone3, v9

					if k <= 12 then
						clone2 = v6.IndicatorBursts:Take()
						clone3 = v6.IndicatorBursts:Take()
						v9 = v6.IndicatorBursts:Take()
					end

					if v8:FindFirstChild("Icon") then
						VisualHelper:Tween(
							v8.Icon.BillboardGui.Image,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Size = UDim2.new()
							}
						)

						if v8 then
							task.delay(DELAY_DURATION, v8.Destroy, v8)
						end

						local v10 = k % 4 == 0 and 2 or 1

						if not clone2 then
							clone2 = ObjectClass.TemplateModel:Clone()
							clone2:ScaleTo(v10)
						end

						local v11 = ObjectClass.new(player2, v8.WorldCFrame, nil, nil, clone2)
						v11.UltimateObject = true
						v11:SetLayout((`{v10}x{v10}`))
						v11:SwitchMode("Planing", true)
						v11:ToggleBodyPattern(true)
						v11:RemoveDragable()
						v11.Model.Main.CanQuery = false
						v11.CanSlice = false
						local onTop = v8:GetAttribute("OnTop")
						v11:PivotTo(v8.WorldCFrame * CFrame.new(0, -v11:GetSize().Y / 2 - 1, 0))
						local v12 = v11:GetPivot() * CFrame.new(
							0,
							v11:GetSize().Y / 2 + v5 * (onTop and random:NextNumber(0.5, 0.75) or 0.25),
							0
						) * CFrame.Angles(0, math.rad((math.random(360))), (math.rad((math.random(-25, 25)))))
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
						VisualHelper:Tween(v11.Model.Main, tweenInfo, {
							CFrame = v12
						})
						VisualHelper:Tween(v11.Model.Main.Outline, tweenInfo, {
							CFrame = v12
						})
						task.delay(tweenInfo.Time, function()
							v11.PlaningCFrame = v12
						end)
						ObjectClass:ApplyModelColor(
							v11.Model,
							RecolorControlColor(player.Player, Color3.fromRGB(127, 76, 255))
						)
						cameraShaker:Shake("Pilar Hard")
						local cFrame = v8.WorldCFrame * CFrame.new(0, 0.5, 0)

						if not clone3 then
							clone3 = v_Katsuo.PushExplosionFast:Clone()
							clone3:ScaleTo(v10 * 3)
							VisualHelper:ThinEmitBursts(clone3)
						end

						clone3:PivotTo(cFrame)
						Util.SetParentOverrideWithColor(
							clone3,
							workspace.Terrain,
							player.Player,
							"ControlFruitVFXColor"
						)
						VisualHelper:EmitAll(clone3)

						if clone3 then
							task.delay(3, clone3.Destroy, clone3)
						end

						local v16 = v9 or c_Katsuo.BallNeon:Clone()
						v16.CFrame = cFrame
						v16.Transparency = 0.95
						v16.Color = Color3.fromRGB(180, 94, 255)
						v16.Size = createVector(1, 1, 1) * (clone3.Main.Size.Y * 0.65)
						v16.Parent = workspace.Terrain
						VisualHelper:Tween(v16, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Size = v16.Size * 4,
							Transparency = 1
						})

						if v16 then
							task.delay(0.2, v16.Destroy, v16)
						end

						local beams = clone3.Main.Beams
						VisualHelper:Tween(beams, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							WorldCFrame = beams.WorldCFrame * CFrame.Angles(0, 3.141592653589793, 0)
						})

						for _, beam in beams:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							VisualHelper:Tween(
								beam,
								TweenInfo.new(0.15 + math.random(3) * 0.025, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						if beams then
							task.delay(DELAY_DURATION, beams.Destroy, beams)
						end

						local _ = clone3.Main.Size.X / 2
						local airMeshHuge = clone3.AirMeshHuge
						local superFlash = clone3.SuperFlash
						local flash = clone3.Flash
						local airHard = clone3.AirHard
						VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Scale = airMeshHuge.Mesh.Scale * 1.9
						})
						VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						})

						if airMeshHuge then
							task.delay(0.3, airMeshHuge.Destroy, airMeshHuge)
						end

						VisualHelper:Tween(airHard, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
							CFrame = airHard.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
						})
						VisualHelper:Tween(airHard.Decal, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
							Transparency = 1
						})
						VisualHelper:Tween(airHard.Mesh, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
							Scale = airHard.Mesh.Scale * 2
						})

						if airHard then
							task.delay(DELAY_DURATION, airHard.Destroy, airHard)
						end

						VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						})
						VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Scale = flash.Mesh.Scale * 2.5
						})

						if flash then
							task.delay(0.4, flash.Destroy, flash)
						end

						local scale = superFlash.Mesh.Scale * 2.6
						superFlash.Mesh.Scale /= 2
						VisualHelper:Tween(superFlash, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							CFrame = superFlash.CFrame * CFrame.new(0, -7, 0)
						})
						VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						})
						VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
							Scale = scale
						})

						if superFlash then
							task.delay(0.7, superFlash.Destroy, superFlash)
						end

						table.insert(v7, v11)
						waitScheduler2:wait(0.035)
					else
						if clone2 then
							clone2:Destroy()
						end

						if clone3 then
							clone3:Destroy()
						end

						if v9 then
							v9:Destroy()
						end
					end
				end

				v6.IndicatorBursts:Destroy()
			end)
			local waitScheduler2 = Util.WaitScheduler.new()
			DarkSlash(
				root.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, 3.141592653589793, 0.7853981633974483),
				100,
				true,
				4.5,
				player.Player
			)
			waitScheduler2:wait(0.05)
			StormBeamPattern(root.CFrame, 10, player.Player)
			waitScheduler2:wait(0.1)
			VisualHelper:SetEnableAll(clone, true)
			local cFrame2 = root.CFrame * CFrame.new(0, -2.8, 0)
			EmitAuraExplosion(cFrame2, 11, player.Player)
			waitScheduler2:wait(0.075)
			task.delay(0.2, function()
				EmitAuraExplosion(cFrame2, 18, player.Player)
				VisualHelper:SetEnableAll(clone, false)
				local v9 = clone

				if not v9 then
					return
				end

				task.delay(2, v9.Destroy, v9)
			end)
			StormBeamPattern(root.CFrame, 5, player.Player)
			EmitAuraExplosion(cFrame2, 8.5, player.Player)
			waitScheduler2:wait(0.085)
			EmitFloor(cFrame2, player.Player)

			local function ClearCubes()
				for k, v9 in v7 do
					local v10 = v9
					local v11 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
					task.delay((k - 1) * 0.075, function()
						VisualHelper:TweenScale(v10.Model, v11, 0.01)
						task.wait(v11.Time)
						v10:Destroy()
					end)
				end

				table.clear(v7)
			end

			VisualHelper:Tween(v3, TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {
				FieldOfView = 80
			})
			cameraShaker:Shake("Pilar Hard")
			local rush = PreAnimations:Rush(character, player.StartCFrame, player.Target, player.TeleportCFrame)

			if rush then
				root.CFrame:ToObjectSpace(v3.CFrame)
				root.Anchored = true
				local Players = game:GetService("Players")

				if player2 == Players.LocalPlayer then
					Util.Sound:Play("DomainExpansion_HitSequence_01", player2.PlayerGui)
				else
					Util.Sound:Play("DomainExpansion_HitSequence_01", position)
				end

				local v9 = {
					[rush] = PreAnimations:Unjoint(rush)
				}
				local clone2 = v_Katsuo.ShootWaveMinimal:Clone()
				clone2.Parent = workspace.Terrain
				local clone3 = v_Katsuo.SuperIntense:Clone()
				VisualHelper:CapEmitterRates(clone3, 15, true)
				clone3.Size = createVector(1, 1, 1) * v4
				clone3.CFrame = CFrame.new(position)
				clone3.Parent = workspace.Terrain
				local clone4 = v_Katsuo.FloorBase:Clone()
				clone4:PivotTo(CFrame.new(position + createVector(0, 0.5, 0)))
				clone4:ScaleTo(v4 * 1.3)
				VisualHelper:CapEmitterRates(clone4, 10, true)
				Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player.Player, "ControlFruitVFXColor")
				local trailsStorm = clone4.Main.TrailsStorm
				VisualHelper:Tween(
					trailsStorm,
					TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
					{
						Orientation = trailsStorm.Orientation - createVector(0, 360, 0)
					}
				)
				local clone5 = v_Katsuo.Vault.HexBorder:Clone()
				Util.SetParentOverrideWithColor(clone5, workspace.Terrain, player.Player, "ControlFruitVFXColor")
				VisualHelper:Tween(v3, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					FieldOfView = 67
				})
				local clone6 = v_Katsuo.CameraEffects:Clone()
				Util.SetParentOverrideWithColor(clone6, v3, player.Player, "ControlFruitVFXColor")

				if player.Player == game.Players.LocalPlayer then
					VisualHelper:SetEnableAll(clone6, true)
					VisualHelper:EmitAll(clone6)
				end

				local _, v10 = player.FinalCFrames.RushTeleportCFrame:ToEulerAnglesXYZ()
				local clone7 = v_Katsuo.Vault.CameraSlice:Clone()
				Util.SetParentOverrideWithColor(clone7, clone6, player.Player, "ControlFruitVFXColor")
				local clone8 = domain_Katsuo.RoomShaderScreen:Clone()
				clone8.Back.Visible = true
				clone8.Image.ImageTransparency = 0.87
				local total = 0
				local total2 = 0

				for _, child2 in pairs(clone8:GetChildren()) do
					local player3 = player.Player
					local color = Color3.fromRGB(191, 88, 255)

					if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
						color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
					end

					child2.ImageColor3 = color
				end

				Util.SetParentOverrideWithColor(
					clone8,
					player.Player == game.Players.LocalPlayer and player.Player:FindFirstChild("PlayerGui") or SkillVisuals,
					player.Player,
					"ControlFruitVFXColor"
				)
				local image = clone8.Image
				local imageTransparency = image.ImageTransparency
				VisualHelper:Tween(image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					ImageTransparency = imageTransparency * 0.6
				})
				local v11 = nil
				v3.CameraType = Enum.CameraType.Scriptable
				local model = Instance.new("Model", workspace._WorldOrigin)
				Util.Debris:AddItem(model, 6)
				local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local position2 = CFrame.new(position) * CFrame.Angles(0, v10, 0) * CFrame.new(
						0,
						v5 + math.sin(v10) * v5 * 0.2,
						v5 * (math.abs((math.cos(v10))) * 0.2 + 1.2)
					).Position
					local magnitude = (position2 - position).Magnitude
					local rayCast = MathHelper:RayCast(
						position,
						(position2 - position).Unit * magnitude,
						{ workspace.Map },
						Enum.RaycastFilterType.Include
					)

					if rayCast then
						position2 = rayCast.Position
					end

					total += dt
					total2 += dt

					if not v11 then
						local v12 = 1 - math.exp(-3 * dt)
						v3.CFrame = v3.CFrame:Lerp(CFrame.lookAt(position2, position), v12)

						if total2 > 0.325 and VisualHelper:VFXVisible(position) then
							total2 = 0
							local clone9 = v_Katsuo.NeonCircle:Clone()
							VisualHelper:CapEmitterRates(clone9, 10, true)
							clone9:PivotTo(CFrame.new(position) * CFrame.new(0, v5 * 1.25, 0))
							clone9:ScaleTo(5)
							Util.SetParentOverrideWithColor(clone9, model, player.Player, "ControlFruitVFXColor")
							VisualHelper:TweenScale(
								clone9,
								TweenInfo.new(0.8999999999999999, Enum.EasingStyle.Sine),
								v4 * 1.05
							)
							VisualHelper:Tween(clone9.Main, TweenInfo.new(3, Enum.EasingStyle.Sine), {
								CFrame = CFrame.new(position) * CFrame.new(0, -v5 * 1.05, 0)
							})
							task.delay(3, function()
								VisualHelper:SetEnableAll(clone9, false)
								task.wait(0.5)
								clone9:Destroy()
							end)
						end
					end

					clone6.CFrame = v3.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
					v10 += dt * 1.4

					if total < 0.25 then
						return
					end

					total = 0
					clone7.CFrame = CFrame.new(random:NextNumber(-3, 3), random:NextNumber(-3, 3), 0) * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						0,
						0
					)
					VisualHelper:EmitAll(clone7)
					clone5.WorldCFrame = CFrame.new(position) * CFrame.Angles(0, v10 * 10, 0) * CFrame.Angles(
						-math.rad((math.random(70))),
						0,
						0
					) * CFrame.new(0, 0, v5 * 1.1)
					VisualHelper:EmitAll(clone5)
				end)

				local function pickRandomFurthestCube(items, position2: Vector3, value: number?)
					local v12 = {}

					for k, item in pairs(items) do
						if not (item and item.Model and item.Model.Parent) then
							continue
						end

						local magnitude = (item.Model.PrimaryPart.Position - position2).Magnitude
						v12[#v12 + 1] = {
							Key = k,
							Cube = item,
							Distance = magnitude
						}
					end

					if #v12 == 0 then
						return nil, nil
					end

					table.sort(v12, function(a, b)
						return a.Distance > b.Distance
					end)
					local v14 = math.max(1, (math.floor(#v12 * (value or 0.35))))
					local v15 = v12[math.random(1, v14)]
					return v15.Key, v15.Cube
				end

				local position2 = root.Position
				local dome = Dome({
					Stage = "FromPlayer",
					Player = player.Player
				})
				dome.Object:SetAttribute("Ult", true)
				local v13 = 6
				local v14 = 0
				local total3 = 0

				while #v7 > 0 do
					local _, v15 = pickRandomFurthestCube(v7, position2)

					if v15 then
						local v16 = task.wait()
						local lastTime = os.clock()
						local v17 = v13 < v14 and 0 or v14
						local v18 = total3 >= 3.5
						local target = (v17 == 6 or v18) and player.Target

						if target and v18 then
							ClearCubes()
							VisualHelper:SetEnableAll(clone4, false)
							local position3 = target:GetPivot().Position
							local v19 = ObjectClass.new(
								player2,
								CFrame.lookAt(position + createVector(100, 230, 100), position3)
							)
							v19:SetLayout((`{1}x{1}`))
							v19:ScaleTo(0.01)
							v19:SwitchMode("Planing", true)
							v19:ToggleBodyPattern(true)
							v19:RemoveDragable()
							v19.Model.Main.CanQuery = false
							v19.CanSlice = false
							ObjectClass:ApplyModelColor(
								v19.Model,
								RecolorControlColor(player.Player, Color3.fromRGB(127, 76, 255))
							)
							v19.PlaningCFrame = v19:GetPivot() * CFrame.Angles(
								0,
								math.rad((math.random(5))),
								(math.rad((math.random(-25, 25))))
							)
							VisualHelper:TweenScale(v19, TweenInfo.new(0.25, Enum.EasingStyle.Back), 1)
							task.wait(0.1)
							PreAnimations:Lunge(character, v19, nil, Enum.NormalId.Front)
							v11 = true
							VisualHelper:SetEnableAll(model, false)
							local v20 = CFrame.lookAt(v19:GetPivot().Position, position3) * CFrame.new(-65, 5, 55).Position
							VisualHelper:Tween(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								FieldOfView = 70,
								CFrame = CFrame.lookAt(v20, position3) * CFrame.Angles(0, 0, 0.06981317007977318)
							})
							task.wait(0.3)
							v19:Flash()
							task.wait(0.1)
							local clone9 = v_Katsuo.RockBreak:Clone()
							clone9:PivotTo(v19:GetPivot())
							Util.SetParentOverrideWithColor(
								clone9,
								workspace.Terrain,
								player.Player,
								"ControlFruitVFXColor"
							)
							v19:Destroy()

							if clone9 then
								task.delay(6, clone9.Destroy, clone9)
							end

							local clone10 = v_Katsuo.RockBreakExplosion:Clone()
							clone10:ScaleTo(1.7)
							VisualHelper:ThinEmitBursts(clone10)
							clone10:PivotTo(clone9:GetPivot() * CFrame.Angles(1.5707963267948966, 0, 0))
							Util.SetParentOverrideWithColor(
								clone10,
								workspace.Terrain,
								player.Player,
								"ControlFruitVFXColor"
							)
							VisualHelper:EmitAll(clone10)

							if clone10 then
								task.delay(6, clone10.Destroy, clone10)
							end

							local circleWave = clone10.CircleWave
							local size = circleWave.Size
							circleWave.Size = size * 1.3
							VisualHelper:Tween(circleWave, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								CFrame = circleWave.CFrame * CFrame.new(0, 1.5, 0),
								Transparency = 1,
								Size = size
							})
							local clone11 = c_Katsuo.BallNeon:Clone()
							clone11.CFrame = clone10:GetPivot()
							clone11.Transparency = 0.94
							local player3 = player.Player
							local color = Color3.fromRGB(164, 89, 255)

							if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
								color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
							end

							clone11.Color = color
							clone11.Size = createVector(1, 1, 1) * (clone10.Main.Size.Y * 0.65)
							clone11.Parent = workspace.Terrain
							VisualHelper:Tween(clone11, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
								Size = clone11.Size * 2.5,
								Transparency = 1
							})

							if clone11 then
								task.delay(0.55, clone11.Destroy, clone11)
							end

							cameraShaker:Shake("Pilar Hard")
							VisualHelper:Tween(v3, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
								FieldOfView = 80
							})

							for i, child2 in clone9:GetChildren() do
								local position4 = clone9:GetPivot().Position
								local pivot = child2:GetPivot()
								local position5 = pivot.Position
								local rotation = pivot.Rotation
								local cframe = CFrame.lookAt(position4, position5)
								local magnitude = (position5 - position4).Magnitude

								-- equivalent calls inferred from this helper; original call sites unknown
								local function GetPivotWithRotation(p: number, p2: number)
									return CFrame.new(cframe * CFrame.new(0, 0, -magnitude * p).Position) * rotation:Lerp(
										CFrame.new(),
										p2
									)
								end

								child2:ScaleTo(1.15)
								child2:PivotTo(GetPivotWithRotation(0.3, 0.45))
								local v24 = (0.1 + i * 0.025) / 1.5
								VisualHelper:Tween(child2.Main, TweenInfo.new(v24, Enum.EasingStyle.Linear), {
									CFrame = GetPivotWithRotation(1.15, 0.8)
								})
								local v25 = child2
								local v26 = i
								local v27 = cframe
								local magnitude2 = magnitude
								local rotation2 = rotation
								task.delay(v24, function()
									local scope = VisualHelper
									local main = v25.Main
									local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
									local v31 = 1.6 + v26 * 0.075
									scope:Tween(main, tweenInfo, {
										CFrame = CFrame.new(v27 * CFrame.new(0, 0, -magnitude2 * v31).Position) * rotation2:Lerp(
											CFrame.new(),
											1
										)
									})
									task.wait(2)
									VisualHelper:TweenScale(
										v25,
										TweenInfo.new(
											0.19999999999999998,
											Enum.EasingStyle.Back,
											Enum.EasingDirection.In
										),
										0.01
									)
									task.wait(0.26666666666666666)
									v25:Destroy()
								end)
							end

							PreAnimations:FinalRush(character, target, player.FinalCFrames, v3)
						else
							position2 = PreAnimations:Lunge(character, target or v15, nil)
							task.spawn(function()
								clone2.CFrame = CFrame.new(position2)
								task.wait()
								VisualHelper:EmitAll(clone2)
							end)
						end

						total3 += v16 + (os.clock() - lastTime)

						if target and not v9[target] then
							v9[target] = PreAnimations:Unjoint(target)
						end

						v14 = v17 + 1

						if v18 then
							break
						end
					else
						task.wait()
					end
				end

				dome.Object:SetAttribute("Ult", nil)

				for _, v15 in v9 do
					PreAnimations:Rejoint(v15)
				end

				VisualHelper:SetEnableAll(clone4, false)

				if clone4 then
					task.delay(2, clone4.Destroy, clone4)
				end

				if clone2 then
					task.delay(1, clone2.Destroy, clone2)
				end

				if clone5 then
					task.delay(2, clone5.Destroy, clone5)
				end

				clone7:Destroy()
				clone6:Destroy()
				renderSteppedConnection:Disconnect()
				clone3:Destroy()
				VisualHelper:Tween(image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					ImageTransparency = imageTransparency
				})
				clone8:Destroy()

				if flag then
					v3.CameraType = Enum.CameraType.Scriptable
					VisualHelper:Tween(v3, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						FieldOfView = 70,
						CFrame = CFrame.lookAt(
							player.FinalCFrames.RushTeleportCFrame * CFrame.new(-15, 12.5, 22.5).Position,
							player.FinalCFrames.KnockbackCFrame.Position
						)
					}).Completed:Connect(function()
						task.wait(0.6)
						v3.CameraType = Enum.CameraType.Custom
						v3.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
					end)
				end

				task.wait(0.03333333333333333)
				Util.Sound:Play("DomainExpansion_FinalSlash_01", rush.PrimaryPart)
				PreAnimations:CrossSlash(character, rush, player.FinalCFrames)
			else
				v3.CameraType = Enum.CameraType.Custom
				v3.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
			end

			ClearCubes()
			StormBeamPattern(root.CFrame, 7, player.Player)
			task.wait(0.065)
			EmitAuraExplosion(root.CFrame * CFrame.new(0, -2.8, 0), 5, player.Player)
			root.Anchored = false
			child.Name = "Destroying"
			local dome2 = Dome({
				Stage = "FromPlayer",
				Player = player.Player
			})

			if dome2 then
				dome2:SetMaxTransparency()
				dome2:UpdateColor(nil, nil, 1)
			end
		else
			DestroyPreparedVState(v6) -- equivalent call inferred; original call site unknown
		end
	end
end