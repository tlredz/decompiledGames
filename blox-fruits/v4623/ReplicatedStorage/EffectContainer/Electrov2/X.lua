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
local _WorldOrigin2 = workspace._WorldOrigin
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

local function ClearAllChildren(instance, className)
	for _, child in pairs(instance:GetChildren()) do
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
local function deleteWhenTweenCompletes(p, instance)
	local completedConnection = nil
	completedConnection = p.Completed:Connect(function(_)
		instance:Destroy()
		completedConnection:Disconnect()
	end)
end

local function randomSphericalPoint(p, p2, list)
	local v = { -p2, p2 }
	local number = random:NextNumber(-list[1].X, list[1].X)
	local v2

	if list[1].IsPositiveOrNegative then
		v2 = v[random:NextInteger(1, #v)] or p2
	else
		v2 = p2
	end

	local v3 = number * v2
	local number2 = random:NextNumber(-list[2].Y, list[2].Y)
	local v4

	if list[2].IsPositiveOrNegative then
		v4 = v[random:NextInteger(1, #v)] or p2
	else
		v4 = p2
	end

	local v5 = number2 * v4
	local number3 = random:NextNumber(-list[3].Z, list[3].Z)

	if list[3].IsPositiveOrNegative then
		p2 = v[random:NextInteger(1, #v)] or p2
	end

	local v6 = p + Vector3.new(v3, v5, number3 * p2)
	return CFrame.new(v6.p, -(p.p - v6.p) * 999)
end

return function(data)
	local function Dash()
		local lastTime = tick()
		local lastTime2 = tick()
		tick()
		local v = 1

		for i = -1, 1, 2 do
			local clone = electro2Effects:WaitForChild("LightningSpike"):Clone()
			clone.Parent = _WorldOrigin

			for _, child in pairs(clone:GetChildren()) do
				child.Mesh.Scale = i == 1 and child.Mesh.Scale or Vector3.new(
					0.4,
					0.9,
					math.sign(child.Mesh.Scale.Z) * 0.4
				)
				child.Mesh.Offset = i == 1 and createVector(0, 2.75, 0) or child.Mesh.Offset
				local v2 = i
				local v3 = child
				local v4 = clone
				coroutine.wrap(function()
					local total = 0

					repeat
						RunService.RenderStepped:Wait()
						total += v2 * 13
						v3.CFrame = data.dashRef.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
							1.5707963267948966,
							math.rad(total),
							0
						)
					until tick() - lastTime > data.FullLifetime

					v4:Destroy()
				end)()
			end
		end

		local part = CreatePart({
			Transparency = 1,
			CFrame = data.dashRef.CFrame * CFrame.new(0, 0, -3),
			Parent = _WorldOrigin
		})
		coroutine.resume(coroutine.create(function()
			local total = 0

			repeat
				RunService.RenderStepped:Wait()
				total += 12
				part.CFrame = data.dashRef.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, 0, (math.rad(total)))
			until tick() - lastTime > data.FullLifetime

			part:Destroy()
		end))

		for i = 0, 2 do
			local clone = electro2Effects:WaitForChild("LightningSpinTrail"):Clone()
			clone.Parent = _WorldOrigin
			local v4 = i
			coroutine.wrap(function()
				repeat
					RunService.RenderStepped:Wait()
					clone.CFrame = part.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0, 0, (math.rad(v4 * 120)))
					clone.CFrame *= CFrame.new(0, 5, 0)
				until part.Parent == nil

				pcall(function()
					clone:Destroy()
				end)
			end)()
		end

		while true do
			RunService.RenderStepped:Wait()

			if tick() - lastTime > data.FullLifetime then
				break
			end

			if not (tick() - lastTime2 > data.FullLifetime / data.Rate or v == 1) then
				continue
			end

			v += 1
			lastTime2 = tick()
			local parent = CreatePart({
				Transparency = 1,
				CFrame = data.dashRef.CFrame * CFrame.new(0, 0, -15),
				Parent = _WorldOrigin
			})
			local clone = electro2Effects:WaitForChild("dashSparks"):Clone()
			clone.Parent = parent
			clone:Emit(11)
			Util.Debris:AddItem(parent, clone.Lifetime.Max)
			local clone2 = electro2Effects:WaitForChild("Wind"):Clone()
			clone2.Parent = _WorldOrigin
			local number = random:NextNumber(-15, 15)
			local number2 = random:NextNumber(1.95, 2.05)
			local number3 = random:NextNumber(-180, 180)
			local number4 = random:NextNumber(-12, 12)

			for _, child in pairs(clone2:GetChildren()) do
				child.CFrame = data.dashRef.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(
					3.141592653589793 / number2,
					math.rad(number3),
					(math.rad(number4))
				)
				local v4 = child
				local v5 = number
				local v6 = clone2
				coroutine.wrap(function()
					repeat
						RunService.RenderStepped:Wait()
						v4.CFrame *= CFrame.new(0, 1.33, 0.3) * CFrame.Angles(0, math.rad(v5), 0)
					until v6.Parent == nil
				end)()
				local tween = TweenService:Create(child.Mesh, TweenInfo.new(data.Lifetime, Enum.EasingStyle.Sine), {
					Scale = child.Mesh.Scale * 3.75
				})
				tween:Play()
				TweenService:Create(
					child.Decal,
					TweenInfo.new(data.Lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				):Play()
				deleteWhenTweenCompletes(tween, clone2) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local function Explosion()
		local ray = Util.Ray(
			data.Ref.Position,
			data.Ref.CFrame.UpVector * -8,
			{ workspace.Characters, workspace.Enemies }
		)

		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.Ref.Position).Magnitude < 60 then
			Util.CameraShaker:ShakeOnce(11, 8, 0.2, 0.95)
		end

		local clone = electro2Effects:WaitForChild("ElectricPulse"):Clone()
		clone.CFrame = data.Ref.CFrame * CFrame.new(0, 0, -38)
		clone.Parent = _WorldOrigin
		clone.Attachment.ParticleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 12),
			NumberSequenceKeypoint.new(0.5, 36),
			NumberSequenceKeypoint.new(1, 55)
		})
		delay(0.125, function()
			clone.Attachment.ParticleEmitter.Enabled = false
			Util.Debris:AddItem(clone, clone.Attachment.ParticleEmitter.Lifetime.Max)
		end)

		for i = 1, 12 do
			local _ = i % 2
			local clone2 = electro2Effects:WaitForChild("LightningSpinTrail"):Clone()
			clone2.CFrame = data.Ref.CFrame * CFrame.new(0, 0, random:NextNumber(-40, -35)) * CFrame.Angles(
				math.rad((random:NextNumber(-40, 40))),
				math.rad((random:NextNumber(-40, 40))),
				0
			)
			clone2.Anchored = true
			clone2.CanCollide = true
			clone2.Trail.FaceCamera = true
			clone2.Trail.Lifetime = 0.225
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				CFrame = CFrame.new(clone2.Position + clone2.CFrame.LookVector * random:NextNumber(-165, -115))
			}):Play()
			delay(0.15, function()
				Util.Debris:AddItem(clone2, clone2.Trail.Lifetime)
			end)
		end

		for i = 1, 2 do
			local clone2 = electro2Effects:WaitForChild("ElectricRumble"):Clone()
			clone2.Size = createVector(67, 67, 30) * data.SizeMult
			clone2.CFrame = ray == nil and CFrame.new(data.Ref.Position, (data.mousePos - data.Ref.Position) * 999) * CFrame.Angles(
				0,
				math.rad(i == 1 and 180 or 0),
				0
			) * CFrame.new(0, 0, clone2.Size.Z / -2.25) or data.Ref.CFrame * CFrame.Angles(
				0,
				math.rad(i == 1 and 180 or 0),
				0
			) * CFrame.new(0, 0, clone2.Size.Z / -2.25)
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 2, false),
				{
					Size = Vector3.new(clone2.Size.X / 1.5, clone2.Size.Y / 1.5, clone2.Size.Z * 2)
				}
			)
			tween:Play()
			local v2 = i
			tween.Completed:Connect(function(p)
				if p == Enum.PlaybackState.Completed then
					local tween2 = TweenService:Create(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Cubic), {
						Transparency = 1,
						Size = createVector(0, 0, 50) * data.SizeMult,
						CFrame = CFrame.new(data.Ref.Position, (data.mousePos - data.Ref.Position) * 999) * CFrame.Angles(
							0,
							math.rad(v2 == 1 and 180 or 0),
							0
						) * CFrame.new(0, 0, clone2.Size.Z / -5)
					})
					tween2:Play()
					deleteWhenTweenCompletes(tween2, clone2) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local lockToPart = CreatePart({
			CFrame = data.Ref.CFrame * CFrame.new(0, 0, -36),
			Transparency = 1,
			Parent = _WorldOrigin
		})
		Util.Debris:AddItem(lockToPart, 0.6)

		for _ = 1, 8 do
			local lockToPart2 = CreatePart({
				Transparency = 1,
				CFrame = lockToPart.CFrame * CFrame.new(
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50),
					random:NextNumber(45, 55)
				),
				Parent = _WorldOrigin
			})
			TweenService:Create(lockToPart2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(lockToPart2.Position + lockToPart2.CFrame.LookVector * -12 + lockToPart2.CFrame.UpVector * random:NextNumber(
					-30,
					30
				) + lockToPart2.CFrame.RightVector * random:NextNumber(-30, 30))
			}):Play()
			Util.Debris:AddItem(lockToPart2, 0.3)
			lightning.new({
				Lifetime = 0.3,
				DrawType = "Singular",
				Colors = {
					ColorSequenceKeypoint.new(0, Color3.new(0, 0.784314, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(0.737255, 0.952941, 1))
				},
				Sizes = {
					{
						Size = 2,
						Time = 0
					},
					{
						Size = 0,
						Time = 0.33
					},
					{
						Size = 2,
						Time = 0.67
					},
					{
						Size = 0,
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
						Position = lockToPart2.Position,
						Velocity = createVector(0, 0, 0),
						Acceleration = createVector(0, 0, 0),
						Drag = 0,
						LockToPart = lockToPart2
					}
				},
				ArcSize = {
					Min = 5,
					Max = 8
				},
				ChangesSegmentOffset = true,
				OffsetChangePercent = {
					EqualOrBelow = 0.25,
					Bounds = { 0, 1 }
				}
			})
		end

		if ray then
			local clone2 = electro2Effects:WaitForChild("ExplosionCrack2"):Clone()
			Util.Debris:AddItem(clone2, 5)
			clone2:SetPrimaryPartCFrame(data.Ref.CFrame)
			clone2.Parent = _WorldOrigin

			for _, child in pairs(clone2:GetChildren()) do
				if child.Name == clone2.PrimaryPart then
					continue
				end

				local ray2, v2, _ = Util.Ray(
					child.Position,
					child.CFrame.UpVector * -15,
					{ workspace.Enemies, workspace.Characters }
				)

				if ray2 then
					child.CFrame -= Vector3.new(0, child.CFrame.Y - v2.Y, 0)
					local v3 = TweenService:Create(
						child,
						TweenInfo.new(
							0.5 - (child.Position - clone2.PrimaryPart.Position).Magnitude / 100,
							Enum.EasingStyle.Linear
						),
						{
							Transparency = 1
						}
					)
					local v4 = child
					delay(0.75, function()
						v3:Play()
						deleteWhenTweenCompletes(v3, v4) -- equivalent call inferred; original call site unknown
					end)
				else
					child:Destroy()
				end
			end

			for i = 1, 2 do
				for i2 = 1, 8 do
					local v2 = data.Ref.CFrame * CFrame.new(0, -3, i2 * 13 - 38) * CFrame.Angles(
						0,
						math.rad((i2 * 1.67 + 13) * (i == 1 and 1 or -1)),
						0
					) * CFrame.new(0, 0, -i2 * 8)
					local ray2, v3 = Util.Ray(
						v2.p + createVector(0, 7, 0),
						v2.UpVector * -15,
						{ workspace.Enemies, workspace.Characters }
					)

					if not ray2 then
						continue
					end

					local part = CreatePart({
						Material = ray.Material,
						Color = ray.Color,
						Transparency = ray.Transparency,
						Reflectance = ray.Reflectance,
						TopSurface = ray.TopSurface,
						BottomSurface = ray.BottomSurface,
						Size = createVector(6.75, 6.75, 6.75),
						CFrame = CFrame.new(v3) * CFrame.Angles(
							math.rad((random:NextNumber(-180, 180))),
							math.rad((random:NextNumber(-180, 180))),
							(math.rad((random:NextNumber(-180, 180))))
						),
						Parent = _WorldOrigin
					})
					delay(1, function()
						local tween = TweenService:Create(part, TweenInfo.new(0.5), {
							Size = createVector(1, 1, 1)
						})
						tween:Play()
						deleteWhenTweenCompletes(tween, part) -- equivalent call inferred; original call site unknown
					end)
				end
			end
		end
	end

	if data.Arg == "Dash" then
		if (data.dashRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
			return
		end

		Dash()
	elseif data.Arg == "Explosion" then
		if (data.Ref.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
			return
		end

		Explosion()
	elseif data.Arg == "Charge" then
		local dashRef = data.dashRef

		if data.Remove then
			pcall(function()
				dashRef.OnGoingCharge:Destroy()
			end)
			return
		end

		if (dashRef.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 600 then
			return
		end

		local folder = Instance.new("Folder", dashRef)
		folder.Name = "OnGoingCharge"
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		local v = Sound:Play("ElectricLoopable", dashRef.Position)
		local v2 = false
		local Lightning = require(game.ReplicatedStorage.Util.Lightning)
		spawn(function()
			while folder:IsDescendantOf(workspace) do
				Lightning.new({
					Lifetime = 0.1 + math.random() * 0.1,
					DrawType = "Singular",
					Colors = {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 175, 236))
					},
					Sizes = {
						{
							Size = 0.0525,
							Time = 0
						},
						{
							Size = 0.35,
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
							Position = dashRef.Position
						},
						End = {
							Position = dashRef.Position + Vector3.new(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							).unit * math.random(4, 5) * (v2 and 2.5 or 1)
						}
					},
					ArcSize = {
						Min = 3,
						Max = 6
					},
					ChangesSegmentOffset = true,
					OffsetChangePercent = {
						EqualOrBelow = 0.15,
						Bounds = { 0, 1 }
					}
				})
				wait(0.06)
			end

			wait()
			local Sound2 = require(game.ReplicatedStorage.Util.Sound)
			Sound2:FadeOut(v, 0.05)
			wait(0.1)
			pcall(function()
				v:Stop()
				v:Destroy()
			end)
		end)
		local lastTime = tick()

		while tick() - lastTime < 1 do
			local v3 = 1 + tick() - lastTime

			if not folder.Parent then
				break
			end

			local color = math.random() > 0.5 and Color3.fromRGB(110, 153, 202) or Color3.fromRGB(255, 255, 255)
			local v4 = (15 + math.random() * 10) * v3 * 0.6
			local v5 = CFrame.new(dashRef.Position) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			local v6 = math.random(20, 35) * v3 * 0.6
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = v5 * CFrame.new(0, 0, -v6)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.1, 0.1, 1) * v4
			specialMesh.Parent = part
			part.Parent = _WorldOrigin2
			local tween = TweenService:Create(specialMesh, TweenInfo.new(0.1 + math.random() * 0.1), {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, 0, v6)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
			wait()
		end

		v2 = true

		if tick() - lastTime > 0.99 then
			Util.Sound:Play("ElectricPowerup", dashRef.Position)
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = dashRef.CFrame
			part.Size = createVector(1, 1, 1)
			part.Color = Color3.fromRGB(110, 153, 202)
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = Vector3.new()
			specialMesh.Parent = part
			part.Parent = _WorldOrigin2
			TweenService:Create(part, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(specialMesh, TweenInfo.new(0.1), {
				Scale = createVector(35, 35, 35)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		Util.Debris:AddItem(folder, 30)
	end
end