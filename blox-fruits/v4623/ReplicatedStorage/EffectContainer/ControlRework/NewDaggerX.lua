local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xDagger = FX:WaitForChild("ControlRework").XDagger
local xOutside = FX:WaitForChild("ControlRework").XOutside
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Textures)
local Rocks = require(shared.Rocks)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
require(ReplicatedStorage.Effect)
require(ReplicatedStorage.CharacterTransparency)
require(shared.HexsStormClass)
local ObjectExplosion = require(script.Parent:WaitForChild("ObjectExplosion"))
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RandomAngleFunc(p: number)
	return CFrame.Angles(
		math.random() * 3.141592653589793 / p,
		math.random() * 3.141592653589793 / p,
		math.random() * 3.141592653589793 / p
	)
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

local function DarkSlash(cFrame: CFrame, rotation: number?, flag: boolean?, value: number?, player)
	local clone = xDagger.Phase0.DarkSlash:Clone()
	clone:ScaleTo(value or 1.65)
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
	Debris(slash, 2)
	local staticSlash = slash.StaticSlash
	staticSlash.Beam.Enabled = true
	task.delay(0.025, function()
		staticSlash:Destroy()
	end)
	return slash
end

local function EmitLiteExplosion(cframe: CFrame, flag: boolean?, p, player)
	if not cframe then
		return
	end

	local clone = xDagger.Phase0.LiteExplosion:Clone()
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, p, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	Debris(clone, 6)

	if flag then
		return
	end

	local v = clone.Main.Size.X / 2
	task.spawn(function()
		for _ = 1, 3 do
			local v2 = cframe * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v + 5, v + 25)
			)
			local rayCast = MathHelper:RayCast(
				v2.Position,
				v2.UpVector * -10,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
				Enum.RaycastFilterType.Exclude
			)

			if rayCast then
				local clone2 = xDagger.Phase0.BoltExplosion:Clone()
				clone2.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				Util.SetParentOverrideWithColor(clone2, p, player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone2)
				Debris(clone2, 1)
			end

			task.wait(0.125)
		end
	end)
end

local function EmitLiteFloor(_: CFrame, _, _) end

local function RushLink(vector2: Vector3, vector3: Vector3, p, player)
	local magnitude = (vector2 - vector3).Magnitude
	local clone = xDagger.Phase0.RushLine:Clone()
	clone.CFrame = CFrame.lookAt(vector2, vector3) * CFrame.new(0, 0, -(magnitude / 2))
	clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, magnitude)
	Util.SetParentOverrideWithColor(clone, p, player, "ControlFruitVFXColor")
	local beams = clone.Beams

	for i, child in beams.Beams:GetChildren() do
		child.Enabled = true

		if child.Name == "Air" then
			VisualHelper:Tween(child, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		else
			local v = child.Name == "Fade"
			VisualHelper:Tween(
				child,
				TweenInfo.new(
					v and 0.3 or 0.15 + i * 0.01,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out,
					0,
					false,
					v and 0 or 0.075
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
		Position = Vector3.new(0, 1, -magnitude)
	})
	VisualHelper:EmitAll(clone)
	Debris(clone, 1.5)
	return clone
end

local function EmitExplosion(cFrame, flag: boolean?, player)
	if not cFrame then
		return
	end

	local v = typeof(cFrame) == "RaycastResult"
	local model = Instance.new("Model")
	model.Parent = workspace._WorldOrigin
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
			local rayCast = MathHelper:RayCast(
				v3.Position,
				v3.UpVector * -10,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
				Enum.RaycastFilterType.Exclude
			)

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

function Debris(p, p2: number)
	Util.Debris:AddItem(p, p2)
end

local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
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
		return
	end

	if stage == 2 then
		local random2 = Random.new()
		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Debris:AddItem(model, 10)
		local startCFrame = player.StartCFrame
		local root = player.Root
		local player2 = player.Player
		local character = player.Character
		local unit = startCFrame.LookVector.Unit
		local unit2 = unit:Cross(math.abs(unit.Y) > 0.95 and createVector(0, 0, 1) or createVector(0, 1, 0)).Unit
		local maid = Util.Maid.new()
		VisualHelper:Tween(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Sine), {
			FieldOfView = 76
		})
		local clone = xDagger.Phase0.ShaderScreen:Clone()
		clone.Image.ImageTransparency = 1
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local v2

		if player.Player == game.Players.LocalPlayer then
			v2 = player.Player:FindFirstChild("PlayerGui") or model
		else
			v2 = model
		end

		setParentOverrideWithColor(clone, v2, player2, "ControlFruitVFXColor")
		VisualHelper:Tween(clone.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.86
		})
		local clone2 = xDagger.Phase0.CameraEffects:Clone()
		Util.SetParentOverrideWithColor(clone2, currentCamera, player2, "ControlFruitVFXColor")

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(clone2, true)
			VisualHelper:EmitAll(clone2)
		end

		maid:GiveTask(clone2)
		maid:GiveTask(clone)
		local attachment = Instance.new("Attachment", workspace.Terrain)
		attachment.WorldCFrame = startCFrame
		maid:GiveTask(attachment)
		root.Anchored = true
		attachment.Destroying:Once(function()
			root.CFrame = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector * createVector(1, 0, 1)) + root.Position
			root.Anchored = false
			local humanoid = root.Parent:FindFirstChild("Humanoid")

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
		maid:GiveTask(attachment:GetPropertyChangedSignal("CFrame"):Connect(function()
			root.CFrame = attachment.WorldCFrame
		end))
		maid:GiveTask(model)
		local endPoint = player.EndPoint
		local maxDistance = player.MaxDistance
		local v3 = math.floor(maxDistance / 33)
		local v4 = math.clamp(math.round((endPoint - startCFrame.Position).Magnitude / maxDistance * v3), 1, v3)
		local v5 = {}
		local v6 = 1
		local v7 = nil

		for i = 1, v4 do
			local v8 = i / v4
			local lerped = startCFrame.Position:Lerp(endPoint, v8)
			local v9

			if i == v4 then
				v9 = createVector(0, 0, 0)
			else
				v9 = unit2 * (v6 * 30 + random2:NextNumber(-4.5, 4.5))
				v6 *= -1
			end

			v5[i] = lerped + v9
		end

		local v8 = 1
		local count = 0
		local total = 0
		local heartbeatConnection = nil
		local v9 = ObjectClass.TemplateModel.Main.Size / 6
		local position = startCFrame.Position
		local v10 = true
		local flag = false
		local highlight = Instance.new("Highlight")
		highlight.Adornee = character
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		local color = Color3.fromRGB(30, 56, 100)

		if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
			color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
		end

		highlight.FillColor = color
		highlight.Parent = model
		local cRDaggerXLoopFly = nil
		local v11 = 1
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.06 then
				return
			end

			total = 0

			if count >= #v5 then
				heartbeatConnection:Disconnect()
				flag = true
			else
				if v8 > #v5 then
					return
				end

				local v12 = v5[v8]
				local v13 = v5[v8 + 1] or v12 + unit
				local ray = Util.Ray
				local v14 = v12 + createVector(0, 1, 0)
				local v15 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				local v16, position4, v18 = ray(v14, createVector(-0, -600, -0), v15)
				local v19 = {
					Instance = v16 or nil,
					Normal = v18 or createVector(0, 1, 0),
					Position = position4
				}

				if not v16 then
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Black")
					part.Material = Enum.Material.Slate
					part.Transparency = 1
					part.CanCollide = false
					part.Anchored = true
					part.Parent = model
					v19.Instance = part
				end

				local cframe = CFrame.lookAt(position4, position4 + v18)
				local v20 = ObjectClass.new(player2, cframe)
				v20:RemoveDragable()
				local main = v20.Model.Main
				main.CanCollide = false
				main.Color = v19.Instance.Color
				main.Material = v19.Instance.Material
				main.CanQuery = false
				main.Outline:Destroy()
				v20:SetLayout((`{1}x{1}`))
				v20:ScaleTo(1)
				local _ = position4.Y
				local _ = v13.Y
				local v21 = math.random(5, 10)
				local size = v9 * 1
				local _ = cframe * CFrame.new(0, 0, -(size.Y / 2 + v21)).Position
				local v23 = v12 + v18 * (size.Y / 2 + v21)
				local cframe2 = CFrame.Angles(math.rad((math.random(-10, 10))), 0, math.random() * 3.141592653589793)
				local cframe3 = CFrame.lookAt(v23, position)
				v20:PivotTo(cframe)
				v20:SetSize(createVector(0, 0, 0))
				local v24 = position
				task.delay(0.125, function()
					v20:SwitchMode("Planing")
					v20:ToggleBodyPattern(true)

					if not cRDaggerXLoopFly then
						cRDaggerXLoopFly = Util.Anims:Get(character, "CRDaggerXLoopFly")
						cRDaggerXLoopFly.Looped = true
						cRDaggerXLoopFly.Priority = Enum.AnimationPriority.Action2
						cRDaggerXLoopFly:Play()
					end

					Util.Sound:Play("X_CubeDash_Dash_0" .. tostring(v11), root)
					v11 += 1

					if v11 > 4 then
						v11 = 1
					end

					RushLink(v24, v23, model, player2)
					EmitLiteExplosion(root.CFrame * CFrame.new(0, -2.8, 0), v10, model, player2)
					v10 = false
					VisualHelper:Tween(
						main,
						TweenInfo.new(0.082, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
						{
							Size = size * 1.2
						}
					)
					local worldCFrame = cframe3 * CFrame.new(0, 0, -size.Y / 2 - 3) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					local raycastResult = v10 and workspace:Raycast(
						root.Position,
						worldCFrame.Position - root.Position,
						raycastParams
					) or workspace:Raycast(position, worldCFrame.Position - position, raycastParams)

					if raycastResult then
						worldCFrame = worldCFrame - worldCFrame.Position + raycastResult.Position
					end

					VisualHelper:Tween(attachment, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						WorldCFrame = worldCFrame
					})
					count += 1
					task.wait(0.035)
					local _ = worldCFrame * CFrame.new(0, -2.8, 0)
					highlight.FillTransparency = 0.75
					VisualHelper:Tween(highlight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						FillTransparency = 1
					})
					task.wait(0.5)
					ObjectExplosion({
						Object = v20.Model.Main,
						Energized = false,
						Scale = 2.15 * v20:GetLayoutSize(),
						IsSliceModel = v20:IsSliceModel()
					})
					v20:Destroy()
				end)
				local _ = cframe * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0)
				VisualHelper:Tween(main, TweenInfo.new(0.145, Enum.EasingStyle.Sine), {
					Size = size,
					CFrame = cframe3 * cframe2
				})
				local cFrame = CFrame.lookAt(position4, position4 + v18) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
					0,
					0.5,
					0
				)
				local clone3 = xDagger.Phase0.PushExplosionFast:Clone()
				clone3:PivotTo(cFrame)
				Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone3)
				Util.Debris:AddItem(clone3, 3)
				local clone4 = xDagger.Phase0.BallNeon:Clone()
				clone4.CFrame = cFrame
				clone4.Transparency = 0.95
				local player3 = player2
				local color2 = Color3.fromRGB(89, 133, 255)

				if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
					color2 = Util.WrapColor3Constructor(color2, player3, "ControlFruitVFXColor")
				end

				clone4.Color = color2
				clone4.Size = createVector(1, 1, 1) * (clone3.Main.Size.Y * 0.65)
				clone4.Parent = model
				VisualHelper:Tween(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Size = clone4.Size * 4,
					Transparency = 1
				})
				Debris(clone4, 0.2)
				local beams = clone3.Main.Beams
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
				local v26 = clone3.Main.Size.X / 2
				local position2 = cFrame.Position
				local v28 = v26 * 0.7
				local v29 = { workspace.Terrain }
				Rocks:CircleRocks(position2, 13, v28, createVector(6.2, 1.2, 2), 0, v29)
				local position3 = cFrame.Position
				local v31 = v26 * 1.05
				local v32 = { workspace.Terrain }
				Rocks:CircleRocks(position3, 5, v31, createVector(5, 1.8, 3.2), 0, v32)

				for _ = 1, 3 do
					Rocks:AirRocks(
						cFrame,
						Vector3.new(random:NextNumber(6.5, 9), 2, random:NextNumber(6.5, 9)),
						false,
						math.random(90, 130),
						1,
						1,
						3,
						v19.Instance.Color,
						v19.Instance.Material
					)
				end

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
				Debris(airMeshHuge, 0.3)
				VisualHelper:Tween(airHard, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
					CFrame = airHard.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				})
				VisualHelper:Tween(airHard.Decal, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				VisualHelper:Tween(airHard.Mesh, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
					Scale = airHard.Mesh.Scale * 2
				})
				Debris(airHard, 0.5)
				VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Scale = flash.Mesh.Scale * 2.5
				})
				Debris(flash, 0.4)
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
				Debris(superFlash, 0.7)
				position = v23
				v7 = v20
				v8 += 1
			end
		end)

		repeat
			task.wait()
		until flag

		task.wait(0.1)
		local enemyChar = player.EnemyChar
		local humanoidRootPart = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")

		if enemyChar and humanoidRootPart then
			local upCFrame = player.UpCFrame
			local pushCFrame = player.PushCFrame
			local enemyCFrame = player.EnemyCFrame
			local ray = Util.Ray
			local position2 = upCFrame.Position
			local v12 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			local v13, position5, v15 = ray(position2, createVector(-0, -600, -0), v12)
			local v16 = {
				Instance = v13 or nil,
				Normal = v15 or createVector(0, 1, 0),
				Position = position5
			}

			if not v13 then
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Black")
				part.Material = Enum.Material.Slate
				part.Transparency = 1
				part.CanCollide = false
				part.Anchored = true
				part.Parent = model
				v16.Instance = part
			end

			local _ = v16.Position.Y < -2
			local cframe = CFrame.lookAt(position5, position5 + v15)
			local v17 = ObjectClass.new(player2, cframe)
			v17:RemoveDragable()
			local main = v17.Model.Main
			main.CanCollide = false
			main.Color = v16.Instance.Color
			main.Material = v16.Instance.Material
			main.CanQuery = false
			main.Outline:Destroy()
			v17:SetLayout((`{1}x{1}`))
			v17:ScaleTo(1)
			local size2 = v9 * 2
			local cframe2 = CFrame.Angles(math.rad((math.random(-10, 10))), 0, math.random() * 3.141592653589793)
			v17:PivotTo(cframe)
			v17:SetSize(createVector(0, 0, 0))
			VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				CFrame = enemyCFrame
			})
			task.delay(0.1, function()
				local WAIT_INTERVAL = 0.1
				v17:SwitchMode("Planing")
				v17:ToggleBodyPattern(true)
				RushLink(root.Position, upCFrame.Position, model, player2)
				EmitLiteExplosion(root.CFrame * CFrame.new(0, -2.8, 0), v10, model, player2)
				v10 = false
				VisualHelper:Tween(
					main,
					TweenInfo.new(0.082, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
					{
						Size = size2 * 1.2
					}
				)
				local worldCFrame = upCFrame * CFrame.new(0, 0, -size2.Y / 2 - 3) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				local raycastResult = v10 and workspace:Raycast(
					root.Position,
					worldCFrame.Position - root.Position,
					raycastParams
				) or workspace:Raycast(position, worldCFrame.Position - position, raycastParams)

				if raycastResult then
					worldCFrame = worldCFrame - worldCFrame.Position + raycastResult.Position
				end

				Util.Sound:Play("X_CubeDash_Dash_0" .. tostring(v11), root)
				VisualHelper:Tween(attachment, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					WorldCFrame = worldCFrame
				})
				task.spawn(function()
					task.wait(0.1)

					if cRDaggerXLoopFly then
						cRDaggerXLoopFly:Stop()
						cRDaggerXLoopFly = nil
					end

					cRDaggerXLoopFly = Util.Anims:Get(character, "CRDaggerXLoopRock")
					cRDaggerXLoopFly.Looped = true
					cRDaggerXLoopFly.Priority = Enum.AnimationPriority.Action2
					cRDaggerXLoopFly:Play()
				end)
				task.wait(0.2)
				Util.Sound:Play("X_CubeDash_BungieOffFloatingRock_01", root)
				local cframe3 = pushCFrame
				RushLink(root.Position, cframe3.Position, nil, player2)

				if cRDaggerXLoopFly then
					cRDaggerXLoopFly:Stop()
				end

				local cRDaggerXRockJump = Util.Anims:Get(character, "CRDaggerXRockJump")
				cRDaggerXRockJump.Looped = false
				cRDaggerXRockJump.Priority = Enum.AnimationPriority.Action3
				cRDaggerXRockJump:Play()
				VisualHelper:Tween(attachment, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					WorldCFrame = cframe3
				})
				local clone3 = xOutside.Phase1.EndImpact:Clone()
				Util.ResizeModel(clone3, 2.25)
				clone3.CFrame = CFrame.lookAt(upCFrame.Position, cframe3.Position) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")
				task.spawn(function()
					ObjectExplosion({
						Object = v17.Model.Main,
						Energized = false,
						Scale = 2.15 * v17:GetLayoutSize(),
						IsSliceModel = v17:IsSliceModel()
					})
					v17:Destroy()
				end)
				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v20 = emitter
					task.spawn(function()
						if v20:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v20:GetAttribute("EmitDelay"))
						end

						v20:Emit(v20:GetAttribute("EmitCount"))
					end)
				end

				task.wait(WAIT_INTERVAL)

				if attachment then
					attachment:Destroy()
				end

				VisualHelper:Tween(humanoidRootPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					CFrame = player.EnemyCFrame2
				})
				task.spawn(function()
					local clone4 = xDagger.Phase0.Impact:Clone()
					clone4:PivotTo(cframe3)
					Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player2, "ControlFruitVFXColor")
					Debris(clone4, 1.5)
					local beams = clone4.Main.Beams
					VisualHelper:Tween(
						beams,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
						{
							Orientation = beams.Orientation + createVector(0, 360, 0)
						}
					)

					for _, beam in beams:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						local width0 = beam:GetAttribute("Width0") or beam.Width0
						local width1 = beam:GetAttribute("Width1") or beam.Width0
						beam:SetAttribute("Width0", width0)
						beam:SetAttribute("Width1", width1)
						beam.Width0 = width0
						beam.Width1 = width1
						beam.Enabled = true
						VisualHelper:Tween(beam, TweenInfo.new(0.1 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					VisualHelper:EmitAll(clone4)
					local meshs = clone4.Main.Meshs
					local airMeshHuge = meshs.AirMeshHuge
					local airMeshStorm = meshs.AirMeshStorm
					local superFlash = meshs.SuperFlash
					local flash = meshs.Flash
					VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Scale = airMeshHuge.Mesh.Scale * createVector(4, 1, 4)
					})
					VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					Debris(airMeshHuge, 1)
					VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
						Scale = airMeshStorm.Mesh.Scale * createVector(3, 1, 3)
					})
					VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
						CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					})
					Debris(airMeshStorm, 1)
					VisualHelper:Tween(flash.Decal, TweenInfo.new(0.26, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.26, Enum.EasingStyle.Sine), {
						Scale = flash.Mesh.Scale * createVector(3.5, 1, 3.5)
					})
					Debris(flash, 1)
					local scale = superFlash.Mesh.Scale * 2.25
					superFlash.Mesh.Scale /= 2
					VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Scale = scale
					})
					Debris(superFlash, 1)
				end)
				local cRDaggerXHit = Util.Anims:Get(character, "CRDaggerXHit")
				cRDaggerXHit.Looped = false
				cRDaggerXHit.Priority = Enum.AnimationPriority.Action4
				cRDaggerXHit:Play()

				if clone then
					VisualHelper:Tween(clone.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					})
					Debris(clone, 0.5)
				end

				local _, v20 = cframe3:ToEulerAnglesYXZ()
				local v22 = cframe3.Position + createVector(0, 0.1, 0)
				local v23 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				local rayCast = MathHelper:RayCast(v22, createVector(-0, -200, -0), v23, Enum.RaycastFilterType.Exclude)
				local v24 = not rayCast and MathHelper:RayCast(
					position,
					cframe3.LookVector * 1,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
					Enum.RaycastFilterType.Exclude
				)
				local v25

				if rayCast then
					v25 = CFrame.new(rayCast.Position + createVector(0, 3, 0)) * CFrame.Angles(0, v20, 0)
				elseif v24 then
					v25 = CFrame.lookAt(v24.Position, v24.Position + v24.Normal) * CFrame.new(0, 0, -3) * CFrame.Angles(
						-1.5707963267948966,
						v20 + 3.141592653589793,
						0
					)
				else
					v25 = cframe3 * CFrame.new(0, 0, -1)
				end

				Util.Sound:Play("X_CubeDash_SlashFinisher_02", v25)
				EmitLiteExplosion(cframe3 * CFrame.new(0, -2.8, 0), nil, nil, player2)
				highlight.FillTransparency = 0.4
				VisualHelper:Tween(highlight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					FillTransparency = 1
				})
				Debris(highlight, 0.6)
				local clone4 = xDagger.Phase0.Indicator:Clone()
				clone4.CFrame = cframe3
				Util.SetParentOverrideWithColor(clone4, workspace.Terrain, player2, "ControlFruitVFXColor")
				local beam = clone4.Beam
				local brightness = beam.Brightness
				beam.Brightness = 0
				VisualHelper:Tween(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Brightness = brightness
				})
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					FieldOfView = 60
				})
				task.wait(WAIT_INTERVAL)
				local clone5 = xDagger.Phase0.DoubleNeonEye:Clone()
				clone5.Anchored = false
				clone5.Weld.Part0 = character.Head
				Util.SetParentOverrideWithColor(clone5, workspace.Terrain, player2, "ControlFruitVFXColor")
				VisualHelper:SetEnableAll(clone5, true)
				local clone6 = xDagger.Phase0.Handle:Clone()
				clone6.Anchored = false
				clone6.Weld.Part1 = root
				Util.SetParentOverrideWithColor(clone6, workspace.Terrain, player2, "ControlFruitVFXColor")
				VisualHelper:Tween(
					clone6.Beams,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
					{
						Orientation = clone6.Beams.Orientation - createVector(0, 360, 0)
					}
				)
				VisualHelper:SetEnableAll(clone6, true)
				local startTime = player.StartTime or workspace:GetServerTimeNow()
				local v26 = workspace:GetServerTimeNow() - startTime
				RunService.RenderStepped:Connect(function(dt)
					v26 += dt

					if clone2 then
						clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
					end
				end)
				local v27 = {
					{
						Angle = 0,
						Rotation = 0,
						Scale = 5
					},
					{
						Angle = 90,
						Rotation = 95,
						Scale = 4
					},
					{
						Angle = 45,
						Rotation = 100,
						Scale = 4
					},
					{
						Angle = -45,
						Rotation = -100,
						Scale = 4
					},
					{
						Angle = 0,
						Rotation = 0,
						Scale = 5
					}
				}
				task.spawn(function()
					for k, v28 in v27 do
						DarkSlash(
							v25 * CFrame.new(0, 0, -35) * CFrame.Angles(0, 3.141592653589793, (math.rad(v28.Angle))),
							v28.Rotation,
							true,
							12 + v28.Scale * 0.1,
							player2
						)

						if k % 3 == 0 then
							local _ = cframe3 * CFrame.new(0, -2.8, 0)
						end

						task.wait(0.018)
					end
				end)
				local clone7 = xDagger.Phase0.GroundSlice:Clone()
				clone7:PivotTo(cframe3 * CFrame.new(0, -2, -clone7.Main.Size.Z / 2 - 2.5))
				Util.SetParentOverrideWithColor(clone7, workspace.Terrain, player2, "ControlFruitVFXColor")
				VisualHelper:SetEnableAll(clone7.Main, true, true)
				task.spawn(function()
					for _ = 1, 3 do
						VisualHelper:EmitAll(clone7.FloorImpactFast)
						task.wait(0.16)
					end

					VisualHelper:Tween(currentCamera, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
						FieldOfView = 55
					})
				end)
				local children = clone7.Slices:GetChildren()

				for k, v28 in children do
					local size = v28.Size
					v28.Size = createVector(0, 0, 0)
					local v29 = v28
					local v30 = k
					task.delay(k * 0.02, function()
						VisualHelper:EmitAll(v29)
						local v32 = v30 % 2 == 0 and -1 or 1
						local position6 = createVector(0, 0, 1) * size.Z / 2 * v32
						local clone8 = xDagger.Phase0.Vault.SliceGroundBeam:Clone()
						Util.SetParentOverrideWithColor(clone8, v29, player2, "ControlFruitVFXColor")
						local left = clone8.Left
						local right = clone8.Right
						left.Position = position6 * -1
						right.Position = createVector(0, 0, 0)
						local number = random:NextNumber(0.5, 2)
						local beam2 = clone8.Beam
						beam2.Width0 *= number
						beam2.Width1 *= number
						beam2.Enabled = true
						VisualHelper:Tween(clone8.Right, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							Position = position6
						})
						VisualHelper:Tween(beam2, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
							Width0 = 0,
							Width1 = 0
						})
						task.wait(0.05)
						VisualHelper:Tween(v29, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Size = size
						})
						task.wait(0.045)
						VisualHelper:EmitAll(v29)
						task.wait(0.025)
						VisualHelper:SetEnableAll(v29, true, true)
					end)
				end

				task.wait(#children * 0.02 + 0.125)
				local clone8 = xDagger.Phase0.StormBeamPattern:Clone()
				clone8:PivotTo(clone7:GetPivot())
				clone8:ScaleTo(4)
				Util.SetParentOverrideWithColor(clone8, workspace.Terrain, player2, "ControlFruitVFXColor")

				for _, attachment2 in clone8.Main:GetChildren() do
					if not attachment2:IsA("Attachment") then
						continue
					end

					attachment2.Orientation *= 1.15
					local beam2 = attachment2.Beam
					beam2.Brightness *= 1.75
					beam2.Enabled = true
					VisualHelper:Tween(attachment2, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
						Orientation = attachment2.Orientation + createVector(0, 515, 0)
					})
					VisualHelper:Tween(beam2, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
						Brightness = 0,
						Width0 = beam2.Width0 * 0.2,
						Width1 = beam2.Width1 * 0.2
					})
				end

				VisualHelper:TweenScale(clone8, TweenInfo.new(0.7, Enum.EasingStyle.Sine), clone8:GetScale() + 0.5)
				Debris(clone8, 0.7)
				VisualHelper:Tween(beam, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
				Debris(clone4, 0.4)
				local clone9 = xDagger.Phase0.NeonRotation:Clone()
				clone9:ScaleTo(1.2)
				clone9.Main.Anchored = false
				clone9.Main.Weld.Part0 = root
				Util.SetParentOverrideWithColor(clone9, workspace.Terrain, player2, "ControlFruitVFXColor")
				clone9.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

				for i, child in clone9.Main.Layers:GetChildren() do
					child.Orientation *= 1.5
					child.Position *= 1.5
					local beam2 = child.Beam
					local width = beam2.Width0 / 2
					local width2 = beam2.Width1 / 2
					beam2.Width0 = width
					beam2.Width1 = width2
					beam2.Enabled = true
					local number = random:NextNumber(0.12, 0.22)
					VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
						Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
					})
					VisualHelper:Tween(beam2, TweenInfo.new(number, Enum.EasingStyle.Sine), {
						Width0 = 0,
						Width1 = 0
					})
				end

				Debris(clone9, 2)
				local _ = cframe3 * CFrame.new(0, -2.8, 0)
				task.wait(0.125)

				for _, v28 in children do
					VisualHelper:SetEnableAll(v28, false, true)
				end

				task.spawn(function()
					local clone10 = xDagger.Phase1.GroundAura:Clone()
					clone10.CFrame = cframe3 * CFrame.new(0, -2, -clone7.Main.Size.Z / 2 - 2.5)
					Util.SetParentOverrideWithColor(clone10, model, player2, "ControlFruitVFXColor")

					for _, emitter in pairs(clone10:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v28 = emitter
						task.spawn(function()
							v28.Enabled = true
							task.wait(0.35)
							v28.Enabled = false
						end)
					end

					clone10.Aura2.Size = createVector(5, 1, 5)
					TweenService:Create(
						clone10.Aura2,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(350, 1, 350)
						}
					):Play()
				end)
				task.wait(WAIT_INTERVAL)
				VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					FieldOfView = 70
				})
				VisualHelper:EmitAll(clone7.FloorImpactEnd)
				task.wait(0.065)

				if rayCast or v24 then
					local clone10 = xDagger.Phase0.GroundSliceExplosion:Clone()
					clone10:PivotTo(clone7:GetPivot())
					Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player2, "ControlFruitVFXColor")
					VisualHelper:EmitAll(clone10)
					Debris(clone10, 2.5)
					local airMeshHuge = clone10.AirMeshHuge
					local airMeshStorm = clone10.AirMeshStorm
					local superFlash = clone10.SuperFlash
					local flash = clone10.Flash
					local airHard = clone10.AirHard
					VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Scale = airMeshHuge.Mesh.Scale * 2.3
					})
					VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					Debris(airMeshHuge, 1)
					VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Scale = airMeshStorm.Mesh.Scale * 3
					})
					VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					})
					Debris(airMeshStorm, 1)
					VisualHelper:Tween(airHard, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						CFrame = airHard.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					})
					VisualHelper:Tween(airHard.Decal, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(airHard.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						Scale = airHard.Mesh.Scale * 3
					})
					Debris(airHard, 1)
					VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Scale = flash.Mesh.Scale * 4.5
					})
					Debris(flash, 1)
					local scale = superFlash.Mesh.Scale * 2.6
					superFlash.Mesh.Scale /= 2
					VisualHelper:Tween(superFlash, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						CFrame = superFlash.CFrame * CFrame.new(0, -7, 0)
					})
					VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Transparency = 1
					})
					VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Scale = scale
					})
					Debris(superFlash, 1)
					local v29 = {
						Rate = 10,
						MaxRange = clone7.Main.Size.Z / 2,
						SideMaxRange = clone7.Main.Size.X / 2,
						Templates = xDagger.Phase0.Rocks:GetChildren()
					}

					for i = 1, v29.Rate do
						local v30 = cframe3 * CFrame.new(
							random:NextNumber(-v29.SideMaxRange, v29.SideMaxRange),
							1,
							-(i / v29.Rate * v29.MaxRange + math.random(25))
						)
						local rayCast2 = MathHelper:RayCast(
							v30.Position,
							v30.UpVector * -5,
							{ character, workspace.Terrain }
						)

						if not rayCast2 then
							continue
						end

						local cframe4 = CFrame.lookAt(rayCast2.Position, rayCast2.Position + rayCast2.Normal)
						local randomAngleFunc = RandomAngleFunc(5) -- equivalent call inferred; original call site unknown
						local clone11 = v29.Templates[math.random(#v29.Templates)]:Clone()
						clone11.PrimaryPart.Color = rayCast2.Instance.Color
						clone11.PrimaryPart.Material = rayCast2.Instance.Material
						clone11:ScaleTo(1 + math.random() * 3)
						clone11:PivotTo(cframe4 * CFrame.new(0, 0, clone11.PrimaryPart.Size.Y * 1.2) * randomAngleFunc)
						clone11.Parent = workspace.Terrain
						VisualHelper:Tween(clone11.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
							CFrame = cframe4 * CFrame.new(0, 0, -clone11.PrimaryPart.Size.Y - math.random(1, 30)) * randomAngleFunc * CFrame.Angles(
								math.random() * 3.141592653589793 / 5,
								math.random() * 3.141592653589793 / 5,
								math.random() * 3.141592653589793 / 5
							)
						})
						task.delay(0.105, function()
							clone11.PrimaryPart.Anchored = false
							clone11.PrimaryPart.CanCollide = true
							rocks:ApplyCollision(clone11, nil, true)
							clone11.PrimaryPart.AssemblyLinearVelocity = cframe4.LookVector * math.random(40, 200)
							clone11.PrimaryPart.AssemblyAngularVelocity = Vector3.new(
								math.random(-1, 1),
								math.random(-1, 1),
								math.random(-1, 1)
							) * 2.5
							task.delay(0.5, function()
								for i2, emitter in pairs(clone11.PrimaryPart:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							task.wait(1 + math.random() * 1)

							for i2, descendant in pairs(clone11.PrimaryPart:GetDescendants()) do
								if descendant:IsA("ParticleEmitter") then
									descendant.Enabled = false
								elseif descendant:IsA("MeshPart") or descendant:IsA("BasePart") then
									VisualHelper:Tween(descendant, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
										Size = createVector(0, 0, 0)
									})
								elseif descendant:IsA("Decal") then
									VisualHelper:Tween(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
										Transparency = 1
									})
								end
							end

							VisualHelper:Tween(clone11.PrimaryPart, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
								Size = createVector(0, 0, 0)
							})
						end)
					end
				else
					clone7.FinalToggle.Floor.Smoke:Destroy()
					clone7.FinalToggle.Floor.SmokeRotation:Destroy()
				end

				VisualHelper:SetEnableAll(clone7.FinalToggle, true)

				for _, v28 in children do
					local sliceGroundBeam = v28.SliceGroundBeam
					VisualHelper:Tween(v28, TweenInfo.new(0.115, Enum.EasingStyle.Back), {
						Size = v28.Size * createVector(1.75, 1, 1.75)
					})
					sliceGroundBeam.Left.Position *= 1.4
					sliceGroundBeam.Right.Position *= 1.4
					local upBeam = sliceGroundBeam.UpBeam
					upBeam.Enabled = true
					local fadeBeam = sliceGroundBeam.FadeBeam
					fadeBeam.Enabled = true
					local v29 = v28.Size.Z * 0.028
					local width = upBeam.Width0 * v29
					local width2 = upBeam.Width1 * v29
					upBeam.Width0 = 0
					upBeam.Width1 = 0
					fadeBeam.Width0 = 0
					fadeBeam.Width1 = 0
					VisualHelper:Tween(
						upBeam,
						TweenInfo.new(0.0425, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
						{
							Width0 = width,
							Width1 = width2
						}
					)
					VisualHelper:Tween(fadeBeam, TweenInfo.new(0.04, Enum.EasingStyle.Sine), {
						Width0 = width * 1.06,
						Width1 = width2 * 1.06
					})
					VisualHelper:Tween(fadeBeam, TweenInfo.new(0.27, Enum.EasingStyle.Sine), {
						Brightness = 0
					})
					VisualHelper:SetEnableAll(v28, true, true)
					task.wait(0.0055)
					local v32 = v28
					task.delay(0.1, function()
						VisualHelper:SetEnableAll(v32, false, true)
					end)
				end

				task.wait(WAIT_INTERVAL)

				for k, v28 in children do
					VisualHelper:Tween(v28, TweenInfo.new(0.3 + k * 0.075, Enum.EasingStyle.Sine), {
						Size = v28.Size * createVector(0, 1, 1)
					})
				end

				task.wait(0.07)
				VisualHelper:EmitAll(clone7.FloorImpactEnd)
				VisualHelper:SetEnableAll(clone7.Main, false, true)
				task.wait(0.15)
				VisualHelper:EmitAll(clone7.FloorImpactFast)
				VisualHelper:SetEnableAll(clone7.FinalToggle, false)
				Debris(clone7, 2)
				VisualHelper:SetEnableAll(clone6, false)
				Debris(clone6, 1.5)
				VisualHelper:SetEnableAll(clone5, false)
				Debris(clone5, 1)
				clone4:Destroy()
				task.wait(0.2)
				maid:DoCleaning()
			end)
			local _ = cframe * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0)
			VisualHelper:Tween(main, TweenInfo.new(0.145, Enum.EasingStyle.Sine), {
				Size = size2,
				CFrame = upCFrame * cframe2
			})
			local cFrame = CFrame.lookAt(position5, position5 + v15) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
				0,
				0.5,
				0
			)
			local clone3 = xDagger.Phase0.PushExplosionFast:Clone()
			clone3:PivotTo(cFrame)
			Util.SetParentOverrideWithColor(clone3, model, player2, "ControlFruitVFXColor")
			VisualHelper:EmitAll(clone3)
			Util.Debris:AddItem(clone3, 3)
			local clone4 = xDagger.Phase0.BallNeon:Clone()
			clone4.CFrame = cFrame
			clone4.Transparency = 0.95
			local color2 = Color3.fromRGB(89, 133, 255)

			if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
				color2 = Util.WrapColor3Constructor(color2, player2, "ControlFruitVFXColor")
			end

			clone4.Color = color2
			clone4.Size = createVector(1, 1, 1) * (clone3.Main.Size.Y * 0.65)
			clone4.Parent = model
			VisualHelper:Tween(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Size = clone4.Size * 4,
				Transparency = 1
			})
			Debris(clone4, 0.2)
			local beams = clone3.Main.Beams
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
			local v20 = clone3.Main.Size.X / 2
			local position3 = cFrame.Position
			local v22 = v20 * 0.7
			local v23 = { workspace.Terrain }
			Rocks:CircleRocks(position3, 13, v22, createVector(6.2, 1.2, 2), 0, v23)
			local position4 = cFrame.Position
			local v25 = v20 * 1.05
			local v26 = { workspace.Terrain }
			Rocks:CircleRocks(position4, 5, v25, createVector(5, 1.8, 3.2), 0, v26)

			for _ = 1, 3 do
				Rocks:AirRocks(
					cFrame,
					Vector3.new(random:NextNumber(6.5, 9), 2, random:NextNumber(6.5, 9)),
					false,
					math.random(90, 130),
					1,
					1,
					3,
					v16.Instance.Color,
					v16.Instance.Material
				)
			end

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
			Debris(airMeshHuge, 0.3)
			VisualHelper:Tween(airHard, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
				CFrame = airHard.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			})
			VisualHelper:Tween(airHard.Decal, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			VisualHelper:Tween(airHard.Mesh, TweenInfo.new(0.325, Enum.EasingStyle.Sine), {
				Scale = airHard.Mesh.Scale * 2
			})
			Debris(airHard, 0.5)
			VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Transparency = 1
			})
			VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Scale = flash.Mesh.Scale * 2.5
			})
			Debris(flash, 0.4)
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
			Debris(superFlash, 0.7)
		else
			if cRDaggerXLoopFly then
				cRDaggerXLoopFly:Stop()
			end

			if attachment then
				attachment:Destroy()
			end

			maid:DoCleaning()
		end
	end
end