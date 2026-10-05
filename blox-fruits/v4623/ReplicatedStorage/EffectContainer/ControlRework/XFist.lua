local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xFist = FX:WaitForChild("ControlRework").XFist
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
local ObjectExplosion = require(script.Parent:WaitForChild("ObjectExplosion"))
local Effect = require(ReplicatedStorage.Effect)
local _WorldOrigin = workspace._WorldOrigin

function Debris(p, p2: number)
	if not p then
		return
	end

	Util.Debris:AddItem(p, p2)
end

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function EmitFloor(cFrame: CFrame, player)
	local clone = xFist.Phase0.FloorSpawnEnd:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	clone.PointLight.Enabled = true
	VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	Debris(clone, 2.15)
end

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

local function Flash(root, flag: boolean, player)
	local clone = xFist.Phase0.VaultF.Flash:Clone()
	Util.SetParentOverrideWithColor(clone, root, player, "ControlFruitVFXColor")

	for _, descendant in clone:GetDescendants() do
		descendant:Emit(descendant:GetAttribute("Emit"))
		descendant.LockedToPart = flag or false
	end

	Debris(clone, 0.6)
end

local function EmitExplosion(cFrame, flag: boolean?, player)
	if not cFrame then
		return
	end

	local v = typeof(cFrame) == "RaycastResult"
	Util.CameraShaker:Shake("Fast")

	if v then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local clone = xFist.Phase0.Explosion:Clone()
	clone:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")

	if not v then
		clone.Main.GlowShape.Crater:Destroy()
	end

	VisualHelper:EmitAll(clone)
	Debris(clone, 6)
	local v2 = clone.Main.Size.X / 2
	local beams = clone.Main.Beams
	VisualHelper:Tween(beams, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Orientation = beams.Orientation + createVector(0, 550, 0)
	})

	for _, beam in beams:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.2 + math.random() * 0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	Debris(beams, 0.5)
	local clone2 = xFist.Phase0.BallNeon:Clone()
	clone2.CFrame = cFrame
	clone2.Transparency = 0.94
	local color = Color3.fromRGB(89, 133, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color = Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	clone2.Color = color
	clone2.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
	clone2.Parent = workspace.Terrain
	VisualHelper:Tween(clone2, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Size = clone2.Size * 1.35,
		Transparency = 1
	})
	Debris(clone2, 0.14)
	local clone3 = xFist.Phase0.BallNeon:Clone()
	clone3.CFrame = cFrame
	clone3.Transparency = 0.85
	local color2 = Color3.fromRGB(89, 133, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	clone3.Color = color2
	clone3.Size = createVector(1, 1, 1) * clone.Main.Size.Y
	clone3.Parent = workspace.Terrain
	VisualHelper:Tween(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = clone3.Size * 1.6,
		Transparency = 1
	})
	Debris(clone3, 0.15)

	if flag then
		return
	end

	for _, child in clone.Main.Boom:GetChildren() do
		if child.Name == "Smoke" then
			child:Destroy()
		end
	end

	task.spawn(function()
		for _ = 1, 3 do
			local v3 = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v2 + 5, v2 + 25)
			)
			local rayCast = MathHelper:RayCast(
				v3.Position,
				v3.UpVector * -10,
				{ workspace.Map },
				Enum.RaycastFilterType.Include
			)

			if rayCast then
				local clone4 = xFist.Phase0.BoltExplosion:Clone()
				clone4.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone4)
				Debris(clone4, 1)
			end

			task.wait(0.125)
		end
	end)
end

Random.new()

local function ScaledCloneRequest(template, p2: number)
	return {
		Template = template,
		Prepare = function(instance)
			instance:ScaleTo(p2)
		end
	}
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	if player.Stage == 1 then
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		Util.Debris:AddItem(model, 10)
		local player2 = player.Player
		local targetObjects = player.TargetObjects
		local v, v2, v3

		if player.EnemyChar then
			v = nil
			v2 = nil
			v3 = nil
		else
			local v4 = table.create(#targetObjects)
			local v5 = table.create(#targetObjects)
			local v6 = table.create(#targetObjects)

			for i = 1, #targetObjects do
				local targetObject = targetObjects[i]
				local v7 = not targetObject and 1 or targetObject:GetAttribute("SizeScale") or 1
				v4[i] = {
					Template = ObjectClass.TemplateModel,
					Prepare = function(instance)
						instance:ScaleTo(v7)
					end
				}
				local expansionExplosion = xFist.Phase0.ExpansionExplosion
				local v10 = v7 * 1.5
				v5[i] = {
					Template = expansionExplosion,
					Prepare = function(instance)
						instance:ScaleTo(v10)
					end
				}
				local expansionExplosion2 = xFist.Phase0.ExpansionExplosion
				local v12 = v7 * 1.25 * 1.5
				v6[i] = {
					Template = expansionExplosion2,
					Prepare = function(instance)
						instance:ScaleTo(v12)
					end
				}
			end

			v = PrepareClonedInstances.new(v4)
			v2 = PrepareClonedInstances.new(v5)
			v3 = PrepareClonedInstances.new(v6)
			model.Destroying:Once(function()
				v:Destroy()
				v2:Destroy()
				v3:Destroy()
			end)
		end

		local character = player.Character
		local root = player.Root
		local cFrame = player.CFrame or root.CFrame
		local xZCFrame = player.XZCFrame or root.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		VisualHelper:Tween(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Sine), {
			FieldOfView = 76
		})
		local clone = xFist.Phase0.ShaderScreen:Clone()
		clone.Image.ImageTransparency = 1
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local v4

		if player.Player == game.Players.LocalPlayer then
			v4 = player.Player:FindFirstChild("PlayerGui") or model
		else
			v4 = model
		end

		setParentOverrideWithColor(clone, v4, player.Player, "ControlFruitVFXColor")
		VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.86
		})
		local random = Random.new()
		local clone2 = xFist.Phase0.DoubleNeonEye:Clone()
		clone2.Anchored = false
		clone2.Weld.Part0 = character.Head
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
		VisualHelper:SetEnableAll(clone2, true)
		EmitFloor(cFrame * CFrame.new(0, -2.8, 0), player.Player)
		local clone3 = xFist.Phase0.NeonRotation:Clone()
		clone3:ScaleTo(1.2)
		clone3.Main.Anchored = false
		clone3.Main.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
		clone3.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)
		Util.Sound:Play("HandsX_ReleaseShockwave_01", root)

		for i, child in clone3.Main.Layers:GetChildren() do
			child.Orientation *= 1.5
			child.Position *= 1.5
			local beam = child.Beam
			local width = beam.Width0 / 2
			local width2 = beam.Width1 / 2
			beam.Width0 = width
			beam.Width1 = width2
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

		Debris(clone3, 2)
		task.wait(0.1)
		Util.CameraShaker:Shake("Pilar Hard")
		local clone4 = xFist.Phase0.CameraEffectsHex:Clone()
		Util.SetParentOverrideWithColor(clone4, currentCamera, player.Player, "ControlFruitVFXColor")

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(clone4, true)
			VisualHelper:EmitAll(clone4)
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
		end)

		local function HexWaveMeshs(value: number)
			local v5 = value or 1
			local clone5 = xFist.Phase0.HexWaveMeshs:Clone()
			clone5:PivotTo(cFrame * CFrame.new(0, 0, -55) * CFrame.Angles(1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
			Debris(clone5, 1)
			local airMeshHuge = clone5.AirMeshHuge
			VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(v5 * 0.3, Enum.EasingStyle.Sine), {
				Scale = airMeshHuge.Mesh.Scale * createVector(3, 2, 3)
			})
			VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(v5 * 0.3, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			local airMeshStorm = clone5.AirMeshStorm
			VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Scale = airMeshStorm.Mesh.Scale * createVector(2, 1.3, 2)
			})
			VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			VisualHelper:Tween(airMeshStorm, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			})
			local airMeshHuge2 = clone5.AirMeshHuge2
			VisualHelper:Tween(airMeshHuge2.Mesh, TweenInfo.new(v5 * 0.15, Enum.EasingStyle.Sine), {
				Scale = airMeshHuge2.Mesh.Scale * 1.3
			})
			VisualHelper:Tween(airMeshHuge2.Decal, TweenInfo.new(v5 * 0.15, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			local airMeshHuge3 = clone5.AirMeshHuge3
			VisualHelper:Tween(airMeshHuge3.Mesh, TweenInfo.new(v5 * 0.12, Enum.EasingStyle.Sine), {
				Scale = airMeshHuge3.Mesh.Scale * 4
			})
			VisualHelper:Tween(airMeshHuge3.Decal, TweenInfo.new(v5 * 0.12, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			local airMeshHuge4 = clone5.AirMeshHuge4
			VisualHelper:Tween(airMeshHuge4.Mesh, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Scale = airMeshHuge4.Mesh.Scale * createVector(3, 1.4, 3)
			})
			VisualHelper:Tween(airMeshHuge4.Decal, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			local bodyFlash = clone5.BodyFlash
			VisualHelper:Tween(bodyFlash.Decal, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			VisualHelper:Tween(bodyFlash.Mesh, TweenInfo.new(v5 * 0.1, Enum.EasingStyle.Sine), {
				Scale = bodyFlash.Mesh.Scale * createVector(3, 1.8, 3)
			})
		end

		HexWaveMeshs(1.2)
		local clone5 = xFist.Phase0.FrontWave:Clone()
		clone5.CFrame = cFrame * CFrame.new(0, 0, -(clone5.Size.Z / 2 + 1.5))
		Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
		VisualHelper:Tween(clone5.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Brightness = 0
		})
		VisualHelper:EmitAll(clone5)
		Debris(clone5, 1.5)
		local beams = clone5.Beams

		for i, child in beams.Beams:GetChildren() do
			child.Enabled = true

			if child.Name == "Air" then
				VisualHelper:Tween(child, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			else
				VisualHelper:Tween(child, TweenInfo.new(0.215 + i * 0.01, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end
		end

		beams.Drag.Position = createVector(0, 0, 0)
		VisualHelper:Tween(beams.Drag, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Position = Vector3.new(0, 1, -clone5.Size.Z * 0.7)
		})
		local clone6 = xFist.Phase0.HexWave:Clone()
		clone6.CFrame = cFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
		VisualHelper:EmitAll(clone6.Emit)
		VisualHelper:SetEnableAll(clone6.Emit.Toggle, true)
		VisualHelper:SetEnableAll(clone6.Toggle, true)
		VisualHelper:SetEnableAll(clone6, true, true)
		local smash = clone6.Smash

		for _, v5 in { smash.CircleBeamFlash.Beam1, smash.CircleBeamFlash.Beam2 } do
			v5.Enabled = true
			VisualHelper:Tween(v5, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		VisualHelper:Tween(smash.Winds, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
			Orientation = smash.Winds.Orientation + createVector(0, 650, 0)
		})

		for _, beam in smash.Winds:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.3 + math.random(3) * 0.035, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		local hexs = smash.Hexs
		VisualHelper:Tween(hexs, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
			Orientation = hexs.Orientation + createVector(0, 650, 0)
		})

		for _, child in hexs:GetChildren() do
			local beam = child.Beam
			beam.Brightness *= 1.3
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.5 + math.random() * 0.25, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		for _, child in clone6.FadeBeams.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(child:GetAttribute("Time") or 0.7, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		for _, child in clone6.FloorBeams.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		local beam = clone6.FloorBeamsPattern.Beam
		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Brightness = 0
		})

		for _, child in clone6.ShapeLayers:GetChildren() do
			local beam2 = child.Beam
			beam2.Enabled = true
			VisualHelper:Tween(
				beam2,
				TweenInfo.new((child.Name == "Air" and 0.4 or 0.2) + math.random() * 0.2, Enum.EasingStyle.Sine),
				{
					Brightness = 0,
					CurveSize0 = beam2.CurveSize0 * 0.5,
					CurveSize1 = beam2.CurveSize1 * -1.5,
					Width0 = beam2.Width0 * 1.15,
					Width1 = beam2.Width1 * 1.5
				}
			)
			VisualHelper:Tween(child.Point, TweenInfo.new(0.85, Enum.EasingStyle.Sine), {
				Position = child.Point.Position + createVector(0, 0, -3) + child.Point.Position.Unit * 100
			})
		end

		Debris(clone6.ShapeLayers, 1)
		Debris(smash, 1)

		for _ = 1, 7 do
			local v5 = 0.3 + math.random() * 0.4
			local v6 = cFrame * CFrame.new(math.random(-75, 75), math.random(-2, 75), math.random(5, 10))
			local v7 = v6 * CFrame.new(0, 0, -clone5.Size.Z / 2).Position
			local position = v6.Position
			local clone7 = xFist.Phase0.VaultC.HexTrailSpecsMove:Clone()
			clone7.Position = position
			Util.SetParentOverrideWithColor(clone7, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			Debris(clone7, v5 + 0.5)
			local magnitude = (position - v7).Magnitude
			local cframe = CFrame.lookAt(position, v7)
			local v11 = cframe * CFrame.new(math.random(-120, 120), math.random(-120, 120), -magnitude * 0.25).Position
			local v12 = cframe * CFrame.new(math.random(-120, 120), math.random(-120, 120), -magnitude * 0.75).Position
			VisualHelper:TweenNumberValue(1, TweenInfo.new(v5, Enum.EasingStyle.Sine), function(p: number)
				clone7.Position = MathHelper:CubicBezier(p, position, v11, v12, v7)
			end)
		end

		local enemyChar = player.EnemyChar

		if enemyChar then
			local humanoidRootPart = enemyChar.HumanoidRootPart
			local position = humanoidRootPart.Position
			local v5 = (xZCFrame.LookVector * 0.25 + createVector(0, 1, 0)) * 350
			local clone7 = xFist.Phase0.VaultF.BodyPattern:Clone()
			Util.SetParentOverrideWithColor(clone7, humanoidRootPart, player.Player, "ControlFruitVFXColor")
			VisualHelper:SetEnableAll(clone7, true)
			local total = 0
			local v6 = 25
			local v7 = "Follow"
			local v8 = {}
			local cFrame2 = humanoidRootPart.CFrame
			local total2 = 0
			local v9 = -2
			renderSteppedConnection:Disconnect()
			local cFrame3 = nil
			local v10 = nil
			local total3 = 0
			local clone8 = xFist.Phase0.Hit:Clone()
			clone8.PointLight:Destroy()
			Util.SetParentOverrideWithColor(clone8, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			Util.Sound:Play("HandsX_HitSequence_01", humanoidRootPart)
			local renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
				total3 += dt

				if total < 0.6 then
					total += dt
					v5 -= Vector3.new(0, 700 * dt)
				elseif not v10 then
					v10 = true
					clone8.CFrame = humanoidRootPart.CFrame
					VisualHelper:EmitAll(clone8.Boom)
				end

				if clone4 then
					clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
				end

				local v11 = v7 == "Planing"
				total2 += v9 * dt
				cFrame2 = (cFrame3 or humanoidRootPart.CFrame) * CFrame.Angles(0, 0, total2)
				v6 = math.lerp(
					v6,
					1.5,
					TweenService:GetValue(2.5 * dt, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				)
				v9 = math.lerp(
					v9,
					v11 and -1.25 or -2,
					TweenService:GetValue(0.25 * dt, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				)

				for k, v12 in v8 do
					local hardedCFrame = v12.HardedCFrame or cFrame2 * CFrame.Angles(0, 0, -math.rad(v12.Index * 45)) * CFrame.new(
						0,
						math.sin(v12.Index * 0.1 + total3 * 3) * 5 + 70,
						0
					)

					if not v12.HardedCFrame then
						v12.Offset = v12.Offset:Lerp(
							v11 and v12.PlaningOffset or v12.FollowOffset or -2,
							TweenService:GetValue(0.5 * dt, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						)
						hardedCFrame *= v12.Offset

						if v11 then
							local v13 = v12.AngleSpeed * dt
							hardedCFrame = hardedCFrame * CFrame.Angles(v13, v13, 0) + Vector3.new(
								0,
								math.sin(total3 * 5 + v12.Index) * 3
							)
						end
					end

					k:PivotTo(k:GetPivot():Lerp(
						hardedCFrame,
						TweenService:GetValue(v6 * dt, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					))
				end
			end)
			VisualHelper:Tween(currentCamera, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				FieldOfView = 80
			})
			task.delay(0.1, function()
				for i = 1, 8 do
					local position2 = humanoidRootPart.Position
					local v11 = position + Vector3.new(math.random(-75, 75), 0, math.random(-75, 75))
					local rayCast = MathHelper:RayCast(
						position2,
						CFrame.lookAt(position2, v11).LookVector * 500,
						{ workspace.Map },
						Enum.RaycastFilterType.Include
					)

					if rayCast then
						local v12 = ObjectClass.new(player2, CFrame.new(rayCast.Position))
						v12:RemoveDragable()
						v12.Model.Main.CanQuery = false
						v12.CanSlice = false
						local clone9 = xFist.Phase0.Vault.ObjectTrail:Clone()
						Util.SetParentOverrideWithColor(clone9, v12.Model.Main, player2, "ControlFruitVFXColor")
						v12:ScaleTo(0.75)
						v12:ToggleBodyPattern(true)
						v12.Model.Main.BodyPattern.DarkGlow.LightEmission = 0.9
						v8[v12] = {
							Index = i,
							FollowOffset = CFrame.new(0, random:NextNumber(-8, 8), random:NextNumber(-8, 8)),
							PlaningOffset = CFrame.new(
								random:NextNumber(-15, 15) * 0.5,
								random:NextNumber(-15, 15) * 0.5,
								random:NextNumber(-15, 15) * 4
							),
							Offset = CFrame.new(),
							AngleSpeed = math.random(30, 85),
							JointTime = i * 0.025 + 0.025
						}
						Util.CameraShaker:Shake("Pilar Hard")
						local cFrame4 = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						) * CFrame.new(0, 0.5, 0)
						local clone10 = xFist.Phase0.PushExplosion:Clone()
						clone10:PivotTo(cFrame4)
						Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player2, "ControlFruitVFXColor")
						VisualHelper:EmitAll(clone10)
						Debris(clone10, 4)
						local clone11 = xFist.Phase0.BallNeon:Clone()
						clone11.CFrame = cFrame4
						clone11.Transparency = 0.95
						local player3 = player2
						local color = Color3.fromRGB(89, 133, 255)

						if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
							color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
						end

						clone11.Color = color
						clone11.Size = createVector(1, 1, 1) * (clone10.Main.Size.Y * 0.65)
						clone11.Parent = workspace.Terrain
						VisualHelper:Tween(clone11, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Size = clone11.Size * 4,
							Transparency = 1
						})
						Debris(clone11, 0.2)
						local beams2 = clone10.Main.Beams
						VisualHelper:Tween(beams2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							WorldCFrame = beams2.WorldCFrame * CFrame.Angles(0, 3.141592653589793, 0)
						})

						for _, beam2 in beams2:GetDescendants() do
							if not beam2:IsA("Beam") then
								continue
							end

							beam2.Enabled = true
							VisualHelper:Tween(
								beam2,
								TweenInfo.new(0.15 + math.random(3) * 0.025, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						Debris(beams2, 0.5)
						local v14 = clone10.Main.Size.X / 2
						local position3 = cFrame4.Position
						local v16 = v14 * 0.7
						local v17 = { workspace.Terrain }
						Rocks:CircleRocks(position3, 10, v16, createVector(5.2, 1.2, 2), 0, v17)
						local position4 = cFrame4.Position
						local v19 = v14 * 1.05
						local v20 = { workspace.Terrain }
						Rocks:CircleRocks(position4, 5, v19, createVector(4, 1.8, 3.2), 0, v20)

						for _ = 1, 3 do
							Rocks:AirRocks(
								cFrame4,
								Vector3.new(random:NextNumber(4.5, 7), 2, random:NextNumber(4.5, 7)),
								false,
								math.random(90, 130),
								1,
								1,
								3,
								rayCast.Instance.Color,
								rayCast.Material
							)
						end

						local airMeshHuge = clone10.AirMeshHuge
						local superFlash = clone10.SuperFlash
						local flash = clone10.Flash
						local airHard = clone10.AirHard
						VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Scale = airMeshHuge.Mesh.Scale * 1.9
						})
						VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						})
						Debris(airMeshHuge, 1)
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
						VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						})
						VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Scale = flash.Mesh.Scale * 2.5
						})
						Debris(flash, 1)
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
						Debris(superFlash, 1)
					end

					task.wait(0.1)
				end

				VisualHelper:SetEnableAll(clone4, false)
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					FieldOfView = 70
				})
				task.wait(0.03333333333333333)

				for k in v8 do
					local objectTrail = k.Model.Main.ObjectTrail
					objectTrail.Trail.Enabled = false
					objectTrail.Trail2.Enabled = false
				end

				task.wait(0.06666666666666667)
				v7 = "Planing"
				clone8.CFrame = humanoidRootPart.CFrame
				VisualHelper:EmitAll(clone8.Boom)
				task.wait(0.03333333333333333)

				for k in v8 do
					k:SwitchMode("Planing")
				end

				task.wait(0.06666666666666667)
				VisualHelper:EmitAll(clone8.BoomEnd)
				VisualHelper:EmitAll(clone8, true)
				VisualHelper:SetEnableAll(clone4, true)
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Back), {
					FieldOfView = 76
				})
				local v11 = {}

				for k in v8 do
					table.insert(v11, k)
				end

				random:Shuffle(v11)

				local function RushLine(position2: Vector3, position3: Vector3, p: number)
					local magnitude = (position2 - position3).Magnitude
					local clone9 = xFist.Phase0.RushLine:Clone()
					clone9.CFrame = CFrame.lookAt(position2, position3) * CFrame.new(0, 0, -(magnitude / 2 - p))
					clone9.Size = Vector3.new(clone9.Size.X, clone9.Size.Y, magnitude)
					Util.SetParentOverrideWithColor(clone9, workspace.Terrain, player2, "ControlFruitVFXColor")
					local beams2 = clone9.Beams

					for i, child in beams2.Beams:GetChildren() do
						child.Enabled = true

						if child.Name == "Air" then
							VisualHelper:Tween(child, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
								Brightness = 0
							})
						else
							local v12 = child.Name == "Fade"
							VisualHelper:Tween(
								child,
								TweenInfo.new(
									v12 and 0.7 or 0.17 + i * 0.01,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out,
									0,
									false,
									v12 and 0 or 0.075
								),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end
					end

					beams2.Drag.Position = createVector(0, 0, 0)
					VisualHelper:Tween(beams2.Drag, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
						Position = Vector3.new(0, 1, -magnitude - p)
					})
					VisualHelper:EmitAll(clone9)
					Debris(clone9, 2)
					return clone9
				end

				cFrame3 = humanoidRootPart.CFrame
				local position2 = cFrame2.Position

				for _ = 1, 2 do
					for _, v12 in v11 do
						v12:Flash()
						local position3 = v12:GetPivot().Position
						local rushLine = RushLine(position2, position3, 5)
						VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.0375, Enum.EasingStyle.Sine), {
							CFrame = CFrame.new(position3)
						})
						task.wait(0.0375)
						local clone9 = xFist.Phase0.Kick:Clone()
						clone9.CFrame = rushLine.Beams.Drag.WorldCFrame
						Util.SetParentOverrideWithColor(clone9, workspace.Terrain, player2, "ControlFruitVFXColor")
						VisualHelper:EmitAll(clone9)
						Debris(clone9, 3)
						Util.CameraShaker:Shake("Fast")
						position2 = position3
					end
				end

				RushLine(position2, cFrame3.Position, 5)
				VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
					CFrame = cFrame3
				})
				clone4:Destroy()
				clone4 = nil
				task.wait(0.1)
				VisualHelper:EmitAll(clone8.BoomEnd)
				VisualHelper:EmitAll(clone8, true)
				task.delay(0.35, function()
					VisualHelper:EmitAll(clone8.Boom)
					task.wait(0.5)
					clone8:Destroy()
				end)
				cFrame3 = nil
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
					FieldOfView = 70
				})
				local Y = v11[1].Model.Main.Size.Y
				local cframes = {}

				for i = 1, 2 do
					for i2 = 1, 2 do
						table.insert(cframes, CFrame.new((i2 - 1.5) * Y, (i - 1.5) * Y, -0.5 * Y))
						table.insert(cframes, CFrame.new((i2 - 1.5) * Y, (i - 1.5) * Y, 0.5 * Y))
					end
				end

				renderSteppedConnection2:Disconnect()
				local clone9 = xFist.Phase0.Vault.EndArrow:Clone()
				Util.SetParentOverrideWithColor(clone9, workspace.Terrain, player2, "ControlFruitVFXColor")
				local v12 = 10
				local total4 = 0
				local v13 = cFrame2.Position - createVector(0, 100, 0)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function GetNewPivot()
					local magnitude = (humanoidRootPart.Position - v13).Magnitude
					return CFrame.lookAt(v13, humanoidRootPart.Position) * CFrame.new(
						0,
						0,
						-magnitude - Y * (math.sin(total4 * 3) * 0.5 + 3)
					)
				end

				local model2 = Instance.new("Model", workspace.Terrain)
				local newPivot = GetNewPivot() -- equivalent call inferred; original call site unknown
				local teleporting = player2:GetAttribute("Teleporting")
				local v15 = nil

				while not v15 or teleporting do
					local v16 = RunService.RenderStepped:Wait()
					total4 += v16
					teleporting = player2:GetAttribute("Teleporting")
					clone9.WorldCFrame = CFrame.lookAt(newPivot.Position, v13) * CFrame.new(0, 0, -Y)
					local _ = (humanoidRootPart.Position - v13).Magnitude
					newPivot = newPivot:Lerp(GetNewPivot(), v12 * v16)
					v15 = #model2:GetChildren() >= #v11

					if v15 then
						model2:PivotTo(newPivot)

						if teleporting then
							if teleporting ~= "Linked" then
								v12 /= 2

								for k in v8 do
									k:ToggleBolts(true)
									k:ToggleDarkLayers(true)
								end

								root.Anchored = true
								player2:SetAttribute("Teleporting", "Linked")
								currentCamera.CameraType = Enum.CameraType.Scriptable
								VisualHelper:ModelTransparency(character, 1)
								EmitExplosion(root.CFrame * CFrame.new(0, -2.8, 0), nil, player2)
								task.wait(0.05)
								currentCamera.CameraType = Enum.CameraType.Custom
								task.wait(0.09)
								VisualHelper:ModelTransparency(character, 0)
								local highlight = Instance.new("Highlight")
								highlight.Adornee = character
								highlight.FillTransparency = 0
								highlight.OutlineTransparency = 1
								highlight.DepthMode = Enum.HighlightDepthMode.Occluded
								local player3 = player2
								local color = Color3.fromRGB(76, 139, 255)

								if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
									color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
								end

								highlight.FillColor = color
								highlight.Parent = workspace.Terrain
								VisualHelper:Tween(highlight, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
									FillTransparency = 1
								})
								Debris(highlight, 0.6)
								Flash(root, true, player2)
							end

							root.CFrame = newPivot * CFrame.new(0, 0, -Y - 5) * CFrame.Angles(0, 3.141592653589793, 0)
						end
					else
						for k, v17 in v11 do
							local v18 = v8[v17]
							local v19 = cframes[k]
							local jointBezier = v18.JointBezier

							if not jointBezier then
								local position3 = v17:GetPivot().Position
								local clone10 = xFist.Phase0.Vault.Arrow:Clone()
								Util.SetParentOverrideWithColor(
									clone10,
									v17.Model.Main,
									player2,
									"ControlFruitVFXColor"
								)
								jointBezier = {
									Arrow = clone10,
									Alpha = 0,
									Point1 = position3,
									Curve1Offset = Vector2.new(math.random(-90, 90), math.random(-90, 90)),
									Curve2Offset = Vector2.new(math.random(-90, 90), math.random(-90, 90))
								}
								v18.JointBezier = jointBezier
							end

							jointBezier.Alpha = math.clamp(total4 / v18.JointTime, 0, 1)
							local arrow = jointBezier.Arrow
							local v20 = newPivot * v19
							local point1 = jointBezier.Point1
							local position3 = v20.Position
							local magnitude = (point1 - position3).Magnitude
							local cframe = CFrame.lookAt(point1, position3)
							local v21 = cframe * CFrame.new(
								jointBezier.Curve1Offset.X,
								jointBezier.Curve1Offset.Y,
								-magnitude * 0.25
							).Position
							local v22 = cframe * CFrame.new(
								jointBezier.Curve2Offset.X,
								jointBezier.Curve2Offset.Y,
								-magnitude * 0.75
							).Position
							local cubicBezier = MathHelper:CubicBezier(jointBezier.Alpha, point1, v21, v22, position3)
							local v23 = CFrame.lookAt(cubicBezier, position2) * CFrame.Angles(
								0,
								3.141592653589793,
								jointBezier.Alpha * 3.141592653589793
							)
							arrow.WorldCFrame = CFrame.lookAt(arrow.Parent.Position, position3) * CFrame.new(
								0,
								0,
								-Y / 2
							)
							arrow.Beam.Brightness = (1 - jointBezier.Alpha) * 0.8
							local lerped = v23.Rotation:Lerp(
								v20.Rotation,
								TweenService:GetValue(
									math.min(jointBezier.Alpha * 1.3, 1),
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out
								)
							)
							local lerped2 = v17:GetPivot().Position:Lerp(
								v23.Position,
								TweenService:GetValue(
									jointBezier.Alpha,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.InOut
								)
							)
							v17:PivotTo(CFrame.new(lerped2) * lerped)

							if not (jointBezier.Alpha < 1) and v17.Model.Parent ~= model2 then
								v17.Model.Parent = model2
								v17:Flash()
							end

							position2 = cubicBezier
						end
					end
				end

				local anchored = root.Anchored == true

				if anchored then
					root.Anchored = false
					task.delay(0.05, function()
						root.AssemblyLinearVelocity = root.CFrame.LookVector * -120
					end)
				end

				VisualHelper:Tween(clone9.Beam, TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				})
				task.wait(0.15)

				for k in v8 do
					k:Flash()
				end

				VisualHelper:SetEnableAll(clone7, false)
				Debris(clone7, 1.5)
				local pivot = model2:GetPivot()
				local rayCast = MathHelper:RayCast(
					pivot.Position,
					pivot.LookVector * -500,
					{ workspace.Map },
					Enum.RaycastFilterType.Include
				)
				local v16 = not rayCast and 500 or (rayCast.Position - pivot.Position).Magnitude or 500
				local v17 = v16 / 500 * 0.5
				local v18 = pivot * CFrame.new(0, 0, v16)
				local v19 = false
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.11666666666666665, Enum.EasingStyle.Back), {
					FieldOfView = 75
				})
				VisualHelper:TweenNumberValue(
					1,
					TweenInfo.new(v17, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					function(p)
						model2:PivotTo(pivot:Lerp(v18, p))

						if p < 0.3 then
							return
						end

						if not v19 then
							v19 = true
							Util.CameraShaker:Shake("Fast Hard")
							local clone10 = xFist.Phase0.EndShockwave:Clone()
							clone10.CFrame = pivot
							Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player2, "ControlFruitVFXColor")
							VisualHelper:EmitAll(clone10)
							Debris(clone10, 3)

							if anchored then
								local clone11 = xFist.Phase0.EndShockwaveEnergized:Clone()
								clone11.CFrame = pivot
								Util.SetParentOverrideWithColor(
									clone11,
									workspace.Terrain,
									player2,
									"ControlFruitVFXColor"
								)
								VisualHelper:EmitAll(clone11.Emit)
								VisualHelper:SetEnableAll(clone11.Toggle, true)
								task.delay(0.2, function()
									VisualHelper:SetEnableAll(clone11.Toggle, false)
								end)
								Debris(clone11, 3)
							end
						end

						humanoidRootPart:PivotTo(humanoidRootPart.CFrame:Lerp(v18, p))
					end
				)
				task.wait(v17)
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Back), {
					FieldOfView = 70
				})
				local v20 = v11[1]
				local box = xFist.Phase0.Box
				box.Size = model2:GetExtentsSize()
				box.Color = rayCast.Instance.Color
				box.Material = rayCast.Instance.Material
				box.CFrame = model2:GetPivot()

				if rayCast then
					Util.CameraShaker:Shake("Regular Explosion")
					task.spawn(function()
						ObjectExplosion({
							Position = rayCast.Position,
							Normal = rayCast.Normal,
							Object = box,
							Energized = anchored,
							Scale = 5.0525
						})
					end)
					local clone10 = xFist.Phase0.Vault.EplosionSmash:Clone()
					Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player2, "ControlFruitVFXColor")
					Util.Sound:Play("HandsX_Explode_01", v18.Position)
					clone10.WorldCFrame = v18 * CFrame.new(0, 0, 5) * CFrame.Angles(-1.5707963267948966, 0, 0)
					local clone11 = xFist.Phase1.GroundCrack:Clone()
					clone11.CFrame = CFrame.new(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					) * CFrame.new(0, 1, 0)
					Util.SetParentOverrideWithColor(clone11, model, player2, "ControlFruitVFXColor")
					DeleteImpactAfterDuration(clone11) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(clone11:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					for _, v21 in { clone10.CircleBeamFlash.Beam1, clone10.CircleBeamFlash.Beam2 } do
						v21.Enabled = true
						VisualHelper:Tween(v21, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					VisualHelper:Tween(clone10.Winds, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						Orientation = clone10.Winds.Orientation + createVector(0, 750, 0)
					})

					for _, beam2 in clone10.Winds:GetDescendants() do
						if not beam2:IsA("Beam") then
							continue
						end

						beam2.Enabled = true
						VisualHelper:Tween(beam2, TweenInfo.new(0.45 + math.random(3) * 0.055, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					Debris(clone10, 1.5)
				else
					ObjectExplosion({
						Object = v20.Model.Main,
						Energized = anchored,
						Scale = 2.15 * v20:GetLayoutSize(),
						IsSliceModel = v20:IsSliceModel()
					})
				end

				table.clear(v11)

				for k in v8 do
					k:Destroy()
				end

				clone9:Destroy()
			end)
		else
			task.wait(player.DelayTimestamp - workspace:GetServerTimeNow())

			local function EmitExpansionExplosion(cframe: CFrame, instance)
				Util.CameraShaker:Shake("Fast Hard")
				instance:PivotTo(cframe)
				Util.SetParentOverrideWithColor(instance, workspace.Terrain, player2, "ControlFruitVFXColor")
				instance.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

				for i, child in instance.Main.Layers:GetChildren() do
					child.Orientation *= 1.5
					local beam2 = child.Beam
					beam2.Width0 *= 2
					beam2.Width1 *= 2
					beam2.Enabled = true
					local number = random:NextNumber(0.2, 0.3)
					VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
						Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
					})
					VisualHelper:Tween(beam2, TweenInfo.new(number, Enum.EasingStyle.Sine), {
						Width0 = 0,
						Width1 = 0
					})
				end

				for _, child in instance.Main.CircleWinds:GetChildren() do
					local beam2 = child.Beam
					beam2.Enabled = true
					VisualHelper:Tween(beam2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Width0 = 0,
						Width1 = 0
					})
				end

				VisualHelper:EmitAll(instance)
				Debris(instance, 2)
			end

			ObjectClass.UnPassRequests = true
			ObjectClass:SetSelected(nil)
			ObjectClass:LockSelection()
			local v5 = {}
			local v6 = ObjectClass.TemplateModel.Main.Size / 3
			local v7 = math.random(0, 15)
			local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
			task.spawn(function()
				for i = 1, #targetObjects do
					local targetObject = targetObjects[i]
					local v8 = v:Take()
					local v9 = v2:Take()
					local v10 = v3:Take()

					if targetObject then
						local position = targetObject.Value.Position
						local v12 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						local rayCast = MathHelper:RayCast(
							position,
							createVector(-0, -100, -0),
							v12,
							Enum.RaycastFilterType.Exclude
						)

						if rayCast then
							local value = targetObject.Value
							local v13 = ObjectClass.new(player2, value, targetObject, nil, v8)
							local main = v13.Model.Main
							main.Color = rayCast.Instance.Color
							main.Material = rayCast.Instance.Material
							v13.Model:SetAttribute("SizeScale", targetObject:GetAttribute("SizeScale") or 1)
							local main2 = v13.Model.Main
							local outline = main2.Outline
							local transparency = outline.Decal.Transparency
							outline.Decal.Transparency = 1
							local sizeScale = targetObject:GetAttribute("SizeScale") or 1
							v13:SetLayout((`{sizeScale}x{sizeScale}`))
							local size = v6 * sizeScale
							local v15 = value * CFrame.new(0, 0, -(size.Y / 2 + v7))
							v13:PivotTo(value * cframe)
							v13:SetSize(createVector(0, 0, 0))
							VisualHelper:Tween(main2, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
								Size = size * createVector(1.35, 0.3, 1.35),
								CFrame = main2.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
							})
							local v16 = value * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0)
							Util.Sound:Play(
								({
									"CTRLFRT_Fist_CubeSpawn_Small_01",
									"CTRLFRT_Fist_CubeSpawn_Medium_01",
									"CTRLFRT_Fist_CubeSpawn_Large_01"
								})[sizeScale],
								main2.Position
							)
							local v21 = v10
							task.delay(0.1, function()
								VisualHelper:Tween(main2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
									Size = size,
									CFrame = v15 * cframe
								})
								task.wait(0.225)
								EmitExpansionExplosion(v16, v21)
								v13:Flash()
								VisualHelper:Tween(main2, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
									Size = size * createVector(1, 1, 1) * 1.55,
									CFrame = main2.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
								})
								task.wait(0.05)
								outline.CFrame = main2.CFrame
								VisualHelper:Tween(main2, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
									Size = size
								})
								VisualHelper:Tween(outline.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
									Transparency = transparency
								})
								v13:SwitchMode("Planing")
								v13:ToggleBodyPattern(true)
								v13.PlaningCFrame = value * CFrame.new(
									0,
									0,
									-(v13:GetSize().Y / 2 + math.random(35, 65))
								) * cframe * CFrame.Angles(
									0,
									math.rad((math.random(360))),
									(math.rad((math.random(-25, 25))))
								)
								local planingCFrame = v13.PlaningCFrame
								local v27 = time()
								task.spawn(function()
									while v13 and v13.Model and v13.Model.Parent do
										local v28 = 1 - math.exp(-0.6 * task.wait())
										local v29 = time() - v27
										local cframe2 = v13:GetPivot():Lerp(planingCFrame, v28)
										v13:PivotTo(CFrame.new(cframe2.Position + Vector3.new(
											0,
											math.sin(v29 * 2) * 0.12,
											0
										)) * CFrame.fromOrientation(cframe2:ToOrientation()))
									end
								end)
								Util.Sound:Play(
									({
										"CTRLFRT_Fist_CubeLift_Small_01",
										"CTRLFRT_Fist_CubeLift_Medium_01",
										"CTRLFRT_Fist_CubeLift_Large_01"
									})[sizeScale],
									main2.Position
								)
							end)
							EmitExpansionExplosion(v16, v9)
							table.insert(v5, v13)
							task.wait(0.05)
						else
							v8:Destroy()
							v9:Destroy()
							v10:Destroy()
						end
					else
						v8:Destroy()
						v9:Destroy()
						v10:Destroy()
						print("wut?")
					end
				end

				v:Destroy()
				v2:Destroy()
				v3:Destroy()

				if #v5 < 1 then
					return ObjectClass:UnlockSelection()
				end

				task.wait(0.23)
				local v8 = -1
				ObjectClass:MultipleSelect(v5, function(object)
					v8 += 1
					local v9 = v8 / #v5
					local throwData = object.ThrowData
					local model2 = object.Model
					task.delay(30, function()
						object.Maid:Destroy()
					end)
					local mouseArea = object.Maid:GiveTask(ObjectClass:CreateMouseArea(
						object:GetLayoutSize(),
						object.Player
					))
					mouseArea.Main.Light:Destroy()
					local scale = mouseArea:GetScale()
					mouseArea:ScaleTo(0.01)
					VisualHelper:TweenScale(
						mouseArea,
						TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, v8 * 0.07),
						scale
					)
					throwData.MouseArea = mouseArea
					throwData.MouseCFrameOffset = CFrame.Angles(0, 0, (math.rad(v9 * 360 + math.random(-35, 35))))
					throwData.MouseCFrameYOffset = CFrame.new(0, v9 * 155, 0)
					model2:SetAttribute("MouseCFrameOffset", throwData.MouseCFrameOffset)
					model2:SetAttribute("MouseCFrameYOffset", throwData.MouseCFrameYOffset)
				end)
				local renderSteppedConnection2 = nil
				local positionsByName = {}

				local function Update(dt)
					local Mouse = require(game.ReplicatedStorage.Mouse)
					local p = Mouse.Hit.p
					local UserInputService = game:GetService("UserInputService")
					local mouseLocation = UserInputService:GetMouseLocation()

					if player2 == game.Players.LocalPlayer then
						if Mouse.isMobile then
							mouseLocation = Vector2.new(Mouse.X, Mouse.Y)
						end
					else
						mouseLocation = workspace.CurrentCamera:WorldToViewportPoint(player.Mouse.Value)
					end

					local X = mouseLocation.X
					local Y = mouseLocation.Y
					local GuiService = game:GetService("GuiService")
					local screenPointToRay = currentCamera:ScreenPointToRay(X, Y - GuiService:GetGuiInset().Y)
					local rayCast = MathHelper:RayCast(
						screenPointToRay.Origin,
						screenPointToRay.Direction * 2000,
						{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
						Enum.RaycastFilterType.Exclude
					)

					for _, v10 in v5 do
						if v10.IsThrowing then
							renderSteppedConnection2:Disconnect()
						end

						local throwData = v10.ThrowData
						local position = v10:GetPivot().Position
						local cframe2 = rayCast and CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) or CFrame.lookAt(
							p,
							position
						)
						local v11 = 0 + throwData.MouseCFrameYOffset.Y
						local position2 = (cframe2 * throwData.MouseCFrameOffset * throwData.MouseCFrameYOffset * CFrame.new(
							math.cos(v11) * 25,
							math.sin(v11) * 25,
							0
						)).Position
						local rayCast2 = MathHelper:RayCast(
							position,
							CFrame.lookAt(position, position2).LookVector * 2000,
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
							Enum.RaycastFilterType.Exclude
						)

						if not rayCast2 then
							break
						end

						throwData.RayCastResult = rayCast2
						throwData.MouseArea:PivotTo(CFrame.lookAt(
							rayCast2.Position,
							rayCast2.Position + rayCast2.Normal
						) * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0))
						local selectedUpdate = throwData.SelectedUpdate

						if not selectedUpdate then
							break
						end

						positionsByName[v10.Model.Name] = rayCast2.Position
						selectedUpdate(dt)
					end
				end

				renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
					Update(dt)
				end)
				local v9 = false
				local childRemovedConnection = character.ChildRemoved:Connect(function(child)
					if child.Name == "ControlXHack" and child:GetAttribute("Fire") then
						v9 = true
					end
				end)
				local lastTime = tick()

				repeat
					task.wait()
				until v9 == true or tick() - lastTime >= 1.2

				if childRemovedConnection then
					childRemovedConnection:Disconnect()
				end

				if renderSteppedConnection2 then
					renderSteppedConnection2:Disconnect()
				end

				local xFistRemote = game.Players.LocalPlayer == player2 and (game.Players.LocalPlayer.Character:FindFirstChild(
					"XFistRemote",
					true
				) or game.Players.LocalPlayer.Backpack:FindFirstChild("XFistRemote", true))

				if xFistRemote then
					xFistRemote:FireServer("FireFistX", positionsByName, workspace:GetServerTimeNow())
				end

				task.wait(0.2)
				Util.Anims:Get(character, "CRFistXDropCubes"):Play()

				for _, v10 in v5 do
					local model2 = v10.Model

					if not model2.Parent then
						continue
					end

					local _ = model2:GetPivot().Position
					Util.Sound:Play(
						({
							"CTRLFRT_Fist_Release_Small_0",
							"CTRLFRT_Fist_Release_Medium_0",
							"CTRLFRT_Fist_Release_Large_0"
						})[model2:GetAttribute("SizeScale")] .. tostring(math.random(1, 4)),
						model2.PrimaryPart.Position
					)
					local v11 = v10
					v10:Throw(function(p)
						if not v11.Model.Parent then
							return
						end

						Effect.new("ControlRework.ObjectExplosion"):play({
							Position = p.Position,
							Normal = p.Normal,
							Object = v11.Custom and v11.Custom or v11.Model.Main,
							Energized = v11.Energized,
							Scale = 2.15 * v11:GetLayoutSize(),
							IsCustom = v11.Custom and true or false
						})
						v11:Destroy()
					end)
				end

				ObjectClass:SetSelected(nil)
				ObjectClass:UnlockSelection()
			end)
		end

		for k, v5 in {
			{
				Offset = 3,
				Scale = 0.75
			},
			{
				Offset = 20,
				Scale = 1.75
			},
			{
				Offset = 45,
				Scale = 1.25
			},
			{
				Offset = 65,
				Scale = 2.25
			}
		} do
			local clone7 = xFist.Phase0.SinalLayer:Clone()
			clone7:PivotTo(clone6.CFrame * CFrame.new(0, 0, -v5.Offset))
			Util.SetParentOverrideWithColor(clone7, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
			clone7:ScaleTo(0.15)
			VisualHelper:TweenScale(clone7, TweenInfo.new(0.125, Enum.EasingStyle.Back), v5.Scale)
			VisualHelper:Tween(clone7.Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
				CFrame = clone7.Main.CFrame * CFrame.new(0, 0, -5)
			})
			local v7 = v5
			local v8 = k
			task.delay(0.125, function()
				VisualHelper:TweenScale(
					clone7,
					TweenInfo.new(0.225, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					v7.Scale * 1.5
				)
				task.wait(0.225)

				if v8 == 1 then
					Util.CameraShaker:Shake("Fast")
					VisualHelper:Tween(currentCamera, TweenInfo.new(5, Enum.EasingStyle.Sine), {
						FieldOfView = 70
					})

					if renderSteppedConnection.Connected then
						renderSteppedConnection:Disconnect()
						clone4:Destroy()
					end

					HexWaveMeshs(0.5)
					VisualHelper:EmitAll(clone6.EndEmit)
					VisualHelper:SetEnableAll(clone6.Toggle, false)
					VisualHelper:SetEnableAll(clone6, false, true)
					Debris(clone6, 1.5)
					VisualHelper:SetEnableAll(clone2, false)
					Debris(clone2, 1)
					VisualHelper:Tween(clone.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					})
					Debris(clone, 0.5)
				end

				clone7:Destroy()
			end)
			task.wait(0.015)
		end

		Util.CameraShaker:Shake("Pilar Hard")
		EmitFloor(root.CFrame * CFrame.new(0, -2.8, 0), player.Player)
		HexWaveMeshs(0.5)
		VisualHelper:SetEnableAll(clone6.Emit.Toggle, false)
	end
end