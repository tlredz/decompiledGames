local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris

-- equivalent calls inferred from this helper; original call sites unknown
local function getDir(devil)
	if devil then
		return script.Diable
	end

	return script
end

local function sizetusrr(instance, p)
	local size = instance.Size * math.random(90, 130) / 100
	local v2 = math.random(100, 1000) / 5000
	instance.Size = Vector3.new(v2, v2, instance.Size.Z)
	local tween = TweenService:Create(instance, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = instance.CFrame * CFrame.new(0, 0, -p / 2),
		Size = size,
		Transparency = 1
	})
	tween:Play()
	tween:Destroy()

	if instance.Name == "Center" then
		for _, decal in ipairs(instance:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			local tween2 = TweenService:Create(
				decal,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			)
			tween2:Play()
			tween2:Destroy()
			task.delay(0.1, function()
				for _, emitter in pairs(instance:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end
	end
end

return function(player)
	local subEffect = player.SubEffect or 1

	if subEffect == 1 then
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local character = player.Character
		local devil = player.Devil
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local dir = getDir(devil) -- equivalent call inferred; original call site unknown
			local holdValue = player.HoldValue
			local humanoid = player.Humanoid
			local minHold = player.MinHold
			character.LeftLowerLeg.Transparency = 1
			character.LeftUpperLeg.Transparency = 1
			character.LeftFoot.Transparency = 1
			local clone = nil

			if devil then
				local upperTorso = character:FindFirstChild("UpperTorso")

				if upperTorso then
					clone = dir.particle:Clone()
					debris:AddItem(clone, 10)
					clone.CFrame = upperTorso.CFrame
					clone.Parent = _WorldOrigin
					local weldConstraint = Instance.new("WeldConstraint")
					debris:AddItem(weldConstraint, 10)
					weldConstraint.Name = "particleholdweld"
					weldConstraint.Part0 = upperTorso
					weldConstraint.Part1 = clone
					weldConstraint.Parent = upperTorso
				end
			end

			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local lastTime = tick()

			local function running()
				return tick() - lastTime < minHold or diedConnection and holdValue and holdValue.Value == true
			end

			local lastTime2 = tick()
			local lastTime3 = tick()

			while (tick() - lastTime < minHold or diedConnection and holdValue and holdValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid do
				if tick() - lastTime2 > 0.05 then
					if humanoidRootPart then
						Util.Sound:Play("MeleeSwingLoud", humanoidRootPart.Position)
						tick()
					end

					lastTime2 = tick()
				end

				if tick() - lastTime3 > 0.025 then
					local clone2 = dir.Model:Clone()
					clone2:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.Angles(
						math.rad((math.random(-10, 10))),
						math.rad((math.random(-10, 10))),
						math.random(-360, 360)
					) * CFrame.new(math.random(-1000, 1000) / 1000, math.random(-1000, 1000) / 1000, -5))
					clone2.Parent = _WorldOrigin
					sizetusrr(clone2.PrimaryPart, 25)

					if devil then
						sizetusrr(clone2.Flame, 10)
					end

					debris:AddItem(clone2, 0.55)
					local clone3 = dir.Ring:Clone()
					clone3.CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(
						1.5707963267948966,
						math.random(-360, 360),
						0
					)
					clone3.Parent = _WorldOrigin
					local v = math.random(400, 600) / 100
					local tween = TweenService:Create(
						clone3,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(v, clone3.Size.Y, v),
							Transparency = 1
						}
					)
					tween:Play()
					tween:Destroy()
					debris:AddItem(clone3, 0.25)
					lastTime3 = tick()
				end

				RunService.RenderStepped:Wait()
			end

			if diedConnection then
				diedConnection:Disconnect()
			end

			if devil and clone then
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(1, function()
					if clone then
						clone:Destroy()
					end
				end)
			end

			character.LeftLowerLeg.Transparency = 0
			character.LeftUpperLeg.Transparency = 0
			character.LeftFoot.Transparency = 0
		end
	elseif subEffect == 2 then
		local cFrame = player.CFrame
		local devil = player.Devil

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 500 then
			return
		end

		local clone = devil and script.Diable.KickImpact:Clone() or script.KickImpact:Clone()
		debris:AddItem(clone, 1)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Util.Sound:Play("Hit1", cFrame.Position, nil, 1 + math.random(-15, 15) / 100, 0.5)

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "Sparks" then
				child:Emit(math.random(6, 8))
			else
				child:Emit(1)
			end
		end
	end
end