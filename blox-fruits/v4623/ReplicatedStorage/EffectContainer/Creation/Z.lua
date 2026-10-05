local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local cameraShaker = Util.CameraShaker
local rocks = CustomCollisions.new("Rocks")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("Creation").Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

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

local function CreateCube(p, cFrame, model)
	local clone = Z.Phase2.CubePart:Clone()
	clone.Size = p + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) / 10
	clone.CFrame = cFrame
	clone.Parent = model
	clone.Color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100)):Lerp(
		Color3.fromRGB(0, 0, 0),
		0.9
	)
	clone.Transparency = 0
	rocks:ApplyCollision(clone, nil, true)
	local v = math.random(5, 10) / 100
	TweenService:Create(clone, TweenInfo.new(0.325 - v, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(math.random(-5, 5) / 2, math.random(-5, 5) / 2, math.random(-5, 5) / 2)
	})
	clone.CFrame *= CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	clone.CFrame *= CFrame.Angles(
		math.rad(math.random(-5, 5) * 10),
		math.rad(math.random(-5, 5) * 10),
		(math.rad(math.random(-5, 5) * 10))
	)
	local v2 = {
		Color3.fromRGB(150, 200, 400),
		Color3.fromRGB(480, 50, 100),
		Color3.fromRGB(450, 200, 150),
		Color3.fromRGB(250, 380, 500),
		Color3.fromRGB(250, 480, 250),
		Color3.fromRGB(500, 100, 250),
		Color3.fromRGB(500, 200, 250),
		Color3.fromRGB(200, 100, 450)
	}
	local selectionBox = clone.SelectionBox
	selectionBox.Color3 = v2[math.random(1, 8)]
	selectionBox.Parent = clone
	selectionBox.Adornee = clone
	return clone
end

local function Dizzy(currentCamera2, duration, victimChar, folder)
	if victimChar == game.Players.LocalPlayer.Character then
		task.spawn(function()
			cameraShaker:ShakeOnce(15, 15, 0.1, 0.25)
			local lastTime = tick()
			local total = 1
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 45
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = 70
			TweenService:Create(numberValue, TweenInfo.new(duration), {
				Value = 10
			}):Play()
			TweenService:Create(numberValue2, TweenInfo.new(duration), {
				Value = 25
			}):Play()
			RunService:BindToRenderStep("nauseaCam", Enum.RenderPriority.Camera.Value + 1, function(p)
				total += p * 60
				local v = 1 - (tick() - lastTime) / duration
				local v2 = { currentCamera2.CFrame:GetComponents() }
				v2[10] -= (math.cos(total / numberValue.Value) * 0.04 + 0.02) * v
				v2[11] -= (math.cos(total / numberValue2.Value) * 0.14 + 0.07) * v
				currentCamera2.CFrame = CFrame.new(table.unpack(v2))
			end)
			task.wait(duration)
			RunService:UnbindFromRenderStep("nauseaCam")
			numberValue:Destroy()
			numberValue2:Destroy()
		end)
	end

	task.spawn(function()
		local humanoidRootPart = victimChar.HumanoidRootPart
		local clone = Z.Phase2.DizzyStar:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		clone.Anchored = false
		clone.Weld.Part0 = victimChar.Head
		local v = {}

		for _, weld in pairs(clone:GetDescendants()) do
			if weld:IsA("Weld") and weld.Name ~= "Weld" then
				v[weld] = false
			end
		end

		local v2 = tick() + duration

		while true do
			for k, v3 in pairs(v) do
				if not (k ~= nil and v3 == false) then
					continue
				end

				local v4 = k
				task.spawn(function()
					v[v4] = true
					local v5 = v4
					local tween = TweenService:Create(
						v5,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = v5.Part0.CFrame:ToObjectSpace(v5.Part1.CFrame) * CFrame.Angles(
								0,
								-1.2217304763960306,
								0
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v[v4] = false
				end)
			end

			task.wait()

			if not (v2 - tick() <= 0) then
				continue
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(1)
			v = nil
			break
		end
	end)
end

return function(player)
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "CreationZHolding_" .. player.Character.Name
		folder.Parent = _WorldOrigin
		local root = player.Root
		Util.Sound:Play("CreationFruit_V1_Z_Start_01", root.Position)
		local clone = Z.Phase1.Cannon:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -1.25, 3)
		clone.Parent = folder
		Util.Sound:Play("CreationFruit_V1_Z_CannonSpawn_05", clone.Position)
		local track = clone.Model.AnimationController:LoadAnimation(clone.Model.Loop)
		track:Play(0)
		local v = Util.Sound:Play("CreationFruit_V1_Z_Hold_01", root)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local clone2 = Z.Phase0.SpawnAura:Clone()
		Util.ResizeModel(clone2, 2)
		clone2.Size *= 1.5
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 6)
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount") / 2)
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(math.random(400, 600), math.random(400, 600), math.random(400, 600))
		highlight.OutlineColor = Color3.fromRGB(
			math.random(400, 600) * 0.75,
			math.random(400, 600) * 0.75,
			math.random(400, 600) * 0.75
		)
		highlight.Parent = clone.Model
		highlight.Adornee = clone.Model
		local tween = TweenService:Create(
			highlight,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				OutlineTransparency = 1,
				FillTransparency = 1
			}
		)
		tween.Completed:Connect(function()
			highlight:Destroy()
		end)
		tween:Play()

		while true do
			task.wait()
			clone.CFrame = root.CFrame * CFrame.new(0, -1.25, 3)

			if clone2 and clone2.Parent then
				clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 6)
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			track:Stop(0)
			clone.Model.AnimationController:LoadAnimation(clone.Model.Fire):Play(0)

			if not v then
				break
			end

			Util.Sound:FadeOut(v, 0.2)
			return
		end
	elseif stage == 2 then
		local root = player.Root
		local startCFrame = player.StartCFrame
		local parent = _WorldOrigin:FindFirstChild("CreationZHolding_" .. player.Character.Name)
		local cannon

		if parent then
			cannon = parent.Cannon
			Util.Debris:AddItem(parent, 15)
		else
			parent = Instance.new("Folder")
			parent.Parent = _WorldOrigin
			Util.Debris:AddItem(parent, 15)
			cannon = Z.Phase1.Cannon:Clone()
			cannon.CFrame = startCFrame
			cannon.Parent = parent
		end

		parent.Name = "DONEZO"
		task.spawn(function()
			task.wait(1)
			Util.Sound:Play("CreationFruit_Z_Cannon_Disappear_03", cannon.Position)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(math.random(400, 600), math.random(400, 600), math.random(400, 600))
			highlight.OutlineColor = Color3.fromRGB(
				math.random(400, 600) * 0.75,
				math.random(400, 600) * 0.75,
				math.random(400, 600) * 0.75
			)
			highlight.Parent = cannon.Model
			highlight.Adornee = cannon.Model
			TweenService:Create(highlight, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				OutlineTransparency = 0,
				FillTransparency = 0
			}):Play()
			task.wait(0.5)
			local clone = Z.Phase2.EndImpact:Clone()
			Util.ResizeModel(clone, 2, clone.Position)
			clone.CFrame = cannon:GetPivot()
			clone.Parent = parent

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit((math.clamp(v2:GetAttribute("EmitCount") / 1.6, 1, v2:GetAttribute("EmitCount"))))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local model = Instance.new("Model")
				model.Parent = parent

				for _ = 1, 5 do
					local cFrame = cannon:GetPivot() * CFrame.new(
						math.random(-30, 30) / 10,
						math.random(-50, 50) / 10,
						math.random(-30, 30) / 10
					)
					CreateCube(createVector(1.5384616, 1.5384616, 1.5384616), cFrame, model)
				end

				for _, part in pairs(model:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					local v2 = part
					task.spawn(function()
						v2.CanCollide = true
						v2.Anchored = false
						v2.Massless = false
						local v3 = 0.1 * math.random() + 0.01
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Orientation = Vector3.new(
									math.random(-50, 50),
									math.random(-50, 50),
									math.random(-50, 50)
								)
							}
						)
						tween:Play()
						task.spawn(function()
							task.wait(v3 * 0.8)
							tween:Pause()
							tween:Destroy()
							v2.Velocity = CFrame.new(v2.Position, startCFrame.Position).LookVector * -math.random(
								50,
								100
							) / 2
						end)
						local selectionBox = v2.SelectionBox
						task.spawn(function()
							selectionBox.LineThickness = 1.5
							TweenService:Create(
								selectionBox,
								TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									LineThickness = 0.25
								}
							):Play()
						end)
						task.wait(1)
						task.wait(0.5 * math.random())
						local tween2 = TweenService:Create(v2, TweenInfo.new(0.225), {
							Size = createVector(0, 0, 0),
							Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
						})
						tween2:Play()
						tween2.Completed:Wait()
						v2.SelectionBox.Transparency = 1
					end)
				end
			end)
			cannon:Destroy()
		end)
		task.wait(0.05)
		local clone = Z.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -5)
		clone.Parent = parent

		if player.Player then
			local player2 = player.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
			end
		end

		Util.Sound:Play("CreationFruit_V2_Z_CannonFire_02", clone.Position)

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
		task.wait(0.015)
		local dashSpeed = player.DashSpeed
		local _ = player.DashRange

		if player.Player then
			local player2 = player.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				task.spawn(function()
					local currentCamera2 = workspace.CurrentCamera
					local clone2 = Z.Phase1.CameraFocus:Clone()
					clone2.Parent = parent
					local renderSteppedConnection = RunService.RenderStepped:Connect(function()
						clone2.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
					end)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.wait(dashSpeed)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(1)
					renderSteppedConnection:Disconnect()
					clone2:Destroy()
				end)
			end
		end

		task.spawn(function()
			local clone2 = Z.Phase1.Dash:Clone()
			clone2.CFrame = root.CFrame
			clone2.Anchored = false
			clone2.Weld.Part1 = root
			clone2.Parent = parent
			local v2 = {}

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v2[emitter] = emitter
				emitter.Enabled = true
			end

			local lastTime = tick()
			local now = tick() - 0.016666666666666666

			while tick() - lastTime < dashSpeed * 0.9 do
				local v3 = tick() - now
				local ray, _, _ = Util.Ray(
					root.CFrame.p,
					startCFrame.lookVector * (5 + root.Velocity.Magnitude * v3),
					{ workspace.Enemies, workspace.Characters }
				)

				if ray then
					break
				end

				now = tick()
				local RunService2 = game:GetService("RunService")
				RunService2.RenderStepped:Wait()
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	elseif stage == 3 then
		local root = player.Root
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local clone = Z.Phase2.Weapon:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		clone.Anchored = false
		clone.Weld.Part0 = root.Parent.RightHand
		local startCFrame = player.StartCFrame
		local clone2 = Z.Phase2.WallModel:Clone()
		clone2:SetPrimaryPartCFrame(startCFrame * CFrame.new(0, 0, -30) * CFrame.Angles(0, 3.141592653589793, 0))
		clone2.Parent = folder
		task.spawn(function()
			local victimChar = player.VictimChar
			local clone3 = Z.Phase2.GrabImpact:Clone()
			clone3.CFrame = victimChar.HumanoidRootPart.CFrame
			clone3.Parent = folder
			Util.Sound:Play("CreationFruit_V1_Z_BatIntoWall_04", root)

			for _, emitter in pairs(clone3:GetDescendants()) do
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

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local _ = root.Parent == game.Players.LocalPlayer.Character
			end)
		end)
		local v = {
			Color3.fromRGB(150, 200, 300),
			Color3.fromRGB(380, 50, 100),
			Color3.fromRGB(250, 200, 150),
			Color3.fromRGB(250, 380, 400),
			Color3.fromRGB(250, 380, 250),
			Color3.fromRGB(400, 100, 250),
			Color3.fromRGB(400, 200, 250),
			Color3.fromRGB(200, 100, 350)
		}

		for _, part in pairs(clone2:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			rocks:ApplyCollision(part, nil, true)
			local v2 = part
			task.spawn(function()
				v2.Transparency = 1
				local v3 = math.random(0, 25) / 100
				task.wait(v3)
				local clone3 = Z.Phase2.SelectionBox:Clone()
				clone3.Color3 = v[math.random(1, 8)]
				clone3.Parent = v2
				clone3.Adornee = v2
				v2.Color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100)):Lerp(
					Color3.fromRGB(0, 0, 0),
					0.9
				)
				v2.Transparency = 0.7
				local tween = TweenService:Create(v2, TweenInfo.new(0.225), {
					CFrame = v2.CFrame,
					Size = v2.Size
				})
				v2.CFrame *= CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				v2.CFrame *= CFrame.Angles(
					math.rad(math.random(-5, 5) * 10),
					math.rad(math.random(-5, 5) * 10),
					(math.rad(math.random(-5, 5) * 10))
				)
				v2.Size = createVector(0, 0, 0)
				tween:Play()
				task.spawn(function()
					clone3.Parent = v2
					clone3.Adornee = v2
					clone3.LineThickness = 3
					TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
						LineThickness = 0.1
					}):Play()
				end)
				task.delay(0.35 - v3, function()
					v2.Anchored = false
					v2.CanCollide = true
					v2.Massless = false
					v2.Size += Vector3.new(math.random(-3, 3) * 2, math.random(-3, 3) / 2, math.random(-3, 3))
					local cframe = CFrame.new(v2.Position, startCFrame * CFrame.new(0, 0, -5).Position)
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
					bodyVelocity.P = 700
					bodyVelocity.Velocity = cframe.LookVector * -math.random(50, 200)
					bodyVelocity.Parent = v2
					local clone4

					if math.random(1, 3) == 1 then
						clone4 = Z.Phase2.SmallTrail:Clone()
						clone4.CFrame = v2.CFrame
						clone4.Parent = folder
						clone4.Anchored = false
						clone4.WeldConstraint.Part1 = v2
						local color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100))
						clone4.Trail.Color = ColorSequence.new(color, color)
					else
						clone4 = false
					end

					task.wait(math.random(10, 20) / 170)
					bodyVelocity:Destroy()
					task.wait(math.random(10, 20) / 15)
					tween = TweenService:Create(v2, TweenInfo.new(0.225), {
						Size = createVector(0, 0, 0)
					})
					tween:Play()

					if clone4 then
						for i, effect in pairs(clone4:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end

					tween.Completed:Wait()
					v2:Destroy()
				end)
			end)
		end

		task.delay(0.325, function()
			local clone3 = Z.Phase2.Slash:Clone()
			clone3.CFrame = startCFrame * CFrame.new(0, 0, -10) * CFrame.Angles(3.141592653589793, 0, 0)
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
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

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		end)
		task.wait(0.39999999999999997)
		local clone3 = Z.Phase2.HitImpact:Clone()
		clone3.CFrame = startCFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, 3.141592653589793, 0)
		clone3.Parent = folder

		if (currentCamera.CFrame.p - clone3.Position).Magnitude <= 70 then
			cameraShaker:ShakeOnce(20, 16, 0.2, 0.25)
		end

		Dizzy(currentCamera, 2, player.VictimChar, folder)

		for _, emitter in pairs(clone3:GetDescendants()) do
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

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		task.wait(0.15)
		clone.Weld.Enabled = false
		clone.Velocity = clone.CFrame.LookVector * 80
		clone.RotVelocity = clone.CFrame.RightVector * -30
		task.delay(2, function()
			clone:Destroy()
		end)
	end
end