local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local c_Attract = FX:WaitForChild("Magnet"):WaitForChild("C_Attract")
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

local function QuadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
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

local function Explosion(endCFrame, child, raycastParams, claim)
	local function Scale(instance, p)
		local position = endCFrame.Position

		if instance.ClassName ~= "Model" then
			local model = Instance.new("Model")
			model.Parent = instance.Parent
			instance.Parent = model
			instance = model
		end

		instance:ScaleTo(p)
		local v2 = position + (instance:GetPivot().Position - position) * p
		instance:PivotTo(instance:GetPivot().Rotation + v2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(instance, duration)
		task.delay(duration, function()
			instance:Destroy()
		end)
	end

	local function RockCrater(p, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
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
				v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v6 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v7 = (v5.Position - p.Position).Magnitude / 200
					local v8 = size * math.random(20, 40) / 10
					local v9 = size * math.random(10, 30) / 10
					local v10 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v8 * v7, v9 * v7, v10 * v7)
					v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
					v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
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
				else
					v5:Destroy()
					v3[v5] = nil
				end

				TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v5.Position + Vector3.new(0, v5.Size.Y * math.random(3, 5) / 10, 0)
				}):Play()
				local v7 = v5
				local v8 = v5
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v7,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v7.Position + Vector3.new(
								math.random(-1, 1),
								-v7.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v7:Destroy()
					v3[v7] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local parent2 = VfxPool.PreparedClones.take(claim, "flyRocks", c_Attract.Rock)
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
		bodyVelocity.Parent = parent2
		local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
		local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
		local v3 = math.random(50, 250) * 1.25
		bodyVelocity.Velocity = CFrame.new(parent2.Position, parent2.Position + vector2 + vector3).LookVector * v3
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
		endCFrame.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local v2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v3 = {
		Radius = 75,
		Size = 13.75,
		Duration = 0.75,
		Amount = 35,
		RockType = c_Attract.CraterRock
	}
	task.spawn(function()
		local rockType = v3.RockType
		local radius = v3.Radius
		local size = v3.Size
		local duration = v3.Duration
		local amount = v3.Amount
		local v4 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
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
				local v10 = size * math.random(20, 40) / 10
				local v11 = size * math.random(10, 30) / 10
				local v12 = size * math.random(30, 50) / 10
				v7.Size = Vector3.new(v10 * v9, v11 * v9, v12 * v9)
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
			else
				v7:Destroy()
				v5[v7] = nil
			end

			TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v9 = v7
			local v10 = v7
			task.spawn(function()
				task.wait(duration + math.random(10, 35) / 100)
				local tween = TweenService:Create(
					v9,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v9.Position + Vector3.new(
							math.random(-1, 1),
							-v9.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v9:Destroy()
				v5[v9] = nil
			end)
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
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "MagnetCTap_" .. player.Name
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

		local v5 = begin(name, "CTapLanding", {
			scraps = {
				Templates = getScrapChildren(scrapModelA, 3.125),
				Count = 40
			},
			airSpins = {
				Template = c_Attract.Phase2.AirSpin,
				Count = 3
			},
			airSpinLayers = {
				Template = c_Attract.Phase2.AirSpin.Model,
				Count = 6
			},
			upwardSlashRings = {
				Template = c_Attract.Phase2.SpinSlashModel,
				Count = 9
			},
			downwardSlashRings = {
				Template = c_Attract.Phase2.SpinSlashModel2,
				Count = 9
			},
			startBeams = {
				Template = c_Attract.Phase3.StartBeam,
				Count = 3
			},
			craterRocks = {
				Template = c_Attract.CraterRock,
				Count = 35
			},
			flyRocks = {
				Template = c_Attract.Rock,
				Count = 20
			},
			screenColors = {
				Template = c_Attract.Phase3.ScreenColor,
				Count = 1
			},
			downImpacts = {
				Template = c_Attract.Phase2.DownImpact,
				Count = 1
			},
			slamImpacts = {
				Template = c_Attract.Phase2.SlamImpact,
				Count = 1
			},
			explosionStarts = {
				Template = c_Attract.Phase2.ExplosionStart,
				Count = 1
			},
			groundSlamImpacts = {
				Template = c_Attract.Phase2.GroundSlamImpact,
				Count = 1
			},
			middleSphereLayers = {
				Template = c_Attract.Phase1.Sphere1,
				Count = 1
			},
			magnetAuras = {
				Template = c_Attract.Phase2.MagnetAura,
				Count = 1
			},
			groundCracks = {
				Template = c_Attract.Phase3.GroundCrack,
				Count = 1
			},
			groundImpacts = {
				Template = c_Attract.Phase3.GroundImpact,
				Count = 1
			},
			impactSpheres = {
				Template = c_Attract.Phase1.Sphere,
				Count = 1
			},
			impactSphereLayers = {
				Template = c_Attract.Phase1.Sphere1,
				Count = 1
			},
			boltAnchors = {
				Template = script.Part,
				Count = 10
			}
		})
		folder.Destroying:Once(function()
			VfxPool.PreparedClones.discard(player.Name, "CTapLanding", v5)
		end)
		local root = data.Root
		root.Parent:FindFirstChild("FloatingRightArm", true)
		local position = root.Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v6

		if magnetArms then
			local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
			v6 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet C Tap Charge Arm Start") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v6 then
			v6.Priority = Enum.AnimationPriority.Action2
			v6.Looped = false
			v6:Play()
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v7

		if magnetArms2 then
			local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
			v7 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet C Tap Charge Arm Loop") or nil
		else
			warn("Magnet Arms Folder missing!")
			v7 = nil
		end

		if v7 then
			v7.Looped = true
			v7:Play()
		end

		local cFrame = root.CFrame * CFrame.new(0, 1, 0)
		local v9 = VfxPool.takeBurst(player, "CTapPullImpact125", c_Attract.Phase1.PullImpact, 1, function(folder2)
			for _, emitter in pairs(folder2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.25, lifetime.Max * 1.25)
			end

			VfxPool.thinBurstHaze(folder2)
		end)
		v9.Model.CFrame = cFrame
		VfxPool.emitBurst(v9)
		task.delay(0.1, function()
			local v10 = VfxPool.takeBurst(player, "CTapPullImpact85", c_Attract.Phase1.PullImpact, 1, function(folder2)
				for _, emitter in pairs(folder2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 0.85, lifetime.Max * 0.85)
				end

				VfxPool.thinBurstHaze(folder2)
			end)
			v10.Model.CFrame = cFrame

			for _ = 1, 3 do
				task.spawn(function()
					VfxPool.emitBurst(v10)
					VfxPool.spherePulse({
						Owner = player,
						Template = c_Attract.Phase1.Sphere,
						RingKey = "CTapPulseSphere",
						RingSize = 3,
						CFrame = CFrame.new(cFrame.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						),
						StartSize = createVector(135, 135, 135),
						EndSize = createVector(0, 0, 0),
						Transparency = 0.795,
						Prepare = function(instance)
							local highlight = instance:FindFirstChildOfClass("Highlight")

							if highlight then
								highlight:Destroy()
							end
						end
					})
					VfxPool.spherePulse({
						Owner = player,
						Template = c_Attract.Phase1.Sphere1,
						RingKey = "CTapPulseSphere1",
						RingSize = 3,
						CFrame = CFrame.new(cFrame.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						),
						StartSize = createVector(135, 135, 135),
						EndSize = createVector(0, 0, 0),
						Transparency = 0.875,
						TileTween = true
					})
				end)
				task.wait(0.1)
			end
		end)
		tick()
		tick()
		task.spawn(function()
			for _ = 1, 13 do
				local position2 = cFrame.Position
				task.spawn(function()
					task.wait(math.random() * 0.225)
					local v11 = math.random(45, 50) / 170
					local clone = c_Attract.Phase1.TrailModel:Clone()
					clone.Start.CFrame = CFrame.new(position2) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					clone:ScaleTo(math.random(10, 20) / 10)
					local start = clone.Start
					local trail = clone.Trail
					local cframe = CFrame.new(0, 0, -math.random(100, 150) * 0.5)
					TweenService:Create(trail.Weld, TweenInfo.new(v11 / 5), {
						C1 = cframe
					}):Play()
					TweenService:Create(start, TweenInfo.new(v11), {
						CFrame = CFrame.new(position2) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v11 / 3, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v11), {
							C1 = CFrame.new(0, 0, 0)
						}):Play()
						start.AlignPosition.Position = position2
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

					for i, effect in pairs(clone:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v12 = effect
						task.delay(v11 + v11 / 5, function()
							v12.Enabled = false
						end)
					end

					task.wait(v11)
					angularVelocity.Enabled = false
					task.wait(v11)
					clone:Destroy()
				end)
			end
		end)
		local clone = c_Attract.Phase1.Arm:Clone()
		VfxPool.thinStreamingHaze(clone, 3)
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		tick()
		local v10 = Util.Sound:Play("Magnet_Untransformed_C_Tap_Held_Variant_01", root)
		local flag = false

		while holding and holding:IsDescendantOf(workspace) and holding.Value do
			cFrame = root.CFrame * CFrame.new((position - root.Position).Magnitude, 1, -4.25)

			if not (holding and holding.Value) then
				break
			end

			if root:FindFirstChild("MagnetCHeldTrigger") then
				flag = true
				break
			else
				task.wait()
			end
		end

		if v10 then
			Util.Sound:FadeOut(v10, 0.1)
		end

		if flag then
			if v7 then
				v7:Stop()
			end
		else
			task.delay(0.2, function()
				if v7 then
					v7:Stop()
				end
			end)
		end

		Util.Debris:AddItem(folder, 10)
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild("MagnetCTap_" .. player.Name)

		if not child then
			return
		end

		local claim = VfxPool.PreparedClones.claim(player.Name, "CTapLanding")
		child.Destroying:Once(function()
			VfxPool.PreparedClones.destroy(claim)
		end)
		child.Name = "DESTROYING"
		local arm = child:FindFirstChild("Arm")

		if not arm then
			print("ArmPart missing")
			return
		end

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

		local scrapChildren = getScrapChildren(scrapModelA, 3.125)

		for _, emitter in pairs(arm:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local startCFrame = data.StartCFrame
		local parent = root.Parent
		local magnetArmFunctions = root.Parent:FindFirstChild("MagnetArmFunctions")

		if magnetArmFunctions then
			local folder = Instance.new("Folder")
			folder.Name = "HoldingSkill"
			folder:SetAttribute("HardSnap", true)
			folder.Parent = magnetArmFunctions
			Util.Debris:AddItem(folder, 1)
		end

		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.FillColor = Color3.new(0, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.Adornee = parent
		highlight.Parent = parent
		TweenService:Create(highlight, TweenInfo.new(0.1), {
			FillTransparency = 0.2
		}):Play()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v2

		if magnetArms then
			local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
			v2 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet C Tap Release Arm Start") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v2 then
			v2.Priority = Enum.AnimationPriority.Action2
			v2.Looped = false
			v2:Play()
		end

		local v3 = Util.Anims:Get(root.Parent, "Magnet New C Tap Release Loop")
		v3.Looped = true
		v3.Priority = Enum.AnimationPriority.Action
		v3:Play()
		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v4

		if magnetArms2 then
			local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
			v4 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet C Tap Release Arm Loop") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		v4.Looped = true
		v4:Play()
		local v5 = VfxPool.takeBurst(player, "CTapExStartImpact", c_Attract.Phase2.ExStartImpact)
		local v6 = data.UpCFrame.Position - startCFrame.Position
		local unit = v6.Magnitude > 0.01 and v6.Unit or createVector(0, 1, 0)
		local v7 = startCFrame.Position + unit
		v5.Model.CFrame = AlignCFrame(CFrame.new(v7, v7 + startCFrame.LookVector), unit)
		Util.Sound:Play("Magnet_Untransformed_C_Tap_Release_Explode_01", root)
		VfxPool.emitBurst(v5)
		task.spawn(function()
			task.wait(0.175)
			local clone = c_Attract.Phase2.SpinSlash:Clone()
			clone:PivotTo(AlignCFrame(CFrame.new(v7, v7 + startCFrame.LookVector), unit) * CFrame.new(0, 15, 0))
			Util.SetParentOverrideWithColor(clone, child, player, "MagnetFruitVFXColor")
			local model = clone.Model

			for i = 1, 5 do
				local v8 = i * 1 + 4.25
				local clone2 = model:Clone()
				clone2:ScaleTo(v8)
				local primaryPart = clone2.PrimaryPart
				local v9 = clone.PrimaryPart.CFrame * CFrame.new(0, v8 * i, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
					math.random(-10, 10) / 10,
					-v8 * 2,
					math.random(-10, 10) / 10
				)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
				clone2:PivotTo(v9)
				Util.SetParentOverrideWithColor(clone2, clone, player, "MagnetFruitVFXColor")
				clone2:GetScale()
				local folder = clone2
				task.spawn(function()
					task.spawn(function()
						local Y = folder.Slash.Position.Y
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 5,
									math.random(5, 15) * 2,
									math.random(-5, 5) / 5
								)
							}
						):Play()
					end)
					task.wait(0.1 * math.random() + 0.1)

					for i2, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.15 + math.random() * 0.1), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v11 = effect
							task.delay(1, function()
								v11:Destroy()
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
				local scale = clone:GetScale()
				local v8 = scale * 1.15

				for i = scale * 100, v8 * 100, 5 do
					clone:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.wait(WAIT_INTERVAL)
		root.Anchored = true
		TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = data.UpCFrame
		}):Play()
		task.wait(0.35)
		task.wait(WAIT_INTERVAL)
		local endCFrame = data.EndCFrame
		local v8 = VfxPool.takePreparedBurst(
			player,
			"CTapDownImpact",
			c_Attract.Phase2.DownImpact,
			claim,
			"downImpacts",
			1,
			VfxPool.thinBurstHaze
		)
		v8.Model.CFrame = endCFrame * CFrame.new(0, 50, 0)
		VfxPool.emitBurst(v8)
		local v9 = VfxPool.takePreparedBurst(
			player,
			"CTapSlamImpact",
			c_Attract.Phase2.SlamImpact,
			claim,
			"slamImpacts",
			1,
			VfxPool.thinBurstHaze
		)
		v9.Model.CFrame = endCFrame
		VfxPool.emitBurst(v9)
		TweenService:Create(root, TweenInfo.new(0.1), {
			CFrame = endCFrame
		}):Play()
		task.spawn(function()
			local function QuadBezier2(p, p2, p3, p4)
				return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
			end

			for i = 1, 20 do
				local v10 = i
				task.spawn(function()
					local v11 = v10 / 20 * 3.141592653589793 * 2
					local v12 = math.random(5, 100)
					local vector2 = Vector3.new(math.cos(v11) * v12, 0, math.sin(v11) * v12)
					local v13 = endCFrame.Position + vector2
					local v14 = VfxPool.PreparedClones.take(
						claim,
						"scraps",
						scrapChildren[math.random(1, #scrapChildren)]
					)
					v14.Anchored = true
					v14.CanCollide = false
					Util.SetParentOverrideWithColor(v14, child, player, "MagnetFruitVFXColor")
					local v15 = VfxPool.takeHighlight(c_Attract.Phase1.Highlight, v14, player)

					if v15 then
						v15.Enabled = true
					end

					local position = v13 + createVector(0, 5, 0) + Vector3.new(0, math.random(5, 100), 0)
					local v17 = (v13 + position) / 2 + Vector3.new(
						math.random(-5, 5) * 2,
						math.random(6, 12) * 2,
						math.random(-5, 5) * 2
					)
					local lastTime = tick()
					VfxPool.addStep(function()
						if not v14.Parent then
							return true
						end

						local v18 = (tick() - lastTime) / 0.785

						if v18 >= 1 then
							v14.Position = position
							v14.Anchored = false
							v14.CanCollide = true

							if v15 then
								v15:Destroy()
							end

							task.delay(0.1, function()
								TweenService:Create(v14, TweenInfo.new(0.15), {
									Size = createVector(0, 0, 0)
								}):Play()
								task.wait(0.15)
								v14:Destroy()
							end)
							return true
						else
							local v19

							if v18 < 0.17197452229299365 then
								v19 = (v18 / 0.17197452229299365) ^ 0.6
							elseif v18 < 0.49044585987261147 then
								v19 = 0.6 + (v18 - 0.17197452229299365) / 0.3184713375796178 * 0.2
							else
								v19 = 0.8 + ((v18 - 0.49044585987261147) / 0.5095541401273885) ^ 3 * 0.2
							end

							local v23 = (1 - v19) ^ 2 * v13 + 2 * (1 - v19) * v19 * v17 + v19 ^ 2 * position
							v14.CFrame = CFrame.lookAt(v23, endCFrame.Position) * CFrame.Angles(
								math.rad(v18 * 720),
								math.rad(v18 * 360),
								(math.rad(v18 * 180))
							)
							return false
						end
					end)
				end)
			end
		end)
		task.wait(WAIT_INTERVAL)
		root.Anchored = false
		local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
		local v10

		if magnetArms3 then
			local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
			v10 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet C Tap Release Land Arm") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		v10.Priority = Enum.AnimationPriority.Action4
		v10:Play()
		local v11 = Util.Anims:Get(root.Parent, "Magnet New C Tap Release Land")
		v11.Looped = false
		v11.Priority = Enum.AnimationPriority.Action4
		v11:Play()

		if v4 then
			v4:Stop()
		end

		if v3 then
			v3:Stop()
		end

		arm:Destroy()
		local v12 = VfxPool.takePreparedBurst(
			player,
			"CTapExplosionStart",
			c_Attract.Phase2.ExplosionStart,
			claim,
			"explosionStarts"
		)
		v12.Model.CFrame = endCFrame

		if (workspace.CurrentCamera.CFrame.p - endCFrame.Position).Magnitude < 120 then
			Util.CameraShaker:ShakeOnce(5, 4, 0.1, 0.4)
		end

		VfxPool.emitBurst(v12)
		task.wait(0.05)
		local v13 = VfxPool.takePreparedBurst(
			player,
			"CTapGroundSlamImpact",
			c_Attract.Phase2.GroundSlamImpact,
			claim,
			"groundSlamImpacts",
			1,
			VfxPool.thinBurstHaze
		)
		v13.Model.CFrame = endCFrame
		VfxPool.emitBurst(v13)
		VfxPool.spherePulse({
			Owner = player,
			Template = c_Attract.Phase1.Sphere1,
			RingKey = "CTapImpactSphere1Mid",
			CFrame = CFrame.new(endCFrame.Position + createVector(0, 15, 0), workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
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
		local v15 = VfxPool.takePreparedBurst(
			player,
			"CTapMagnetAura",
			c_Attract.Phase2.MagnetAura,
			claim,
			"magnetAuras",
			1,
			function(p)
				VfxPool.thinStreamingHaze(p, 3)
			end
		)
		v15.Model:PivotTo(endCFrame)

		for _, emit in v15.Emits do
			local emitter = emit.Emitter
			emitter:Emit(1)
			task.spawn(function()
				emitter.Enabled = true
				task.wait(0.3)
				emitter.Enabled = false
			end)
		end

		task.wait(WAIT_INTERVAL)
		task.wait(0.15)
		TweenService:Create(highlight, TweenInfo.new(0.4), {
			FillTransparency = 1
		}):Play()
		task.delay(0.4, function()
			highlight:Destroy()
		end)
		local v16 = VfxPool.takePreparedBurst(
			player,
			"CTapGroundCrack",
			c_Attract.Phase3.GroundCrack,
			claim,
			"groundCracks",
			1,
			function(folder)
				for _, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				end

				VfxPool.thinBurstHaze(folder)
			end
		)
		v16.Model.CFrame = endCFrame
		VfxPool.emitBurst(v16)
		task.delay(0.05, function()
			task.wait(0.025)
			task.spawn(function()
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Parent = game.Lighting
				bloomEffect.Size += 10
				local v17 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
					Size = 54
				}):Play()
				task.delay(0.1, function()
					v17 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
						Size = 0
					}):Play()
					task.wait(0.1)
					bloomEffect:Destroy()
				end)
				local v18 = VfxPool.PreparedClones.take(claim, "screenColors", c_Attract.Phase3.ScreenColor)
				v18.Parent = game.Lighting
				local tween = TweenService:Create(v18, TweenInfo.new(0.025), {
					Brightness = v18.Brightness,
					Contrast = v18.Contrast,
					Saturation = v18.Saturation,
					TintColor = v18.TintColor
				})
				v18.Brightness = 0
				v18.Contrast = 0
				v18.Saturation = 0
				v18.TintColor = Color3.fromRGB(255, 255, 255)
				tween:Play()
				task.wait(0.075)
				local tween2 = TweenService:Create(v18, TweenInfo.new(0.0125), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween2:Play()
				tween2.Completed:Wait()
				v18:Destroy()
			end)
			local raycastResult = workspace:Raycast(
				endCFrame.Position + createVector(0, 1, 0),
				createVector(-0, -25, -0),
				raycastParams
			)
			local v17 = VfxPool.takePreparedBurst(
				player,
				"CTapGroundImpact",
				c_Attract.Phase3.GroundImpact,
				claim,
				"groundImpacts",
				1,
				VfxPool.thinBurstHaze
			)
			v17.Model.CFrame = endCFrame * CFrame.new(0, -3.75, 0)
			local groundAura

			if raycastResult then
				groundAura = nil
			else
				groundAura = v17.Model:FindFirstChild("GroundAura")
			end

			VfxPool.emitBurst(v17, nil, groundAura)
			task.delay(0.1, function()
				VfxPool.emitBurst(v17, 0.5, groundAura)
				task.wait(0.1)
				VfxPool.emitBurst(v17, 0.5, groundAura)
			end)
		end)
		task.spawn(function()
			for i = 1, 3 do
				local v17 = i
				task.spawn(function()
					local v18 = 10
					local v19 = VfxPool.PreparedClones.take(claim, "airSpins", c_Attract.Phase2.AirSpin)
					v19:PivotTo(endCFrame * CFrame.new(0, 10, 0))
					Util.SetParentOverrideWithColor(v19, child, player, "MagnetFruitVFXColor")

					if v17 == 2 then
						v19:PivotTo(endCFrame * CFrame.new(0, 25, 0))
						v18 = 11
					elseif v17 == 3 then
						v19:PivotTo(endCFrame * CFrame.new(0, 50, 0))
						v18 = 12
					end

					local model = v19.Model

					for i2 = 1, 2 do
						local v20 = v18 + 3 + i2 * 1.05
						local v21 = VfxPool.PreparedClones.take(claim, "airSpinLayers", model)
						v21:ScaleTo(v20)
						local primaryPart = v21.PrimaryPart
						local v22 = v19.PrimaryPart.CFrame * CFrame.new(0, v20, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						local angularVelocity = primaryPart.AngularVelocity
						primaryPart.Anchored = false
						primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
							math.random(-10, 10) / 10,
							0,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(
							math.random(-5, 5) / 5,
							math.random(10, 15) * 3,
							math.random(-5, 5) / 5
						)
						v21:PivotTo(v22)
						Util.SetParentOverrideWithColor(v21, v19, player, "MagnetFruitVFXColor")
						v21:GetScale()
						local folder = v21
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
									local v24 = effect
									task.delay(1, function()
										v24:Destroy()
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
						local scale = v19:GetScale()
						local v20 = scale * 1.75

						for i2 = scale * 100, v20 * 100, 5 do
							v19:ScaleTo(i2 / 100)
							task.wait(0.005)
						end
					end)
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 3 do
				local v17 = i
				task.spawn(function()
					local v18 = 3
					local v19 = CFrame.new(endCFrame.Position) * CFrame.new(0, -3, 0)
					local v20 = 10

					if v17 == 2 then
						v20 = 15
						v18 = 5
					elseif v17 == 3 then
						v20 = 25
						v18 = 7
					end

					for i2 = 1, 3 do
						task.spawn(function()
							local v21 = VfxPool.PreparedClones.take(
								claim,
								"upwardSlashRings",
								c_Attract.Phase2.SpinSlashModel
							)
							local primaryPart = v21.PrimaryPart
							primaryPart.CFrame = v19 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
							Util.SetParentOverrideWithColor(v21, child, player, "MagnetFruitVFXColor")
							v21:ScaleTo(3)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
								math.random(-10, 10) / 10,
								0,
								math.random(-10, 10) / 10
							)
							angularVelocity.AngularVelocity = Vector3.new(
								math.random(-5, 5) / 5,
								math.random(10, 15) * 2,
								math.random(-5, 5) / 5
							)
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									AngularVelocity = createVector(0, 0, 0)
								}
							):Play()
							TweenService:Create(
								primaryPart.AlignPosition,
								TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Position = primaryPart.Position + Vector3.new(0, v20, 0)
								}
							):Play()

							for i3, descendant in pairs(primaryPart:GetDescendants()) do
								if descendant:IsA("Beam") then
									local v22 = descendant
									task.spawn(function()
										v22.Width0 = v22.Width0 * v18 / 2
										v22.Width1 = v22.Width1 * v18 / 2
										TweenService:Create(
											v22,
											TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
											{
												CurveSize0 = v22.CurveSize0 * v18,
												CurveSize1 = v22.CurveSize1 * v18,
												Width0 = v22.Width0 * 2,
												Width1 = v22.Width1 * 2
											}
										):Play()
										task.wait(0.15)
										local tween = TweenService:Create(
											v22,
											TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Width0 = 0,
												Width1 = 0
											}
										)
										tween:Play()
										tween.Completed:Wait()
										v22:Destroy()
									end)
								elseif descendant:IsA("Attachment") then
									TweenService:Create(
										descendant,
										TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{
											Position = Vector3.new(
												descendant.Position.X * v18,
												descendant.Position.Y * v18,
												descendant.Position.Z * v18
											)
										}
									):Play()
								end
							end
						end)
						task.wait(0.1)
					end
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 3 do
				local v17 = i
				task.spawn(function()
					local v18 = 3.5
					local v19 = CFrame.new(endCFrame.Position) * CFrame.new(0, 25, 0)
					local v20 = -10
					local v21 = 2

					if v17 == 2 then
						v20 = -15
						v21 = 1.5
						v18 = 5
					elseif v17 == 3 then
						v20 = -25
						v21 = 1.25
						v18 = 7
					end

					for i2 = 1, 3 do
						task.spawn(function()
							local v22 = VfxPool.PreparedClones.take(
								claim,
								"downwardSlashRings",
								c_Attract.Phase2.SpinSlashModel2
							)
							local primaryPart = v22.PrimaryPart
							primaryPart.CFrame = v19 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
							Util.SetParentOverrideWithColor(v22, child, player, "MagnetFruitVFXColor")
							v22:ScaleTo(3)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
								math.random(-10, 10) / 10,
								0,
								math.random(-10, 10) / 10
							)
							angularVelocity.AngularVelocity = Vector3.new(
								math.random(-5, 5) / 5,
								math.random(10, 15) * 1,
								math.random(-5, 5) / 5
							)
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									AngularVelocity = createVector(0, 0, 0)
								}
							):Play()
							TweenService:Create(
								primaryPart.AlignPosition,
								TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Position = primaryPart.Position + Vector3.new(0, v20, 0)
								}
							):Play()

							for i3, descendant in pairs(primaryPart:GetDescendants()) do
								if descendant:IsA("Beam") then
									local v23 = descendant
									task.spawn(function()
										v23.Width0 *= v21
										v23.Width1 *= v21
										TweenService:Create(
											v23,
											TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
											{
												CurveSize0 = v23.CurveSize0 * v18,
												CurveSize1 = v23.CurveSize1 * v18,
												Width0 = v23.Width0 * 1.25,
												Width1 = v23.Width1 * 1.25
											}
										):Play()
										task.wait(0.15)
										TweenService:Create(
											v23,
											TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Width0 = v23.Width0 / 2,
												Width1 = v23.Width1 / 2
											}
										):Play()

										for i4 = 90, 100 do
											v23.Transparency = NumberSequence.new(i4 / 100, i4 / 100)
											task.wait(0.015)
										end

										v23:Destroy()
									end)
								elseif descendant:IsA("Attachment") then
									TweenService:Create(
										descendant,
										TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{
											Position = Vector3.new(
												descendant.Position.X * v18,
												descendant.Position.Y * v18,
												descendant.Position.Z * v18
											)
										}
									):Play()
								end
							end
						end)
						task.wait(0.1)
					end
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 3 do
				local v17 = 7
				local v18 = 0.15
				local v19 = 5
				local cFrame = CFrame.new(endCFrame.Position) * CFrame.new(0, 10, 0)

				if i == 2 then
					v18 = 0.1
					v19 = 10
					v17 = 8
				elseif i == 3 then
					v18 = 0.085
					v19 = 15
					v17 = 10
				end

				local folder = VfxPool.PreparedClones.take(claim, "startBeams", c_Attract.Phase3.StartBeam)
				folder.CFrame = cFrame
				Util.SetParentOverrideWithColor(folder, child, player, "MagnetFruitVFXColor")
				TweenService:Create(folder, TweenInfo.new(v18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = folder.CFrame * CFrame.new(0, v19, 0)
				}):Play()

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v21 = descendant
						task.spawn(function()
							TweenService:Create(
								v21,
								TweenInfo.new(v18 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v21.CurveSize0 * v17,
									CurveSize1 = v21.CurveSize1 * v17,
									Width0 = v21.Width0,
									Width1 = v21.Width1
								}
							):Play()
							task.wait(v18 / 2)
							local tween = TweenService:Create(
								v21,
								TweenInfo.new(v18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v21:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v18 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v23 = descendant.Position.X * v17
						local v24 = descendant.Position.Y * v17
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v23, v24, descendant.Position.Z * v17)
						}):Play()
					end
				end

				task.wait(0.0025)
			end
		end)
		Explosion(endCFrame, child, raycastParams, claim)

		if (workspace.CurrentCamera.CFrame.p - endCFrame.Position).Magnitude < 200 then
			Util.CameraShaker:ShakeOnce(12, 9, 0.2, 0.6)
		end

		task.spawn(function()
			VfxPool.spherePulse({
				Owner = player,
				Template = c_Attract.Phase1.Sphere,
				RingKey = "CTapImpactSphere",
				CFrame = CFrame.new(
					endCFrame.Position + createVector(0, 15, 0),
					workspace.CurrentCamera.CFrame.Position
				) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)),
				StartSize = createVector(50, 50, 50),
				EndSize = createVector(250, 250, 250),
				Duration = 0.45,
				Transparency = 0.5,
				FadeDuration = 0.25,
				FadeStyle = Enum.EasingStyle.Back,
				FadeDirection = Enum.EasingDirection.InOut,
				Prepare = function(instance)
					local highlight2 = instance:FindFirstChildOfClass("Highlight")

					if highlight2 then
						highlight2:Destroy()
					end
				end,
				PreparedState = claim,
				PreparedKey = "impactSpheres"
			})
			VfxPool.spherePulse({
				Owner = player,
				Template = c_Attract.Phase1.Sphere1,
				RingKey = "CTapImpactSphere1",
				CFrame = CFrame.new(
					endCFrame.Position + createVector(0, 15, 0),
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
					local v17 = i
					task.spawn(function()
						local v18 = CFrame.new(endCFrame.Position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 10))
						) * CFrame.new(0, 0, -70)
						local v19 = VfxPool.takeBoltAnchor(
							player,
							script.Part,
							12,
							v18,
							v18 * CFrame.new(0, 0, 140).Position,
							claim,
							"boltAnchors"
						)
						local shafiBolt = ShafiBolt(v19.Attach0, v19.Attach1, math.random(8, 12) * 1.25, 0.75, child)
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

						if v17 % 2 == 0 then
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(35, 46, 255),
								player,
								"MagnetFruitVFXColor"
							)
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.1 + math.random() * 0.2)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
		end)

		for _ = 1, 20 do
			task.spawn(function()
				local v17 = VfxPool.PreparedClones.take(claim, "scraps", scrapChildren[math.random(1, #scrapChildren)])
				local v18 = endCFrame.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				v17.CFrame = CFrame.new(v18)
				v17.Anchored = false
				v17.CanCollide = false
				v17.Size = v17.Size * math.random(10, 15) / 10
				Util.SetParentOverrideWithColor(v17, child, player, "MagnetFruitVFXColor")
				task.delay(0.15, function()
					v17.CanCollide = true
				end)
				v17.AssemblyLinearVelocity = (v18 - endCFrame.Position).Unit * math.random(120, 220) + Vector3.new(
					math.random(-25, 25),
					math.random(30, 80),
					math.random(-25, 25)
				)
				v17.AssemblyAngularVelocity = Vector3.new(
					math.random(-20, 20),
					math.random(-20, 20),
					math.random(-20, 20)
				)
				task.delay(1 + math.random() * 0.5, function()
					TweenService:Create(v17, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
					task.wait(0.5)
					v17:Destroy()
				end)
			end)
		end
	end
end