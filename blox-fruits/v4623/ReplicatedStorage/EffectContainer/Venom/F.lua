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
local function implode(humanoidRootPart, duration, p)
	spawn(function()
		Util.Sound:Play("AcidCast", humanoidRootPart, nil, 1.5 + math.random(-10, 10) / 100, 2)
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(0.05, 0.05, 0.05)
		part.Color = p or Color3.fromRGB(82, 17, 140)
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
				Size = createVector(15, 15, 15),
				Color = Color3.fromRGB(125, 15, 161)
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

		for _ = 0, 8 do
			local v3 = duration + math.random(-25, 25) / 100
			local part2 = Instance.new("Part")
			Util.Debris:AddItem(part2, 5)
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = createVector(0.1, 0.1, 10)
			part2.Color = p or Color3.fromRGB(82, 17, 140)
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
					Color = Color3.fromRGB(125, 15, 161),
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

function trailSegment(p, p2, p3, p4)
	local magnitude = (p.p - p2.p).magnitude
	local clone = FX:WaitForChild("VenomEffects").FlightSegment:Clone()
	clone.CFrame = CFrame.new((p.p + p2.p) / 2, p2.p) * CFrame.Angles(0, 1.5707963267948966, 0)
	clone.Size = Vector3.new(magnitude, p3, p3)
	Util.Debris:AddItem(clone, p4 + 2)
	clone.Transparency = 0
	clone.Material = Enum.Material.Glass
	clone.Parent = _WorldOrigin
	spawn(function()
		if clone.Parent == nil then
			return
		end

		clone.Dissipation.Enabled = true
		wait(p4)
		magnitude = (p.p - p2.p).magnitude
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(clone.Size.X, 0, 0),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			if clone:FindFirstChild("Dissipation") then
				clone.Dissipation.Enabled = false
			end

			wait(3)
			clone:Destroy()
		end)
		tween:Play()
	end)
	return clone
end

function trailSegmentEnd(position, p, p2)
	spawn(function()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, p2 + 2)
		part.Anchored = true
		part.Size = Vector3.new(p, p, p)
		part.Color = Color3.fromRGB(82, 17, 140)
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
		wait(p2)
		local tween = TweenService:Create(
			part,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
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
			Size = createVector(35, 35, 35),
			Color = Color3.fromRGB(125, 15, 161)
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

local function explosion(cframe)
	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	Util.Sound:Play("VenomSplat", cframe.p, nil, 0.5 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("VenomBlast", cframe.p, nil, 1 + math.random(-10, 10) / 100, 2)
	local clone = FX:WaitForChild("VenomEffects").VenomXBlast:Clone()
	Util.Debris:AddItem(clone, 8)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin
	local origin = clone.Origin
	origin.Spirals:Destroy()
	origin.Smog:Destroy()
	local p = cframe.p
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.8)
		end
	end

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Inner" or child.Name == "Outer" then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(math.random(10, 15) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = child.Size * 35
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "PoisonCrescent" then
			local cframe2 = CFrame.Angles(
				math.rad((math.random(-30, 30))),
				2.9670597283903604,
				(math.rad((math.random(-30, 30))))
			)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 30,
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
				TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(80, 3, 80),
					CFrame = child.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
					Transparency = 1
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "LiquidWave" then
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
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = child.Size * 5,
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "ShockwaveFlat" then
			child.Size += createVector(0, 50, 0)
			child.CFrame *= CFrame.new(0, 30, 0)
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(183.364, 4.989, 184.99),
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
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(35, 0, 35, 0)
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
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(45, 0, 45, 0)
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
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(100, 0, 100, 0)
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
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = UDim2.new(100, 0, 100, 0)
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

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
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

				implode(humanoidRootPart, 0.35, nil) -- equivalent call inferred; original call site unknown
				local clone = FX:WaitForChild("VenomEffects").HydraHead:Clone()
				clone.TrailPart:Destroy()
				clone.Parent = _WorldOrigin
				local v4 = {}

				for _, child in pairs(clone:GetChildren()) do
					table.insert(v4, { child, child.Size })
				end

				for _, v5 in pairs(v4) do
					v5[1].Size = createVector(0.05, 0.05, 0.05)
				end

				for _, v5 in pairs(v4) do
					v5[1].Transparency = 1
				end

				for _, v5 in pairs(v4) do
					TweenService:Create(
						v5[1],
						TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Transparency = 0,
							Size = v5[2]
						}
					):Play()
				end

				local v5 = {}
				local clone2 = FX:WaitForChild("VenomEffects").VenomBolt.MeshInner:Clone()
				local clone3 = FX:WaitForChild("VenomEffects").VenomBolt.MeshOuter:Clone()
				Util.Debris:AddItem(clone3, 60)
				Util.Debris:AddItem(clone2, 60)

				local function newFluid()
					local clone4 = clone2:Clone()
					local clone5 = clone3:Clone()
					local clone6 = FX:WaitForChild("VenomEffects").VenomWind:Clone()
					clone6.Size = createVector(3.109, 0.4662, 3.16)
					clone4.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 4)
					clone5.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 4)
					clone6.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 1) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone4.Parent = clone
					clone5.Parent = clone
					clone6.Parent = _WorldOrigin
					local tween = TweenService:Create(
						clone4,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(15.1, 20.5, 15.1),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						clone5,
						TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(15.12, 20, 15.12),
							Transparency = 1
						}
					)
					local tween3 = TweenService:Create(
						clone6,
						TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = createVector(10, 3, 10),
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
					table.insert(v5, {
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
				local v6 = nil
				local now = 0
				local now2 = 0

				while (tick() - lastTime < duration or v and player.HoldValue and player.HoldValue.Value == true) and humanoidRootPart do
					clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
					cFrame = cFrame or clone.PrimaryPart.CFrame

					if v6 then
						local magnitude = (clone.PrimaryPart.CFrame.p - cFrame.p).magnitude
						v6.CFrame = CFrame.new((clone.PrimaryPart.CFrame.p + cFrame.p) / 2, cFrame.p) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
						v6.Size = Vector3.new(magnitude, 7.5, 7.5)
					end

					if tick() - now > 0.35 then
						v6 = trailSegment(clone.PrimaryPart.CFrame, cFrame, 7.5, 2)
						cFrame = clone.PrimaryPart.CFrame
						trailSegmentEnd((v6.CFrame * CFrame.new(-v6.Size.X / 2, 0, 0)).p, 7.5, 2)
						now = tick()
					end

					if tick() - now2 > 0.25 then
						newFluid()
						now2 = tick()
					end

					for _, v7 in pairs(v5) do
						v7[1].CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v7[5] + 2) * CFrame.Angles(
							1.5707963267948966,
							v7[4],
							0
						)
						v7[2].CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v7[5] + 2) * CFrame.Angles(
							1.5707963267948966,
							v7[4],
							0
						)
						v7[3].CFrame = v7[3].CFrame * CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0.2617993877991494, 0)
						v7[4] += 0.1
						local v8 = v7[4]
						v7[5] = v8 + (8 - v8) * 0.15
					end

					RunService.RenderStepped:Wait()
				end

				if v6 then
					trailSegmentEnd((v6.CFrame * CFrame.new(-v6.Size.X / 2, 0, 0)).p, 7.5, 2)
				end

				clone3:Destroy()
				clone2:Destroy()
				clone:Destroy()

				if humanoidRootPart then
					endEffect(humanoidRootPart.Position, Color3.fromRGB(82, 17, 140))
					explosion(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.random(-180, 180), 0))
				end
			end
		end
	elseif step == 2 then
		local cFrame = player.CFrame
		local _ = player.Impact
		local _ = player.Timestamp

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
			return
		end
	end
end