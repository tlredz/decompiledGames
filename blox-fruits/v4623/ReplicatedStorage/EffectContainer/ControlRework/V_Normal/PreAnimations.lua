local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local shared = script.Parent.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local Textures = require(shared.Textures)
require(shared.Rocks)
require(shared:WaitForChild("ObjectClass"))
require(ReplicatedStorage.Effect)
require(shared:WaitForChild("ObjectClass"))
local HexsStormClass = require(shared:WaitForChild("HexsStormClass"))
local cameraShaker = Util.CameraShaker
local camera = workspace.Camera
local lightningBoltShafi = Util.LightningBoltShafi
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("ControlRework").Domain
local z_Katsuo = FX:WaitForChild("ControlRework").Z_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local f_Katsuo = FX:WaitForChild("ControlRework").F_Katsuo
local v_Katsuo = FX:WaitForChild("ControlRework").V_Katsuo
local random = Random.new()

local function Debris(instance, duration: number)
	if not instance then
		return
	end

	if duration and duration > 0 then
		return task.delay(duration, instance.Destroy, instance)
	end

	instance:Destroy()
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

local v = {}
local ScheduleBurstEviction

ScheduleBurstEviction = function(p: string)
	local v2 = v[p]

	if v2 and not v2.EvictScheduled then
		v2.EvictScheduled = true
		task.delay(8, function()
			local v3 = v[p]

			if not v3 then
				return
			end

			v3.EvictScheduled = false

			if os.clock() - v3.LastUse < 8 then
				ScheduleBurstEviction(p)
				return
			end

			v[p] = nil

			for _, ring in v3.Rings do
				for _, entry in ring.Entries do
					entry.Model:Destroy()
				end
			end
		end)
	end
end

local function BuildBurstEntry(instance, p: number?, player, callback)
	local clone = instance:Clone()

	if p and clone:IsA("Model") then
		clone:ScaleTo(p)
	end

	if callback then
		callback(clone)
	end

	local emits = {}
	local beamFades = {}

	for _, effect in clone:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local emit = effect:GetAttribute("Emit") or effect:GetAttribute("EmitCount")
			local delay = effect:GetAttribute("Delay") or effect:GetAttribute("EmitDelay")

			if emit or delay then
				table.insert(emits, {
					Emitter = effect,
					Count = emit,
					Delay = delay
				})
			end
		elseif effect:IsA("Beam") then
			table.insert(beamFades, {
				Beam = effect,
				Width0 = effect.Width0,
				Width1 = effect.Width1
			})
		end
	end

	local main = clone:FindFirstChild("Main")
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
	local beamsAttachment

	if main then
		beamsAttachment = main:FindFirstChild("Beams")
	end

	return {
		Model = clone,
		Emits = emits,
		BeamFades = beamFades,
		BeamsAttachment = beamsAttachment,
		MainSize = not (main and main:IsA("BasePart")) and createVector(0, 0, 0) or main.Size
	}
end

local function TakeBurstEntry(player, p: string, p2: number, fn)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return nil
	end

	local ownerName = VisualHelper:OwnerName(player)
	local v2 = v[ownerName]

	if not v2 then
		v2 = {
			Rings = {},
			LastUse = 0,
			EvictScheduled = false
		}
		v[ownerName] = v2
	end

	v2.LastUse = os.clock()
	local v3 = v[ownerName]

	if v3 and not v3.EvictScheduled then
		v3.EvictScheduled = true
		task.delay(8, function()
			local v4 = v[ownerName]

			if not v4 then
				return
			end

			v4.EvictScheduled = false

			if os.clock() - v4.LastUse < 8 then
				ScheduleBurstEviction(ownerName)
				return
			end

			v[ownerName] = nil

			for _, ring in v4.Rings do
				for _, entry in ring.Entries do
					entry.Model:Destroy()
				end
			end
		end)
	end

	local ring = v2.Rings[p]

	if not ring then
		ring = {
			Entries = {},
			NextIndex = 1
		}
		v2.Rings[p] = ring
	end

	if #ring.Entries < p2 then
		local v4 = fn()
		table.insert(ring.Entries, v4)
		return v4
	else
		local entry = ring.Entries[ring.NextIndex]

		if not entry.Model.Parent then
			entry = fn()
			ring.Entries[ring.NextIndex] = entry
		end

		ring.NextIndex = ring.NextIndex % p2 + 1
		return entry
	end
end

local function EmitBurstEntry(p)
	for _, emit in p.Emits do
		local delay = emit.Delay

		if delay then
			local v2 = emit
			task.delay(delay, function()
				v2.Emitter:Emit(v2.Count)
			end)
		else
			emit.Emitter:Emit(emit.Count)
		end
	end
end

local function SmashBeams(cframe: CFrame, p: number?, playerFromCharacter)
	if not VisualHelper:VFXVisible(cframe.Position) then
		return
	end

	local clone = v_Katsuo.SmashBeams:Clone()

	if p then
		clone:ScaleTo(p)
	end

	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")

	if clone then
		task.delay(0.5, clone.Destroy, clone)
	end

	local frontWinds = clone.Main.FrontWinds
	VisualHelper:Tween(frontWinds, TweenInfo.new(0.21, Enum.EasingStyle.Sine), {
		Orientation = frontWinds.Orientation + createVector(0, 0, 250)
	})

	for _, child in frontWinds:GetChildren() do
		local beamMain = child.BeamMain
		beamMain.Enabled = true
		VisualHelper:Tween(beamMain, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, v2 in { clone.Main.CircleBeam.Beam1, clone.Main.CircleBeam.Beam2 } do
		v2.Enabled = true
		VisualHelper:Tween(v2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end
end

local function BoltsTrailsMove(worldPosition: Vector3, vector2: Vector3, p: number, duration: number, value: number?, player)
	if not (VisualHelper:VFXVisible(worldPosition) or VisualHelper:VFXVisible(vector2)) then
		return
	end

	for i = 1, p do
		local v2 = i % 2 == 0
		local v3 = (v2 and 0.35 or 0.2) + math.random() * 0.25
		local clone = (v2 and c_Katsuo.Vault.HexTrailSpecs3 or f_Katsuo.Vault.HexTrailSpecs):Clone()
		clone.WorldPosition = worldPosition
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
		local v4 = value or 5

		for _, effect in clone:GetChildren() do
			if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter")) then
				continue
			end

			local colorSequence = ColorSequence.new(Color3.fromRGB(135, 88, 255))

			if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
				colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
			end

			effect.Color = colorSequence
		end

		local v5 = v3 + 0.5

		if clone then
			if v5 and v5 > 0 then
				task.delay(v5, clone.Destroy, clone)
			else
				clone:Destroy()
			end
		end

		local v6 = CFrame.lookAt(vector2, worldPosition) * CFrame.new(
			math.random(-v4, v4),
			math.random(-v4, v4),
			math.random(15, 35)
		).Position
		local magnitude = (worldPosition - v6).Magnitude
		local cframe = CFrame.lookAt(worldPosition, v6)
		VisualHelper:MoveAlongBezierTrail(
			clone,
			v3,
			worldPosition,
			cframe * CFrame.new(math.random(-60, 60), math.random(-60, 60), -magnitude * 0.25).Position,
			cframe * CFrame.new(math.random(-60, 60), math.random(-60, 60), -magnitude * 0.75).Position,
			v6,
			function()
				VisualHelper:SetEnableAll(clone, false)
			end
		)

		if duration then
			task.wait(duration)
		end
	end
end

local function EmitExplosion(cFrame, flag: boolean?, value: string?, value2: number?, player)
	if not (cFrame and VisualHelper:VFXVisible(cFrame.Position)) then
		return
	end

	local v2 = typeof(cFrame) == "RaycastResult"
	cameraShaker:Shake("Fast")

	if v2 then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local v3

	if value == "Explosion" then
		v3 = TakeBurstEntry(player, `Explosion@{value2 or 0}`, 3, function()
			return (BuildBurstEntry(v_Katsuo.Explosion, value2, player, function(p)
				VisualHelper:ThinEmitBursts(p)

				for _, child in p.Main.Boom:GetChildren() do
					if child.Name == "Smoke" then
						child:Destroy()
					end
				end
			end))
		end)
	end

	local v4 = nil
	local mainSize, beamsAttachment, beamFades

	if v3 then
		v3.Model:PivotTo(cFrame)
		EmitBurstEntry(v3)
		mainSize = v3.MainSize
		beamsAttachment = v3.BeamsAttachment
		beamFades = v3.BeamFades
	else
		local clone = v_Katsuo[value or "Explosion"]:Clone()
		clone:PivotTo(cFrame)
		clone:ScaleTo(value2 or clone:GetScale())
		VisualHelper:ThinEmitBursts(clone)
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
		VisualHelper:EmitAll(clone)

		if clone then
			task.delay(6, clone.Destroy, clone)
		end

		mainSize = clone.Main.Size

		if value == "SliceExplosion" then
			local slashBeams = clone.Main.SlashBeams
			v4 = clone

			for i, child in slashBeams:GetChildren() do
				local beam = child.Beam
				beam.Enabled = true
				VisualHelper:Tween(beam, TweenInfo.new(0.2 + i * 0.075, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			local total = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if total >= 0.5 then
					heartbeatConnection:Disconnect()
				end

				for _, child in slashBeams:GetChildren() do
					child.CFrame *= CFrame.Angles(0, 25 * dt, 0)
				end

				total += dt
			end)
		else
			v4 = clone
		end

		local beams = clone.Main.Beams
		beamsAttachment = beams
		beamFades = {}

		for _, beam in beams:GetDescendants() do
			if beam:IsA("Beam") then
				table.insert(beamFades, {
					Beam = beam,
					Width0 = beam.Width0,
					Width1 = beam.Width1
				})
			end
		end

		if beams then
			task.delay(0.5, beams.Destroy, beams)
		end
	end

	if beamsAttachment then
		VisualHelper:Tween(beamsAttachment, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Orientation = beamsAttachment.Orientation + createVector(0, 550, 0)
		})
	end

	for _, beamFade in beamFades do
		local beam = beamFade.Beam
		local width0 = beamFade.Width0
		local width1 = beamFade.Width1
		beam.Width0 = width0
		beam.Width1 = width1
		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.2 + math.random() * 0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	local v5 = mainSize.X / 2
	local clone = c_Katsuo.BallNeon:Clone()
	clone.CFrame = cFrame
	clone.Transparency = 0.94
	local color = Color3.fromRGB(99, 60, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color = Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	clone.Color = color
	clone.Size = createVector(1, 1, 1) * (mainSize.Y * 0.65)
	clone.Parent = workspace.Terrain
	VisualHelper:Tween(clone, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Size = clone.Size * 1.35,
		Transparency = 1
	})

	if clone then
		task.delay(0.14, clone.Destroy, clone)
	end

	local clone2 = c_Katsuo.BallNeon:Clone()
	clone2.CFrame = cFrame
	clone2.Transparency = 0.85
	local color2 = Color3.fromRGB(170, 96, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	clone2.Color = color2
	clone2.Size = createVector(1, 1, 1) * mainSize.Y
	clone2.Parent = workspace.Terrain
	VisualHelper:Tween(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = clone2.Size * 1.6,
		Transparency = 1
	})

	if clone2 then
		task.delay(0.15, clone2.Destroy, clone2)
	end

	if flag then
		return
	end

	if v4 and value == "Explosion" then
		for _, child in v4.Main.Boom:GetChildren() do
			if child.Name == "Smoke" then
				child:Destroy()
			end
		end
	end

	task.spawn(function()
		for _ = 1, 3 do
			local v6 = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v5 + 5, v5 + 25)
			)
			local rayCast = MathHelper:RayCast(
				v6.Position,
				v6.UpVector * -10,
				{ workspace.Map },
				Enum.RaycastFilterType.Include
			)

			if rayCast then
				local cFrame2 = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				local takeBurstEntry = TakeBurstEntry(player, "BoltExplosion", 6, function()
					return (BuildBurstEntry(v_Katsuo.BoltExplosion, nil, player))
				end)

				if takeBurstEntry then
					takeBurstEntry.Model:PivotTo(cFrame2)
					EmitBurstEntry(takeBurstEntry)
				else
					local clone3 = v_Katsuo.BoltExplosion:Clone()
					clone3.CFrame = cFrame2
					Util.SetParentOverrideWithColor(clone3, workspace.Terrain, player, "ControlFruitVFXColor")
					VisualHelper:EmitAll(clone3)

					if clone3 then
						task.delay(1, clone3.Destroy, clone3)
					end
				end
			end

			task.wait(0.125)
		end
	end)
end

local function RushLink(position: Vector3, position2: Vector3, p: number?, value: number?, value2: number?, player)
	local DELAY_DURATION = 1

	if not (VisualHelper:VFXVisible(position) or VisualHelper:VFXVisible(position2)) then
		return
	end

	local cframe = CFrame.lookAt(position, position2)
	local magnitude = (position - position2).Magnitude
	local clone = v_Katsuo.RushLine:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, -(magnitude / 2))
	clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, magnitude)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
	local beams = clone.Beams
	local v2 = value2 or 1
	local v3 = value or 1

	for i, child in beams.Beams:GetChildren() do
		child.Enabled = true

		if child.Name == "Air" then
			VisualHelper:Tween(child, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		else
			local v4 = child.Name == "Fade"
			VisualHelper:Tween(
				child,
				TweenInfo.new(
					v4 and 0.3 or 0.2 + i * 0.015,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out,
					0,
					false,
					v4 and 0 or 0.075
				),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
		end
	end

	beams.Drag.Position = createVector(0, 0, 0)
	VisualHelper:Tween(beams.Drag, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
		Position = Vector3.new(0, 1, -magnitude * 0.75)
	})
	VisualHelper:EmitAll(clone)

	if clone then
		task.delay(1.5, clone.Destroy, clone)
	end

	if v2 > 0 then
		local clone2 = c_Katsuo.BallNeon:Clone()
		clone2.CFrame = cframe
		clone2.Transparency = 0
		local color = Color3.fromRGB(153, 124, 216)

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			color = Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
		end

		clone2.Color = color
		clone2.Size = createVector(45, 45, 0)
		clone2.Parent = workspace.Terrain
		VisualHelper:Tween(clone2, TweenInfo.new(0.2 * v2, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = cframe * CFrame.new(0, 0, -magnitude / 2)
		})

		if clone2 then
			task.delay(DELAY_DURATION, clone2.Destroy, clone2)
		end

		local clone3 = c_Katsuo.BallNeon:Clone()
		clone3.CFrame = cframe
		clone3.Transparency = 0.85
		local color2 = Color3.fromRGB(132, 93, 216)

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
		end

		clone3.Color = color2
		clone3.Size = createVector(72, 72, 0)
		clone3.Parent = workspace.Terrain
		VisualHelper:Tween(clone3, TweenInfo.new(0.15 * v2, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = cframe * CFrame.new(0, 0, -magnitude / 2)
		})

		if clone3 then
			task.delay(DELAY_DURATION, clone3.Destroy, clone3)
		end

		local clone4 = c_Katsuo.BallNeon:Clone()
		clone4.CFrame = cframe
		clone4.Transparency = -1.5
		clone4.Material = Enum.Material.ForceField
		local color3 = Color3.fromRGB(132, 93, 216)

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			color3 = Util.WrapColor3Constructor(color3, player, "ControlFruitVFXColor")
		end

		clone4.Color = color3
		clone4.Size = createVector(75, 75, 0)
		clone4.Parent = workspace.Terrain
		VisualHelper:Tween(clone4, TweenInfo.new(0.27 * v2, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = cframe * CFrame.new(0, 0, -magnitude / 2),
			Transparency = 1
		})

		if clone4 then
			task.delay(DELAY_DURATION, clone4.Destroy, clone4)
		end
	end

	task.delay(0.1, function()
		local clone2 = v_Katsuo.SmashMeshs:Clone()
		clone2:PivotTo(cframe * CFrame.new(0, 0, -magnitude * 0.5) * CFrame.Angles(1.5707963267948966, 0, 0))
		clone2:ScaleTo(p or clone2:GetScale())
		Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player, "ControlFruitVFXColor")

		if clone2 then
			task.delay(1, clone2.Destroy, clone2)
		end

		local airMeshHuge = clone2.AirMeshHuge
		local tweenInfo = TweenInfo.new(0.12 * v3, Enum.EasingStyle.Sine)
		VisualHelper:Tween(airMeshHuge.Mesh, tweenInfo, {
			Scale = airMeshHuge.Mesh.Scale * createVector(2, 1.25, 2)
		})
		VisualHelper:Tween(airMeshHuge.Decal, tweenInfo, {
			Transparency = 1
		})
		local airMeshStorm = clone2.AirMeshStorm
		local tweenInfo2 = TweenInfo.new((p and 0.075 or 0.4) * v3, Enum.EasingStyle.Sine)
		VisualHelper:Tween(airMeshStorm.Mesh, tweenInfo2, {
			Scale = airMeshStorm.Mesh.Scale * createVector(0.2, 1.3, 0.2)
		})
		VisualHelper:Tween(airMeshStorm.Decal, tweenInfo2, {
			Transparency = 1
		})
		VisualHelper:Tween(airMeshStorm, tweenInfo2, {
			CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		local bodyFlash = clone2.BodyFlash
		local tweenInfo3 = TweenInfo.new(0.25 * v3, Enum.EasingStyle.Sine)
		VisualHelper:Tween(bodyFlash.Decal, tweenInfo3, {
			Transparency = 1
		})
		VisualHelper:Tween(bodyFlash.Mesh, tweenInfo3, {
			Scale = bodyFlash.Mesh.Scale * createVector(3, 1.8, 3)
		})
		local airMeshHuge2 = clone2.AirMeshHuge2
		local tweenInfo4 = TweenInfo.new(0.35 * v3, Enum.EasingStyle.Sine)
		VisualHelper:Tween(airMeshHuge2.Mesh, tweenInfo4, {
			Scale = airMeshHuge2.Mesh.Scale * createVector(2, 1.25, 2)
		})
		VisualHelper:Tween(airMeshHuge2.Decal, tweenInfo4, {
			Transparency = 1
		})
		local airMeshHuge4 = clone2.AirMeshHuge4
		local tweenInfo5 = TweenInfo.new(0.4 * v3, Enum.EasingStyle.Cubic)
		VisualHelper:Tween(airMeshHuge4.Mesh, tweenInfo5, {
			Scale = airMeshHuge4.Mesh.Scale * createVector(3, 1.4, 3)
		})
		VisualHelper:Tween(airMeshHuge4.Decal, tweenInfo5, {
			Transparency = 1
		})
		local circleWave = clone2.CircleWave
		local size = circleWave.Size
		circleWave.Size = size * 0.5
		VisualHelper:Tween(circleWave, TweenInfo.new(0.25 * v3, Enum.EasingStyle.Sine), {
			CFrame = circleWave.CFrame * CFrame.new(0, 3, 0),
			Transparency = 1,
			Size = size
		})
	end)
end

local function EmitAuraExplosion(cframe: CFrame, p: number, playerFromCharacter)
	local clone = v_Katsuo.AuraExplosion:Clone()
	clone:ScaleTo(p)
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
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

local function EmitFloor(cFrame: CFrame, p)
	local clone = v_Katsuo.FloorSpawnEnd:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, p, "ControlFruitVFXColor")
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

local function DarkSlash(cFrame: CFrame, rotation: number?, flag: boolean?, scale: number?, playerFromCharacter)
	local clone = v_Katsuo.DarkSlash:Clone()
	clone:ScaleTo(scale or 1.65)
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
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

local function NewBolt(attachment, attachment2, value: number?, player)
	local v2 = lightningBoltShafi.new(attachment, attachment2, value or 35, 0.7, workspace.Terrain)
	local curveSize = math.random(15, 25)
	local curveSize2 = math.random(15, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 5
	v2.MaxRadius = 15
	v2.Frequency = 0.5
	v2.AnimationSpeed = math.random(5, 9)
	local maxThicknessMultiplier = 0.3 + math.random() * 0.75
	v2.MinThicknessMultiplier = 0.1
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 40
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 153, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(203, 158, 255))
	})

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
	end

	v2.Color = colorSequence
	v2.ContractFrom = 0.5
	v2.ColorOffsetSpeed = 3
	return v2
end

local v2 = {
	{
		Angle = 27,
		RayDirection = -1,
		Rotation = 130,
		Scale = 5
	},
	{
		Angle = -27,
		RayDirection = 1,
		Rotation = -130,
		Scale = 5
	}
}
local v3 = {
	Enum.NormalId.Front,
	Enum.NormalId.Back,
	Enum.NormalId.Left,
	Enum.NormalId.Right
}
local PreAnimations = {}

function PreAnimations.Rush(_, adornee, cframe: CFrame, p, cframe2: CFrame)
	local WAIT_INTERVAL = 0.05
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(adornee)
	local humanoidRootPart = adornee.HumanoidRootPart
	humanoidRootPart.Anchored = true

	local function GetCFrameFromRayCast(raycastResult: RaycastResult)
		return raycastResult and CFrame.new(CFrame.lookAt(
			raycastResult.Position,
			raycastResult.Position + raycastResult.Normal
		) * CFrame.new(0, 0, -3).Position) * CFrame.Angles(humanoidRootPart.CFrame:ToEulerAnglesXYZ())
	end

	if not GetCFrameFromRayCast(MathHelper:RayCast(
		humanoidRootPart.CFrame.Position,
		cframe.LookVector * 353,
		{ workspace.Map },
		Enum.RaycastFilterType.Include
	)) then
		local _ = cframe * CFrame.new(0, 0, -350)
	end

	VisualHelper:ModelTransparency(adornee, 1)
	local position = humanoidRootPart.Position
	local v5 = { workspace.Map }
	EmitExplosion(
		MathHelper:RayCast(position, createVector(-0, -5, -0), v5, Enum.RaycastFilterType.Include),
		nil,
		nil,
		nil,
		playerFromCharacter
	)
	task.wait(0.1)
	EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 4, playerFromCharacter)
	StormBeamPattern(humanoidRootPart.CFrame, 2, playerFromCharacter)
	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), nil, nil, nil, playerFromCharacter)
	task.wait(0.2)
	cameraShaker:Shake("Pilar Hard")
	local position2 = humanoidRootPart.Position
	RushLink(position2, cframe2.Position, nil, nil, nil, playerFromCharacter)
	task.delay(0.1, BoltsTrailsMove, position2, cframe2.Position, 10, 0.01)
	task.wait(WAIT_INTERVAL)
	SmashBeams(cframe * CFrame.new(0, 0, -192.50000000000003), 3.5, playerFromCharacter)
	VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.15), {
		CFrame = cframe2
	})
	task.wait(0.15)
	EmitAuraExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), 6, playerFromCharacter)
	task.wait(WAIT_INTERVAL)
	StormBeamPattern(humanoidRootPart.CFrame, 2, playerFromCharacter)
	task.wait(WAIT_INTERVAL)
	VisualHelper:ModelTransparency(adornee, 0)
	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), nil, nil, nil, playerFromCharacter)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = adornee
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	local color = Color3.fromRGB(154, 96, 255)

	if typeof(playerFromCharacter) == "Instance" and playerFromCharacter:IsA("Player") and playerFromCharacter.Parent then
		color = Util.WrapColor3Constructor(color, playerFromCharacter, "ControlFruitVFXColor")
	end

	highlight.FillColor = color
	highlight.Parent = workspace.Terrain
	VisualHelper:Tween(highlight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		FillTransparency = 1
	})

	if highlight then
		task.delay(0.2, highlight.Destroy, highlight)
	end

	humanoidRootPart.Anchored = false
	return p
end

function PreAnimations.Lunge(_, character, instance, _, p)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)
	local humanoidRootPart = character.HumanoidRootPart
	local v4

	if typeof(instance) == "table" then
		v4 = instance.__type == "Object"
	else
		v4 = false
	end

	local cFrame

	if v4 then
		local v6 = p or v3[math.random(#v3)]
		local vector2 = Vector3.FromNormalId(v6)
		cFrame = CFrame.lookAt(
			instance:GetPivot() * CFrame.new(vector2 * instance:GetSize().X / 2).Position,
			instance:GetPivot().Position
		) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 3, 0)
	else
		cFrame = instance.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0)
	end

	local position = humanoidRootPart.Position
	local position2 = cFrame.Position
	local magnitude = (position - position2).Magnitude
	local cframe = CFrame.lookAt(position, position2)
	local v6 = VisualHelper:VFXVisible(position) or VisualHelper:VFXVisible(position2)
	local clone

	if v6 then
		clone = v_Katsuo.Vault.Aim:Clone()
		clone.WorldCFrame = cframe * CFrame.new(0, 0, -magnitude + 2)
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
		VisualHelper:Emit(clone.Focus)
	end

	if v4 and v6 then
		instance:Flash(Color3.fromRGB(164, 111, 255))
	end

	task.wait(0.05)

	if v4 and v6 then
		VisualHelper:Tween(
			instance.Model.Main,
			TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
			{
				Size = instance:GetSize() * 1.3
			}
		)
		instance:Flash(Color3.fromRGB(164, 111, 255))
	end

	local v7

	if v6 then
		v7 = VisualHelper:BlinkHideModel(character)
	end

	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), false, "Explosion", 3, playerFromCharacter)
	RushLink(position, position2, 1.95, 2.1, 1.35, playerFromCharacter)
	SmashBeams(cframe * CFrame.new(0, 0, -magnitude * 0.5), 5.15, playerFromCharacter)
	local position3 = humanoidRootPart.Position
	local position4 = cFrame.Position

	if v6 then
		for _ = 1, 2 do
			local clone2 = v_Katsuo.Vault.TrailSpecsFast:Clone()
			clone2.WorldPosition = position3
			Util.SetParentOverrideWithColor(clone2, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
			VisualHelper:MoveAlongBezierTrail(
				clone2,
				0.25,
				position3,
				cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.25).Position,
				cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.75).Position,
				position4
			)

			if clone2 then
				task.delay(0.25, clone2.Destroy, clone2)
			end
		end

		task.delay(0.1, BoltsTrailsMove, position3, position4, 5, 0.01)
	end

	VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
		CFrame = cFrame
	})
	task.wait(0.05)
	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), false, "Explosion", 3, playerFromCharacter)

	if v7 then
		VisualHelper:BlinkShowModel(character, v7)
	end

	if clone then
		VisualHelper:SetEnableAll(clone, false)

		if clone then
			task.delay(1, clone.Destroy, clone)
		end
	end

	return cFrame.Position
end

function PreAnimations.Unjoint(_, folder)
	local result = {}

	for i, motor6D in folder:GetDescendants() do
		local parent = motor6D.Parent

		if not (motor6D:IsA("Motor6D") and parent.Parent == folder) then
			continue
		end

		local v4 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)) * CFrame.Angles(
			math.random() * 3.141592653589793 / 4,
			math.random() * 3.141592653589793 / 4,
			math.random() * 3.141592653589793 / 4
		)
		local clone

		if parent:IsA("BasePart") and not parent:FindFirstChild("SingleBodyPattern") then
			clone = v_Katsuo.Vault.SingleBodyPattern:Clone()
			clone.Parent = parent
		end

		result[motor6D] = {
			C0 = motor6D.C0,
			C1 = motor6D.C1,
			SingleBodyPattern = clone,
			Tween = VisualHelper:Tween(
				motor6D,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, i * 0.05),
				{
					C1 = motor6D.C1 * v4
				}
			)
		}
	end

	return result
end

function PreAnimations.Rejoint(_, items)
	for k, item in items do
		if item.Tween.PlaybackState == Enum.PlaybackState.Playing then
			item.Tween:Cancel()
		end

		VisualHelper:Tween(
			k,
			TweenInfo.new(
				0.25 + math.random() * 0.15,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.In,
				0,
				false,
				math.random() * 0.15
			),
			{
				C1 = item.C1,
				C0 = item.C0
			}
		)
		local singleBodyPattern = item.SingleBodyPattern

		if not singleBodyPattern then
			continue
		end

		local singleBodyPattern2 = singleBodyPattern
		task.delay(0.35, function()
			VisualHelper:SetEnableAll(singleBodyPattern2, false)
			task.wait(0.5)
			singleBodyPattern2:Destroy()
		end)
	end
end

function PreAnimations.FinalRush(_, character, p, p2, p3)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)
	local v4 = p3 or camera
	local humanoidRootPart = character.HumanoidRootPart
	humanoidRootPart.Anchored = true
	local humanoidRootPart2 = p.HumanoidRootPart
	local _, v5 = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position):ToEulerAnglesYXZ()
	humanoidRootPart2.CFrame = CFrame.new(humanoidRootPart2.Position) * CFrame.Angles(0, v5 + 3.141592653589793, 0)
	humanoidRootPart2.CFrame = p2.RushTeleportCFrame * CFrame.new(0, 0, -2)
	local rushTeleportCFrame = p2.RushTeleportCFrame
	local position = humanoidRootPart.Position
	local position2 = rushTeleportCFrame.Position
	local magnitude = (position - position2).Magnitude
	local cframe = CFrame.lookAt(position, position2)
	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), false, "Explosion", 3, playerFromCharacter)
	local clone = v_Katsuo.Vault.Aim:Clone()
	clone.WorldCFrame = rushTeleportCFrame
	clone.Parent = workspace.Terrain
	VisualHelper:Emit(clone.Focus)
	task.delay(0.2, function()
		VisualHelper:SetEnableAll(clone, false)
		task.wait(1)
		clone:Destroy()
	end)
	task.wait(0.1)
	local cFrame = cframe * CFrame.new(0, 0, -magnitude * 0.45)
	RushLink(position, cFrame.Position, 1.95, 2.1, 1.35, playerFromCharacter)
	SmashBeams(cFrame, 5.15, playerFromCharacter)
	task.delay(0.1, BoltsTrailsMove, position, cFrame.Position, 5, 0.01)
	humanoidRootPart.CFrame = cFrame
	local v7 = {}

	for _, v8 in v2 do
		local C1 = CFrame.new(0, 0, -13) * CFrame.Angles(0, 0, (math.rad(v8.Angle)))
		local clone2 = v_Katsuo.CrossSlashCharacter:Clone()
		clone2.GroundPart:Destroy()
		clone2:PivotTo(humanoidRootPart.CFrame * C1)
		clone2:ScaleTo(3)
		VisualHelper:ThinEmitBursts(clone2)
		local main = clone2.Main
		main.Anchored = false
		main.Massless = true
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, playerFromCharacter, "ControlFruitVFXColor")
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = main
		weld.C1 = C1
		weld.Parent = main
		local charge = main.Charge
		local windStorm = charge.WindStorm
		VisualHelper:Tween(windStorm, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = windStorm.Orientation - createVector(0, 360, 0)
		})
		local hexTrail = charge.TrailsBeam.Point1.HexTrail
		local thread = task.spawn(function()
			while true do
				for k, texture in Textures.HexTrailBeam do
					hexTrail.Texture = texture
					task.wait(0.041666666666666664)
				end
			end
		end)
		local beam = charge.TrailsBeam.Point3.Beam
		v7[clone2] = {
			Thread0 = thread,
			Thread1 = task.spawn(function()
				while true do
					for k, texture in Textures.WindBeam do
						beam.Texture = texture
						task.wait(0.02)
					end
				end
			end)
		}
	end

	VisualHelper:Tween(v4, TweenInfo.new(0.4166666666666667, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		FieldOfView = 40,
		CFrame = v4.CFrame * CFrame.new(0, 0, -(v4.CFrame.Position - p2.RushTeleportCFrame.Position).Magnitude * 0.8)
	})
	VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.4166666666666667, Enum.EasingStyle.Sine), {
		CFrame = cframe * CFrame.new(0, 0, -magnitude)
	})
	local clone2 = v_Katsuo.FrontalBeams:Clone()
	clone2.Weld.Part1 = humanoidRootPart
	clone2.Parent = workspace._WorldOrigin
	task.delay(0.1, BoltsTrailsMove, cFrame.Position, position2, 10, 0.01)
	task.wait(0.25)
	EmitAuraExplosion(rushTeleportCFrame * CFrame.new(0, -2.8, 0), 11, playerFromCharacter)
	SmashBeams(humanoidRootPart.CFrame, 4.5, playerFromCharacter)
	task.wait(0.16666666666666669)
	EmitAuraExplosion(rushTeleportCFrame * CFrame.new(0, -2.8, 0), 20, playerFromCharacter)

	for k, v8 in v7 do
		k:Destroy()
		task.cancel(v8.Thread0)
		task.cancel(v8.Thread1)
	end

	clone2:Destroy()
	humanoidRootPart.CFrame = rushTeleportCFrame
	VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
		CFrame = rushTeleportCFrame
	})
end

function PreAnimations.CrossSlash(_, adornee, p, p2)
	local DELAY_DURATION = 3
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(adornee)
	local humanoidRootPart = adornee.HumanoidRootPart
	humanoidRootPart.Anchored = true
	local humanoidRootPart2 = p.HumanoidRootPart
	cameraShaker:Shake("Pilar Hard")
	EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), nil, nil, nil, playerFromCharacter)
	local _, v4 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
	local position = humanoidRootPart.Position
	local highlight = Instance.new("Highlight")
	highlight.Adornee = adornee
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	local color = Color3.fromRGB(154, 96, 255)

	if typeof(playerFromCharacter) == "Instance" and playerFromCharacter:IsA("Player") and playerFromCharacter.Parent then
		color = Util.WrapColor3Constructor(color, playerFromCharacter, "ControlFruitVFXColor")
	end

	highlight.FillColor = color
	highlight.Parent = workspace.Terrain
	VisualHelper:Tween(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		FillTransparency = 1
	})

	if highlight then
		task.delay(0.3, highlight.Destroy, highlight)
	end

	task.wait(0.15)

	for _, v5 in v2 do
		DarkSlash(
			humanoidRootPart.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, 3.141592653589793, (math.rad(v5.Angle))),
			v5.Rotation,
			true,
			v5.Scale,
			playerFromCharacter
		)
		task.wait(0.012)
	end

	cameraShaker:Shake("Pilar Hard")
	VisualHelper:Tween(camera, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		FieldOfView = 70
	})
	local clone = v_Katsuo.FinalRush:Clone()
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -20)
	VisualHelper:ThinEmitBursts(clone)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
	VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	VisualHelper:EmitAll(clone)

	if clone then
		task.delay(1, clone.Destroy, clone)
	end

	local clone2 = f_Katsuo.SmashMeshs.AirMeshHuge4:Clone()
	clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(-1.5707963267948966, 0, 0)
	Util.SetParentOverrideWithColor(clone2, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
	VisualHelper:Tween(clone2.Mesh, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
		Scale = clone2.Mesh.Scale * createVector(2.5, 1.9, 2.5)
	})
	VisualHelper:Tween(clone2.Decal, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
		Transparency = 1
	})

	if clone2 then
		task.delay(1, clone2.Destroy, clone2)
	end

	SmashBeams(humanoidRootPart.CFrame * CFrame.new(0, 0, -6), 2.5, playerFromCharacter)
	local knockbackCFrame = p2.KnockbackCFrame
	local magnitude = (knockbackCFrame.Position - humanoidRootPart.Position).Magnitude
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	VisualHelper:Tween(humanoidRootPart2, tweenInfo, {
		CFrame = knockbackCFrame
	})
	local tweenInfo2 = TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine)
	local v5 = {}

	for _, v6 in v2 do
		local clone3 = v_Katsuo.CrossSlash:Clone()
		VisualHelper:CapEmitterRates(clone3, 12)
		clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(math.sign(v6.Angle) * 5, 10.125, -6) * CFrame.Angles(
			0,
			0,
			(math.rad(v6.Angle))
		))
		Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, playerFromCharacter, "ControlFruitVFXColor")
		VisualHelper:TweenModel(clone3.Main, tweenInfo, clone3.Main.Main.CFrame * CFrame.new(0, 0, -magnitude))
		VisualHelper:TweenScale(clone3, tweenInfo, clone3:GetScale() * 1.5 * 1.35)
		local charge = clone3.Main.Main.Charge
		local windStorm = charge.WindStorm
		VisualHelper:Tween(windStorm, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = windStorm.Orientation - createVector(0, 360, 0)
		})
		local hexTrail = charge.TrailsBeam.Point1.HexTrail
		local thread = task.spawn(function()
			while true do
				for k, texture in Textures.HexTrailBeam do
					hexTrail.Texture = texture
					task.wait(0.041666666666666664)
				end
			end
		end)
		local beam = charge.TrailsBeam.Point3.Beam
		local thread2 = task.spawn(function()
			while true do
				for k, texture in Textures.WindBeam do
					beam.Texture = texture
					task.wait(0.02)
				end
			end
		end)
		local smokes = clone3.GroundPart.Smokes
		smokes.Parent = workspace.Terrain
		v5[clone3] = {
			Thread0 = thread,
			Thread1 = thread2,
			RayDirection = v6.RayDirection,
			Smokes = smokes,
			Origin = clone3:GetPivot().Position
		}
	end

	task.spawn(BoltsTrailsMove, position, knockbackCFrame.Position, 10, 0.01, nil, playerFromCharacter)
	local clone3 = v_Katsuo.SliceBall:Clone()
	clone3:ScaleTo(0.7)
	VisualHelper:CapEmitterRates(clone3, 12)
	Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, playerFromCharacter, "ControlFruitVFXColor")
	clone3.Main.Anchored = false
	local flash = clone3.Main.Flash
	flash.Parent = workspace.Terrain
	flash.WorldCFrame = humanoidRootPart2.CFrame
	VisualHelper:EmitAll(flash)
	local v6 = HexsStormClass.new(clone3.Main, nil, playerFromCharacter)
	v6.YFactor = clone3.Main.Size.Y / 2

	for i = -1, 1, 0.2 do
		v6:AddHex("Dagger", i, v6.YFactor * 2, i * 360, random:NextNumber(50, 450))
	end

	for k in v6.Data do
		k.Size *= 3.25
	end

	local total = 0
	local clone4 = v_Katsuo.CameraEffects:Clone()
	Util.SetParentOverrideWithColor(clone4, camera, playerFromCharacter, "ControlFruitVFXColor")

	if game.Players:GetPlayerFromCharacter(adornee) and game.Players:GetPlayerFromCharacter(adornee) == game.Players.LocalPlayer then
		VisualHelper:SetEnableAll(clone4, true)
		VisualHelper:EmitAll(clone4)
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total += dt
		clone4.CFrame = camera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
		v6:Update(dt)

		for k, v7 in v5 do
			local groundPart = k.GroundPart
			local smokes = v7.Smokes
			local v8 = k.Main.Main.Size.X / 2 + 1.5
			local rayCast = MathHelper:RayCast(
				k.Main.Main.Position,
				k.Main.Main.CFrame.RightVector * (v8 * v7.RayDirection),
				{ workspace.Terrain, adornee }
			)

			if rayCast then
				groundPart.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.15, 0)) * CFrame.Angles(0, v4, 0)
				smokes.WorldCFrame = groundPart.CFrame

				if not v7.GroundPartEnabled then
					v7.GroundPartEnabled = true
					VisualHelper:SetEnableAll(groundPart, v7.GroundPartEnabled)
					VisualHelper:SetEnableAll(smokes, v7.GroundPartEnabled)
				end
			elseif v7.GroundPartEnabled then
				v7.GroundPartEnabled = false
				VisualHelper:SetEnableAll(groundPart, v7.GroundPartEnabled)
				VisualHelper:SetEnableAll(smokes, v7.GroundPartEnabled)
			end
		end

		if total < 0.1 then
			return
		end

		total = 0

		if not clone3 then
			return
		end

		cameraShaker:Shake("Fast Hard")
		local v7 = clone3.Main.Size.X * 2

		for i = 1, 2 do
			local v8 = 0.2 + math.random(5) * 0.03 - i * 0.05
			local worldPosition = clone3.Main.Position + Vector3.new(
				math.random(-v7, v7),
				math.random(-v7, v7),
				math.random(-v7, v7)
			)
			local position2 = clone3.Main.Position
			local clone5 = v_Katsuo.Vault.HexTrailSpecsMove:Clone()
			Util.SetParentOverrideWithColor(clone5, workspace.Terrain, playerFromCharacter, "ControlFruitVFXColor")
			clone5.WorldPosition = worldPosition
			local v10 = v8 + 0.5

			if clone5 then
				if v10 and v10 > 0 then
					task.delay(v10, clone5.Destroy, clone5)
				else
					clone5:Destroy()
				end
			end

			local magnitude2 = (worldPosition - position2).Magnitude
			local cframe = CFrame.lookAt(worldPosition, position2)
			VisualHelper:MoveAlongBezierTrail(
				clone5,
				v8,
				worldPosition,
				cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude2 * 0.25).Position,
				cframe * CFrame.new(math.random(-65, 65), math.random(-65, 65), -magnitude2 * 0.75).Position,
				position2
			)
		end
	end)
	VisualHelper:TweenScale(clone3, tweenInfo2, clone3:GetScale() * 1.4 * 1.35)
	task.wait(tweenInfo2.Time)
	local tweenInfo3 = TweenInfo.new(0.19999999999999998, Enum.EasingStyle.Sine)
	VisualHelper:TweenScale(clone3, tweenInfo3, 0.2)

	for k in v5 do
		VisualHelper:TweenScale(k, tweenInfo3, k:GetScale() * 1.5 * 1.35)
	end

	task.wait(tweenInfo3.Time)

	for k, v7 in v5 do
		VisualHelper:TweenScale(k, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), 0.01)
		local v8 = k
		local v9 = v7
		task.delay(0.2, function()
			v5[v8] = nil
			v8:Destroy()
			v9.Smokes:Destroy()
			task.cancel(v9.Thread0)
			task.cancel(v9.Thread1)
		end)
	end

	cameraShaker:Shake("Pilar Hard")
	task.wait(0.175)

	for k in v6.Data do
		VisualHelper:Tween(k, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
			Size = createVector(0, 0, 0)
		})
	end

	if v6 then
		task.delay(0.5, v6.Destroy, v6)
	end

	flash.WorldCFrame = humanoidRootPart2.CFrame
	VisualHelper:EmitAll(flash)

	if flash then
		task.delay(2, flash.Destroy, flash)
	end

	clone3:Destroy()
	clone3 = nil
	cameraShaker:Shake("Pilar Hard")
	local cFrame = humanoidRootPart2.CFrame
	local clone5 = v_Katsuo.TargetExplosion:Clone()
	clone5.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	VisualHelper:ThinEmitBursts(clone5)
	Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, playerFromCharacter, "ControlFruitVFXColor")
	Util.Sound:Play("DomainExpansion_FinalExplosion_01", clone5.Position)
	VisualHelper:EmitAll(clone5)

	if clone5 then
		task.delay(DELAY_DURATION, clone5.Destroy, clone5)
	end

	local beams = clone5.Beams
	VisualHelper:Tween(beams, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Orientation = beams.Orientation + createVector(0, 360, 0)
	})

	for _, beam in beams:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.15 + math.random(3) * 0.05, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	task.delay(
		0.15,
		SmashBeams,
		cFrame * CFrame.new(0, 0, -8) * CFrame.Angles(0, 3.141592653589793, 0),
		3.5,
		playerFromCharacter
	)
	task.delay(0.1, StormBeamPattern, clone5.CFrame, 3.5, playerFromCharacter)
	local attachment = Instance.new("Attachment", humanoidRootPart2)

	if attachment then
		task.delay(DELAY_DURATION, attachment.Destroy, attachment)
	end

	for i = 1, 10 do
		local worldPosition = CFrame.new(clone5.Position) * CFrame.Angles(
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793 * 2,
			0
		) * CFrame.new(0, 0, -math.random(55, 90)).Position
		local attachment2 = Instance.new("Attachment", workspace.Terrain)
		attachment2.WorldPosition = worldPosition
		local newBolt = NewBolt(attachment, attachment2, 10, playerFromCharacter)
		local v9 = i * 0.045 + 0.15

		if newBolt then
			if v9 and v9 > 0 then
				task.delay(v9, newBolt.Destroy, newBolt)
			else
				newBolt:Destroy()
			end
		end

		if attachment2 then
			task.delay(DELAY_DURATION, attachment2.Destroy, attachment2)
		end
	end

	clone4:Destroy()
	renderSteppedConnection:Disconnect()
	humanoidRootPart.Anchored = false
end

return PreAnimations