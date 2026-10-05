local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xOutside = FX:WaitForChild("ControlRework").XOutside
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
require(shared:WaitForChild("ObjectClass"))
local HexsStormClass = require(shared:WaitForChild("HexsStormClass"))
local lightningBoltShafi = Util.LightningBoltShafi

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

local _WorldOrigin = workspace._WorldOrigin
local domain_Katsuo = FX:WaitForChild("ControlRework").Domain_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local x_Katsuo = FX:WaitForChild("ControlRework").X_Katsuo

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

	if instance then
		instance:Destroy()
	end
end

local function Slash(cFrame: CFrame, value: number?, flag: boolean?, value2: number?, p)
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	Util.Debris:AddItem(model, 10)
	local model2 = Instance.new("Model", model)
	local clone = xOutside.Phase0.Slash:Clone()
	clone:ScaleTo(value2 or 1.65)
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, model2, p, "ControlFruitVFXColor")
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

		emitter.LockedToPart = true
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
	Debris(slash, 2)
	return slash
end

local function DarkSlash(cFrame: CFrame, value: number?, flag: boolean?, value2: number?, p)
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	Util.Debris:AddItem(model, 10)
	local clone = xOutside.Phase0.DarkSlash:Clone()
	clone:ScaleTo(value2 or 1.65)
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, model, p, "ControlFruitVFXColor")
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
	Debris(slash, 2)
	local staticSlash = slash.StaticSlash
	staticSlash.Beam.Enabled = true
	task.delay(0.025, function()
		staticSlash:Destroy()
	end)
	return slash
end

local function Flash(root, flag: boolean, player)
	local clone = xOutside.Phase0.VaultF.Flash:Clone()
	Util.SetParentOverrideWithColor(clone, root, player, "ControlFruitVFXColor")

	for _, descendant in clone:GetDescendants() do
		descendant:Emit(descendant:GetAttribute("Emit"))
		descendant.LockedToPart = flag or false
	end

	Debris(clone, 0.6)
end

local map = workspace.Map

local function EmitExplosion(cFrame, flag: boolean?, player)
	if not cFrame then
		return
	end

	local v = typeof(cFrame) == "RaycastResult"
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	Util.Debris:AddItem(model, 10)
	Util.CameraShaker:Shake("Fast")

	if v then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local clone = xOutside.Phase0.Explosion:Clone()
	clone:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

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
	local clone2 = xOutside.Phase0.BallNeon:Clone()
	clone2.CFrame = cFrame
	clone2.Transparency = 0.94
	local color = Color3.fromRGB(89, 133, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color = Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	clone2.Color = color
	clone2.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
	clone2.Parent = model
	VisualHelper:Tween(clone2, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Size = clone2.Size * 1.35,
		Transparency = 1
	})
	Debris(clone2, 0.14)
	local clone3 = xOutside.Phase0.BallNeon:Clone()
	clone3.CFrame = cFrame
	clone3.Transparency = 0.85
	local color2 = Color3.fromRGB(89, 133, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	clone3.Color = color2
	clone3.Size = createVector(1, 1, 1) * clone.Main.Size.Y
	clone3.Parent = model
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
			local rayCast = MathHelper:RayCast(v3.Position, v3.UpVector * -10, { map }, Enum.RaycastFilterType.Include)

			if rayCast then
				local clone4 = xOutside.Phase0.BoltExplosion:Clone()
				clone4.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				Util.SetParentOverrideWithColor(clone4, model, player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone4)
				Debris(clone4, 1)
			end

			task.wait(0.125)
		end
	end)
end

local function EmitFloor(cFrame: CFrame, player)
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	Util.Debris:AddItem(model, 10)
	local clone = xOutside.Phase0.FloorSpawnEnd:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	clone.PointLight.Enabled = true
	VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	Debris(clone, 2.15)
end

local random = Random.new()
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

	if stage == 1 then
		local player2 = player.Player
		local character = player.Character
		local root = player.Root
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Sound:Play("X_Activate_01", root.Position)
		local v = Util.Sound:Play("X_Held_01", root)
		TweenService:Create(v, TweenInfo.new(0.4), {
			Volume = 1
		}):Play()
		local clone = domain_Katsuo.ShaderScreen:Clone()
		clone.Name = "ControlXShaderScreen"
		clone.Image.ImageTransparency = 1
		local parent

		if player.Player == game.Players.LocalPlayer then
			parent = player.Player.PlayerGui or model
		else
			parent = model
		end

		clone.Parent = parent
		VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.86
		})
		local clone2 = domain_Katsuo.DoubleNeonEye:Clone()
		clone2.Weld.Part0 = character.Head
		Util.SetParentOverrideWithColor(clone2, model, player2, "ControlFruitVFXColor")
		VisualHelper:SetEnableAll(clone2, true)
		local clone3 = c_Katsuo.FloorSpawn:Clone()
		clone3.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")

		if not MathHelper:GroundRayCast(character) then
			clone3.SmokeRotation:Destroy()
		end

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

		Util.Debris:AddItem(clone3, 2.15)
		local clone4 = c_Katsuo.NeonRotation:Clone()
		clone4:ScaleTo(1.2)
		clone4.Main.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone4, model, player2, "ControlFruitVFXColor")
		clone4.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

		for i, child in clone4.Main.Layers:GetChildren() do
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

		Util.Debris:AddItem(clone4, 2)
		local clone5 = x_Katsuo.Handle:Clone()
		clone5.Weld.Part1 = root
		Util.SetParentOverrideWithColor(clone5, model, player2, "ControlFruitVFXColor")
		VisualHelper:Tween(clone5.Beams, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = clone5.Beams.Orientation - createVector(0, 360, 0)
		})
		VisualHelper:SetEnableAll(clone5, true)

		if holding and holding.Value then
			local clone6 = domain_Katsuo.CameraEffectsHex:Clone()
			Util.SetParentOverrideWithColor(clone6, currentCamera, player2, "ControlFruitVFXColor")

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:SetEnableAll(clone6, true)
				VisualHelper:EmitAll(clone6)
			end

			local total = 0

			while holding and holding.Value do
				total += RunService.RenderStepped:Wait()
				clone6.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
			end

			clone6:Destroy()
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		clone5:Destroy()
		clone2:Destroy()
		Util.Debris:AddItem(model, 3)
		Util.Debris:AddItem(clone, 9)
	elseif stage == 2 then
		local player2 = player.Player
		local Players = game:GetService("Players")
		local controlXShaderScreen

		if player2 == Players.LocalPlayer then
			controlXShaderScreen = player2.PlayerGui:FindFirstChild("ControlXShaderScreen")
		else
			controlXShaderScreen = nil
		end

		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		Util.Debris:AddItem(model, 14)
		local _ = player.Character
		local root = player.Root
		local startCFrame = player.StartCFrame
		Util.Sound:Play("X_Release_01", root)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		task.spawn(function()
			local WAIT_INTERVAL = 0.05
			local clone = xOutside.Phase0.Knife:Clone()
			clone:PivotTo(CFrame.new(0, 100000, 0))
			Util.SetParentOverrideWithColor(clone, model, player2, "ControlFruitVFXColor")
			local v = startCFrame
			local distance = player.Distance
			MathHelper:RayCast(v.Position, v.LookVector * (distance + 3), { map }, Enum.RaycastFilterType.Include)

			local function GetCFrameFromRayCast(raycastResult: RaycastResult)
				return raycastResult and CFrame.new(CFrame.lookAt(
					raycastResult.Position,
					raycastResult.Position + raycastResult.Normal
				) * CFrame.new(0, 0, -3).Position) * CFrame.Angles(startCFrame:ToEulerAnglesXYZ())
			end

			local endCFrame = player.EndCFrame
			EmitExplosion(startCFrame * CFrame.new(0, -2.8, 0), nil, player2)

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					FieldOfView = 80
				})
			end

			task.wait(0.085)
			local tween = VisualHelper:Tween(root, TweenInfo.new(player.Duration, Enum.EasingStyle.Linear), {
				CFrame = endCFrame
			})

			for _ = 1, 6 do
				local v2 = 0.45 + math.random() * 0.3
				local position2 = v.Position + Vector3.new(
					math.random(-6.5, 6.5),
					math.random(4.333333333333333),
					math.random(-6.5, 6.5)
				)
				local clone2 = xOutside.Phase0.Vault.HexTrailSpecs:Clone()
				clone2.Position = position2
				Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player2, "ControlFruitVFXColor")
				Debris(clone2, v2 + 0.5)
				local v5 = CFrame.new(math.random(-35, 35), math.random(-35, 35), 0)
				local v6 = CFrame.new(math.random(-35, 35), math.random(-35, 35), 0)
				VisualHelper:TweenNumberValue(1, TweenInfo.new(v2, Enum.EasingStyle.Sine), function(p: number)
					local position = root.Position
					local magnitude = (position2 - position).Magnitude
					local cframe3 = CFrame.lookAt(position2, position)
					clone2.Position = MathHelper:CubicBezier(
						p,
						position2,
						cframe3 * CFrame.new(0, 0, -magnitude * 0.25) * v5.Position,
						cframe3 * CFrame.new(0, 0, -magnitude * 0.75) * v6.Position,
						position
					)
				end)
			end

			local function RushMeshs(flag: boolean?, value: number?, cframe: CFrame?)
				local v2 = value or 1
				local clone2 = xOutside.Phase0.RushMeshs:Clone()
				clone2:PivotTo((cframe or startCFrame) * CFrame.new(0, 0, -8) * CFrame.Angles(1.5707963267948966, 0, 0))
				Util.SetParentOverrideWithColor(clone2, model, player2, "ControlFruitVFXColor")
				Debris(clone2, 1)
				local airMeshHuge = clone2.AirMeshHuge
				VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.3 * v2, Enum.EasingStyle.Sine), {
					Scale = airMeshHuge.Mesh.Scale * createVector(3, 2, 3)
				})
				VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.3 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				local airMeshStorm = clone2.AirMeshStorm

				if flag then
					airMeshStorm.Mesh.Scale = createVector(4.5, 15, 4.5)
					airMeshStorm.Decal.Transparency = 0.9
				end

				VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.2 * v2, Enum.EasingStyle.Sine), {
					Scale = airMeshStorm.Mesh.Scale * (flag and createVector(0.7, 1.5, 0.7) or createVector(
						0.2,
						1.3,
						0.2
					))
				})
				VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.2 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.2 * v2, Enum.EasingStyle.Sine), {
					CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				})
				local airMeshHuge2 = clone2.AirMeshHuge2
				VisualHelper:Tween(airMeshHuge2.Mesh, TweenInfo.new(0.15 * v2, Enum.EasingStyle.Sine), {
					Scale = airMeshHuge2.Mesh.Scale * 1.3
				})
				VisualHelper:Tween(airMeshHuge2.Decal, TweenInfo.new(0.15 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				local airMeshHuge3 = clone2.AirMeshHuge3
				VisualHelper:Tween(airMeshHuge3.Mesh, TweenInfo.new(0.3 * v2, Enum.EasingStyle.Sine), {
					Scale = airMeshHuge3.Mesh.Scale * 1.5
				})
				VisualHelper:Tween(airMeshHuge3.Decal, TweenInfo.new(0.3 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				local airMeshHuge4 = clone2.AirMeshHuge4
				VisualHelper:Tween(airMeshHuge4.Mesh, TweenInfo.new(0.1 * v2, Enum.EasingStyle.Sine), {
					Scale = airMeshHuge4.Mesh.Scale * createVector(3, 1.4, 3)
				})
				VisualHelper:Tween(airMeshHuge4.Decal, TweenInfo.new(0.1 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				local bodyFlash = clone2.BodyFlash
				VisualHelper:Tween(bodyFlash.Decal, TweenInfo.new(0.1 * v2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				VisualHelper:Tween(bodyFlash.Mesh, TweenInfo.new(0.1 * v2, Enum.EasingStyle.Sine), {
					Scale = bodyFlash.Mesh.Scale * createVector(3, 1.8, 3)
				})
			end

			local function Rush(duration: number, cframe: CFrame?)
				RushMeshs(false, 1, cframe)
				local clone2 = xOutside.Phase0.Rush:Clone()
				clone2.CFrame = (cframe or startCFrame) * CFrame.new(0, 0, -clone2.Size.Z / 2)
				Util.SetParentOverrideWithColor(clone2, model, player2, "ControlFruitVFXColor")
				VisualHelper:Tween(clone2.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
				VisualHelper:EmitAll(clone2)
				Debris(clone2, 1.5)
				local beams = clone2.Beams

				for i, child in beams.Beams:GetChildren() do
					child.Enabled = true

					if child.Name == "Air" then
						VisualHelper:Tween(child, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
							Brightness = 0
						})
					else
						local v2 = child.Name == "Fade"
						VisualHelper:Tween(
							child,
							TweenInfo.new(
								v2 and 0.7 or 0.17 + i * 0.01,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.Out,
								0,
								false,
								v2 and 0 or duration * 0.5
							),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
					end
				end

				beams.Drag.Position = createVector(0, 0, 0)
				VisualHelper:Tween(beams.Drag, TweenInfo.new(duration * 0.2, Enum.EasingStyle.Sine), {
					Position = Vector3.new(0, 1, -distance)
				})

				local function NewBolt(beams2, drag, _: number?)
					local v2 = lightningBoltShafi.new(beams2, drag, 15, 0.7 + math.random() * 0.5, model)
					local curveSize = math.random(5, 10)
					local curveSize2 = math.random(-10, -5)
					v2.CurveSize0 = curveSize
					v2.CurveSize1 = curveSize2
					v2.MinRadius = 1
					v2.MaxRadius = 6
					v2.Frequency = 0.7
					v2.AnimationSpeed = math.random(4.5, 8.5)
					local maxThicknessMultiplier = 0.3 + math.random() * 0.75
					v2.MinThicknessMultiplier = 0.1
					v2.MaxThicknessMultiplier = maxThicknessMultiplier
					v2.MinTransparency = 0
					v2.MaxTransparency = 1
					v2.PulseSpeed = 40
					v2.PulseLength = 1000000
					v2.FadeLength = 0.2
					local player3 = player2
					local colorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
					})

					if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
						colorSequence = Util.WrapColorSequenceConstructor(
							colorSequence,
							player3,
							"ControlFruitVFXColor"
						)
					end

					v2.Color = colorSequence
					v2.ContractFrom = 0.5
					v2.ColorOffsetSpeed = 3
					return v2
				end

				Debris(NewBolt(beams, beams.Drag, 20), duration * 0.3 + 0.1)
				Debris(NewBolt(beams, beams.Drag, 20), duration * 0.3 + 0.2)
			end

			if controlXShaderScreen then
				VisualHelper:Tween(controlXShaderScreen.Image, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					ImageTransparency = 0.75
				})
			end

			local duration = player.Duration
			Rush(duration)
			task.wait(duration)

			if controlXShaderScreen then
				VisualHelper:Tween(controlXShaderScreen.Image, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					ImageTransparency = 0.925
				})
			end

			tween:Cancel()
			EmitExplosion(root.CFrame * CFrame.new(0, -2.8, 0), nil, player2)

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					FieldOfView = 70
				})
			end

			local enemyChar = player.EnemyChar

			if enemyChar then
				local humanoidRootPart = enemyChar.HumanoidRootPart
				local throwDirection = player.ThrowDirection
				root.CFrame = throwDirection
				Util.Sound:Play("X_Impact_Slash_01", humanoidRootPart.Position)

				if game.Players.LocalPlayer.Character and root.Parent == game.Players.LocalPlayer.Character then
					local cFrame = root.CFrame
					local currentCamera2 = workspace.CurrentCamera
					local cFrame2 = currentCamera2.CFrame
					local _ = cFrame2.p - root.Position
					local orientation, _, _ = (cFrame2 - cFrame2.p):ToOrientation()
					local _, v2, v3 = cFrame:ToOrientation()
					RunService:BindToRenderStep("controlXTeleportCam", Enum.RenderPriority.Camera.Value + 1, function(p)
						if currentCamera2 then
							currentCamera2.CFrame = currentCamera2.CFrame:Lerp(
								CFrame.new(cFrame.p) * CFrame.fromOrientation(orientation, v2, v3),
								0.2 * p * 60
							)
						else
							RunService:UnbindFromRenderStep("controlXTeleportCam")
						end

						RunService.RenderStepped:Wait()
					end)
					task.spawn(function()
						task.wait(0.4)
						RunService:UnbindFromRenderStep("controlXTeleportCam")
					end)
				end

				EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), nil, player2)
				local clone2 = xOutside.Phase0.CameraEffectsHex:Clone()
				Util.SetParentOverrideWithColor(clone2, currentCamera, player2, "ControlFruitVFXColor")
				local currentCamera2 = workspace.CurrentCamera

				if player.Player == game.Players.LocalPlayer then
					VisualHelper:SetEnableAll(clone2, true)
					VisualHelper:EmitAll(clone2)
				end

				local v2 = nil
				local groundPart = nil
				local clone3 = nil
				local flag = false
				local total = 0
				local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					total += dt
					clone2.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)

					if v2 then
						v2:Update(dt)
					end

					local v3 = total > 0.08

					if v3 then
						total = 0
					end

					if clone3 and v3 then
						local v4 = clone3.Main.Size.X * 2
						clone3:PivotTo(CFrame.new(humanoidRootPart.Position))

						for i = 1, 2 do
							local v5 = 0.2 + math.random(5) * 0.03 - i * 0.05
							local position2 = clone3.Main.Position + Vector3.new(
								math.random(-v4, v4),
								math.random(-v4, v4),
								math.random(-v4, v4)
							)
							local position = clone3.Main.Position
							local clone4 = xOutside.Phase0.VaultC.HexTrailSpecsMove2:Clone()
							Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player2, "ControlFruitVFXColor")
							clone4.Position = position2
							Debris(clone4, v5 + 0.5)
							local magnitude = (position2 - position).Magnitude
							local cframe = CFrame.lookAt(position2, position)
							local v11 = cframe * CFrame.new(
								math.random(-65, 65),
								math.random(-65, 65),
								-magnitude * 0.25
							).Position
							local v12 = cframe * CFrame.new(
								math.random(-65, 65),
								math.random(-65, 65),
								-magnitude * 0.75
							).Position
							VisualHelper:TweenNumberValue(
								1,
								TweenInfo.new(v5, Enum.EasingStyle.Sine),
								function(p: number)
									clone4.Position = MathHelper:CubicBezier(p, position2, v11, v12, position)
								end
							)
						end
					end

					if groundPart then
						local parent = groundPart.Parent
						local v4 = parent.Size.X / 2 + 2
						local rayCast = MathHelper:RayCast(
							parent.Position,
							parent.CFrame.RightVector * -v4,
							{ map },
							Enum.RaycastFilterType.Include
						)

						if rayCast then
							local _, v5 = CFrame.lookAt(
								throwDirection.Position,
								(Vector3.new(rayCast.Position.X, throwDirection.Y, rayCast.Position.Z))
							):ToEulerAnglesYXZ()
							groundPart.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.15, 0)) * CFrame.Angles(
								0,
								v5,
								0
							)

							if not flag then
								flag = true
								VisualHelper:SetEnableAll(groundPart, flag)
							end

							if not v3 then
								return
							end

							local clone4 = xOutside.Phase0.SliceGround:Clone()
							clone4:ScaleTo(random:NextNumber(1.55, 3))
							clone4:PivotTo(CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
								-1.5707963267948966,
								math.rad((math.random(360))),
								0
							) * CFrame.new(math.random(-5, 5), 0, 0))
							Util.SetParentOverrideWithColor(clone4, model, player2, "ControlFruitVFXColor")
							VisualHelper:EmitAll(clone4)
							local size = clone4.SliceGround.Size
							clone4.SliceGround.Size = createVector(0, 0, 0)
							VisualHelper:Tween(clone4.SliceGround, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
								Size = size
							})
							task.delay(0.3, function()
								VisualHelper:Tween(clone4.SliceGround.Decal, TweenInfo.new(0.25), {
									Color3 = Color3.fromRGB()
								})
								VisualHelper:Tween(clone4.SliceGround, TweenInfo.new(0.3), {
									Size = Vector3.new(0, 0, clone4.SliceGround.Size.Z)
								})
								task.wait(0.3)
								clone4:Destroy()
							end)
							local airRocks = Rocks:AirRocks(
								groundPart.CFrame,
								xOutside.Phase0.IronSingleSpark.Size,
								true,
								math.random(50, 115),
								2,
								0,
								20,
								false,
								false,
								xOutside.Phase0.IronSingleSpark:Clone(),
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
						elseif flag then
							flag = false
							VisualHelper:SetEnableAll(groundPart, flag)
						end
					end
				end)
				task.wait(0.22)
				EmitFloor(root.CFrame * CFrame.new(0, -2.8, 0), player2)
				task.wait(WAIT_INTERVAL)
				Slash(
					throwDirection * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, -0.7853981633974483),
					100,
					true,
					3
				)
				task.wait(WAIT_INTERVAL)
				EmitExplosion(root.CFrame * CFrame.new(0, -2.8, 0), nil, player2)
				RushMeshs(true, 0.5)
				local cframe = CFrame.Angles(0, 0, 1.0471975511965976)
				local clone4 = xOutside.Phase0.StormSlash:Clone()
				clone4.CFrame = player.KnockCFrame * CFrame.new(0, 3.3, -4) * cframe
				Util.SetParentOverrideWithColor(clone4, model, player2, "ControlFruitVFXColor")
				groundPart = clone4.GroundPart
				local windStorm = clone4.Charge.WindStorm
				VisualHelper:Tween(
					windStorm,
					TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
					{
						Orientation = windStorm.Orientation - createVector(0, 360, 0)
					}
				)
				local storm = clone4.Charge.Storm
				VisualHelper:Tween(storm, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
					Orientation = storm.Orientation - createVector(0, 360, 0)
				})
				VisualHelper:SetEnableAll(clone4, true, true)
				VisualHelper:SetEnableAll(clone4.Charge, true)
				VisualHelper:EmitAll(clone4.Init)
				VisualHelper:Tween(clone4, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
					CFrame = player.KnockCFrame * cframe
				})
				local knockCFrame = player.KnockCFrame
				local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
				VisualHelper:Tween(humanoidRootPart, tweenInfo2, {
					CFrame = knockCFrame
				})
				VisualHelper:Tween(clone4, tweenInfo2, {
					CFrame = knockCFrame * cframe
				})
				task.spawn(function()
					EmitFloor(root.CFrame * CFrame.new(0, -2.8, 0), player2)
					local cframe2 = CFrame.Angles(0, 0, -1.5707963267948966)
					local cframe3 = CFrame.lookAt(root.Position, humanoidRootPart.Position)
					local _ = player.KnifeDistance
					local time = tweenInfo2.Time
					local slash = Slash(
						cframe3 * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, -0.7853981633974483),
						100,
						true,
						3,
						player2
					)
					EmitExplosion(root.CFrame * CFrame.new(0, -2.8, 0), nil, player2)
					clone:PivotTo(cframe3 * cframe2)

					for _ = 1, 4 do
						local v4 = time * (0.5 + math.random() * 0.5)
						local position2 = cframe3.Position + Vector3.new(
							math.random(-32, 32),
							math.random(21.333333333333332),
							math.random(-32, 32)
						)
						local clone5 = xOutside.Phase0.VaultC.HexTrailSpecs3:Clone()
						clone5.Position = position2
						Util.SetParentOverrideWithColor(clone5, workspace.Terrain, player2, "ControlFruitVFXColor")
						Debris(clone5, v4 + 0.5)
						local v7 = CFrame.new(math.random(-65, 65), math.random(-65, 65), 0)
						local v8 = CFrame.new(math.random(-65, 65), math.random(-65, 65), 0)
						VisualHelper:TweenNumberValue(1, TweenInfo.new(v4, Enum.EasingStyle.Sine), function(p: number)
							local position = clone:GetPivot().Position
							local magnitude = (position2 - position).Magnitude
							local cframe6 = CFrame.lookAt(position2, position)
							clone5.Position = MathHelper:CubicBezier(
								p,
								position2,
								cframe6 * CFrame.new(0, 0, -magnitude * 0.25) * v7.Position,
								cframe6 * CFrame.new(0, 0, -magnitude * 0.75) * v8.Position,
								position
							)
						end)
					end

					local descendants = clone:GetDescendants()

					for _, emitter in pairs(descendants) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter.Rate / 10)
						end
					end

					local lastTime = os.clock()

					while os.clock() - lastTime < time do
						clone:PivotTo(cframe3:Lerp(
							CFrame.lookAt(humanoidRootPart.Position, root.Position) * CFrame.Angles(
								0,
								3.141592653589793,
								0
							),
							(os.clock() - lastTime) / time
						) * cframe2)
						slash.CFrame = clone:GetPivot()
						task.wait()
					end

					for _, instance in pairs(descendants) do
						if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("SurfaceGui") then
							instance.Enabled = false
						elseif instance:IsA("BasePart") then
							instance.Transparency = 1
						end
					end

					task.wait(2)
					clone:Destroy()
				end)
				task.wait(tweenInfo2.Time)
				task.wait(WAIT_INTERVAL)
				groundPart = nil
				VisualHelper:EmitAll(clone4.Init)
				VisualHelper:SetEnableAll(clone4, false)
				Debris(clone4, 1)
				VisualHelper:Tween(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
				local cFrame = humanoidRootPart.CFrame
				EmitExplosion(humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0), nil, player2)
				task.wait(0.03)
				EmitFloor(root.CFrame * CFrame.new(0, -2.8, 0), player2)
				task.wait(0.1)
				task.spawn(function()
					if player.EnemyChar ~= game.Players.LocalPlayer.Character then
						return
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function getHorizontalFov()
						local fieldOfView = game.Workspace.CurrentCamera.FieldOfView
						local viewportSize = game.Workspace.CurrentCamera.ViewportSize
						local v3 = viewportSize.X / viewportSize.Y
						return (math.deg(math.atan(math.tan(math.rad(fieldOfView) * 0.5) * v3) * 2))
					end

					TweenService:Create(currentCamera2, TweenInfo.new(1.2), {
						FieldOfView = 100
					}):Play()
					local v3 = 100 + (getHorizontalFov() - 100) / 1.65
					local v4 = {
						topLeft = CFrame.new() * CFrame.Angles(0.8726646259971648, math.rad(v3 / 2), 0) * CFrame.new(
							0,
							0,
							-5
						),
						topRight = CFrame.new() * CFrame.Angles(0.8726646259971648, -math.rad(v3 / 2), 0) * CFrame.new(
							0,
							0,
							-5
						),
						bottomLeft = CFrame.new() * CFrame.Angles(-0.8726646259971648, math.rad(v3 / 2), 0) * CFrame.new(
							0,
							0,
							-5
						),
						bottomRight = CFrame.new() * CFrame.Angles(-0.8726646259971648, -math.rad(v3 / 2), 0) * CFrame.new(
							0,
							0,
							-5
						)
					}
					local magnitude = (v4.topLeft.Position - v4.topRight.Position).magnitude
					local magnitude2 = (v4.topLeft.Position - v4.bottomLeft.Position).magnitude
					local currentCamera3 = workspace.CurrentCamera
					local clone5 = xOutside.Phase1.CameraFocus1:Clone()
					clone5.Size = Vector3.new(magnitude, magnitude2, magnitude)
					clone5.Parent = model
					local renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
						clone5.CFrame = currentCamera3.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 0)
					end)

					for _, descendant in pairs(clone5:GetDescendants()) do
						if descendant:IsA("Beam") then
							local v5 = descendant
							task.spawn(function()
								if v5.Name == "Beam" then
									v5.Enabled = false
								elseif v5.Name == "Beam2" then
									v5.Transparency = NumberSequence.new(1, 1)
									v5.Enabled = true
								end
							end)
						elseif descendant:IsA("Attachment") then
							if descendant.Name ~= "Attachment" then
								descendant:SetAttribute("1", descendant.Position)
								descendant.Position = descendant.Parent.Attach0.Position
							end
						elseif descendant:IsA("ParticleEmitter") and descendant.Parent.Name ~= "Attachment" then
							descendant.Enabled = false
						end
					end

					for _, child in pairs(clone5:GetChildren()) do
						local folder = child
						task.spawn(function()
							for i, descendant in pairs(folder:GetDescendants()) do
								if descendant:IsA("Beam") then
									local v5 = descendant
									task.spawn(function()
										if v5.Name == "Beam" then
											v5.Enabled = true
											local tween2 = TweenService:Create(
												v5,
												TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
												{
													TextureSpeed = 10
												}
											)
											tween2:Play()
											tween2.Completed:Wait()
											TweenService:Create(
												v5,
												TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
												{
													TextureSpeed = 7
												}
											):Play()
											task.wait(0.075)

											for i2 = 0, 10 do
												v5.Transparency = NumberSequence.new(i2 / 10, i2 / 10)
												task.wait(0.01)
											end
										elseif v5.Name == "Beam2" then
											v5.Transparency = NumberSequence.new(1, 1)
											task.wait(0.15)
											v5.Enabled = true
											task.spawn(function()
												for i2 = 10, 0, -1 do
													v5.Transparency = NumberSequence.new(i2 / 10, i2 / 10)
													task.wait(0.025)
												end
											end)
											v5.TextureLength = math.random(20, 100)
											local tween2 = TweenService:Create(
												v5,
												TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
												{
													TextureSpeed = 3
												}
											)
											tween2:Play()
											tween2.Completed:Wait()
											TweenService:Create(
												v5,
												TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
												{
													TextureSpeed = math.random(1, 10) / 10
												}
											):Play()
										end
									end)
								elseif descendant:IsA("Attachment") then
									if descendant.Name ~= "Attachment" then
										local v5 = descendant
										task.spawn(function()
											if v5.Name == "Attach1" then
												local tween2 = TweenService:Create(
													v5,
													TweenInfo.new(
														0.075,
														Enum.EasingStyle.Quad,
														Enum.EasingDirection.Out
													),
													{
														Position = v5:GetAttribute("1")
													}
												)
												task.wait(math.random(20, 40) / 500)
												tween2:Play()
											end
										end)
									end
								elseif descendant:IsA("ParticleEmitter") and descendant.Parent.Name ~= "Attachment" then
									local v5 = descendant
									task.spawn(function()
										v5.Enabled = false
										task.wait(0.05)
										v5.Enabled = true
										task.wait(0.1)
										v5.Enabled = false
									end)
								end
							end
						end)
						task.wait(0.05 + math.random() * 0.025)
					end

					task.wait(0.5)
					TweenService:Create(currentCamera3, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
						FieldOfView = 70
					}):Play()
					local bloomEffect = Instance.new("BloomEffect")
					bloomEffect.Intensity = 2
					bloomEffect.Size = 12
					bloomEffect.Threshold = 0
					bloomEffect.Parent = game.Lighting
					local tween2 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
						Intensity = 0
					})
					tween2.Completed:Connect(function()
						bloomEffect:Destroy()
					end)
					tween2:Play()

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("Beam") then
							local v5 = effect
							task.spawn(function()
								TweenService:Create(
									v5,
									TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
									{
										Width0 = 0,
										Width1 = 0,
										TextureSpeed = 15
									}
								):Play()
							end)
						elseif effect:IsA("ParticleEmitter") and effect.Parent.Name == "Attachment" then
							effect:Emit(effect:GetAttribute("EmitCount"))
						end
					end

					task.wait(1)
					renderSteppedConnection2:Disconnect()
					clone5:Destroy()
				end)
				clone3 = xOutside.Phase0.SliceBall:Clone()
				clone3:PivotTo(cFrame)
				Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")
				local flash = clone3.Main.Flash
				flash.Parent = model
				flash.WorldCFrame = cFrame
				VisualHelper:EmitAll(flash)
				v2 = HexsStormClass.new(clone3.Main, nil, player2)
				v2.YFactor = clone3.Main.Size.Y / 2

				for i = -1, 1, 0.2 do
					local v3 = i > 0.3 and "Gradient" or "Normal"
					local v4 = v2.YFactor * 2.5
					v2:AddHex(v3, i, v4, i * 360, random:NextNumber(50, 450))
				end

				for k in v2.Data do
					k.Size *= 3.25
				end

				local scale = clone3:GetScale()
				VisualHelper:TweenScale(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Sine), scale * 1.4)
				task.wait(0.8)
				VisualHelper:TweenScale(
					clone3,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					scale * 0.3
				)
				task.wait(0.3)
				VisualHelper:EmitAll(flash)
				Debris(flash, 2)

				for k in v2.Data do
					VisualHelper:Tween(k, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Size = createVector(0, 0, 0)
					})
				end

				task.delay(0.5, function()
					v2 = nil
				end)
				clone3:Destroy()
				clone3 = nil
				EmitExplosion(CFrame.new(humanoidRootPart.Position) * CFrame.new(0, -2.8, 0), nil, player2)
				Flash(root, false, player2)
				RushMeshs(false, 1, CFrame.lookAt(endCFrame.Position, humanoidRootPart.Position))
				renderSteppedConnection:Disconnect()
				clone2:Destroy()

				if controlXShaderScreen then
					VisualHelper:Tween(controlXShaderScreen.Image, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					})
					Debris(controlXShaderScreen, 0.5)
				end
			else
				if controlXShaderScreen then
					VisualHelper:Tween(controlXShaderScreen.Image, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					})
					Debris(controlXShaderScreen, 0.5)
				end

				clone:Destroy()
			end
		end)
	end
end