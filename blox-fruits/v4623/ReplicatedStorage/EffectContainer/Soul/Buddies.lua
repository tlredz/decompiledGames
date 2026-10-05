local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local buddies = FX:WaitForChild("Soul").Buddies
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris
local _ = Util.LightningBolt

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function candyHealProjectile(position, healedRoot, p, p2, p3, p4, p5)
	task.spawn(function()
		if healedRoot then
			local clone = buddies.CandyFX:Clone()
			Util.Debris:AddItem(clone, p + 3)
			clone.Position = position
			local at = clone.At
			local trail = clone.Trail
			local dots = at.Dots
			local ring = at.Ring
			local magnitude = (position - healedRoot.Position).magnitude
			local cframe = CFrame.new(position, healedRoot.Position)
			local v = cframe * CFrame.new(0, 0, -magnitude)
			clone.CFrame = cframe
			clone.Parent = _WorldOrigin
			ring:Emit(1)
			local v2 = {
				position,
				position:Lerp((v * CFrame.new(p2, p3, 0)).p, 0.25),
				position:Lerp((v * CFrame.new(p4, p5, 0)).p, 0.75),
				healedRoot.Position
			}
			local lastTime = tick()
			local lastTime2 = tick()
			local position2 = position

			while tick() - lastTime <= p and healedRoot do
				local v3 = tick() - lastTime
				local v4 = cubicBezier(math.max(0.001, v3) / p, unpack(v2))
				clone.CFrame = CFrame.new(v4, position2) * CFrame.Angles(0, 3.141592653589793, 0)
				position2 = clone.Position

				if tick() - lastTime2 > 0.05 then
					dots:Emit(2)
					lastTime2 = tick()
				end

				v2 = {
					position,
					position:Lerp((v * CFrame.new(p2, p3, 0)).p, 0.25),
					position:Lerp((v * CFrame.new(p4, p5, 0)).p, 0.75),
					healedRoot.Position
				}
				RunService.RenderStepped:Wait()
			end

			trail.Enabled = false

			if healedRoot ~= nil then
				at.Parent = healedRoot
				Util.Debris:AddItem(at, 2)
				dots:Emit(5)
				ring:Emit(1)
			end

			if clone then
				wait(2)
				clone:Destroy()
			end
		end
	end)
end

local v = {
	{
		buddyName = "Flower",
		buddyModel = buddies.Flower
	},
	{
		buddyName = "Tree",
		buddyModel = buddies.Tree
	},
	{
		buddyName = "Candy",
		buddyModel = buddies.Candy
	}
}
local v2 = {
	active = {},
	loopActive = false
}

function v2:StartRenderLoop()
	if v2.loopActive == false then
		task.spawn(function()
			local _, result = pcall(function()
				if #v2.active > 0 then
					v2.loopActive = true

					while #v2.active > 0 do
						for k, v3 in pairs(v2.active) do
							local _ = v3[1]
							local _ = v3[2]
							local v4 = v3[3]
							local v5 = v3[4]
							local v6 = v3[5]
							local v7 = v3[6]

							if v4 ~= nil then
								local v8 = masterClock:GetTime() - v5

								if not (v6 + 5 < v8) then
									if v7 ~= nil and v4.PrimaryPart ~= nil and (v7.Position - v4.PrimaryPart.Position).Magnitude < 300 then
										local cFrame = v4.PrimaryPart.CFrame
										local cframe = CFrame.new(
											cFrame.Position,
											(Vector3.new(v7.Position.X, cFrame.Position.Y, v7.Position.Z))
										)
										v4:SetPrimaryPartCFrame(cflerp(v4.PrimaryPart.CFrame, cframe, 0.2))
									end

									continue
								end
							end

							if v4 ~= nil then
								v4:Destroy()
							end

							table.remove(v2.active, k)
						end

						RunService.RenderStepped:Wait()
					end

					v2.loopActive = false
				end
			end)

			if result then
				warn("[Soul Fruit - Client] Something went wrong in the Buddy main loop: \n", result)

				if #v2.active > 0 then
					for _, v3 in pairs(v2.active) do
						if v3[3] then
							v3[3]:Destroy()
						end
					end

					v2.loopActive = false
					v2.active = {}
				end
			end
		end)
	end
end

function v2:Find(p)
	for _, v3 in pairs(v2.active) do
		if v3[2] == p then
			return v3
		end
	end

	return nil
end

function v2:Spawn(p, p2, cframe, p3, p4, p5)
	local clone = v[p].buddyModel:Clone()
	Util.Debris:AddItem(clone, p3 + 5)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin
	table.insert(v2.active, {
		p,
		p2,
		clone,
		p4,
		p3,
		p5
	})
	v2:StartRenderLoop()
	return (v2:Find(p2))
end

function v2:Remove(p)
	for k, v3 in pairs(v2.active) do
		if v3[2] ~= p then
			continue
		end

		if v3[3] ~= nil then
			v3[3]:Destroy()
		end

		table.remove(v2.active, k)
	end
end

local function debrisPart(data, p, p2)
	if (p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local v3 = math.random(40, 100) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 3)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v3, v3, v3)
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

local function vanishSmoke(position, value)
	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local cFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)

	for _ = 1, 8 do
		local clone = buddies.Cloud:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.Size = Vector3.new()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v4 = math.random(25, 38)
		local v5 = math.random(30, 50) / 100
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(v5 / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = Vector3.new(v4, v4, v4) * (value or 1)
			}
		)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cFrame * CFrame.new(0, math.random(5, 15), 0 - math.random(20, 30)) * CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
			}
		)
		tween.Completed:Connect(function()
			if clone then
				clone:Destroy()
			end
		end)
		tween:Play()
		tween2:Play()
		cFrame *= CFrame.Angles(0, 0.7853981633974483, 0)
	end
end

return function(data)
	local index = data.Index
	local uniqueID = data.UniqueID
	local actionID = data.ActionID
	local cFrame = data.CFrame

	if index == 1 then
		if actionID == 1 then
			local lifetime = data.Lifetime
			local timestamp = data.Timestamp
			local initialTarget = data.InitialTarget
			math.max(lifetime - (masterClock:GetTime() - timestamp), 0.5)
			Util.Sound:Play("SeekerFire", cFrame.Position, nil, math.random(20, 25) / 10, 1)
			vanishSmoke(cFrame.Position, 0.5)
			local v3 = v2:Spawn(1, uniqueID, cFrame, lifetime, timestamp, initialTarget or nil)[3]

			if v3 then
				task.spawn(function()
					local track = v3.AnimationController:LoadAnimation(v3.Idle)
					track:Play()
					track:AdjustSpeed(1)
				end)
			end
		elseif actionID == 2 then
			local v3 = v2:Find(uniqueID)
			local v4 = v3 and v3[3]

			if v4 then
				vanishSmoke(v4.PrimaryPart.Position, 0.5)
				Util.Sound:Play("Engulf", v4.PrimaryPart.Position, nil, math.random(16, 20) / 10, 0.5)
			end

			v2:Remove(uniqueID)
		elseif actionID == 3 then
			local targetRootPart = data.TargetRootPart or nil
			local targetRootParts = v2:Find(uniqueID)

			if targetRootParts and targetRootParts[3] then
				if targetRootPart ~= nil then
					targetRootParts[6] = targetRootPart
				end

				local v3 = targetRootParts[3]

				if v3 then
					task.spawn(function()
						local track = v3.AnimationController:LoadAnimation(v3.Attack)
						track:Play()
						track:AdjustSpeed(1.5)
						wait(0.25)
						Util.Sound:Play("HydraHiss", cFrame.Position, nil, math.random(20, 25) / 10, 1)
					end)
				end
			end
		end
	elseif index == 2 then
		if actionID == 1 then
			local lifetime = data.Lifetime
			local timestamp = data.Timestamp
			local initialTarget = data.InitialTarget
			math.max(lifetime - (masterClock:GetTime() - timestamp), 0.5)
			Util.Sound:Play("Wallhit2", cFrame.Position, nil, math.random(9, 11) / 10, 1)
			Util.Sound:Play("TreeRoot", cFrame.Position, nil, math.random(9, 11) / 10, 1)
			local v3 = v2:Spawn(2, uniqueID, cFrame, lifetime, timestamp, initialTarget or nil)[3]

			if v3 then
				task.spawn(function()
					local animationController = v3.AnimationController
					local track = animationController:LoadAnimation(v3.Spawn)
					track:Play()
					track:AdjustSpeed(1)
					local track2 = animationController:LoadAnimation(v3.Idle)
					track2:Play()
					track2:AdjustSpeed(1)
				end)
			end

			local clone = buddies.TreeSpawnFX:Clone()
			Util.Debris:AddItem(clone, 2)
			local ray, v4, v5 = Util.Ray(
				cFrame.Position,
				CFrame.new(cFrame.Position + createVector(0, 2, 0), cFrame.Position - createVector(0, 1, 0)).lookVector.Unit * 20,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				clone.FXHolder.Rock.Color = ColorSequence.new(ray.Color)
				task.spawn(function()
					for _ = 1, 5 do
						debrisPart(ray, v4, v5)
					end
				end)
			end

			clone:SetPrimaryPartCFrame(cFrame)
			clone.Parent = _WorldOrigin
			clone.FXHolder.Rock:Emit(math.random(10, 15))
			clone.FXHolder.Dust:Emit(math.random(12, 15))
			local innerWave = clone.InnerWave
			local outerWave = clone.OuterWave
			local tween = TweenService:Create(
				innerWave,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(100, 2, 100),
					Position = innerWave.Position - createVector(0, 30, 0),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				if innerWave then
					innerWave:Destroy()
				end
			end)
			local tween2 = TweenService:Create(
				outerWave,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(100, 2, 100),
					Position = innerWave.Position - createVector(0, 30, 0),
					Transparency = 1
				}
			)
			tween2.Completed:Connect(function()
				if outerWave then
					outerWave:Destroy()
				end
			end)
			tween2:Play()
			tween:Play()
		elseif actionID == 2 then
			local v3 = v2:Find(uniqueID)
			local v4 = v3 and v3[3]

			if v4 then
				vanishSmoke(v4.PrimaryPart.Position, 1.4)
				Util.Sound:Play("Engulf", v4.PrimaryPart.Position, nil, math.random(16, 20) / 10, 0.5)
			end

			v2:Remove(uniqueID)
		elseif actionID == 3 then
			local targetRootPart = data.TargetRootPart or nil
			local targetRootParts = v2:Find(uniqueID)

			if targetRootParts and targetRootParts[3] then
				if targetRootPart ~= nil then
					targetRootParts[6] = targetRootPart
				end

				Util.Sound:Play("TreeGroan", cFrame.Position, nil, math.random(9, 11) / 10, 2)
				local v3 = targetRootParts[3]

				if v3 then
					task.spawn(function()
						local track = v3.AnimationController:LoadAnimation(v3.Attack)
						track:Play()
						track:AdjustSpeed(1)
						wait(0.5)
						Util.Sound:Play("TreeRoot", cFrame.Position, nil, math.random(9, 11) / 10, 2)
					end)
				end
			end
		end
	elseif index == 3 then
		if actionID == 1 then
			local lifetime = data.Lifetime
			local timestamp = data.Timestamp
			local initialTarget = data.InitialTarget
			math.max(lifetime - (masterClock:GetTime() - timestamp), 0.5)
			Util.Sound:Play("SeekerFire", cFrame.Position, nil, math.random(20, 25) / 10, 1)
			vanishSmoke(cFrame.Position, 0.8)
			local v3 = v2:Spawn(3, uniqueID, cFrame, lifetime, timestamp, initialTarget or nil)[3]

			if v3 then
				task.spawn(function()
					local track = v3.AnimationController:LoadAnimation(v3.Idle)
					track:Play()
					track:AdjustSpeed(1)
				end)
			end
		elseif actionID == 2 then
			local v3 = v2:Find(uniqueID)
			local v4 = v3 and v3[3]

			if v4 then
				vanishSmoke(v4.PrimaryPart.Position, 0.8)
				Util.Sound:Play("Engulf", v4.PrimaryPart.Position, nil, math.random(16, 20) / 10, 0.5)
			end

			v2:Remove(uniqueID)
		elseif actionID == 3 then
			local targetRootPart = data.TargetRootPart or nil
			local targetRootParts = v2:Find(uniqueID)

			if targetRootParts and targetRootParts[3] then
				if targetRootPart ~= nil then
					targetRootParts[6] = targetRootPart
				end

				local v3 = targetRootParts[3]

				if v3 then
					task.spawn(function()
						local track = v3.AnimationController:LoadAnimation(v3.Attack)
						track:Play()
						track:AdjustSpeed(1)
						Util.Sound:Play("RepulseShoot", cFrame.Position, nil, math.random(15, 20) / 10, 2)
					end)
				end
			end
		else
			local healedRoot = actionID == 4 and data.HealedRoot

			if healedRoot then
				if (healedRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
					return
				end

				candyHealProjectile(
					cFrame.Position,
					healedRoot,
					1,
					math.random(-290, 290),
					math.random(65, 155),
					0,
					math.random(30, 65)
				) -- equivalent call inferred; original call site unknown
			end
		end
	end
end