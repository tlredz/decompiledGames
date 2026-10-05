local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local cameraShaker = Util.CameraShaker

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, position, position2, position3, position4)
	return position * (1 - p) ^ 3 + position2 * 3 * p * (1 - p) ^ 2 + position3 * 3 * (1 - p) * p ^ 2 + position4 * p ^ 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function insertFlakeParticles(hitRoot, p)
	local clone = script.ParticleContainer[p]:Clone()
	clone.Parent = hitRoot
	return clone
end

local v = {
	-8,
	8,
	-20,
	20,
	-40,
	40
}
local v2 = {
	0,
	0,
	5,
	5,
	10,
	10
}
local v3 = {
	1,
	1,
	2,
	2,
	3,
	3
}
return function(player)
	local ID = player.ID

	if ID == 1 then
		local character = player.Character
		local holdValue = player.HoldValue

		if character and holdValue then
			local rightHand = character:FindFirstChild("RightHand")
			local leftHand = character:FindFirstChild("LeftHand")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if rightHand and leftHand and humanoid and humanoidRootPart then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > 600 then
					return
				end

				local chargeTime = player.ChargeTime
				local timestamp = player.Timestamp
				local v4 = math.max(0.1, chargeTime - (masterClock:GetTime() - timestamp))
				local play = Util.Sound:Play("IceBlock", rightHand, nil, 1, 0.5)
				play.TimePosition = 0.3
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
				local lastTime = tick()

				local function running()
					if holdValue.Parent == nil or holdValue.Parent.Parent == nil then
						return false
					end

					if rightHand and leftHand and humanoid and humanoidRootPart then
						return tick() - lastTime < 0.1 or diedConnection and player.HoldValue and player.HoldValue.Value == true
					end

					return false
				end

				local v5 = {}
				local v6 = {}

				for i = 1, 2 do
					local clone = script.Flake1:Clone()
					Util.Debris:AddItem(clone, 60)
					local clone_2 = script.ParticleContainer.Charging:Clone()
					clone_2.Parent = clone
					clone.Size = Vector3.new()
					table.insert(i == 1 and v6 or v5, clone)
					local clone_3 = script.ChargeRing:Clone()
					clone_3.Parent = clone
					local clone_4 = script.ChargeRing:Clone()
					clone_4.Parent = clone
					clone.Parent = _WorldOrigin

					for _, child in pairs(clone.Charging:GetChildren()) do
						child.Enabled = true
					end

					TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(1.8, 0.12, 1.8)
					}):Play()
				end

				local clones = {}
				local total = 0

				for i = 1, 2 do
					local clone = script.BeamWind:Clone()
					debris:AddItem(clone, 60)
					clone:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
						0,
						math.rad(i == 1 and 0 or 90),
						0
					))

					if i == 2 then
						for _, child in pairs(clone:GetChildren()) do
							if child.Name == "Beam2" then
								child.Position += createVector(0, 8, 0)
							end
						end
					end

					clone.Parent = _WorldOrigin
					table.insert(clones, clone)
				end

				local v7 = false
				local v8 = 0.016666666666666666

				while running() do
					if not v7 and v4 <= tick() - lastTime then
						local play_2 = Util.Sound:Play("IceBlock", rightHand, nil, 1.3, 0.6)
						play_2.TimePosition = 0.3

						for _, v9 in pairs(v6) do
							local chargeRing = v9:FindFirstChild("ChargeRing")

							if chargeRing then
								chargeRing:Emit(1)
							end
						end

						for _, v9 in pairs(v5) do
							local chargeRing = v9:FindFirstChild("ChargeRing")

							if chargeRing then
								chargeRing:Emit(1)
							end
						end

						for i = 1, 2 do
							for i2 = 1, 2 do
								local clone = script["Flake" .. (i == 1 and 2 or 3)]:Clone()
								Util.Debris:AddItem(clone, 60 - v4)
								local clone_5 = script.ParticleContainer.Charging:Clone()
								clone_5.Parent = clone
								clone.Size = Vector3.new()
								table.insert(i2 == 1 and v6 or v5, clone)
								clone.Parent = _WorldOrigin
								TweenService:Create(
									clone,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = createVector(1.8, 0.12, 1.8) * (1 - i * 0.2),
										Color = Color3.fromRGB(115 - i * 8, 146 - i * 8, 165 - i * 8)
									}
								):Play()
							end
						end

						v7 = true
					end

					for k, v9 in pairs(v6) do
						v9.CFrame = leftHand.CFrame * CFrame.new(-0.2 * k, -0.5 * k, -0.5 * k) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						)
					end

					for k, v9 in pairs(v5) do
						v9.CFrame = rightHand.CFrame * CFrame.new(0.2 * k, -0.5 * k, -0.5 * k) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						)
					end

					for k, v9 in pairs(clones) do
						v9:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
							0,
							math.rad((k == 1 and 0 or 90) + total),
							0
						))
					end

					total += v8 * 5 * 60
					v8 = RunService.RenderStepped:Wait()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				if #v6 > 0 then
					for _, v9 in pairs(v6) do
						v9:Destroy()
					end
				end

				if #v5 > 0 then
					for _, v9 in pairs(v5) do
						v9:Destroy()
					end
				end

				if #clones > 0 then
					for _, folder in pairs(clones) do
						for _, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("Beam") then
								local v9 = effect
								local v10 = folder
								task.spawn(function()
									local v11 = 0.3

									for i = 1, 60 do
										if v9 and v10 then
											v9.Transparency = NumberSequence.new(0 + 1 * (i * 0.6))
											v11 += 1
											RunService.RenderStepped:Wait()
										else
											break
										end
									end
								end)
							elseif effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end
						end
					end
				end

				task.wait(2)

				if #clones > 0 then
					for _, v9 in pairs(clones) do
						v9:Destroy()
					end
				end
			end
		end
	elseif ID == 2 then
		local _ = player.Timestamp
		local cFrame = player.CFrame
		local rootPart = player.RootPart

		if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
			return
		end

		local clone = script.Throw:Clone()
		debris:AddItem(clone, 3)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		Util.Sound:Play("IceShoot", cFrame, nil, 0.5, 0.5)

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude < 75 then
			cameraShaker:ShakeOnce(8, 8, 0, 0.5)
		end

		local ray, v4, v5 = Util.Ray(
			rootPart.Position,
			CFrame.new(rootPart.Position).UpVector.Unit * -10,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone2 = script.SnowDustWave:Clone()
			debris:AddItem(clone2, 1.5)
			clone2.CFrame = CFrame.new(v4, v4 + v5) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = _WorldOrigin
			clone2.Dust:Emit(clone2.Dust:GetAttribute("EmitCount"))
		end
	elseif ID == 3 then
		local timestamp = player.Timestamp
		local cFrame = player.CFrame
		local maxDist = player.MaxDist
		local life = player.Life
		local increment = player.Increment

		if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
			return
		end

		local v4 = masterClock:GetTime() - timestamp
		math.max(0.1, life - v4)
		local clone = script["Flake" .. v3[increment]]:Clone()
		debris:AddItem(clone, life + 1)
		local clone_6 = script.ParticleContainer.Flight:Clone()
		clone_6.Parent = clone
		clone.Size = createVector(2, 0.25, 2)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Util.Sound:Play("WindBlowing", clone, nil, 3, 2)

		for _, child in pairs(clone.Flight:GetChildren()) do
			child.Enabled = true
		end

		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(12, 0.35, 12)
		}):Play()
		local v5 = cFrame * CFrame.new(0, 0, -maxDist) * CFrame.new(v[increment], v2[increment], 0)
		local v6 = cFrame:lerp(v5, 0.25) * CFrame.new(v[increment], v2[increment], 0)
		local v7 = cFrame:lerp(v5, 0.75) * CFrame.new(v[increment], v2[increment], 0)
		local time = masterClock:GetTime()
		local v8 = {
			lastCF = clone.CFrame,
			lastPos = clone.Position,
			currentPos = 0,
			lastDist = 1,
			rotation = 0,
			hit = nil,
			pos = nil,
			norm = nil
		}
		local position = cFrame.Position
		local position2 = v6.Position
		local position3 = v7.Position
		local position4 = v5.Position
		v8.currentPos = position * 1 + position2 * 3 * 0 * 1 + position3 * 3 * 1 * 0 + position4 * 0
		local v9 = math.random(-6, 6)
		local total = 0
		local v10 = 0.016666666666666666

		while masterClock:GetTime() - time + v4 < life do
			local time2 = masterClock:GetTime()
			local _ = (time2 - time + v4) / life
			local v11 = (time2 - time + v4) / 100 / (life / 100)

			if not clone or v8.hit then
				break
			end

			v8.currentPos = cubicBezier(v11, cFrame.Position, v6.Position, v7.Position, v5.Position)
			clone.Position = v8.currentPos
			clone.CFrame = v8.lastCF * CFrame.Angles(0, math.rad(total), (math.rad(v9)))
			v8.lastDist = (v8.lastPos - v8.currentPos).Magnitude
			v8.lastCF = CFrame.new(v8.lastPos, v8.currentPos)
			local ray, pos, norm = Util.Ray(
				v8.lastPos,
				v8.lastCF.lookVector.Unit * v8.lastDist,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			v8.hit = ray
			v8.pos = pos
			v8.norm = norm
			v8.lastPos = v8.currentPos
			total += v10 * 10 * 60
			v10 = RunService.RenderStepped:Wait()
		end

		if clone then
			clone.Transparency = 1

			for _, child in pairs(clone.Flight:GetChildren()) do
				child.Enabled = false
			end

			task.delay(1, function()
				if clone then
					clone:Destroy()
				end
			end)
		end

		local part = Instance.new("Part")
		debris:AddItem(part, 4)
		part.Anchored = true
		part.Transparency = 1
		part.CFrame = v8.lastCF * CFrame.new(0, 1.5707963267948966, 0)
		local clone_7 = script.ParticleContainer.Crash:Clone()
		clone_7.Parent = part
		part.Parent = _WorldOrigin
		Util.Sound:Play("IcebergExplosion2", part.Position, nil, 1.5, 0.5)

		for _, child in pairs(part.Crash:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		if (workspace.CurrentCamera.CFrame.Position - v8.lastCF.Position).magnitude < 150 then
			cameraShaker:ShakeOnce(10, 16, 0, 0.666)
		end
	elseif ID == 4 then
		local hitRoot = player.HitRoot

		if hitRoot and hitRoot.Position then
			if (hitRoot.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 500 then
				return
			end

			Util.Sound:Play("shot", hitRoot, nil, 2.5, 0.7)
			local clone = insertFlakeParticles(hitRoot, "Slash") -- equivalent call inferred; original call site unknown
			debris:AddItem(clone, 3)

			for _, child in pairs(clone:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end
end