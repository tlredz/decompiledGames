local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Attract = FX:WaitForChild("Magnet"):WaitForChild("Z_Attract")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
pcall(function()
	for _, child in scraps:FindFirstChild("ScrapModelA"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ScrapModelA2"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ScrapModelA3"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end
end)
local _WorldOrigin = workspace._WorldOrigin

local function scaleFX(instance, p: number)
	if p == 1 then
		return
	end

	if instance:IsA("Model") then
		instance:ScaleTo(instance:GetScale() * p)
	elseif instance:IsA("BasePart") then
		instance.Size *= p
	end
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

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(position, p, p2, p3)
	return position:Lerp(p, p3):Lerp(p:Lerp(p2, p3), p3)
end

local function EndOrbit(folder, position, value)
	local v = value or 1

	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	folder.Anchored = false
	folder.CanCollide = true
	local unit = (folder.Position - position).Unit
	local vector2 = Vector3.new(math.random(-30, 30) * v, math.random(15, 40) * v, math.random(-30, 30) * v)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = unit * math.random(30, 50) * v + vector2
	bodyVelocity.Parent = folder
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(100000, 100000, 100000)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
	bodyAngularVelocity.Parent = folder
	task.delay(0.25, function()
		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		if bodyAngularVelocity then
			bodyAngularVelocity:Destroy()
		end

		if folder:FindFirstChild("Highlight") then
			folder.Highlight.Enabled = false
		end

		task.wait(1 + math.random() * 0.5)
		TweenService:Create(folder, TweenInfo.new(0.25), {
			Size = createVector(0, 0, 0)
		}):Play()
	end)
end

local function StartOrbit(parent, position, p2, p3, p4, value)
	local v = value or 1
	local unit = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)).Unit
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = p3 * (math.random(80, 140) / 100)

	if math.random() < 0.5 then
		v3 = -v3
	end

	local cross = unit:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.1 then
		cross = unit:Cross(createVector(1, 0, 0))
	end

	local unit2 = cross.Unit
	local v4 = p2
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (parent and parent.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		v2 += v3 * dt
		local model = p4 and p4.Model

		if model then
			if (model:GetAttribute("CurrTime") or 0) - tick() <= 0 then
				heartbeatConnection:Disconnect()
				EndOrbit(parent, position, v)
				return
			else
				position = model.PrimaryPart.Position
			end
		end

		local v5

		if model then
			local baseScale = p4 and p4.BaseScale or v or 1
			v5 = (model:GetScale() or baseScale) / math.max(baseScale, 0.001)
		else
			v5 = 1
		end

		local v6 = p2 * v5
		v4 += (v6 - v4) * math.clamp(dt * 6, 0, 1)
		local vectorToWorldSpace = CFrame.fromAxisAngle(unit, v2):VectorToWorldSpace(unit2 * v4)
		local v7 = position + vectorToWorldSpace
		parent.CFrame = CFrame.new(v7, position)
	end)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Color3.new(1, 0.380392, 0.380392)
	v.ColorOffsetSpeed = 3
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FlyCurve(clone, cFrame, cFrame2, vector2, p, p2, visualScale)
	local v = visualScale or 1
	local position = cFrame.Position
	local position2 = cFrame2.Position
	local v2 = (position + position2) / 2 + vector2
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v3 = (os.clock() - lastTime) / p

		if v3 >= 1 then
			clone.CFrame = cFrame2
			StartOrbit(clone, position2, math.random(12, 15) * 1.5 * v, math.random(7, 9), p2, v)
			heartbeatConnection:Disconnect()
		else
			local quadBezier = QuadBezier(position, v2, position2, v3) -- equivalent call inferred; original call site unknown
			clone.CFrame = CFrame.new(quadBezier)
		end
	end)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(clone, cFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	local v2 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getArmAnim(parent, p: string, p2: string)
	local magnetArms = parent:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
		return
	end

	local child = magnetArms:FindFirstChild("Floating" .. p2 .. "Arm")
	local v = child and Util.Anims:Get(child, p)
	return v or nil
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage
	local visualScale = data.VisualScale or 1

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local root = data.Root

		if not (root and root.Parent) then
			return
		end

		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v

		if magnetArms then
			local floatingLeftArm = magnetArms:FindFirstChild("FloatingLeftArm")
			v = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Z Tap Held L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v2

		if magnetArms2 then
			local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
			v2 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Z Tap Held R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
		local v3

		if magnetArms3 then
			local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
			v3 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Z Tap Start R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v3 then
			v3.Priority = Enum.AnimationPriority.Action2
			v3.Looped = false
			v3:Play()
		end

		local magnetArms4 = root.Parent:FindFirstChild("MagnetArms")
		local v4

		if magnetArms4 then
			local floatingLeftArm = magnetArms4:FindFirstChild("FloatingLeftArm")
			v4 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Z Tap Start L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v4 then
			v4.Priority = Enum.AnimationPriority.Action2
			v4.Looped = false
			v4:Play()
		end

		Util.Sound:Play("Magnet_Untransformed_Z_Gun_Mechanics_Activate_01", root.Position)

		if v and v2 then
			v.Looped = true
			v2.Looped = true
			v:Play()
			v2:Play()
		end

		repeat
			task.wait()
		until not (holding and holding.Value)

		if v and v2 then
			task.wait(0.05)
			v:Stop()
			v2:Stop()
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local root = data.Root
		local startCFrame = data.StartCFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
		local v = {}

		local function MakeBullet(p, i)
			local v2 = {
				Model = nil,
				BaseScale = visualScale
			}
			local v3 = startCFrame[i]
			local value = data.MousePos.Value
			local cFrame = CFrame.new(v3.Position, value) * CFrame.new(0, 0, -3 * visualScale)

			local function getTravelTime(p2)
				return p2 / 333.33333333333337
			end

			local _, v5, _ = Util.Ray(
				cFrame.Position,
				cFrame.LookVector * 200,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			local magnitude = (v5 - cFrame.Position).Magnitude
			local v6 = magnitude / 333.33333333333337
			local clone = scraps.ScrapModelA:Clone()
			clone:ScaleTo(2.5 * visualScale)
			local children = clone:GetChildren()
			local clonesByClone = {}

			for _ = 1, p do
				local clone2 = children[math.random(1, #children)]:Clone()
				clone2.CFrame = cFrame * CFrame.new(
					math.random(-3, 3) * visualScale,
					math.random(-3, 3) * visualScale,
					math.random(-3, 3) * visualScale
				)
				clone2.Parent = folder
				clonesByClone[clone2] = clone2
				local clone3 = z_Attract.Phase1.Highlight:Clone()
				clone3.Parent = clone2
				clone3.Enabled = true
				local clone4 = children[math.random(1, #children)]:Clone()
				clone4.Size *= 0.7
				clone4.Parent = folder
				local clone5 = z_Attract.Phase1.Highlight:Clone()
				clone5.Parent = clone4
				clone5.Enabled = true
				local clone6 = z_Attract.Phase1.AuraModel:Clone()
				clone6.PrimaryPart.Anchored = false
				clone6.PrimaryPart.Weld.Part1 = clone4
				local v7 = visualScale

				if v7 ~= 1 then
					if clone6:IsA("Model") then
						clone6:ScaleTo(clone6:GetScale() * v7)
					elseif clone6:IsA("BasePart") then
						clone6.Size *= v7
					end
				end

				clone6.Parent = clone4
				local vector2 = Vector3.new(
					math.random(-6, 6) * visualScale,
					math.random(-3, 5) * visualScale,
					math.random(-6, 6) * visualScale
				)
				clone4.CFrame = cFrame * CFrame.new(vector2)
				local v8 = magnitude + math.random(-6, 6) * visualScale
				local cFrame2 = cFrame * CFrame.new(vector2) * CFrame.new(0, 0, -v8)
				local vector3 = Vector3.new(
					math.random(-15, 15) * visualScale,
					math.random(-10, 15) * visualScale,
					math.random(-15, 15) * visualScale
				)
				FlyCurve(clone4, clone4.CFrame, cFrame2, vector3, v6 + math.random() * 0.15, v2, visualScale) -- equivalent call inferred; original call site unknown
			end

			local time = v6

			for _, v7 in pairs(clonesByClone) do
				local v8 = magnitude + math.random(-5, 5) * visualScale
				local tweenInfo = TweenInfo.new(
					v6 + math.random() * 0.15,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
				local cFrame2 = v7.CFrame * CFrame.new(0, 0, -v8) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				TweenService:Create(v7, tweenInfo, {
					CFrame = cFrame2
				}):Play()
				local parent = v7
				task.delay(tweenInfo.Time, function()
					StartOrbit(
						parent,
						cFrame2.Position,
						math.random(12, 15) * 1.25 * visualScale,
						math.random(7, 9),
						v2,
						visualScale
					)
				end)

				if time < tweenInfo.Time then
					time = tweenInfo.Time
				end
			end

			local clone2 = z_Attract.Phase1.MainProjectile:Clone()
			local v7 = visualScale

			if v7 ~= 1 then
				if clone2:IsA("Model") then
					clone2:ScaleTo(clone2:GetScale() * v7)
				elseif clone2:IsA("BasePart") then
					clone2.Size *= v7
				end
			end

			clone2:PivotTo(cFrame)
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local tweenInfo = TweenInfo.new(v6 + 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			TweenService:Create(clone2.PrimaryPart, tweenInfo, {
				CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, -magnitude)
			}):Play()
			local clone3 = z_Attract.Phase1.StartImpact:Clone()
			local v8 = visualScale

			if v8 ~= 1 then
				if clone3:IsA("Model") then
					clone3:ScaleTo(clone3:GetScale() * v8)
				elseif clone3:IsA("BasePart") then
					clone3.Size *= v8
				end
			end

			clone3.CFrame = cFrame
			clone3.Parent = folder
			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v9 = emitter
				task.spawn(function()
					if v9:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v9:GetAttribute("EmitDelay"))
					end

					v9:Emit(v9:GetAttribute("EmitCount"))
				end)
			end

			local v9 = false
			task.spawn(function()
				task.wait(0.1)

				local function AlignCFrame(data2, normal)
					local v10 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
					local p2 = data2.p
					local unit = data2.LookVector:Cross(v10).Unit
					local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
					local unit3 = unit2:Cross(v10).Unit
					return CFrame.fromMatrix(p2, unit2, v10, unit3)
				end

				local clone4 = z_Attract.Phase1.GroundBurn:Clone()
				local v10 = visualScale

				if v10 ~= 1 then
					if clone4:IsA("Model") then
						clone4:ScaleTo(clone4:GetScale() * v10)
					elseif clone4:IsA("BasePart") then
						clone4.Size *= v10
					end
				end

				clone4.CFrame = cFrame
				clone4.Parent = folder

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local v11 = 25 * visualScale
				local emitters = {}
				local v12 = false

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				while true do
					local v13 = clone2.PrimaryPart.CFrame * CFrame.new(0, 5 * visualScale, 0)
					local raycastResult = workspace:Raycast(
						v13.Position,
						CFrame.new(v13.Position).UpVector * -v11,
						raycastParams
					)

					if raycastResult then
						clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
						clone4.CFrame = CFrame.new(clone4.Position, clone4.Position + cFrame.LookVector)
						clone4.Orientation = Vector3.new(0, clone4.Orientation.Y, clone4.Orientation.Z)

						if v12 == false then
							v12 = true

							for _, v14 in pairs(emitters) do
								v14.Enabled = true
							end
						end
					elseif v12 == true then
						v12 = false

						for _, v14 in pairs(emitters) do
							v14.Enabled = false
						end
					end

					task.wait(0.1)

					if v9 ~= true then
						continue
					end

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					break
				end
			end)
			local cframe = cFrame * CFrame.new(0, 0, -magnitude)
			task.delay(time, function()
				v9 = true
				local clone4 = z_Attract.Phase2.Explosion:Clone()
				local v10 = visualScale

				if v10 ~= 1 then
					if clone4:IsA("Model") then
						clone4:ScaleTo(clone4:GetScale() * v10)
					elseif clone4:IsA("BasePart") then
						clone4.Size *= v10
					end
				end

				clone4.CFrame = cframe
				clone4.Parent = folder
				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v11 = emitter
					task.spawn(function()
						if v11:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v11:GetAttribute("EmitDelay"))
						end

						v11:Emit(v11:GetAttribute("EmitCount") / 2)
					end)
				end

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local v11 = 30 * visualScale

				if i ~= 1 and next(v) then
					local v12 = 1e999
					local v13 = nil

					for k, v14 in pairs(v) do
						if not (k ~= i and v14 and v14.endCF) then
							continue
						end

						local magnitude2 = (v14.endCF.Position - cframe.Position).Magnitude

						if not (magnitude2 < v12) then
							continue
						end

						v13 = k
						v12 = magnitude2
					end

					if v13 and v12 <= v11 then
						local aura = v[v13].aura
						aura:ScaleTo(aura:GetScale() + 0.25 * visualScale)
						local ray, v14 = Util.Ray(
							cframe.Position + createVector(0, 1, 0),
							createVector(0, 1, 0) * -aura.PrimaryPart.Size.Y / 2,
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						)

						if ray then
							local v15 = v14 + Vector3.new(0, aura.PrimaryPart.Size.Y / 2, 0)
							cframe = CFrame.new(v15, v15 + aura.PrimaryPart.CFrame.LookVector)
							aura:PivotTo(cframe)
						end

						aura:SetAttribute("CurrTime", tick() + 1)
						aura:SetAttribute("Tier", aura:GetAttribute("Tier") + 1)
						local sfx = v[v13].sfx

						if sfx then
							sfx.RollOffMinDistance += 20 * visualScale
						end

						v[i] = {
							aura = aura,
							endCF = cframe,
							sfx = sfx
						}
						v2.Model = aura
						return
					end
				end

				local clone5 = z_Attract.Phase3.MagnetAuraModel:Clone()
				clone5:ScaleTo(clone5:GetScale() * visualScale)
				local primaryPart = clone5.PrimaryPart
				local ray, v12 = Util.Ray(
					cframe.Position + createVector(0, 1, 0),
					createVector(0, 1, 0) * -primaryPart.Size.Y / 2,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)

				if ray then
					local v13 = v12 + Vector3.new(0, primaryPart.Size.Y / 2, 0)
					cframe = CFrame.new(v13, v13 + cframe.LookVector)
				end

				primaryPart.CFrame = cframe
				clone5.Parent = folder
				clone5:SetAttribute("CurrTime", tick() + 1)
				clone5:SetAttribute("Tier", 1)
				v2.Model = clone5

				for _, emitter in pairs(primaryPart:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local sfx2 = Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Loop_SmallIndividual_01", primaryPart)
				v[i] = {
					aura = clone5,
					endCF = cframe,
					sfx = sfx2
				}
				local now = tick()
				local now2 = tick()
				local now3 = tick()

				while true do
					if now - tick() <= 0 then
						now = tick() + 0.1

						for i2 = 1, math.random(1, 3) do
							local v14 = i2
							task.spawn(function()
								local Z = clone5.PrimaryPart.Size.Z
								local clone6 = script.Part:Clone()
								local cFrame2 = CFrame.new(clone5.PrimaryPart.Position) * CFrame.Angles(
									math.rad((math.random(-180, 180))),
									math.rad((math.random(-180, 180))),
									(math.rad((math.random(-180, 180))))
								) * CFrame.new(0, 0, -Z)
								clone6.CFrame = cFrame2
								clone6.Parent = folder
								clone6.Attach1.WorldPosition = (cFrame2 * CFrame.new(0, 0, Z)).Position
								local shafiBolt = ShafiBolt(
									clone6.Attach0,
									clone6.Attach1,
									math.random(8, 12) / 2 * visualScale,
									0.5,
									folder
								)
								shafiBolt.CurveSize0 = math.random(-25, 25) * visualScale
								shafiBolt.CurveSize1 = math.random(-25, 25) * visualScale
								shafiBolt.Frequency = math.random(5, 10) * 2
								shafiBolt.MaxRadius = 5 * visualScale
								shafiBolt.AnimationSpeed = math.random(20, 50) / 10
								shafiBolt.Color = Color3.fromRGB(26, 60, 255)

								if v14 % 2 == 0 then
									shafiBolt.Color = Color3.fromRGB(48, 79, 255)
									shafiBolt.Thickness = 0.5 * visualScale
								end

								task.spawn(function()
									task.wait(0.1 + math.random() * 0.15)
									shafiBolt:Destroy()
									clone6:Destroy()
								end)
							end)
						end
					end

					if now2 - tick() <= 0 then
						now2 = tick() + 0.1
					end

					if now3 - tick() <= 0 then
						now3 = tick() + 0.05
						task.spawn(function()
							if clone5:GetAttribute("CurrTime") - tick() <= 0.125 then
								return
							end

							local clone6 = z_Attract.Phase3.Trail:Clone()
							local v14 = visualScale

							if v14 ~= 1 then
								if clone6:IsA("Model") then
									clone6:ScaleTo(clone6:GetScale() * v14)
								elseif clone6:IsA("BasePart") then
									clone6.Size *= v14
								end
							end

							clone6.CFrame = clone5.PrimaryPart.CFrame
							clone6.Parent = folder
							local Z = clone5.PrimaryPart.Size.Z
							local v15 = math.max(Z * 2 - 10 * visualScale, 1 * visualScale)
							local v16 = math.max(Z * 2, v15 + 1 * visualScale)
							clone6.CFrame = clone6.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, math.random(v15 * 100, v16 * 100) / 100 * 0.8)

							for _, effect in pairs(clone6:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							local position = clone6.Position
							local position2 = clone5.PrimaryPart.CFrame.Position
							local cframe2 = CFrame.new(
								math.random(-50, 50) / 2 * visualScale,
								math.random(-50, 50) / 2 * visualScale,
								math.random(-50, 50) / 2 * visualScale
							)
							local cframe3 = CFrame.new(
								math.random(-50, 50) / 2 * visualScale,
								math.random(-50, 50) / 2 * visualScale,
								math.random(-50, 50) / 2 * visualScale
							)
							local v17 = math.random(35, 40) / 12
							TrailCurve(clone6, clone5.PrimaryPart.CFrame, position, position2, cframe2, cframe3, v17)

							for _, effect in pairs(clone6:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end

					task.wait()

					if not (clone5:GetAttribute("CurrTime") - tick() <= 0) then
						continue
					end

					for _, emitter in pairs(primaryPart:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					if sfx2 then
						Util.Sound:FadeOut(sfx2, 0.2)
					end

					local clone6 = z_Attract.Phase3.ExplosionFinalModel:Clone()
					clone6:ScaleTo((math.max(clone5:GetScale() - 0.1 * visualScale, 0.05)))
					local primaryPart2 = clone6.PrimaryPart
					primaryPart2.CFrame = cframe
					clone6.Parent = folder
					local tier = clone5:GetAttribute("Tier")

					if tier <= 2 then
						Util.Sound:Play(
							"Magnet_Untransformed_Z_Projectile_Explode_Small_0" .. tostring(math.random(1, 3)),
							primaryPart
						)
					elseif tier <= 3 then
						Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Explode_Medium_02", primaryPart)
					else
						Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Explode_Large_01", primaryPart)
					end

					DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(primaryPart2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v14 = emitter
						task.spawn(function()
							if v14:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v14:GetAttribute("EmitDelay"))
							end

							v14:Emit(v14:GetAttribute("EmitCount"))
						end)
					end

					break
				end
			end)
		end

		local magnetArmFunctions = data.Root.Parent:FindFirstChild("MagnetArmFunctions")
		local v2 = "Left"

		for i = 1, data.ShotCount or 4 do
			if magnetArmFunctions and i < 3 then
				v2 = v2 == "Left" and "Right" or "Left"
				local armAnim = getArmAnim(
					root.Parent,
					v2 == "Right" and "Untr_ Z Tap Release R" or "Untr_ Z Tap Release L",
					v2
				) -- equivalent call inferred; original call site unknown

				if armAnim then
					armAnim:Play()
				end
			end

			Util.Sound:Play("Magnet_Untransformed_Z_Tap_Pistol_Fire_SingleShot_01", root.Position)

			if i ~= 1 then
				task.wait(0.15)
			end

			MakeBullet(i + 4, i)
		end
	end
end