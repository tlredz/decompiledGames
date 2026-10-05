local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
require(shared:WaitForChild("ObjectClass"))
local gameplay = FX:WaitForChild("ControlRework").Gameplay
local f_Katsuo = FX:WaitForChild("ControlRework").F_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local z_Katsuo = FX:WaitForChild("ControlRework").Z_Katsuo
local v = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	RightUpperArm = true,
	RightLowerArm = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	RightHand = true,
	LeftHand = true,
	RightFoot = true,
	LeftFoot = true
}
local random = Random.new()

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function Impulse(cframe: CFrame, player)
	local clone = gameplay.Impulse:Clone()
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 1)
	local main = clone.Main
	local circleBeam = main.CircleBeam
	VisualHelper:Tween(circleBeam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Position = circleBeam.Position - createVector(0, 3, 0)
	})

	for _, child in circleBeam.Beams:GetChildren() do
		child.Enabled = true
		VisualHelper:Tween(child, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Width0 = 0.3,
			Width1 = 0.3,
			Brightness = 0
		})
	end

	local circleBeamUp = main.CircleBeamUp
	VisualHelper:Tween(circleBeamUp, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Position = circleBeamUp.Position - createVector(0, 1.75, 0)
	})

	for _, child in circleBeamUp.Beams:GetChildren() do
		child.Enabled = true
		VisualHelper:Tween(child, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AfterImage(character, p: string, player)
	VisualHelper:ModelParts(character, function(instance)
		if not v[instance.Name] then
			return
		end

		local clone = instance:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone:ClearAllChildren()

		if clone:IsA("MeshPart") then
			clone.TextureID = ""
		end

		if p == "Fade" then
			clone.Transparency = -1
			clone.Material = Enum.Material.ForceField
			local player2 = player
			local color = Color3.fromRGB(75, 116, 255)

			if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
				color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
			end

			clone.Color = color
			VisualHelper:Tween(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			Util.Debris:AddItem(clone, 0.5)
		elseif p == "Shrinkage" then
			clone.Transparency = 1
			clone.Material = Enum.Material.Neon
			local player2 = player
			local color = Color3.fromRGB(108, 135, 255)

			if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
				color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
			end

			clone.Color = color
			VisualHelper:Tween(clone, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
				Transparency = 0
			})
			task.delay(0.125 + math.random() * 0.25, function()
				local number = random:NextNumber(0.25, 0.6)
				VisualHelper:Tween(clone, TweenInfo.new(number, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Size = createVector(0, 0, 0)
				})
				task.wait(number)
				clone:Destroy()
			end)
		end

		clone.Parent = workspace._WorldOrigin
	end)
end

local function GetTrailsDragData(p, p2: number, p3, value: string?)
	local result = {}

	for _ = 1, p2 do
		local v2 = 0.12 + math.random() * 0.12
		local v3 = math.random(10, 25)
		local v4 = p.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
		local clone = gameplay.Vault[value or "HexTrailSpecs"]:Clone()
		clone.Position = v4
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, p3, "ControlFruitVFXColor")
		Util.Debris:AddItem(clone, v2 + 0.5)
		result[clone] = {
			Point1 = v4,
			CurveOffset1 = CFrame.new(math.random(-v3, v3), math.random(-v3, v3), 0),
			CurveOffset2 = CFrame.new(math.random(-v3, v3), math.random(-v3, v3), 0)
		}
	end

	return result
end

local function DragEffects(root, p: number, player, flag: boolean?)
	local clone = gameplay.DragEffects:Clone()
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "ControlFruitVFXColor")

	if not flag then
		clone.DoubleJump:Destroy()
	end

	VisualHelper:SetEnableAll(clone, true)
	local total = 0
	local trailsDragData = GetTrailsDragData(root, 4, player)
	local postSimulationConnection = nil

	local function Update(p2)
		total += p2
		clone.CFrame = CFrame.lookAt(root.Position, root.Position + root.AssemblyLinearVelocity.Unit)
		local v3 = math.min(total / p, 1)
		local position = root.Position

		for k, v4 in trailsDragData do
			local magnitude = (v4.Point1 - position).Magnitude
			local cframe = CFrame.lookAt(v4.Point1, position)
			local v5 = cframe * CFrame.new(0, 0, -magnitude * 0.25) * v4.CurveOffset1.Position
			local v6 = cframe * CFrame.new(0, 0, -magnitude * 0.75) * v4.CurveOffset2.Position
			k.Position = MathHelper:CubicBezier(v3, v4.Point1, v5, v6, position)
		end

		if v3 < 1 then
			return
		end

		postSimulationConnection:Disconnect()

		for k in trailsDragData do
			Util.Debris:AddItem(k, 0.5)
			trailsDragData[k] = nil
		end

		clone.Trail.Instance.Enabled = false
		local clone2 = gameplay.Vault.EndStar:Clone()
		Util.SetParentOverrideWithColor(clone2, workspace.Terrain, player, "ControlFruitVFXColor")
		clone2.Position = root.Position
		VisualHelper:SetEnableAll(clone, false)
		Util.Debris:AddItem(clone, 1)
		task.wait(0.075)
		VisualHelper:EmitAll(clone2)
		Util.Debris:AddItem(clone2, 0.7)
	end

	Update(0)
	postSimulationConnection = RunService.PostSimulation:Connect(Update)
end

local function Flash(root, player)
	local clone = gameplay.Vault.Flash:Clone()
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "ControlFruitVFXColor")
	clone.Position = root.Position
	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 0.6)
end

local function EmitExplosion(cFrame, player, flag: boolean?)
	if not cFrame then
		return
	end

	local v2 = typeof(cFrame) == "RaycastResult"
	Util.CameraShaker:Shake("Fast")

	if v2 then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local clone = f_Katsuo.Explosion:Clone()
	clone:PivotTo(cFrame)
	clone:ScaleTo(clone:GetScale() * 0.55)
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "ControlFruitVFXColor")

	if not v2 then
		clone.Main.GlowShape.Crater:Destroy()
	end

	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 6)
	local v3 = clone.Main.Size.X / 2
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
	clone2.Parent = workspace._WorldOrigin
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
	clone3.Parent = workspace._WorldOrigin
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
			local v4 = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v3 + 5, v3 + 25)
			)
			local rayCast = MathHelper:RayCast(
				v4.Position,
				v4.UpVector * -10,
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
				Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone4)
				Util.Debris:AddItem(clone4, 1)
			end

			task.wait(0.125)
		end
	end)
end

return function(player)
	local WAIT_INTERVAL = 0.1

	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local player2 = player.Player or player.player
	local stage = player.Stage
	local root = player.Root

	if stage == 1 then
		Util.Sound:Play("CtrlFt_Jump_0" .. tostring(math.random(1, 2)), root)
		Impulse(root.CFrame * CFrame.new(0, -2.8, 0), player2)
		DragEffects(root, 0.3, player2, true)
	elseif stage == 2 then
		local humanoid = player.Humanoid
		local character = player.Character
		Util.Sound:Play("CtrlFt_Dash_0" .. tostring(math.random(1, 2)), root)
		local moveDirection = humanoid.MoveDirection
		local unit = moveDirection.Magnitude > 0 and moveDirection.Unit or root.CFrame.LookVector
		MathHelper:BodyVelocity(root, unit * 130, createVector(2500000, 2500000, 2500000))
		MathHelper:BodyGyro(root, 0, 0, createVector(2500000, 2500000, 2500000))
		Impulse(
			CFrame.lookAt(root.Position, root.Position + unit) * CFrame.new(0, 0, 5) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			),
			player2
		)
		DragEffects(root, 0.4, player2)
		task.wait(WAIT_INTERVAL)
		AfterImage(character, "Fade", player2) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		AfterImage(character, "Fade", player2) -- equivalent call inferred; original call site unknown
	elseif stage == 3 then
		local character = player.Character
		local raycastResult = player.RaycastResult
		local cFrame = root.CFrame
		local cframe = raycastResult and CFrame.lookAt(
			raycastResult.Position,
			raycastResult.Position + raycastResult.Normal
		)
		local endCF = player.EndCF
		AfterImage(character, "Shrinkage", player2) -- equivalent call inferred; original call site unknown
		VisualHelper:ModelTransparency(character, 1, false)
		VisualHelper:Tween(currentCamera, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
			FieldOfView = 60
		})
		EmitExplosion(cFrame * CFrame.new(0, -2.8, 0), player2)
		Flash(root, player2)
		task.wait(0.125)
		Util.Sound:Play("CtrlFt_FlashStep_Teleport_02", root)
		local total = 0
		local trailsDragData = GetTrailsDragData(root, 5, player2, "RejointTrail")
		local postSimulationConnection = nil

		local function Update(p)
			total += p
			local v4 = math.min(total / 0.6, 1)
			local position = root.Position

			for k, v5 in trailsDragData do
				local magnitude = (v5.Point1 - position).Magnitude
				local cframe2 = CFrame.lookAt(v5.Point1, position)
				local v6 = cframe2 * CFrame.new(0, 0, -magnitude * 0.25) * v5.CurveOffset1.Position
				local v7 = cframe2 * CFrame.new(0, 0, -magnitude * 0.75) * v5.CurveOffset2.Position
				k.Position = MathHelper:CubicBezier(v4, v5.Point1, v6, v7, position)
			end

			if v4 < 1 then
				return
			end

			postSimulationConnection:Disconnect()

			for k in trailsDragData do
				Util.Debris:AddItem(k, 0.5)
				trailsDragData[k] = nil
			end

			local clone = gameplay.Vault.EndStar:Clone()
			Util.SetParentOverrideWithColor(clone, workspace.Terrain, player2, "ControlFruitVFXColor")
			clone.Position = root.Position
			task.wait(0.075)
			VisualHelper:EmitAll(clone)
			Util.Debris:AddItem(clone, 0.7)
		end

		Update(0)
		postSimulationConnection = RunService.PostSimulation:Connect(Update)
		VisualHelper:Tween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			FieldOfView = 70
		})
		EmitExplosion(root.CFrame * CFrame.new(0, -2.8, 0), player2)
		Flash(root, player2)
		local v4 = endCF.Y - 3
		VisualHelper:ModelParts(character, function(part)
			if not v[part.Name] then
				return
			end

			local clone = part:Clone()
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone:ClearAllChildren()
			clone.Material = Enum.Material.Neon
			local player3 = player2
			local color = Color3.fromRGB(108, 135, 255)

			if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
				color = Util.WrapColor3Constructor(color, player3, "ControlFruitVFXColor")
			end

			clone.Color = color

			if clone:IsA("MeshPart") then
				clone.TextureID = ""
			end

			local size = clone.Size * 1.01
			clone.Size = createVector(0, 0, 0)
			clone.Transparency = 1
			clone.Parent = workspace._WorldOrigin
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = part
			weld.Parent = clone
			task.delay((clone.Position.Y - v4) * 0.1, function()
				clone.Transparency = 0
				VisualHelper:Tween(clone, TweenInfo.new(0.075, Enum.EasingStyle.Back), {
					Size = size * createVector(1.75, 0.3, 1.75)
				})
				task.wait(0.075)
				VisualHelper:Tween(clone, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
					Size = size
				})
				task.wait(0.15)
				VisualHelper:Tween(clone, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Size = size * createVector(1, 1, 1) * 1.35
				})
				task.wait(0.1)
				VisualHelper:Tween(clone, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
					Size = size
				})
				task.wait(0.125)
				VisualHelper:Tween(clone, TweenInfo.new(1, Enum.EasingStyle.Back), {
					Transparency = 1
				})
				task.wait(1)
				clone:Destroy()
			end)
		end)
		task.delay(0.75, function()
			VisualHelper:ModelTransparency(character, 0, false)
		end)

		if cframe then
			local clone = gameplay.Indicator:Clone()
			clone.Main.Main.Icon.Rotation = NumberRange.new(math.random(1, 4) * 90)
			clone:PivotTo(cframe * CFrame.new(0, 0, -0.1) * CFrame.Angles(-1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "ControlFruitVFXColor")
			clone.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)
			VisualHelper:EmitAll(clone)
			task.delay(0.4, function()
				VisualHelper:EmitAll(clone)

				for i, child in clone.Main.Layers:GetChildren() do
					child.Orientation *= 1.5
					local beam = child.Beam
					beam.Width0 *= 2
					beam.Width1 *= 2
					beam.Enabled = true
					local number = random:NextNumber(0.2, 0.3)
					VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
						Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
					})
					VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
						Width0 = 0,
						Width1 = 0
					})
				end

				task.wait(0.35)
				VisualHelper:EmitAll(clone)
				task.wait(0.15)
				VisualHelper:EmitAll(clone)
				Util.Debris:AddItem(clone, 2.5)
				local clone2 = z_Katsuo.Pilar:Clone()
				clone2.Size = createVector(24.5, 0, 24.5)
				clone2.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
				Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "ControlFruitVFXColor")
				local localPlayer = game.Players.LocalPlayer
				local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and character == localPlayer.Character then
					local v5 = 1e999
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(_)
						if clone2 and clone2.Parent then
							local pointToObjectSpace = clone2.CFrame:PointToObjectSpace(humanoidRootPart.Position)
							local v6 = createVector(2, 2, 2) + clone2.Size * 0.5 + createVector(0, 5, 0)
							local v7

							if math.abs(pointToObjectSpace.X) <= v6.X and math.abs(pointToObjectSpace.Y) <= v6.Y then
								v7 = math.abs(pointToObjectSpace.Z) <= v6.Z
							else
								v7 = false
							end

							if v7 then
								if tick() - v5 < 0.1 then
									v5 = 0
									Util.BodyMover.new(localPlayer.Character):Create("BodyVelocity", {
										Priority = -1,
										Duration = 0.1,
										Velocity = createVector(0, 300, 0)
									})
								end
							else
								clone2.CanCollide = true

								if heartbeatConnection then
									heartbeatConnection:Disconnect()
								end
							end
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
						end
					end)
				end

				Util.Sound:Play("CtrlFt_FlashStep_Pillar_01", clone2.CFrame)
				clone2.Floor.CFrame = clone2.CFrame * CFrame.new(0, 0.05, 0)
				VisualHelper:Tween(
					clone2.Floor,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
					{
						Size = clone2.Floor.Size * 1.04
					}
				)

				for _, child in clone2.Shader:GetChildren() do
					if child.Name ~= "PreShader" then
						continue
					end

					local uIGradient = child.Glow.UIGradient
					uIGradient.Offset = Vector2.new(0, 0.5)
					VisualHelper:Tween(uIGradient, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
						Offset = Vector2.new(0, -0.8)
					})
				end

				local outline = clone2.Outline

				-- equivalent calls inferred from this helper; original call sites unknown
				local function Update2()
					outline.Mesh.Scale = clone2.Size / createVector(50, 50, 50) + createVector(0.015, 0.015, 0.015)
					outline.CFrame = clone2.CFrame
				end

				Update2() -- equivalent call inferred; original call site unknown
				local sizeChangedConnection = clone2:GetPropertyChangedSignal("Size"):Connect(Update2)
				local cFrameChangedConnection = clone2:GetPropertyChangedSignal("CFrame"):Connect(Update2)

				local function EmitExplosion2(flag: boolean)
					Util.CameraShaker:Shake("Fast Hard")
					local clone3 = z_Katsuo.Explosion:Clone()
					clone3:PivotTo(clone2.CFrame * CFrame.new(0, 0.2, 0))
					Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "ControlFruitVFXColor")
					VisualHelper:EmitAll(clone3)
					Util.Debris:AddItem(clone3, 2.65)
					local superFlash = clone3.SuperFlash
					local circleWave = clone3.CircleWave
					local size = circleWave.Size
					circleWave.Size = size * 0.7
					VisualHelper:Tween(circleWave, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
						CFrame = circleWave.CFrame * CFrame.new(0, -clone2.Size.Y / 3.8, 0),
						Transparency = 1,
						Size = size
					})
					local scale = superFlash.Mesh.Scale * 2.6
					superFlash.Mesh.Scale /= 2
					VisualHelper:Tween(superFlash, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						CFrame = superFlash.CFrame * CFrame.new(0, -7, 0)
					})
					VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
						Scale = scale
					})
					Util.Debris:AddItem(superFlash, 1)
					local beams = clone3.Main.Beams

					if flag then
						VisualHelper:Tween(beams, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Orientation = beams.Orientation + createVector(0, 450, 0)
						})

						for _, beam in beams:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							VisualHelper:Tween(
								beam,
								TweenInfo.new(0.075 + math.random(3) * 0.025, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						Util.Debris:AddItem(beams, 0.5)
					else
						beams:Destroy()
					end

					local circleBeam = clone3.Main.CircleBeam
					circleBeam.Orientation = Vector3.new(0, math.random(360))

					for _, v6 in { circleBeam.Beam1, circleBeam.Beam2 } do
						v6.Enabled = true
						VisualHelper:Tween(v6, TweenInfo.new(0.16, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					Util.Debris:AddItem(circleBeam, 0.16)

					if not flag then
						return
					end

					local v6 = clone3.Main.Size.X / 1.9
					local position = raycastResult.Position
					local v8 = v6 * 0.7
					local v9 = { workspace.Terrain }
					Rocks:CircleRocks(position, 12, v8, createVector(8, 1.5, 2.5), 0.5, v9)
					local position2 = raycastResult.Position
					local v11 = v6 * 0.9
					local v12 = { workspace.Terrain }
					Rocks:CircleRocks(position2, 4, v11, createVector(5, 2.25, 2.5), 0.2, v12)
				end

				for _ = 1, 3 do
					Rocks:AirRocks(
						clone2.CFrame,
						Vector3.new(random:NextNumber(1.5, 3), 1, random:NextNumber(1.5, 3)) * 3.5,
						false,
						math.random(90, 180),
						0.2,
						2.5,
						5,
						clone2.Color,
						clone2.Material
					)
				end

				EmitExplosion2(true)
				local v5 = (root.Position - cframe.Position).Magnitude < clone2.Size.X / 1.5
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back)
				VisualHelper:Tween(clone2, tweenInfo, {
					Size = clone2.Size + createVector(0, 75, 0),
					CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
				})
				task.wait(tweenInfo.Time)

				if v5 then
					VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
						FieldOfView = 70
					})
				end

				task.wait(1.35 + math.random() * 0.75)

				for _, child in clone2.Shader:GetChildren() do
					if child.Name ~= "PreShader" then
						continue
					end

					local uIGradient = child.Glow.UIGradient
					uIGradient.Rotation *= -1
					uIGradient.Offset = Vector2.new(0, -0.5)
					VisualHelper:Tween(
						uIGradient,
						TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Offset = Vector2.new(0, 0.8)
						}
					)
				end

				clone:Destroy()
				task.wait(0.45)
				VisualHelper:Tween(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Size = clone2.Size * createVector(1, 0, 1),
					CFrame = clone2.CFrame * CFrame.new(0, -37.5, 0)
				})
				task.wait(0.1)

				for _ = 1, 2 do
					Rocks:AirRocks(
						clone2.CFrame,
						Vector3.new(random:NextNumber(1.5, 3), 1, random:NextNumber(1.5, 3)) * 4.6,
						false,
						math.random(90, 180),
						0.2,
						2.5,
						5,
						clone2.Color,
						clone2.Material
					)
				end

				EmitExplosion2()
				sizeChangedConnection:Disconnect()
				cFrameChangedConnection:Disconnect()
				clone2:Destroy()
			end)
		else
			task.wait(WAIT_INTERVAL)
		end
	end
end