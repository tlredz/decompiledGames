local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local lightning = Util.Lightning
local _ = Util.Sound
local _ = Util.MasterClock
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local electro2Effects = FX:WaitForChild("Electro2Effects")
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local random = Random.new()

local function flop(list)
	for i = 1, math.floor(#list / 2) do
		local v = #list - i + 1
		local v2 = list[v]
		local v3 = list[i]
		list[i] = v2
		list[v] = v3
	end

	return list
end

local function Create(className, items)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	return instance
end

local function CreatePart(items)
	local part = Instance.new("Part")

	for k, v in pairs({
		Size = createVector(1, 1, 1),
		TopSurface = "Smooth",
		BottomSurface = "Smooth",
		CanCollide = false,
		Massless = true,
		Anchored = true
	}) do
		part[k] = v
	end

	for k, item in pairs(items) do
		part[k] = item
	end

	return part
end

local function ClearAllChildren(clone, className)
	for _, child in pairs(clone:GetChildren()) do
		if className then
			if child:IsA(className) then
				child:Destroy()
			end
		else
			child:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deleteWhenTweenCompletes(tween, instance)
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function(_)
		instance:Destroy()
		completedConnection:Disconnect()
	end)
end

local function ScaleModel(folder, sizeMult)
	local primaryPart = folder.PrimaryPart
	local cFrame = primaryPart.CFrame

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size *= sizeMult

		if part ~= primaryPart then
			part.CFrame = cFrame + cFrame:inverse() * part.Position * sizeMult
		end
	end

	return folder
end

return function(data)
	local v = { workspace.Characters, workspace.Enemies }

	local function ClawSlash()
		local clone = electro2Effects:WaitForChild("ClawR"):Clone()
		ScaleModel(clone, data.SizeMult)
		clone:SetPrimaryPartCFrame(data.SlashOrigin.CFrame * CFrame.new(0, 0, -1.5))
		clone.Parent = _WorldOrigin
		local clone2 = electro2Effects:WaitForChild("ClawL"):Clone()
		ScaleModel(clone2, data.SizeMult)
		local recursiveSlashEFX

		recursiveSlashEFX = function(instance)
			local v2 = {}

			for _, part in pairs(instance:GetChildren()) do
				if part:IsA("BasePart") and part.Parent:IsA("Folder") then
					part.Transparency = 1

					if not v2[part.Parent.Name] then
						v2[part.Parent.Name] = {}
					end

					v2[part.Parent.Name][tonumber(part.Name)] = part
				end

				recursiveSlashEFX(part)
			end

			for k, v3 in pairs(v2) do
				for k2, v4 in pairs(v3) do
					local lockToPart = v4
					local v6 = k2
					local v7 = k
					delay(k2 / 25, function()
						if lockToPart:FindFirstChild("Sparkles") then
							lockToPart.Sparkles.Sparks.Speed = NumberRange.new(
								lockToPart.Sparkles.Sparks.Speed.Min * data.SizeMult,
								lockToPart.Sparkles.Sparks.Speed.Max * data.SizeMult
							)
							lockToPart.Sparkles.Sparks:Emit(16)
						end

						if v6 > 1 then
							lightning.new({
								Lifetime = 0.1,
								DrawType = "Singular",
								Colors = {
									ColorSequenceKeypoint.new(0, Color3.new(0, 0.784314, 1)),
									ColorSequenceKeypoint.new(1, Color3.new(0.737255, 0.952941, 1))
								},
								Sizes = {
									{
										Size = 0,
										Time = 0
									},
									{
										Size = 0.9,
										Time = 0.5
									},
									{
										Size = 0,
										Time = 1
									}
								},
								Transparencies = {
									{
										Transparency = 0,
										Time = 0
									},
									{
										Transparency = 0,
										Time = 0.8
									},
									{
										Transparency = 1,
										Time = 1
									}
								},
								Points = {
									Start = {
										Position = lockToPart.Position,
										Velocity = createVector(0, 0, 0),
										Acceleration = createVector(0, 0, 0),
										Drag = 0,
										LockToPart = lockToPart
									},
									End = {
										Position = v2[v7][v6 - 1].Position,
										Velocity = createVector(0, 0, 0),
										Acceleration = createVector(0, 0, 0),
										Drag = 0,
										LockToPart = v2[v7][v6 - 1]
									}
								},
								ArcSize = {
									Min = 0.3,
									Max = 0.65
								},
								ChangesSegmentOffset = true,
								OffsetChangePercent = {
									EqualOrBelow = 0.25,
									Bounds = { 0, 1 }
								}
							})

							if v6 == #v2[v7] then
								Util.Debris:AddItem(instance:FindFirstAncestorWhichIsA("Model"), 0.25)
							end
						end
					end)
				end
			end
		end

		local function pushModel(clone3, p)
			local v2 = CFrame.new(
				data.SlashOrigin.Position + data.SlashOrigin.CFrame.LookVector,
				data.SlashOrigin.Position + data.SlashOrigin.CFrame.LookVector * 999
			) * CFrame.new(0, 15 * p * data.SizeMult / 2, 0) * CFrame.Angles(
				2.181661564992912,
				math.rad(65 * p),
				(math.rad(-30 * p))
			)
			local v3 = CFrame.new(
				data.SlashOrigin.Position + data.SlashOrigin.CFrame.LookVector * 15 * data.SizeMult / 2,
				data.SlashOrigin.Position + data.SlashOrigin.CFrame.LookVector * 999
			) * CFrame.Angles(-0.8726646259971648, math.rad(-50 * p), (math.rad(-50 * p)))
			local lastTime = tick()

			while tick() - lastTime < 0.45 do
				local v4 = (tick() - lastTime) / 0.45
				RunService.RenderStepped:Wait()
				v2 = v2:Lerp(v3, v4)
				pcall(function()
					clone3:SetPrimaryPartCFrame(v2)
				end)
			end
		end

		delay(0.1, function()
			clone2:SetPrimaryPartCFrame(data.SlashOrigin.CFrame * CFrame.new(0, 0, -1.5))
			clone2.Parent = _WorldOrigin
			recursiveSlashEFX(clone2)
			pushModel(clone2, 1)
		end)
		recursiveSlashEFX(clone)
		pushModel(clone, -1)
	end

	local function Dash()
		local vanishMult = data.VanishMult

		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.PierceOrigin.Position).Magnitude < 25 then
			Util.CameraShaker:ShakeOnce(8, 7, 0.275, 0.95)
		end

		local part = Instance.new("Part")
		part.Transparency = 1
		part.CFrame = data.oldPos
		part.Anchored = true
		part.CanCollide = false
		part.Parent = _WorldOrigin
		local model = Instance.new("Model")

		for k, v3 in pairs({
			Name = "Lightning Glow",
			Parent = _WorldOrigin
		}) do
			model[k] = v3
		end

		local neGlowRecursive

		neGlowRecursive = function(instance)
			for _, part2 in pairs(instance:GetChildren()) do
				if part2:IsA("BasePart") and part2.Transparency < 1 then
					local clone = part2:Clone()
					clone.Size *= 1.05
					clone.Material = Enum.Material.Neon
					clone.Color = Color3.fromRGB(44, 238, 255)
					clone.CanCollide = false
					clone.CFrame = part2.CFrame
					clone.Anchored = true
					clone.Massless = true
					clone.Name = "asdasd"
					clone.Transparency = 0.1
					clone.Parent = model
					ClearAllChildren(clone, "JointInstance")
					ClearAllChildren(clone, "Decal")
					local v4 = part2
					spawn(function()
						repeat
							RunService.RenderStepped:Wait()
							clone.CFrame = v4.CFrame
						until not clone:IsDescendantOf(workspace)

						pcall(function()
							clone:Destroy()
						end)
					end)
					local tween = TweenService:Create(clone, TweenInfo.new(0.3), {
						Color = Color3.fromRGB(129, 232, 255),
						Transparency = 1
					})
					tween:Play()
					deleteWhenTweenCompletes(tween, model) -- equivalent call inferred; original call site unknown
				end

				neGlowRecursive(part2)
			end
		end

		neGlowRecursive(data.PierceChar)
		local clone = electro2Effects:WaitForChild("LightningDash"):Clone()
		clone.Size = Vector3.new(clone.Size.X, clone.Size.Y, data.StrikeDist - 5)
		clone.CFrame = CFrame.new(
			part.Position + part.CFrame.LookVector * data.StrikeDist / 2,
			part.Position + part.CFrame.LookVector * -999
		) * CFrame.new(0, 0, -7.5)
		clone.Parent = _WorldOrigin
		local parent = CreatePart({
			Size = clone.Size,
			CFrame = clone.CFrame,
			Transparency = 1,
			Parent = _WorldOrigin
		})
		local clone2 = electro2Effects:WaitForChild("LightningDust"):Clone()
		clone2.Parent = parent
		clone2:Emit(50)
		Util.Debris:AddItem(parent, clone2.Lifetime.Max)
		local tween = TweenService:Create(clone, TweenInfo.new(0.375 * vanishMult, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, clone.Size.Z + 4),
			CFrame = clone.CFrame * CFrame.new(0, 0, 5)
		})
		tween:Play()
		deleteWhenTweenCompletes(tween, clone) -- equivalent call inferred; original call site unknown

		for i = 1, 2 do
			local clone3 = electro2Effects:WaitForChild("NingAfter"):Clone()
			local cFrame = clone.CFrame
			local v4 = i == 1 and -random:NextNumber(0.5, 2) or random:NextNumber(0.5, 2)
			clone3.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 3.141592653589793 / v4, 0)
			clone3.Size = Vector3.new(clone3.Size.X, data.StrikeDist - 10, clone3.Size.Z)
			clone3.Parent = _WorldOrigin
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(0.09 * vanishMult, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 2, true),
				{
					Transparency = 0
				}
			)
			local tween3 = TweenService:Create(
				clone3,
				TweenInfo.new(0.18 * vanishMult * random:NextNumber(1, 1.15), Enum.EasingStyle.Linear),
				{
					Size = Vector3.new(clone3.Size.X - 5, clone3.Size.Y + 12, clone3.Size.Z - 5)
				}
			)
			tween2:Play()
			tween3:Play()
			deleteWhenTweenCompletes(tween2, clone3) -- equivalent call inferred; original call site unknown
			local v6 = i
			spawn(function()
				repeat
					RunService.RenderStepped:Wait()
					clone3.CFrame *= CFrame.new(0, 0.05, 0) * CFrame.Angles(
						0,
						3.141592653589793 / (v6 == 1 and -13 or 13),
						0
					)
				until clone3.Parent == nil
			end)
		end

		for i = 0, math.ceil(data.StrikeDist / 30) do
			local clone3 = electro2Effects:WaitForChild("Shockwave"):Clone()
			clone3.CFrame = part.CFrame * CFrame.new(
				0,
				0,
				-(i / (math.ceil(data.StrikeDist / 30 + 1) / data.StrikeDist))
			) * CFrame.Angles(-1.5707963267948966, math.rad((random:NextNumber(-180, 180))), 0)
			clone3.Parent = _WorldOrigin
			local tween2 = TweenService:Create(clone3, TweenInfo.new(i / 6 + 0.275, Enum.EasingStyle.Quad), {
				Transparency = 1,
				Size = clone3.Size * (4 - i / 7)
			})
			tween2:Play()
			deleteWhenTweenCompletes(tween2, clone3) -- equivalent call inferred; original call site unknown
			spawn(function()
				local number = random:NextNumber(-1, 1)

				repeat
					RunService.RenderStepped:Wait()
					clone3.CFrame *= CFrame.Angles(0, math.rad(9 * number), 0)
				until clone3.Parent == nil
			end)
		end

		for i = 1, 3 do
			local clone3 = electro2Effects:WaitForChild("CircleShockwave"):Clone()
			clone3.CFrame = part.CFrame * CFrame.new(0, 0, i * 1.5) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone3.Size *= i ^ 0.67
			clone3.Parent = _WorldOrigin
			local tween2 = TweenService:Create(clone3, TweenInfo.new((i ^ 0.2 / i + 0.35) * vanishMult), {
				Size = clone3.Size * (i ^ 0.35 + 1.85),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.new(i ^ 0.6 * -17.5, 0, 0) * CFrame.Angles(
					math.rad((random:NextNumber(-175, 175))),
					0,
					0
				)
			})
			tween2:Play()
			deleteWhenTweenCompletes(tween2, clone3) -- equivalent call inferred; original call site unknown
		end

		local clone3 = electro2Effects:WaitForChild("SparkRay"):Clone()
		clone3.CFrame = part.CFrame * CFrame.new(0, 0, 8)
		clone3.Parent = _WorldOrigin
		local attachment = clone3.Attachment
		attachment.Spark:Emit(1)
		attachment.Wave:Emit(1)
		Util.Debris:AddItem(clone3, attachment.Spark.Lifetime.Max)
		local clone4 = electro2Effects:WaitForChild("LightningSpike"):Clone()
		clone4.Parent = _WorldOrigin

		for _, child in pairs(clone4:GetChildren()) do
			child.CFrame = CFrame.new(
				data.PierceOrigin.Position,
				(data.PierceOrigin.Position - data.oldPos.p) * 9999999
			) * CFrame.new(0, 0, 7) * CFrame.Angles(1.5707963267948966, 0, 0)
			child.Decal.Color3 = Color3.fromRGB(655, 655, 2337)
			child.Mesh.Scale *= 1.67
			local tween2 = TweenService:Create(child.Mesh, TweenInfo.new(0.3), {
				Scale = Vector3.new(child.Mesh.Scale.X * 1.25, child.Mesh.Scale.Y * 1.33, child.Mesh.Scale.Z * 1.25)
			})
			TweenService:Create(child.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 1), {
				Transparency = 1,
				Color3 = Color3.fromRGB(255, 455, 2337)
			}):Play()
			TweenService:Create(child, TweenInfo.new(0.3), {
				CFrame = child.CFrame * CFrame.new(0, -7, 0)
			}):Play()
			tween2:Play()
			deleteWhenTweenCompletes(tween2, clone4) -- equivalent call inferred; original call site unknown
		end

		local ray, v4 = Util.Ray(part.Position, part.CFrame.UpVector.Unit * -8, v)
		local ray2, v5 = Util.Ray(data.PierceOrigin.Position, part.CFrame.UpVector.Unit * -8, v)
		local _ = { v4, v5 }

		if ray and ray.CanCollide == true then
			for i = 1, 2 do
				local clone5 = electro2Effects:WaitForChild("groundDash1"):Clone()
				clone5.CFrame = part.CFrame * CFrame.new(i == 1 and 4 or -4, 0, clone5.Size.Z / 2 - 6) * CFrame.Angles(
					0,
					math.rad(i == 1 and 9 or -9),
					0
				)
				clone5.Parent = _WorldOrigin
				local clone6 = electro2Effects:WaitForChild("groundDash2"):Clone()
				clone6.CFrame = part.CFrame * CFrame.new(i == 1 and 4 or -4, 0, clone6.Size.Z / 2 - 6) * CFrame.Angles(
					0,
					math.rad(i == 1 and 9 or -9),
					0
				)
				clone6.Parent = _WorldOrigin
				local tween2 = TweenService:Create(clone5, TweenInfo.new(0.5 * vanishMult, Enum.EasingStyle.Cubic), {
					Size = Vector3.new(clone5.Size.X, clone5.Size.Y * 0.8, clone5.Size.Z * 2.1),
					CFrame = clone5.CFrame * CFrame.new(0, 0, 25),
					Transparency = 1
				})
				local tween3 = TweenService:Create(clone6, TweenInfo.new(0.4 * vanishMult, Enum.EasingStyle.Cubic), {
					Size = Vector3.new(clone6.Size.X, clone6.Size.Y * 0.6666666666666666, clone6.Size.Z * 1.85),
					CFrame = clone6.CFrame * CFrame.new(0, 0, 15),
					Transparency = 1
				})
				tween2:Play()
				tween3:Play()
				deleteWhenTweenCompletes(tween2, clone5) -- equivalent call inferred; original call site unknown
				deleteWhenTweenCompletes(tween3, clone6) -- equivalent call inferred; original call site unknown
			end

			for i = 1, 2 do
				for _ = 1, 8 do
					if i == 2 and not ray2 then
						return false
					end

					local part2 = Instance.new("Part")
					part2.Material = i == 1 and ray.Material or ray2.Material
					part2.Transparency = i == 1 and ray.Transparency or ray2.Transparency
					part2.CastShadow = i == 1 and ray.CastShadow or ray.CastShadow
					part2.Color = i == 1 and ray.Color or ray2.Color
					part2.TopSurface = i == 1 and ray.TopSurface or ray2.TopSurface
					part2.BottomSurface = i == 1 and ray.BottomSurface or ray2.BottomSurface
					part2.CanCollide = false
					part2.Massless = true
					part2.Size = createVector(1, 1, 1) * (i == 1 and random:NextNumber(5, 9) or random:NextNumber(
						1.5,
						5
					))
					part2.CFrame = (i == 1 and part.CFrame or data.newCF) * CFrame.new(0, -3, 5) * (i == 1 and CFrame.Angles(
						math.rad((random:NextNumber(-35, -20))),
						math.rad((random:NextNumber(-15, 15))),
						0
					) or CFrame.Angles(
						math.rad((random:NextNumber(-40, 40))),
						math.rad((random:NextNumber(-180, 180))),
						(math.rad((random:NextNumber(-40, 40))))
					))
					part2.Parent = _WorldOrigin
					part2.Velocity = i == 1 and -part2.CFrame.LookVector * random:NextNumber(80, 150) or part2.CFrame.UpVector * random:NextNumber(
						85,
						115
					)
					part2.RotVelocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					) * random:NextNumber(-10, 10)
					local tween2 = TweenService:Create(part2, TweenInfo.new(random:NextNumber(0.7, 0.9)), {
						Size = createVector(0, 0, 0)
					})
					tween2:Play()
					deleteWhenTweenCompletes(tween2, part2) -- equivalent call inferred; original call site unknown
				end
			end

			if ray2 then
				for i = 1, 2 do
					for i2 = 1, 7 do
						local cFrame = CFrame.new(v5, v5 + data.newCF.LookVector) * CFrame.new(0, 0, i2 * 0.7 - 26) * CFrame.Angles(
							0,
							math.rad(20 * (i == 1 and -1 or 1)),
							0
						) * CFrame.new(0, 0, i2 * 5.5) * CFrame.Angles(
							math.rad((random:NextNumber(-180, 180))),
							math.rad((random:NextNumber(-180, 180))),
							(math.rad((random:NextNumber(-180, 180))))
						)

						if not Util.Ray(cFrame.p + createVector(0, 1, 0), createVector(0, -2.5, 0), v) then
							continue
						end

						local part2 = CreatePart({
							Size = createVector(1, 1, 1) * (5 / i2 ^ 0.2),
							CFrame = cFrame,
							Color = ray2.Color,
							Transparency = ray2.Transparency,
							Material = ray2.Material,
							Parent = _WorldOrigin
						})
						delay(1.15, function()
							local tween2 = TweenService:Create(part2, TweenInfo.new(0.33), {
								Size = createVector(0, 0, 0)
							})
							tween2:Play()
							deleteWhenTweenCompletes(tween2, part2) -- equivalent call inferred; original call site unknown
						end)
					end
				end
			end
		end

		for i = 1, 2 do
			local v6 = CreatePart({
				Transparency = 1,
				CFrame = data.newCF * CFrame.new(i == 1 and -1.5 or 1.5, 0, 0),
				Parent = _WorldOrigin
			})

			for _ = 1, 2 do
				local clone5 = v6:Clone()
				clone5.CFrame *= CFrame.new(
					random:NextNumber(i == 1 and -15 or 5, i == 1 and -5 or 15),
					random:NextNumber(-2, 15),
					random:NextNumber(8, 16)
				)
				clone5.Parent = v6
				TweenService:Create(clone5, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
					CFrame = clone5.CFrame * CFrame.new(0, 0, 10)
				}):Play()
				lightning.new({
					Lifetime = 0.4,
					DrawType = "Singular",
					Colors = {
						ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0.85098)),
						ColorSequenceKeypoint.new(1, Color3.new(0.745098, 1, 0.964706))
					},
					Sizes = {
						{
							Size = 2,
							Time = 0
						},
						{
							Size = 1.35,
							Time = 0.5
						},
						{
							Size = 0,
							Time = 1
						}
					},
					Transparencies = {
						{
							Transparency = 0,
							Time = 0
						},
						{
							Transparency = 0,
							Time = 1
						}
					},
					Points = {
						Start = {
							Position = v6.Position,
							Velocity = createVector(0, 0, 0),
							Acceleration = createVector(0, 0, 0),
							Drag = 0,
							LockToPart = v6
						},
						End = {
							Position = clone5.Position,
							Velocity = createVector(0, 0, 0),
							Acceleration = createVector(0, 0, 0),
							Drag = 0,
							LockToPart = clone5
						}
					},
					ArcSize = {
						Min = 1.25,
						Max = 4
					},
					ChangesSegmentOffset = true,
					OffsetChangePercent = {
						EqualOrBelow = 0.5,
						Bounds = { 0, 1 }
					}
				})
				Util.Debris:AddItem(v6, 0.275)
			end
		end

		part:Destroy()
	end

	if data.Arg == "ClawSlash" then
		if (data.SlashOrigin.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
			return
		end

		ClawSlash()
	elseif data.Arg == "Dash" then
		if (data.PierceOrigin.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
			return
		else
			Dash()
		end
	end
end