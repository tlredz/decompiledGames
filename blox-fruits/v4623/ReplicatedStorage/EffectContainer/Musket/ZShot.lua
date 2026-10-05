local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local musket_Z = FX:WaitForChild("Musket").Musket_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local startCFrame = data.startCFrame
	local targetPos = data.targetPos

	if data.stage == 1 then
		local _ = data.hrp
		local _ = data.maxRange
		local projectileSpeed = data.projectileSpeed
		local folder = Instance.new("Folder")
		folder.Name = "MusketZ1"
		folder.Parent = _WorldOrigin
		local clone = musket_Z.Start:Clone()
		clone.CFrame = startCFrame
		clone.Parent = folder

		if data.hrp == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			Effect.new("ShakeCam"):play({
				8,
				12,
				0.05,
				0.2
			})
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("BF_WPN_Musket_Z_Fire_01", clone.Position)
		local clone2 = musket_Z.FirstProjectile:Clone()
		clone2.CFrame = startCFrame
		clone2.Parent = folder
		TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		local v = data.distance / projectileSpeed
		TweenService:Create(clone2, TweenInfo.new(v, Enum.EasingStyle.Linear), {
			Position = targetPos
		}):Play()
		task.wait(v)
		local clone3 = musket_Z.Projectilebreak:Clone()
		clone3.CFrame = clone2.CFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1)
		folder:Destroy()
	elseif data.stage == 2 then
		local halfpoint = data.halfpoint
		local curveHeight = data.curveHeight
		local curveSize = data.curveSize
		local headtime = data.headtime
		local folder = Instance.new("Folder")
		folder.Name = "MusketZ2"
		folder.Parent = _WorldOrigin
		Util.Sound:Play("BF_WPN_Musket_Z_Explosion_01", targetPos)

		for i = 1, 3 do
			local v = i
			task.spawn(function()
				local clone = musket_Z.DragonHead:Clone()
				local position = halfpoint
				local v4 = halfpoint + startCFrame.RightVector * (v - 2) * curveSize + startCFrame.UpVector * curveHeight
				local position2 = targetPos
				clone.Position = position
				clone.Parent = folder
				local lastTime = tick()
				local headtime2 = headtime
				local v7 = position

				while tick() - lastTime < headtime2 do
					local v8 = (tick() - lastTime) / headtime2
					local v9 = position + (v4 - position) * v8
					local v10 = v9 + (v4 + (position2 - v4) * v8 - v9) * v8

					if v7 ~= position then
						clone.CFrame = CFrame.lookAt(v10, v7) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					task.wait()
					v7 = v10
				end

				clone.Position = position2

				for i2, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for i2, weld in clone:GetDescendants() do
					if weld:IsA("Weld") then
						weld:Destroy()
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
			end)
		end

		task.wait(headtime)
		local clone = musket_Z.Explode:Clone()
		local rayMap, v, v2 = Util.RayMap(targetPos, createVector(0, -5, 0))

		if rayMap then
			CFrame.lookAt(v, v + v2)
			clone.CFrame = CFrame.lookAt(v, v + v2)
			local clone2 = musket_Z.FloorFire:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Parent = folder
			task.delay(2, function()
				local folder2 = clone2

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		else
			clone.Position = targetPos
		end

		clone.Parent = folder

		if (currentCamera.CFrame.Position - clone.Position).Magnitude <= 90 then
			local clone2 = musket_Z.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			Effect.new("ShakeCam"):play({
				20,
				10,
				0.1,
				0.5
			})
			task.delay(0.3, clone2.Destroy, clone2)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(2.5)
		folder:Destroy()
	end
end