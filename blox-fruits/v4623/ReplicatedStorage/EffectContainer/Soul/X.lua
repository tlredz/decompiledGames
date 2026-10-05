local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Soul").X
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris

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

local function getResource(p, p2, items)
	local clone = X[p]:Clone()

	if p2 then
		Util.Debris:AddItem(clone, p2)
	end

	if items then
		for k, item in pairs(items) do
			if clone[k] then
				clone[k] = item
			end
		end
	end

	return clone
end

local function meteorExplosion(position)
	Util.Sound:Play("GenericExplosion", position, nil, 1, math.random(8, 12) / 10)
	local clone = X.MeteorExplosion:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Position = position
	clone.Parent = _WorldOrigin
	clone.Embers:Emit(10)

	for _, child in pairs(clone.Core:GetChildren()) do
		child:Emit(10)
	end
end

local function meteor(startPos, endPos, life, timestamp)
	local _ = masterClock:GetTime() - timestamp
	local clone = X.Meteor:Clone()
	Util.Debris:AddItem(clone, life + 2)
	CFrame.new(startPos, endPos)
	clone:SetPrimaryPartCFrame(CFrame.new(startPos, endPos))
	clone.Parent = _WorldOrigin
	spawn(function()
		local magnitude = (startPos - endPos).Magnitude
		local v = {
			startPos,
			startPos:Lerp(Vector3.new(endPos.X, startPos.Y + magnitude / 0.35, endPos.Z), 0.25),
			startPos:Lerp(Vector3.new(endPos.X, endPos.Y + magnitude / 0.35, endPos.Z), 0.75),
			endPos
		}
		local lastTime = tick()
		local v2 = nil

		while tick() - lastTime <= life do
			local v3 = tick() - lastTime
			v2 = cubicBezier(v3 / life, unpack(v))
			clone:SetPrimaryPartCFrame(CFrame.new(v2))
			RunService.RenderStepped:Wait()
		end

		wait()
		meteorExplosion(v2)
		clone:Destroy()
	end)
end

local function flamePillar(position, life, sizeMul)
	local v = {
		Color3.fromRGB(170, 85, 0),
		Color3.fromRGB(188, 155, 93),
		Color3.fromRGB(213, 115, 61),
		Color3.fromRGB(255, 39, 20)
	}
	TweenService:Create(
		Util.Sound:Play("Burning", position, nil, 0.8, 2),
		TweenInfo.new(life / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Pitch = 1.5
		}
	):Play()
	TweenService:Create(
		Util.Sound:Play("ShortExplosion3", position, nil, 2, 2),
		TweenInfo.new(life / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Pitch = 0.3
		}
	):Play()
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 150 then
			Util.CameraShaker:ShakeOnce(10, 25, 0.3, life)
		end
	end

	local v4 = {}
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = createVector(16, 86, 16) * sizeMul
	part.Position = position + Vector3.new(0, part.Size.Y / 2, 0)
	part.Parent = _WorldOrigin
	Util.Debris:AddItem(part, life + 2)
	local clone = X.Embers:Clone()
	clone.Parent = part
	local clone2 = X.Rings:Clone()
	clone2.Parent = part
	clone2:Emit(4)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.Position = Vector3.new(0, 35 * sizeMul, 0)
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = part
	attachment2.Position = Vector3.new(0, -35 * sizeMul, 0)
	local clone3 = X.CoreBeam:Clone()
	clone3.Parent = part
	clone3.Attachment0 = attachment
	clone3.Attachment1 = attachment2
	local part2 = Instance.new("Part")
	Util.Debris:AddItem(part2, life + 2)
	part2.Size = createVector(1, 1, 1)
	part2.Anchored = true
	part2.CanCollide = false
	part2.Transparency = 1
	part2.Position = position
	part2.Parent = _WorldOrigin
	local clone4 = X.Flames:Clone()
	local clone5 = X.Shockwave:Clone()
	local clone6 = X.Light:Clone()
	clone4.Parent = part2
	clone5.Parent = part2
	clone6.Parent = part2
	local clone7 = X.BlastWave:Clone()
	Util.Debris:AddItem(clone7, 2)
	clone7.Size *= sizeMul
	clone7.Position = position + Vector3.new(0, clone7.Size.Y / 2, 0)
	clone7.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone7,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			CFrame = CFrame.new(position),
			Size = createVector(131, 13, 133) * sizeMul
		}
	)
	tween.Completed:Connect(function()
		if clone7 then
			clone7:Destroy()
		end
	end)
	tween:Play()
	task.spawn(function()
		wait(life)
		clone.Enabled = false
		clone2.Enabled = false
		clone4.Enabled = false
		clone5.Enabled = false
		local tween2 = TweenService:Create(
			clone6,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Brightness = 0,
				Range = 0
			}
		)
		tween2.Completed:Connect(function()
			if clone6 then
				clone6:Destroy()
			end
		end)
		tween2:Play()
	end)
	local v5 = 0.016666666666666666
	local now = tick()
	task.spawn(function()
		local now2 = tick()
		local now3 = tick()
		local now4 = tick()

		while true do
			local now5 = tick()
			local v6 = now5 - now

			if life + 2 < v6 then
				break
			end

			local v7 = v6 / (life + 0.5)

			if clone3 ~= nil then
				clone3.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.148, 0.612 + 0.388 * v7),
					NumberSequenceKeypoint.new(0.282, 0.387 + 0.613 * v7),
					NumberSequenceKeypoint.new(0.433, 0.231 + 0.769 * v7),
					NumberSequenceKeypoint.new(0.576, 0.169 + 0.831 * v7),
					NumberSequenceKeypoint.new(0.708, 0.131 + 0.869 * v7),
					NumberSequenceKeypoint.new(0.843, 0.125 + 0.875 * v7),
					NumberSequenceKeypoint.new(1, 1)
				})
			end

			if v6 < life then
				if now5 - now2 > 0.15 then
					local resource = getResource("FlameMesh", 0.7, {
						CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
						Color = v[math.random(1, #v)]
					})
					resource.Parent = _WorldOrigin
					table.insert(v4, { 1, resource })
					tick()
					local tween2 = TweenService:Create(
						resource,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true, 0),
						{
							Size = createVector(107, 44, 107) * sizeMul
						}
					)
					tween2.Completed:Connect(function()
						if resource then
							resource:Destroy()
						end
					end)
					tween2:Play()
					local resource2 = getResource("FlameMesh", 1, {
						CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
						Color = v[math.random(1, #v)]
					})
					resource2.Parent = _WorldOrigin
					table.insert(v4, { 0, resource2 })
					now2 = tick()
					local tween3 = TweenService:Create(
						resource2,
						TweenInfo.new(0.23, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 2, true, 0),
						{
							Size = createVector(71, 41, 71) * sizeMul
						}
					)
					local tween4 = TweenService:Create(
						resource2,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
						{
							Transparency = 1
						}
					)
					tween3.Completed:Connect(function()
						if resource2 then
							resource2:Destroy()
						end
					end)
					tween3:Play()
					tween4:Play()
				end

				if now5 - now3 > 0.2 then
					local resource = getResource("SplashMesh", 0.7, {
						CFrame = CFrame.new(position + createVector(0, 10, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						),
						Color = v[math.random(1, #v)]
					})
					resource.Parent = _WorldOrigin
					table.insert(v4, { 2, resource })
					now3 = tick()
				end

				if now5 - now4 > 0.08 then
					local resource = getResource("FireballMesh", 0.5, {
						CFrame = CFrame.new(position + Vector3.new(0, part.Size.Y / 2 - 4, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							1.5707963267948966
						)
					})
					resource.Parent = _WorldOrigin
					table.insert(v4, { 3, resource })
					now4 = tick()
					clone4:Emit(1)
					clone2:Emit(1)
					clone5:Emit(1)
					clone:Emit(1)
				end
			end

			if #v4 > 0 then
				local v8 = v5 * 60

				for k, v9 in pairs(v4) do
					if v9[2] == nil then
						table.remove(v4, k)
					elseif v9[1] == 0 then
						v9[2].CFrame *= CFrame.new(0, v8 * 1.25, 0) * CFrame.Angles(0, math.rad(v8 * -25), 0)
					elseif v9[1] == 1 then
						v9[2].CFrame *= CFrame.new(0, v8 * 0.7, 0) * CFrame.Angles(0, math.rad(v8 * 25), 0)
						local v11 = v9[2]
						local transparency = v9[2].Transparency
						local v12 = v8 * 0.07
						v11.Transparency = transparency + (1 - transparency) * v12
					elseif v9[1] == 2 then
						v9[2].CFrame *= CFrame.new(0, v8 * -0.25, 0) * CFrame.Angles(0, math.rad(v8 * 2), 0)
						local v11 = v9[2]
						local transparency = v9[2].Transparency
						local v12 = v8 * 0.1
						v11.Transparency = transparency + (1 - transparency) * v12
						local v13 = v9[2]
						local size = v9[2].Size
						local v14 = createVector(145, 2, 145) * sizeMul
						local v15 = v8 * 0.1
						v13.Size = size + (v14 - size) * v15
					elseif v9[1] == 3 then
						v9[2].CFrame *= CFrame.new(v8 * -0.8, 0, 0) * CFrame.Angles(math.rad(v8 * 15), 0, 0)
						local v11 = v9[2]
						local size = v9[2].Size
						local v12 = createVector(50, 65, 65) * sizeMul
						local v13 = v8 * 0.05
						v11.Size = size + (v12 - size) * v13
						local v14 = v9[2]
						local transparency = v9[2].Transparency
						local v15 = v8 * 0.12
						v14.Transparency = transparency + (1 - transparency) * v15
					end
				end
			end

			v5 = RunService.RenderStepped:Wait()
		end

		if #v4 > 0 then
			for _, v6 in pairs(v4) do
				if v6[2] then
					v6[2]:Destroy()
				end
			end
		end

		v4 = nil
	end)
end

return function(instance)
	local stage = instance.Stage or 1

	if stage == 1 then
		local rootPart = instance.RootPart

		if (rootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		Util.Sound:Play("thrown", rootPart, nil, math.random(10, 12) / 10, 1)
		local clone = X.ThrowCrescent:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.CFrame = rootPart.CFrame * CFrame.Angles(0.5235987755982988, 0, 0)
		clone.Parent = _WorldOrigin
		clone.Dots:Emit(10)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = clone.CFrame * CFrame.Angles(0, 3.0543261909900767, 0)
			}
		)
		tween.Completed:Connect(function()
			TweenService:Create(
				clone,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1
				}
			):Play()
			wait(2)

			if clone then
				clone:Destroy()
			end
		end)
		tween:Play()
	elseif stage == 2 then
		local _ = instance.CFrame

		if (instance.GoalPosition - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end
	elseif stage == 3 then
		local position = instance.Position
		local life = instance.Life

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		flamePillar(position, life, instance.SizeMul)
	elseif stage == 4 then
		local startPos = instance.StartPos
		local endPos = instance.EndPos
		local life = instance.Life
		local timestamp = instance.Timestamp

		if (startPos - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		else
			meteor(startPos, endPos, life, timestamp)
		end
	end
end