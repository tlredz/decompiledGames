local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local c_Attract_Held = FX:WaitForChild("Magnet"):WaitForChild("C_Attract_Held")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local function resolveScrap(childName: string, flag: boolean)
	if not flag then
		return scraps:FindFirstChild(childName)
	end

	local v2 = v[childName]
	local child = v2 and scraps:FindFirstChild(v2)

	if child then
		return child
	end

	return scraps:FindFirstChild(childName)
end

local VfxPool = require(script.Parent.VfxPool)
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(p, p2)
	return WrapColor3Constructor(p2, p, "MagnetFruitVFXColor")
end

local function RecolorMagnetColorSequence(p, p2, p3)
	return ColorSequence.new(WrapColor3Constructor(p2, p, "MagnetFruitVFXColor"), RecolorMagnetColor(p, p3))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function QuadBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return (1 - p) ^ 2 * vector2 + (1 - p) * 2 * p * vector3 + p ^ 2 * vector4
end

local function AlignCFrame(data, p)
	local v2 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p2, unit2, v2, unit3)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 10
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Color3.new(1, 0.380392, 0.380392)
	v2.ColorOffsetSpeed = 3
	return v2
end

local function Explosion(p, child, raycastParams, claim)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(instance, duration)
		task.delay(duration, function()
			instance:Destroy()
		end)
	end

	local function AlignCFrameLocal(data, normal)
		local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p2 = data.p
		local unit = data.LookVector:Cross(v2).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
		local unit3 = unit2:Cross(v2).Unit
		return CFrame.fromMatrix(p2, unit2, v2, unit3)
	end

	local function RockCrater(p2, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrameLocal(CFrame.new(p2.Position), p2.Normal) + p2.Normal * 0.01
			local v3 = {}

			for _ = 1, amount do
				local v4 = VfxPool.PreparedClones.take(claim, "craterRocks", rockType)
				rocks:ApplyCollision(v4, nil, true)
				v4.Parent = parent
				DestroyAfter(v4, 7) -- equivalent call inferred; original call site unknown
				table.insert(v3, v4)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v4 in pairs(v3) do
					v4:Destroy()
				end

				v3 = nil
			end)
			local v4 = 360 / #v3
			local total = 0

			for _, v5 in pairs(v3) do
				total += v4
				v5.CFrame = v2 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v6 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v7 = (v5.Position - p2.Position).Magnitude / 200
					v5.Size = Vector3.new(
						size * math.random(20, 40) / 10 * v7,
						size * math.random(10, 30) / 10 * v7,
						size * math.random(30, 50) / 10 * v7
					)
					v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
					v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(-25, 25) / 2
					)
					v5.CFrame = CFrame.new(
						v5.Position,
						v2.Position + Vector3.new(0, math.random(-55, -45) / 100 + v5.Size.Y / 200, 0)
					) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v7), 0, 0) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-5, 5))))
					)
					v5.Material = part.Material
					v5.Color = part.Color
					TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Position = v5.Position + Vector3.new(0, v5.Size.Y * math.random(3, 5) / 10, 0)
					}):Play()
					local v8 = v5
					local v9 = v5
					task.spawn(function()
						task.wait(duration + math.random(10, 35) / 100)
						TweenService:Create(
							v8,
							TweenInfo.new(
								0.5,
								Enum.EasingStyle.Back,
								Enum.EasingDirection.In,
								0,
								false,
								math.random(10, 35) / 100
							),
							{
								Position = v8.Position + Vector3.new(
									math.random(-1, 1),
									-v8.Size.Y * math.random(20, 25) / 10,
									math.random(-1, 1)
								)
							}
						):Play()
						task.wait(0.6)
						v8:Destroy()
						v3[v8] = nil
					end)
				else
					v5:Destroy()
					v3[v5] = nil
				end
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local parent2 = VfxPool.PreparedClones.take(claim, "flyRocks", c_Attract_Held.Rock)
		rocks:ApplyCollision(parent2, nil, true)
		parent2.CFrame = cFrame
		parent2.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		parent2.Size *= math.random(3, 6) / 3
		parent2.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		parent2.Material = raycastResult.Instance.Material
		parent2.Color = raycastResult.Instance.Color
		parent2.CanCollide = false
		parent2.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 5000
		bodyVelocity.Velocity = CFrame.new(
			parent2.Position,
			parent2.Position + Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2) + Vector3.new(
				0,
				math.random(150, 200) / 1.5,
				0
			)
		).LookVector * math.random(50, 250) * 1.25
		bodyVelocity.Parent = parent2
		task.delay(1 * math.random() + 2.5, function()
			TweenService:Create(parent2, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.025 * math.random() + 0.025, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			parent2.CanCollide = true
		end)
	end

	local raycastResult = workspace:Raycast(
		p.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local v2 = AlignCFrameLocal(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v3 = {
		Radius = 75,
		Size = 13.75,
		Duration = 0.75,
		Amount = 35,
		RockType = c_Attract_Held.CraterRock
	}
	task.spawn(function()
		local rockType = v3.RockType
		local radius = v3.Radius
		local size = v3.Size
		local duration = v3.Duration
		local amount = v3.Amount
		local v4 = AlignCFrameLocal(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v5 = {}

		for _ = 1, amount do
			local v6 = VfxPool.PreparedClones.take(claim, "craterRocks", rockType)
			rocks:ApplyCollision(v6, nil, true)
			v6.Parent = child
			DestroyAfter(v6, 7) -- equivalent call inferred; original call site unknown
			table.insert(v5, v6)
		end

		task.spawn(function()
			task.wait(duration * 3)

			for _, v6 in pairs(v5) do
				v6:Destroy()
			end

			v5 = nil
		end)
		local v6 = 360 / #v5
		local total = 0

		for _, v7 in pairs(v5) do
			total += v6
			v7.CFrame = v4 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
			v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-150, 250) / 7
			)
			local ray = Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v8 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

			if part then
				local v9 = (v7.Position - raycastResult.Position).Magnitude / 200
				v7.Size = Vector3.new(
					size * math.random(20, 40) / 10 * v9,
					size * math.random(10, 30) / 10 * v9,
					size * math.random(30, 50) / 10 * v9
				)
				v7.Position = v8 + Vector3.new(0, -v7.Size.Y * math.random(5, 6) / 15, 0)
				v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-25, 25) / 2
				)
				v7.CFrame = CFrame.new(
					v7.Position,
					v4.Position + Vector3.new(0, math.random(-55, -45) / 100 + v7.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v9), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v7.Material = part.Material
				v7.Color = part.Color
				TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
				}):Play()
				local v10 = v7
				local v11 = v7
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					TweenService:Create(
						v10,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v10.Position + Vector3.new(
								math.random(-1, 1),
								-v10.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					):Play()
					task.wait(0.6)
					v10:Destroy()
					v5[v10] = nil
				end)
			else
				v7:Destroy()
				v5[v7] = nil
			end
		end
	end)
	task.spawn(function()
		for i = 1, 20 do
			task.spawn(function()
				FlyRock(
					v2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-math.random(125, 150) / 1.5
					),
					raycastResult,
					child
				)
			end)

			if i % 2 == 0 then
				task.wait(0.001 * math.random())
			end
		end
	end)
	return raycastResult
end

local function getArmAnim(instance, p: string, p2: string)
	local magnetArms = instance:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
		return
	end

	local child = magnetArms:FindFirstChild("Floating" .. p2 .. "Arm")
	local v2 = child and Util.Anims:Get(child, p)
	return v2 or nil
end

return function(data)
	local WAIT_INTERVAL = 0.1
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: " .. script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local holding = data.Holding
		local v2

		if data.Root == nil then
			v2 = false
		else
			v2 = data.Root:FindFirstChild("MagnetCHeldTrigger") ~= nil
		end

		if not (v2 or holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "MagnetCHeld_" .. player.Name
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local begin = VfxPool.PreparedClones.begin
		local name = player.Name
		local getScrapChildren = VfxPool.getScrapChildren
		local scrapModelA

		if hasCrimsonGoldSkin(data.Player) then
			local scrapModelA2 = v.ScrapModelA
			scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

			if not scrapModelA then
				scrapModelA = scraps:FindFirstChild("ScrapModelA")
			end
		else
			scrapModelA = scraps:FindFirstChild("ScrapModelA")
		end

		local v6 = begin(name, "CHeldLanding", {
			scraps = {
				Templates = getScrapChildren(scrapModelA, 2.5),
				Count = 60
			},
			smallTrails = {
				Template = c_Attract_Held.Phase2.SmallTrail,
				Count = 21
			},
			ringBeams = {
				Template = c_Attract_Held.Phase2.RingBeam,
				Count = 3
			},
			fallAuraFlames = {
				Template = c_Attract_Held.Phase2.FallAuraFlame,
				Count = 5
			},
			fallingSlashRings = {
				Template = c_Attract_Held.Phase2.SpinSlashModel,
				Count = 9
			},
			airSpins = {
				Template = c_Attract_Held.Phase2.AirSpin,
				Count = 3
			},
			airSpinLayers = {
				Template = c_Attract_Held.Phase2.AirSpin.Model,
				Count = 6
			},
			craterRocks = {
				Template = c_Attract_Held.CraterRock,
				Count = 35
			},
			flyRocks = {
				Template = c_Attract_Held.Rock,
				Count = 20
			},
			screenColors = {
				Template = c_Attract_Held.Phase3.ScreenColor,
				Count = 1
			},
			middleSphereLayers = {
				Template = c_Attract_Held.Phase1.Sphere1,
				Count = 1
			},
			finalExplosions = {
				Template = c_Attract_Held.Phase3.FinalExplosion,
				Count = 1
			},
			groundImpacts = {
				Template = c_Attract_Held.Phase3.GroundImpact,
				Count = 1
			},
			impactSpheres = {
				Template = c_Attract_Held.Phase1.Sphere,
				Count = 1
			},
			impactSphereLayers = {
				Template = c_Attract_Held.Phase1.Sphere1,
				Count = 1
			},
			boltAnchors = {
				Template = script.Part,
				Count = 12
			}
		})
		folder.Destroying:Once(function()
			VfxPool.PreparedClones.discard(player.Name, "CHeldLanding", v6)
		end)
		local v7 = tick() + 0.3
		local v8 = true
		local root = data.Root
		local _ = root.Parent
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		local cFrame = root.CFrame * CFrame.new(0, 0, -0.5)
		local v10 = Util.Sound:Play("Magnet_Untransformed_C_Held_Variant_01", root)
		task.spawn(function()
			while v8 == true do
				cFrame = root.CFrame * CFrame.new(0, 0, -0.5)
				task.wait()
			end
		end)
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v11

		if magnetArms then
			local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
			v11 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Magnet C Held Start R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v11 then
			v11.Priority = Enum.AnimationPriority.Action2
			v11.Looped = false
			v11:Play()
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v12

		if magnetArms2 then
			local floatingLeftArm = magnetArms2:FindFirstChild("FloatingLeftArm")
			v12 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Magnet C Held Start L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v12 then
			v12.Priority = Enum.AnimationPriority.Action2
			v12.Looped = false
			v12:Play()
		end

		local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
		local v13

		if magnetArms3 then
			local floatingLeftArm = magnetArms3:FindFirstChild("FloatingLeftArm")
			v13 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Magnet C Held Loop L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms4 = root.Parent:FindFirstChild("MagnetArms")
		local v14

		if magnetArms4 then
			local floatingRightArm = magnetArms4:FindFirstChild("FloatingRightArm")
			v14 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Magnet C Held Loop R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v13 and v14 then
			v13.Looped = true
			v14.Looped = true
			v13:Play()
			v14:Play()
		end

		local v15 = VfxPool.takeBurst(player, "CHeldChangeImpact", c_Attract_Held.Phase1.ChangeImpact)
		v15.Model.CFrame = cFrame
		VfxPool.emitBurst(v15)
		local clone = c_Attract_Held.Phase1.AuraSphereModel:Clone()
		clone.PrimaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		local emittersByEmitter = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		task.spawn(function()
			local v16 = clone:GetScale() * 100

			for i = v16, v16 * 2, 4 do
				clone:ScaleTo(i / 100)

				for _, emitter in pairs(emittersByEmitter) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(3)
					end
				end

				task.wait()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = false
			end
		end)
		task.spawn(function()
			for _ = 1, 15 do
				local position = cFrame * CFrame.new(math.random(-25, 25), 0, math.random(-50, -25)).Position
				task.spawn(function()
					task.wait(math.random() * 0.225)
					local v18 = math.random(45, 50) / 100
					local clone2 = c_Attract_Held.Phase1.TrailModel:Clone()
					clone2.Start.CFrame = CFrame.new(position) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
					clone2:ScaleTo(math.random(10, 20) / 10)
					local start = clone2.Start
					local trail = clone2.Trail
					local C1 = cFrame
					TweenService:Create(trail.Weld, TweenInfo.new(v18 / 5), {
						C1 = C1
					}):Play()
					TweenService:Create(start, TweenInfo.new(v18), {
						CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v18 / 3, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v18), {
							C1 = CFrame.new(0, 0, 0)
						}):Play()
						start.AlignPosition.Position = position
					end)
					trail.Trail1.Lifetime = math.random(50, 200) / 1500
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					TweenService:Create(angularVelocity, TweenInfo.new(0.15), {
						AngularVelocity = Vector3.new(
							math.random(-20, 25) * 2,
							math.random(-20, 25) * 2,
							math.random(-20, 25) * 2
						)
					}):Play()

					for i, effect in pairs(clone2:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v20 = effect
						task.delay(v18 + v18 / 5, function()
							v20.Enabled = false
						end)
					end

					task.wait(v18)
					angularVelocity.Enabled = false
					task.wait(v18)
					clone2:Destroy()
				end)
			end
		end)
		task.wait(WAIT_INTERVAL)
		local v16 = VfxPool.takeBurst(player, "CHeldStartImpact", c_Attract_Held.Phase1.HeldStartImpact)
		v16.Model.CFrame = cFrame
		VfxPool.emitBurst(v16)
		task.wait(WAIT_INTERVAL)
		task.spawn(function()
			task.wait(0.05)

			for i = 1, 2 do
				local cFrame2 = cFrame * CFrame.new(i == 1 and 12 or -12, 0, 0)
				local v18 = VfxPool.takeBurst(player, "CHeldSideImpact", c_Attract_Held.Phase1.SideImpact, 2)
				v18.Model.CFrame = cFrame2
				VfxPool.emitBurst(v18)
			end
		end)
		tick()
		local now = tick()
		local getScrapChildren2 = VfxPool.getScrapChildren
		local scrapModelA2

		if hasCrimsonGoldSkin(data.Player) then
			local scrapModelA3 = v.ScrapModelA
			scrapModelA2 = scrapModelA3 and scraps:FindFirstChild(scrapModelA3)

			if not scrapModelA2 then
				scrapModelA2 = scraps:FindFirstChild("ScrapModelA")
			end
		else
			scrapModelA2 = scraps:FindFirstChild("ScrapModelA")
		end

		local scrapChildren = getScrapChildren2(scrapModelA2, 2.5)
		local v17 = true
		local v18 = 0
		task.spawn(function()
			task.wait(0.5)

			if v17 == true then
				v18 = 1
				local v19 = VfxPool.takeBurst(
					player,
					"CHeldHoldAura",
					c_Attract_Held.Phase1.HoldAuraModel,
					1,
					function(p)
						VfxPool.thinStreamingHaze(p, 3)
					end
				)
				local model = v19.Model
				model:ScaleTo(0.75)
				model:PivotTo(cFrame)

				for _, emit in v19.Emits do
					local emitter = emit.Emitter
					emitter:Emit(1)
					task.spawn(function()
						emitter.Enabled = true
						task.wait(1)
						emitter.Enabled = false
					end)
				end

				task.wait(0.5)
				v18 = 2
				model:ScaleTo(1.5)
				local v20 = VfxPool.takeBurst(
					player,
					"CHeldHoldAura2",
					c_Attract_Held.Phase1.HoldAura2Model,
					1,
					function(p)
						VfxPool.thinStreamingHaze(p, 3)
					end
				)
				v20.Model.PrimaryPart.CFrame = cFrame

				for _, emit in v20.Emits do
					local emitter = emit.Emitter
					emitter:Emit(1)
					task.spawn(function()
						emitter.Enabled = true
						task.wait(0.5)
						emitter.Enabled = false
					end)
				end
			end
		end)
		local now2 = tick()
		local now3 = tick()
		local clone2 = c_Attract_Held.Phase1.AuraModel:Clone()
		VfxPool.stripNearInvisible(clone2, 0.88)
		local v19 = {}

		local function buildPullScrap()
			local clone3 = scrapChildren[math.random(1, #scrapChildren)]:Clone()
			clone3.Massless = true
			clone3.Anchored = true
			clone3.CanCollide = false
			local highlight = VfxPool.takeHighlight(c_Attract_Held.Phase1.Highlight, clone3, player)

			if highlight then
				highlight.Enabled = false
			end

			local clone4 = clone2:Clone()
			clone4.PrimaryPart.Anchored = false
			clone4.PrimaryPart.Weld.Part1 = clone3
			clone4.Parent = clone3
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
			local effects = {}

			for _, effect in pairs(clone3:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
				table.insert(effects, effect)
			end

			return {
				Part = clone3,
				BaseSize = clone3.Size,
				Highlight = highlight,
				Emitterish = effects,
				Busy = false
			}
		end

		local function spawnPullScrap(position: Vector3)
			local v20 = nil

			for _, v22 in v19 do
				if v22.Busy then
					continue
				end

				v20 = v22
				break
			end

			if not v20 then
				if #v19 >= 10 then
					return
				end

				v20 = buildPullScrap()
				table.insert(v19, v20)
			end

			v20.Busy = true
			local part = v20.Part
			part.Size = v20.BaseSize
			local v22 = position + Vector3.new(math.random(-50, 50), math.random(-15, 50), math.random(-50, 50))
			part.CFrame = CFrame.new(v22)

			if v20.Highlight then
				v20.Highlight.Enabled = true
			end

			for _, v23 in v20.Emitterish do
				v23.Enabled = true
			end

			local v23 = (v22 + position) / 2 + Vector3.new(
				math.random(-20, 20),
				math.random(-20, 20),
				math.random(-20, 20)
			)
			local v24 = math.random(15, 30) / 100
			local total = 0
			VfxPool.addStep(function(p)
				if not part.Parent then
					return true
				end

				total += p
				local v25 = total / v24

				if v25 >= 1 then
					for _, v26 in v20.Emitterish do
						v26.Enabled = false
					end

					if v20.Highlight then
						v20.Highlight.Enabled = false
					end

					part.Size = createVector(0, 0, 0)
					v20.Busy = false
					return true
				else
					local quadBezier = QuadBezier(v22, v23, position, v25 ^ 1.5)
					part.CFrame = CFrame.lookAt(quadBezier, position) * CFrame.Angles(
						math.rad(v25 * 720),
						math.rad(v25 * 540),
						(math.rad(v25 * 360))
					)
					part.Size *= 0.99
					return false
				end
			end)
		end

		local function spawnSideTrail(cframe: CFrame)
			local position = cframe.Position
			task.wait(math.random() * 0.225)
			local v20 = math.random(45, 50) / 200
			local clone3 = c_Attract_Held.Phase1.TrailModel:Clone()
			clone3.Start.CFrame = CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
			clone3:ScaleTo(math.random(10, 20) / 10)
			local start = clone3.Start
			local trail = clone3.Trail
			local cframe2 = CFrame.new(0, 0, -math.random(100, 150) * 0.5)
			TweenService:Create(trail.Weld, TweenInfo.new(v20 / 5), {
				C1 = cframe2
			}):Play()
			TweenService:Create(start, TweenInfo.new(v20), {
				CFrame = CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
			}):Play()
			trail.Weld.C1 = CFrame.new(0, 0, 0)
			task.delay(v20 / 3, function()
				TweenService:Create(trail.Weld, TweenInfo.new(v20), {
					C1 = CFrame.new(0, 0, 0)
				}):Play()
				start.AlignPosition.Position = position
			end)
			trail.Trail1.Lifetime = math.random(50, 200) / 1500
			local angularVelocity = start.AngularVelocity
			start.Anchored = false
			start.AlignPosition.Position = start.Position
			TweenService:Create(angularVelocity, TweenInfo.new(0.15), {
				AngularVelocity = Vector3.new(
					math.random(-20, 25) * 2,
					math.random(-20, 25) * 2,
					math.random(-20, 25) * 2
				)
			}):Play()

			for _, effect in pairs(clone3:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
				local v21 = effect
				task.delay(v20 + v20 / 5, function()
					v21.Enabled = false
				end)
			end

			task.wait(v20)
			angularVelocity.Enabled = false
			task.wait(v20)
			clone3:Destroy()
		end

		local function spawnSpinTrails(cframe: CFrame)
			for _ = 1, 2 do
				local clone3 = c_Attract_Held.Phase1.SpinTrail:Clone()
				clone3.CFrame = cframe * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
				Util.Debris:AddItem(clone3, 0.7)
				local clone4 = scrapChildren[math.random(1, #scrapChildren)]:Clone()
				clone4.Massless = true
				clone4.Anchored = false
				clone4.CFrame = clone3.CFrame
				clone4.Size = clone4.Size * math.random(8, 15) / 10
				Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
				clone3.SpinTrail2.Weld.Part0 = clone4
				task.delay(0.15, function()
					TweenService:Create(clone4, TweenInfo.new(0.15), {
						Size = createVector(0, 0, 0)
					}):Play()
					task.wait(0.15)
					clone4:Destroy()
				end)

				for _, trail in pairs(clone3:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					trail.Enabled = true
					trail.Lifetime = math.random(1, 3) / 30
				end

				clone3.Motor6D.C0 = CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(70, 100))
				local v21 = math.random(1, 3)

				if v21 == 1 then
					local trail = clone3.Trail
					local v22 = player
					local color = Color3.fromRGB(23, 35, 248)
					local color2 = Color3.fromRGB(35, 57, 255)
					trail.Color = ColorSequence.new(
						WrapColor3Constructor(color, v22, "MagnetFruitVFXColor"),
						RecolorMagnetColor(v22, color2)
					)
				elseif v21 == 2 then
					local trail = clone3.Trail
					local v22 = player
					local color = Color3.fromRGB(42, 42, 230)
					local color2 = Color3.fromRGB(67, 29, 255)
					trail.Color = ColorSequence.new(
						WrapColor3Constructor(color, v22, "MagnetFruitVFXColor"),
						RecolorMagnetColor(v22, color2)
					)
				elseif v21 == 3 then
					local trail = clone3.Trail
					local v22 = player
					local color = Color3.fromRGB(73, 73, 244)
					local color2 = Color3.fromRGB(23, 35, 255)
					trail.Color = ColorSequence.new(
						WrapColor3Constructor(color, v22, "MagnetFruitVFXColor"),
						RecolorMagnetColor(v22, color2)
					)
				end

				local v22 = math.random(7, 15) / 7
				clone3.SpinTrail2.Attach0.Position = Vector3.new(v22, 0, 0)
				clone3.SpinTrail2.Attach1.Position = Vector3.new(-v22, 0, 0)
				task.spawn(function()
					TweenService:Create(
						clone3.Motor6D,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = CFrame.new(0, 0, 0)
						}
					):Play()

					for i = 1, 3 do
						TweenService:Create(
							clone3,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
							}
						):Play()
						task.wait(0.05)
					end
				end)
			end
		end

		local function spawnTornado()
			local v20 = v18 == 1 and 17 or v18 == 2 and 20 or 15
			local clone3 = c_Attract_Held.Phase1.SpinSlash:Clone()
			clone3:PivotTo(CFrame.new(cFrame.Position + createVector(0, -15, 0)))
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
			Util.Debris:AddItem(clone3, 2)
			local model = clone3.Model
			local model2 = clone3.Model2

			for i = 1, v18 + 2 do
				local v21 = v20 + i * 1.05
				local v22 = 1.5
				local clone4

				if i == 1 then
					clone4 = model:Clone()
				else
					clone4 = model2:Clone()
					v22 = 1.75
				end

				clone4:ScaleTo(v21 / (v22 / 1.25))

				for _, beam in pairs(clone4:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local value = beam.Transparency.Keypoints[1].Value
					beam.Transparency = NumberSequence.new((math.max(0, 1 - (1 - value) * 2.5)))
					beam.Enabled = true
				end

				local primaryPart = clone4.PrimaryPart
				local v23 = clone3.PrimaryPart.CFrame * CFrame.new(0, v21, 0) * CFrame.Angles(
					math.rad(math.random(-180, 180) / 100),
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 100))
				)

				if i > 3 then
					v23 *= CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					v22 = 2
				end

				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
					math.random(-10, 10) / 10,
					15,
					math.random(-10, 10) / 10
				)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
				clone4:PivotTo(v23)
				Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 2,
									math.random(5, 15),
									math.random(-5, 5) / 2
								)
							}
						):Play()
					end)
					task.wait(0.1 * math.random() + 0.1 / v22)

					for i2, effect in pairs(clone4:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.15 / v22 + math.random() * 0.15 / v22), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v25 = effect
							task.delay(1, function()
								v25:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
			end

			model:Destroy()
			task.spawn(function()
				local v21 = clone3:GetScale() * 1.5
				local v22 = v21 * 0.225

				for i = v21 * 100, v22 * 100, -7 do
					clone3:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end

		local function spawnSideBolt(cframe: CFrame, p: number)
			local v20 = CFrame.new(cframe.Position) * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			local v21 = VfxPool.takeBoltAnchor(
				player,
				script.Part,
				12,
				v20,
				v20 * CFrame.new(0, 0, 40 * math.random(12, 20) / 10).Position
			)
			local shafiBolt = ShafiBolt(v21.Attach0, v21.Attach1, math.random(8, 12) * 0.75, 0.5, folder)
			shafiBolt.Frequency = math.random(5, 10) * 2
			shafiBolt.MaxRadius = 12
			shafiBolt.AnimationSpeed = math.random(20, 50) / 10
			shafiBolt.Color = WrapColor3Constructor(Color3.fromRGB(28, 28, 255), player, "MagnetFruitVFXColor")

			if p == 2 then
				shafiBolt.Color = WrapColor3Constructor(Color3.fromRGB(35, 46, 255), player, "MagnetFruitVFXColor")
				shafiBolt.Thickness = 0.7
			end

			task.spawn(function()
				task.wait(0.05 + math.random() * 0.115)
				shafiBolt:Destroy()
			end)
		end

		local function pulseSpheres()
			VfxPool.spherePulse({
				Owner = player,
				Template = c_Attract_Held.Phase1.Sphere,
				RingKey = "CHeldPulseSphere",
				RingSize = 3,
				CFrame = CFrame.new(cFrame.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				),
				StartSize = createVector(135, 135, 135),
				EndSize = createVector(0, 0, 0),
				Transparency = 0.709
			})
			VfxPool.spherePulse({
				Owner = player,
				Template = c_Attract_Held.Phase1.Sphere1,
				RingKey = "CHeldPulseSphere1",
				RingSize = 3,
				CFrame = CFrame.new(cFrame.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				),
				StartSize = createVector(135, 135, 135),
				EndSize = createVector(0, 0, 0),
				Transparency = 0.819,
				TileTween = true
			})
		end

		while holding and holding:IsDescendantOf(workspace) and (holding.Value or not (v7 <= tick())) do
			local magnitude = (currentCamera.CFrame.Position - cFrame.Position).Magnitude

			if now - tick() <= 0 and magnitude < 350 then
				now = tick() + 0.1

				for i = 1, 2 do
					local v20 = cFrame * CFrame.new(i == 1 and 12 or -12, 0, 0)
					task.spawn(spawnSideTrail, v20)
					task.spawn(spawnSpinTrails, v20)
					spawnPullScrap(v20.Position)
					spawnPullScrap(v20.Position)
				end
			end

			if now2 - tick() <= 0 and magnitude < 1200 then
				now2 = tick() + 0.2
				task.spawn(spawnTornado)

				if magnitude < 350 then
					for i = 1, 2 do
						local v20 = cFrame * CFrame.new(i == 1 and 12 or -12, 0, 0)
						task.spawn(spawnSideBolt, v20, i)
					end
				end
			end

			if now3 - tick() <= 0 and magnitude < 1200 then
				now3 = tick() + 0.15
				task.spawn(pulseSpheres)
			end

			task.wait(0.05)
		end

		if v10 then
			Util.Sound:FadeOut(v10, 0.2)
		end

		v17 = false
		task.delay(0.4, function()
			for _, v20 in v19 do
				v20.Busy = true
				v20.Part:Destroy()
			end
		end)
		v8 = false

		if v13 and v14 then
			v13:Stop()
			v14:Stop()
		end

		Util.Debris:AddItem(folder, 10)
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild("MagnetCHeld_" .. player.Name)

		if not child then
			return
		end

		local claim = VfxPool.PreparedClones.claim(player.Name, "CHeldLanding")
		child.Destroying:Once(function()
			VfxPool.PreparedClones.destroy(claim)
		end)
		child.Name = "DESTROYING"
		local root = data.Root
		local getScrapChildren = VfxPool.getScrapChildren
		local scrapModelA

		if hasCrimsonGoldSkin(data.Player) then
			local scrapModelA2 = v.ScrapModelA
			scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

			if not scrapModelA then
				scrapModelA = scraps:FindFirstChild("ScrapModelA")
			end
		else
			scrapModelA = scraps:FindFirstChild("ScrapModelA")
		end

		local scrapChildren = getScrapChildren(scrapModelA, 2.5)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		local startCFrame = data.StartCFrame
		local clone = c_Attract_Held.Phase1.Arm:Clone()
		VfxPool.thinStreamingHaze(clone, 3)
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, child, player, "MagnetFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = root
		local clone2 = c_Attract_Held.Phase1.HoldAura2Model:Clone()
		VfxPool.thinStreamingHaze(clone2, 3)
		local primaryPart = clone2.PrimaryPart
		primaryPart.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, clone, player, "MagnetFruitVFXColor")
		primaryPart.Anchored = false
		primaryPart.Weld.Part1 = clone
		Util.Sound:Play("Magnet_Untransformed_C_Release_01", root)

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			local v2 = emitter
			task.spawn(function()
				v2.Enabled = true
			end)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local cFrame = startCFrame
		local upDist = data.UpDist or 25
		local v3 = VfxPool.takeBurst(player, "CHeldExStartImpact", c_Attract_Held.Phase2.ExStartImpact)
		v3.Model.CFrame = cFrame * CFrame.new(0, 1, 0)
		VfxPool.emitBurst(v3)
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v4

		if magnetArms then
			local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
			v4 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Magnet C Held End R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v4 then
			v4.Priority = Enum.AnimationPriority.Action2
			v4.Looped = false
			v4:Play()
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v5

		if magnetArms2 then
			local floatingLeftArm = magnetArms2:FindFirstChild("FloatingLeftArm")
			v5 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Magnet C Held End L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v5 then
			v5.Priority = Enum.AnimationPriority.Action2
			v5.Looped = false
			v5:Play()
		end

		task.wait(WAIT_INTERVAL)
		root.Anchored = true
		TweenService:Create(root, TweenInfo.new(0.1), {
			CFrame = data.UpCFrame
		}):Play()
		local v6 = VfxPool.takeBurst(
			player,
			"CHeldJumpStartImpact",
			c_Attract_Held.Phase2.JumpStartImpact,
			1,
			VfxPool.thinBurstHaze
		)
		v6.Model.CFrame = cFrame
		VfxPool.emitBurst(v6)
		local v7 = VfxPool.takeBurst(
			player,
			"CHeldJumpImpact",
			c_Attract_Held.Phase2.JumpImpact,
			1,
			VfxPool.thinBurstHaze
		)
		v7.Model.CFrame = cFrame
		VfxPool.emitBurst(v7)
		task.spawn(function()
			local v8 = upDist

			for i = 1, 10 do
				local v9 = i
				task.spawn(function()
					local v10 = 1 + math.random(5, 25) / 100
					local v11 = VfxPool.PreparedClones.take(
						claim,
						"scraps",
						scrapChildren[math.random(1, #scrapChildren)]
					)
					v11.Anchored = true
					v11.CanCollide = false
					v11.Size = v11.Size * math.random(10, 15) / 10
					Util.SetParentOverrideWithColor(v11, child, player, "MagnetFruitVFXColor")
					local v12 = VfxPool.takeHighlight(c_Attract_Held.Phase1.Highlight, v11, player)

					if v12 then
						v12.Enabled = true
					end

					local v13 = v9 / 10 * 3.141592653589793 * 2
					local v14 = math.random(20, 70)
					local v15 = math.random(-10, 35)
					local lastTime = tick()
					local v16 = math.random(15, 30) / 100
					local v17 = false
					VfxPool.addStep(function()
						if not v11.Parent then
							return true
						end

						local v18 = tick() - lastTime

						if v10 - v16 < v18 and v17 == false then
							v17 = true
							task.spawn(function()
								local v19 = math.random(15, 35) / 100
								TweenService:Create(v11, TweenInfo.new(v19), {
									Size = createVector(0, 0, 0)
								}):Play()

								if v12 then
									v12:Destroy()
								end

								task.wait(v19)
								v11:Destroy()
							end)
						elseif v10 < v18 then
							return true
						end

						local v19 = v18 / v10
						local v20 = v13 + v18 * 7
						local v21 = v14 * (1 - v19 * 0.25)
						local v22 = v19 * v8 + v15 + math.sin(v18 * 4 + v9) * 12
						local v23 = cFrame.Position + Vector3.new(math.cos(v20) * v21, v22, math.sin(v20) * v21)
						v11.CFrame = CFrame.lookAt(v23, cFrame.Position) * CFrame.Angles(
							math.rad(v18 * 720),
							math.rad(v18 * 360),
							(math.rad(v18 * 180))
						)
						return false
					end)
				end)
			end
		end)
		task.spawn(function()
			local modelsByModel = {}

			for _, model in pairs(clone:GetChildren()) do
				if model:IsA("Model") then
					modelsByModel[model] = model
				end
			end

			for i = 100, 50, -1.5 do
				for _, v8 in pairs(modelsByModel) do
					v8:ScaleTo(i / 100)
				end

				RunService.Heartbeat:Wait()
			end
		end)
		task.spawn(function()
			local numberValue = Instance.new("NumberValue", child)
			numberValue.Value = 125
			local v8 = upDist
			TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Value = 70
			}):Play()
			task.delay(0.75, function()
				TweenService:Create(
					numberValue,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
					{
						Value = 25
					}
				):Play()
			end)
			local v9 = {}
			task.spawn(function()
				for i = 1, 15 do
					local part = VfxPool.PreparedClones.take(
						claim,
						"scraps",
						scrapChildren[math.random(1, #scrapChildren)]
					)
					part.Anchored = true
					part.CanCollide = false
					part.Size *= math.random(10, 15) / 7
					Util.SetParentOverrideWithColor(part, child, player, "MagnetFruitVFXColor")
					local highlight = VfxPool.takeHighlight(c_Attract_Held.Phase1.Highlight, part, player)

					if highlight then
						highlight.Enabled = true
					end

					table.insert(v9, {
						part = part,
						baseAngle = i / 15 * 3.141592653589793 * 2,
						highlight = highlight,
						spawnTime = tick(),
						rising = true,
						yOffset = math.random(-25, 25)
					})
					task.wait(0.015)
				end
			end)
			local lastTime = tick()
			VfxPool.addStep(function()
				local v10 = tick() - lastTime

				if v10 > 1 then
					for _, v11 in ipairs(v9) do
						TweenService:Create(v11.part, TweenInfo.new(0.25), {
							Size = createVector(0, 0, 0)
						}):Play()

						if v11.highlight then
							v11.highlight:Destroy()
						end

						local v12 = v11
						task.delay(0.25, function()
							if v12.part then
								v12.part:Destroy()
							end
						end)
					end

					return true
				else
					for _, v11 in ipairs(v9) do
						local part = v11.part

						if not part.Parent then
							continue
						end

						local v12 = v11.baseAngle + v10 * 13
						local v13 = math.sin(v10 * 4 + v11.baseAngle * 3) * 7
						local v14 = cFrame.Position + Vector3.new(
							math.cos(v12) * numberValue.Value,
							v8 + v11.yOffset + v13,
							math.sin(v12) * numberValue.Value
						)
						part.CFrame = CFrame.lookAt(v14, cFrame.Position) * CFrame.Angles(
							math.rad(v10 * 300),
							math.rad(v10 * 200),
							(math.rad(v10 * 100))
						)

						if v11.rising and (tick() - v11.spawnTime) / 0.375 >= 1 then
							v11.rising = false
						end
					end

					return false
				end
			end)
		end)

		if clone:FindFirstChild("HoldAura2Model") then
			clone:FindFirstChild("HoldAura2Model"):ScaleTo(0.75)
		end

		task.spawn(function()
			local v8 = tick() + 0.5

			repeat
				local v9 = VfxPool.PreparedClones.take(claim, "smallTrails", c_Attract_Held.Phase2.SmallTrail)
				v9.CFrame = clone.CFrame * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				) * CFrame.new(0, 0, -math.random(50, 100))
				Util.SetParentOverrideWithColor(v9, child, player, "MagnetFruitVFXColor")
				local position = clone.Position
				local position2 = v9.Position
				local v10 = (position2 + position) / 2 + Vector3.new(
					math.random(-15, 15),
					math.random(10, 25),
					math.random(-15, 15)
				)
				local v11 = math.random(30, 45) / 100
				local now = tick()
				local unit = Vector3.new(
					math.random(-100, 100) / 100,
					math.random(-100, 100) / 100,
					math.random(-100, 100) / 100
				).Unit
				Util.Debris:AddItem(v9, v11 + 0.5)
				VfxPool.addStep(function()
					if not v9.Parent then
						return true
					end

					local v19 = (tick() - now) / v11

					if v19 >= 1 then
						v9.Position = position
						return true
					end

					local quadBezier = QuadBezier(position2, v10, position, v19)
					local v24 = (tick() - now) * 15
					local v25 = 50 * (1 - v19)
					local cframe = CFrame.fromAxisAngle(unit, v24)
					v9.CFrame = CFrame.lookAt(
						quadBezier + cframe:VectorToWorldSpace((Vector3.new(v25, 0, 0))),
						position
					)
					return false
				end)
				task.wait(0.025)
			until v8 - tick() <= 0
		end)
		local upCFrame = data.UpCFrame
		task.wait(1.05)
		local v8 = VfxPool.takeBurst(player, "CHeldThrowImpact", c_Attract_Held.Phase3.ThrowImpact)
		v8.Model.CFrame = upCFrame
		VfxPool.emitBurst(v8)
		local v9 = 110 + upDist
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(0, 1, 0) * -v9,
			raycastParams
		)
		clone.Weld.Enabled = false
		clone.Anchored = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local cframe = CFrame.new(clone.Position)
		task.spawn(function()
			task.wait(0.1)

			for i = 1, 3 do
				local v10 = 8
				local v11 = 0.1
				local v12 = 25
				local cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, 10, 0)

				if i == 2 then
					cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, -35, 0)
					v11 = 0.125
					v12 = 35
					v10 = 6
				elseif i == 3 then
					cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, -50, 0)
					v11 = 0.085
					v12 = -25
					v10 = 4
				end

				local folder = VfxPool.PreparedClones.take(claim, "ringBeams", c_Attract_Held.Phase2.RingBeam)
				folder.CFrame = cFrame2
				Util.SetParentOverrideWithColor(folder, child, player, "MagnetFruitVFXColor")
				TweenService:Create(folder, TweenInfo.new(v11, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = folder.CFrame * CFrame.new(0, v12, 0)
				}):Play()

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v14 = descendant
						task.spawn(function()
							TweenService:Create(
								v14,
								TweenInfo.new(v11 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v14.CurveSize0 * v10,
									CurveSize1 = v14.CurveSize1 * v10,
									Width0 = v14.Width0,
									Width1 = v14.Width1
								}
							):Play()
							task.wait(v11 / 2)
							local tween = TweenService:Create(
								v14,
								TweenInfo.new(v11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v14:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v11 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v16 = descendant.Position.X * v10
						local v17 = descendant.Position.Y * v10
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v16, v17, descendant.Position.Z * v10)
						}):Play()
					end
				end

				task.wait(0.0025)
			end
		end)
		local magnitude

		if raycastResult then
			magnitude = (raycastResult.Position - clone.Position).Magnitude or v9
		else
			magnitude = v9
		end

		local v10 = 0.3 * (magnitude / v9)
		task.spawn(function()
			for _ = 1, 5 do
				local folder = VfxPool.PreparedClones.take(claim, "fallAuraFlames", c_Attract_Held.Phase2.FallAuraFlame)
				folder:PivotTo(clone.CFrame)
				folder.PrimaryPart.Anchored = false
				Util.SetParentOverrideWithColor(folder, child, player, "MagnetFruitVFXColor")
				folder:ScaleTo(math.random(7, 12) / 10)
				local weld = folder.PrimaryPart.Weld
				weld.Part1 = clone
				weld.C1 = CFrame.new(math.random(-5, 5) * 3, 5, math.random(-5, 5) * 3) * CFrame.new(
					0,
					math.random(5, 10),
					0
				)

				for _, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					emitter:Emit(1)
					local v11 = emitter
					task.delay(v10, function()
						v11.Enabled = false
					end)
				end

				task.delay(v10, function()
					folder.PrimaryPart.Anchored = true
				end)
			end
		end)
		cFrame = clone.CFrame - Vector3.new(0, magnitude, 0)
		Util.Sound:Play("Magnet_Untransformed_C_Explosion_03", cFrame.Position)
		TweenService:Create(clone, TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
		local v11 = tick() + v10 * 0.75
		local now = tick()

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.035
				task.spawn(function()
					local v12 = VfxPool.PreparedClones.take(
						claim,
						"fallingSlashRings",
						c_Attract_Held.Phase2.SpinSlashModel
					)
					local primaryPart2 = v12.PrimaryPart
					primaryPart2.CFrame = clone.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					Util.SetParentOverrideWithColor(v12, child, player, "MagnetFruitVFXColor")
					Util.Debris:AddItem(v12, 1)
					v12:ScaleTo(3)
					primaryPart2.Anchored = false
					primaryPart2.Massless = true
					local motor6D = primaryPart2.Motor6D
					motor6D.Part1 = clone
					motor6D.C0 = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					task.spawn(function()
						local tween = TweenService:Create(
							motor6D,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C1 = CFrame.new(0, 35, 0) * CFrame.Angles(0, 1.4835298641951802, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(
							motor6D,
							TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								C1 = CFrame.new(0, 7, 0) * CFrame.Angles(0, 0.9890199094634534, 0)
							}
						):Play()
					end)

					for _, descendant in pairs(primaryPart2:GetDescendants()) do
						if descendant:IsA("Beam") then
							local v13 = descendant
							task.spawn(function()
								v13.Width0 *= 3.5
								v13.Width1 *= 3.5
								TweenService:Create(
									v13,
									TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										CurveSize0 = v13.CurveSize0 * 3.5,
										CurveSize1 = v13.CurveSize1 * 3.5,
										Width0 = 0,
										Width1 = 0
									}
								):Play()
								task.wait(0.05)
								local tween = TweenService:Create(
									v13,
									TweenInfo.new(0.025, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween:Play()
								tween.Completed:Wait()
								v13:Destroy()
							end)
						elseif descendant:IsA("Attachment") then
							TweenService:Create(
								descendant,
								TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(
										descendant.Position.X * 3.5,
										descendant.Position.Y * 3.5,
										descendant.Position.Z * 3.5
									)
								}
							):Play()
						end
					end
				end)
			end

			RunService.Heartbeat:Wait()

			if not (v11 - tick() <= 0) then
				continue
			end

			root.Anchored = false
			clone:Destroy()
			task.spawn(function()
				for i = 1, 7 do
					local v12 = i
					task.spawn(function()
						local v13 = CFrame.new(cFrame.Position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 10))
						)
						local v14 = VfxPool.takeBoltAnchor(
							player,
							script.Part,
							12,
							v13,
							v13 * CFrame.new(0, 150, 140).Position + Vector3.new(0, math.random(-70, 15), 0),
							claim,
							"boltAnchors"
						)
						local shafiBolt = ShafiBolt(v14.Attach0, v14.Attach1, math.random(8, 12) * 1.5, 1.5, child)
						shafiBolt.CurveSize0 = -math.random(5, 15)
						shafiBolt.CurveSize1 = math.random(5, 15)
						shafiBolt.Frequency = math.random(7, 10) * 2
						shafiBolt.MaxRadius = 25
						shafiBolt.AnimationSpeed = math.random(20, 30) / 10
						shafiBolt.Color = WrapColor3Constructor(
							Color3.fromRGB(35, 50, 255),
							player,
							"MagnetFruitVFXColor"
						)

						if v12 % 2 == 0 then
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(67, 61, 255),
								player,
								"MagnetFruitVFXColor"
							)
						end

						task.spawn(function()
							task.wait(0.35 + math.random() * 0.2)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
			VfxPool.spherePulse({
				Owner = player,
				Template = c_Attract_Held.Phase1.Sphere1,
				RingKey = "CHeldImpactSphere1Mid",
				CFrame = CFrame.new(cFrame.Position + createVector(0, 15, 0), workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				),
				StartSize = createVector(50, 50, 50),
				EndSize = createVector(175, 175, 175),
				Transparency = 0.75,
				FadeDuration = 0.25,
				FadeStyle = Enum.EasingStyle.Back,
				FadeDirection = Enum.EasingDirection.InOut,
				TileTween = true,
				PreparedState = claim,
				PreparedKey = "middleSphereLayers"
			})
			local v13 = VfxPool.takePreparedBurst(
				player,
				"CHeldFinalExplosion",
				c_Attract_Held.Phase3.FinalExplosion,
				claim,
				"finalExplosions",
				1,
				function(folder)
					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local lifetime = emitter.Lifetime
						emitter.Lifetime = NumberRange.new(lifetime.Min * 2.25, lifetime.Max * 2.25)
					end

					VfxPool.thinBurstHaze(folder)
				end
			)
			v13.Model.CFrame = cFrame

			if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 150 then
				Util.CameraShaker:ShakeOnce(12, 8, 0.2, 0.6)
			end

			VfxPool.emitBurst(v13)
			task.delay(0.05, function()
				task.wait(0.025)
				task.spawn(function()
					local bloomEffect = Instance.new("BloomEffect")
					bloomEffect.Parent = game.Lighting
					bloomEffect.Size += 10
					local v14 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
						Size = 54
					}):Play()
					task.delay(0.1, function()
						v14 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
							Size = 0
						}):Play()
						task.wait(0.1)
						bloomEffect:Destroy()
					end)
					local v15 = VfxPool.PreparedClones.take(claim, "screenColors", c_Attract_Held.Phase3.ScreenColor)
					v15.Parent = game.Lighting
					local tween = TweenService:Create(v15, TweenInfo.new(0.025), {
						Brightness = v15.Brightness,
						Contrast = v15.Contrast,
						Saturation = v15.Saturation,
						TintColor = v15.TintColor
					})
					v15.Brightness = 0
					v15.Contrast = 0
					v15.Saturation = 0
					v15.TintColor = Color3.fromRGB(255, 255, 255)
					tween:Play()
					task.wait(0.075)
					local tween2 = TweenService:Create(v15, TweenInfo.new(0.0125), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween2:Play()
					tween2.Completed:Wait()
					v15:Destroy()
				end)
				local raycastResult2 = workspace:Raycast(
					cFrame.Position + createVector(0, 1, 0),
					createVector(-0, -25, -0),
					raycastParams
				)
				local v14 = VfxPool.takePreparedBurst(
					player,
					"CHeldGroundImpact",
					c_Attract_Held.Phase3.GroundImpact,
					claim,
					"groundImpacts",
					1,
					VfxPool.thinBurstHaze
				)
				v14.Model.CFrame = cFrame
				local groundAura

				if raycastResult2 then
					groundAura = nil
				else
					groundAura = v14.Model:FindFirstChild("GroundAura")
				end

				VfxPool.emitBurst(v14, nil, groundAura)
				task.delay(0.1, function()
					VfxPool.emitBurst(v14, 0.5, groundAura)
					task.wait(0.1)
					VfxPool.emitBurst(v14, 0.5, groundAura)
				end)
			end)
			task.spawn(function()
				for i = 1, 3 do
					local v14 = i
					task.spawn(function()
						local v15 = 8
						local v16 = VfxPool.PreparedClones.take(claim, "airSpins", c_Attract_Held.Phase2.AirSpin)
						v16:PivotTo(cFrame * CFrame.new(0, 10, 0))
						Util.SetParentOverrideWithColor(v16, child, player, "MagnetFruitVFXColor")

						if v14 == 2 then
							v16:PivotTo(cFrame * CFrame.new(0, 25, 0))
							v15 = 9
						elseif v14 == 3 then
							v16:PivotTo(cFrame * CFrame.new(0, 50, 0))
							v15 = 10
						end

						local model = v16.Model

						for i2 = 1, 2 do
							local v17 = v15 + 3 + i2 * 1.05
							local v18 = VfxPool.PreparedClones.take(claim, "airSpinLayers", model)
							v18:ScaleTo(v17)
							local primaryPart2 = v18.PrimaryPart
							local v19 = v16.PrimaryPart.CFrame * CFrame.new(0, v17, 0) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							)
							local angularVelocity = primaryPart2.AngularVelocity
							primaryPart2.Anchored = false
							primaryPart2.AlignPosition.Position = primaryPart2.Position + Vector3.new(
								math.random(-10, 10) / 10,
								0,
								math.random(-10, 10) / 10
							)
							angularVelocity.AngularVelocity = Vector3.new(
								math.random(-5, 5) / 5,
								math.random(10, 15) * 3,
								math.random(-5, 5) / 5
							)
							v18:PivotTo(v19)
							Util.SetParentOverrideWithColor(v18, v16, player, "MagnetFruitVFXColor")
							v18:GetScale()
							local folder = v18
							task.spawn(function()
								task.spawn(function()
									local Y = folder.Slash.Position.Y
									task.wait(0.125)
									TweenService:Create(
										angularVelocity,
										TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											AngularVelocity = createVector(0, 5, 0)
										}
									):Play()
									task.wait(0.3)
									TweenService:Create(
										angularVelocity,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											AngularVelocity = Vector3.new(
												math.random(-5, 5) / 10,
												math.random(5, 15),
												math.random(-5, 5) / 10
											)
										}
									):Play()
								end)
								task.wait(0.1 * math.random() + 0.5)

								for i3, effect in pairs(folder:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(effect, TweenInfo.new(0.15 + math.random() * 0.15), {
											Width0 = 0,
											Width1 = 0
										}):Play()
										local v21 = effect
										task.delay(1, function()
											v21:Destroy()
										end)
									elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end

								task.wait(1)
								angularVelocity.Enabled = false
							end)
						end

						model:Destroy()
						task.spawn(function()
							local scale = v16:GetScale()
							local v17 = scale * 1.75

							for i2 = scale * 100, v17 * 100, 5 do
								v16:ScaleTo(i2 / 100)
								task.wait(0.005)
							end
						end)
					end)
				end
			end)
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams2.FilterDescendantsInstances = {
				workspace._WorldOrigin,
				workspace.Characters,
				workspace.Enemies
			}
			Explosion(cFrame, child, raycastParams2, claim)
			task.spawn(function()
				VfxPool.spherePulse({
					Owner = player,
					Template = c_Attract_Held.Phase1.Sphere,
					RingKey = "CHeldImpactSphere",
					CFrame = CFrame.new(
						cFrame.Position + createVector(0, 15, 0),
						workspace.CurrentCamera.CFrame.Position
					) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)),
					StartSize = createVector(50, 50, 50),
					EndSize = createVector(250, 250, 250),
					Duration = 0.45,
					Transparency = 0.5,
					FadeDuration = 0.25,
					FadeStyle = Enum.EasingStyle.Back,
					FadeDirection = Enum.EasingDirection.InOut,
					PreparedState = claim,
					PreparedKey = "impactSpheres"
				})
				VfxPool.spherePulse({
					Owner = player,
					Template = c_Attract_Held.Phase1.Sphere1,
					RingKey = "CHeldImpactSphere1",
					CFrame = CFrame.new(
						cFrame.Position + createVector(0, 15, 0),
						workspace.CurrentCamera.CFrame.Position
					) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)),
					StartSize = createVector(50, 50, 50),
					EndSize = createVector(250, 250, 250),
					Duration = 0.45,
					Transparency = 0.5,
					FadeDuration = 0.25,
					FadeStyle = Enum.EasingStyle.Back,
					FadeDirection = Enum.EasingDirection.InOut,
					TileTween = true,
					PreparedState = claim,
					PreparedKey = "impactSphereLayers"
				})
				task.spawn(function()
					for i = 1, 10 do
						local v14 = i
						task.spawn(function()
							local v15 = CFrame.new(cFrame.Position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
								math.rad(math.random(-180, 180) / 10),
								math.rad((math.random(-180, 180))),
								(math.rad(math.random(-180, 180) / 10))
							) * CFrame.new(0, 0, -70)
							local v16 = VfxPool.takeBoltAnchor(
								player,
								script.Part,
								12,
								v15,
								v15 * CFrame.new(0, 0, 140).Position,
								claim,
								"boltAnchors"
							)
							local shafiBolt = ShafiBolt(
								v16.Attach0,
								v16.Attach1,
								math.random(8, 12) * 1.25,
								0.75,
								child
							)
							shafiBolt.CurveSize0 = -60
							shafiBolt.CurveSize1 = 60
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 12
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(28, 28, 255),
								player,
								"MagnetFruitVFXColor"
							)

							if v14 % 2 == 0 then
								shafiBolt.Color = WrapColor3Constructor(
									Color3.fromRGB(35, 46, 255),
									player,
									"MagnetFruitVFXColor"
								)
								shafiBolt.Thickness = 1
							end

							task.spawn(function()
								task.wait(0.25 + math.random() * 0.35)
								shafiBolt:Destroy()
							end)
						end)
					end
				end)
			end)

			for _ = 1, 15 do
				task.spawn(function()
					local v14 = VfxPool.PreparedClones.take(
						claim,
						"scraps",
						scrapChildren[math.random(1, #scrapChildren)]
					)
					local v15 = cFrame.Position + Vector3.new(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 5)
					)
					v14.CFrame = CFrame.new(v15)
					v14.Anchored = false
					v14.CanCollide = false
					v14.Size = v14.Size * math.random(10, 25) / 10
					Util.SetParentOverrideWithColor(v14, child, player, "MagnetFruitVFXColor")
					task.delay(0.15, function()
						v14.CanCollide = true
					end)
					v14.AssemblyLinearVelocity = (v15 - cFrame.Position).Unit * math.random(120, 220) + Vector3.new(
						math.random(-25, 25),
						math.random(30, 80),
						math.random(-25, 25)
					)
					v14.AssemblyAngularVelocity = Vector3.new(
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(-20, 20)
					)
					task.delay(1 + math.random() * 0.5, function()
						TweenService:Create(v14, TweenInfo.new(0.5), {
							Size = createVector(0, 0, 0)
						}):Play()
						task.wait(0.5)
						v14:Destroy()
					end)
				end)
			end

			local v14 = {}

			for _ = 1, 20 do
				local v15 = v14
				task.spawn(function()
					local v16 = VfxPool.PreparedClones.take(
						claim,
						"scraps",
						scrapChildren[math.random(1, #scrapChildren)]
					)
					local v17 = cFrame.Position + Vector3.new(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 5)
					)
					v16.CFrame = CFrame.new(v17)
					v16.Anchored = false
					v16.CanCollide = false
					v16.Size = v16.Size * math.random(10, 15) / 10
					Util.SetParentOverrideWithColor(v16, child, player, "MagnetFruitVFXColor")
					local v18 = VfxPool.takeHighlight(c_Attract_Held.Phase1.Highlight, v16, player)

					if v18 then
						v18.Enabled = true
					end

					table.insert(v15, v16)
					task.delay(0.15, function()
						v16.CanCollide = true
					end)
					v16.AssemblyLinearVelocity = (v17 - cFrame.Position).Unit * math.random(120, 220) + Vector3.new(
						math.random(-25, 25),
						math.random(30, 80),
						math.random(-25, 25)
					)
					v16.AssemblyAngularVelocity = Vector3.new(
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(-20, 20)
					)
					task.delay(1 + math.random() * 0.5, function()
						TweenService:Create(v16, TweenInfo.new(0.5), {
							Size = createVector(0, 0, 0)
						}):Play()
						task.wait(0.5)
						v16:Destroy()
					end)
				end)
			end

			break
		end
	end
end