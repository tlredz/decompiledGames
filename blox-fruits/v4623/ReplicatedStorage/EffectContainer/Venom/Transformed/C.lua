local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService2 = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function drip(position, vector2, outerColor, duration)
	spawn(function()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 10)
		part.Size = vector2 + createVector(2, -2, 2)
		part.Color = outerColor
		part.CanCollide = false
		part.Anchored = true
		part.Material = Enum.Material.Glass
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.Position = position
		part.Parent = _WorldOrigin
		local ray, position2, v2 = Util.Ray(
			position,
			CFrame.new(position, position - createVector(0, 10, 0)).lookVector.Unit * 150,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Size = vector2 + Vector3.new(0, vector2.Y + 3, 0)
			}
		)
		local tween2 = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Position = position2
			}
		)
		local tween3 = TweenService:Create(
			specialMesh,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Scale = createVector(0, 1, 0)
			}
		)
		tween:Play()
		tween2:Play()
		tween3:Play()
		tween2.Completed:Connect(function()
			part:Destroy()

			if position2 and ray then
				local part2 = Instance.new("Part")
				Util.Debris:AddItem(part2, 10)
				part2.Size = createVector(0, 0, 0)
				part2.Color = outerColor
				part2.CanCollide = false
				part2.Anchored = true
				part2.Material = Enum.Material.Glass
				local specialMesh2 = Instance.new("SpecialMesh")
				specialMesh2.MeshType = Enum.MeshType.Cylinder
				specialMesh2.Parent = part2
				part2.CFrame = CFrame.new(position2, position2 + v2) * CFrame.Angles(0, 1.5707963267948966, 0)
				part2.Parent = _WorldOrigin
				local v3 = math.random(2, 3)
				local tween4 = TweenService:Create(
					part2,
					TweenInfo.new(duration / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = Vector3.new(0.05, v3, v3)
					}
				)
				tween4.Completed:Connect(function()
					part2:Destroy()
				end)
				tween4:Play()
			end
		end)
	end)
end

local function twister(p, p2, color)
	Util.Sound:Play("Wind", p, nil, 0.3 + math.random(-10, 10) / 100, 0.25)
	local v = {}

	for i = 0, 8 do
		local size = Vector3.new(i + 5, i + 5, i + 5) + Vector3.new(i * 2, i, i * 2)
		local clone = FX:WaitForChild("VenomEffects").VenomWind2:Clone()
		Util.Debris:AddItem(clone, p2 + 5)
		clone.Color = color
		clone.Transparency = 1
		clone.CFrame = CFrame.new(p + Vector3.new(0, i * 5 + -10, 0)) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			3.141592653589793
		)
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 0,
				Size = size
			}
		)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(0.05, 0.05, 0.05)
			}
		)
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		tween.Completed:Connect(function()
			wait(p2 - 2)
			tween2:Play()
		end)
		local v5 = { clone, clone.CFrame, ({ -1, 1 })[math.random(1, 2)] }
		table.insert(v, v5)
		tween:Play()
	end

	local total = 0
	local v2 = 0.016666666666666666
	local lastTime = tick()
	spawn(function()
		while tick() - lastTime <= p2 do
			for k, v3 in pairs(v) do
				v3[1].CFrame = v3[2] * CFrame.Angles(0, math.rad(v3[3] * total), 0) * CFrame.new(0, 0, -0.3 * k)
			end

			total += v2 * 20 * 60
			v2 = RunService2.RenderStepped:Wait()
		end

		for _, v3 in pairs(v) do
			if v3[1] then
				v3[1]:Destroy()
			end
		end

		v = nil
	end)
end

local function particle(cFrame, p, p2, p3)
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

local function newRing(lifetime, position, innerColor, outerColor, p)
	local clone = FX:WaitForChild("VenomEffects").SmogRing:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)

	if not p then
		for _, child in pairs(clone:GetChildren()) do
			if child.Name ~= "Inner" and child.Name ~= "Outer" then
				child:Destroy()
			end
		end
	end

	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, innerColor),
		ColorSequenceKeypoint.new(1, outerColor)
	})
	clone:SetPrimaryPartCFrame(CFrame.new(position))
	clone.Inner.Color = innerColor
	clone.Outer.Color = outerColor
	clone.Inner.Smog.Color = colorSequence
	spawn(function()
		for _ = 0, 5 do
			wait(0.5)
			clone.Inner.Smog:Emit(10)
		end
	end)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, lifetime + 5)
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Position = position
	part.Parent = _WorldOrigin
	local clone2 = FX:WaitForChild("VenomEffects").RingHaze:Clone()
	clone2.Color = colorSequence
	local attachment = Instance.new("Attachment")
	attachment.Parent = clone.Inner
	clone2.Parent = part
	spawn(function()
		wait(lifetime - 2)
		clone2.Enabled = false
	end)

	for _, child in pairs(clone:GetChildren()) do
		if child == clone.Inner or child == clone.Outer then
			child.Size /= 100
			local tween = TweenService:Create(
				child,
				TweenInfo.new(lifetime / 3 * 2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 400
				}
			)
			local tween2 = TweenService:Create(
				child,
				TweenInfo.new(lifetime / 3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(50, 0, 50),
					Position = child.Position - createVector(0, 10, 0)
				}
			)
			local v = child
			tween2.Completed:Connect(function()
				wait(5)

				if v.Parent then
					v.Parent:Destroy()
				end
			end)
			local v2 = child
			tween.Completed:Connect(function()
				if v2 == clone.Inner then
					v2.Smog:Emit(20)
				end

				tween2:Play()
			end)
			tween:Play()
		elseif child.Name == "Ribbon" or child.Name == "Ribbon2" then
			if child.Color == Color3.fromRGB(163, 0, 76) then
				child.Color = outerColor
			else
				child.Color = innerColor
			end

			child.Size /= 100
			local tween = TweenService:Create(
				child,
				TweenInfo.new(lifetime / 3 * 2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 250 - createVector(0, 30, 0)
				}
			)
			local tween2 = TweenService:Create(
				child,
				TweenInfo.new(lifetime / 3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(50, 0, 50),
					Position = child.Position - createVector(0, 10, 0)
				}
			)
			local v = child
			tween2.Completed:Connect(function()
				v:Destroy()
			end)
			tween.Completed:Connect(function()
				tween2:Play()
			end)
			tween:Play()
		end
	end

	return clone
end

local function newSwirl(position, outerColor)
	local v = { outerColor, Color3.fromRGB(86, 0, 148) }
	local v2 = math.random(65, 75)
	local clone = FX:WaitForChild("VenomEffects").Ribbons:Clone()
	clone.Transparency = 1
	Util.Debris:AddItem(clone, 3)
	clone.Color = v[math.random(1, #v)]
	clone.Size = Vector3.new(v2, v2 / 5, v2)
	clone.CFrame = CFrame.new(position + Vector3.new(0, math.random(-10, 10), 0)) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		0
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(math.random(5, 8) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0.05, 0.05, 0.05),
			Color = outerColor or Color3.fromRGB(125, 15, 161),
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

return function(data)
	local position = data.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1600 then
		return
	end

	local lifetime = data.Lifetime
	local timestamp = data.Timestamp
	local v = lifetime - (Util.MasterClock:GetTime() - timestamp)
	local innerColor = data.InnerColor
	local outerColor = data.OuterColor
	Util.Sound:Play("HydraHiss", position, nil, 0.8 + math.random(-10, 10) / 100, 1)
	Util.Sound:Play("PrimeChime", position, nil, 1 + math.random(-10, 10) / 100, 2)

	for _ = 0, 10 do
		wait()
		newSwirl(position, outerColor)
	end

	wait(0.25)
	Util.Sound:Play("Wind", position, nil, 0.25, 0.25)
	Util.Sound:Play("AcidCast", position, nil, 0.5 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("AcidBubble", position, nil, 0.5 + math.random(-10, 10) / 100, 2)
	local v2 = newRing(lifetime, position, innerColor, outerColor, true)
	local v3 = newRing(lifetime, position, innerColor, outerColor)
	v2.Parent = _WorldOrigin
	v3.Parent = _WorldOrigin
	local clone = FX:WaitForChild("VenomEffects").PoisonCloud:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)
	clone:SetPrimaryPartCFrame(CFrame.new(position + createVector(0, 80, 0)))
	local inner = clone.Inner
	local outer = clone.Outer
	inner.Color = innerColor
	outer.Color = outerColor

	for _, child in pairs(clone:GetChildren()) do
		local size

		if child.Name == "Inner" then
			child.Size = createVector(0, 0, 0)
			size = createVector(219.27878, 51.407196, 206.13838)
		else
			child.Size = createVector(0, 0, 0)
			size = createVector(221.87878, 54.007195, 208.73839)
		end

		local tween = TweenService:Create(
			child,
			TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = size
			}
		)
		local tween2 = TweenService:Create(
			child,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
			{
				Size = size + createVector(-10, 2, -10)
			}
		)
		local tween3 = TweenService:Create(
			child,
			TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				Size = createVector(0, 0, 0)
			}
		)
		tween3.Completed:Connect(function()
			clone:Destroy()
		end)
		tween.Completed:Connect(function()
			tween2:Play()
			wait(lifetime - 2)
			tween3:Play()
		end)
		tween:Play()
	end

	clone.Parent = _WorldOrigin
	local lastTime = tick()
	local lastTime2 = tick()
	local lastTime3 = tick()
	local total = 0
	local total2 = 0
	local v4 = 0.016666666666666666

	while tick() - lastTime <= v do
		v2:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(total), 0))
		v3:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(-total + 5), 0))

		for _, child in pairs(v2:GetChildren()) do
			if child.Name == "Ribbon" then
				child.CFrame = CFrame.new(child.Position) * CFrame.Angles(0, -math.rad(total2), 0)
			elseif child.Name == "Ribbon2" then
				child.CFrame = CFrame.new(child.Position) * CFrame.Angles(0, -math.rad(total2 - 90), 0)
			end
		end

		total += 2 / (tick() - lastTime) * v4 * 60
		total2 += (tick() - lastTime) * v4 * 60

		if tick() - lastTime2 >= 0.07 and clone ~= nil then
			drip(
				(inner.CFrame * CFrame.new(
					math.random(-inner.Size.X / 3, inner.Size.X / 3),
					0,
					math.random(-inner.Size.Z / 3, inner.Size.Z / 3)
				)).p,
				Vector3.new(math.random(55, 75) / 100, 1, math.random(55, 75) / 100),
				outerColor,
				1
			) -- equivalent call inferred; original call site unknown
			lastTime2 = tick()
		end

		if tick() - lastTime3 >= 0.5 then
			local v5 = position + Vector3.new(math.random(-100, 100), math.random(-5, 10), math.random(-100, 100))
			particle(
				CFrame.new(v5) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
				math.random(15, 25) / 10,
				math.random(20, 30) / 10,
				math.random(-25, 25)
			)
			lastTime3 = tick()
		end

		v4 = RunService2.RenderStepped:Wait()
	end
end