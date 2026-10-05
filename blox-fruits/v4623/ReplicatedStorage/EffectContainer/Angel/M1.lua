local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
return function(p)
	local hrp = p.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local angelM1 = FX:WaitForChild("Angel").AngelM1
	local parent2 = _WorldOrigin

	local function ChainSwing(_, parent, data)
		local chainType = data.ChainType
		local chainWeldOffset = data.ChainWeldOffset
		local v2 = chainWeldOffset * CFrame.new(chainWeldOffset.X * 0.2, 1.2, 0)
		local startChainRotation = data.StartChainRotation
		local chainC0Rotation1 = data.ChainC0Rotation1
		local chainC0Rotation2 = data.ChainC0Rotation2
		local chainDistanceMultiplier = data.ChainDistanceMultiplier
		local chainCurveMultiplier = data.ChainCurveMultiplier
		local clone = chainType:Clone()
		clone.CFrame = hrp.CFrame
		clone.Weld.Part1.Massless = true
		clone.Weld.Part0 = hrp
		clone.Parent = parent
		destroyAfter(clone, 7)
		local handChain = clone.HandChain
		local weld = handChain.Weld
		local attach_1 = handChain.Attach_1
		local beam = attach_1.Beam
		weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * v2
		weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * startChainRotation
		TweenService:Create(weld, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * chainC0Rotation1
		}):Play()
		TweenService:Create(attach_1, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = Vector3.new(-5, 0, -15 * chainDistanceMultiplier)
		})
		beam.CurveSize0 = -2
		beam.CurveSize1 = 6
		TweenService:Create(beam, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CurveSize0 = -5 * chainCurveMultiplier,
			CurveSize1 = 9 * chainCurveMultiplier
		}):Play()
		task.wait(0.125)
		TweenService:Create(weld, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * chainC0Rotation2
		}):Play()
		TweenService:Create(attach_1, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = Vector3.new(-3, 0, -13 * chainDistanceMultiplier)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CurveSize0 = 2 * chainCurveMultiplier,
			CurveSize1 = -2 * chainCurveMultiplier
		}):Play()
		task.wait(0.1)
		TweenService:Create(weld, TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(0, -0.5235987755982988, 0)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CurveSize0 = 0,
			CurveSize1 = 0
		})
		TweenService:Create(attach_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = createVector(0, 0, 0)
		}):Play()

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	local index = p.index
	local _ = hrp.CFrame
	Util.Sound:Play("AngelM" .. (index or 1), hrp)

	if index == 1 then
		task.spawn(function()
			task.spawn(function()
				local cframe = CFrame.new(1.6, 1.8, -10)
				local cframe2 = CFrame.Angles(0, 0, 0.29670597283903605)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * cframe2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(-0.08726646259971647, -2.2689280275926285, -0.5235987755982988),
				ChainC0Rotation1 = CFrame.Angles(0, 2.2689280275926285, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 1.5707963267948966, 0),
				ChainDistanceMultiplier = 1,
				ChainCurveMultiplier = 1
			})
		end)
		task.spawn(function()
			task.spawn(function()
				local cframe = CFrame.new(0.3, 1.85, -10)
				local cframe2 = CFrame.Angles(0, 0, 0.12217304763960307)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * cframe2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(-1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(0.4363323129985824, -0.8726646259971648, 0.17453292519943295),
				ChainC0Rotation1 = CFrame.Angles(0, 1.2217304763960306, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 0.5235987755982988, 0),
				ChainDistanceMultiplier = 1,
				ChainCurveMultiplier = 1
			})
		end)
	elseif index == 2 then
		task.spawn(function()
			task.spawn(function()
				task.wait(0.1)
				local cframe = CFrame.new(1.25, 1.65, -10)
				local v2 = CFrame.Angles(0, 0, 3.141592653589793) * CFrame.Angles(0, 0, 0.14835298641951802)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * v2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(3.490658503988659, 0.8726646259971648, -0.17453292519943295),
				ChainC0Rotation1 = CFrame.Angles(0, 2.2689280275926285, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 1.5707963267948966, 0),
				ChainDistanceMultiplier = 1.25,
				ChainCurveMultiplier = 1.35
			})
		end)
		task.spawn(function()
			task.spawn(function()
				task.wait(0.1)
				local cframe = CFrame.new(0.3, 1.85, -11)
				local v2 = CFrame.Angles(0, 0, 3.141592653589793) * CFrame.Angles(0, 0, -0.3490658503988659)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * v2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(-1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(3.141592653589793, 0.8726646259971648, 0.5235987755982988),
				ChainC0Rotation1 = CFrame.Angles(0, 2.6179938779914944, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 0.8726646259971648, 0),
				ChainDistanceMultiplier = 1.45,
				ChainCurveMultiplier = 1.7
			})
		end)
	elseif index == 3 then
		task.spawn(function()
			task.spawn(function()
				task.wait(0.1)
				local cframe = CFrame.new(-0.75, 1, -10)
				local v2 = CFrame.Angles(-0.20943951023931956, 0, -1.5707963267948966) * CFrame.Angles(
					0,
					0,
					-0.6108652381980153
				)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * v2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(-2.2689280275926285, 0.3490658503988659, -0.8726646259971648),
				ChainC0Rotation1 = CFrame.Angles(0, 2.6179938779914944, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 0.6981317007977318, 0),
				ChainDistanceMultiplier = 1.25,
				ChainCurveMultiplier = 1
			})
		end)
		task.spawn(function()
			task.spawn(function()
				task.wait(0.1)
				local cframe = CFrame.new(0.75, 1, -10)
				local v2 = CFrame.Angles(-0.20943951023931956, 0, -1.5707963267948966) * CFrame.Angles(
					0,
					0,
					0.6108652381980153
				)
				local clone = angelM1.SlashHit:Clone()
				clone.Parent = parent2
				destroyAfter(clone, 7)
				clone.CFrame = hrp.CFrame * cframe * v2

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(-1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(-2.2689280275926285, -0.3490658503988659, -2.2689280275926285),
				ChainC0Rotation1 = CFrame.Angles(0, 2.6179938779914944, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 0.6981317007977318, 0),
				ChainDistanceMultiplier = 1.25,
				ChainCurveMultiplier = 1
			})
		end)
	elseif index == 4 then
		task.spawn(function()
			task.spawn(function()
				task.wait(0.1)
				local raycastResult = Workspace:Raycast(
					hrp.CFrame * CFrame.new(0, 0, -15).Position + createVector(0, 1, 0),
					createVector(-0, -10, -0),
					raycastParams
				)

				if raycastResult then
					local position = raycastResult.Position
					local clone = angelM1.GroundImpactSpark:Clone()
					clone.CFrame = CFrame.new(position, position + hrp.CFrame.LookVector)
					clone.Parent = parent2
					destroyAfter(clone, 7)

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end
			end)
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(3.6651914291880923, -0.08726646259971647, 1.5707963267948966),
				ChainC0Rotation1 = CFrame.Angles(0, 2.9670597283903604, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 1.0471975511965976, 0),
				ChainDistanceMultiplier = 2.25,
				ChainCurveMultiplier = 2
			})
		end)
		task.spawn(function()
			ChainSwing(hrp, parent2, {
				ChainType = angelM1.Chains,
				ChainWeldOffset = CFrame.new(-1.5, -0.5, 0),
				StartChainRotation = CFrame.Angles(3.6651914291880923, 0.08726646259971647, 1.5707963267948966),
				ChainC0Rotation1 = CFrame.Angles(0, 2.9670597283903604, 0),
				ChainC0Rotation2 = CFrame.Angles(0, 1.0471975511965976, 0),
				ChainDistanceMultiplier = 2.25,
				ChainCurveMultiplier = 2
			})
		end)
	end
end