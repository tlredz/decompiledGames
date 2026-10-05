local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local beziers = Util.Beziers
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

local function windRibbon(cFrame, _, folder)
	local clone = FX:WaitForChild("TwinHooks").Z.Ribbon:Clone()
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
	clone.Parent = folder or _WorldOrigin
	tween:Play()
end

local function motor6D(parent, part, part2, C0, C1)
	local motor6D2 = Instance.new("Motor6D")
	motor6D2.Parent = parent
	motor6D2.Part0 = part
	motor6D2.Part1 = part2
	motor6D2.C0 = C0
	motor6D2.C1 = C1
	return motor6D2
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local function hitEffect(root)
	local position = root.Position
	local clone = FX:WaitForChild("TwinHooks").Z.SwirlSpiral:Clone()
	clone.Size = createVector(1, 0.05, 2)
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = CFrame.new(position) * CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(2.34, 0.05, 35.13),
			CFrame = clone.CFrame * CFrame.Angles(0, 0.3490658503988659, 0)
		}
	)
	clone.Parent = _WorldOrigin
	Util.Sound:Play("QuickSlice", position, nil, 1.3 + math.random(-32, 32) / 100, 0.25)
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1)
	part.Anchored = true
	part.Size = createVector(0.05, 0.05, 0.05)
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	part.Parent = _WorldOrigin
	local clone2 = FX:WaitForChild("TwinHooks").Z.HitEmitter:Clone()
	Util.Debris:AddItem(clone2, 1)
	clone2.Parent = part
	clone2:emit(1)
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		return
	end

	if stage == 2 then
		local char = data.Char
		local startPos = data.StartPos
		local endPos = data.EndPos
		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 10)
		local clone = FX:WaitForChild("TwinHooks").Z.ImpactHooks:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = CFrame.new(endPos)
		clone.Parent = folder
		Util.Sound:Play("TH_PuntThrow", humanoidRootPart.Position, nil, 1.5 + math.random(-42, 42) / 100, 4)
		local rightLowerArm = humanoidRootPart.Parent:FindFirstChild("RightLowerArm")
		local leftLowerArm = humanoidRootPart.Parent:FindFirstChild("LeftLowerArm")
		local clone2 = FX:WaitForChild("TwinHooks").Z.HookBeamL:Clone()
		local startPart = clone2.StartPart
		local endPart = clone2.EndPart
		startPart.Anchored = false
		Util.Debris:AddItem(clone2, 5)
		clone2.Parent = folder
		emitAll(clone2.EndPart)
		startPart.CFrame = leftLowerArm.CFrame
		endPart.CFrame = leftLowerArm.CFrame
		local cframe = CFrame.new()
		local cframe2 = CFrame.new()
		local motor6D2 = Instance.new("Motor6D")
		motor6D2.Parent = leftLowerArm
		motor6D2.Part0 = leftLowerArm
		motor6D2.Part1 = startPart
		motor6D2.C0 = cframe
		motor6D2.C1 = cframe2
		Util.Debris:AddItem(motor6D2, 5)
		local clone3 = FX:WaitForChild("TwinHooks").Z.HookBeamR:Clone()
		Util.Debris:AddItem(clone3, 5)
		local startPart2 = clone3.StartPart
		local endPart2 = clone3.EndPart
		startPart2.Anchored = false
		clone3.Parent = folder
		emitAll(clone3.EndPart)
		startPart2.CFrame = rightLowerArm.CFrame
		endPart2.CFrame = rightLowerArm.CFrame
		local cframe3 = CFrame.new()
		local cframe4 = CFrame.new()
		local motor6D3 = Instance.new("Motor6D")
		motor6D3.Parent = rightLowerArm
		motor6D3.Part0 = rightLowerArm
		motor6D3.Part1 = startPart2
		motor6D3.C0 = cframe3
		motor6D3.C1 = cframe4
		Util.Debris:AddItem(motor6D3, 5)
		task.spawn(function()
			task.spawn(function()
				task.wait(0.05)
				task.spawn(function()
					for _ = 1, 8 do
						if endPart2:FindFirstChild("Right") then
							emitAll(endPart2.Right)
						end

						task.wait(0.015)
					end
				end)
				task.wait(0.067)
				emitAll(endPart2.Start)
				task.wait(0.1)
				emitAll(endPart2.BAMP)
			end)
			task.spawn(function()
				local WAIT_INTERVAL = 0.2
				TweenService:Create(
					startPart2.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = -15,
						CurveSize1 = -15
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart2.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = 20,
						CurveSize1 = 20
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart2.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = -10,
						CurveSize1 = -10
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart2.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = 0,
						CurveSize1 = 0
					}
				):Play()
			end)
			beziers.Interpolate(
				"Cubic",
				0.4,
				100,
				0.4,
				nil,
				endPart.CFrame,
				endPart.CFrame * CFrame.new(-25, 5, 0),
				endPart.CFrame * CFrame.new(-48, 10, 0),
				clone.CFrame,
				endPart,
				"CFrame"
			)
			task.wait(0.4)
			TweenService:Create(endPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = leftLowerArm.CFrame
			}):Play()
			task.wait(0.1)
			clone2:Destroy()
		end)
		task.spawn(function()
			task.spawn(function()
				task.wait(0.05)
				task.spawn(function()
					for _ = 1, 8 do
						if endPart:FindFirstChild("Right") then
							emitAll(endPart.Right)
						end

						task.wait(0.015)
					end
				end)
				task.wait(0.067)
				emitAll(endPart.Start)
				task.wait(0.1)
				emitAll(endPart.BAMP)
			end)
			task.spawn(function()
				local WAIT_INTERVAL = 0.2
				TweenService:Create(
					startPart.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = -15,
						CurveSize1 = -15
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = 20,
						CurveSize1 = 20
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = -10,
						CurveSize1 = -10
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					startPart2.Parent.Beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						CurveSize0 = 0,
						CurveSize1 = 0
					}
				):Play()
			end)
			beziers.Interpolate(
				"Cubic",
				0.4,
				100,
				0.4,
				nil,
				endPart2.CFrame,
				endPart2.CFrame * CFrame.new(25, 5, 0),
				endPart2.CFrame * CFrame.new(48, 10, 0),
				clone.CFrame,
				endPart2,
				"CFrame"
			)
			task.wait(0.4)
			TweenService:Create(endPart2, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = rightLowerArm.CFrame
			}):Play()
			task.wait(0.1)
			clone3:Destroy()
		end)
		task.wait(0.2)

		if (startPos - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local magnitude = (startPos - endPos).magnitude
		local part, position, _ = Util.Ray(
			startPos,
			CFrame.new(startPos, endPos).LookVector.Unit * (magnitude + 8),
			{ workspace.Characters, workspace.Enemies }
		)

		if part then
			local clone4 = FX:WaitForChild("TwinHooks").Z.GroundWindFX:Clone()
			clone4.Position = position
			clone4.Parent = folder
			clone4.Color = data.Color or clone4.Color

			if part:IsA("BasePart") then
				clone4.Rock.Color = ColorSequence.new(part.Color)
				clone4.Wind.Color = ColorSequence.new(part.Color)
			end

			task.spawn(function()
				wait(0.4)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end)
			TweenService:Create(clone4, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Orientation = clone4.Orientation + createVector(0, -840, 0)
			}):Play()
			spawn(function()
				wait(0.8)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				wait(2)
				clone4:Destroy()
			end)
		end

		task.spawn(function()
			task.wait(0.35)
			local clone4 = FX:WaitForChild("TwinHooks").Z.Tornado:Clone()
			Util.Debris:AddItem(clone4, 2)
			clone4.CFrame = CFrame.new(endPos)
			clone4.Parent = folder
			spawn(function()
				wait(0.45)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				wait(2)
				clone4:Destroy()
			end)
		end)
		emitAll(clone)
		Util.Sound:Play("TH_Tornado", clone.Position, nil, 1 + math.random(-9, 5) / 100, 10)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and (humanoidRootPart2.Position - endPos).magnitude <= 70 then
				task.spawn(function()
					task.wait(0.25)
					local clone4 = script.DOF:Clone()
					clone4.Parent = game.Lighting
					TweenService:Create(
						clone4,
						TweenInfo.new(1.433, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
					Util.Debris:AddItem(clone4, 1.5)
					local bloomEffect = Instance.new("BloomEffect")
					bloomEffect.Parent = game.Lighting
					bloomEffect.Intensity = 1
					bloomEffect.Size = 25
					bloomEffect.Threshold = 2.3
					Util.Debris:AddItem(bloomEffect, 1.5)
					TweenService:Create(
						bloomEffect,
						TweenInfo.new(1.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							Size = 0
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							FieldOfView = 63
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							FieldOfView = 75
						}
					):Play()
					task.wait(0.3)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							FieldOfView = 70
						}
					):Play()
				end)
			end
		end

		local function lerp2(p, p2, p3)
			return p + (p2 - p) * p3
		end

		task.spawn(function()
			task.wait(0.35)

			for i = 1, 15 do
				local v2 = i
				task.spawn(function()
					if 20 % v2 ~= 0 then
						local v3 = CFrame.new(startPos, position) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(1.5707963267948966, 0, 0)
						task.spawn(function()
							windRibbon(CFrame.new(v3.p), false, folder)
						end)
					end
				end)
				wait(0.025)
			end
		end)
		task.wait(0.2)
		local back = Util.Tween.ease.inout.back

		for i = 1, 35 do
			local v2 = i
			task.spawn(function()
				if 20 % v2 ~= 0 then
					local v3 = CFrame.new(startPos, position) * CFrame.new(
						0,
						0,
						-math.random(5, (math.max(14, magnitude)))
					) * CFrame.Angles(1.5707963267948966, 0, 0)
				end

				local endPos2 = endPos
				local character2 = game.Players.LocalPlayer.Character

				if character2 ~= nil then
					local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 and (humanoidRootPart2.Position - endPos2).magnitude <= 70 then
						Util.CameraShaker:ShakeOnce(1, 20, 0.1, 0.5)
					end
				end

				local v5 = v2 % 2 == 0
				local clone4

				if v5 then
					clone4 = FX:WaitForChild("TwinHooks").Z.SwirlCrescent:Clone()
				elseif v2 % 3 == 0 then
					clone4 = FX:WaitForChild("TwinHooks").Z.WindV2:Clone()
				else
					clone4 = FX:WaitForChild("TwinHooks").Z.WindFragments:Clone()
				end

				Util.Debris:AddItem(clone4, 2)
				local part2 = clone4.Part
				Util.Debris:AddItem(part2, 2)
				part2.Transparency = 1
				local v6 = false
				local v7 = v2 / 35
				local v8

				if v7 < 0.75 then
					v8 = math.min(1, (v7 / 0.75) ^ 0.8 + 0.2)
				else
					v8 = 1 - (v7 - 0.75) / 0.25
					v6 = true
				end

				local v9 = back(v8, 0.01, 1.59, 1, 11)
				clone4:ScaleTo((math.max(v9, v6 and 2.5 or 0.1)))
				task.spawn(function()
					local beam = part2.beam1.Beam
					local beam2 = part2.beam2.Beam
					local beam3 = part2.beam3.Beam
					local beam4 = part2.beam4.Beam
					local beam5 = part2.beam5.Beam
					local beam6 = part2.beam6.Beam
					TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = 17.6 * v9,
						Width1 = 0
					}):Play()
					TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = 17.6 * v9,
						Width1 = 0
					}):Play()
					TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = math.random(20, 30) * v9,
						Width1 = 6 * v9
					}):Play()
					TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = 17.6 * v9,
						Width1 = 0
					}):Play()
					TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = 17.6 * v9,
						Width1 = 0
					}):Play()
					TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Width0 = math.random(20, 30) * v9,
						Width1 = 6 * v9
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
					emitAll(clone4)
					task.wait(0.2)

					for i2, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.LockedToPart = false
						end
					end
				end)
				Util.Sound:Play("SpinWoosh", startPos, nil, 1.5 + math.random(-42, 42) / 100, 0.75)
				local cframe5 = CFrame.Angles(
					math.rad((math.random(-15, 15))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-15, 15))))
				)
				part2.CFrame = CFrame.new(endPos) * cframe5
				local v11 = ({ -1, 1 })[math.random(1, 2)] * 179
				local tween = TweenService:Create(
					part2,
					TweenInfo.new(v5 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = Vector3.new(5, v5 and 1 or 3, 5),
						Position = startPos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
						Transparency = 1
					}
				)
				local tween2 = TweenService:Create(
					part2,
					TweenInfo.new(v5 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
					{
						Orientation = part2.Orientation + Vector3.new(0, v11, 0)
					}
				)
				tween2.Completed:Connect(function()
					if part2 and part2.Parent then
						tween2 = TweenService:Create(
							part2,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Orientation = part2.Orientation + Vector3.new(0, v11, 0)
							}
						)
						tween2:Play()
					end
				end)
				tween.Completed:Connect(function()
					if not part then
						task.spawn(function(folder2)
							for i2, beam in pairs(folder2:GetDescendants()) do
								if beam:IsA("Beam") then
									beam.Enabled = false
								end
							end

							task.wait(2.5)
							folder2:Destroy()
						end, clone4)
						return
					end

					local tween3 = TweenService:Create(
						part2,
						TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Transparency = 1,
							CFrame = part2.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
								math.rad((math.random(-5, 5))),
								v11,
								(math.rad((math.random(-5, 5))))
							)
						}
					)
					tween3.Completed:Connect(function()
						task.spawn(function()
							for i2, beam in pairs(clone4:GetDescendants()) do
								if beam:IsA("Beam") then
									beam.Enabled = false
								end
							end

							task.wait(2.5)
							clone4:Destroy()
						end)
					end)
					tween3:Play()
				end)
				clone4.Parent = folder
				tween:Play()
				tween2:Play()
				task.delay(2, function()
					pcall(function()
						tween:Destroy()
					end)
					pcall(function()
						tween2:Destroy()
					end)
					pcall(function()
						clone4:Destroy()
					end)
				end)
			end)
			wait(0.025)
		end
	else
		local root = stage == 3 and data.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			else
				hitEffect(root)
			end
		end
	end
end