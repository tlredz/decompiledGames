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

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function debrisPart(data, p, p2)
	local v = math.random(40, 100) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * math.random(100, 150)
	part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(math.random(10, 15) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = createVector(0.1, 0.1, 0.1)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	return part
end

local function windEffect(cFrame)
	local clone = FX:WaitForChild("StringEffects").StringWind:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = cFrame
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Color = Color3.new(1, 1, 1),
			Size = createVector(30, 10, 30)
		}
	)
	clone.Parent = _WorldOrigin
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function swirlDecal(cFrame, p)
	spawn(function()
		local clone = FX:WaitForChild("StringEffects").StringSpinDecal:Clone()
		Util.Debris:AddItem(clone, 6)
		clone.CFrame = cFrame
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(p / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(60, 0.01, 60)
			}
		)
		clone.Parent = _WorldOrigin
		tween:Play()
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		local lastTime = tick()
		local lastTime2 = tick()
		local clones = {}

		while tick() - lastTime < p do
			clone.CFrame *= CFrame.Angles(0, 0.17453292519943295, 0)

			for _, v in pairs(clones) do
				v.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
			end

			if tick() - lastTime2 > 0.1 then
				local v = math.random(20, 30)
				local clone2 = FX:WaitForChild("StringEffects").StringWind:Clone()
				Util.Debris:AddItem(clone2, 3)
				clone2.Size = Vector3.new(v, 1, v)
				clone2.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-120, 120))), 0)
				table.insert(clones, clone2)
				local tween2 = TweenService:Create(
					clone2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1,
						Color = Color3.fromRGB(255, 255, 255),
						Size = createVector(22.5, 22.5, 22.5),
						Position = clone2.Position + createVector(0, 15, 0)
					}
				)
				clone2.Parent = _WorldOrigin
				tween2:Play()
				tween2.Completed:Connect(function()
					clone2:Destroy()
				end)
				lastTime2 = tick()
			end

			RunService.RenderStepped:Wait()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function explosionEffect(radius, position, p)
	spawn(function()
		local ray, v, v2 = Util.Ray(
			position,
			(CFrame.new(position, p) * CFrame.new(0, 0, -1)).lookVector.Unit * 10,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local clone = FX:WaitForChild("StringEffects").GiantStringImpact:Clone()
		Util.Debris:AddItem(clone, 5)
		local primaryPart = clone.PrimaryPart
		local windMesh = clone.WindMesh
		local smokeMesh = clone.SmokeMesh
		local vortexMesh = clone.VortexMesh
		local shockwaveBillboard = clone.ShockwaveBillboard
		local imageLabel = shockwaveBillboard.ImageLabel
		local tween = TweenService:Create(
			shockwaveBillboard,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = UDim2.new(255, 0, 255, 0)
			}
		)
		local tween2 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				ImageTransparency = 1,
				ImageColor3 = Color3.fromRGB(159, 139, 199)
			}
		)
		local stringThreadEmitter = primaryPart:WaitForChild("StringThreadEmitter")
		local v3 = position
		local v4 = CFrame.new(v3, v3 + (v2 or createVector(0, 1, 0))) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone:SetPrimaryPartCFrame(ray and v4 or CFrame.new(v3))
		local shockwave = clone.Shockwave
		vortexMesh.Color = Color3.new(1, 1, 1)

		if ray == nil then
			shockwave:Destroy()
			vortexMesh.CFrame *= CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			windMesh.CFrame *= CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
		else
			windMesh.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			shockwave.Size = createVector(10, 15, 10)
			shockwave.CFrame = shockwave.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			local tween3 = TweenService:Create(
				shockwave,
				TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(85, 3, 85),
					CFrame = shockwave.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-50, 50))),
						0
					),
					Transparency = 1
				}
			)
			tween3.Completed:Connect(function()
				shockwave:Destroy()
			end)
			tween3:Play()

			for _ = 1, math.random(4, 6) do
				debrisPart(ray, v, v2)
			end
		end

		local tween3 = TweenService:Create(
			windMesh,
			TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(100, 35, 100),
				CFrame = windMesh.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}
		)
		smokeMesh.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		local tween4 = TweenService:Create(
			smokeMesh,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(125, 125, 125)
			}
		)
		vortexMesh.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		local tween5 = TweenService:Create(
			vortexMesh,
			TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(100, 20, 100),
				CFrame = vortexMesh.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}
		)
		tween:Play()
		tween2:Play()
		tween3:Play()
		tween4:Play()
		tween5:Play()
		tween4.Completed:Connect(function()
			wait(2)
			clone:Destroy()
		end)
		clone.Parent = _WorldOrigin
		Util.Sound:Play("ExplosionHeavyFast", primaryPart.Position, nil, 1.1 + math.random(-12, 12) / 100, 0.15)
		stringThreadEmitter:Emit(30)
		primaryPart.KiImpact:Emit(1)
		primaryPart.KiSpikes:Emit(1)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - v3).magnitude <= radius + 15 then
			Util.CameraShaker:ShakeOnce(10, 12, 0.1, 1)
		end
	end)
end

local function segmentShell(cFrame, vector2, clones, tweenInTime, tweenOutTime)
	local clone = FX:WaitForChild("StringEffects").GiantStringSegmentShell:Clone()
	Util.Debris:AddItem(clone, 10)
	clone.Color = Color3.fromRGB(100, 100, 100)
	clone.CFrame = cFrame
	clone.Size = vector2
	table.insert(clones, clone)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(tweenInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = Vector3.new(15, vector2.Y, 15)
		}
	)
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(tweenOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = Color3.fromRGB(255, 255, 255),
			Size = Vector3.new(0.1, vector2.Y, 0.1)
		}
	)
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	tween2.Completed:Connect(function()
		if table.find(clones, clone) then
			table.remove(clones, table.find(clones, clone))
		end

		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

return function(data)
	local v = {
		minSegDist = 11,
		newSegRate = 0.01,
		tweenInTime = 0.3,
		tweenOutTime = 0.3
	}
	local timeStamp = data.TimeStamp
	local positionTable = data.PositionTable
	local lifetime = data.Lifetime
	local radius = data.Radius
	local ray, v2, v3 = Util.Ray(
		positionTable[1] + createVector(0, 4, 0),
		-CFrame.new(positionTable[1]).upVector.Unit * 24,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	positionTable[1] = v2
	v.minSegDist = math.max(v.minSegDist, (positionTable[1] - positionTable[#positionTable]).magnitude / 13.5)

	if (positionTable[1] - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local v4 = lifetime - (Util.MasterClock:GetTime() - timeStamp)
	local v5 = {}
	local clones = {}
	local clone = FX:WaitForChild("StringEffects").GiantStringTrack:Clone()
	Util.Debris:AddItem(clone, data.Lifetime * 2 + 3)
	local startPart = clone.StartPart
	local endPart = clone.EndPart
	local clone2 = FX:WaitForChild("StringEffects").GiantStringHead:Clone()
	clone2.Position = positionTable[1]
	clone2.Size = createVector(15, 18, 15)
	clone2.Parent = _WorldOrigin
	startPart.Position = positionTable[1]
	endPart.Position = positionTable[1]
	clone.Parent = _WorldOrigin
	Util.Sound:Play("WhipStrong", startPart.Position)
	Util.Sound:Play("Engulf", endPart, nil, 0.9 + math.random(-12, 12) / 100, 1.4)
	Util.Sound:Play("KiDashLoop", endPart, nil, 0.9 + math.random(-12, 12) / 100, 0.4)
	local v6

	if ray then
		v6 = CFrame.new(v2, v2 + v3) * CFrame.Angles(1.5707963267948966, 0, 0)
	else
		v6 = CFrame.new(startPart.Position, positionTable[2]) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(
			0,
			2,
			0
		)
	end

	swirlDecal(v6, v4) -- equivalent call inferred; original call site unknown
	spawn(function()
		repeat
			wait()
		until #clones > 0

		local total = 20

		while #clones > 0 do
			RunService.RenderStepped:Wait()

			for _, v7 in pairs(clones) do
				v7.CFrame *= CFrame.Angles(0, math.rad(total), 0)
			end

			total += (0 - total) * 0.05
		end
	end)
	local lastTime = tick()
	local lastTime2 = tick()
	local lastTime3 = tick()
	local position = startPart.Position
	local position2 = endPart.Position
	local now = tick() - 1

	while tick() - lastTime <= v4 do
		local v7 = tick() - lastTime
		position2 = endPart.Position
		local v8 = cubicBezier(v7 / v4, unpack(positionTable))
		endPart.CFrame = CFrame.new(v8, position2) * CFrame.Angles(0, 3.141592653589793, 0)
		local v9 = tick() - now > 0.03333333333333333

		if v9 then
			now = tick()
			clone2.CFrame = CFrame.new(v8, position2) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 1.5, 0)
		end

		if tick() - lastTime3 > v7 / v4 * v.newSegRate and (position - position2).magnitude > v.minSegDist then
			if not v9 then
				clone2.CFrame = CFrame.new(v8, position2) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(
					0,
					1.5,
					0
				)
			end

			local clone3 = FX:WaitForChild("StringEffects").GiantStringSegment:Clone()
			Util.Debris:AddItem(clone3, 10)
			local cFrame = CFrame.new(position, position2) * CFrame.Angles(
				-1.5707963267948966,
				math.rad((math.random(-180, 180))),
				0
			) * CFrame.new(0, (position2 - position).magnitude / 2, 0)
			local vector2 = Vector3.new(15, (position2 - position).magnitude + 4, 15)
			clone3.CFrame = cFrame
			clone3.Size = vector2
			position = (cFrame * CFrame.new(0, vector2.Y / 2, 0)).p
			table.insert(clones, clone3)
			local tween = TweenService:Create(
				clone3,
				TweenInfo.new(v.tweenInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Color = Color3.fromRGB(255, 255, 255),
					Size = Vector3.new(15, vector2.Y, 15)
				}
			)
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(v.tweenOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Color = Color3.fromRGB(255, 255, 255),
					Size = Vector3.new(0.1, vector2.Y, 0.1)
				}
			)
			tween.Completed:Connect(function()
				tween2:Play()
			end)
			tween2.Completed:Connect(function()
				if table.find(clones, clone3) then
					table.remove(clones, table.find(clones, clone3))
				end

				clone3:Destroy()
			end)
			clone3.Parent = _WorldOrigin
			tween:Play()
			segmentShell(cFrame, vector2, clones, v.tweenInTime, v.tweenOutTime)
			lastTime3 = tick()
		end

		if tick() - lastTime2 > 0.15 then
			lastTime2 = tick()
			table.insert(
				v5,
				(windEffect(endPart.CFrame * CFrame.Angles(1.5707963267948966, math.rad((math.random(-120, 120))), 0)))
			)
		end

		for _, v10 in pairs(v5) do
			v10.CFrame *= CFrame.Angles(0, 0.17453292519943295, 0)
		end

		RunService.RenderStepped:Wait()
	end

	local clone3 = FX:WaitForChild("StringEffects").GiantStringSegment:Clone()
	Util.Debris:AddItem(clone3, 10)
	local cFrame2 = CFrame.new(position, position2) * CFrame.Angles(
		-1.5707963267948966,
		math.rad((math.random(-180, 180))),
		0
	) * CFrame.new(0, (endPart.Position - position).magnitude / 2, 0)
	local vector2 = Vector3.new(15, (endPart.Position - position).magnitude + 4, 15)
	clone3.CFrame = cFrame2
	clone3.Size = vector2
	local _ = (cFrame2 * CFrame.new(0, vector2.Y / 2, 0)).p
	table.insert(clones, clone3)
	local tween = TweenService:Create(
		clone3,
		TweenInfo.new(v.tweenInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = Color3.fromRGB(255, 255, 255),
			Size = Vector3.new(15, vector2.Y, 15)
		}
	)
	local tween2 = TweenService:Create(
		clone3,
		TweenInfo.new(v.tweenOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Color = Color3.fromRGB(255, 255, 255),
			Size = Vector3.new(0.1, vector2.Y, 0.1)
		}
	)
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	tween2.Completed:Connect(function()
		if table.find(clones, clone3) then
			table.remove(clones, table.find(clones, clone3))
		end

		clone3:Destroy()
	end)
	clone3.Parent = _WorldOrigin
	tween:Play()
	segmentShell(cFrame2, vector2, clones, v.tweenInTime, v.tweenOutTime)
	explosionEffect(radius, endPart.Position, positionTable[4]) -- equivalent call inferred; original call site unknown
	local tween3 = TweenService:Create(
		clone2,
		TweenInfo.new(v.tweenInTime + v.tweenOutTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(1, 20, 1)
		}
	)
	tween3:Play()
	tween3.Completed:Connect(function()
		clone2:Destroy()
	end)
	clone:Destroy()
end