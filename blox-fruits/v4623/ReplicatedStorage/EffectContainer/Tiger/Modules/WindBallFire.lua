local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("SoulGuitarEffects").Wind
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local attachmentPair = Util.AttachmentPair
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, p, p2)
	return vector2 + vector3 * p2 + createVector(-0, -0.5, -0) * p * p2 ^ 2
end

function gaussian()
	return math.sqrt(math.log(math.random()) * -2) * math.cos(6.283185307179586 * math.random())
end

local function windRibbon(cFrame, _)
	local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
	local clone = FX2:WaitForChild("TigerEffects").WINDRIBBONS.XWindRibbon:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Part.Color = Color3.fromRGB(0, 0, 0)
	clone.Part.CFrame = cFrame
	clone.Part.Transparency = 1
	local tween = TweenService:Create(
		clone.Part,
		TweenInfo.new(math.random(3, 5) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = clone.Part.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				3.1066860685499065,
				(math.rad((math.random(-25, 25))))
			),
			Size = clone.Part.Size * math.random(6, 8),
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 1
		}
	)
	Util.ResizeModel(clone, math.random(1.7, 4), clone.Part.Position)
	task.spawn(function()
		local beam = clone.Part.beam1.Beam
		local beam2 = clone.Part.beam2.Beam
		local beam3 = clone.Part.beam3.Beam
		local beam4 = clone.Part.beam4.Beam
		local beam5 = clone.Part.beam5.Beam
		local beam6 = clone.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandPointInSphere(p: number)
	local v = math.random()
	local vector2 = Vector3.new(gaussian(), gaussian(), gaussian())
	return p * vector2 * v ^ 0.3333333333333333 / vector2.magnitude
end

local function WindBall(parent, data, p, vector2: Vector3, vector3: Vector3, p2)
	local v = p * 0.67
	task.delay(v + 1, function()
		parent:Destroy()
	end)
	local v2 = time()
	local clone = parent:Clone()
	clone.Parent = parent
	clone:ClearAllChildren()
	local clone_2 = data.LongTrail:Clone()
	clone_2.Parent = clone
	heartbeatLoopFor2(v, function(p3)
		local v4 = vector2 + vector3 * p3 + createVector(-0, -0.5, -0) * p2 * p3 ^ 2
		local v8 = p3 + 0.01
		local v9 = vector2 + vector3 * v8 + createVector(-0, -0.5, -0) * p2 * v8 ^ 2
		parent.CFrame = CFrame.lookAt(v4, v9) * CFrame.Angles(0, 0, -14 * p3)
		clone.CFrame = CFrame.lookAt(v4, v9)
	end, function()
		clone.LongTrail.Enabled = false
	end)
	local v3 = parent.Size.Y * 0.5
	local integer = random:NextInteger(5, 10)
	local integer2 = random:NextInteger(3, 7)
	local children = data.Trails:GetChildren()
	local children2 = data.Particles:GetChildren()
	local centerAttachment = parent.CenterAttachment

	for _ = 1, integer do
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		local randPointInSphere = getRandPointInSphere(v3) -- equivalent call inferred; original call site unknown
		attachment.CFrame = CFrame.lookAt(createVector(0, 0, 0), random:NextUnitVector()) + randPointInSphere
		attachment2.CFrame = attachment.CFrame * CFrame.new(random:NextNumber(7, 14), 0, 0)
		local clone2 = children[random:NextInteger(1, #children)]:Clone()
		clone2.Attachment0 = attachment
		clone2.Attachment1 = attachment2
		clone2.Parent = attachment
		attachment.Parent = parent
		attachment2.Parent = parent
	end

	for _ = 1, integer2 do
		local clone2 = children2[random:NextInteger(1, #children2)]:Clone()
		local emitCount = clone2:GetAttribute("EmitCount")
		clone2.Parent = centerAttachment
		task.spawn(function()
			task.wait(v * random:NextNumber(0, 1))

			if v < time() - v2 then
				return
			end

			clone2:Emit(emitCount)
		end)
	end

	local function lerp(p3, p4, p5)
		return p3 + (p4 - p3) * p5
	end

	local position = parent.Position
	local position2 = parent.Position
	local magnitude = (position - position2).magnitude
	local ray, v4, _ = Util.Ray(
		position,
		CFrame.new(position, position2).LookVector.Unit * (magnitude + 8),
		{ workspace.Characters, workspace.Enemies }
	)
	task.spawn(function()
		task.wait(0.35)

		for i = 1, 15 do
			local v5 = i
			task.spawn(function()
				if 20 % v5 ~= 0 then
					local v6 = CFrame.new(position, v4) * CFrame.new(0, 0, -math.random(5, (math.max(14, magnitude)))) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					task.spawn(function()
						windRibbon(CFrame.new(v6.p))
					end)
				end
			end)
			wait(0.025)
		end
	end)
	task.wait(0.2)
	local back = Util.Tween.ease.inout.back

	for i = 1, 35 do
		local v5 = i
		task.spawn(function()
			if 20 % v5 ~= 0 then
				local v6 = CFrame.new(position, v4) * CFrame.new(0, 0, -math.random(5, (math.max(14, magnitude)))) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			end

			print("BAMMMPIIIIISTTTTTT")
			local v7 = v5 % 2 == 0
			local clone2

			if v7 then
				local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
				clone2 = FX2.TwinHooks.Z.SwirlCrescent:Clone()
			elseif v5 % 3 == 0 then
				local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
				clone2 = FX2.TwinHooks.Z.WindV2:Clone()
			else
				local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
				clone2 = FX2.TwinHooks.Z.WindFragments:Clone()
			end

			Util.Debris:AddItem(clone2, 2)
			local part = clone2.Part
			part.Transparency = 1
			local v8 = false
			local v9 = v5 / 35
			local v10

			if v9 < 0.75 then
				v10 = math.min(1, (v9 / 0.75) ^ 0.8 + 0.2)
			else
				v10 = 1 - (v9 - 0.75) / 0.25
				v8 = true
			end

			local v11 = back(v10, 0.01, 1.59, 1, 11)
			clone2:ScaleTo((math.max(v11, v8 and 2.5 or 0.1)))
			task.spawn(function()
				local beam = part.beam1.Beam
				local beam2 = part.beam2.Beam
				local beam3 = part.beam3.Beam
				local beam4 = part.beam4.Beam
				local beam5 = part.beam5.Beam
				local beam6 = part.beam6.Beam
				TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 17.6 * v11,
					Width1 = 0
				}):Play()
				TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 17.6 * v11,
					Width1 = 0
				}):Play()
				TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = math.random(20, 30) * v11,
					Width1 = 6 * v11
				}):Play()
				TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 17.6 * v11,
					Width1 = 0
				}):Play()
				TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 17.6 * v11,
					Width1 = 0
				}):Play()
				TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = math.random(20, 30) * v11,
					Width1 = 6 * v11
				}):Play()
				task.wait(0.05)
				TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam4, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam6, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
			task.spawn(function()
				task.wait(0.2)

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.LockedToPart = false
					end
				end
			end)
			Util.Sound:Play("SpinWoosh", position, nil, 1.5 + math.random(-42, 42) / 100, 0.75)
			local cframe = CFrame.Angles(
				math.rad((math.random(-15, 15))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-15, 15))))
			)
			part.CFrame = CFrame.new(position2) * cframe
			local v13 = ({ -1, 1 })[math.random(1, 2)] * 179
			local tween = TweenService:Create(
				part,
				TweenInfo.new(v7 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(5, v7 and 1 or 3, 5),
					Position = position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
					Transparency = 1
				}
			)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(v7 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
				{
					Orientation = part.Orientation + Vector3.new(0, v13, 0)
				}
			)
			tween2.Completed:Connect(function()
				if part then
					tween2 = TweenService:Create(
						part,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Orientation = part.Orientation + Vector3.new(0, v13, 0)
						}
					)
					tween2:Play()
				end
			end)
			tween.Completed:Connect(function()
				if not ray then
					task.spawn(function()
						for i2, beam in pairs(clone2:GetDescendants()) do
							if beam:IsA("Beam") then
								beam.Enabled = false
							end
						end

						task.wait(2.5)
						clone2:Destroy()
					end)
					return
				end

				local tween3 = TweenService:Create(
					part,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1,
						CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
							math.rad((math.random(-5, 5))),
							v13,
							(math.rad((math.random(-5, 5))))
						)
					}
				)
				tween3.Completed:Connect(function()
					task.spawn(function()
						for i2, beam in pairs(clone2:GetDescendants()) do
							if beam:IsA("Beam") then
								beam.Enabled = false
							end
						end

						task.wait(2.5)
						clone2:Destroy()
					end)
				end)
				tween3:Play()
			end)
			clone2.Parent = _WorldOrigin
			tween:Play()
			tween2:Play()
		end)
		wait(0.025)
	end

	task.spawn(function()
		for _ = 1, 25 do
			if v < time() - v2 then
				break
			end

			if math.random() < 0.5 then
				continue
			end

			task.wait(v / 25)
			local v6 = attachmentPair.new(CFrame.new(1, 0, 0), CFrame.new(-1, 0, 0))
			local clone2 = data.MainTrail:Clone()
			v6:hookUp(clone2)
			local lookVector = RandomVectorOffsetBetween(createVector(0, 0, 1), 0.5235987755982988, 1.0471975511965976)
			local v8 = v3 * lookVector * random:NextNumber(0.75, 1)
			local vector4 = lookVector * random:NextNumber(120, 140) * 1.25
			local v9 = vector4:Dot(createVector(0, 0, 1)) * createVector(0, 0, 1)
			local v10 = v8 + vector4
			local v11 = v8 + v9 * 0.7
			local v12 = v10 + (v11 - v10) * 0.7
			local cFrame = parent.CFrame
			local v19 = v6
			local v20 = v8
			local v21 = v11
			local v22 = v12
			local v23 = v10
			heartbeatLoopFor2(0.134, function(p3, p4, p5)
				cFrame *= CFrame.Angles(0, 0, -0.05)
				local cframe = CFrame.new()
				local cframe2 = cFrame
				v6:setRelativeCFrame(cframe + cframe2:PointToWorldSpace(CubicBezier(p5 * 0.5, v8, v11, v12, v10)))
			end, function()
				heartbeatLoopFor2(0.268, function(p3, p4, p5)
					cFrame *= CFrame.Angles(0, 0, -0.05)
					clone2.MaxLength = 100 * (1 - p5)
					clone2.Lifetime = 0.35 * (1 - p5)
					local cframe = CFrame.new()
					local cframe2 = cFrame
					v19:setRelativeCFrame(cframe + cframe2:PointToWorldSpace(CubicBezier(
						0.5 + p5 * 0.5,
						v20,
						v21,
						v22,
						v23
					)))
				end, function()
					v19:destroy()
				end)
			end)
		end
	end)
end

return WindBall