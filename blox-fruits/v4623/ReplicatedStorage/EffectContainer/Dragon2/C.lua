local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local rock2 = Util.Rock2
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Dragon2").C
local partCache = Util.PartCache
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function charInRange(p, p2)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraInRange(p, p2)
	return (workspace.CurrentCamera.CFrame.p - p).Magnitude < p2
end

local function scaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local waterBasePlanes = { workspace.Characters, workspace.Enemies }
local waterBasePlane = nil
task.spawn(function()
	waterBasePlane = workspace.Map:WaitForChild("WaterBase-Plane", 9999)
	table.insert(waterBasePlanes, waterBasePlane)
end)
local v = 0
return function(instance)
	local ID = instance.ID
	local player = instance.player

	if ID == 1 then
		local position = instance.Position
		local root = instance.Root

		if root then
			Util.Sound:Play("BF_V3_Dragon_C_Activate_03", root)

			if root.Parent == game.Players.LocalPlayer.Character then
				root.Velocity = createVector(0, 150, 0)
			end

			if not cameraInRange(position, 750) then
				return
			end

			local _, v2, _ = Util.Ray(
				position,
				CFrame.new(position).UpVector.Unit * -15,
				{ workspace.Characters, workspace.Enemies }
			)
			Util.Sound:Play("BF_V3_Dragon_C_Activate_03", root)
			Util.Sound:Play("SetFire2", v2, nil, 1.2 + math.random(-10, 10) / 100, 1, 5)
			local _ = v2 + createVector(0, 1, 0)
			task.spawn(function()
				local clone = C.ShockwaveMesh:Clone()
				debris:AddItem(clone, 2)
				clone.Color = Util.WrapColor3Constructor(Color3.fromRGB(255, 184, 126), player, "DragonFruitVFXColor")
				clone.CFrame = CFrame.new(v2) * CFrame.new(0, 12, 0)
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DragonFruitVFXColor")
				local cFrame = clone.CFrame
				local lastTime = tick()
				local v3 = 0.016666666666666666

				while tick() - lastTime < 0.16666666666666666 do
					local v4 = v3 * 60
					local v5 = (tick() - lastTime) / 0.16666666666666666
					local _ = v5 * 60
					clone.Size = createVector(5, 20, 5) + createVector(45, -19, 45) * v5
					clone.CFrame = cflerp(
						cFrame,
						cFrame * CFrame.new(0, -12, 0) * CFrame.Angles(0, math.rad(v4 * 60), 0),
						v5
					)
					v3 = RunService.RenderStepped:Wait()
				end

				if clone then
					clone:Destroy()
				end
			end)
			local clone = C.Jump:Clone()
			debris:AddItem(clone, 3)
			clone.CFrame = CFrame.new(v2)

			if not root.Parent:FindFirstChild("DragonHybrid") then
				clone.Attachment3:Destroy()
			end

			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DragonFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = C.RisingTrail:Clone()
			debris:AddItem(clone2, 2)
			local clone3 = C.RisingTrail:Clone()
			debris:AddItem(clone3, 2)
			clone2.Position = position
			clone3.Position = position
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "DragonFruitVFXColor")
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "DragonFruitVFXColor")
			local cframe = CFrame.new(position)
			local lastTime = tick()
			local v3 = 0.016666666666666666

			while tick() - lastTime < 0.25 do
				local v4 = v3 * 60
				local _ = (tick() - lastTime) / 0.25 * 60
				cframe = cframe * CFrame.new(0, v4 * 3, 0) * CFrame.Angles(0, math.rad(v4 * 30), 0)
				clone2.CFrame = cframe * CFrame.new(0, 0, -10)

				for _, v5 in pairs({ clone2, clone3 }) do
					for _, child in pairs(v5.FX:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				clone3.CFrame = cframe * CFrame.new(0, 0, 10)
				v3 = RunService.RenderStepped:Wait()
			end

			for _, v4 in pairs({ clone2, clone3 }) do
				if not v4 then
					continue
				end

				v4.TrailLarge.Enabled = false
				v4.TrailSmall.Enabled = false
			end

			task.delay(0.5, function()
				for _, v5 in pairs({ clone2, clone3 }) do
					if v5 then
						v5:Destroy()
					end
				end
			end)
		end
	elseif ID == 2 then
		local root = instance.Root
		local holding = instance.Holding
		local mouse = instance.Mouse
		local humanoid = instance.Humanoid

		if root and holding and mouse and humanoid then
			if not cameraInRange(root.Position, 900) then
				return
			end

			local timestamp = instance.Timestamp
			local life = instance.Life
			local dist = instance.Dist
			local devi = instance.Devi
			local _ = instance.Dely
			local _ = masterClock:GetTime() - timestamp
			local folder = Instance.new("Folder")
			Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
			Util.Debris:AddItem(folder, 13)
			local clone = C.Explosion:Clone()
			local v2 = partCache.new(clone, 25)
			v2:SetCacheParent(folder)

			local function explosionEffect(folder2, position2, p, instance2, clone2, clone3, emittersByEmitter, items)
				local magnitude = (workspace.CurrentCamera.CFrame.p - position2).Magnitude

				if magnitude <= 250 then
					local v3 = math.min(1, (250 - magnitude) / 250)
					Util.CameraShaker:ShakeOnce(v3 * 4, v3 * 8, v3 * 0.4, v3 * 0.2)
				end

				local part = v2:GetPart()
				Util.ColorShiftObjectDescendants(part, player, "DragonFruitVFXColor")
				part.CFrame = CFrame.new(position2)

				if p ~= createVector(0, 1, 0) then
					part.CFrame = CFrame.new(position2, position2 + p) * CFrame.Angles(-1.5707963267948966, 0, 0)
				end

				part.Ground.ScorchLayer.Lifetime = NumberRange.new(4.3991999999999996, 5.865600000000001)
				Util.SetParentOverrideWithColor(part, folder2, player, "DragonFruitVFXColor")
				Util.Sound:Play("CannonFire", position2, nil, 1.1 + math.random(-10, 10) / 100, 0.4)

				if instance2 and instance2:IsDescendantOf(workspace.Map) then
					local v3 = Util.Sound:Play(
						"BF_V3_Dragon_C_Mini_Explosion_0" .. tostring(math.random(1, 4)),
						position2
					)
					part.FireRise.Enabled = true
					task.delay(0.566 * (math.random() * 0.5 + 1), function()
						Util.Sound:FadeOut(v3, 0.333)
						part.FireRise.Enabled = false
						v2:ReturnPart(part)
					end)

					for _, child in pairs(part.Ground:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				for _, child in pairs(part.Raised:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				clone2.CFrame = part.CFrame
				clone3.CFrame = part.CFrame

				for _, item in pairs(emittersByEmitter) do
					item:Emit(item:GetAttribute("EmitCount"))
				end

				if items ~= nil then
					for _, item in pairs(items) do
						item:Emit(item:GetAttribute("EmitCount"))
					end
				end
			end

			local clone2 = C.Projectile:Clone()
			local v3 = partCache.new(clone2, 25)
			v3:SetCacheParent(folder)
			local clone3 = C.ExplosionTrail:Clone()
			local v4 = partCache.new(clone3, 25)
			v4:SetCacheParent(folder)
			local clone4 = C.ShootImpact:Clone()

			if not instance.Hybrid then
				clone4.Attachment2:Destroy()
			end

			Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")
			local emittersByEmitter = {}

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emittersByEmitter[emitter] = emitter
				end
			end

			local clone5 = C.Explosion2:Clone()

			if not instance.Hybrid then
				clone5.Attachment:Destroy()
				clone5.Attachment2:Destroy()
			end

			Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "DragonFruitVFXColor")
			local clone6 = C.Smoke:Clone()
			Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "DragonFruitVFXColor")
			local emittersByEmitter2 = {}
			local emittersByEmitter3 = {}
			local emittersByEmitter4 = {}

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Parent.Name == "Attachment" then
					emittersByEmitter4[emitter] = emitter
				elseif emitter.Parent.Name == "Attachment2" then
					emittersByEmitter3[emitter] = emitter
				else
					emittersByEmitter2[emitter] = emitter
				end
			end

			for _, emitter in pairs(clone6:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emittersByEmitter2[emitter] = emitter
				end
			end

			local v5 = _G.FastMode and 25 or 50

			local function CreateRocks(_, p, p2)
				if not ziggy12 then
					return
				end

				local v6 = p + createVector(0, 1, 0)

				for _ = 1, 1 do
					if v5 <= v and math.random() > 0.1 then
						continue
					end

					local v7 = math.random() * 360
					local v8 = CFrame.new(v6, v6 + p2 * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						math.rad(v7),
						0
					) * CFrame.new(0, 0, -20)
					local ray, v9, v10 = Util.Ray(v8.Position, v8.upVector * -30, waterBasePlanes)

					if not ray then
						continue
					end

					v += 1
					task.delay(2, function()
						v -= 1
					end)
					local vector2 = Vector3.new(math.random(3, 4), 2, math.random(3, 4))
					local v11 = rock2.new({
						FadeIn = { 0.1, 0.2 },
						Lifetime = 4 * math.random(10, 15) / 10,
						FadeOut = { 0.25, 0.35 },
						Size = vector2,
						Scale = { 1, 2 }
					})
					v11:Spawn(CFrame.new(v9, v9 + v10) * CFrame.Angles(-1.5707963267948966, 0, 0), 0.75)

					if not (math.random(1, 100) <= (instance.Hybrid and 70 or 60) * 0.9) then
						continue
					end

					local part = v4:GetPart()
					Util.ColorShiftObjectDescendants(part, player, "DragonFruitVFXColor")
					part.Color = v11.Part.Color
					part.Material = v11.Part.Material
					part.Size = vector2 * (math.random() + 1)
					part.Anchored = false
					part.Transparency = 0
					part.Velocity = v8.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v11.Part.CFrame.lookVector * math.random(
						10,
						20
					) * 6
					part.RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
					part.Position = v8.Position:Lerp(v9, 0.5) + createVector(0, 1, 0) * vector2.Magnitude * 1.333

					for _, emitter in pairs(part:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					if instance.Hybrid then
						part.Size *= 1.1
						part.Velocity *= 1.1
						local v12 = part
						task.delay((1.75 + math.random() * 1.25) * 0.666 * 0.666, function()
							v12.Zaps1.Enabled = false
						end)
					else
						part.Zaps1.Enabled = false
					end

					Util.SetParentOverrideWithColor(part, folder, player, "DragonFruitVFXColor")
					part.Color = v11.Part.Color
					rocks:ApplyCollision(part, nil, true)
					task.spawn(function()
						task.wait((1.75 + math.random() * 1.25) * 0.666)

						for i, emitter in pairs(part:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						TweenService:Create(part, TweenInfo.new(0.5), {
							Size = createVector(0.01, 0.01, 0.01)
						}):Play()
						task.wait(0.5)
						part.Transparency = 1
						part.Anchored = true
						v4:ReturnPart(part)
					end)
				end
			end

			local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
			local v6 = {}
			local v7 = true
			task.spawn(function()
				local v8 = { root.Parent }
				local now = 0

				while v7 == true do
					for k, v9 in pairs(v6) do
						local v10 = math.min(1, (tick() - v9[3]) / life)
						v9[5] = v9[1].CFrame * cframe
						local v11 = v9[9]
						local v12 = cubicBezier(v10, v11[1].p, v11[2].p, v11[3].p, v11[4].p)
						v9[1].CFrame = CFrame.new(v12, v9[5].p) * cframe

						if tick() - now > 0.015151515151515152 then
							now = tick()

							for k2, v13 in pairs(v9[8]) do
								k2:Emit(v13)
							end
						end

						v9[6] = (v9[5].p - v9[1].Position).Magnitude
						local ray, v13, v14 = Util.Ray(v9[5].p, v9[5].lookVector * v9[6], v8, false)

						if not (ray or v10 >= 1) then
							continue
						end

						if not ray then
							v13 = v9[4] * Vector3.new(0, 0, -dist)
							v14 = -v9[4].lookVector
						end

						local v15 = nil

						if instance.Hybrid then
							local v16 = math.random(1, 3)

							if v16 == 1 then
								v15 = emittersByEmitter4
							elseif v16 == 2 then
								v15 = emittersByEmitter3
							end
						end

						explosionEffect(folder, v13, v14, ray, clone5, clone6, emittersByEmitter2, v15)
						v9[1].Transparency = 1
						table.remove(v6, k)
						local v16 = v9
						task.delay(0.4, function()
							v16[1].TrailLarge.Enabled = false
							v16[1].TrailSmall.Enabled = false
							task.wait()
							v3:ReturnPart(v16[1])
						end)

						if ray and ray:IsDescendantOf(workspace.Map) then
							CreateRocks(ray, v13, v14)
						end
					end

					RunService.RenderStepped:Wait()
				end

				debris:AddItem(clone5, 3)
				debris:AddItem(clone6, 3)
			end)
			local diedConnection = nil
			diedConnection = humanoid.Died:Connect(function()
				diedConnection:Disconnect()
				diedConnection = nil
			end)
			local lastTime = tick()
			local v8 = tick() + 0.1
			local now = tick() - 1
			local v9 = Util.Sound:Play("BF_V3_Dragon_C_Fire_Loop_01", root.Position)

			while tick() - lastTime <= instance.HoldMax and holding.Parent ~= nil and holding.Parent.Parent ~= nil and (not (tick() - lastTime > instance.HoldMin) or holding.Value ~= false) and humanoid and root do
				if tick() - now > 0.02 then
					local cFrame = CFrame.new(root.Position, mouse.Value) * CFrame.new(0, 0, -(2 + root.Size.Z / 2)) * CFrame.new(
						0,
						0,
						-(2 + root.Size.Z / 2)
					) * CFrame.Angles(
						math.rad((math.random(-devi, devi))),
						math.rad((math.random(-devi, devi))),
						(math.rad((math.random(-devi, devi))))
					)
					clone4.CFrame = cFrame

					for _, v11 in pairs(emittersByEmitter) do
						if v11.Parent.Name ~= "Attachment2" or not (v8 - tick() > 0) then
							v11:Emit(v11:GetAttribute("EmitCount"))
						end
					end

					if v8 - tick() <= 0 then
						v8 = tick() + 0.25
					end

					local part = v3:GetPart()
					Util.ColorShiftObjectDescendants(part, player, "DragonFruitVFXColor")
					local root2 = part.Root
					task.spawn(function()
						part.Transparency = 1
						task.wait(0.01)
						part.Transparency = 0
					end)
					part.CFrame = cFrame * cframe

					if root.Parent:FindFirstChild("DragonHybrid") then
						root2.Lightning.Enabled = true
					else
						root2.Lightning.Enabled = false
					end

					part.TrailSmall.Enabled = true
					part.TrailLarge.Enabled = true
					Util.SetParentOverrideWithColor(part, folder, player, "DragonFruitVFXColor")
					local emitCountsByStreakFlames = {
						[root2.StreakFlames] = root2.StreakFlames:GetAttribute("EmitCount")
					}
					local cframe2 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
					local cframe3 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
					local v12 = cFrame * CFrame.new(0, 0, -dist)
					local v13 = {
						cFrame,
						cFrame:Lerp(v12, 0.3) * cframe2,
						cFrame:Lerp(v12, 0.6) * cframe3,
						cFrame:Lerp(v12, 1)
					}
					table.insert(v6, {
						part,
						root2,
						tick(),
						cFrame,
						cFrame,
						0,
						{ cframe2, cframe3 },
						emitCountsByStreakFlames,
						v13
					})
					now = tick()
				end

				RunService.RenderStepped:Wait()
			end

			if v9 then
				sound:FadeOut(v9, 0.15)
			end

			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			task.delay(1, function()
				v7 = false
			end)
		end
	end
end