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

local function transform(plr, hrp)
	local clone = mammoth.Spark:Clone()
	clone.Parent = hrp
	clone:Emit(5)
	Util.Debris:AddItem(clone, 1)
	local v = Util.WaitWhileParentExists(Util.WaitWhileParentExists(plr.Character, "Mammoth"), "Mammoth")

	if not v then
		return
	end

	local v2 = #mammoth.Mammoth:GetChildren()
	local lastTime = tick()

	while tick() - lastTime < 1 and not (v:GetAttribute("Loaded") and v2 <= #v:GetChildren()) do
		task.wait()
	end

	local children = v:GetChildren()

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
			local v4 = part
			task.spawn(function()
				task.wait(0.05)

				if tween.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v4,
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

				TweenService:Create(v4, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
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
	local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
	local v3 = hrp.Position + lookVector * 0
	local rayMap, v4, v5 = Util.RayMap(v3, createVector(0, -25, 0))
	local clone2 = mammoth.Core:Clone()
	local clone3 = mammoth.Ground:Clone()
	local clone4 = mammoth.TransIn:Clone()
	Util.Debris:AddItem(clone2, 4)
	Util.Debris:AddItem(clone3, 4)
	Util.Debris:AddItem(clone4, 4)
	clone2.CFrame = hrp.CFrame
	clone2.Parent = _WorldOrigin
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = clone2
	weldConstraint.Part0 = hrp
	weldConstraint.Part1 = clone2
	Util.Debris:AddItem(weldConstraint, 2)
	clone4.CFrame = CFrame.new(v4 + v5 * 0.1)

	if rayMap then
		clone2.smoke.SMOKE.Color = ColorSequence.new(rayMap.Color)
		clone4.inwards.SMOKE.Color = ColorSequence.new(rayMap.Color)
	else
		clone2.smoke.SMOKE:Destroy()
		clone4.inwards.SMOKE:Destroy()
	end

	clone4.Parent = _WorldOrigin
	local children2 = clone4.inwards:GetChildren()
	local v6 = {}

	for k, v7 in pairs(children2) do
		v6[k] = {
			count = v7:GetAttribute("EmitCount") or 0,
			delay = v7:GetAttribute("EmitDelay") or 0
		}
	end

	for k, v7 in pairs(children2) do
		if not v6[k] then
			continue
		end

		if v6[k].delay > 0 then
			local v8 = k
			local v9 = v7
			task.spawn(function()
				task.wait(v6[v8].delay)
				v9:Emit(v6[v8].count)
			end)
		else
			v7:Emit(v6[k].count)
		end
	end

	task.spawn(function()
		for _ = 1, 4 do
			task.wait(0.03)
			local clone5 = mammoth.WindBurst:Clone()
			clone5.CFrame = hrp.CFrame
			clone5.Parent = _WorldOrigin
			Util.Debris:AddItem(clone5, 0.5)
			TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(160, 160, 160),
				CFrame = clone5.CFrame * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				),
				Transparency = 1
			}):Play()
		end
	end)
	Util.Sound:Play("port2", clone2.Position, nil, 1 + math.random(-5, 5) / 100, 3)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	if plr == game.Players.LocalPlayer then
		task.spawn(function()
			local WAIT_INTERVAL = 0.08
			task.wait(0.23)
			local clone5 = script.LTN:Clone()
			clone5.Parent = game.Lighting
			Util.Debris:AddItem(clone5, 2)
			TweenService:Create(clone5, TweenInfo.new(0.08), {
				TintColor = Color3.fromRGB(0, 0, 0),
				Brightness = 0.3,
				Contrast = 0.7,
				Saturation = -1
			}):Play()
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone5, TweenInfo.new(0.08), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Util.Debris:AddItem(clone5, 1)
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone5, TweenInfo.new(0.08), {
				TintColor = Color3.fromRGB(153, 19, 19),
				Brightness = 0.3,
				Contrast = 0.5,
				Saturation = -1
			}):Play()
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone5, TweenInfo.new(0.08), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Util.Debris:AddItem(clone5, 1)
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone5, TweenInfo.new(0.08), {
				TintColor = Color3.fromRGB(255, 0, 0),
				Brightness = 0.3,
				Contrast = 1.4,
				Saturation = -1
			}):Play()
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone5, TweenInfo.new(0.13), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Util.Debris:AddItem(clone5, 1)
		end)
	end

	Util.Sound:Play("MammothRoar", clone2, 30, 1 + math.random(-5, 5) / 100, 5)
	task.spawn(function()
		task.wait(0.45)
		local children3 = clone2.smoke:GetChildren()
		local children4 = clone2.blast:GetChildren()

		for _ = 1, 8 do
			Util.Sound:Play("Shock", clone2.Position, nil, 1 + math.random(-5, 5) / 100, 2)

			if plr == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(3, 15, 0.1, 0.3)
			end

			local clone5 = mammoth.Ringp:Clone()
			clone5.CFrame = hrp.CFrame * CFrame.new(0, -4, 0)
			clone5.Parent = _WorldOrigin
			Util.Debris:AddItem(clone5, 0.5)
			TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = hrp.CFrame * CFrame.new(0, -16, 0),
				Size = createVector(184, 3, 184),
				Transparency = 1
			}):Play()
			local clone6 = mammoth.SPIKESHOCK:Clone()
			clone6.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 0)
			clone6.Parent = _WorldOrigin
			Util.Debris:AddItem(clone6, 0.5)
			TweenService:Create(clone6, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(0, -11, 0),
				Size = createVector(224, 8, 224),
				Transparency = 1
			}):Play()
			local clone7 = mammoth.Wind:Clone()
			clone7.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
			clone7.Parent = _WorldOrigin
			Util.Debris:AddItem(clone7, 0.5)
			TweenService:Create(clone7, TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = hrp.CFrame * CFrame.new(0, -8, 0),
				Size = createVector(160, 8, 160),
				Transparency = 1
			}):Play()
			local clone8 = mammoth.purple:Clone()
			clone8.CFrame = hrp.CFrame
			clone8.Parent = _WorldOrigin
			Util.Debris:AddItem(clone8, 0.5)
			TweenService:Create(clone8, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(240, 240, 240),
				Transparency = 1
			}):Play()
			local clone9 = mammoth.WindBurst:Clone()
			clone9.CFrame = hrp.CFrame
			clone9.Parent = _WorldOrigin
			Util.Debris:AddItem(clone9, 0.5)
			TweenService:Create(clone9, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(160, 160, 160),
				CFrame = clone9.CFrame * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				),
				Transparency = 1
			}):Play()

			for _, v7 in pairs(children3) do
				v7:Emit(v7:GetAttribute("EmitCount"))
			end

			for _, v7 in pairs(children4) do
				v7:Emit(v7:GetAttribute("EmitCount"))
			end

			task.wait(0.18)
		end
	end)
	task.wait(0.45)

	if plr == game.Players.LocalPlayer then
		task.spawn(function()
			local camera = workspace.Camera

			for i = 1, 13 do
				camera.FieldOfView = i * 8
				task.wait()
			end

			task.wait(1.4)

			for i = 1, 10 do
				camera.FieldOfView = 104 - i * 3.4
				task.wait()
			end
		end)
	end

	task.wait(1.4)
	lightoff()
end

return function(p)
	local plr = p.plr
	local hrp = p.hrp

	if (hrp.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
		return
	end

	transform(plr, hrp)
end