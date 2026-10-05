local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService2 = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function flatten(p)
	return p * createVector(1, 0, 1)
end

local function parabolic(p, p2, p3, p4)
	return p + p2 * p3 + 0.5 * p4 * p3 * p3
end

local function reflect(vector2, p)
	return vector2 - 2 * vector2:Dot(p) * p
end

local function blobSpark(value, p, p2, p3)
	local v = value or 3
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, v)
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = Color3.fromRGB(127, 21, 188)
	part.Material = Enum.Material.Neon
	part.CFrame = p3.CFrame
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part

	for k, v2 in pairs(p3) do
		part[k] = v2
	end

	part.Parent = _WorldOrigin
	local tween = TweenService:Create(
		part,
		TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0, 0, 0),
			Color = Color3.fromRGB(84, 12, 104)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	local lastTime = tick()
	spawn(function()
		tween:Play()
		local v2 = 1

		while tick() - lastTime < v do
			local _ = (tick() - lastTime) / v
			part.CFrame = part.CFrame * CFrame.new(0, 0, -p2) * CFrame.Angles(
				math.rad(p * math.cos(v2 / 5 + math.random(-15, 15) / 10)),
				0,
				0
			)
			v2 += 1
			RunService.RenderStepped:Wait()
		end

		if part then
			part:Destroy()
		end
	end)
end

local function explosionFX(p, color)
	if (p.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local clone = FX:WaitForChild("VenomEffects").VenomZBlast:Clone()
	Util.Debris:AddItem(clone, 4)
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 26, 156)),
		ColorSequenceKeypoint.new(1, color)
	})
	local colorSequence2 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 26, 156)),
		ColorSequenceKeypoint.new(1, color)
	})
	local origin = clone.Origin
	local root = origin.Root
	local shockwaveBillboard = clone.ShockwaveBillboard
	local imageLabel = shockwaveBillboard.ImageLabel
	local dropBillboard = clone.DropBillboard
	local imageLabel2 = dropBillboard.ImageLabel
	local ring = root.Ring
	local smoke = root.Smoke
	smoke.Color = colorSequence2
	ring:Emit(2)
	smoke:Emit(3)
	local v = math.random(60, 100)
	local tween = TweenService:Create(
		shockwaveBillboard,
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Size = UDim2.new(v, 0, v, 0)
		}
	)
	local tween2 = TweenService:Create(
		imageLabel,
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			ImageColor3 = color,
			Rotation = math.random(-180, 180)
		}
	)
	tween.Completed:Connect(function()
		shockwaveBillboard:Destroy()
	end)
	tween:Play()
	tween2:Play()
	local tween3 = TweenService:Create(
		dropBillboard,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = UDim2.new(v, 0, v, 0)
		}
	)
	local tween4 = TweenService:Create(
		imageLabel2,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			ImageTransparency = 1,
			ImageColor3 = color,
			Rotation = math.random(-180, 180)
		}
	)
	tween3.Completed:Connect(function()
		dropBillboard:Destroy()
	end)
	tween3:Play()
	tween4:Play()
	local clone2 = FX:WaitForChild("VenomEffects").Ribbons:Clone()
	Util.Debris:AddItem(clone2, 2)
	clone2.CFrame = CFrame.new(p.p) * CFrame.Angles(
		math.rad((math.random(-20, 20))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-20, 20))))
	)
	clone2.Color = Color3.fromRGB(89, 19, 194)
	local tween5 = TweenService:Create(
		clone2,
		TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = color,
			Size = clone2.Size * 8,
			CFrame = clone2.CFrame * CFrame.Angles(0, 2.9670597283903604, 0),
			Transparency = 1
		}
	)
	tween5.Completed:Connect(function()
		clone2:Destroy()
	end)
	clone2.Parent = _WorldOrigin
	tween5:Play()

	for _ = 0, math.random(6, 10) do
		local clone3 = FX:WaitForChild("VenomEffects").BlastBeam:Clone()
		clone3.Color = colorSequence
		clone3.Parent = root
		clone3.Attachment0 = root
		clone3.Width0 = 8
		local attachment = Instance.new("Attachment")
		attachment.Parent = origin
		clone3.Attachment1 = attachment
		TweenService:Create(
			attachment,
			TweenInfo.new(math.random(1, 2) / 15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Position = Vector3.new(math.random(-30, 30), math.random(-30, 30), math.random(-30, 30))
			}
		):Play()
	end

	Util.Sound:Play("VenomSplat", p.p, nil, 1 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("VenomBlast", p.p, nil, 2.5 + math.random(-10, 10) / 100, 0.2)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - p.p).magnitude <= 25 then
		Util.CameraShaker:ShakeOnce(5, 10, 0.1, 0.5)
	end

	clone:SetPrimaryPartCFrame(p * CFrame.Angles(math.random(180, 180), math.random(180, 180), math.random(180, 180)))
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Inner" or child.Name == "Outer" then
			child.Color = color
			local tween6 = TweenService:Create(
				child,
				TweenInfo.new(math.random(5, 8) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Color = Color3.fromRGB(124, 50, 117),
					Size = child.Size * 20,
					Transparency = 1,
					CFrame = child.CFrame * CFrame.Angles(
						math.random(180, 180),
						math.random(180, 180),
						math.random(180, 180)
					)
				}
			)
			local v2 = child
			tween6.Completed:Connect(function()
				v2:Destroy()
			end)
			tween6:Play()
		elseif child.Name == "PoisonCrescent" then
			local cframe = CFrame.Angles(
				math.rad((math.random(-30, 30))),
				2.9670597283903604,
				(math.rad((math.random(-30, 30))))
			)
			local tween6 = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Color = color,
					Size = child.Size * 15,
					CFrame = child.CFrame * cframe,
					Transparency = 1
				}
			)
			local v2 = child
			tween6.Completed:Connect(function()
				v2:Destroy()
			end)
			tween6:Play()
		elseif child.Name == "Shockwave" then
			child.Size = createVector(1, 10, 1)
			child.Color = color
			local tween6 = TweenService:Create(
				child,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(30, 3, 30),
					CFrame = child.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
					Transparency = 1
				}
			)
			local v2 = child
			tween6.Completed:Connect(function()
				v2:Destroy()
			end)
			tween6:Play()
		elseif child.Name == "LiquidWave" then
			local tween6 = TweenService:Create(
				child,
				TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(30, 2, 30),
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
				}
			)
			local v2 = child
			tween6.Completed:Connect(function()
				v2:Destroy()
			end)
			tween6:Play()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spitProjectile(cFrame, goalPos, timestamp, lifetime, color)
	spawn(function()
		local v = {}
		local clone = FX:WaitForChild("VenomEffects").VenomBolt:Clone()
		Util.Debris:AddItem(clone, lifetime or 10)
		local root = clone.Root
		clone.MeshOuter.Color = color
		clone.Head.Color = color
		local clone2 = clone.MeshOuter:Clone()
		local clone3 = clone.MeshInner:Clone()
		Util.Debris:AddItem(clone2, lifetime or 10)
		Util.Debris:AddItem(clone3, lifetime or 10)
		clone.MeshOuter:Destroy()
		clone.MeshInner:Destroy()

		local function newFluid()
			local clone4 = clone3:Clone()
			local clone5 = clone2:Clone()
			clone4.Parent = clone
			clone5.Parent = clone
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(3.1, 10.5, 3.1),
					Transparency = 1
				}
			)
			local tween2 = TweenService:Create(
				clone5,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(3.12, 10, 3.12),
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

		clone:SetPrimaryPartCFrame(cFrame)
		clone.Parent = _WorldOrigin
		local v2 = masterClock:GetTime() - timestamp
		local v3 = lifetime - v2
		local v4 = cFrame * createVector(0, 2, -2)
		local v5 = (goalPos - v4 - createVector(0, -50, 0) * lifetime * lifetime) / lifetime
		local ray, v6, _ = Util.Ray(
			cFrame.p,
			cFrame.lookVector.Unit * 5,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local position = root.Position
		local lastTime = tick()
		local _ = tick() - v2
		local total = 0

		while clone ~= nil and root ~= nil do
			math.min(1, (tick() - lifetime) / lifetime)
			local v7 = lifetime
			lifetime = v7 + (v3 - v7) * 0.1

			if not clone.PrimaryPart then
				break
			end

			clone:SetPrimaryPartCFrame(CFrame.new(createVector(0, -50, 0) * total * total + v5 * total + v4, position) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			))
			local magnitude = (position - root.Position).magnitude
			local v8
			ray, v6, v8 = Util.Ray(
				root.Position,
				root.CFrame.lookVector.Unit * magnitude * 2,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				explosionFX(CFrame.new(v6, v6 + v8) * CFrame.Angles(-1.5707963267948966, 0, 0), color)
				break
			end

			position = root.Position

			if tick() - lastTime > 0.15 then
				newFluid()
				lastTime = tick()
			end

			for _, v9 in pairs(v) do
				v9[1].CFrame = root.CFrame * CFrame.new(0, 0, v9[4]) * CFrame.Angles(1.5707963267948966, v9[3], 0)
				v9[2].CFrame = root.CFrame * CFrame.new(0, 0, v9[4]) * CFrame.Angles(1.5707963267948966, v9[3], 0)
				v9[3] += 0.1
				local v10 = v9[4]
				v9[4] = v10 + (4.6 - v10) * 0.15
			end

			if lifetime <= total then
				break
			else
				total += RunService2.RenderStepped:Wait()
			end
		end

		if not ray then
			explosionFX(CFrame.new(v6, v6 + createVector(0, 1, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0), color)
		end

		clone:Destroy()
		v = nil
	end)
end

return function(data)
	local step = data.Step

	if step == 1 then
		local positionPart = data.PositionPart

		if positionPart then
			if (positionPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
				return
			end

			Util.Sound:Play("WaterSplash3", positionPart.Position, nil, 0.9 + math.random(-10, 10) / 100, 3)
			local clone = FX:WaitForChild("VenomEffects").VenomZStart:Clone()
			Util.Debris:AddItem(clone, 5)
			clone.Position = positionPart.Position
			clone.Parent = _WorldOrigin

			for _, child in pairs(clone.Attachment:GetChildren()) do
				child:Emit(1)
			end

			for _ = 0, 2 do
				local clone2 = FX:WaitForChild("VenomEffects").VenomWind:Clone()
				Util.Debris:AddItem(clone2, 2)
				clone2.Transparency = 1
				clone2.CFrame = CFrame.new(positionPart.Position) * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					math.rad((math.random(-90, 90))),
					(math.rad((math.random(-90, 90))))
				)
				clone2.Parent = _WorldOrigin
				local tween = TweenService:Create(
					clone2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 0,
						Size = createVector(0, 0, 0),
						CFrame = clone2.CFrame * CFrame.Angles(0, -3.0543261909900767, 0)
					}
				)
				tween.Completed:Connect(function()
					clone2:Destroy()
				end)
				tween:Play()
			end

			wait(2)
			clone:Destroy()
		end
	elseif step == 2 then
		local cFrame = data.CFrame
		local timestamp = data.Timestamp
		local lifetime = data.Lifetime
		local goalPos = data.GoalPos
		local color = data.Color

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		spitProjectile(cFrame, goalPos, timestamp, lifetime, color) -- equivalent call inferred; original call site unknown
		Util.Sound:Play("VenomSplat", cFrame.p, nil, 1.5 + math.random(-10, 10) / 100, 2)
		local v = math.random(12, 15) / 10
		local v2 = math.random(3, 4)
		local v3 = { math.random(-55, -25), math.random(25, 55) }
		local v4 = { math.random(-55, -25), math.random(25, 55) }
		local v5 = { math.random(-55, -25), math.random(25, 55) }
		blobSpark(math.random(8, 10) / 10, 25, 1, {
			CFrame = cFrame * CFrame.Angles(
				math.rad(v3[math.random(1, #v3)]),
				math.rad(v4[math.random(1, #v4)]),
				(math.rad(v5[math.random(1, #v5)]))
			),
			Color = color or Color3.fromRGB(81, 28, 186),
			Size = Vector3.new(v, v, v2)
		})
	end
end