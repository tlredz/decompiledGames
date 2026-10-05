local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local Players = game:GetService("Players")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local C = FX:WaitForChild("DragonTalon").C
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

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

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, p4)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function OuterFlame(p, folder)
	local clone = C.Phase3.TrailModel:Clone()
	local primaryPart = clone.PrimaryPart
	primaryPart.CFrame = p * CFrame.new(0, 0, -3.5)
	clone.Parent = folder
	clone:ScaleTo(math.random(3, 6) / 10)

	for _, emitter in pairs(primaryPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local position = primaryPart.Position
	local v = primaryPart.CFrame * CFrame.new(
		math.random(-25, 25) / 10,
		math.random(10, 70),
		-math.random(50, 100) / 10
	).Position
	local magnitude = (position - v).Magnitude
	primaryPart.CFrame = CFrame.new(position, v)
	local v2 = (position - v) / 2
	local cframe = CFrame.new(CFrame.new(position) * (v2 / -1.5))
	local cframe2 = CFrame.new(CFrame.new(v) * (v2 / 1.5))
	local v3 = CFrame.new(cframe.Position, cframe.Position + p.LookVector) * CFrame.Angles(
		0,
		0,
		(math.rad((math.random(-180, 180))))
	)
	local v4 = CFrame.new(cframe2.Position, cframe2.Position + p.LookVector) * CFrame.Angles(
		0,
		0,
		(math.rad((math.random(-180, 180))))
	)
	local v5 = math.random(20, 30) * 1.5
	local v6 = v3 * CFrame.new(0, math.random(v5, v5 * 2), math.random(-v5 / 3, v5 / 3)).Position
	local v7 = v4 * CFrame.new(0, math.random(v5, v5 * 2), math.random(-v5 / 3, v5 / 3)).Position
	local v8 = math.random(20, 35) / 10
	local lastTime = tick()
	local v9 = magnitude / v8 / 60

	while tick() - lastTime < v9 do
		local v10 = (tick() - lastTime) / v9
		local v11 = cubicBezier(v10, position, v6, v7, v)
		primaryPart.CFrame = primaryPart.CFrame:Lerp(CFrame.new(v11, v), v10)
		RunService.Heartbeat:Wait()
	end

	for _, emitter in pairs(primaryPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

local function SpinRocks(startCFrame, folder, color, material)
	local clone = C.Phase3.RockPoint:Clone()
	clone.CFrame = startCFrame
	rocks:ApplyCollision(clone.FlyRock, nil, true)
	clone.Parent = folder
	local flyRock = clone.FlyRock
	flyRock.CFrame = clone.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(0, 0, -150) * CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	flyRock.Anchored = false
	flyRock.WeldConstraint.Enabled = true
	flyRock.Color = color
	flyRock.Material = material
	flyRock.Size = Vector3.new(math.random(5, 10), math.random(5, 10), math.random(5, 10)) * math.random(70, 125) / 100

	for _ = 1, 15 do
		local clone2 = clone.FlyRock:Clone()
		clone2.WeldConstraint.Enabled = false
		clone2.CFrame = clone.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
			0,
			math.random(-50, 50),
			-math.random(100, 150)
		) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
		clone2.WeldConstraint.Enabled = true
		clone2.Size = Vector3.new(math.random(5, 10), math.random(5, 10), math.random(5, 10)) * math.random(70, 125) / 100
		clone2.Parent = clone
		task.delay(math.random(5, 9) / 10, function()
			clone2.WeldConstraint:Destroy()
			clone2.CanCollide = true
		end)
	end

	task.delay(math.random(5, 9) / 10, function()
		flyRock.WeldConstraint:Destroy()
		flyRock.CanCollide = true
	end)
	task.spawn(function()
		local v = math.random(10, 15)

		for i = 1, 10 do
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, math.rad(179 / (i / 2)), 0) * CFrame.new(0, v, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "FlyRock" then
				TweenService:Create(
					child,
					TweenInfo.new(
						0.35,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(150, 250) / 100
					),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
			end
		end
	end)
end

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	return part
end

return function(player)
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local character = player.Character
	local root = player.Root
	local startCFrame = player.StartCFrame

	if player.Stage == 1 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local upDistance = player.UpDistance
		task.spawn(function()
			local cFrame = root.CFrame
			local lastTime = tick()

			while tick() - lastTime < 0.5 do
				root.CFrame = cFrame:Lerp(player.goalCF, ((tick() - lastTime) / 0.5) ^ 0.66)
				RunService.PreSimulation:Wait()
			end

			root.CFrame = player.goalCF
		end)
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = startCFrame
		part.Parent = _WorldOrigin
		part.Parent = folder
		Util.Sound:Play("DragonTalon.CActivate", part)
		local screenColorDFV3 = game.Lighting:FindFirstChild("ScreenColorDFV3") or C.Phase1.ScreenColorDFV3:Clone()
		screenColorDFV3:SetAttribute("UsedTimes", screenColorDFV3:GetAttribute("UsedTimes") + 1)
		screenColorDFV3:GetAttribute("UsedTimes")
		TweenService:Create(screenColorDFV3, TweenInfo.new(0.5), {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(231, 191, 170)
		}):Play()
		task.spawn(function()
			local clone = C.Phase1.TrailModel:Clone()
			local trails = clone.Trails
			trails.CFrame = startCFrame
			clone.Parent = folder
			trails.Anchored = false
			trails.Motor6D.Part1 = part
			local clone_2 = clone.Trails:Clone()
			clone_2.Parent = clone
			trails.Motor6D.C1 = CFrame.Angles(0, 3.141592653589793, 0)
			clone:ScaleTo(0.5)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			task.spawn(function()
				task.wait(0.15)

				for _, motor6D in pairs(clone:GetDescendants()) do
					if motor6D:IsA("Motor6D") then
						TweenService:Create(motor6D, TweenInfo.new(0.15), {
							C0 = CFrame.new(0, 0, 0)
						}):Play()
					end
				end

				for i = 7, 3, -1 do
					clone:ScaleTo(i / 15)
					task.wait(0.05)
				end
			end)
			task.wait(0.35)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		local clone = C.Phase1.AlignMover:Clone()
		clone.CFrame = startCFrame
		clone.Anchored = false
		clone.Parent = folder
		clone.Weld.Part0 = part
		local alignOrientation = clone.AlignOrientation
		alignOrientation.Enabled = true
		alignOrientation.CFrame = startCFrame
		local alignPosition = clone.AlignPosition
		alignPosition.Enabled = true
		alignPosition.Responsiveness = 25
		alignPosition.Position = startCFrame * CFrame.new(0, upDistance, 0).Position
		TweenService:Create(
			alignPosition,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false),
			{
				Responsiveness = 15
			}
		):Play()
		task.spawn(function()
			for i = 1, 3 do
				local tween = TweenService:Create(
					alignOrientation,
					TweenInfo.new(i / 100 + 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
					{
						CFrame = alignOrientation.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			local tween = TweenService:Create(
				alignOrientation,
				TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
				{
					CFrame = alignOrientation.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(
				alignOrientation,
				TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
				{
					CFrame = startCFrame
				}
			)
			tween2:Play()
			tween2.Completed:Wait()
		end)
		task.spawn(function()
			if player.Player == game.Players.LocalPlayer then
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.225, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()
			end

			task.wait(0.15)
			local clone2 = C.Phase1.RiseAura:Clone()
			clone2.CFrame = startCFrame
			clone2.Parent = folder
			TweenService:Create(
				clone2,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false),
				{
					CFrame = startCFrame * CFrame.new(0, upDistance, 0)
				}
			):Play()
			local v = {}

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v[emitter] = tick() + 1 / emitter.Rate
				emitter.Enabled = true
			end

			local v2 = tick() + 0.35

			while true do
				for k, _ in pairs(v) do
					k:Emit(1)
				end

				task.wait(0.05)

				if not (v2 - tick() <= 0) then
					continue
				end

				for k, _ in pairs(v) do
					k.Enabled = false
				end

				if player.Player == game.Players.LocalPlayer then
					TweenService:Create(
						currentCamera,
						TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end

				break
			end
		end)
		task.wait(0.125)
		local clone2 = C.Phase1.Slash:Clone()
		clone2.CFrame = CFrame.new(startCFrame.Position) * CFrame.new(0, upDistance, 0)
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
				{
					CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end)
		local clone3 = C.Phase2.BurnModel:Clone()
		clone3.PrimaryPart.CFrame = startCFrame * CFrame.new(0, upDistance, 0)
		clone3.Parent = folder
		local clone4 = C.Phase2.CameraFocus:Clone()
		clone4.Parent = folder
		local renderSteppedConnection

		if player.Player == game.Players.LocalPlayer then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3)
				clone3.PrimaryPart.CFrame = CFrame.new(root.Position)
			end)
		else
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone4.CFrame = CFrame.lookAt(root.Position, currentCamera.CFrame.Position) * CFrame.new(0, 0, -3)
				clone3.PrimaryPart.CFrame = CFrame.new(root.Position)
			end)
		end

		task.wait(0.1)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v = nil
		task.spawn(function()
			local WAIT_INTERVAL = 0.1
			Util.Sound:Play("DragonTalon.CIntense", clone3.PrimaryPart)
			clone3:ScaleTo(1.2)
			task.wait(WAIT_INTERVAL)
			clone3:ScaleTo(1.4)
			task.wait(WAIT_INTERVAL)
			clone3:ScaleTo(1.6)
			task.wait(WAIT_INTERVAL)
			v = Util.Sound:Play("DragonTalon.CHoldIntense", clone3.PrimaryPart)
			clone3:ScaleTo(1.8)
			local clone5 = C.Phase2.StarAura:Clone()
			clone5.CFrame = startCFrame * CFrame.new(0, player.UpDistance, 0)
			clone5.Parent = folder

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(3)
			end

			task.wait(WAIT_INTERVAL)
			clone3:ScaleTo(2)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Emit(3)
			end
		end)
		TweenService:Create(screenColorDFV3, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Brightness = -0.15,
			Contrast = 0.1,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(231, 164, 116)
		}):Play()

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local lastTime = tick()

		while player.Holding and player.Holding.Value and tick() - lastTime < player.TimeOut do
			task.wait()
		end

		if tick() - lastTime < 0.4 then
			task.wait(0.4 - (tick() - lastTime))
		end

		if v then
			sound:FadeOut(v, 0.7)
		end

		task.spawn(function()
			task.wait(0.25)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.5)
			renderSteppedConnection:Disconnect()
			clone4:Destroy()
		end)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	elseif player.Stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local timeToLand = player.TimeToLand
		local screenColorDFV3 = game.Lighting:FindFirstChild("ScreenColorDFV3") or C.Phase1.ScreenColorDFV3:Clone()
		local parent

		if player.Player == Players.LocalPlayer then
			parent = game.Lighting or folder
		else
			parent = folder
		end

		screenColorDFV3.Parent = parent
		screenColorDFV3:SetAttribute("UsedTimes", screenColorDFV3:GetAttribute("UsedTimes") + 1)
		local usedTimes = screenColorDFV3:GetAttribute("UsedTimes")
		local dTalonCDiveDown = Util.Anims:Get(character, "DTalon_CDiveDown")
		dTalonCDiveDown.Priority = Enum.AnimationPriority.Action2
		dTalonCDiveDown:Play(nil, nil, 3)
		task.delay(0.05, function()
			local clone = C.Phase2.StartImpact:Clone()
			clone.CFrame = player.TopCFrame
			clone.Parent = folder

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
		local tween = TweenService:Create(screenColorDFV3, TweenInfo.new(0.15), {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(231, 164, 116)
		})
		tween:Play()
		local clone = C.Phase2.FallAura:Clone()
		clone.CFrame = root.CFrame
		clone.Anchored = false
		clone.Weld.Part0 = root
		clone.Parent = folder
		local v2 = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v2[emitter] = tick() + 1 / emitter.Rate
			emitter.Enabled = true
		end

		TweenService:Create(root, TweenInfo.new(timeToLand), {
			CFrame = startCFrame
		}):Play()
		Util.Sound:Play("DragonTalon.CExplosion", root)
		task.wait(timeToLand)

		for k, _ in pairs(v2) do
			k.Enabled = false
		end

		dTalonCDiveDown:Stop()
		Util.Anims:Get(character, "DTalon_CLand"):Play(nil, nil, 2)
		local clone2 = C.Phase3.Explosion:Clone()
		clone2.CFrame = startCFrame
		clone2.Parent = folder
		Util.ResizeModel(clone2, 0.8, clone2.Position)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			local function AlignCFrame(data, normal)
				local v3 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
				local p = data.p
				local unit = data.LookVector:Cross(v3).Unit
				local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
				local unit3 = unit2:Cross(v3).Unit
				return CFrame.fromMatrix(p, unit2, v3, unit3)
			end

			local raycastResult = workspace:Raycast(
				clone2.Position + createVector(0, 5, 0) + createVector(0, 1, 0),
				createVector(-0, -15, -0),
				raycastParams
			)

			if raycastResult then
				local material = raycastResult.Material
				local color = raycastResult.Instance.Color
				task.spawn(function()
					task.wait(0.1)
					SpinRocks(startCFrame, folder, color, material)
				end)
				local clone3 = C.Phase3.GroundExplosion:Clone()
				clone3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
				clone3.Parent = folder
				Util.ResizeModel(clone3, 0.5, clone3.Position)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v3 = emitter
					task.spawn(function()
						if v3:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v3:GetAttribute("EmitDelay"))
						end

						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
				local clone4 = C.Phase3.GroundBurn:Clone()
				clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
				clone4.Parent = folder
				Util.ResizeModel(clone4, 0.8, clone4.Position)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					task.wait(0.25)
					local clone5 = C.Phase3.ExplosionStartImpact:Clone()
					clone5.CFrame = startCFrame
					clone5.Parent = folder
					Util.ResizeModel(clone5, 0.8, clone5.Position)

					for _, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					task.wait(0.1)
					local clone6 = C.Phase3.Explosion2:Clone()
					clone6.CFrame = startCFrame
					clone6.Parent = folder
					Util.ResizeModel(clone6, 0.5, clone6.Position)

					for _, emitter in pairs(clone6:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v3 = emitter
						task.spawn(function()
							if v3.Parent ~= clone6.Attachment and v3.Parent ~= clone6.Attachment2 and v3.Parent ~= clone6 then
								v3.Enabled = true
								task.wait(0.15)
								v3.Enabled = false
							end

							if v3:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v3:GetAttribute("EmitDelay"))
							end

							v3:Emit(v3:GetAttribute("EmitCount"))
						end)
					end

					for _ = 1, 10 do
						task.spawn(function()
							OuterFlame(
								startCFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(100, 150)
								),
								folder
							)
						end)
					end
				end)
				task.spawn(function()
					task.wait(0.3)
					local clone5 = C.Phase3.Pillar:Clone()
					clone5.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
					clone5.Parent = folder
					Util.ResizeModel(clone5, 0.8, clone5.Position)

					for _, emitter in pairs(clone5:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						emitter:Emit(1)
					end

					task.wait(0.25)

					for _, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				task.wait(1.5)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
		task.spawn(function()
			for _ = 1, 3 do
				task.spawn(function()
					local clone3 = C.Phase3.SpinTrailModel:Clone()
					local trails = clone3.Trails
					trails.CFrame = startCFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					clone3.Parent = folder
					clone3:ScaleTo(0.8)

					for _, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					task.spawn(function()
						task.wait(0.35)

						for _, motor6D in pairs(clone3:GetDescendants()) do
							if motor6D:IsA("Motor6D") then
								TweenService:Create(motor6D, TweenInfo.new(0.3), {
									C0 = CFrame.new(0, 0, 0)
								}):Play()
							end
						end
					end)
					task.spawn(function()
						local v3 = math.random(15, 30)

						for i = 1, 5 do
							local tween2 = TweenService:Create(
								trails,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = trails.CFrame * CFrame.Angles(0, math.rad(179 / (i / 2)), 0) * CFrame.new(
										0,
										v3,
										0
									)
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
						end
					end)
					task.wait(0.5)

					for _, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
				task.wait(0.15)
			end
		end)
		task.spawn(function()
			if (currentCamera.CFrame.p - startCFrame.Position).Magnitude <= 250 then
				Effect.new("ShakeCam"):play({
					25,
					10,
					0.25,
					0.5
				})
			end

			tween = TweenService:Create(screenColorDFV3, TweenInfo.new(0.05), {
				Brightness = 0.1,
				Contrast = 0.25,
				Saturation = 0.25,
				TintColor = Color3.fromRGB(255, 255, 255)
			})
			tween:Play()
			task.wait(0.05)
			tween = TweenService:Create(screenColorDFV3, TweenInfo.new(0.15), {
				Brightness = 0,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Color3.fromRGB(231, 169, 119)
			})
			tween:Play()
			task.wait(0.25)

			if screenColorDFV3:GetAttribute("UsedTimes") == usedTimes then
				tween = TweenService:Create(screenColorDFV3, TweenInfo.new(0.5), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween:Play()
				tween.Completed:Wait()

				if screenColorDFV3:GetAttribute("UsedTimes") == usedTimes then
					screenColorDFV3:Destroy()
				end
			end
		end)
	end
end