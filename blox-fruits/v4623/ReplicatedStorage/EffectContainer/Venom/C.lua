local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function miniCloud(cframe, p, color, color2, list, p2, p3)
	local v = math.random(-5, 5)
	local clone = FX:WaitForChild("VenomEffects").PoisonCloud:Clone()
	Util.Debris:AddItem(clone, 60)
	local inner = clone.Inner
	local outer = clone.Outer
	inner.Color = color
	outer.Color = color2
	outer.Transparency = 0.5
	inner.Transparency = 0.5
	inner.Size = createVector(0, 0, 0)
	outer.Size = createVector(0, 0, 0)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = p or _WorldOrigin
	table.insert(list, { clone, p3 })
	local v2 = createVector(9.338, 10.772, 9.284) + Vector3.new(v, v, v)
	local v3 = createVector(8.338, 9.772, 8.284) + Vector3.new(v, v, v)

	for _, child in pairs(clone:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(p2 / 6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = child.Name == "Inner" and v3 or v2
			}
		)
		local tween2 = TweenService:Create(
			child,
			TweenInfo.new(p2 / 6 * 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true, 0),
			{
				Size = child.Name == "Inner" and v3 * 1.2 or v2 * 1.2
			}
		)
		local tween3 = TweenService:Create(
			child,
			TweenInfo.new(p2 / 6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(0, 0, 0)
			}
		)
		tween3.Completed:Connect(function()
			clone:Destroy()
		end)
		tween2.Completed:Connect(function()
			tween3:Play()
		end)
		tween.Completed:Connect(function()
			tween2:Play()
		end)
		tween:Play()
	end
end

local function wind(cframe, duration, p)
	local clone = FX:WaitForChild("VenomEffects").VenomWind:Clone()
	Util.Debris:AddItem(clone, duration)
	clone.Position = cframe.p
	clone.Transparency = 0
	clone.CFrame = CFrame.new(cframe.p) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = (clone.Size + createVector(0, 5, 0)) * (p + math.random(-3, -1)),
			CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
				0,
				math.rad(({ -179, 179 })[math.random(1, 2)]),
				0
			),
			Transparency = 1
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	return clone
end

local function cloud(cframe, clone, duration, innerColor, outerColor)
	local clone2 = clone:Clone()
	Util.Debris:AddItem(clone2, duration + 10)
	local inner = clone2.Inner
	local outer = clone2.Outer
	inner.Color = innerColor
	outer.Color = outerColor
	inner.Size = createVector(0, 0, 0)
	outer.Size = createVector(0, 0, 0)
	clone2:SetPrimaryPartCFrame(cframe)
	clone2.Parent = _WorldOrigin

	for _, child in pairs(clone2:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = child.Name == "Inner" and createVector(94.625, 94.625, 94.625) or createVector(
					99.079,
					99.079,
					99.079
				)
			}
		)
		local tween2 = TweenService:Create(
			child,
			TweenInfo.new(duration * 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Orientation = child.Orientation + createVector(0, 150, 0)
			}
		)
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()
		tween2:Play()
	end

	return clone2
end

return function(player)
	local cFrame = player.CFrame
	local lifetime = player.Lifetime
	local timestamp = player.Timestamp
	local character = player.Character

	if (cFrame.Position - workspace.CurrentCamera.CFrame.p).magnitude > 3000 then
		return
	end

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")

		if humanoidRootPart and humanoid then
			local v = lifetime - (Util.MasterClock:GetTime() - timestamp)
			local outerColor = player.OuterColor
			local innerColor = player.InnerColor
			Util.Sound:Play("VenomBreath", cFrame.p, nil, 0.5 + math.random(-10, 10) / 100, 4)
			local clone = FX:WaitForChild("VenomEffects").PoisonBreathModel:Clone()
			Util.Debris:AddItem(clone, v + 10)
			local clone2 = clone.Cloud:Clone()
			clone.Cloud:Destroy()
			local core = clone.Core
			local spirals = core.ParticleAttachment.Spirals
			local flatSmog = core.ParticleAttachment.FlatSmog
			local uprightSmog = core.ParticleAttachment.UprightSmog
			clone.Parent = _WorldOrigin
			local v2 = {}
			table.insert(v2, (cloud(cFrame, clone2, 2, innerColor, outerColor)))
			spirals.Enabled = true
			uprightSmog.Enabled = true
			flatSmog.Enabled = true
			local v3 = Util.MasterClock:GetTime() - timestamp
			local lastTime = tick()
			local lastTime2 = tick()
			local now = tick() - 0.8
			local v4 = v - v3
			local v5 = {}
			local total = 0
			local v6 = 0.016666666666666666

			while tick() - lastTime <= v4 do
				if tick() - lastTime2 > 0.2 then
					local v7 = wind(CFrame.new(humanoidRootPart.Position), 0.5, 5)
					v7.Parent = clone
					table.insert(v5, v7)
					lastTime2 = tick()
				end

				if tick() - now > 0.8 then
					table.insert(
						v2,
						(cloud(
							CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.random(-180, 180), 0),
							clone2,
							2,
							innerColor,
							outerColor
						))
					)
					now = tick()
				end

				if #v5 > 0 then
					for k, part in pairs(v5) do
						if part:IsA("BasePart") then
							part.Position = core.Position
						elseif part[1] ~= nil and part[1].PrimaryPart ~= nil then
							part[1]:SetPrimaryPartCFrame(part[1].PrimaryPart.CFrame * CFrame.new(0, k / 80, -part[2]))
							part[2] *= 0.95
						end
					end
				end

				if #v2 > 0 then
					for _, v7 in pairs(v2) do
						if v7 ~= nil and v7.PrimaryPart ~= nil then
							v7:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
								0,
								math.rad(total),
								0
							))
						end
					end
				end

				clone:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position - createVector(0, 2, 0)) * CFrame.Angles(
					0,
					math.rad(total),
					0
				))
				total += 2 / (tick() - lastTime) * v6 * 60
				v6 = RunService.RenderStepped:Wait()
			end

			uprightSmog.Enabled = false
			flatSmog.Enabled = false
			spirals.Enabled = false
			wait(5)
			clone:Destroy()
			clone2:Destroy()
		end
	end
end