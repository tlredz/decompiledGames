local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Z = FX:WaitForChild("DragonTalon").Z
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = {
	"LeftLowerArm",
	"RightLowerArm",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftUpperLeg",
	"RightUpperLeg",
	"RightHand",
	"LeftHand",
	"LeftFoot",
	"RightFoot",
	"UpperTorso",
	"LowerTorso",
	"Head"
}

for _, v2 in pairs(v) do
	v[v2] = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local function SmallFlames(startCFrame, folder, root)
	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end

	local function lerp(p, p2, p3)
		return p + (p2 - p) * p3
	end

	local function cubicBezier(p, position, p2, p3, p4)
		local v2 = position + (p2 - position) * p
		local v3 = p2 + (p3 - p2) * p
		local v4 = p3 + (p4 - p3) * p
		local v5 = v2 + (v3 - v2) * p
		return v5 + (v3 + (v4 - v3) * p - v5) * p
	end

	local function FlameTrails(p, parent)
		local clone = Z.Phase2.SmallTrail:Clone()
		clone.CFrame = p * CFrame.new(0, 0, -3.5)
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local position = clone.Position
		local v2 = clone.CFrame * CFrame.new(math.random(-25, 25), math.random(-3, 3), -math.random(50, 100)).Position
		local magnitude = (position - v2).Magnitude
		clone.CFrame = CFrame.new(position, v2)
		local v3 = (position - v2) / 2
		local cframe = CFrame.new(CFrame.new(position) * (v3 / -1.5))
		local cframe2 = CFrame.new(CFrame.new(v2) * (v3 / 1.5))
		local v4 = CFrame.new(cframe.Position, cframe.Position + p.LookVector) * CFrame.Angles(
			0,
			0,
			(math.rad((math.random(-180, 180))))
		)
		local v5 = CFrame.new(cframe2.Position, cframe2.Position + p.LookVector) * CFrame.Angles(
			0,
			0,
			(math.rad((math.random(-180, 180))))
		)
		local v6 = math.random(20, 30)
		local v7 = v4 * CFrame.new(0, math.random(v6, v6 * 2), math.random(-v6 / 3, v6 / 3)).Position
		local v8 = v5 * CFrame.new(0, math.random(v6, v6 * 2), math.random(-v6 / 3, v6 / 3)).Position
		local v9 = math.random(25, 30) / 10
		local lastTime = tick()
		local v10 = magnitude / v9 / 60

		while tick() - lastTime < v10 do
			local v11 = (tick() - lastTime) / v10
			local v12 = cubicBezier(v11, position, v7, v8, v2)
			clone.CFrame = clone.CFrame:Lerp(CFrame.new(v12, v2), v11)
			RunService.Heartbeat:Wait()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	for _ = 1, 3 do
		task.spawn(function()
			local clone = Z.Phase2.TornadoSlashModel:Clone()
			clone.PrimaryPart.CFrame = root.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			clone.Parent = folder
			task.spawn(function()
				clone:ScaleTo(1)
				task.wait(0.1)

				for i = 10, 15 do
					clone:ScaleTo(i / 10)
					task.wait(0.015)
				end

				for _, beam in pairs(clone:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v2 = beam
					task.spawn(function()
						local endDelay = v2:GetAttribute("EndDelay")
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				end
			end)
			task.spawn(function()
				local v2 = math.random(30, 50) / 2

				for _ = 1, 10 do
					local tween = TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(0.035, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(
								0,
								0,
								(math.rad(v2))
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
		end)
		task.wait()
	end

	task.wait(0.35)
	task.wait(0.35)
	task.spawn(function()
		task.wait(0.1)

		for _ = 1, 5 do
			task.spawn(function()
				local clone = Z.Phase2.TornadoSlashModel2:Clone()
				clone.PrimaryPart.CFrame = root.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
				clone.Parent = folder
				task.spawn(function()
					clone:ScaleTo(1)
					task.wait(0.125)
					clone:ScaleTo(1.5)

					for i = 15, 25 do
						clone:ScaleTo(i / 10)
						task.wait(0.025 / i)
					end

					for _, beam in pairs(clone:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local v2 = beam
						task.spawn(function()
							local endDelay = v2:GetAttribute("EndDelay")
							local tween = TweenService:Create(
								v2,
								TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v2:Destroy()
						end)
					end
				end)
				task.spawn(function()
					local v2 = math.random(30, 50)

					for _ = 1, 15 do
						local tween = TweenService:Create(
							clone.PrimaryPart,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(
									0,
									0,
									(math.rad(v2))
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end
				end)
			end)
			task.wait(0.125)
		end
	end)

	for _ = 1, 10 do
		task.spawn(function()
			FlameTrails(startCFrame, folder)
		end)
		task.wait(0.05)
	end
end

local function ScreenEffectExecute(folder)
	local screenColorDFV2 = game.Lighting:FindFirstChild("ScreenColorDFV2") or Z.Phase2.ScreenColorDFV2:Clone()
	screenColorDFV2.Parent = game.Lighting
	screenColorDFV2:SetAttribute("UsedTimes", screenColorDFV2:GetAttribute("UsedTimes") + 1)
	local usedTimes = screenColorDFV2:GetAttribute("UsedTimes")
	local tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.35), {
		Brightness = -0.1,
		Contrast = 0.1,
		Saturation = 0.1,
		TintColor = Color3.fromRGB(255, 172, 139)
	})
	tween:Play()
	task.spawn(function()
		task.wait(0.85)
		tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.25), {
			TintColor = Color3.fromRGB(255, 172, 139),
			Contrast = 0.2,
			Saturation = 0.15
		})
		tween:Play()
	end)
	local currentCamera2 = workspace.CurrentCamera
	local clone = Z.Phase2.CameraFocus:Clone()
	clone.Parent = folder
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		task.delay(0.85, function()
			clone.Particle_1.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0), Color3.fromRGB(0, 0, 0))
		end)
		task.wait(2)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
	task.spawn(function()
		task.wait(1.885)
		tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.01), {
			TintColor = Color3.fromRGB(154, 28, 28),
			Contrast = 5,
			Saturation = -1
		})
		tween:Play()
		task.wait(0.1)
		tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.15), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween:Play()
	end)
	task.wait(2)

	if screenColorDFV2:GetAttribute("UsedTimes") == usedTimes then
		tween = TweenService:Create(screenColorDFV2, TweenInfo.new(1.5), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween:Play()
		tween.Completed:Wait()

		if screenColorDFV2:GetAttribute("UsedTimes") == usedTimes then
			screenColorDFV2:Destroy()
		end
	end
end

local function ScreenEffect(folder, p)
	local screenColorDFV2 = game.Lighting:FindFirstChild("ScreenColorDFV2") or Z.Phase2.ScreenColorDFV2:Clone()
	screenColorDFV2.Parent = game.Lighting
	screenColorDFV2:SetAttribute("UsedTimes", screenColorDFV2:GetAttribute("UsedTimes") + 1)
	local usedTimes = screenColorDFV2:GetAttribute("UsedTimes")
	local tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.35), {
		Brightness = 0,
		Contrast = 0.1,
		Saturation = 0.1,
		TintColor = Color3.fromRGB(231, 174, 140)
	})
	tween:Play()
	task.spawn(function()
		task.wait(0.85)

		if not p then
			tween = TweenService:Create(screenColorDFV2, TweenInfo.new(0.25), {
				TintColor = Color3.fromRGB(155, 175, 231)
			})
			tween:Play()
		end
	end)
	local currentCamera2 = workspace.CurrentCamera
	local clone = Z.Phase2.CameraFocus:Clone()
	clone.Parent = folder
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		task.delay(0.85, function()
			if not p then
				clone.Particle_1.Color = ColorSequence.new(Color3.fromRGB(41, 87, 255), Color3.fromRGB(41, 87, 255))
			end
		end)
		task.wait(2)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
	task.wait(2)

	if screenColorDFV2:GetAttribute("UsedTimes") == usedTimes then
		tween = TweenService:Create(screenColorDFV2, TweenInfo.new(1.5), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween:Play()
		tween.Completed:Wait()

		if screenColorDFV2:GetAttribute("UsedTimes") == usedTimes then
			screenColorDFV2:Destroy()
		end
	end
end

return function(player)
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local character = player.Character
	local root = player.Root

	if player.stage == 1 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local startCFrame = player.StartCFrame
		local clone = Z.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -5)
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
		sound:Play("DragonTalon.ZRelease", root)
		task.wait(0.015)
		local dashSpeed = player.DashSpeed
		local _ = player.DashRange
		root.CFrame = startCFrame
		local clone2 = Z.Phase1.TRexModel:Clone()
		clone2.PrimaryPart.CFrame = startCFrame * CFrame.new(0, 12, -10)
		clone2.Parent = folder
		clone2.PrimaryPart.Anchored = false
		clone2.PrimaryPart.Weld.Part1 = root
		task.spawn(function()
			task.wait(dashSpeed * 0.7)

			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("BasePart") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Beam") then
					descendant.Enabled = false
				end
			end

			task.wait(1)
			clone2:Destroy()
		end)
		local clone3 = Z.Phase1.Dash:Clone()
		clone3.CFrame = root.CFrame
		clone3.Anchored = false
		clone3.Weld.Part1 = root
		clone3.Parent = folder
		local v2 = {}

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v2[emitter] = tick() + 1 / emitter.Rate
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

		for _, effect in pairs(clone3:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	elseif player.stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local startCFrame = player.StartCFrame
		root.CFrame = startCFrame

		if player.GrabTarget then
			local grabTarget = player.GrabTarget

			local function FlameBurst(part, C0, parent, duration)
				task.spawn(function()
					local clone = Z.Phase2.HitFlame:Clone()
					clone:SetPrimaryPartCFrame(part.CFrame)
					clone.Parent = parent
					clone.Main.Anchored = false
					clone.Weld.Part0 = part
					clone.Weld.C0 = C0
					local extraFlameModel = clone.ExtraFlameModel
					extraFlameModel.PrimaryPart.CFrame = root.CFrame * CFrame.new(0, 0, -50)
					extraFlameModel.Parent = parent
					extraFlameModel:ScaleTo(0.5)

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						emitter.Color = ColorSequence.new(Color3.fromRGB(255, 73, 28), Color3.fromRGB(255, 73, 28))
					end

					task.spawn(function()
						clone:ScaleTo(0.35)
						task.wait(0.35)
						clone:ScaleTo(0.5)
						task.wait(0.25)
						clone:ScaleTo(0.5)
						task.wait(0.25)
						extraFlameModel.PrimaryPart.CFrame = extraFlameModel.PrimaryPart.CFrame
						task.delay(0.1, function()
							extraFlameModel:ScaleTo(0.7)
						end)

						for _, emitter in pairs(extraFlameModel:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Color = ColorSequence.new(
									Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), 1),
									Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), 1)
								)
							end
						end

						for i = 5, 10 do
							clone:ScaleTo(i / 10)

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Color = ColorSequence.new(
										Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), i / 10),
										Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), i / 10)
									)
								end
							end

							task.wait(0.025)
						end
					end)
					task.wait(duration)

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							TweenService:Create(
								effect,
								TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end

					for _, emitter in pairs(extraFlameModel:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end

			local _ = root.CFrame * CFrame.new(0, 0, -5)
			local clone = Z.Phase2.GrabImpact:Clone()
			clone.CFrame = player.CFrameGoal
			clone.Parent = folder
			sound:Play("DragonTalon.ZRegularHit", root.Position)

			if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
				Effect.new("ShakeCam"):play({
					6,
					16,
					0.1,
					4,
					createVector(1, 1, 1),
					createVector(1, 1, 2)
				})
			end

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
			task.spawn(function()
				task.wait(0.15)
				SmallFlames(startCFrame, folder, root)
			end)
			task.spawn(function()
				if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
					ScreenEffect(folder)
				end
			end)
			task.wait(0.35)
			local cframe = CFrame.new(0, 0, -5)
			local v2 = 1.5
			task.spawn(function()
				local clone2 = Z.Phase2.HitFlame:Clone()
				clone2:SetPrimaryPartCFrame(root.CFrame)
				clone2.Parent = folder
				clone2.Main.Anchored = false
				clone2.Weld.Part0 = root
				clone2.Weld.C0 = cframe
				local extraFlameModel = clone2.ExtraFlameModel
				extraFlameModel.PrimaryPart.CFrame = root.CFrame * CFrame.new(0, 0, -50)
				extraFlameModel.Parent = folder
				extraFlameModel:ScaleTo(0.5)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					emitter.Color = ColorSequence.new(Color3.fromRGB(255, 73, 28), Color3.fromRGB(255, 73, 28))
				end

				task.spawn(function()
					clone2:ScaleTo(0.35)
					task.wait(0.35)
					clone2:ScaleTo(0.5)
					task.wait(0.25)
					clone2:ScaleTo(0.5)
					task.wait(0.25)
					extraFlameModel.PrimaryPart.CFrame = extraFlameModel.PrimaryPart.CFrame
					task.delay(0.1, function()
						extraFlameModel:ScaleTo(0.7)
					end)

					for _, emitter in pairs(extraFlameModel:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Color = ColorSequence.new(
								Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), 1),
								Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), 1)
							)
						end
					end

					for i = 5, 10 do
						clone2:ScaleTo(i / 10)

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Color = ColorSequence.new(
									Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), i / 10),
									Color3.fromRGB(255, 73, 28):Lerp(Color3.fromRGB(41, 87, 255), i / 10)
								)
							end
						end

						task.wait(0.025)
					end
				end)
				task.wait(v2)

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Beam") then
						TweenService:Create(
							effect,
							TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
					end
				end

				for _, emitter in pairs(extraFlameModel:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait(1.35)
			local clone2 = Z.Phase3.SlashModel:Clone()
			clone2.PrimaryPart.CFrame = startCFrame * CFrame.Angles(2.356194490192345, 0, 0)
			clone2.Parent = folder
			task.spawn(function()
				for _, beam in pairs(clone2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local startDelay = beam:GetAttribute("StartDelay")
					local v3 = beam
					local v4 = beam:GetAttribute("EndDelay")
					task.spawn(function()
						local tween = TweenService:Create(
							v3,
							TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = v3.Width0,
								Width1 = v3.Width1
							}
						)
						v3.Width0 = 0
						v3.Width1 = 0
						task.wait(startDelay)
						tween:Play()
						task.wait(v4)
						local tween2 = TweenService:Create(
							v3,
							TweenInfo.new(v4 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween2:Play()
						tween2.Completed:Wait()
						v3:Destroy()
					end)
				end
			end)
			TweenService:Create(clone2.PrimaryPart, TweenInfo.new(0.25), {
				CFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(-2.6179938779914944, 0, 0)
			}):Play()
			local clone3 = Z.Phase3.SlashHit:Clone()
			clone3.CFrame = startCFrame * CFrame.new(0, 0, -20)
			clone3.Parent = folder

			if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
				Effect.new("ShakeCam"):play({
					14,
					46,
					0.1,
					1,
					createVector(1, 1, 1),
					createVector(1, 1, 2)
				})
			end

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
		end
	elseif player.stage == 3 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local startCFrame = player.StartCFrame
		root.CFrame = startCFrame
		local cFrame = root.CFrame * CFrame.new(0, 0, -5)
		local grabTarget = player.GrabTarget
		local clone = Z.Phase2.GrabImpact:Clone()
		clone.CFrame = player.CFrameGoal
		clone.Parent = folder
		sound:Play("DragonTalon.ZExecution", root.Position)

		if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
			Effect.new("ShakeCam"):play({
				6,
				16,
				0.1,
				4,
				createVector(1, 1, 1),
				createVector(1, 1, 2)
			})
		end

		for _, emitter in pairs(clone:GetDescendants()) do
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

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local descendantsByDescendant = {}
		task.spawn(function()
			local clone2 = Z.FinisherPhase.HitImpact:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = folder

			for i = 1, 15 do
				clone2.Attachment3.Orientation = Vector3.new(
					math.random(-25, 25),
					math.random(-25, 25),
					math.random(-25, 25)
				)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				if i % 2 == 0 then
					task.spawn(function()
						local clone3 = Z.FinisherPhase.BeamPartModel:Clone()
						clone3.PrimaryPart.CFrame = cFrame * CFrame.Angles(
							-1.5707963267948966,
							math.rad((math.random(-90, 90))),
							(math.rad((math.random(-90, 90))))
						)
						clone3.Parent = folder
						clone3:ScaleTo(math.random(20, 35) / 10)
						clone3.PrimaryPart.Attach1.Position = clone3.PrimaryPart.Attach1.Position + Vector3.new(
							0,
							math.random(-15, -5),
							0
						)

						for _, descendant in pairs(clone3:GetDescendants()) do
							if descendant:IsA("ParticleEmitter") then
								local v3 = descendant
								task.spawn(function()
									if v3:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v3:GetAttribute("EmitDelay"))
									end

									v3:Emit(v3:GetAttribute("EmitCount"))
								end)
							elseif descendant:IsA("Beam") then
								local tween = TweenService:Create(descendant, TweenInfo.new(0.15), {
									Width0 = descendant.Width0,
									Width1 = descendant.Width1
								})
								descendant.Width0 = 0
								descendant.Width1 = 0
								tween:Play()
								descendantsByDescendant[descendant] = descendant
							elseif descendant:IsA("Attachment") and descendant.Name == "Attach1" then
								local tween = TweenService:Create(descendant, TweenInfo.new(0.15), {
									Position = descendant.Position
								})
								descendant.Position = createVector(0, 0, 0)
								tween:Play()
							end
						end
					end)
				end

				task.wait(0.1)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
		task.spawn(function()
			if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
				ScreenEffectExecute(folder)
			end
		end)
		task.spawn(function()
			task.wait(1)
			local clone2 = Z.FinisherPhase.BurnModel:Clone()
			clone2.PrimaryPart.CFrame = grabTarget.CFrame
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.885)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false

				if emitter.Parent.Name == "Fire4" then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local parent = grabTarget.Parent
			local v3 = {}

			for _, child in pairs(parent:GetChildren()) do
				if child:IsA("BasePart") and v[child.Name] then
					v3[child] = {
						pos = child.Position,
						speed = math.random(5, 15) / 10,
						distance = math.random(50, 70),
						x = math.random() * 3.141592653589793 * 2,
						y = math.random() * 3.141592653589793 * 2,
						z = math.random() * 3.141592653589793 * 2
					}
					child.Color = Color3.new()
					local clone3 = clone2.Fire4.Particle_1:Clone()
					local clone4 = clone2.Fire4.Particle_3:Clone()
					clone3.Parent = child
					clone4.Parent = child
					clone3.Enabled = true
					clone4.Enabled = true
					clone3.Rate *= 3
					clone4.Rate *= 3
					local v4 = child
					task.delay(v3[child].speed - 0.1, function()
						TweenService:Create(v4, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						task.wait(0.05)
						clone3.Enabled = false
						clone4.Enabled = false
					end)
				elseif child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors") then
					child:Destroy()
				end
			end

			local lastTime = tick()
			local position = root.Position

			if not parent:FindFirstChild("AntiMover") then
				task.spawn(function()
					while tick() - lastTime < 1.5 do
						local v4 = tick() - lastTime
						local v5 = math.clamp(v4 / 1.5, 0, 1)

						for k, v6 in pairs(v3) do
							local unit = (k.Position - position).Unit
							k.CFrame = CFrame.new(v6.pos + unit * v5 * v6.distance * v6.speed) * CFrame.Angles(
								v6.x + v4,
								v6.y + v4,
								v6.z + v4
							)
						end

						RunService.PreSimulation:Wait()
					end
				end)
			end
		end)
		task.wait(1.7)

		for _, v3 in pairs(descendantsByDescendant) do
			local v4 = v3
			task.spawn(function()
				local tween = TweenService:Create(
					v4,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v4:Destroy()
			end)
		end

		task.wait(0.185)
		local v3 = startCFrame * CFrame.new(0, 0, 10)
		local clone2 = Z.FinisherPhase.SlashModel:Clone()
		clone2.PrimaryPart.CFrame = v3 * CFrame.Angles(2.356194490192345, 0.8726646259971648, -0.5235987755982988)
		clone2.Parent = folder
		clone2:ScaleTo(1.5)
		task.spawn(function()
			for _, beam in pairs(clone2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				local startDelay = beam:GetAttribute("StartDelay")
				local v4 = beam
				local v5 = beam:GetAttribute("EndDelay")
				task.spawn(function()
					local tween = TweenService:Create(
						v4,
						TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = v4.Width0,
							Width1 = v4.Width1
						}
					)
					v4.Width0 = 0
					v4.Width1 = 0
					task.wait(startDelay)
					tween:Play()
					task.wait(v5)
					local tween2 = TweenService:Create(
						v4,
						TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v4:Destroy()
				end)
			end
		end)
		TweenService:Create(clone2.PrimaryPart, TweenInfo.new(0.25), {
			CFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(-1.7453292519943295, 0, 0)
		}):Play()
		local clone3 = Z.FinisherPhase.SlashHit:Clone()
		clone3.CFrame = v3 * CFrame.new(0, 0, -30)
		clone3.Parent = folder

		if game.Players.LocalPlayer.Character == character or game.Players.LocalPlayer.Character == grabTarget.Parent then
			Effect.new("ShakeCam"):play({
				14,
				46,
				0.1,
				1,
				createVector(1, 1, 1),
				createVector(1, 1, 2)
			})
		end

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end
	end
end