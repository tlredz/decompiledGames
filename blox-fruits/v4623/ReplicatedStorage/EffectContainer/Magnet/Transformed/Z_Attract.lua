local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Attract = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Z_Attract")
local rockets = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Rockets")
local rocketsArcsteel = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("RocketsArcsteel")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player, rig)
	if typeof(rig) == "Instance" and rig:GetAttribute("Arcsteel") then
		return true
	end

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

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(p, p2)
	return WrapColor3Constructor(p2, p, "MagnetFruitVFXColor")
end

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

local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
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

local function GroundHit(p, raycastParams, folder)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function AlignCFrame(data, normal)
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
			local v2 = AlignCFrame(CFrame.new(p2.Position), p2.Normal) + p2.Normal * 0.01
			local v3 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v3, clone)
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
				v5.CFrame = CFrame.new(v5.Position, p2.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(
					v5.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult then
					local v6 = (v5.Position - p2.Position).Magnitude / 50
					local v7 = size * math.random(20, 40) / 10
					local v8 = size * math.random(10, 30) / 10
					local v9 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v7 / 2 + v7 * v6, v8 / 2 + v8 * v6, v9 / 2 + v9 * v6)
					v5.Position = raycastResult.Position + Vector3.new(0, -v5.Size.Y / 2, 0)
					v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-25, 25) / 5
					)
					v5.CFrame = CFrame.new(v5.Position, v2.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v6)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v5.Material = raycastResult.Instance.Material
					v5.Color = raycastResult.Instance.Color
				else
					v5:Destroy()
					v3[v5] = nil
				end

				TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v5.Position + Vector3.new(0, v5.Size.Y / 1.75, 0)
				}):Play()
				local v6 = v5
				local v7 = v5
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v6,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v6.Position + Vector3.new(
								math.random(-1, 1),
								-v6.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v6:Destroy()
					v3[v6] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local clone = z_Attract.Phase2.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 5) / 5
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.CanCollide = false
		clone.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 5000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 1.5, 0, math.random(-30, 30) * 1.5)
		local vector3 = Vector3.new(0, math.random(150, 200) * 2, 0)
		local v2 = math.random(50, 150) * 0.75
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 2.5, function()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.025 * math.random() + 0.025, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	local v2 = p * CFrame.new(0, 0, -13.5)
	local raycastResult = workspace:Raycast(
		v2.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if raycastResult then
		local v3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v4 = {
			Radius = 25,
			Size = 2,
			Duration = 1,
			Amount = 5,
			RockType = z_Attract.Phase2.CraterRock
		}
		task.spawn(function()
			local rockType = v4.RockType
			local radius = v4.Radius
			local size = v4.Size
			local duration = v4.Duration
			local amount = v4.Amount
			local v5 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			local v6 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = folder
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v6, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v7 in pairs(v6) do
					v7:Destroy()
				end

				v6 = nil
			end)
			local v7 = 360 / #v6
			local total = 0

			for _, v8 in pairs(v6) do
				total += v7
				v8.CFrame = v5 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v8.CFrame = CFrame.new(v8.Position, raycastResult.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v8.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult2 = workspace:Raycast(
					v8.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult2 then
					local v9 = (v8.Position - raycastResult.Position).Magnitude / 50
					local v10 = size * math.random(20, 40) / 10
					local v11 = size * math.random(10, 30) / 10
					local v12 = size * math.random(30, 50) / 10
					v8.Size = Vector3.new(v10 / 2 + v10 * v9, v11 / 2 + v11 * v9, v12 / 2 + v12 * v9)
					v8.Position = raycastResult2.Position + Vector3.new(0, -v8.Size.Y / 2, 0)
					v8.CFrame = CFrame.new(v8.Position, raycastResult.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-25, 25) / 5
					)
					v8.CFrame = CFrame.new(v8.Position, v5.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v9)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v8.Material = raycastResult2.Instance.Material
					v8.Color = raycastResult2.Instance.Color
				else
					v8:Destroy()
					v6[v8] = nil
				end

				TweenService:Create(v8, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v8.Position + Vector3.new(0, v8.Size.Y / 1.75, 0)
				}):Play()
				local v9 = v8
				local v10 = v8
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
					v6[v9] = nil
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 5 do
				task.spawn(function()
					FlyRock(
						v3 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							0,
							-math.random(125, 150) / 7
						),
						raycastResult,
						folder
					)
				end)

				if i % 2 == 0 then
					task.wait(0.001 * math.random())
				end
			end
		end)
	end
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local v2

	if typeof(player) == "Instance" then
		local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

		if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
			v2 = true
		else
			local character = player.Character
			local primaryPart = character and character.PrimaryPart
			v2 = primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
		end
	else
		v2 = false
	end

	local v3 = v2 and "Arcsteel " or ""
	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local rig = data.Rig

		if not rig then
			return
		end

		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Sound:Play("Magnet_Transformed_Z_Tap_GattlingGun_Formation_02", root.Position)
		local v4 = Util.Sound:Play("Magnet_Transformed_Z_Tap_GattlingGun_Looped_Gears_01", root.Position)
		TweenService:Create(v4, TweenInfo.new(0.65), {
			Volume = 0.5
		}):Play()
		local v5

		if hasCrimsonGoldSkin(data.Player, data.Rig) then
			v5 = rocketsArcsteel
		else
			v5 = rockets
		end

		local clone = v5:Clone()
		clone.Name = player.Name .. "_MagnetRocket"
		clone:PivotTo(rig.PrimaryPart.CFrame)
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "MagnetFruitVFXColor")
		local v6 = Util.Anims:Get(clone, v3 .. "Magnet Rockets Z+V Tap Start")
		v6.Priority = Enum.AnimationPriority.Action2
		v6.Looped = false
		v6:Play()
		local v7 = Util.Anims:Get(clone, v3 .. "Magnet Rockets Z+V Tap Charge")
		v7.Looped = true
		v7:Play()
		task.spawn(function()
			while rig and root and rig.PrimaryPart and not clone:GetAttribute("Destroy") do
				if clone and rig then
					clone:PivotTo(rig.PrimaryPart.CFrame)
				end

				task.wait()
			end

			clone:Destroy()

			if v4 then
				Util.Sound:FadeOut(v4, 0.2)
			end
		end)

		repeat
			task.wait()
		until not holding or not holding.Value or root:FindFirstChild("MagnetZHeldTransition")

		Util.Debris:AddItem(folder, 2)
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local child = workspace._WorldOrigin:FindFirstChild(player.Name .. "_MagnetRocket")

		if child then
			child.Parent = folder
		end

		local root = data.Root
		local cFrame = root.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local clone = z_Attract.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		local clone2 = z_Attract.Phase1.ShootImpact:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_Z_Tap_Rockets_Release_01", root.Position)
		local mousePos = data.MousePos
		local range = data.Range
		local speed = data.Speed

		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function cubicBezier(p, p2, p3, p4, p5)
			return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
		end

		local function AlignCFrame(data2, normal)
			local v4 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
			local unit = data2.LookVector:Cross(v4).Unit
			local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
			local unit3 = unit2:Cross(v4).Unit
			return CFrame.fromMatrix(data2.Position, unit2, v4, unit3)
		end

		local scrapModelA

		if hasCrimsonGoldSkin(data.Player, data.Rig) then
			local scrapModelA2 = v.ScrapModelA
			scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

			if not scrapModelA then
				scrapModelA = scraps:FindFirstChild("ScrapModelA")
			end
		else
			scrapModelA = scraps:FindFirstChild("ScrapModelA")
		end

		scrapModelA:ScaleTo(1)
		local children = scrapModelA:GetChildren()

		local function Explosion(position)
			task.spawn(function()
				local raycastResult = workspace:Raycast(
					position + createVector(0, 1, 0),
					createVector(0, -25, 0),
					raycastParams
				)

				if raycastResult then
					local cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
					local clone3 = z_Attract.Phase2.GroundCrack:Clone()
					clone3.CFrame = cFrame2
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount") / 2.5)
						end
					end

					GroundHit(cFrame2, raycastParams, folder)
					task.spawn(function()
						local clone4 = z_Attract.Phase2.SpinSlash:Clone()
						clone4:PivotTo(CFrame.new(position))
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						local model2 = clone4.Model2

						for i = 1, 3 do
							local v6 = 1
							local clone5 = model2:Clone()

							if i ~= 1 then
								v6 = i == 2 and 0.95 or i == 3 and 0.9 or v6
							end

							clone5:ScaleTo((i * 1.075 + 7) / v6)

							for _, beam in pairs(clone5:GetDescendants()) do
								if beam:IsA("Beam") then
									beam.Enabled = true
								end
							end

							local primaryPart = clone5.PrimaryPart
							local v7 = clone4.PrimaryPart.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.Position
							angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
							clone5:PivotTo(v7)
							Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
							clone5:GetScale()
							task.spawn(function()
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 5,
											math.random(-5, 5) / 5,
											math.random(5, 10)
										)
									}
								):Play()
								task.wait(0.05 * math.random() + 0.075 / v6)

								for i2, effect in pairs(clone5:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(
											effect,
											TweenInfo.new(0.1 / v6 + math.random() * 0.1 / v6),
											{
												Width0 = 0,
												Width1 = 0
											}
										):Play()
										local v9 = effect
										task.delay(1, function()
											v9:Destroy()
										end)
									elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end

								task.wait(1)
								angularVelocity.Enabled = false
							end)
						end

						task.spawn(function()
							local v5 = clone4:GetScale() * 0.75
							local v6 = v5 * 1.15

							for i = v5 * 100, v6 * 100, 10 do
								clone4:ScaleTo(i / 100)
								task.wait(0.005)
							end
						end)
					end)
				end
			end)
			task.spawn(function()
				local clone3 = z_Attract.Phase2.ExplosionFinalModel:Clone()
				clone3:PivotTo(CFrame.new(position))
				Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
				Util.Sound:Play("Magnet_Transformed_Z_Tap_Rocket_Explode_0" .. tostring(math.random(1, 3)), position)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") / 2)
					end
				end

				for _ = 1, 3 do
					task.spawn(function()
						local clone4 = children[math.random(1, #children)]:Clone()
						local v4 = position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
						clone4.CFrame = CFrame.new(v4)
						clone4.Anchored = false
						clone4.CanCollide = false
						clone4.Size = clone4.Size * math.random(10, 15) / 10
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						task.delay(0.15, function()
							clone4.CanCollide = true
						end)
						clone4.AssemblyLinearVelocity = (v4 - position).Unit * (math.random(200, 300) / 3) + Vector3.new(
							math.random(-25, 25),
							math.random(30, 80),
							math.random(-25, 25)
						)
						clone4.AssemblyAngularVelocity = Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
						task.delay(1 + math.random() * 0.5, function()
							TweenService:Create(clone4, TweenInfo.new(0.5), {
								Size = createVector(0, 0, 0)
							}):Play()
							task.wait(0.5)
							clone4:Destroy()
						end)
					end)
				end

				for i = 1, math.random(1, 3) do
					local v4 = i
					task.spawn(function()
						local clone4 = script.Part:Clone()
						local cFrame2 = CFrame.new(clone3.PrimaryPart.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.rad((math.random(-180, 180))),
							math.random(-180, 180)
						) * CFrame.new(0, 0, -40.5)
						clone4.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						clone4.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 81).Position
						local shafiBolt = ShafiBolt(clone4.Attach0, clone4.Attach1, math.random(8, 12), 0.75, folder)
						shafiBolt.CurveSize0 = -27
						shafiBolt.CurveSize1 = 27
						shafiBolt.Frequency = math.random(5, 10)
						shafiBolt.MaxRadius = 5
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						shafiBolt.Color = WrapColor3Constructor(
							Color3.fromRGB(26, 60, 255),
							player,
							"MagnetFruitVFXColor"
						)

						if v4 % 2 == 0 then
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(48, 79, 255),
								player,
								"MagnetFruitVFXColor"
							)
						end

						task.spawn(function()
							task.wait(0.1 + math.random() * 0.135)
							shafiBolt:Destroy()
						end)
					end)
				end

				local clone4 = z_Attract.Phase2.Sphere:Clone()
				clone4.Size = createVector(30, 30, 30)
				clone4.CFrame = CFrame.new(position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				)
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				task.spawn(function()
					TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = clone4.Size * 2.7
					}):Play()

					for _, decal in pairs(clone4:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						decal.Transparency = math.random(0, 30) / 100
						TweenService:Create(
							decal,
							TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end)
				task.spawn(function()
					local clone5 = z_Attract.Phase2.Sphere1:Clone()
					clone5.Size = createVector(30, 30, 30)
					clone5.CFrame = CFrame.new(position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					task.spawn(function()
						TweenService:Create(
							clone5,
							TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = clone5.Size * 2.7
							}
						):Play()

						for _, decal in pairs(clone5:GetDescendants()) do
							if not decal:IsA("Decal") then
								continue
							end

							decal.Transparency = math.random(50, 80) / 100
							TweenService:Create(
								decal,
								TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									Transparency = 1,
									StudsPerTileU = math.random(15, 20) * 2,
									StudsPerTileV = math.random(15, 20) * 2
								}
							):Play()
						end
					end)
				end)
			end)
		end

		local function MissileCurve(folder2, position, position2, speed2, raycastParams2)
			local magnitude = (position2 - position).Magnitude

			if magnitude < 5 then
				position2 = position + CFrame.new(position, position2).LookVector * 5
				magnitude = 5
			end

			local v4 = magnitude / speed2
			local v5 = math.clamp(magnitude / range, 0, 1)
			local v6 = v5 * 150
			local v7 = v5 * 50
			folder2:PivotTo(CFrame.new(position, position2))
			local unit = (position2 - position).Unit
			local cross = unit:Cross(createVector(0, 1, 0))
			local unit2 = (cross.Magnitude < 0.1 and createVector(1, 0, 0) or cross).Unit
			local v8 = position + unit * (magnitude * 0.3) + unit2 * math.random(-v6, v6) + createVector(0, 1, 0) * v7
			local v9 = position + unit * (magnitude * 0.7) + unit2 * math.random(-v6, v6) + createVector(0, 1, 0) * math.random(
				5,
				(math.max(5, (math.floor(v7))))
			)
			local lastTime = tick()
			local v10 = position
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v11 = (tick() - lastTime) / v4

				if v11 >= 1 then
					folder2:PivotTo(CFrame.new(position2))
					heartbeatConnection:Disconnect()
					Explosion(position2)

					if (workspace.CurrentCamera.CFrame.p - position2).Magnitude < 45 then
						Util.CameraShaker:ShakeOnce(5, 3, 0.1, 0.35)
					end

					for _, descendant in pairs(folder2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("BasePart") then
							descendant.Transparency = 1
						end
					end
				else
					local v16 = cubicBezier(v11, position, v8, v9, position2)
					local v17 = v16 - v10
					local raycastResult = v17.Magnitude > 0.01 and workspace:Raycast(v10, v17, raycastParams2)

					if raycastResult then
						heartbeatConnection:Disconnect()
						local position3 = raycastResult.Position
						folder2:PivotTo(CFrame.new(position3))
						Explosion(position3)
						folder2:Destroy()
					else
						local v18 = v16 - v10

						if v18.Magnitude > 0 then
							folder2:PivotTo(CFrame.lookAt(v16, v16 + v18))
						else
							folder2:PivotTo(CFrame.new(v16))
						end

						v10 = v16
					end
				end
			end)
		end

		math.randomseed(data.Seed)
		local vectors = {}

		for i = 1, 10 do
			vectors[i] = Vector3.new(math.random(-15, 15), math.random(-5, 5), math.random(-15, 15))
		end

		if child then
			local v4 = Util.Anims:Get(child, v3 .. "Magnet Rockets Z+V Tap Release")
			v4.Priority = Enum.AnimationPriority.Action2
			v4.Looped = false
			v4:Play()
			task.delay(0.3333333333333333, function()
				child:SetAttribute("Destroy", true)
			end)
		end

		local frontL = child and child:FindFirstChild("Front.L", true)
		local frontR = child and child:FindFirstChild("Front.R", true)

		for i = 1, 2 do
			local v4 = i
			task.spawn(function()
				local clone3 = z_Attract.Phase1.Arm:Clone()
				clone3.Transparency = 1
				Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
				clone3.CFrame = cFrame
				local v5 = v4 == 1 and 15 or v4 == 2 and -15 or nil
				clone3.CFrame *= CFrame.new(v5, 0, -5)

				for i2 = 1, 5 do
					local v6 = i2
					task.spawn(function()
						local value = mousePos.Value
						cFrame = CFrame.new(
							v4 == 1 and frontR.WorldPosition or frontL.WorldPosition,
							(Vector3.new(value.X, root.Position.Y, value.Z))
						)
						clone3.CFrame = cFrame
						local cFrame2 = clone3.CFrame * CFrame.new(0, 0, -3)
						local v8

						if hasCrimsonGoldSkin(data.Player, data.Rig) then
							v8 = z_Attract.Phase1.ProjectileArcsteel
						else
							v8 = z_Attract.Phase1.Projectile
						end

						local clone4 = v8:Clone()
						clone4:PivotTo(cFrame2)
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						clone2.CFrame = cFrame2

						for i3, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount") / 2)
							end
						end

						task.delay(0, function()
							clone.CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 0, -7)

							for i3, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end
						end)
						task.spawn(function()
							for i3, effect in pairs(clone4:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								effect.Enabled = false
								local v9 = effect
								task.delay(0.015, function()
									v9.Enabled = true
								end)
							end
						end)
						local position = cFrame2.Position
						local v9 = value - position

						if range < v9.Magnitude then
							value = position + v9.Unit * range
						end

						local v11 = value + vectors[(v4 - 1) * 5 + v6]
						MissileCurve(clone4, cFrame2.Position, v11, speed, raycastParams)
					end)
					task.wait(0.075)
				end

				task.wait(0.15)
				clone3:Destroy()
			end)
			task.wait()
		end
	end
end