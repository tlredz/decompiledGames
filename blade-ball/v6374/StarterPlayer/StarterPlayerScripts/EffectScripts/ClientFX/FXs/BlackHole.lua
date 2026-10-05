local createVector = vector.create
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local CameraShaker = require(ReplicatedStorage.ClientGameModules.CameraShaker)
local FastUtils = require(shared.FastUtils)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)

local function isAlive(p)
	return p and p.Parent
end

local v = Replion.Client:WaitReplion("Data")
local v2 = {}
local BlackHole = {
	SpawnBlackHoleSpawn = function(self, instance, instance2, cframe)
		local WAIT_INTERVAL = 0.08
		local WAIT_INTERVAL_2 = 0.1

		if not instance then
			return
		end

		local v3 = localPlayer.Character and localPlayer.Character.Parent == workspace.Alive
		local maid = Trove.new()
		local maid2 = Trove.new()
		local flag = true
		maid:Add(function()
			flag = false
			task.wait(1.15)
			maid2:Clean()
		end)

		v2[instance] = function()
			maid:Destroy()
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		instance:PivotTo(cframe)

		for _, part in instance:GetChildren() do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		local center = instance:FindFirstChild("Center")
		local glassPart = instance:FindFirstChild("GlassPart")
		local outlinePart = instance:FindFirstChild("OutlinePart")
		local motor6D = glassPart and glassPart.Parent and glassPart:FindFirstChild("Motor6D")

		if motor6D then
			motor6D.C1 = CFrame.identity + createVector(0, 1000000, 0)
		end

		local colorCorrectionEffect, colorCorrectionEffect2, bloomEffect

		if v3 then
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = currentCamera
			maid2:Add(colorCorrectionEffect)
			colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect2.Parent = currentCamera
			maid2:Add(colorCorrectionEffect2)
			bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Intensity = 1
			bloomEffect.Size = 0
			bloomEffect.Threshold = 4
			bloomEffect.Parent = currentCamera
			maid2:Add(bloomEffect)
		else
			colorCorrectionEffect2 = nil
			colorCorrectionEffect = nil
		end

		local position = cframe.Position
		local attachment = center:FindFirstChildWhichIsA("Attachment")

		if attachment then
			for _, emitter in attachment:GetChildren() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				local v4 = emitter
				task.delay(emitter:GetAttribute("EmitDuration") or 1, function()
					if v4 and v4.Parent then
						v4.Enabled = false
					end
				end)
			end
		end

		local v4 = nil
		local flag2 = false

		if v3 then
			v4 = CameraShaker.new(Enum.RenderPriority.Last.Value + 1, function(p)
				if not flag then
					return
				end

				if instance and instance.Parent then
					local position2 = currentCamera.CFrame.Position
					local vector2 = Vector2.new(position2.X - position.X, position2.Z - position.Z)

					if vector2.Magnitude > 0.1 then
						local v6 = math.atan2(vector2.X, vector2.Y)
						local v7 = CFrame.new(position) * CFrame.Angles(0, v6, 0) * CFrame.Angles(
							0.2617993877991494,
							0,
							0
						)
						pcall(function()
							instance:PivotTo(v7)
						end)
					end
				end

				if flag2 then
					local v6 = math.clamp(
						1 - ((currentCamera.CFrame.Position - position).Magnitude - 20) / 230,
						0.33,
						1
					)
					p = p:Lerp(CFrame.new(), 1 - v6)

					if humanoidRootPart and humanoidRootPart.Parent then
						local v7 = 1 - math.clamp(
							((humanoidRootPart.CFrame.Position - position).Magnitude - 20) / 130,
							0,
							1
						)
						colorCorrectionEffect2.Brightness = v7 * -0.04
						colorCorrectionEffect2.Saturation = v7 * -0.5
						colorCorrectionEffect2.Contrast = v7 * 0.3
					else
						colorCorrectionEffect2.Brightness = 0
						colorCorrectionEffect2.Saturation = 0
						colorCorrectionEffect2.Contrast = 0
					end
				else
					colorCorrectionEffect2.Brightness = 0
					colorCorrectionEffect2.Saturation = 0
					colorCorrectionEffect2.Contrast = 0
				end

				if flag then
					currentCamera.CFrame *= p
				end
			end)
			maid:Add(function()
				if v4 then
					v4:StopSustained(3)
					task.delay(2, function()
						v4:Stop()
					end)
				end
			end)
			v4:Start()
			local cameraShakeInstance = CameraShaker.CameraShakeInstance.new(1, 4, 3, 3)
			cameraShakeInstance.PositionInfluence = createVector(0.5, 0.5, 0.5)
			cameraShakeInstance.RotationInfluence = createVector(1, 1, 1)
			v4:Shake(cameraShakeInstance)
			ReplicatedStorage.Remotes.ResetFOV:Fire()
			FastUtils.fastTween(
				colorCorrectionEffect,
				TweenInfo.new(4.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Brightness = 0.25
				}
			)
			FastUtils.fastTween(
				currentCamera,
				TweenInfo.new(3.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, true),
				{
					FieldOfView = 90
				}
			)
			task.delay(4.5, function()
				if colorCorrectionEffect and colorCorrectionEffect.Parent then
					FastUtils.fastTween(
						colorCorrectionEffect,
						TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					)
				end
			end)
		end

		task.wait(6.25)

		if not (flag and instance and instance.Parent) then
			return
		end

		if v3 then
			FastUtils.fastTween(
				currentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					FieldOfView = 20
				}
			)
			local cameraShakeInstance = CameraShaker.CameraShakeInstance.new(8, 10, 0.5, 1.25)
			cameraShakeInstance.PositionInfluence = createVector(0.5, 0.5, 0.5)
			cameraShakeInstance.RotationInfluence = createVector(0.1, 0.1, 0.1)
			task.delay(0.98, function()
				if flag and instance and instance.Parent then
					flag2 = true
					local cameraShakeInstance2 = CameraShaker.CameraShakeInstance.new(0.25, 7, 3, 0)
					cameraShakeInstance2.PositionInfluence = createVector(0.5, 0.5, 0.5)
					cameraShakeInstance2.RotationInfluence = createVector(1, 1, 1)
					v4:ShakeSustain(cameraShakeInstance2)
				end
			end)

			if flag then
				v4:Shake(cameraShakeInstance)
			end

			if bloomEffect and bloomEffect.Parent then
				FastUtils.fastTween(bloomEffect, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Size = 56,
					Threshold = 0.1
				})
			end
		end

		if center and center.Parent then
			FastUtils.fastTween(center, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Transparency = 0
			})
		end

		task.wait(WAIT_INTERVAL_2)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			FastUtils.fastTween(colorCorrectionEffect, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Brightness = 0.25,
				Contrast = 3
			})
		end

		task.wait(WAIT_INTERVAL_2)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = -0.5
			colorCorrectionEffect.Contrast = 10
			colorCorrectionEffect.Saturation = -1
		end

		if glassPart and glassPart.Parent then
			glassPart.Motor6D.C1 = CFrame.identity
			glassPart.Transparency = 4
		end

		if instance and instance.Parent then
			for _, part in instance:GetChildren() do
				if part:IsA("BasePart") then
					part.Transparency = 0
				end
			end

			instance:ScaleTo(0.001)
			FastUtils.fastScaleToTween(instance, TweenInfo.new(2, Enum.EasingStyle.Elastic), 1, nil, 0)
		end

		task.delay(0.7, function()
			if glassPart and glassPart.Parent then
				local size = glassPart.Size
				FastUtils.fastTween(
					glassPart,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						Size = size * 1.125
					}
				)
			end

			while flag do
				if not (instance and instance.Parent) then
					break
				end

				if not (outlinePart and outlinePart.Parent and outlinePart:FindFirstChild("Motor6D")) then
					break
				end

				if not (glassPart and glassPart.Parent and glassPart:FindFirstChild("Motor6D")) then
					break
				end

				outlinePart.Motor6D.C1 *= CFrame.Angles(0, 0.05235987755982989, 0)
				glassPart.Motor6D.C1 *= CFrame.Angles(0, 0.0017453292519943296, 0)
				task.wait()
			end
		end)
		task.wait(WAIT_INTERVAL)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = 0.25
			colorCorrectionEffect.Contrast = 5
		end

		task.wait(WAIT_INTERVAL_2)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = -1
			colorCorrectionEffect.Contrast = 4
		end

		task.wait(WAIT_INTERVAL)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = 0.25
			colorCorrectionEffect.Contrast = 5
		end

		if v3 then
			FastUtils.fastTween(
				currentCamera,
				TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					FieldOfView = 58
				}
			)
		end

		task.wait(WAIT_INTERVAL_2)

		if v3 and instance2 and instance2.Parent then
			local clouds = workspace.Terrain:FindFirstChildWhichIsA("Clouds")
			instance2.Parent = Lighting
			Lighting.SunRays.Enabled = false

			if clouds then
				clouds.Enabled = false
			end

			maid2:Add(function()
				Lighting.SunRays.Enabled = true

				if clouds then
					clouds.Enabled = true
				end
			end)
		end

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = -1
			colorCorrectionEffect.Contrast = 4
		end

		task.wait(WAIT_INTERVAL)

		if v3 and bloomEffect and bloomEffect.Parent then
			FastUtils.fastTween(bloomEffect, TweenInfo.new(10, Enum.EasingStyle.Sine), {
				Size = 0,
				Threshold = 4
			})
		end

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = 0.25
			colorCorrectionEffect.Contrast = 5
		end

		if v3 then
			FastUtils.fastTween(
				currentCamera,
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					FieldOfView = 63
				}
			)
		end

		task.wait(WAIT_INTERVAL_2)

		if v3 and colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect.Saturation = 0
		end

		local function clean()
			maid:Clean()
			local v5 = localPlayer.Character and localPlayer.Character.Parent == workspace.Alive
			local colorCorrectionEffect3

			if v5 then
				colorCorrectionEffect3 = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect3.Parent = currentCamera
				Debris:AddItem(colorCorrectionEffect3, 1.5)
				FastUtils.fastTween(
					colorCorrectionEffect3,
					TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Brightness = 5
					}
				)
				FastUtils.fastTween(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FieldOfView = 30
				})
			end

			task.wait(0.65)

			if instance2 and instance2.Parent then
				instance2:Destroy()
			end

			if instance and instance.Parent then
				instance:Destroy()
			end

			if v5 then
				local fieldOfView = 70 + ((v:Get("Settings.Misc.FOV.Current") or 0) - 50) / 2.5
				FastUtils.fastTween(
					colorCorrectionEffect3,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				)
				FastUtils.fastTween(
					currentCamera,
					TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = fieldOfView
					}
				)
			end
		end

		v2[instance] = clean
	end,
	DespawnBlackHoleSpawn = function(self, p)
		if v2[p] then
			v2[p]()
			v2[p] = nil
		end
	end
}
local renderSteppedConnection = nil

function BlackHole:HandleBlackHole(p, p2, p3)
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if not p then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoidRootPart or not humanoid or character.Parent ~= workspace.Alive then
		return
	end

	local v3 = p3 >= 2 and 36 or p3 == 1 and 27 or 18
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if humanoidRootPart.Parent and humanoid.Parent and not (humanoid.Health <= 0) and character.Parent == workspace.Alive then
			local v4 = (p2 - humanoidRootPart.Position) * createVector(1, 0, 1)
			local magnitude = v4.Magnitude

			if magnitude < 350 and magnitude > 8 then
				local v5 = math.map(magnitude, 0, 150, 1, 0.75)
				local v6 = math.max(0, v3 * dt * v5)
				local v7 = v4.Unit * v6
				humanoidRootPart.CFrame += Vector3.new(v7.X, 0, v7.Z)
			end
		elseif renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end)
end

function BlackHole:Execute(p: string, ...)
	if p == "SpawnBlackHoleSpawn" then
		self:SpawnBlackHoleSpawn(...)
	elseif p == "DespawnBlackHoleSpawn" then
		self:DespawnBlackHoleSpawn(...)
	elseif p == "HandleBlackHole" then
		self:HandleBlackHole(...)
	end
end

return BlackHole