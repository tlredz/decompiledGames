local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local WeaponData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponData"))
local v = WeaponData[script.Name]
local Sound = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local rock2 = Util.Rock2
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bazooka_M1 = FX:WaitForChild("Gun_M1").Bazooka_M1
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

return function(data)
	if (data.origin - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local HRP = data.HRP
	local child = HRP.Parent:FindFirstChild("EquippedWeapon") and HRP.Parent.EquippedWeapon:FindFirstChild(
		data.ShootAttachment,
		true
	)

	if not child then
		return
	end

	if data.Stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "GunM1Effect"
		folder.Parent = _WorldOrigin
		local clone = bazooka_M1.Shoot:Clone()
		clone.CFrame = HRP.CFrame * CFrame.new(0, 0, -3)
		clone.Position = child and child.WorldPosition or clone.Position
		clone.Parent = folder
		local fireSound = v.FireSound

		if fireSound then
			Sound:Play("Guns." .. fireSound, clone.Position)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = bazooka_M1.Projectile:Clone()
		clone2.CFrame = data.Start
		clone2.Parent = folder
		clone2.Anchored = false
		local v2 = workspace:GetServerTimeNow() - data.Timestamp
		local v3 = data.Velocity.Magnitude / (1 - v2)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(9000000000, 9000000000, 9000000000)
		bodyVelocity.Velocity = data.Velocity.Unit * v3
		bodyVelocity.Parent = clone2
		local v4 = "__UnidentifiedProjectile" .. script.Name .. data.Shooter.Name
		local proxy = data.Proxy

		while proxy and proxy.Parent and not proxy:GetAttribute("Exploding") and data.Proxy.Parent do
			local child2 = workspace._WorldOrigin.PersistentParts:FindFirstChild(v4)

			if child2 then
				child2.Name = "Projectile"
				proxy = child2
			end

			if proxy:GetAttribute("ServerTimestamp") then
				local v5 = workspace:GetServerTimeNow() - proxy:GetAttribute("ServerTimestamp")
				local v6 = data.Velocity.Magnitude / (1 - v5)
				bodyVelocity.Velocity = data.Velocity.Unit * v6
				proxy:SetAttribute("ServerTimestamp", nil)
			end

			task.wait()
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone2.Transparency = 1
		TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(2)
		folder:Destroy()
	elseif data.Stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "GunM1Effect"
		folder.Parent = _WorldOrigin
		local clone = bazooka_M1.Impact:Clone()
		clone.Position = data.origin
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if data.Normal then
			task.spawn(function()
				local v2 = math.random(3, 6)
				local v3 = data.ExplodePos + data.Normal

				for i = 1, v2 do
					local v4 = 360 / v2 * i
					local v5 = CFrame.new(v3, v3 + data.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						math.rad(v4),
						0
					) * CFrame.new(0, 0, -15)
					local ray, v6, v7 = Util.Ray(
						v5.Position,
						v5.upVector.Unit * -30,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if not ray then
						continue
					end

					local v8 = rock2.new({
						FadeIn = { 0.3, 0.6 },
						Lifetime = math.random(5, 15) / 10,
						FadeOut = { 0.4, 0.5 },
						Type = "Flying",
						Size = Vector3.new(math.random(2, 3), 2, math.random(2, 3)),
						Scale = { 1, 2 }
					})
					v8:Spawn(CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0))
					v8:Eject({
						Velocity = v5.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v8.Part.CFrame.lookVector * math.random(
							10,
							20
						),
						RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
					})
				end
			end)
		end

		if (workspace.CurrentCamera.CFrame.p - clone.CFrame.Position).Magnitude < 90 then
			local clone2 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			Util.CameraShaker:ShakeOnce(16, 16, 0.1, 0.25)
			task.delay(0.25, clone2.Destroy, clone2)
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		Sound:Play("BF_WPN_Bazooka_Explosion_01", data.origin)
		task.wait(3)
		folder:Destroy()
	end
end