local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
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
local function implode(humanoidRootPart, duration, color)
	spawn(function()
		Util.Sound:Play("AcidCast", humanoidRootPart, nil, 1 + math.random(-10, 10) / 100, 2)
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(0.05, 0.05, 0.05)
		part.Color = color or Color3.fromRGB(82, 17, 140)
		part.Material = Enum.Material.Glass
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.Position = humanoidRootPart.Position
		local clone = FX:WaitForChild("VenomEffects").FlyStart:Clone()
		local attachment = clone.Attachment
		attachment.Parent = part
		clone:Destroy()
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(55, 55, 55),
				Color = color
			}
		)
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		part.Parent = _WorldOrigin

		for _, child in pairs(attachment:GetChildren()) do
			child:Emit(2)
		end

		tween:Play()
		local v = {
			-8,
			8,
			-12,
			12,
			-16,
			16,
			-25,
			25
		}
		local v2 = {}

		for _ = 0, 15 do
			local v3 = duration + math.random(-25, 25) / 100
			local part2 = Instance.new("Part")
			Util.Debris:AddItem(part2, 5)
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = createVector(0.1, 0.1, 10)
			part2.Color = color or Color3.fromRGB(82, 17, 140)
			part2.Material = Enum.Material.Glass
			part2.Transparency = 1
			local specialMesh2 = Instance.new("SpecialMesh")
			specialMesh2.MeshType = Enum.MeshType.Sphere
			specialMesh2.Parent = part2
			local vector2 = Vector3.new(v[math.random(duration, #v)], math.random(-1, 8), v[math.random(1, #v)])
			local vector3 = Vector3.new(math.random(-50, 50), math.random(-15, 40), math.random(-50, 50))
			local vector4 = Vector3.new(math.random(-50, 50), math.random(-15, 40), math.random(-50, 50))
			part2.Position = humanoidRootPart.Position + vector2
			table.insert(v2, {
				part2,
				part2.Position,
				vector3,
				vector4,
				v3,
				part2.Position
			})
			local v4 = math.random(3, 5)
			local tween2 = TweenService:Create(
				part2,
				TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(v4, v4, v4),
					Color = color,
					Transparency = 0
				}
			)
			tween2.Completed:Connect(function()
				part2:Destroy()
			end)
			tween2:Play()
			part2.Parent = _WorldOrigin
		end

		local lastTime = tick()

		while tick() - lastTime <= duration do
			if humanoidRootPart == nil then
				continue
			end

			local v3 = tick() - lastTime

			for _, positions in pairs(v2) do
				local v4 = {
					positions[2],
					positions[2]:Lerp(humanoidRootPart.Position + positions[3], 0.25),
					positions[2]:Lerp(humanoidRootPart.Position + positions[4], 0.75),
					humanoidRootPart.Position
				}
				local v5 = cubicBezier(v3 / duration, unpack(v4))

				if part then
					part.Position = humanoidRootPart.Position
				end

				positions[1].CFrame = CFrame.new(v5, positions[6])
				positions[6] = positions[1].Position
			end

			RunService.RenderStepped:Wait()
		end
	end)
end

function trailSegment(p, p2, p3, duration, color)
	local magnitude = (p.p - p2.p).magnitude
	local clone = FX:WaitForChild("VenomEffects").FlightSegment:Clone()
	clone.CFrame = CFrame.new((p.p + p2.p) / 2, p2.p) * CFrame.Angles(0, 1.5707963267948966, 0)
	clone.Size = Vector3.new(magnitude, p3, p3)
	Util.Debris:AddItem(clone, duration + 2)
	clone.Transparency = 0
	clone.Material = Enum.Material.Glass
	clone.Parent = _WorldOrigin
	clone.Color = color
	clone.Dissipation:Destroy()
	spawn(function()
		wait(duration)
		magnitude = (p.p - p2.p).magnitude
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(clone.Size.X, 0, 0),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			wait(5)
			clone:Destroy()
		end)
		tween:Play()
	end)
	return clone
end

function trailSegmentEnd(position, p, duration, color)
	spawn(function()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, duration + 2)
		part.Anchored = true
		part.Size = Vector3.new(p, p, p)
		part.Color = color
		part.Material = Enum.Material.Glass
		part.CanCollide = false
		part.CastShadow = false
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.CFrame = CFrame.new(position)
		part.Parent = _WorldOrigin
		TweenService:Create(part, TweenInfo.new(0.01, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Size = Vector3.new(p, p, p),
			Transparency = 0
		}):Play()
		wait(duration)
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(0, 0, 0),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		return part
	end)
end

local function endEffect(position, color)
	Util.Sound:Play("AcidFizzle", position, nil, 0.7 + math.random(-10, 10) / 100, 2)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(0.05, 0.05, 0.05)
	part.Color = color or Color3.fromRGB(82, 17, 140)
	part.Material = Enum.Material.Glass
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part
	part.Position = position
	local clone = FX:WaitForChild("VenomEffects").FlyStart:Clone()
	local attachment = clone.Attachment
	attachment.Parent = part
	clone:Destroy()
	local tween = TweenService:Create(
		part,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Size = createVector(45, 45, 45),
			Color = color or Color3.fromRGB(125, 15, 161)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	part.Parent = _WorldOrigin

	for _, child in pairs(attachment:GetChildren()) do
		child:Emit(2)
	end

	tween:Play()
end

local function seekerExplosion(p, color, color3)
	if (p.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	Util.Sound:Play("VenomSplat", p.p, nil, math.random(100, 155) / 100, 1)
	Util.Sound:Play("VenomBlast", p.p, nil, math.random(180, 210) / 100, 1)
	local clone = FX:WaitForChild("VenomEffects").HydraSeekerBlast:Clone()
	Util.Debris:AddItem(clone, 4)
	local core = clone.Core
	local inner = clone.Inner
	local outer = clone.Outer
	local partCloud = clone.PartCloud
	local smoke = core.Att.Smoke
	local color2 = Color3.fromRGB(
		math.abs(math.clamp(color.R * 255, 0, 255) - 40),
		math.abs(math.clamp(color.G * 255, 0, 255) - 40),
		(math.abs(math.clamp(color.B * 255, 0, 255) - 40))
	)
	smoke.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 20, 156)),
		ColorSequenceKeypoint.new(1, color)
	})
	smoke:Emit(40)
	local tween = TweenService:Create(
		inner,
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Size = inner.Size * 20,
			Color = color
		}
	)
	TweenService:Create(outer, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Size = outer.Size * 20,
		Color = color3
	})
	tween.Completed:Connect(function()
		inner:Destroy()
		outer:Destroy()
	end)
	tween:Play()
	spawn(function()
		local clone2 = partCloud:Clone()
		partCloud:Destroy()
		clone2.Parent = nil
		Util.Debris:AddItem(clone2, 5)
		local v = math.rad((math.random(-90, 90)))

		for i = 1, 3 do
			local position = (CFrame.new(p.p) * CFrame.Angles(0, v + 2.0943951023931953 * i, 0) * CFrame.new(0, 0, -30)).p
			local clone3 = clone2:Clone()
			Util.Debris:AddItem(clone3, 5)
			clone3.Size = createVector(0.05, 0.05, 0.05)
			clone3.Position = p.p
			clone3.CFrame = CFrame.new(p.p) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				(math.rad((math.random(-90, 90))))
			)
			clone3.Color = color2
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(math.random(50, 80) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = createVector(15, 15, 15)
				}
			)
			local tween3 = TweenService:Create(
				clone3,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Position = position,
					Orientation = Vector3.new(math.random(-170, 170), math.random(-170, 170), math.random(-170, 170)),
					Color = color
				}
			)
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			clone3.Parent = _WorldOrigin
			tween2:Play()
			tween3:Play()
			local clone4 = FX:WaitForChild("VenomEffects").Ribbons:Clone()
			Util.Debris:AddItem(clone4, 2)
			clone4.CFrame = CFrame.new(p.p) * CFrame.Angles(0, math.rad((math.random(-90, 90))), 0)
			clone4.Size = createVector(0.05, 0.05, 0.05)
			clone4.Color = color
			local tween4 = TweenService:Create(
				clone4,
				TweenInfo.new(math.random(15, 20) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(80, 15, 80),
					CFrame = clone4.CFrame * CFrame.new(0, math.random(-4, 4), 0) * CFrame.Angles(
						0,
						({ -1, 1 })[math.random(1, 2)] * 3.12413936106985,
						0
					)
				}
			)
			tween4.Completed:Connect(function()
				clone4:Destroy()
			end)
			clone4.Parent = _WorldOrigin
			tween4:Play()
		end
	end)
	Util.Sound:Play("VenomSplat", p.p, nil, 1 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("VenomBlast", p.p, nil, 2.5 + math.random(-10, 10) / 100, 0.2)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - p.p).magnitude <= 35 then
		Util.CameraShaker:ShakeOnce(5, 10, 0.1, 0.8)
	end

	clone:SetPrimaryPartCFrame(p * CFrame.Angles(0, math.random(-180, 180), 0))
	clone.Parent = _WorldOrigin
end

local function newSwirl(p, p2)
	local v = { p2, Color3.fromRGB(86, 0, 148) }
	local v2 = math.random(185, 200)
	local clone = FX:WaitForChild("VenomEffects").Ribbons:Clone()
	clone.Transparency = 1
	Util.Debris:AddItem(clone, 3)
	clone.Color = v[math.random(1, #v)]
	clone.Size = Vector3.new(v2, v2 / 5, v2)
	clone.CFrame = CFrame.new(p + Vector3.new(0, math.random(-10, 10), 0)) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		0
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(math.random(3, 5) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0.05, 0.05, 0.05),
			Color = p2 or Color3.fromRGB(125, 15, 161),
			Transparency = 0,
			CFrame = clone.CFrame * CFrame.Angles(
				math.rad((math.random(-5, 5))),
				math.rad(180 * ({ -1, 1 })[math.random(1, 2)]),
				(math.rad((math.random(-5, 5))))
			)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function explosion(cframe, color, colorOuter)
	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	Util.Sound:Play("VenomSplat", cframe.p, nil, 0.5 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("VenomBlast", cframe.p, nil, 1 + math.random(-10, 10) / 100, 2)
	local clone = FX:WaitForChild("VenomEffects").VenomXBlast:Clone()
	Util.Debris:AddItem(clone, 8)
	clone:SetPrimaryPartCFrame(cframe)
	local origin = clone.Origin
	origin.Spirals:Destroy()
	origin.Smog:Destroy()
	clone.Parent = _WorldOrigin
	local p = cframe.p
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.8)
		end
	end

	spawn(function()
		for _ = 0, 8 do
			wait(0.05)
			newSwirl(cframe.p, color)
		end
	end)

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Inner" or child.Name == "Outer" then
			local color2

			if child.Name == "Inner" and color then
				color2 = color
			elseif child.Name == "Outer" then
				color2 = colorOuter
			else
				color2 = false
			end

			child.Color = color2
			local tween = TweenService:Create(
				child,
				TweenInfo.new(math.random(10, 15) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = child.Size * 65
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
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 45,
					CFrame = child.CFrame * cframe2 * CFrame.new(0, 20, 0),
					Transparency = 1
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Tatters" then
			child.Size = createVector(1, 20, 1)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(80, 6, 80),
					CFrame = child.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
					Transparency = 1,
					Color = color
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "LiquidWave" then
			child.Color = colorOuter
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(90, 1, 90),
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Cloud" then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 15,
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -2.9670597283903604, 0),
					Color = color
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "ShockwaveFlat" then
			child.Color = color
			child.Size += createVector(0, 90, 0)
			child.CFrame *= CFrame.new(0, 50, 0)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(193.364, 5.989, 194.99),
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, -30, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "1" then
			child.Color = color
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(65, 0, 65, 0)
				}
			)
			local tween2 = TweenService:Create(
				child.img,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1,
					Rotation = 90
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
			tween2:Play()
		elseif child.Name == "2" then
			child.Color = colorOuter
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(95, 0, 95, 0)
				}
			)
			local tween2 = TweenService:Create(
				child.img,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1,
					Rotation = -180
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
			tween2:Play()
		elseif child.Name == "3" then
			child.Color = colorOuter
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(120, 0, 120, 0)
				}
			)
			local tween2 = TweenService:Create(
				child.img,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1,
					Rotation = 180
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
			tween2:Play()
		elseif child.Name == "Shock" then
			child.img.Rotation = math.random(-180, 180)
			child.img.ImageColor3 = color
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = UDim2.new(150, 0, 150, 0)
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		end
	end
end

return function(player)
	local step = player.Step

	if step == 1 then
		local _ = player.HoldValue
		local character = player.Character
		local duration = player.Duration
		local color = player.Color
		local colorOuter = player.ColorOuter

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				local clones = {}

				local function newHead()
					local clone = FX:WaitForChild("VenomEffects").UltHydraHeadSmall:Clone()
					Util.Debris:AddItem(clone, 10)
					table.insert(clones, clone)
					clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)

					for _, child in pairs(clone:GetChildren()) do
						child.Color = colorOuter or Color3.fromRGB(163, 0, 76)
					end

					local colorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, colorOuter or Color3.fromRGB(179, 8, 99)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 17, 106))
					})
					clone.TrailPart.LT.Color = colorSequence
					clone.TrailPart.RT.Color = colorSequence
					clone.Parent = _WorldOrigin
				end

				newHead()
				newHead()
				newHead()
				local v = true

				if humanoid then
					humanoid.Died:Connect(function()
						v = false
					end)
				else
					v = false
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < duration or v and player.HoldValue and player.HoldValue.Value == true
				end

				implode(humanoidRootPart, 0.35, color) -- equivalent call inferred; original call site unknown
				local clone = FX:WaitForChild("VenomEffects").UltHydraHead:Clone()
				clone.TrailPart:Destroy()
				Util.Debris:AddItem(clone, 10)
				clone.Parent = _WorldOrigin

				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						part.Color = color or Color3.fromRGB(124, 50, 117)
					end
				end

				local mouthAttachment = clone.Ball.MouthAttachment
				local bodyAttachment = clone.Ball.BodyAttachment
				local flatSmog = mouthAttachment.FlatSmog
				local mouthSmog = mouthAttachment.MouthSmog
				local uprightSmog = bodyAttachment.UprightSmog
				flatSmog.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 19, 96)),
					ColorSequenceKeypoint.new(1, color or Color3.fromRGB(72, 0, 154))
				})
				mouthSmog.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 10, 96)),
					ColorSequenceKeypoint.new(0.8, color or Color3.fromRGB(82, 19, 96)),
					ColorSequenceKeypoint.new(1, color or Color3.fromRGB(173, 19, 81))
				})
				uprightSmog.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(154, 16, 74)),
					ColorSequenceKeypoint.new(0.8, color or Color3.fromRGB(74, 0, 152)),
					ColorSequenceKeypoint.new(1, color or Color3.fromRGB(72, 0, 154))
				})
				local v3 = {}

				for _, child in pairs(clone:GetChildren()) do
					table.insert(v3, { child, child.Size })
				end

				for _, v4 in pairs(v3) do
					v4[1].Size = createVector(0.05, 0.05, 0.05)
				end

				for _, v4 in pairs(v3) do
					v4[1].Transparency = 1
				end

				for _, v4 in pairs(v3) do
					TweenService:Create(
						v4[1],
						TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Transparency = 0,
							Size = v4[2]
						}
					):Play()
				end

				local v4 = {}
				local clone2 = FX:WaitForChild("VenomEffects").VenomBolt.MeshInner:Clone()
				local clone3 = FX:WaitForChild("VenomEffects").VenomBolt.MeshOuter:Clone()
				Util.Debris:AddItem(clone3, 60)
				Util.Debris:AddItem(clone2, 60)
				local clones2 = {}

				local function spiralEffect(p, _)
					local clone4 = nil
					local size = nil

					if p == 1 then
						clone4 = FX:WaitForChild("VenomEffects").FullSwirl:Clone()
						size = clone4.Size * 5
					elseif p == 2 then
						clone4 = FX:WaitForChild("VenomEffects").LightSwirl:Clone()
						size = clone4.Size * 5
					elseif p == 3 then
						clone4 = FX:WaitForChild("VenomEffects").Ribbons:Clone()
						size = clone4.Size * 5
					end

					clone4.CFrame = humanoidRootPart.CFrame
					clone4.Size = createVector(0.05, 0.05, 0.05)
					Util.Debris:AddItem(clone4, 3)
					table.insert(clones2, clone4)
					clone4.Parent = _WorldOrigin
					TweenService:Create(
						clone4,
						TweenInfo.new(
							math.random(20, 25) / 10,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.Out,
							0,
							false,
							0
						),
						{
							Size = size,
							Color = Color3.fromRGB(163, 0, 76),
							Transparency = 1
						}
					).Completed:Connect(function()
						clone4:Destroy()
					end)
				end

				local function newFluid()
					local clone4 = clone2:Clone()
					local clone5 = clone3:Clone()
					local clone6 = FX:WaitForChild("VenomEffects").VenomWind:Clone()
					clone6.Size = createVector(13.109, 15.4662, 13.16)
					clone6.Color = color
					clone4.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 4)
					clone4.Color = color
					clone5.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 4)
					clone5.Color = colorOuter
					clone6.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 6) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone4.Parent = clone
					clone5.Parent = clone
					clone6.Parent = clone
					local tween = TweenService:Create(
						clone4,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(38.1, 30.5, 38.1),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						clone5,
						TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(39.12, 30, 39.12),
							Transparency = 1
						}
					)
					local tween3 = TweenService:Create(
						clone6,
						TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = createVector(20, 15, 20),
							Transparency = 0
						}
					)
					tween.Completed:Connect(function()
						clone4:Destroy()
					end)
					tween2.Completed:Connect(function()
						clone5:Destroy()
					end)
					tween3.Completed:Connect(function()
						clone6:Destroy()
					end)
					table.insert(v4, {
						clone4,
						clone5,
						clone6,
						1,
						0
					})
					tween:Play()
					tween2:Play()
					tween3:Play()
				end

				clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
				local cFrame = nil
				local v5 = nil
				local now = 0
				local now2 = 0
				local total = 0

				while (tick() - lastTime < duration or v and player.HoldValue and player.HoldValue.Value == true) and humanoidRootPart do
					clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
					cFrame = cFrame or clone.PrimaryPart.CFrame

					if v5 then
						local magnitude = (clone.PrimaryPart.CFrame.p - cFrame.p).magnitude
						v5.CFrame = CFrame.new((clone.PrimaryPart.CFrame.p + cFrame.p) / 2, cFrame.p) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
						v5.Size = Vector3.new(magnitude, 16.904, 16.904)
					end

					if tick() - now > 0.35 then
						v5 = trailSegment(clone.PrimaryPart.CFrame, cFrame, 16.904, 0.5, color)
						cFrame = clone.PrimaryPart.CFrame
						trailSegmentEnd((v5.CFrame * CFrame.new(-v5.Size.X / 2, 0, 0)).p, 16.904, 0.5, color)
						now = tick()
					end

					if tick() - now2 > 0.25 then
						newFluid()
						spiralEffect(math.random(1, 3), color)
						now2 = tick()
					end

					for _, v6 in pairs(v4) do
						v6[1].CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v6[5] + 2) * CFrame.Angles(
							1.5707963267948966,
							v6[4],
							0
						)
						v6[2].CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v6[5] + 2) * CFrame.Angles(
							1.5707963267948966,
							v6[4],
							0
						)
						v6[3].CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v6[5] - 3) * CFrame.Angles(
							1.5707963267948966,
							-v6[4],
							0
						)
						v6[4] += 0.1
						local v7 = v6[4]
						v6[5] = v7 + (8 - v7) * 0.15
					end

					total += 2

					if #clones > 0 then
						for k, v6 in pairs(clones) do
							if not (v6 and v6.Parent and v6.PrimaryPart) then
								continue
							end

							v6:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame * CFrame.Angles(
								0,
								0,
								(math.rad(total + k * (360 / #clones)))
							) * CFrame.new(0, 15, 0))
							v6:SetPrimaryPartCFrame(CFrame.new(
								v6.PrimaryPart.Position,
								(clone.PrimaryPart.CFrame * CFrame.new(0, 0, -50)).p
							))
						end

						if total >= 360 then
							total = 0
						end
					end

					if #clones2 > 0 then
						for _, v6 in pairs(clones2) do
							if v6 then
								v6.CFrame *= CFrame.Angles(0.08726646259971647, 0, 0)
							end
						end
					end

					RunService.RenderStepped:Wait()
				end

				trailSegmentEnd((v5.CFrame * CFrame.new(-v5.Size.X / 2, 0, 0)).p, 16.904, 0.5, color)

				for _, v6 in pairs(clones) do
					v6:Destroy()
				end

				clones2 = {}
				clones = {}
				clone3:Destroy()
				clone2:Destroy()
				clone:Destroy()

				if humanoidRootPart then
					endEffect(humanoidRootPart.Position, color)
					explosion(
						CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.random(-180, 180), 0),
						color,
						colorOuter
					)
				end
			end
		end
	elseif step == 2 then
		local spawnPos = player.SpawnPos
		local _ = player.Timestamp

		if (spawnPos - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local targets = player.Targets
		local seekerLife = player.seekerLife
		local seekerDist = player.seekerDist
		local seekerDelay = player.seekerDelay
		local projectileOffsets = player.ProjectileOffsets
		local color = player.Color
		local colorOuter = player.ColorOuter

		local function headProjectile(p, position, p2)
			spawn(function()
				local clone = FX:WaitForChild("VenomEffects").UltHydraHeadSmall:Clone()
				Util.Debris:AddItem(clone, 8)
				clone:SetPrimaryPartCFrame(CFrame.new(spawnPos))

				for _, child in pairs(clone:GetChildren()) do
					child.Color = colorOuter or Color3.fromRGB(163, 0, 76)
				end

				local colorSequence = ColorSequence.new({
					ColorSequenceKeypoint.new(0, colorOuter or Color3.fromRGB(179, 8, 99)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 17, 106))
				})
				clone.TrailPart.LT.Color = colorSequence
				clone.TrailPart.RT.Color = colorSequence
				clone.Parent = _WorldOrigin
				local v = {
					p,
					p:Lerp(position, 0.25) + Vector3.new(
						math.random(-150, 150),
						math.random(-2, 10),
						math.random(-150, 150)
					),
					p:Lerp(position, 0.75) + Vector3.new(math.random(-50, 50), math.random(-2, 5), math.random(-50, 50)),
					position
				}
				local lastTime = tick()
				tick()
				local position2 = p

				while tick() - lastTime <= seekerDelay do
					local v2 = tick() - lastTime
					local v3 = cubicBezier(math.max(0.001, v2) / seekerDelay, unpack(v))
					clone:SetPrimaryPartCFrame(cflerp(
						clone.PrimaryPart.CFrame,
						CFrame.new(v3, position2) * CFrame.Angles(0, 3.141592653589793, 0),
						0.25
					))
					position2 = clone.PrimaryPart.Position
					RunService.RenderStepped:Wait()
				end

				if p2 == nil then
					if clone then
						local center = clone.TrailPart.Center
						center.Ring.Enabled = false
						center.Sparks.Enabled = false
						Util.Debris:AddItem(clone.TrailPart, 3)
						clone.TrailPart.Parent = _WorldOrigin
						clone:Destroy()
					end

					seekerExplosion(
						CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
						color,
						colorOuter
					)
				else
					Util.Sound:Play("Woosh", spawnPos, nil, 1.2 + math.random(-10, 10) / 100, 1)
					local lastTime2 = tick()
					tick()

					while tick() - lastTime2 <= 0.5 and p2 ~= nil do
						local _ = tick() - lastTime2
						clone:SetPrimaryPartCFrame(cflerp(
							clone.PrimaryPart.CFrame,
							CFrame.new(clone.PrimaryPart.Position, p2.Position),
							0.1
						))
						local _ = clone.PrimaryPart.Position
						RunService.RenderStepped:Wait()
					end

					local position3

					if p2 ~= nil then
						position3 = p2.Position
					end

					Util.Sound:Play("SeekerFire", clone.PrimaryPart.Position, nil, math.random(100, 125) / 100, 1)

					if clone then
						local center = clone.TrailPart.Center
						center.Ring.Enabled = true
						center.Sparks.Enabled = true
					end

					local cframe = CFrame.new(clone.PrimaryPart.Position, position3)
					local lastTime3 = tick()
					local cFrame = cframe
					local v2 = 0.03333333333333333

					while tick() - lastTime3 < seekerLife do
						local _ = (tick() - lastTime3) / seekerLife
						local v3 = (tick() - lastTime3) / 100 / (seekerLife / 100)
						cFrame = clone.PrimaryPart.CFrame
						local v4 = cflerp(cframe, cframe * CFrame.new(0, 0, -seekerDist), v3)
						clone:SetPrimaryPartCFrame(v4)
						clone.TrailPart.CFrame = clone.TrailPart.CFrame * CFrame.Angles(0, 0, (math.rad(v2 * 25 * 30)))
						local magnitude = (cFrame.p - v4.p).Magnitude
						local ray, _, _ = Util.Ray(
							cFrame.p,
							cFrame.lookVector.Unit * magnitude,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if ray or not clone then
							break
						else
							v2 = RunService.RenderStepped:Wait()
						end
					end

					if clone then
						local center = clone.TrailPart.Center
						center.Ring.Enabled = false
						center.Sparks.Enabled = false
						Util.Debris:AddItem(clone.TrailPart, 3)
						clone.TrailPart.Parent = _WorldOrigin
						clone:Destroy()
					end

					seekerExplosion(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0), color)
				end
			end)
		end

		Util.Sound:Play("WaterSplash3", spawnPos, nil, 0.9 + math.random(-10, 10) / 100, 2)
		local v = spawnPos + projectileOffsets[1]
		local target = targets[1]
		spawn(function()
			local clone = FX:WaitForChild("VenomEffects").UltHydraHeadSmall:Clone()
			Util.Debris:AddItem(clone, 8)
			clone:SetPrimaryPartCFrame(CFrame.new(spawnPos))

			for _, child in pairs(clone:GetChildren()) do
				child.Color = colorOuter or Color3.fromRGB(163, 0, 76)
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorOuter or Color3.fromRGB(179, 8, 99)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 17, 106))
			})
			clone.TrailPart.LT.Color = colorSequence
			clone.TrailPart.RT.Color = colorSequence
			clone.Parent = _WorldOrigin
			local v2 = {
				spawnPos,
				spawnPos:Lerp(v, 0.25) + Vector3.new(
					math.random(-150, 150),
					math.random(-2, 10),
					math.random(-150, 150)
				),
				spawnPos:Lerp(v, 0.75) + Vector3.new(math.random(-50, 50), math.random(-2, 5), math.random(-50, 50)),
				v
			}
			local lastTime = tick()
			tick()
			local position = spawnPos

			while tick() - lastTime <= seekerDelay do
				local v3 = tick() - lastTime
				local v4 = cubicBezier(math.max(0.001, v3) / seekerDelay, unpack(v2))
				clone:SetPrimaryPartCFrame(cflerp(
					clone.PrimaryPart.CFrame,
					CFrame.new(v4, position) * CFrame.Angles(0, 3.141592653589793, 0),
					0.25
				))
				position = clone.PrimaryPart.Position
				RunService.RenderStepped:Wait()
			end

			if target == nil then
				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(
					CFrame.new(v) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
					color,
					colorOuter
				)
			else
				Util.Sound:Play("Woosh", spawnPos, nil, 1.2 + math.random(-10, 10) / 100, 1)
				local lastTime2 = tick()
				tick()

				while tick() - lastTime2 <= 0.5 and target ~= nil do
					local _ = tick() - lastTime2
					clone:SetPrimaryPartCFrame(cflerp(
						clone.PrimaryPart.CFrame,
						CFrame.new(clone.PrimaryPart.Position, target.Position),
						0.1
					))
					local _ = clone.PrimaryPart.Position
					RunService.RenderStepped:Wait()
				end

				local position2

				if target ~= nil then
					position2 = target.Position
				end

				Util.Sound:Play("SeekerFire", clone.PrimaryPart.Position, nil, math.random(100, 125) / 100, 1)

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = true
					center.Sparks.Enabled = true
				end

				local cframe = CFrame.new(clone.PrimaryPart.Position, position2)
				local lastTime3 = tick()
				local cFrame = cframe
				local v3 = 0.03333333333333333

				while tick() - lastTime3 < seekerLife do
					local _ = (tick() - lastTime3) / seekerLife
					local v4 = (tick() - lastTime3) / 100 / (seekerLife / 100)
					cFrame = clone.PrimaryPart.CFrame
					local v5 = cflerp(cframe, cframe * CFrame.new(0, 0, -seekerDist), v4)
					clone:SetPrimaryPartCFrame(v5)
					clone.TrailPart.CFrame = clone.TrailPart.CFrame * CFrame.Angles(0, 0, (math.rad(v3 * 25 * 30)))
					local magnitude = (cFrame.p - v5.p).Magnitude
					local ray, _, _ = Util.Ray(
						cFrame.p,
						cFrame.lookVector.Unit * magnitude,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray or not clone then
						break
					else
						v3 = RunService.RenderStepped:Wait()
					end
				end

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0), color)
			end
		end)
		local v2 = spawnPos + projectileOffsets[2]
		local target2 = targets[2]
		spawn(function()
			local clone = FX:WaitForChild("VenomEffects").UltHydraHeadSmall:Clone()
			Util.Debris:AddItem(clone, 8)
			clone:SetPrimaryPartCFrame(CFrame.new(spawnPos))

			for _, child in pairs(clone:GetChildren()) do
				child.Color = colorOuter or Color3.fromRGB(163, 0, 76)
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorOuter or Color3.fromRGB(179, 8, 99)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 17, 106))
			})
			clone.TrailPart.LT.Color = colorSequence
			clone.TrailPart.RT.Color = colorSequence
			clone.Parent = _WorldOrigin
			local v3 = {
				spawnPos,
				spawnPos:Lerp(v2, 0.25) + Vector3.new(
					math.random(-150, 150),
					math.random(-2, 10),
					math.random(-150, 150)
				),
				spawnPos:Lerp(v2, 0.75) + Vector3.new(math.random(-50, 50), math.random(-2, 5), math.random(-50, 50)),
				v2
			}
			local lastTime = tick()
			tick()
			local position = spawnPos

			while tick() - lastTime <= seekerDelay do
				local v4 = tick() - lastTime
				local v5 = cubicBezier(math.max(0.001, v4) / seekerDelay, unpack(v3))
				clone:SetPrimaryPartCFrame(cflerp(
					clone.PrimaryPart.CFrame,
					CFrame.new(v5, position) * CFrame.Angles(0, 3.141592653589793, 0),
					0.25
				))
				position = clone.PrimaryPart.Position
				RunService.RenderStepped:Wait()
			end

			if target2 == nil then
				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(
					CFrame.new(v2) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
					color,
					colorOuter
				)
			else
				Util.Sound:Play("Woosh", spawnPos, nil, 1.2 + math.random(-10, 10) / 100, 1)
				local lastTime2 = tick()
				tick()

				while tick() - lastTime2 <= 0.5 and target2 ~= nil do
					local _ = tick() - lastTime2
					clone:SetPrimaryPartCFrame(cflerp(
						clone.PrimaryPart.CFrame,
						CFrame.new(clone.PrimaryPart.Position, target2.Position),
						0.1
					))
					local _ = clone.PrimaryPart.Position
					RunService.RenderStepped:Wait()
				end

				local position2

				if target2 ~= nil then
					position2 = target2.Position
				end

				Util.Sound:Play("SeekerFire", clone.PrimaryPart.Position, nil, math.random(100, 125) / 100, 1)

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = true
					center.Sparks.Enabled = true
				end

				local cframe = CFrame.new(clone.PrimaryPart.Position, position2)
				local lastTime3 = tick()
				local cFrame = cframe
				local v4 = 0.03333333333333333

				while tick() - lastTime3 < seekerLife do
					local _ = (tick() - lastTime3) / seekerLife
					local v5 = (tick() - lastTime3) / 100 / (seekerLife / 100)
					cFrame = clone.PrimaryPart.CFrame
					local v6 = cflerp(cframe, cframe * CFrame.new(0, 0, -seekerDist), v5)
					clone:SetPrimaryPartCFrame(v6)
					clone.TrailPart.CFrame = clone.TrailPart.CFrame * CFrame.Angles(0, 0, (math.rad(v4 * 25 * 30)))
					local magnitude = (cFrame.p - v6.p).Magnitude
					local ray, _, _ = Util.Ray(
						cFrame.p,
						cFrame.lookVector.Unit * magnitude,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray or not clone then
						break
					else
						v4 = RunService.RenderStepped:Wait()
					end
				end

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0), color)
			end
		end)
		local v3 = spawnPos + projectileOffsets[3]
		local target3 = targets[3]
		spawn(function()
			local clone = FX:WaitForChild("VenomEffects").UltHydraHeadSmall:Clone()
			Util.Debris:AddItem(clone, 8)
			clone:SetPrimaryPartCFrame(CFrame.new(spawnPos))

			for _, child in pairs(clone:GetChildren()) do
				child.Color = colorOuter or Color3.fromRGB(163, 0, 76)
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorOuter or Color3.fromRGB(179, 8, 99)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 17, 106))
			})
			clone.TrailPart.LT.Color = colorSequence
			clone.TrailPart.RT.Color = colorSequence
			clone.Parent = _WorldOrigin
			local v4 = {
				spawnPos,
				spawnPos:Lerp(v3, 0.25) + Vector3.new(
					math.random(-150, 150),
					math.random(-2, 10),
					math.random(-150, 150)
				),
				spawnPos:Lerp(v3, 0.75) + Vector3.new(math.random(-50, 50), math.random(-2, 5), math.random(-50, 50)),
				v3
			}
			local lastTime = tick()
			tick()
			local position = spawnPos

			while tick() - lastTime <= seekerDelay do
				local v5 = tick() - lastTime
				local v6 = cubicBezier(math.max(0.001, v5) / seekerDelay, unpack(v4))
				clone:SetPrimaryPartCFrame(cflerp(
					clone.PrimaryPart.CFrame,
					CFrame.new(v6, position) * CFrame.Angles(0, 3.141592653589793, 0),
					0.25
				))
				position = clone.PrimaryPart.Position
				RunService.RenderStepped:Wait()
			end

			if target3 == nil then
				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(
					CFrame.new(v3) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
					color,
					colorOuter
				)
			else
				Util.Sound:Play("Woosh", spawnPos, nil, 1.2 + math.random(-10, 10) / 100, 1)
				local lastTime2 = tick()
				tick()

				while tick() - lastTime2 <= 0.5 and target3 ~= nil do
					local _ = tick() - lastTime2
					clone:SetPrimaryPartCFrame(cflerp(
						clone.PrimaryPart.CFrame,
						CFrame.new(clone.PrimaryPart.Position, target3.Position),
						0.1
					))
					local _ = clone.PrimaryPart.Position
					RunService.RenderStepped:Wait()
				end

				local position2

				if target3 ~= nil then
					position2 = target3.Position
				end

				Util.Sound:Play("SeekerFire", clone.PrimaryPart.Position, nil, math.random(100, 125) / 100, 1)

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = true
					center.Sparks.Enabled = true
				end

				local cframe = CFrame.new(clone.PrimaryPart.Position, position2)
				local lastTime3 = tick()
				local cFrame = cframe
				local v5 = 0.03333333333333333

				while tick() - lastTime3 < seekerLife do
					local _ = (tick() - lastTime3) / seekerLife
					local v6 = (tick() - lastTime3) / 100 / (seekerLife / 100)
					cFrame = clone.PrimaryPart.CFrame
					local v7 = cflerp(cframe, cframe * CFrame.new(0, 0, -seekerDist), v6)
					clone:SetPrimaryPartCFrame(v7)
					clone.TrailPart.CFrame = clone.TrailPart.CFrame * CFrame.Angles(0, 0, (math.rad(v5 * 25 * 30)))
					local magnitude = (cFrame.p - v7.p).Magnitude
					local ray, _, _ = Util.Ray(
						cFrame.p,
						cFrame.lookVector.Unit * magnitude,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray or not clone then
						break
					else
						v5 = RunService.RenderStepped:Wait()
					end
				end

				if clone then
					local center = clone.TrailPart.Center
					center.Ring.Enabled = false
					center.Sparks.Enabled = false
					Util.Debris:AddItem(clone.TrailPart, 3)
					clone.TrailPart.Parent = _WorldOrigin
					clone:Destroy()
				end

				seekerExplosion(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0), color)
			end
		end)
	end
end