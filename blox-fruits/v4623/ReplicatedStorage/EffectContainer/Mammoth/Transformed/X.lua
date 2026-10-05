local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)
local mammoth = FX:WaitForChild("Mammoth")

local function punt1(plr, hrp, hold, mammoth2)
	local v = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
	local _ = mammoth2.PrimaryPart
	local body4002 = mammoth2["body4.002"]
	local animationController = mammoth2.AnimationController
	local children = mammoth2:GetChildren()

	local function lightup()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Color = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()
			local v3 = part
			task.spawn(function()
				task.wait(0.05)

				if tween.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(255, 57, 57)
					}
				)
				tween2:Play()
				task.wait(0.1)

				if tween2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Color = Color3.fromRGB(112, 22, 22)
				}):Play()
			end)
		end
	end

	local function lightoff()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Color = Color3.fromRGB(13, 105, 172)
			}):Play()
		end
	end

	lightup()

	while hold and hold.Value and hold.Parent and hold.Parent:IsDescendantOf(workspace) do
		wait()
	end

	Util.Sound:Play("MammothCrush", hrp, 25, 1 + math.random(-5, 5) / 100, 2.2)
	body4002.aura1.Enabled = true
	body4002.aura2.Enabled = true
	mammoth2.exp.Size = createVector(26.202, 4.679, 31.044)
	mammoth2.exp.FR2.Enabled = true
	mammoth2.exp.FR3.Enabled = true
	local descendants = body4002.XDashStart:GetDescendants()
	local v2 = {}

	for k, descendant in pairs(descendants) do
		v2[k] = {
			count = descendant:GetAttribute("EmitCount") or 0,
			delay = descendant:GetAttribute("EmitDelay") or 0
		}
	end

	for k, descendant in pairs(descendants) do
		if not v2[k] then
			continue
		end

		if v2[k].delay > 0 then
			local v3 = k
			local v4 = descendant
			task.spawn(function()
				task.wait(v2[v3].delay)
				v4:Emit(v2[v3].count)
			end)
		else
			descendant:Emit(v2[k].count)
		end
	end

	task.spawn(function()
		task.wait(0.058)

		for _, child in pairs(mammoth2.exp.beams3:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 13.799,
				Width0 = 3.067
			}):Play()
		end

		for _, child in pairs(mammoth2.exp.beams2:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 22.999,
				Width0 = 3.067
			}):Play()
		end

		for _, child in pairs(mammoth2.exp.beams1:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 18.399
			}):Play()
		end

		mammoth2.exp.Sparks2.Enabled = true
		mammoth2.exp.Sparks3.Enabled = true
		local clone = mammoth.Shockwave:Clone()
		local clone2 = mammoth.Shockwave2:Clone()
		clone.CFrame = hrp.CFrame * CFrame.new(-13, 0, 15)
		clone.Parent = _WorldOrigin
		clone2.CFrame = hrp.CFrame * CFrame.new(13, 0, 15)
		clone2.Parent = _WorldOrigin
		Util.Debris:AddItem(clone, 1)
		Util.Debris:AddItem(clone2, 1)
		TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(18.6, 53.25, 205.5)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(-18, 0, -175)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(18.6, 53.25, 205.5)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(18, 0, -175)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	Util.Sound:Play("MammothMiniRoar", hrp, nil, 1 + math.random(-5, 5) / 100, 1.95)

	if plr == game.Players.LocalPlayer then
		animationController:LoadAnimation(script.MammothPunt):Play()
	end

	body4002.WINDTRAIL4.Trail2.Enabled = true
	body4002.WINDTRAIL1.Trail2.Enabled = true
	body4002.t2.Trail2.Enabled = true
	task.spawn(function()
		task.wait(0.07)

		for _ = 1, 3 do
			task.wait(0.038)

			for _, child in pairs(body4002.XDashEmit:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end)
	task.spawn(function()
		task.wait(0.2)
		local position = hrp.Position
		local rayMap, v3, _ = Util.RayMap(position, createVector(0, -1, 0) * (v + 15))

		if rayMap then
			local function groundEffects(_, rayMap2)
				if rayMap2 then
					body4002.emitground.Rocks.Color = ColorSequence.new(rayMap2.Color)
					body4002.emitground.SlashSmoke.Color = ColorSequence.new(rayMap2.Color)
					body4002.emitground.SlashSmoke:Emit(16)
					body4002.emitground.Rocks:Emit(8)
				end
			end

			groundEffects(v3, rayMap)
		end
	end)
	task.wait(0.23)
	local clone = mammoth.tusksBIG:Clone()
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 1.5707963267948966, -0.7853981633974483)
	clone.Parent = _WorldOrigin
	Util.Debris:AddItem(clone, 5)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = clone
	weldConstraint.Part0 = hrp
	weldConstraint.Part1 = clone
	TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = hrp.CFrame * CFrame.new(0, 8, -19) * CFrame.Angles(1.3962634015954636, 1.5707963267948966, 0),
		Size = createVector(47.892, 47.892, 24.503)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	Util.Sound:Play("MammothImpactSlice", clone.Position, 25, 1 + math.random(-5, 5) / 100, 1.8)
	Util.Sound:Play("MammothRunEnd", clone.Position, 25, 1 + math.random(-5, 5) / 100, 1.8)

	for _, child in pairs(mammoth2.exp.beams3:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams2:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams1:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	if plr == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(17, 17, 0.1, 1, createVector(2, 2, 2), createVector(2.8, 2.9, 3.7))
		task.spawn(function()
			wait(0.26)
			local clone2 = script.LTN:Clone()
			clone2.Parent = game.Lighting
			Util.Debris:AddItem(clone2, 2)
			TweenService:Create(clone2, TweenInfo.new(0.013), {
				TintColor = Color3.fromRGB(255, 0, 0),
				Brightness = 0.3,
				Contrast = 1,
				Saturation = -1
			}):Play()
			task.wait(0.007)
			TweenService:Create(clone2, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(0, 0, 0),
				Brightness = 1,
				Contrast = -100,
				Saturation = -1
			}):Play()
			task.wait(0.01)
			TweenService:Create(clone2, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Util.Debris:AddItem(clone2, 1)
		end)
	end

	mammoth2.exp.FR2.Enabled = false
	mammoth2.exp.FR3.Enabled = false
	task.wait(0.15)
	mammoth2.Sphere.EyeL.eye2:Emit(2)
	mammoth2.Sphere.EyeR.eye2:Emit(2)
	mammoth2.exp.Sparks2.Enabled = false
	mammoth2.exp.Sparks3.Enabled = false
	body4002.frontemit.Hit2:Emit(2)

	for _, child in pairs(clone.emit:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	clone.Attachment1.Effect:Emit(3)
	clone.Attachment2.Effect:Emit(3)
	body4002.t2.Trail2.Enabled = false
	body4002.WINDTRAIL4.Trail2.Enabled = false
	body4002.WINDTRAIL1.Trail2.Enabled = false
	body4002.aura1.Enabled = false
	body4002.aura2.Enabled = false
	local clone2 = mammoth.SlamTrunkPart:Clone()
	task.spawn(function()
		local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
		local v3 = hrp.Position + lookVector * 13.5
		local rayMap, v4, v5 = Util.RayMap(v3, createVector(0, -1, 0) * v)

		if rayMap then
			local _ = v5 * 0.1
			local _ = hrp.CFrame
			clone2.CFrame = Util.Misc.AlignCFrame(CFrame.new(v4, v4 + lookVector), v5)
			clone2.Parent = _WorldOrigin
			Util.Debris:AddItem(clone2, 1.5)
			mammoth2["body4.002"].SmokeFront.Smoke2:Emit(30)
			mammoth2["body4.002"].SmokeFront.shock:Emit(12)
			clone2.Decal.Transparency = 1
			local clone3 = mammoth.ground1:Clone()
			local clone4 = mammoth.ground2:Clone()
			clone3.Size = createVector(4, 3, 20)
			clone4.Size = createVector(4, 3, 20)
			clone3.CFrame = clone2.CFrame * CFrame.new(-6.3, 0.2, -20) * CFrame.Angles(0, 0, -3.141592653589793)
			clone4.CFrame = clone2.CFrame * CFrame.new(6.3, 0.2, -20) * CFrame.Angles(0, 0, -3.141592653589793)
			clone3.BrickColor = rayMap.BrickColor
			clone3.Material = rayMap.Material
			clone4.BrickColor = rayMap.BrickColor
			clone4.Material = rayMap.Material
			clone3.Anchored = true
			clone4.Anchored = true
			clone3.Parent = _WorldOrigin
			clone4.Parent = _WorldOrigin
			Util.Debris:AddItem(clone3, 4)
			Util.Debris:AddItem(clone4, 4)
			TweenService:Create(clone3, TweenInfo.new(3.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				CFrame = clone3.CFrame * CFrame.new(0, 4, 0),
				Size = createVector(1.988, 1.612, 13.606)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(3.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				CFrame = clone4.CFrame * CFrame.new(0, 4, 0),
				Size = createVector(1.988, 1.612, 13.606)
			}):Play()
			task.spawn(function()
				task.wait(0.08)
				local _, _ = Util.RayMap(hrp.Position, createVector(0, -1, 0) * v)

				for _ = 1, 8 do
					local clone5 = mammoth.Rock:Clone()
					clone5.Size = Vector3.new(math.random(2.25, 3), math.random(2.25, 4.5), math.random(2.25, 3))
					clone5.Position = clone2.Position + hrp.CFrame.LookVector * 5 + createVector(0, 22, 0)
					clone5.CFrame = CFrame.new(clone5.Position)
					clone5.Anchored = false
					clone5.CanCollide = false
					clone5.Parent = workspace
					clone5.BrickColor = rayMap.BrickColor
					clone5.Material = rayMap.Material
					local vector2 = Vector3.new(math.random(-20, 20), math.random(90, 110), math.random(-20, 20))
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
					bodyVelocity.Velocity = hrp.CFrame.LookVector * 35 + vector2
					bodyVelocity.Parent = clone5
					local vector3 = Vector3.new(
						math.rad((math.random(360))),
						math.rad((math.random(360))),
						(math.rad((math.random(360))))
					)
					local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
					bodyAngularVelocity.AngularVelocity = vector3
					bodyAngularVelocity.Parent = clone5
					task.spawn(function()
						wait(0.02)
						bodyVelocity:Destroy()
					end)
					Util.Debris:AddItem(clone5, 5)
				end
			end)

			local function groundEffects(_, rayMap2)
				if rayMap2 then
					mammoth2["body4.002"].SmokeFront.Smoke2.Color = ColorSequence.new(rayMap2.Color)
					clone2.Rocks.Color = ColorSequence.new(rayMap2.Color)
					clone2.Attachment.ParticleEmitter2.Color = ColorSequence.new(rayMap2.Color)
					clone2.Attachment.ParticleEmitter.Color = ColorSequence.new(rayMap2.Color)
				end
			end

			groundEffects(v4, rayMap)
		end
	end)
	task.wait(0.4)
	lightoff()
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold

	if not hrp or (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local mammoth2 = hrp.Parent:FindFirstChild("Mammoth").Mammoth

	if not mammoth2 then
		return
	end

	punt1(plr, hrp, hold, mammoth2)
end