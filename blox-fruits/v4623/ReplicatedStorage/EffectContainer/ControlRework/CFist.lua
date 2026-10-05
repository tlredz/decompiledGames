local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cFist = FX:WaitForChild("ControlRework"):WaitForChild("CFist")
local Dome = require(script.Parent.Domain.Dome)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local currentCamera = workspace.CurrentCamera

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

function Debris(instance, duration: number)
	if not instance then
		return
	end

	if duration > 0 then
		return task.delay(duration, instance.Destroy, instance)
	end

	instance:Destroy()
end

local function ThinEchoEmitters(folder)
	local v = false

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = 0

		for _, keypoint in emitter.Size.Keypoints do
			v2 = math.max(v2, keypoint.Value)
		end

		if v2 < 25 then
			continue
		end

		v = not v

		if not v then
			emitter:Destroy()
		end
	end
end

local function RaycastPillarSweep(body, cframe: CFrame, p: number, model)
	local v = body.Position - cframe.LookVector * (p * 0.5)
	local v2 = cframe.LookVector * p
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local v3 = (not body.Size and 1 or body.Size.X or 1) * 0.5
	local v4 = (body.Size and body.Size.Y or 1) * 0.5
	local v5 = {
		createVector(0, 0, 0),
		rightVector * v3,
		-rightVector * v3,
		upVector * v4,
		-upVector * v4,
		rightVector * v3 + upVector * v4,
		rightVector * v3 - upVector * v4,
		-rightVector * v3 + upVector * v4,
		-rightVector * v3 - upVector * v4
	}
	local v6 = nil

	for _, v8 in ipairs(v5) do
		local v9 = v + v8
		local rayCast = MathHelper:RayCast(v9, v2, { model }, Enum.RaycastFilterType.Include)

		if not rayCast then
			continue
		end

		local magnitude = (rayCast.Position - v9).Magnitude

		if v6 and not (magnitude < v6) then
			break
		else
			return rayCast, magnitude
		end
	end

	return nil, v6
end

local function PillarExplosion(data)
	local pilar = data.Pilar
	local cFrame = pilar.CFrame
	local size = pilar.Size
	local color = pilar.Color
	local material = pilar.Material
	local skillVisuals = data.SkillVisuals
	local flash = pilar:FindFirstChild("Flash")
	local random = Random.new()

	if not flash then
		flash = pilar:Clone()
		flash:ClearAllChildren()
		flash.Transparency = 0.4
		flash.Size *= 1.015
		flash.Material = Enum.Material.Neon
		local player = data.Player
		local color2 = Color3.fromRGB(103, 123, 189)

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
		end

		flash.Color = color2
		flash.Parent = pilar
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PlayFlash(delay: number)
		VisualHelper:Tween(flash, TweenInfo.new(delay, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
	end

	local position = data.Position or pilar:GetAttribute("OldPosition")
	local normal = data.Normal or pilar:GetAttribute("OldNormal")
	local scale = data.Scale or pilar:GetAttribute("OldScale")
	pilar:SetAttribute("OldPosition", position)
	pilar:SetAttribute("OldNormal", normal)
	pilar:SetAttribute("OldScale", scale)
	local cFrame2

	if position and normal or not cFrame then
		cFrame2 = CFrame.lookAt(position, position + normal) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
			0,
			0.5,
			0
		)
	else
		cFrame2 = cFrame
	end

	local v2 = math.clamp(scale + 0.4, 1, 500)
	local lastBoomPoint = skillVisuals:GetAttribute("LastBoomPoint")
	local lastBoomAt = skillVisuals:GetAttribute("LastBoomAt")
	local v3

	if typeof(lastBoomPoint) == "Vector3" and (lastBoomPoint - cFrame2.Position).Magnitude < 40 and type(lastBoomAt) == "number" then
		v3 = os.clock() - lastBoomAt < 1.25
	else
		v3 = false
	end

	if not v3 then
		skillVisuals:SetAttribute("LastBoomPoint", cFrame2.Position)
		skillVisuals:SetAttribute("LastBoomAt", os.clock())
	end

	Util.Sound:Play("C_Hands_CeilingBlock_Impact_0" .. tostring(math.random(1, 8)), cFrame2.Position)

	if data.Type == "Impact" then
		CameraShaker:Shake("Pilar Hard")
		PlayFlash(0.2) -- equivalent call inferred; original call site unknown
		local clone

		if data.PreparedInstances then
			clone = data.PreparedInstances:Take()
		else
			clone = cFist.Phase1.Explosion:Clone()
		end

		if not data.PreparedInstances then
			clone:ScaleTo(v2)
			VisualHelper:ThinEmitBursts(clone)
		end

		if v3 then
			VisualHelper:ThinEmitBursts(clone, 15, 40)
			ThinEchoEmitters(clone)
		end

		clone:PivotTo(cFrame2)
		Util.SetParentOverrideWithColor(clone, skillVisuals, data.Player, "ControlFruitVFXColor")
		VisualHelper:EmitAll(clone)
		Debris(clone, 3)
		local v4 = clone.Main.Size.X / 2
		local clone2

		if data.PreparedInstances then
			clone2 = data.PreparedInstances:Take()
		else
			clone2 = cFist.Phase1.BallNeon:Clone()
		end

		clone2.CFrame = cFrame2
		clone2.Transparency = 0.8
		local player = data.Player
		local color2 = Color3.fromRGB(89, 133, 255)

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
		end

		clone2.Color = color2
		clone2.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
		clone2.Parent = skillVisuals
		VisualHelper:Tween(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Size = clone.Main.Size + createVector(5, 5, 5),
			Transparency = 1
		})
		Debris(clone2, 0.2)
		VisualHelper:SetEnableAll(pilar, true)
		task.delay(0.25, function()
			VisualHelper:SetEnableAll(pilar, false)
		end)
		local airMeshHuge = clone.AirMeshHuge
		local airMeshSpiral = clone.AirMeshSpiral
		local airMeshStorm = clone.AirMeshStorm
		local darkSpiralAir = clone.DarkSpiralAir
		local superFlash = clone.SuperFlash
		local flash2 = clone.Flash
		local airHard = clone.AirHard
		local circleWave = clone.CircleWave
		VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Scale = airMeshHuge.Mesh.Scale * 1.9
		})
		VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		Debris(airMeshHuge, 1)
		airMeshSpiral.CFrame = pilar.CFrame * CFrame.new(0, pilar.Size.Y / 3, 0)
		VisualHelper:Tween(airMeshSpiral.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Scale = airMeshSpiral.Mesh.Scale * 2
		})
		VisualHelper:Tween(airMeshSpiral.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(airMeshSpiral, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			CFrame = airMeshSpiral.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		Debris(airMeshSpiral, 1)
		VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Scale = airMeshSpiral.Mesh.Scale * 2.15
		})
		VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			CFrame = airMeshSpiral.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		Debris(airMeshStorm, 1)
		darkSpiralAir.CFrame = airMeshSpiral.CFrame
		VisualHelper:Tween(darkSpiralAir, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
			CFrame = darkSpiralAir.CFrame * CFrame.Angles(0, 2.8797932657906435, 0)
		})
		VisualHelper:Tween(darkSpiralAir.Decal, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(darkSpiralAir.Mesh, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
			Scale = darkSpiralAir.Mesh.Scale * 1.6
		})
		Debris(darkSpiralAir, 1)
		airHard.CFrame = airMeshSpiral.CFrame
		VisualHelper:Tween(airHard, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
			CFrame = airHard.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		VisualHelper:Tween(airHard.Decal, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(airHard.Mesh, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
			Scale = airHard.Mesh.Scale * 2
		})
		Debris(airHard, 1)
		VisualHelper:Tween(flash2.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(flash2.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Scale = flash2.Mesh.Scale * 2.5
		})
		Debris(flash2, 1)
		local size2 = circleWave.Size
		circleWave.CFrame = airMeshSpiral.CFrame
		circleWave.Size = size2 * 0.7
		VisualHelper:Tween(circleWave, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			CFrame = circleWave.CFrame * CFrame.new(0, -size.Y / 3.8, 0),
			Transparency = 1,
			Size = size2
		})
		local scale2 = superFlash.Mesh.Scale * 2.6
		superFlash.Mesh.Scale /= 2
		VisualHelper:Tween(superFlash, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			CFrame = superFlash.CFrame * CFrame.new(0, -7, 0)
		})
		VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
			Scale = scale2
		})
		Debris(superFlash, 1)
		local beams = clone.Main.Beams
		beams.WorldCFrame = pilar.CFrame * CFrame.Angles(0, 0, 3.141592653589793) * CFrame.new(0, -pilar.Size.Y / 2, 0)
		VisualHelper:Tween(beams, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			WorldCFrame = beams.WorldCFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})

		for _, beam in beams:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.15 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(beams, 0.5)
		local circleBeam = clone.Main.CircleBeam
		circleBeam.Orientation = Vector3.new(0, math.random(360))

		for _, v6 in { circleBeam.Beam1, circleBeam.Beam2 } do
			v6.Enabled = true
			VisualHelper:Tween(v6, TweenInfo.new(0.16, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(circleBeam, 0.16)

		if skillVisuals:GetAttribute("LastRockPoint") == nil or (skillVisuals:GetAttribute("LastRockPoint") - cFrame2.Position).Magnitude > 50 then
			skillVisuals:SetAttribute("LastRockPoint", cFrame2.Position)
			Rocks:CircleRocks(
				cFrame2.Position,
				9,
				v4 * 0.5,
				createVector(13.5, 3, 5) * (v2 * 0.065 + 1),
				0,
				{ workspace.Characters, workspace.Enemies }
			)
			Rocks:CircleRocks(
				cFrame2.Position,
				4,
				v4 * 0.7,
				createVector(7, 4.5, 5) * (v2 * 0.065 + 1),
				0,
				{ workspace.Characters, workspace.Enemies }
			)
			Rocks:CircleRocks(
				cFrame2.Position,
				4,
				v4 * 0.85,
				createVector(5, 2.5, 5) * (v2 * 0.065 + 1),
				0,
				{ workspace.Characters, workspace.Enemies }
			)

			for _ = 1, 4 do
				Rocks:AirRocks(
					cFrame2,
					Vector3.new(random:NextNumber(1.5, 3), 1, random:NextNumber(1.5, 3)) * (v2 + 2.5),
					false,
					math.random(27, 62) * (v2 + 2.5),
					0.2,
					2.5,
					5,
					color,
					material
				)
			end

			local v6 = cFrame2 * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v4 + 5, v4 + 15)
			)
			local rayCast = MathHelper:RayCast(
				v6.Position,
				v6.UpVector * -10,
				{ data.SkillVisuals },
				Enum.RaycastFilterType.Exclude
			)

			if rayCast then
				local clone3 = cFist.Phase1.BoltExplosion:Clone()
				clone3.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.05, 0))
				Util.SetParentOverrideWithColor(clone3, skillVisuals, data.Player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone3)
				Debris(clone3, 1)
			end

			local clone3 = cFist.Phase2.GroundAura:Clone()
			VisualHelper:CapEmitterRates(clone3, 40, true)
			clone3.CFrame = cFrame2 * CFrame.new(0, 0.1, 0)
			Util.SetParentOverrideWithColor(clone3, skillVisuals, data.Player, "ControlFruitVFXColor")

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.delay(0.35, function()
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			clone3.Aura2.Size = createVector(5, 1, 5)
			TweenService:Create(clone3.Aura2, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = createVector(250, 1, 250)
			}):Play()
		end
	elseif data.Type == "Destroy" then
		local delay = data.Delay

		if delay then
			PlayFlash(delay) -- equivalent call inferred; original call site unknown
			task.wait(delay)
		end

		if pilar.Parent == nil then
			print("WHAAAAA")
			return
		end

		local clone

		if data.PreparedInstances then
			clone = data.PreparedInstances:Take()
		else
			clone = cFist.Phase1.EndExplosion:Clone()
		end

		if math.abs(clone:GetScale() - v2) > 0.0001 then
			clone:ScaleTo(v2)
		end

		VisualHelper:ThinEmitBursts(clone)

		if data.PreparedInstances then
			data.PreparedInstances:Destroy()
		end

		pilar.Parent:Destroy()
		CameraShaker:Shake("Fast Hard")

		if v3 then
			VisualHelper:ThinEmitBursts(clone, 15, 40)
			ThinEchoEmitters(clone)
		end

		clone:PivotTo(cFrame2)
		Util.SetParentOverrideWithColor(clone, skillVisuals, data.Player, "ControlFruitVFXColor")
		local smokeBox = clone.SmokeBox
		local smokeBox2 = clone.SmokeBox
		smokeBox.Size = size
		smokeBox2.CFrame = cFrame
		VisualHelper:EmitAll(clone)
		Debris(clone, 1.4)
		local circleBeam = clone.Main.CircleBeam
		circleBeam.Orientation = Vector3.new(0, math.random(360))

		for _, v4 in { circleBeam.Beam1, circleBeam.Beam2 } do
			v4.Enabled = true
			VisualHelper:Tween(v4, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(circleBeam, 0.075)

		if data.Break then
			for _, child in cFist.Phase1.Breaker:GetChildren() do
				local v4 = child.Name == "Top" and -1 or 1
				local clone2 = child:Clone()
				clone2.Color = color
				clone2.Material = material
				clone2.Size = Vector3.new(size.X, size.Y / 2, size.Z)
				clone2.CFrame = cFrame * CFrame.new(0, size.Y / 2 * v4 / 3, 0) * CFrame.Angles(
					0,
					0,
					3.141592653589793 * v4
				)
				clone2.Anchored = false
				clone2.Parent = skillVisuals
				clone2.AssemblyLinearVelocity = clone2.CFrame.RightVector * (80 * v4) + createVector(0, 25, 0)
				clone2.AssemblyAngularVelocity = createVector(1, 0, 0) * v4 * 5
				task.delay(1, function()
					VisualHelper:Tween(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Size = createVector(0, 0, 0)
					})
					task.wait(0.5)
					clone2:Destroy()
				end)
			end
		end

		local v4 = v2 * 2
		local v5 = v2 * 3
		local v6 = 5

		for i = 1, 3 do
			Rocks:AirRocks(
				cFrame * CFrame.new(0, -size.Y / 2 + size.Y * i / v6, 0),
				Vector3.new(random:NextNumber(v4, v5), random:NextNumber(0.3, 2.5), random:NextNumber(v4, v5)),
				false,
				random:NextNumber(90, 150),
				1,
				0.5,
				5,
				color,
				material
			)
		end

		local v7 = 3

		for i = 1, 2 do
			Rocks:AirRocks(
				cFrame * CFrame.new(0, -size.Y / 2 + size.Y * i / v7, 0),
				createVector(1, 1, 1) * random:NextNumber(v4, v5),
				false,
				random:NextNumber(90, 150),
				1,
				0.5,
				5,
				color,
				material
			)
		end
	end
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder_2 = Instance.new("Folder", player.Player)
		folder_2.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 or player.Stage ~= 1 then
		return
	end

	local dome = Dome({
		Stage = "Fetch",
		Character = player.Character
	})

	if not dome then
		warn("Must spawn Domain to use skill!")
		return
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, _WorldOrigin }
	local model2 = Instance.new("Model", model)
	local v2 = {}
	model.Destroying:Once(function()
		for _, v3 in v2 do
			v3:Destroy()
		end

		table.clear(v2)
	end)

	local function NewPillar(data)
		local _ = data.Position
		local v3 = {
			Position = data.SpawnCFrame.Position,
			Size = createVector(50, 1, 50)
		}
		local clone = cFist.Phase0.PillarModel:Clone()
		local body = clone.Body
		local collider = clone.Collider
		collider.CanQuery = false
		local base = clone.Base
		local primaryPart = base.PrimaryPart
		local gradientPattern = clone.BodyLayers.GradientPattern

		for i = 1, 9 do
			if i % 3 == 0 then
				continue
			end

			local child = gradientPattern:FindFirstChild("Decal" .. i)

			if child then
				child:Destroy()
			end
		end

		for _, decal in gradientPattern:GetChildren() do
			if decal:IsA("Decal") then
				decal.Transparency = 0.3
			end
		end

		for _, v4 in { primaryPart.BoostMode.ShapeAir, primaryPart.BoostMode.ShapeBodyAir } do
			local children = v4:GetChildren()

			for i = 2, #children, 2 do
				children[i]:Destroy()
			end
		end

		local v4 = body.Size / body.MeshSize
		local clone2 = cFist.Phase0.MouseArea:Clone()
		VisualHelper:CapEmitterRates(clone2, 12, true)
		clone2:ScaleTo(0.01)
		clone2:PivotTo(CFrame.lookAt(data.Position, data.Position + data.Normal) * CFrame.new(0, 0, -1) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		))
		Util.SetParentOverrideWithColor(clone2, model, player.Player, "ControlFruitVFXColor")
		local position = dome:GetCFrame().Position
		local v5 = dome:GetSize() / 2
		local v6 = v5 < (data.Position - position).Magnitude
		VisualHelper:TweenScale(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back), clone:GetScale() * 3)
		task.delay(0.35, function()
			VisualHelper:TweenScale(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Sine), 0.01)
			task.wait(0.15)
			clone2:Destroy()
		end)

		for _, surfaceGui in clone2.Main:GetChildren() do
			if not surfaceGui:IsA("SurfaceGui") then
				continue
			end

			VisualHelper:Tween(
				surfaceGui.Edge,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					ImageTransparency = 0.5
				}
			)
			VisualHelper:Tween(
				surfaceGui.InnerGradient,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					ImageTransparency = 0.3
				}
			)
			VisualHelper:Tween(
				surfaceGui.AnimateGradient,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Size = UDim2.fromScale(0.9, 0.9),
					ImageTransparency = 0.3
				}
			)
			VisualHelper:Tween(
				surfaceGui.BorderShader,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					ImageTransparency = 0.96
				}
			)
			VisualHelper:Tween(
				surfaceGui.BorderShader,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Rotation = surfaceGui.BorderShader.Rotation + 360
				}
			)
			VisualHelper:Tween(
				surfaceGui.InnerEngine,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
				{
					Size = UDim2.fromScale(0.23, 0.23)
				}
			)
			VisualHelper:Tween(
				surfaceGui.InnerEngine,
				TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Rotation = surfaceGui.InnerEngine.Rotation + 360
				}
			)
			VisualHelper:Tween(
				surfaceGui.Mark,
				TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Size = UDim2.fromScale(1.1, 1.1)
				}
			)
			VisualHelper:Tween(
				surfaceGui.OutEngine,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Rotation = surfaceGui.OutEngine.Rotation + 360
				}
			)
			VisualHelper:Tween(
				surfaceGui.ExtraOutEngine,
				TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Rotation = surfaceGui.OutEngine.Rotation + 360
				}
			)
		end

		local v7 = {
			[base] = primaryPart.Size,
			[primaryPart.BoostMode.Winds] = createVector(0, 20, 0),
			[primaryPart.BoostMode.ShapeAir] = createVector(-0, -5, -0)
		}

		for _, child in clone.BodyLayers:GetChildren() do
			v7[child] = child.Mesh.Scale - v4
		end

		for _, child in primaryPart.NormalMode.Bolts:GetChildren() do
			local point = child.Point
			v7[point] = point.Position
		end

		local primaryPart2 = base.PrimaryPart
		local normalMode = primaryPart2.NormalMode
		local boostMode = primaryPart2.BoostMode
		local children = normalMode.Bolts:GetChildren()

		local function UpdatePillar(flag: boolean?)
			local v8 = clone
			local bodyLayers = v8:FindFirstChild("BodyLayers")

			if not bodyLayers then
				print("Cancelled UpdatePillar, was destroyed?")
				return
			end

			local size = body.Size
			local meshSize = body.MeshSize
			local v9 = createVector(0, 1, 0) * size.Y
			local v10 = size / meshSize
			local v11 = body.CFrame * CFrame.new(0, -size.Y / 2, 0)

			for _, child in bodyLayers:GetChildren() do
				local vector2 = v10 + v7[child]

				if child.Name == "GradientPattern" then
					vector2 = Vector3.new(vector2.X, math.min(vector2.Y, 75), vector2.Z)
				end

				child.Mesh.Scale = vector2
				child.CFrame = v11 * CFrame.new(0, vector2.Y * meshSize.Y / 2 - 0.05, 0)
			end

			local base2 = v8.Base
			base2:PivotTo(v11 * CFrame.new(0, -0.05, 0))
			local v12 = math.max(size.X / v7[base2].X, 0.01)

			if base2:GetScale() ~= v12 then
				base2:ScaleTo(v12)
			end

			if collider then
				collider.Size = size
				collider.CFrame = clone.Body.CFrame
			end

			for _, v13 in {
				boostMode.PatternBeam.Top,
				normalMode.PatternBeam.Top,
				boostMode.Arrow,
				boostMode.ShapeAir,
				boostMode.ShapeBodyAir,
				boostMode.Winds
			} do
				v13.Position = v9 + (v7[v13] or createVector(0, 0, 0))
			end

			for _, child in boostMode.ShapeBodyAir:GetChildren() do
				child.Drag.Position = createVector(0, 0, 1) * -size.Y
			end

			if not flag then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function UpdateBoltPoint(point)
				local v13 = v7[point]
				point.Position = Vector3.new(point.Position.X, v13.Y / body.Size.Y * size.Y, point.Position.Z)
			end

			for _, v13 in children do
				UpdateBoltPoint(v13.Point) -- equivalent call inferred; original call site unknown
			end
		end

		UpdatePillar(true)
		body:GetPropertyChangedSignal("Size"):Connect(function()
			UpdatePillar(true)
		end)
		local v8 = {}

		local function PillarMode(p)
			local v9 = clone
			local canQuery = p == "Solid"
			local enabled2

			if p == "Normal" then
				enabled2 = not canQuery
			else
				enabled2 = false
			end

			local enabled3

			if p == "Boost" then
				enabled3 = not canQuery
			else
				enabled3 = false
			end

			local base2 = v9.Base
			local primaryPart3 = base2.PrimaryPart
			local scale = clone:GetScale()

			for _, v13 in pairs(v8) do
				if v13 then
					v13:Destroy()
				end
			end

			body.CanCollide = false

			if canQuery then
				local localPlayer2 = game.Players.LocalPlayer
				local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if body and body.Parent then
							local pointToObjectSpace = body.CFrame:PointToObjectSpace(humanoidRootPart.Position)
							local v13 = body.Size * 0.5
							local v14

							if math.abs(pointToObjectSpace.X) <= v13.X and math.abs(pointToObjectSpace.Y) <= v13.Y then
								v14 = math.abs(pointToObjectSpace.Z) <= v13.Z
							else
								v14 = false
							end

							if v14 then
								return
							end

							body.CanCollide = true

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
							end
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
						end
					end)
				end
			end

			collider.CanQuery = canQuery
			local surfacesParticle = base2.SurfacesParticle
			surfacesParticle.Top.Enabled = enabled2
			surfacesParticle.Bottom.Enabled = enabled2
			local normalMode2 = primaryPart3.NormalMode

			local function ToggleBeams(folder, enabled: boolean, value: number?)
				local v13 = value or 1

				for _, beam in folder:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					local v14 = {}

					if beam.LightEmission <= 0 then
						local width = not enabled and 0 or (beam:GetAttribute("Width0") or 0) * v13 or 0
						local width2 = (not enabled and 0 or beam:GetAttribute("Width1") or 0) * v13 or 0
						v14.Width0 = width
						v14.Width1 = width2
					else
						v14.Brightness = not enabled and 0 or beam:GetAttribute("Brightness") or 0
					end

					TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), v14):Play()
					beam.Enabled = enabled
				end
			end

			local function ToggleParticles(folder, enabled: boolean)
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = enabled
					end
				end
			end

			ToggleBeams(normalMode2, enabled2, scale * 5)
			ToggleParticles(normalMode2, enabled2)
			ToggleBeams(primaryPart3.BoostMode, enabled3, scale)
			ToggleParticles(v9.Body, enabled3)

			for _, emitter in v9.Body:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = enabled3
				end
			end
		end

		PillarMode("Normal")

		if v3 then
			body.Size = v3.Size * createVector(1, 0, 1)
			clone:PivotTo(CFrame.lookAt(v3.Position, data.Position) * CFrame.Angles(-1.5707963267948966, 0, 0))
		end

		Util.SetParentOverrideWithColor(clone, model2, player.Player, "ControlFruitVFXColor")
		local clone3 = cFist.Phase2.SpawnImpact:Clone()
		clone3.CFrame = body.CFrame
		Util.SetParentOverrideWithColor(clone3, model, player.Player, "ControlFruitVFXColor")
		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3.Attachment:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		clone3["Particle_" .. math.random(1, 3)]:Emit(1)
		local body2 = clone.Body
		local base2 = clone.Base
		Util.Sound:Play("C_Hands_CeilingBlock_Spawn_0" .. tostring(math.random(1, 4)), body2)
		local v9 = clone:GetScale() * 35.237 * 2.5
		local v10 = math.clamp(clone:GetScale() * 5 + 0.4, 1, 500)
		local preparedInstances = PrepareClonedInstances.new({
			{
				Template = cFist.Phase1.Explosion,
				Prepare = function(instance)
					instance:ScaleTo(v10)
					VisualHelper:ThinEmitBursts(instance)
				end
			},
			cFist.Phase1.BallNeon,
			cFist.Phase2.PillarHitAura,
			{
				Template = cFist.Phase2.GroundCrack,
				Prepare = function(p)
					VisualHelper:ThinEmitBursts(p)
				end
			},
			{
				Template = cFist.Phase1.EndExplosion,
				Prepare = function(instance)
					instance:ScaleTo(v10)
				end
			}
		})
		v2[clone] = preparedInstances
		VisualHelper:Tween(body2, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = body2.Size + Vector3.new(0, v9, 0),
			CFrame = body2.CFrame * CFrame.new(0, v9 / 2, 0)
		})
		local impulse = base2.Impulse
		impulse.Parent = model
		VisualHelper:EmitAll(impulse)
		local winds = impulse.Winds
		VisualHelper:Tween(winds, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Orientation = winds.Orientation - createVector(0, 560, 0)
		})

		for _, child in winds:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		task.wait(0.4)
		Debris(impulse, 3)
		local cframe = CFrame.lookAt(body2.Position, body2.Position + body2.CFrame.UpVector)
		PillarMode("Boost")
		local clone4 = cFist.Phase2.PillarAura:Clone()
		VisualHelper:CapEmitterRates(clone4, 10, true)
		clone4.CFrame = body2.CFrame
		Util.SetParentOverrideWithColor(clone4, model, player.Player, "ControlFruitVFXColor")
		clone4.Weld.Part1 = body2
		clone4.Anchored = false
		local total = 0

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local total2 = 250
		local flag = false
		local position4 = nil
		local v13 = false

		local function GetPillarImpactTime(cframe2: CFrame, vector2: Vector3, p: number, p2: number?)
			local v14 = p * 0.5
			local v15 = p * 10
			local lookVector = cframe2.LookVector
			local dot = (vector2 - cframe2.Position):Dot(lookVector)

			if dot <= 0 then
				return nil
			end

			local v16 = v14 * v14 + v15 * 2 * dot

			if v16 < 0 then
				return nil
			end

			local v17 = (-v14 + math.sqrt(v16)) / v15

			if p2 and p2 < v17 then
				return nil
			end

			return v17
		end

		local spawnCFrame = data.SpawnCFrame
		local position2 = data.Position
		local lookVector = spawnCFrame.LookVector
		local dot = (position2 - spawnCFrame.Position):Dot(lookVector)
		local v14, v15

		if dot <= 0 then
			v14 = cframe
		else
			local v16 = 62500 + 10000 * dot

			if v16 < 0 then
				v14 = cframe
			else
				v15 = (math.sqrt(v16) + -250) / 5000
				v14 = cframe
			end
		end

		while total < v15 do
			local v16 = task.wait()
			total += v16
			total2 += 5000 * v16
			local v17 = v16 * total2
			cframe *= CFrame.new(0, 0, -v17)
			body2.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
			UpdatePillar()
			local rayCast = MathHelper:RayCast(
				v14.Position,
				cframe.Position - v14.Position + cframe.LookVector * v9 / 8,
				{ workspace.Characters, workspace.Enemies }
			)

			if v6 then
				local position3 = (body2.CFrame * CFrame.new(0, body2.Size.Y * 0.5, 0)).Position

				if v5 < (position3 - position).Magnitude then
					position4 = position3
					flag = true
					break
				end
			end

			if rayCast then
				body2.CFrame = CFrame.new(rayCast.Position - cframe.LookVector * v9 / 8) * body2.CFrame.Rotation
				UpdatePillar(true)
				local raycastPillarSweep = RaycastPillarSweep(body2, cframe, v9, model2)

				if raycastPillarSweep then
					local parent = raycastPillarSweep.Instance.Parent
					local collider2

					if parent then
						collider2 = parent:FindFirstChild("Collider")
					end

					if parent and collider2 and collider2:GetAttribute("SolidPillar") == true then
						collider2:SetAttribute("SolidPillar", nil)
						collider2.CanQuery = false
						PillarExplosion({
							Normal = raycastPillarSweep.Normal,
							Position = raycastPillarSweep.Position,
							Scale = parent:GetScale(),
							Pilar = parent.Body,
							Type = "Destroy",
							Player = player.Player,
							Break = true,
							SkillVisuals = model,
							PreparedInstances = v2[parent]
						})
						v2[parent] = nil
						continue
					end
				end

				local v19 = rayCast
				task.spawn(function()
					body2.Material = v19.Instance.Material
					body2.Color = v19.Instance.Color
					TweenService:Create(clone.BodyLayers.Gradient.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
					TweenService:Create(clone.BodyLayers.HardOutline.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
					TweenService:Create(clone.BodyLayers.Outline.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
					TweenService:Create(clone.Base.Main.PointLight, TweenInfo.new(0.25), {
						Brightness = 0
					}):Play()
					local gradientPattern2 = clone.BodyLayers.GradientPattern

					for i = 0, 9 do
						local v20 = i == 0 and "" or i

						if gradientPattern2:FindFirstChild("Decal" .. v20) then
							TweenService:Create(gradientPattern2["Decal" .. v20], TweenInfo.new(i * 0.03 + 0.05), {
								Transparency = 1
							}):Play()
						end
					end
				end)
				PillarExplosion({
					Position = rayCast.Position,
					Normal = rayCast.Normal,
					Scale = clone:GetScale() * 5,
					Pilar = body2,
					Type = "Impact",
					Player = player.Player,
					SkillVisuals = model,
					PreparedInstances = preparedInstances
				})
				v13 = true

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local folder = preparedInstances:Take()
				local v23 = rayCast
				local folder2 = preparedInstances:Take()
				task.spawn(function()
					folder.CFrame = body2.CFrame * CFrame.new(0, body2.Size.Z / 1, 0)
					Util.SetParentOverrideWithColor(folder, model, player.Player, "ControlFruitVFXColor")

					for i, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.delay(0.3, function()
						for i, emitter in pairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
					local X = body2.Size.X
					local v24 = body2.Size.Y / 3
					local Z = body2.Size.Z
					folder.Size = Vector3.new(X, 1, Z)
					TweenService:Create(folder, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(X, v24, Z),
						CFrame = body2.CFrame * CFrame.new(0, -body2.Size.Z / 2, 0)
					}):Play()
					folder2.CFrame = CFrame.lookAt(v23.Position, v23.Position + v23.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					) * CFrame.new(0, 0.5, 0)
					Util.SetParentOverrideWithColor(folder2, model, player.Player, "ControlFruitVFXColor")
					DeleteImpactAfterDuration(folder2) -- equivalent call inferred; original call site unknown

					for i, emitter in pairs(folder2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v27 = emitter
						task.spawn(function()
							if v27:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v27:GetAttribute("EmitDelay"))
							end

							v27:Emit(v27:GetAttribute("EmitCount"))
						end)
					end
				end)
				PillarMode("Solid")
				clone.Collider:SetAttribute("SolidPillar", true)
				local v24 = rayCast
				task.delay(3, function()
					if not (clone ~= nil and clone:FindFirstChild("Collider") ~= nil and clone.Collider:GetAttribute("SolidPillar") == true) then
						return
					end

					clone.Collider:SetAttribute("SolidPillar", nil)
					clone.Collider.CanQuery = false
					PillarExplosion({
						Position = v24.Position,
						Normal = v24.Normal,
						Scale = clone:GetScale() * 5,
						Pilar = body2,
						Delay = 0.2,
						Type = "Destroy",
						Player = player.Player,
						SkillVisuals = model,
						PreparedInstances = preparedInstances
					})
					v2[clone] = nil
				end)
				break
			else
				v14 = cframe
			end
		end

		for _, effect in pairs(clone4:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		if flag then
			local v16 = body2.Position - position4
			local unit = v16.Magnitude > 1e-6 and v16.Unit or createVector(0, 1, 0)

			if unit.Y < 0 then
				unit = Vector3.new(unit.X, -unit.Y, unit.Z).Unit
			end

			local _ = {
				Position = position4,
				Normal = unit
			}
			task.spawn(function()
				TweenService:Create(clone.BodyLayers.Gradient.Decal, TweenInfo.new(0.05), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.BodyLayers.HardOutline.Decal, TweenInfo.new(0.05), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.BodyLayers.Outline.Decal, TweenInfo.new(0.05), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Base.Main.PointLight, TweenInfo.new(0.05), {
					Brightness = 0
				}):Play()
				local gradientPattern2 = clone.BodyLayers.GradientPattern

				for i = 0, 9 do
					local v17 = i == 0 and "" or i

					if gradientPattern2:FindFirstChild("Decal" .. v17) then
						TweenService:Create(gradientPattern2["Decal" .. v17], TweenInfo.new(i * 0.03 + 0.05), {
							Transparency = 1
						}):Play()
					end
				end
			end)
			local surfacesParticle = base.SurfacesParticle
			surfacesParticle.Top.Enabled = true
			surfacesParticle.Bottom.Enabled = true
			TweenService:Create(body, TweenInfo.new(0.1), {
				Size = Vector3.new(body.Size.X, 0, body.Size.Z),
				Transparency = 1
			}):Play()

			for _, image in pairs(surfacesParticle:GetDescendants()) do
				if image:IsA("ImageLabel") then
					TweenService:Create(image, TweenInfo.new(0.5), {
						ImageTransparency = 1
					}):Play()
				end
			end

			task.delay(0.1, function()
				if clone == nil then
				end
			end)
		elseif not v13 then
			PillarExplosion({
				Position = body2.Position,
				Normal = -body2.CFrame.LookVector,
				Scale = clone:GetScale() * 5,
				Pilar = body2,
				Type = "Impact",
				Player = player.Player,
				SkillVisuals = model,
				PreparedInstances = preparedInstances
			})
		end
	end

	if localPlayer == player.Player then
		task.spawn(function()
			local clone = cFist.Phase0.CameraEffectsHex:Clone()
			Util.SetParentOverrideWithColor(clone, currentCamera, player.Player, "ControlFruitVFXColor")
			VisualHelper:SetEnableAll(clone, true)
			VisualHelper:EmitAll(clone)
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
				clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
			end)

			if player.Holding and player.Holding.Value then
				repeat
					task.wait()
				until not (player.Holding and player.Holding.Value)
			else
				task.wait(0.25)
			end

			VisualHelper:SetEnableAll(clone, false)
			task.wait(0.4)
			clone:Destroy()
			renderSteppedConnection:Disconnect()
		end)
	end

	local proxy = player.Proxy

	if not (proxy and proxy.Parent) then
		return
	end

	for i = 1, player.Total do
		local child = proxy:WaitForChild("Pillar_" .. i, 5)

		if not child then
			break
		end

		local lastTime = os.clock()
		local v3

		while true do
			if os.clock() - lastTime > 5 then
				v3 = nil
				break
			end

			v3 = {
				Instance = {
					Material = child:GetAttribute("RayHitMaterial"),
					Color = child:GetAttribute("RayHitColor")
				},
				Position = child:GetAttribute("RayPosition"),
				Normal = child:GetAttribute("RayNormal"),
				CreatedAt = child:GetAttribute("CreatedAt"),
				SpawnCFrame = child.Value
			}

			if v3.Instance.Material ~= nil and v3.Instance.Color ~= nil and v3.Position ~= nil and v3.Normal ~= nil and v3.CreatedAt ~= nil and v3.SpawnCFrame ~= nil then
				break
			end

			task.wait()
		end

		if v3 then
			task.spawn(NewPillar, v3)
		end
	end

	Util.Debris:AddItem(model, 10)
end