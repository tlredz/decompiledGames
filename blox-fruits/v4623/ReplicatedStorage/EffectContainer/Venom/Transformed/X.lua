local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.Spring
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService2 = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blobShot(startPos, endPos, value, p, p2, p3, p4, color)
	spawn(function()
		local v = {}
		local clone = FX:WaitForChild("VenomEffects").VenomXBezier:Clone()
		Util.Debris:AddItem(clone, value + 3)
		local clone2 = clone.MeshOuter:Clone()
		local clone3 = clone.MeshInner:Clone()
		Util.Debris:AddItem(clone2, value or 10)
		Util.Debris:AddItem(clone3, value or 10)
		clone2.Color = color or Color3.fromRGB(163, 0, 76)
		clone3.Color = Color3.fromRGB(80, 19, 96)
		clone.MeshOuter:Destroy()
		clone.MeshInner:Destroy()
		local root = clone.Root
		local head = clone.Head
		local trail = root.Trail
		local centerAt = root.CenterAt
		local smoke = centerAt.Smoke
		local ring = centerAt.Ring
		head.Color = color or Color3.fromRGB(163, 0, 76)
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color or Color3.fromRGB(163, 0, 76)),
			ColorSequenceKeypoint.new(1, color or Color3.fromRGB(163, 0, 76))
		})

		local function newFluid()
			local clone4 = clone3:Clone()
			local clone5 = clone2:Clone()
			clone4.Parent = clone
			clone5.Parent = clone
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(4.1, 11.5, 4.1),
					Transparency = 1
				}
			)
			local tween2 = TweenService:Create(
				clone5,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(4.12, 11, 4.12),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				clone4:Destroy()
			end)
			tween2.Completed:Connect(function()
				clone5:Destroy()
			end)
			table.insert(v, {
				clone4,
				clone5,
				1,
				0
			})
			tween:Play()
			tween2:Play()
		end

		local magnitude = (startPos - endPos).magnitude
		local cframe = CFrame.new(startPos, endPos)
		local v2 = cframe * CFrame.new(0, 0, -magnitude)
		clone:SetPrimaryPartCFrame(cframe)
		clone.Parent = _WorldOrigin
		local v3 = {
			startPos,
			startPos:Lerp((v2 * CFrame.new(p, p2, 0)).p, 0.25),
			startPos:Lerp((v2 * CFrame.new(p3, p4, 0)).p, 0.75),
			endPos
		}
		local lastTime = tick()
		local lastTime2 = tick()
		local position = startPos

		while tick() - lastTime <= value do
			local v4 = tick() - lastTime
			local v5 = cubicBezier(math.max(0.001, v4) / value, unpack(v3))
			clone:SetPrimaryPartCFrame(CFrame.new(v5, position) * CFrame.Angles(0, 3.141592653589793, 0))
			position = root.Position

			if tick() - lastTime2 > 0.15 then
				newFluid()
				ring:Emit(1)
				lastTime2 = tick()
			end

			for _, v6 in pairs(v) do
				v6[1].CFrame = root.CFrame * CFrame.new(0, 0, v6[4]) * CFrame.Angles(1.5707963267948966, v6[3], 0)
				v6[2].CFrame = root.CFrame * CFrame.new(0, 0, v6[4]) * CFrame.Angles(1.5707963267948966, v6[3], 0)
				v6[3] += 0.1
				local v7 = v6[4]
				v6[4] = v7 + (8.6 - v7) * 0.15
			end

			RunService2.RenderStepped:Wait()
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.Size = createVector(0.05, 0.05, 0.05)
		part.Transparency = 1
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, 3)
		trail.Enabled = false
		ring.Enabled = false
		smoke.Enabled = false
		trail.Parent = part
		ring.Parent = part
		smoke.Parent = part
		v = nil

		if clone then
			clone:Destroy()
		end
	end)
end

local function shotgunBlast(cframe, p, color, color2)
	local function spikeBeam(root, rootAttachment, position, p2)
		local attachment = Instance.new("Attachment")
		attachment.Parent = root
		attachment.Position = position
		local clone = FX:WaitForChild("VenomEffects").BlastBeam:Clone()
		clone.Attachment0 = rootAttachment
		clone.Attachment1 = attachment
		clone.Color = ColorSequence.new(p2)
		clone.Parent = attachment
		local tween = TweenService:Create(
			attachment,
			TweenInfo.new(math.random(1, 2) / 12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Position = attachment.Position + Vector3.new(
					math.random(-20, 20),
					math.random(-20, 20),
					-math.random(50, 100)
				)
			}
		)
		tween.Completed:Connect(function()
			attachment:Destroy()
		end)
		tween:Play()
		return { attachment, clone }
	end

	local clone = FX:WaitForChild("VenomEffects").VenomXShotgun:Clone()
	Util.Debris:AddItem(clone, p + 4)
	local root = clone.Root
	local rootAttachment = root.RootAttachment
	local clouds = root.Clouds
	clouds.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 0, 131)),
		ColorSequenceKeypoint.new(1, color)
	})
	local shockwave1 = clone.Shockwave1
	local shockwave2 = clone.Shockwave2
	shockwave2.Color = color2
	local swirl = clone.Swirl
	local v = {}

	for _, child in pairs(clone:GetChildren()) do
		if child.Name ~= "Globlet" then
			continue
		end

		table.insert(v, child)
		child.Color = color2
		local tween = TweenService:Create(
			child,
			TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(0.05, 0.05, 0.05)
			}
		)
		local v2 = child
		tween.Completed:Connect(function()
			v2:Destroy()
		end)
		tween:Play()
	end

	spikeBeam(root, rootAttachment, createVector(0, 0, -0), color)
	spikeBeam(root, rootAttachment, createVector(0, 0, -0), color)
	spikeBeam(root, rootAttachment, createVector(0, 0, -0), color)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin
	Util.Sound:Play("VenomBlast", cframe.p, nil, 1, 2)

	for _, child in pairs(clone:GetChildren()) do
		if child == shockwave1 then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(25, 70, 25),
					CFrame = child.CFrame * CFrame.new(0, 22, 0)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child == shockwave2 then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(24.76, 68.064, 24.76),
					CFrame = child.CFrame * CFrame.new(0, 20, 0)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child == swirl then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(40, 1.69, 40),
					CFrame = child.CFrame * CFrame.Angles(0, 3.12413936106985, 0),
					Transparency = 1
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Globlet" then
			child.Size *= 10
			local v2 = child
			TweenService:Create(child, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Size = createVector(0.05, 0.05, 0.05)
			}).Completed:Connect(function()
				v2:Destroy()
			end)
		end
	end

	clouds:Emit(1)
	clouds:Emit(1)
	clouds:Emit(1)
	clouds:Emit(1)
	clouds:Emit(1)
	clouds:Emit(1)
end

local function particle(cFrame, p, p2, p3, _)
	local clone = FX:WaitForChild("VenomEffects").Particle:Clone()
	Util.Debris:AddItem(clone, p + 3)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0, 0, 0),
			Color = Color3.fromRGB(84, 12, 104)
		}
	)
	clone.Embers.Enabled = false
	clone.Glow.Enabled = false
	local total = 0
	local lastTime = tick()
	spawn(function()
		tween:Play()
		local v = 1

		while tick() - lastTime < p do
			local _ = (tick() - lastTime) / p
			total += 0.1
			clone.CFrame = clone.CFrame * CFrame.new(0, 0, -p2) * CFrame.Angles(
				math.rad(p3 * math.cos(v / 5 + math.random(-15, 15) / 10)),
				math.rad(total),
				0
			)
			v += 1
			RunService.RenderStepped:Wait()
		end

		if clone then
			spawn(function()
				clone.Embers.Enabled = false
				clone.Glow.Enabled = false
				clone.Trail.Enabled = false
				wait(2)
				clone:Destroy()
			end)
		end
	end)
end

local function explosion(cframe, color)
	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	Util.Sound:Play("VenomSplat", cframe.p, nil, 0.5 + math.random(-10, 10) / 100, 3)
	Util.Sound:Play("VenomBlast", cframe.p, nil, 0.8 + math.random(-10, 10) / 100, 2)

	for _ = 0, 6 do
		particle(
			CFrame.new(cframe.p) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
			math.random(15, 25) / 10,
			math.random(20, 30) / 10,
			math.random(-25, 25)
		)
	end

	TweenService:Create(
		Util.Sound:Play("GenericExplosion3Fast", cframe.p, nil, 2 + math.random(-10, 10) / 100, 0.2),
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Pitch = 0.5
		}
	):Play()
	local clone = FX:WaitForChild("VenomEffects").VenomXBlast:Clone()
	Util.Debris:AddItem(clone, 5)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 19, 96)),
		ColorSequenceKeypoint.new(1, color or Color3.fromRGB(72, 0, 154))
	})
	local origin = clone.Origin
	local smog = origin.Smog
	smog.Color = colorSequence
	smog.Speed = NumberRange.new(160, 200)
	smog.Drag = 5
	local spirals = origin.Spirals
	spirals.Color = colorSequence
	spirals.Enabled = false
	local splash1 = origin.Splash1
	local splash2 = origin.Splash2
	local splash3 = origin.Splash3
	local p = cframe.p
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 80 then
			Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.8)
		end
	end

	spawn(function()
		for _ = 0, 4 do
			splash1:Emit(1)
			splash2:Emit(1)
			splash3:Emit(2)
			spirals:Emit(5)
			smog:Emit(3)
			wait(0.01)
		end
	end)

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Inner" or child.Name == "Outer" then
			if child.Name == "Inner" then
				child.Color = color
			end

			local tween = TweenService:Create(
				child,
				TweenInfo.new(math.random(10, 15) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = child.Size * 85
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "PoisonCrescent" then
			child.Color = color
			local cframe2 = CFrame.Angles(
				math.rad((math.random(-30, 30))),
				2.9670597283903604,
				(math.rad((math.random(-30, 30))))
			)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 45 - createVector(0, 10, 0),
					CFrame = child.CFrame * cframe2 * CFrame.new(0, 20, 0),
					Transparency = 1
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Tatters" then
			child.Color = color
			child.Size = createVector(1, 20, 1)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(60, 3, 60),
					CFrame = child.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
					Transparency = 1
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "LiquidWave" then
			child.Color = color
			child.Size = createVector(10, 100, 10)
			child.Position += createVector(0, 40, 0)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(200, 1, 200),
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, -50, 0) * CFrame.Angles(0, 2.9670597283903604, 0)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				smog.Enabled = false
				spirals.Enabled = false
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Cloud" then
			child.Color = color
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 25,
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "ShockwaveFlat" then
			child.Color = color
			child.Size += createVector(0, 50, 0)
			child.CFrame *= CFrame.new(0, 30, 0)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(200.364, 4.989, 200.99),
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, -30, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Shock" then
			child.Adornee = origin
			child.img.Rotation = math.random(-180, 180)
			child.img.ImageColor3 = color or Color3.fromRGB(90, 52, 166)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = UDim2.new(185, 0, 185, 0)
				}
			)
			local v2 = child
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
		end
	end
end

local function pulsation(position, color)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 10)
	part.Anchored = true
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Transparency = 1
	part.Material = Enum.Material.Glass
	part.Position = position
	part.Color = color
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = _WorldOrigin
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		specialMesh,
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Scale = createVector(15, 19, 15)
		}
	)
	local tween2 = TweenService:Create(
		part,
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Transparency = 0
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	tween:Play()
	tween2:Play()
	return part
end

local function hangGlob(cFrame, size, color)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 10)
	part.Anchored = true
	part.Size = size
	part.CanCollide = false
	part.Transparency = 0
	part.Material = Enum.Material.Neon
	part.CFrame = cFrame
	part.Color = color
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = createVector(1, 1, 1)
	specialMesh.Parent = part
	local v = math.random(2, 4)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(math.random(5, 11) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = cFrame * CFrame.new(0, 0, -math.random(40, 150)),
			Size = Vector3.new(v, v, v)
		}
	)
	tween.Completed:Connect(function()
		TweenService:Create(
			part,
			TweenInfo.new(math.random(10, 20) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Position = part.Position - createVector(0, 4, 0),
				Size = createVector(0.05, 0.05, 0.05)
			}
		):Play()
	end)
	part.Parent = _WorldOrigin
	tween:Play()
end

local function chargeWind(position, color)
	local clone = FX:WaitForChild("VenomEffects").VenomWind:Clone()
	Util.Debris:AddItem(clone, 10)
	clone.Size /= 3.2
	clone.Color = color
	clone.Anchored = true
	clone.Material = Enum.Material.Neon
	clone.Transparency = 1
	clone.Position = position
	clone.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0),
		{
			Transparency = 0
		}
	)
	local v = math.random(18, 24)
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = clone.Size + Vector3.new(v, v, v)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween2:Play()
	tween:Play()
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drip(position, vector2, color, duration)
	spawn(function()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 10)
		part.Size = createVector(1, -4, 1)
		part.Color = color
		part.CanCollide = false
		part.Anchored = true
		part.Material = Enum.Material.Glass
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.Position = position
		part.Parent = _WorldOrigin
		local ray, v, v2 = Util.Ray(
			position,
			CFrame.new(position, position - createVector(0, 10, 0)).lookVector.Unit * 80,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Size = vector2 + Vector3.new(0, vector2.Y + 6, 0),
				Position = position - Vector3.new(0, math.random(80), 0)
			}
		)
		local tween2 = TweenService:Create(
			specialMesh,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Scale = createVector(0, 1, 0)
			}
		)
		tween:Play()
		tween2:Play()
		tween.Completed:Connect(function()
			part:Destroy()

			if v and ray then
				local part2 = Instance.new("Part")
				Util.Debris:AddItem(part2, 10)
				part2.Size = createVector(0, 0, 0)
				part2.Color = color
				part2.CanCollide = false
				part2.Anchored = true
				part2.Material = Enum.Material.Glass
				local specialMesh2 = Instance.new("SpecialMesh")
				specialMesh2.MeshType = Enum.MeshType.Cylinder
				specialMesh2.Parent = part2
				part2.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(0, 1.5707963267948966, 0)
				part2.Parent = _WorldOrigin
				local v3 = math.random(2, 3)
				local tween3 = TweenService:Create(
					part2,
					TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = Vector3.new(0.05, v3, v3)
					}
				)
				tween3.Completed:Connect(function()
					part2:Destroy()
				end)
				tween3:Play()
			end
		end)
	end)
end

return function(player)
	local step = player.Step
	local color = player.Color

	if step == 1 then
		local holdValue = player.HoldValue
		local character = player.Character
		local jawPart = player.JawPart
		local chargeTime = player.ChargeTime

		if character and jawPart then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid and jawPart then
				if (jawPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
					return
				end

				local v = true

				if humanoid then
					humanoid.Died:Connect(function()
						v = false
					end)
				else
					v = false
				end

				Util.Sound:Play("Charge Init", jawPart.Position, nil, 1.5 + math.random(-10, 10) / 100, 1)
				local clone = FX:WaitForChild("VenomEffects").HydraHead:Clone()
				Util.Debris:AddItem(clone, 120)
				local ball = clone.Ball
				ball.Size = createVector(5, 5, 5)
				local size = ball.Size
				local clone_2 = FX:WaitForChild("VenomEffects").ParticleDrips:Clone()
				clone_2.Parent = clone.Ball
				ball.Transparency = 1
				ball.Size = createVector(0.05, 0.05, 0.05)

				for _, child in pairs(clone:GetChildren()) do
					if child.Name ~= "Ball" then
						child:Destroy()
					end
				end

				TweenService:Create(
					ball,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 0,
						Size = size
					}
				):Play()
				clone:SetPrimaryPartCFrame(jawPart.CFrame * CFrame.new(0, 1, -12))
				clone.Parent = _WorldOrigin
				local lastTime = tick()

				local function running()
					return tick() - lastTime < chargeTime or v and player.HoldValue and player.HoldValue.Value == true
				end

				tick()
				local lastTime2 = tick()
				local v2 = {}

				while (tick() - lastTime < chargeTime or v and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and jawPart and humanoidRootPart and humanoid do
					if tick() - lastTime2 >= 0.1 and ball ~= nil then
						drip(
							(ball.CFrame * CFrame.new(
								math.random(-ball.Size.X, ball.Size.X),
								0,
								math.random(-ball.Size.Z, ball.Size.Z)
							)).p,
							Vector3.new(math.random(55, 75) / 100, 1, math.random(55, 75) / 100),
							color,
							0.55
						) -- equivalent call inferred; original call site unknown
						lastTime2 = tick()
					end

					if tick() - lastTime2 >= 0.05 then
						local pulsation_2 = pulsation(ball.Position, color)
						pulsation_2.Parent = clone
						local v3 = chargeWind(ball.Position, color)
						v3.Parent = clone
						table.insert(v2, v3)
						tick()
					end

					clone:SetPrimaryPartCFrame(jawPart.CFrame * CFrame.new(0, 1, -12))

					for _, v3 in pairs(v2) do
						v3.Position = ball.Position
						v3.CFrame *= CFrame.Angles(0, 0.08726646259971647, 0)
					end

					RunService.RenderStepped:Wait()
				end

				clone:Destroy()

				if humanoidRootPart then
					shotgunBlast(humanoidRootPart.CFrame * CFrame.new(0, 5, -8), 1, color, color)
				end
			end
		end
	elseif step == 2 then
		local endPos = player.EndPos

		if (endPos - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local timestamp = player.Timestamp
		local startPos = player.StartPos
		local life = player.Life
		local _ = (startPos - endPos).magnitude
		local _ = tick() - timestamp
		Util.Sound:Play("CannonFire", startPos, nil, 1 + math.random(-10, 10) / 100, 0.5)
		TweenService:Create(
			Util.Sound:Play("GenesisFire", startPos, nil, 1.3 + math.random(-10, 10) / 100, 1),
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Pitch = 0.8
			}
		):Play()

		for _ = 0, 5 do
			local v2 = math.random(10, 20) / 10
			local v3 = math.random(6, 10)
			hangGlob(
				CFrame.new(startPos, endPos) * CFrame.Angles(
					math.rad((math.random(-20, 20))),
					math.rad((math.random(-20, 20))),
					0
				),
				Vector3.new(v2, v2, v3),
				color
			)
		end

		blobShot(startPos, endPos, life, -math.random(65, 155), math.random(1, 155), -math.random(30, 65), 0, color) -- equivalent call inferred; original call site unknown
		blobShot(startPos, endPos, life, math.random(65, 155), math.random(1, 155), math.random(30, 65), 0, color) -- equivalent call inferred; original call site unknown
		blobShot(startPos, endPos, life, math.random(-290, 290), math.random(65, 155), 0, math.random(30, 65), color) -- equivalent call inferred; original call site unknown
		spawn(function()
			wait(life)
			explosion(CFrame.new(endPos) * CFrame.Angles(0, math.random(-180, 180), 0), color)
		end)
	end
end