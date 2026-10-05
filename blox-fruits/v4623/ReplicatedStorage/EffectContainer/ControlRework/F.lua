local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local domain_Katsuo = FX:WaitForChild("ControlRework").Domain_Katsuo
local f_Katsuo = FX:WaitForChild("ControlRework").F_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local Textures = require(shared.Textures)
local Rocks = require(shared.Rocks)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function Slash(cFrame: CFrame, value: number?, flag: boolean?, value2: number?, p)
	local clone = c_Katsuo.Slash:Clone()
	clone:ScaleTo(value2 or 1.65)
	local slash = clone.Slash
	slash.PointLight:Destroy()
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, workspace._WorldOrigin, p, "ControlFruitVFXColor")
	clone:Destroy()
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

	Util.Debris:AddItem(slash, 2)
	return slash
end

local function DarkSlash(cFrame: CFrame, rotation: number?, flag: boolean?, scale: number?, player)
	local clone = f_Katsuo.DarkSlash:Clone()
	clone:ScaleTo(scale or 1.65)
	local slash = clone.Slash
	slash.PointLight:Destroy()
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, workspace._WorldOrigin, player, "ControlFruitVFXColor")
	clone:Destroy()
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

	Util.Debris:AddItem(slash, 2)
	local staticSlash = slash.StaticSlash
	staticSlash.Beam.Enabled = true
	task.delay(0.025, function()
		staticSlash:Destroy()
	end)
	return slash
end

local function Flash(root, player)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = f_Katsuo.Vault.Flash:Clone()
	Util.SetParentOverrideWithColor(clone, root, player, "ControlFruitVFXColor")

	if MathHelper:RayCast(
		root.Position,
		root.CFrame.UpVector * -5,
		{ workspace.Characters, workspace._WorldOrigin, workspace.Enemies },
		Enum.RaycastFilterType.Exclude
	) then
		Util.Sound:Play("CtrlFt_F_TeleportToKnife_Ground_0" .. tostring(math.random(1, 3)), root)
	else
		Util.Sound:Play("CtrlFt_F_TeleportToKnife_InAir_0" .. tostring(math.random(1, 3)), root)
	end

	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 0.6)
end

local function EmitExplosion(cFrame, flag: boolean?, player)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)

	if not cFrame then
		return
	end

	local v = typeof(cFrame) == "RaycastResult"

	if v then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local clone = f_Katsuo.Explosion:Clone()
	clone:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")

	if not v then
		clone.Main.GlowShape.Crater:Destroy()
	end

	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 6)
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

	Util.Debris:AddItem(beams, 0.5)
	local clone2 = c_Katsuo.BallNeon:Clone()
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
	Util.Debris:AddItem(clone2, 0.14)
	local clone3 = c_Katsuo.BallNeon:Clone()
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
	Util.Debris:AddItem(clone3, 0.15)

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
				local clone4 = f_Katsuo.BoltExplosion:Clone()
				clone4.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				Util.SetParentOverrideWithColor(clone4, model, player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone4)
				Util.Debris:AddItem(clone4, 1)
			end

			task.wait(0.125)
		end
	end)
end

local function SmashBeams(cframe: CFrame, p: number?, player)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 2)
	local clone = f_Katsuo.SmashBeams:Clone()

	if p then
		clone:ScaleTo(p)
	end

	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	Util.Debris:AddItem(clone, 0.5)
	local frontWinds = clone.Main.FrontWinds
	VisualHelper:Tween(frontWinds, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Orientation = frontWinds.Orientation + createVector(0, 0, 250)
	})

	for _, child in frontWinds:GetChildren() do
		local beamMain = child.BeamMain
		beamMain.Enabled = true
		VisualHelper:Tween(beamMain, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, v in { clone.Main.CircleBeam.Beam1, clone.Main.CircleBeam.Beam2 } do
		v.Enabled = true
		VisualHelper:Tween(v, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end
end

local function SmashMeshs(cframe: CFrame, player)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = f_Katsuo.SmashMeshs:Clone()
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	Util.Debris:AddItem(clone, 1)
	local airMeshHuge = clone.AirMeshHuge
	VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.07, Enum.EasingStyle.Sine), {
		Scale = airMeshHuge.Mesh.Scale * createVector(2, 1.25, 2)
	})
	VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.07, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	local airMeshStorm = clone.AirMeshStorm
	VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Scale = airMeshStorm.Mesh.Scale * createVector(0.2, 1.3, 0.2)
	})
	VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	})
	local bodyFlash = clone.BodyFlash
	VisualHelper:Tween(bodyFlash.Decal, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	VisualHelper:Tween(bodyFlash.Mesh, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Scale = bodyFlash.Mesh.Scale * createVector(3, 1.8, 3)
	})
	local airMeshHuge2 = clone.AirMeshHuge2
	VisualHelper:Tween(airMeshHuge2.Mesh, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Scale = airMeshHuge2.Mesh.Scale * createVector(2, 1.25, 2)
	})
	VisualHelper:Tween(airMeshHuge2.Decal, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	local airMeshHuge3 = clone.AirMeshHuge3
	VisualHelper:Tween(airMeshHuge3.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Scale = airMeshHuge3.Mesh.Scale * createVector(1.5, 1.25, 1.5)
	})
	VisualHelper:Tween(airMeshHuge3.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Transparency = 1
	})
	local airMeshHuge4 = clone.AirMeshHuge4
	VisualHelper:Tween(airMeshHuge4.Mesh, TweenInfo.new(0.22, Enum.EasingStyle.Cubic), {
		Scale = airMeshHuge4.Mesh.Scale * createVector(3, 1.4, 3)
	})
	VisualHelper:Tween(airMeshHuge4.Decal, TweenInfo.new(0.22, Enum.EasingStyle.Cubic), {
		Transparency = 1
	})
	local circleWave = clone.CircleWave
	local size = circleWave.Size
	circleWave.Size = size * 0.5
	VisualHelper:Tween(circleWave, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		CFrame = circleWave.CFrame * CFrame.new(0, 3, 0),
		Transparency = 1,
		Size = size
	})
end

local random = Random.new()
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

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local player2 = player.Player
		local root = player.Root
		local character = player.Character
		local Players = game:GetService("Players")
		local Mouse

		if Players.LocalPlayer == player2 then
			Mouse = require(ReplicatedStorage.Mouse)
		else
			Mouse = nil
		end

		local model = Instance.new("Model")
		model.Parent = workspace._WorldOrigin
		Util.Sound:Play("CtrlFt_F_Activate_01", root.Position)
		local v = Util.Sound:Play("CtrlFt_F_Held_CharacterVFX_01", root.Position)
		TweenService:Create(v, TweenInfo.new(0.7), {
			Volume = 1
		}):Play()
		local clone, clone2, v2

		if Mouse then
			VisualHelper:Tween(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				FieldOfView = 76
			})
			clone = domain_Katsuo.ShaderScreen:Clone()
			clone.Image.ImageTransparency = 1
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local v3

			if player.Player == game.Players.LocalPlayer then
				v3 = player.Player:FindFirstChild("PlayerGui") or model
			else
				v3 = model
			end

			setParentOverrideWithColor(clone, v3, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
				ImageTransparency = 0.86
			})
			clone2 = f_Katsuo.Vault.Indicator:Clone()
			Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			v2 = Util.Sound:Play("CtrlFt_F_Held_IndicatorLocation_01", clone2)
			VisualHelper:SetEnableAll(clone2.Drag.Glow, true)

			for _, child in clone2.Drag.Beams:GetChildren() do
				child.Enabled = true
				local width0 = child.Width0
				local width1 = child.Width1
				VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Width1 = width1,
					Width0 = width0
				})
			end
		else
			clone2 = nil
		end

		local clone3 = domain_Katsuo.DoubleNeonEye:Clone()
		clone3.Weld.Part0 = character.Head
		Util.SetParentOverrideWithColor(clone3, model, player.Player, "ControlFruitVFXColor")
		VisualHelper:SetEnableAll(clone3, true)
		local clone4 = c_Katsuo.FloorSpawn:Clone()
		clone4.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		Util.SetParentOverrideWithColor(clone4, model, player.Player, "ControlFruitVFXColor")

		if not MathHelper:GroundRayCast(character) then
			clone4.SmokeRotation:Destroy()
		end

		VisualHelper:Tween(clone4.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Orientation = clone4.CircleWinds.Orientation + createVector(0, 180, 0)
		})
		VisualHelper:EmitAll(clone4)
		clone4.PointLight.Enabled = true
		VisualHelper:Tween(clone4.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 0
		})

		for _, child in clone4.CircleWinds:GetChildren() do
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

		Util.Debris:AddItem(clone4, 2.15)
		local clone5 = c_Katsuo.NeonRotation:Clone()
		clone5:ScaleTo(1.2)
		clone5.Main.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone5, model, player.Player, "ControlFruitVFXColor")
		clone5.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

		for i, child in clone5.Main.Layers:GetChildren() do
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

		Util.Debris:AddItem(clone5, 2)
		local clone6 = c_Katsuo.Handle:Clone()
		clone6.Weld.Part1 = root
		Util.SetParentOverrideWithColor(clone6, model, player.Player, "ControlFruitVFXColor")

		if not MathHelper:GroundRayCast(character) then
			clone6.Attachment.Smoke:Destroy()
		end

		VisualHelper:Tween(clone6.Beams, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = clone6.Beams.Orientation - createVector(0, 360, 0)
		})
		VisualHelper:SetEnableAll(clone6, true)
		local clone7 = f_Katsuo.Knife:Clone()
		clone7:PivotTo(root.CFrame - createVector(0, 600, 0))
		Util.SetParentOverrideWithColor(clone7, model, player.Player, "ControlFruitVFXColor")

		local function Update()
			if Mouse then
				local position = root.Position
				local cframe = CFrame.lookAt(root.Position, Mouse.Hit.Position)
				local rayCast = MathHelper:RayCast(
					position,
					cframe.LookVector * 500,
					{ workspace.Enemies, workspace.Characters, workspace._WorldOrigin }
				)
				clone2.Position = position
				clone2.Drag.WorldPosition = rayCast and rayCast.Position or cframe * CFrame.new(0, 0, -500).Position
			end
		end

		Update()

		if holding and holding.Value then
			local clone8 = domain_Katsuo.CameraEffectsHex:Clone()
			Util.SetParentOverrideWithColor(clone8, currentCamera, player.Player, "ControlFruitVFXColor")

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:SetEnableAll(clone8, true)
				VisualHelper:EmitAll(clone8)
			end

			while holding and holding:IsDescendantOf(workspace) and holding.Value and holding and holding.Value do
				clone8.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
				Update()
				RunService.RenderStepped:Wait()
			end

			clone8:Destroy()
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		if Mouse then
			VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				FieldOfView = 70
			})
		end

		if clone then
			VisualHelper:Tween(clone.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				ImageTransparency = 1
			})
			Util.Debris:AddItem(clone, 0.5)
		end

		Util.Debris:AddItem(model, 5)
		task.spawn(function()
			task.wait(0.225)

			if clone2 then
				Util.Debris:AddItem(clone2, 0.5)
				VisualHelper:SetEnableAll(clone2.Drag.Glow, false)

				for _, child in clone2.Drag.Beams:GetChildren() do
					VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Width1 = 0,
						Width0 = 0
					})
				end
			end

			VisualHelper:SetEnableAll(clone6, false)
			Util.Debris:AddItem(clone6, 1.5)
			VisualHelper:SetEnableAll(clone3, false)
			Util.Debris:AddItem(clone3, 1)
		end)
	elseif stage == 2 then
		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Debris:AddItem(model, 15)
		local proxyCFrame = player.ProxyCFrame

		if not proxyCFrame then
			return
		end

		local root = player.Root
		local character = player.Character
		local cFrame = root.CFrame
		local startCFrame = player.StartCFrame
		local clone = f_Katsuo.Knife:Clone()
		clone:PivotTo(root.CFrame - createVector(0, 600, 0))
		Util.SetParentOverrideWithColor(clone, model, player.Player, "ControlFruitVFXColor")
		Util.Sound:Play("CtrlFt_F_ThrowKnife_0" .. tostring(math.random(1, 2)), root)
		Slash(
			startCFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, -0.7853981633974483),
			100,
			true,
			3
		)

		local function EmitFloor()
			local clone2 = c_Katsuo.FloorSpawnEnd:Clone()
			clone2.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
			Util.SetParentOverrideWithColor(clone2, model, player.Player, "ControlFruitVFXColor")

			if not MathHelper:GroundRayCast(character) then
				clone2.SmokeRotation:Destroy()
			end

			VisualHelper:EmitAll(clone2)
			clone2.PointLight.Enabled = true
			VisualHelper:Tween(clone2.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
			Util.Debris:AddItem(clone2, 2.15)
		end

		EmitFloor()
		clone:PivotTo(startCFrame * CFrame.Angles(0, 0, -1.5707963267948966))
		local beam = clone.Main.Charge.TrailsBeam.Point3.Beam
		local thread = task.spawn(function()
			while true do
				for _, texture in Textures.WindBeam do
					beam.Texture = texture
					task.wait(0.02)
				end
			end
		end)
		local smash = clone.Main.Smash
		smash.Parent = workspace.Terrain
		smash.CFrame = startCFrame * CFrame.new(0, 0, -4)
		VisualHelper:EmitAll(smash.Particles)
		local frontWinds = smash.FrontWinds
		VisualHelper:Tween(frontWinds, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Orientation = frontWinds.Orientation + createVector(0, 0, 250)
		})
		local heartbeatConnection = nil
		local childAddedConnection = nil

		for _, child in frontWinds:GetChildren() do
			local beamMain = child.BeamMain
			beamMain.Enabled = true
			VisualHelper:Tween(beamMain, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		for _, v in { smash.CircleBeam.Beam1, smash.CircleBeam.Beam2 } do
			v.Enabled = true
			VisualHelper:Tween(v, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Util.Debris:AddItem(smash, 1)
		local flag = false
		local clone2 = f_Katsuo.Vault.Smokes:Clone()
		Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player.Player, "ControlFruitVFXColor")
		VisualHelper:SetEnableAll(clone2, flag)
		local total = 0
		local v = 450
		local total2 = 0
		local v2 = false

		local function TeleportToKnife()
			local busy = root.Parent:FindFirstChild("Busy")
			local stun = root.Parent:FindFirstChild("Stun")

			if busy and busy.Value or stun and stun.Value > 0 then
				return
			end

			task.spawn(function()
				local clone3 = f_Katsuo.Beam:Clone()
				cFrame = CFrame.new(root.Position, clone:GetPivot().Position)
				local position = cFrame.Position
				local v3 = -cFrame.LookVector
				local vector2 = Vector3.new(v3.X, v3.Y, v3.Z)
				local v4 = vector2.Magnitude < 0.001 and createVector(0, 0, -1) or vector2.Unit
				clone3.CFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + v4)
				Util.SetParentOverrideWithColor(clone3, model, player.Player, "ControlFruitVFXColor")
				local position2 = clone:GetPivot().Position
				local magnitude = (Vector3.new(position2.X, position.Y, position2.Z) - position).Magnitude

				local function clearOld()
					for _, child in ipairs(clone3:GetChildren()) do
						if child:IsA("Attachment") or child:IsA("Beam") then
							child:Destroy()
						end
					end
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function newAttachment(position3)
					local attachment = Instance.new("Attachment")
					attachment.Position = position3
					attachment.Parent = clone3
					return attachment
				end

				local function newBeam(attachment, attachment2)
					local clone4 = f_Katsuo.Beam.Beam:Clone()
					clone4.Attachment0 = attachment
					clone4.Attachment1 = attachment2
					clone4.Transparency = NumberSequence.new(1)
					Util.SetParentOverrideWithColor(clone4, attachment, player.Player, "ControlFruitVFXColor")
					return clone4
				end

				local function buildRandomPath()
					clearOld()
					math.randomseed(os.clock() * 100000)
					local v5 = {}
					local attachment = Instance.new("Attachment")
					attachment.Position = createVector(0, 0, 0)
					attachment.Parent = clone3
					table.insert(v5, attachment)

					for i = 1, 10 do
						local v6 = i / 10
						local v7 = createVector(0, 0, 1) * (v6 * magnitude)
						local v8 = (math.random() * 2 - 1) * 70 * (1 - v6)
						local v9 = v7 + createVector(-1, 0, 0) * v8 + createVector(0, 0, 0)

						if i == 10 then
							v9 = createVector(0, 0, 1) * magnitude + createVector(0, 0, 0)
						end

						table.insert(v5, newAttachment(v9))
					end

					local clones = {}

					for i = 1, #v5 - 1 do
						local attachment2 = v5[i]
						local attachment3 = v5[i + 1]
						local clone4 = f_Katsuo.Beam.Beam:Clone()
						clone4.Attachment0 = attachment2
						clone4.Attachment1 = attachment3
						clone4.Transparency = NumberSequence.new(1)
						Util.SetParentOverrideWithColor(clone4, attachment2, player.Player, "ControlFruitVFXColor")
						table.insert(clones, clone4)
					end

					return clones
				end

				local function animatePath()
					local randomPath = buildRandomPath()

					for i = 1, #randomPath do
						randomPath[i].Transparency = NumberSequence.new(0)
						task.wait(0.008)
					end
				end

				task.defer(function()
					animatePath()

					for _, beam2 in pairs(clone3:GetDescendants()) do
						if not beam2:IsA("Beam") then
							continue
						end

						TweenService:Create(beam2, TweenInfo.new(0.025), {
							Width0 = 5,
							Width1 = 5
						}):Play()
						local v5 = beam2
						task.delay(0.025, function()
							TweenService:Create(v5, TweenInfo.new(0.075), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end)
					end

					task.wait(0.5)
					clone3:Destroy()
				end)
			end)
			proxyCFrame.Value = clone:GetPivot()
			root.CFrame = CFrame.new(clone:GetPivot().Position) * CFrame.Angles(root.CFrame:ToEulerAnglesYXZ())
			player.KnifeLanded:FireServer(root.CFrame)
			Flash(root, player.Player)
		end

		local function CleanupKnife()
			heartbeatConnection:Disconnect()
			childAddedConnection:Disconnect()
			task.cancel(thread)
			clone:Destroy()
			VisualHelper:SetEnableAll(clone2, false)
			Util.Debris:AddItem(clone2, 3)
		end

		local humanoid = player.Humanoid or character:FindFirstChild("Humanoid")
		childAddedConnection = character.ChildAdded:Connect(function(child)
			if child.Name == "ControlFGrabStarted" then
				root.CFrame = child.Value
				Flash(root, player.Player)
				EmitExplosion(
					MathHelper:RayCast(
						root.Position,
						root.CFrame.UpVector * -5,
						{ workspace.Map, ObjectClass.Folder },
						Enum.RaycastFilterType.Include
					),
					nil,
					player.Player
				)
				CleanupKnife()
			end
		end)
		local clone3 = f_Katsuo.Aura:Clone()
		clone3.Anchored = false
		clone3.Massless = true
		Util.SetParentOverrideWithColor(clone3, clone, player.Player, "ControlFruitVFXColor")
		clone3.Weld.Part1 = clone.PrimaryPart
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			total2 += dt

			if total >= 0.75 then
				TeleportToKnife()
				CleanupKnife()
			else
				v = math.min(v + 550 * dt, 2500)
				local v3 = v * dt
				local pivot = clone:GetPivot()
				local rayCast = MathHelper:RayCast(
					pivot.Position,
					pivot.LookVector * v3,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)

				if not rayCast then
					local child = workspace._WorldOrigin:FindFirstChild("Cubes-Objects"):FindFirstChild(character.Name)

					if child then
						rayCast = MathHelper:RayCast(
							pivot.Position,
							pivot.LookVector * v3,
							{ child },
							Enum.RaycastFilterType.Include
						)
					end
				end

				if rayCast then
					CleanupKnife()
					EmitExplosion(
						MathHelper:RayCast(
							root.Position,
							root.CFrame.UpVector * -5,
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
							Enum.RaycastFilterType.Exclude
						),
						nil,
						player.Player
					)

					if rayCast and ObjectClass:EnergizeNearbyObjects(rayCast.Instance.Parent) then
						if game.Players.LocalPlayer == player.Player then
							VisualHelper:Tween(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
								FieldOfView = 60
							})
							player.KnifeLanded:FireServer(root.CFrame, true)
						end

						root.Anchored = true
						humanoid.AutoRotate = false
						local _, v4 = character:GetPivot():ToEulerAnglesYXZ()
						character:PivotTo(CFrame.lookAt(rayCast.Position, rayCast.Normal + rayCast.Position) * CFrame.Angles(
							-1.5707963267948966,
							v4 + -1.5707963267948966,
							0
						) * CFrame.new(0, 3, 0))
						task.delay(0.5, function()
							if game.Players.LocalPlayer == player.Player then
								VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
									FieldOfView = 70
								})
							end

							root.Anchored = false
							humanoid.AutoRotate = true
							root.AssemblyLinearVelocity = root.CFrame.UpVector * 125
							humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
						end)
					else
						TeleportToKnife()
					end

					task.spawn(function()
						local clone4 = f_Katsuo.EndImpact:Clone()
						clone4.CFrame = CFrame.new(root.Position, cFrame.Position) * CFrame.new(0, 0, -50) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						)
						Util.SetParentOverrideWithColor(clone4, model, player.Player, "ControlFruitVFXColor")
						Util.Debris:AddItem(clone4, 0.6)

						for _, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)
					EmitExplosion(rayCast, nil, player.Player)
					task.wait(0.05)
					task.wait(0.09)
					local highlight = Instance.new("Highlight")
					highlight.Adornee = character
					highlight.FillTransparency = 0
					highlight.OutlineTransparency = 1
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					local player2 = player.Player
					local color = Color3.fromRGB(76, 139, 255)

					if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
						color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
					end

					highlight.FillColor = color
					highlight.Parent = model
					VisualHelper:Tween(highlight, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						FillTransparency = 1
					})
					Util.Debris:AddItem(highlight, 0.6)
					task.wait(0.05)
					EmitFloor()
				else
					local v4 = clone.Main.Size.X / 2 + 10
					local rayCast2 = MathHelper:RayCast(
						pivot.Position,
						pivot.RightVector * v4,
						{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
					)

					if rayCast2 then
						local _, v5 = startCFrame:ToEulerAnglesYXZ()
						clone2.CFrame = CFrame.new(rayCast2.Position + createVector(0, 0.15, 0)) * CFrame.Angles(
							0,
							v5,
							0
						)

						if not flag then
							flag = true
							VisualHelper:SetEnableAll(clone2, flag)
						end

						if total2 > 0.15 then
							total2 = 0
							v2 = not v2

							if v2 then
								Rocks:AirRocks(
									clone2.CFrame,
									Vector3.new(1, random:NextNumber(0.6, 1), random:NextNumber(1, 1.5)) * random:NextNumber(
										1.7,
										2.2
									),
									true,
									math.random(25, 115),
									random:NextNumber(0.5, 1),
									1.5 + math.random() * 0.5,
									false,
									rayCast2.Instance.Color,
									rayCast2.Instance.Material
								)
							end

							local clone4 = f_Katsuo.SliceGround:Clone()
							clone4:ScaleTo(random:NextNumber(1.55, 3))
							clone4:PivotTo(CFrame.lookAt(rayCast2.Position, rayCast2.Position + rayCast2.Normal) * CFrame.Angles(
								-1.5707963267948966,
								math.rad((math.random(360))),
								0
							) * CFrame.new(math.random(-5, 5), 0, 0))
							Util.SetParentOverrideWithColor(clone4, model, player.Player, "ControlFruitVFXColor")
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
						end
					elseif flag then
						flag = false
						VisualHelper:SetEnableAll(clone2, flag)
					end

					local controlKnifeFlying_Client = character:FindFirstChild("ControlKnifeFlying_Client") or character:FindFirstChild("ControlKnifeFlying")

					if controlKnifeFlying_Client and controlKnifeFlying_Client:GetAttribute("Tapped") then
						TeleportToKnife()
						CleanupKnife()
					end

					clone:PivotTo(pivot * CFrame.new(0, 0, -v3))
				end
			end
		end)
	elseif stage == 3 then
		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Debris:AddItem(model, 8)
		local victimChar = player.VictimChar
		local root = player.Root
		local character = player.Character
		local player2 = player.Player

		if not victimChar then
			return
		end

		tick()

		local function EmitFloor()
			local clone = c_Katsuo.FloorSpawnEnd:Clone()
			clone.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
			Util.SetParentOverrideWithColor(clone, model, player.Player, "ControlFruitVFXColor")

			if not MathHelper:GroundRayCast(character) then
				clone.SmokeRotation:Destroy()
			end

			VisualHelper:EmitAll(clone)
			clone.PointLight.Enabled = true
			VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
			Util.Debris:AddItem(clone, 2.15)
		end

		if victimChar then
			local humanoidRootPart = victimChar.HumanoidRootPart
			local startCFrame = player.StartCFrame
			local enemyCFrame = player.EnemyCFrame
			Util.Sound:Play("CtrlFt_F_Grab_Slash_AndThrow_01", root)
			humanoidRootPart.CFrame = enemyCFrame
			root.CFrame = startCFrame
			root.Anchored = true
			task.spawn(function()
				local currentCamera2 = workspace.CurrentCamera
				local clone = f_Katsuo.CameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone, model, player.Player, "ControlFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
				end)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(1)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			end)
			local clone = domain_Katsuo.CameraEffectsHex:Clone()
			Util.SetParentOverrideWithColor(clone, currentCamera, player.Player, "ControlFruitVFXColor")

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:SetEnableAll(clone, true)
				VisualHelper:EmitAll(clone)
			end

			local total = 0
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += dt
				clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
			end)
			local clone2 = f_Katsuo.Hit:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			Util.SetParentOverrideWithColor(clone2, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:EmitAll(clone2.Boom)
			humanoidRootPart.CFrame = player.VictimCF3
			local tweenInfo = TweenInfo.new(0.8966666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local tween = VisualHelper:Tween(root, tweenInfo, {
				CFrame = player.EndCFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
			})
			local tween2 = VisualHelper:Tween(humanoidRootPart, tweenInfo, {
				CFrame = player.EndCFrame
			})
			clone2.CFrame = enemyCFrame
			VisualHelper:EmitAll(clone2.BoomEnd)
			local clone3 = f_Katsuo.HitImpact:Clone()
			clone3.CFrame = humanoidRootPart.CFrame
			Util.SetParentOverrideWithColor(clone3, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:EmitAll(clone3)
			task.wait(0.1)
			local v = {
				{
					Angle = 0,
					Rotation = 0,
					Scale = 4
				},
				{
					Angle = 90,
					Rotation = 95,
					Scale = 3
				},
				{
					Angle = 45,
					Rotation = 100,
					Scale = 3
				},
				{
					Angle = -45,
					Rotation = -100,
					Scale = 3
				},
				{
					Angle = 0,
					Rotation = 0,
					Scale = 4
				}
			}
			local clone4 = nil
			tick()
			local waitScheduler = Util.WaitScheduler.new()
			local highlight = Instance.new("Highlight")
			highlight.Adornee = character
			highlight.FillTransparency = 0
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			local player3 = player.Player
			local color = Color3.fromRGB(76, 139, 255)

			if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
				color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
			end

			highlight.FillColor = color
			highlight.Parent = model
			local count = 0
			local v2 = nil

			for i = 1, 3 do
				for k, v3 in v do
					count += 1
					DarkSlash(
						root.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, 3.141592653589793, (math.rad(v3.Angle))),
						v3.Rotation,
						true,
						v3.Scale,
						player.Player
					)
					clone3.CFrame = humanoidRootPart.CFrame
					VisualHelper:EmitAll(clone3)

					if k % 3 == 0 then
						EmitFloor()
					end

					waitScheduler:wait(0.03333333333333333)
				end

				if i == 3 then
					break
				end

				if game.Players.LocalPlayer == player.Player and not clone4 then
					clone4 = domain_Katsuo.ShaderScreen:Clone()
					clone4.Image.ImageTransparency = 1
					clone4.Name = VisualHelper:BuildUniqueName(character, "Shader-Screen")
					Util.SetParentOverrideWithColor(clone4, player2.PlayerGui, player.Player, "ControlFruitVFXColor")
					VisualHelper:Tween(clone4.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
						ImageTransparency = 0.83
					})
				end

				EmitFloor()
				Flash(root, player.Player)
				waitScheduler:wait(0.03)
				EmitFloor()
				Flash(root, player.Player)

				if v2 then
					v2:Pause()
					v2:Destroy()
				end

				highlight.FillTransparency = 0
				v2 = VisualHelper:Tween(highlight, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
					FillTransparency = 1
				})
				waitScheduler:wait(0.045)
			end

			waitScheduler:wait(0.05)
			EmitFloor()
			waitScheduler:wait(0.13)

			if clone4 then
				VisualHelper:Tween(clone4.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					ImageTransparency = 1
				})
				Util.Debris:AddItem(clone4, 0.5)
			end

			tween:Pause()
			tween2:Pause()
			tween:Destroy()
			tween2:Destroy()
			root.CFrame = player.EndCFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
			humanoidRootPart.CFrame = player.EndCFrame

			if game.Players.LocalPlayer == player.Player then
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
					FieldOfView = 60
				})
			end

			local clone5 = f_Katsuo.Vault.EnergizedHand:Clone()
			Util.SetParentOverrideWithColor(clone5, character.RightHand, player.Player, "ControlFruitVFXColor")
			VisualHelper:SetEnableAll(clone5, true)
			task.spawn(function()
				for _ = 1, 8 do
					local v3 = 0.125 + math.random() * 0.25
					local position2 = root.CFrame * CFrame.new(
						math.random(-22, 22),
						math.random(-22, 22),
						math.random(-22, 22)
					).Position
					local clone6 = f_Katsuo.Vault.HexTrailSpecs:Clone()
					clone6.Position = position2
					Util.SetParentOverrideWithColor(clone6, workspace.Terrain, player.Player, "ControlFruitVFXColor")
					Util.Debris:AddItem(clone6, v3 + 0.5)
					local position = character.RightHand.Position
					local magnitude = (position2 - position).Magnitude
					local cframe = CFrame.lookAt(position2, position)
					local v9 = cframe * CFrame.new(math.random(-25, 25), math.random(-25, 25), -magnitude * 0.25).Position
					local v10 = cframe * CFrame.new(math.random(-25, 25), math.random(-25, 25), -magnitude * 0.75).Position
					VisualHelper:TweenNumberValue(1, TweenInfo.new(v3, Enum.EasingStyle.Sine), function(p: number)
						clone6.Position = MathHelper:CubicBezier(p, position2, v9, v10, position)

						if p < 1 then
							return
						end

						VisualHelper:SetEnableAll(clone6, false)
					end)
					task.wait(0.01)
				end
			end)
			Util.Debris:AddItem(highlight, 0.6)
			local clone6 = domain_Katsuo.DoubleNeonEye:Clone()
			clone6.Weld.Part0 = character.Head
			Util.SetParentOverrideWithColor(clone6, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:SetEnableAll(clone6, true)
			local clone7 = c_Katsuo.FloorSpawn:Clone()
			clone7.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
			Util.SetParentOverrideWithColor(clone7, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone7.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Orientation = clone7.CircleWinds.Orientation + createVector(0, 180, 0)
			})
			VisualHelper:EmitAll(clone7)
			clone7.PointLight.Enabled = true
			VisualHelper:Tween(clone7.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Brightness = 0
			})

			for _, child in clone7.CircleWinds:GetChildren() do
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

			Util.Debris:AddItem(clone7, 2.15)
			local clone8 = c_Katsuo.NeonRotation:Clone()
			clone8:ScaleTo(1.2)
			clone8.Main.Weld.Part0 = root
			clone8.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)
			Util.SetParentOverrideWithColor(clone8, model, player.Player, "ControlFruitVFXColor")

			for i, child in clone8.Main.Layers:GetChildren() do
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

			Util.Debris:AddItem(clone8, 2)
			local clone9 = c_Katsuo.Handle:Clone()
			clone9.Weld.Part1 = root
			Util.SetParentOverrideWithColor(clone9, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(
				clone9.Beams,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = clone9.Beams.Orientation - createVector(0, 360, 0)
				}
			)
			VisualHelper:SetEnableAll(clone9, true)
			waitScheduler:wait(0.3)

			if game.Players.LocalPlayer == player.Player then
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					FieldOfView = 70
				})
			end

			local clone10 = f_Katsuo.FinalRush:Clone()
			clone10.CFrame = root.CFrame * CFrame.new(0, 0, -20)
			Util.SetParentOverrideWithColor(clone10, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone10.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
			VisualHelper:EmitAll(clone10)
			Util.Debris:AddItem(clone10, 1)
			local clone11 = f_Katsuo.SmashMeshs.AirMeshHuge4:Clone()
			clone11.CFrame = root.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(-1.5707963267948966, 0, 0)
			Util.SetParentOverrideWithColor(clone11, model, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone11.Mesh, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
				Scale = clone11.Mesh.Scale * createVector(2.5, 1.9, 2.5)
			})
			VisualHelper:Tween(clone11.Decal, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
				Transparency = 1
			})
			VisualHelper:SetEnableAll(clone5, false)
			Util.Debris:AddItem(clone5, 1)
			VisualHelper:SetEnableAll(clone9, false)
			Util.Debris:AddItem(clone9, 1.5)
			VisualHelper:SetEnableAll(clone6, false)
			Util.Debris:AddItem(clone6, 1)
			task.spawn(function()
				local waitScheduler2 = Util.WaitScheduler.new()

				for i = 1, 11 do
					local v3 = i % 2 == 0
					local v4 = (v3 and 0.35 or 0.15) + math.random() * 0.25
					local position = root.Position
					local clone12 = (v3 and c_Katsuo.Vault.HexTrailSpecs3 or f_Katsuo.Vault.HexTrailSpecs):Clone()
					clone12.Position = position
					Util.SetParentOverrideWithColor(clone12, workspace.Terrain, player.Player, "ControlFruitVFXColor")
					Util.Debris:AddItem(clone12, v4 + 0.5)
					local v5 = root.CFrame * CFrame.new(
						math.random(-35, 35),
						math.random(-35, 35),
						-math.random(45, 100)
					).Position
					local magnitude = (position - v5).Magnitude
					local cframe = CFrame.lookAt(position, v5)
					local v10 = cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.25).Position
					local v11 = cframe * CFrame.new(math.random(-90, 90), math.random(-90, 90), -magnitude * 0.75).Position
					VisualHelper:TweenNumberValue(1, TweenInfo.new(v4, Enum.EasingStyle.Sine), function(p: number)
						clone12.Position = MathHelper:CubicBezier(p, position, v10, v11, v5)

						if p < 1 then
							return
						end

						VisualHelper:SetEnableAll(clone12, false)
					end)
					waitScheduler2:wait(0.01)
				end
			end)
			EmitFloor()
			waitScheduler:wait(0.05)
			local clone12 = f_Katsuo.Shockwave:Clone()
			clone12.CFrame = player.HugeCFVictim * CFrame.new(0, 0, 12.5)
			Util.SetParentOverrideWithColor(clone12, model, player.Player, "ControlFruitVFXColor")

			if not MathHelper:GroundRayCast(character) then
				clone12.Front:Destroy()
			end

			VisualHelper:EmitAll(clone12)
			Util.Debris:AddItem(clone12, 1.5)
			SmashMeshs(root.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(1.5707963267948966, 0, 0), player.Player)
			SmashBeams(root.CFrame * CFrame.new(0, 0, -7), 2.3, player.Player)
			local clone13 = f_Katsuo.BigImpact:Clone()
			Util.SetParentOverrideWithColor(clone13, model, player.Player, "ControlFruitVFXColor")
			clone13.CFrame = root.CFrame
			VisualHelper:EmitAll(clone13)
			waitScheduler:wait(0.1)
			EmitFloor()
			waitScheduler:wait(0.3)
			Util.Debris:AddItem(clone2, 2)
			renderSteppedConnection:Disconnect()
			clone:Destroy()
			root.Anchored = false
		end
	end
end