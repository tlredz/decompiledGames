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
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
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

local function emberBlob(value, p, p2, p3)
	local v = value or 3
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, v)
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = Color3.fromRGB(188, 155, 93)
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
			Color = Color3.fromRGB(255, 85, 0)
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

local function heatRing(p)
	local clone = FX:WaitForChild("DragonEffects").HeatwaveRing:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.Size = createVector(0, 0, 0)
	clone.CFrame = p * CFrame.Angles(
		math.rad((math.random(-40, 40))),
		math.rad((math.random(-150, 150))),
		(math.rad((math.random(-40, 40))))
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = Color3.fromRGB(168, 65, 17),
			Size = Vector3.new(math.random(220, 250), 15, math.random(220, 250)),
			CFrame = clone.CFrame * CFrame.Angles(0, 2.2689280275926285, 0),
			Transparency = 1
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function beamRing(cframe, p, widthMultiplier)
	local clone = FX:WaitForChild("DragonEffects").HeatwaveRing:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.Size = createVector(5, 2, 5) * widthMultiplier
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.CFrame = cframe * CFrame.Angles(1.5707963267948966, math.rad((math.random(-150, 150))), 0)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Color = Color3.fromRGB(255, 255, 210),
			Size = createVector(15, 10, 15) * widthMultiplier,
			CFrame = clone.CFrame * CFrame.new(0, p / 2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		}
	)
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = Color3.fromRGB(198, 82, 0),
			Size = createVector(0, 0, 0),
			CFrame = clone.CFrame * CFrame.new(0, p, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		}
	)
	tween2.Completed:Connect(function()
		clone:Destroy()
	end)
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function darkenVision()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	Util.Debris:AddItem(colorCorrectionEffect, 5)
	colorCorrectionEffect.Parent = game:GetService("Lighting")
	local tween = TweenService:Create(
		colorCorrectionEffect,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Brightness = -0.2,
			Contrast = 0.5,
			TintColor = Color3.fromRGB(255, 179, 134)
		}
	)
	tween.Completed:Connect(function()
		colorCorrectionEffect:Destroy()
	end)
	tween:Play()
end

local function newCylinder(items)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)

	for k, item in pairs(items) do
		part[k] = item
	end

	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blast(_, p, p2, p3)
	spawn(function()
		Util.Sound:Play("GenericExplosion3", p, nil, 1 + math.random(-10, 10) / 100, 0.8)
		local clone = FX:WaitForChild("DragonEffects").HeatwaveExplosion:Clone()
		Util.Debris:AddItem(clone, 5)
		local shockwave = clone.Shockwave
		local windRing = clone.WindRing
		local cloudCore = clone.CloudCore
		local cloudMiddle = clone.CloudMiddle
		local cloudShell = clone.CloudShell
		local blastSmoke = clone.PrimaryPart.ParticleAttachment.BlastSmoke
		blastSmoke.Speed = NumberRange.new(p3 * 2.25, p3 * 2.75)
		blastSmoke:Emit(math.random(25, 30))
		local v = CFrame.new(p, p + (p2 == nil and createVector(0, 1, 0) or p2 or createVector(0, 1, 0))) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone:SetPrimaryPartCFrame(v * CFrame.new(0, 1, 0))
		heatRing(v)
		heatRing(v)
		heatRing(v)
		local cframe = CFrame.Angles(
			math.rad((math.random(-50, 50))),
			math.rad((math.random(-170, 170))),
			(math.rad((math.random(-50, 50))))
		)
		local tween = TweenService:Create(
			shockwave,
			TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector3.new(60 + p3, 5, 60 + p3),
				CFrame = shockwave.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 2.792526803190927, 0)
			}
		)
		local tween2 = TweenService:Create(
			windRing,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector3.new(120 + p3, 5, 120 + p3),
				CFrame = windRing.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 2.792526803190927, 0)
			}
		)
		local tween3 = TweenService:Create(
			cloudCore,
			TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(13.136 + p3, 14.308 + p3, 12.472 + p3),
				CFrame = cloudCore.CFrame * cframe
			}
		)
		local tween4 = TweenService:Create(
			cloudMiddle,
			TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(15.096 + p3, 17.954 + p3, 14.751 + p3),
				CFrame = cloudMiddle.CFrame * cframe
			}
		)
		local tween5 = TweenService:Create(
			cloudShell,
			TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(20.606 + p3, 23.772 + p3, 20.488 + p3),
				CFrame = cloudShell.CFrame * cframe
			}
		)

		for _, v2 in pairs({
			{ tween, shockwave },
			{ tween2, windRing }
		}) do
			local v3 = v2
			v2[1].Completed:Connect(function()
				v3[2]:Destroy()
			end)
			v2[1]:Play()
		end

		for _, v2 in pairs({
			{ tween3, cloudCore },
			{ tween4, cloudMiddle },
			{ tween5, cloudShell }
		}) do
			local tween6 = TweenService:Create(
				v2[2],
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(0, 0, 0),
					CFrame = v2[2].CFrame * CFrame.new(math.random(-50, 50), 2, math.random(-50, 50))
				}
			)
			local v3 = v2
			tween6.Completed:Connect(function()
				v3[2]:Destroy()
			end)
			v2[1].Completed:Connect(function()
				tween6:Play()
			end)
			v2[1]:Play()
		end

		clone.Parent = _WorldOrigin

		for _ = 0, 10 do
			local v2 = math.random(5, 8)
			local v3 = math.random(20, 25)
			local v4 = { math.random(-55, -25), math.random(25, 55) }
			local v5 = { math.random(-55, -25), math.random(25, 55) }
			local v6 = { math.random(-55, -25), math.random(25, 55) }
			emberBlob(math.random(15, 20) / 10, 15, 3, {
				CFrame = CFrame.new(p, p + (p2 == nil and createVector(0, 1, 0) or p2 or createVector(0, 1, 0))) * CFrame.Angles(
					math.rad(v4[math.random(1, #v4)]),
					math.rad(v5[math.random(1, #v5)]),
					(math.rad(v6[math.random(1, #v6)]))
				),
				Color = Color3.fromRGB(188, 125, 0),
				Size = Vector3.new(v2, v2, v3)
			})
		end
	end)
end

return function(data)
	local stage = data.Stage or 1
	local _ = data.HoldValue or nil
	local head = data.Head or nil
	local hum = data.Hum or nil
	local mouseP = data.MouseP
	local cframe = mouseP and CFrame.new((head.CFrame * CFrame.new(0, 0, -2)).p, mouseP) or head.CFrame * CFrame.new(
		0,
		0,
		-2
	)

	if head.Name ~= "Head" then
		if stage == 1 then
			cframe *= CFrame.new(0, 1.5, -2)
		else
			cframe *= CFrame.new(0, -9, -2)
		end
	end

	local range = data.Range
	local explosionData = data.ExplosionData or nil
	local blastSize = data.BlastSize
	local widthMultiplier = data.WidthMultiplier
	local windUp = data.WindUp
	local magnitude = (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 100 + (range or 200) * 2 < magnitude then
		return
	end

	local v = true

	if hum then
		hum.Died:Connect(function()
			v = false
		end)
	else
		v = false
	end

	if stage == 1 then
		Util.Sound:Play("Burning", cframe.p, nil, 1.2, 0.5)
		local chorusSoundEffect = Instance.new("ChorusSoundEffect")
		chorusSoundEffect.Parent = Util.Sound:Play(
			"GenericBeamCharge",
			cframe.p,
			nil,
			1.2 + math.random(-15, 15) / 100,
			0.2
		)
		local clone = FX:WaitForChild("DragonEffects").HeatwaveCharge:Clone()
		Util.Debris:AddItem(clone, 60)
		local heatwaveMouthFX = clone.HeatwaveMouthFX
		local _ = heatwaveMouthFX.Fire
		local attachment = heatwaveMouthFX.Attachment
		local mesh = heatwaveMouthFX.Mesh
		local light = attachment.Light
		local v2 = { attachment.Ring, attachment.MiniBlobs, attachment.Blobs }
		Util.Sound:Play("KiDashLoop", heatwaveMouthFX, nil, 0.6, 0.3)
		light.Range = 15
		light.Brightness = 2
		clone:SetPrimaryPartCFrame(cframe)
		clone.Parent = _WorldOrigin
		attachment.EnergyRing:Emit(1)
		attachment.EnergyRing2:Emit(1)
		attachment.Vortex:Emit(1)
		local tween = TweenService:Create(
			light,
			TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, -1, true, 0),
			{
				Range = 25,
				Brightness = 3
			}
		)
		tween.Completed:Connect(function()
			light:Destroy()
		end)
		tween:Play()
		mesh.Scale = createVector(2, 1, 2)
		TweenService:Create(mesh, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {
			Scale = createVector(1, 2, 1)
		}):Play()

		for _, child in pairs(clone:GetChildren()) do
			if child.Name ~= "FireLash" then
				continue
			end

			local v3 = math.random(15, 35)
			child.Size = Vector3.new(v3, v3 / 2, v3)
			child.Transparency = 1
			child.CFrame *= CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
			local _ = child.Orientation * 3
			local tween2 = TweenService:Create(
				child,
				TweenInfo.new(
					math.random(1, 2) / 10 * (windUp / 0.5),
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.In,
					0,
					false,
					0
				),
				{
					Transparency = 0,
					Orientation = child.Orientation * 3
				}
			)
			local tween3 = TweenService:Create(
				child,
				TweenInfo.new(
					math.random(3, 6) / 10 * (windUp / 0.5),
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out,
					0,
					false,
					0
				),
				{
					Size = createVector(0, 0, 0),
					Orientation = child.Orientation * 3
				}
			)
			local v4 = child
			tween3.Completed:Connect(function()
				v4:Destroy()
			end)
			tween2.Completed:Connect(function()
				tween3:Play()
			end)
			tween2:Play()
		end

		local lastTime = tick()
		local lastTime2 = tick()

		local function running()
			return tick() - lastTime < windUp + 0.1 or v and data.HoldValue and data.HoldValue.Value == true
		end

		while (tick() - lastTime < windUp + 0.1 or v and data.HoldValue and data.HoldValue.Value == true) and head ~= nil and data.HoldValue.Parent ~= nil and data.HoldValue.Parent.Parent ~= nil do
			if tick() - lastTime2 > 0.4 then
				lastTime2 = tick()

				for _, v3 in pairs(v2) do
					v3:Emit(1)
				end
			end

			local v3 = head.CFrame * CFrame.new(0, 0, -2)

			if head.Name ~= "Head" then
				v3 *= CFrame.new(0, 1.5, -2)
			end

			if head then
				clone:SetPrimaryPartCFrame(v3)
			end

			for _, child in pairs(clone:GetChildren()) do
				if child.Name == "FireLash" then
					child.Position = child.Position:Lerp(v3.p, 0.05)
				end
			end

			RunService.RenderStepped:Wait()
		end

		wait(0.1)
		clone:Destroy()
	elseif stage == 2 then
		local p = cframe.p
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 25 then
				Util.CameraShaker:ShakeOnce(5, 15, 0.2, 0.5)
			end
		end

		Util.Sound:Play("Burning", cframe.p, nil, 1, 0.5)
		Util.Sound:Play("Roar", cframe.p, nil, 1.4, 0.3)
		Util.Sound:Play("SetFire2", cframe.p, nil, 0.7 + math.random(-10, 10) / 100, 1)
		local parent = Util.Sound:Play("GenericBeamFire", cframe.p, nil, 1.1 + math.random(-10, 10) / 100, 0.3)
		local chorusSoundEffect_2 = Instance.new("ChorusSoundEffect")
		chorusSoundEffect_2.Parent = parent

		for _ = 0, 8 do
			local v3 = math.random(3, 5)
			local v4 = math.random(10, 15)
			local v5 = { math.random(-55, -25), math.random(25, 55) }
			local v6 = { math.random(-55, -25), math.random(25, 55) }
			local v7 = { math.random(-55, -25), math.random(25, 55) }
			emberBlob(math.random(5, 15) / 10, 8, 1, {
				CFrame = cframe * CFrame.Angles(
					math.rad(v5[math.random(1, #v5)]),
					math.rad(v6[math.random(1, #v6)]),
					(math.rad(v7[math.random(1, #v7)]))
				),
				Color = Color3.fromRGB(188, 155, 93),
				Size = Vector3.new(v3, v3, v4)
			})
		end

		local model = Instance.new("Model")
		Util.Debris:AddItem(model, 20)
		local v3 = {
			Size = createVector(1, 2, 2) * widthMultiplier,
			Color = Color3.fromRGB(255, 230, 138),
			Material = Enum.Material.Neon,
			Transparency = 0.5,
			CFrame = cframe,
			Parent = model
		}
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
		part.Anchored = true
		part.CastShadow = false
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)

		for k, v4 in pairs(v3) do
			part[k] = v4
		end

		local v4 = {
			Size = createVector(1, 2.5, 2.5) * widthMultiplier,
			Color = Color3.fromRGB(255, 0, 0),
			Material = Enum.Material.Neon,
			Transparency = 0.85,
			CFrame = cframe,
			Parent = model
		}
		local part2 = Instance.new("Part")
		part2.Shape = Enum.PartType.Cylinder
		part2.Anchored = true
		part2.CastShadow = false
		part2.CanCollide = false
		part2.Size = createVector(1, 1, 1)

		for k, v5 in pairs(v4) do
			part2[k] = v5
		end

		local v5 = {
			Size = createVector(1, 2.65, 2.65) * widthMultiplier,
			Color = Color3.fromRGB(188, 155, 93),
			Material = Enum.Material.Neon,
			Transparency = 0.85,
			CFrame = cframe,
			Parent = model
		}
		local part3 = Instance.new("Part")
		part3.Shape = Enum.PartType.Cylinder
		part3.Anchored = true
		part3.CastShadow = false
		part3.CanCollide = false
		part3.Size = createVector(1, 1, 1)

		for k, v6 in pairs(v5) do
			part3[k] = v6
		end

		local clone_2 = FX:WaitForChild("DragonEffects").Embers:Clone()
		clone_2.Parent = part
		local attachment = Instance.new("Attachment")
		attachment.Position = cframe.p
		attachment.Parent = workspace.Terrain
		local clone = FX:WaitForChild("DragonEffects").EnergyRing:Clone()
		clone.Size = NumberSequence.new(0, 10 * widthMultiplier)
		clone.Parent = attachment
		model.PrimaryPart = part
		model:SetPrimaryPartCFrame(cframe * CFrame.Angles(0, 1.5707963267948966, 0))
		model.Parent = _WorldOrigin
		local v6, v7, v8 = Util.Ray(
			cframe.p,
			cframe.lookVector.Unit * (not explosionData and range or (explosionData - cframe.p).Magnitude),
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local magnitude2 = (cframe.p - v7).Magnitude
		spawn(function()
			for _ = 0, 5 do
				wait(0.05)
				beamRing(cframe, -magnitude2, widthMultiplier)
			end
		end)
		local v9 = false

		for _, v10 in pairs({ part, part2, part3 }) do
			local v11 = (v10 == part and 3 or v10 == part2 and 3.5 or v10 == part3 and 4 or false) * widthMultiplier
			local tween = TweenService:Create(
				v10,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					Size = Vector3.new(magnitude2, 3, 3),
					CFrame = part.CFrame * CFrame.new((cframe.p - v7).Magnitude / 2, 0, 0)
				}
			)
			local tween2 = TweenService:Create(
				v10,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = Vector3.new(magnitude2, v11, v11)
				}
			)
			local tween3 = TweenService:Create(
				v10,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(magnitude2, 0, 0)
				}
			)
			tween3.Completed:Connect(function()
				model:Destroy()
			end)
			tween2.Completed:Connect(function()
				tween3:Play()
			end)
			tween.Completed:Connect(function()
				tween2:Play()

				if not v9 then
					v9 = true

					if explosionData then
						blast(nil, explosionData, nil, blastSize * 2) -- equivalent call inferred; original call site unknown
					else
						blast(nil, v7, v6 and v8, blastSize * 2) -- equivalent call inferred; original call site unknown
					end
				end
			end)
			tween:Play()
		end

		if head:IsDescendantOf(game.Players.LocalPlayer.Character) then
			Util.CameraShaker:ShakeOnce(10, 15, 0.8, 0.8)
			darkenVision()
		else
			local character2 = game.Players.LocalPlayer.Character

			if character2 ~= nil then
				local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - v7).magnitude <= 150 then
					Util.CameraShaker:ShakeOnce(10, 15, 0.8, 0.8)
					darkenVision()
				end
			end
		end

		for _ = 1, 5 do
			clone:Emit(1)
			wait(0.08)
		end

		wait(0.5)
		attachment:Destroy()
	end
end