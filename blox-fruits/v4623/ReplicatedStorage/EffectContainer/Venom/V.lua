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

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function implode(humanoidRootPart, duration, color2)
	local v = {
		-8,
		8,
		-12,
		12,
		-16,
		16,
		-25,
		25,
		-30,
		30,
		-35,
		35,
		-40,
		40
	}

	local function newSwirl(p)
		local v2 = { color2, Color3.fromRGB(86, 0, 148) }
		local clone = FX:WaitForChild("VenomEffects").Ribbons:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.Color = v2[math.random(1, #v2)]
		clone.Size = createVector(0.05, 0.05, 0.05)
		clone.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, p, 0)) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			0
		)
		local v3 = math.random(65, 75)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(math.random(2, 3) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = Vector3.new(v3, v3 / 5, v3),
				Color = color2 or Color3.fromRGB(125, 15, 161),
				Transparency = 0,
				CFrame = clone.CFrame * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad(180 * ({ -1, 1 })[math.random(1, 2)]),
					(math.rad((math.random(-5, 5))))
				)
			}
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		clone.Parent = _WorldOrigin
		tween:Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function newGlob(duration2)
		spawn(function()
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, 5)
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(0.1, 0.1, 10)
			part.Color = Color3.fromRGB(95, 26, 156)
			part.Material = Enum.Material.Glass
			part.Transparency = 1
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = Enum.MeshType.Sphere
			specialMesh.Parent = part
			local vector2 = Vector3.new(v[math.random(duration2, #v)], math.random(-10, 10), v[math.random(1, #v)])
			local vector3 = Vector3.new(math.random(-50, 50), math.random(-15, 40), math.random(-50, 50))
			local vector4 = Vector3.new(math.random(-50, 50), math.random(-15, 40), math.random(-50, 50))
			part.Position = humanoidRootPart.Position + vector2
			local _ = part.Position
			local v2 = math.random(1, 15)
			local tween = TweenService:Create(
				part,
				TweenInfo.new(duration2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(v2, v2, v2),
					Color = color2 or Color3.fromRGB(125, 15, 161),
					Transparency = 0
				}
			)
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
			part.Parent = _WorldOrigin
			local lastTime = tick()

			while tick() - lastTime <= duration2 do
				if humanoidRootPart == nil then
					continue
				end

				local v3 = tick() - lastTime
				local v4 = {
					part.Position,
					part.Position:Lerp(humanoidRootPart.Position + vector3, 0.25),
					part.Position:Lerp(humanoidRootPart.Position + vector4, 0.75),
					humanoidRootPart.Position
				}
				local v5 = cubicBezier(v3 / duration2, unpack(v4))
				part.CFrame = CFrame.new(v5, part.Position)
				RunService.RenderStepped:Wait()
			end
		end)
	end

	spawn(function()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(0.05, 0.05, 0.05)
		part.Color = color2 or Color3.fromRGB(95, 26, 156)
		part.Material = Enum.Material.Glass
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = part
		part.Position = humanoidRootPart.Position
		local clone = FX:WaitForChild("VenomEffects").FlyStart:Clone()
		local attachment = clone.Attachment
		attachment.Parent = part
		clone:Destroy()
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(50, 50, 50),
				Color = Color3.fromRGB(125, 15, 161)
			}
		)
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		part.Parent = _WorldOrigin

		for _, child in pairs(attachment:GetChildren()) do
			child:Emit(2)
		end

		tween:Play()

		for _ = 0, 30 do
			spawn(function()
				newGlob(0.6) -- equivalent call inferred; original call site unknown
				newSwirl(math.random(-15, 15))
			end)
		end
	end)
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local _ = player.Color1
		local color2 = player.Color2

		if player.Action == 1 then
			implode(humanoidRootPart, 0.5, color2)
			Util.Sound:Play("AcidForm", humanoidRootPart.Position, nil, 1.4 + math.random(-10, 10) / 100, 4)
			Util.Sound:Play("GravityZ", humanoidRootPart.Position, nil, 1 + math.random(-10, 10) / 100, 0.25)
			Util.Sound:Play("Healing2", humanoidRootPart.Position, nil, 0.8 + math.random(-10, 10) / 100, 1)
			local clone = FX:WaitForChild("VenomEffects").HydraTransformFX.Attachment:Clone()
			Util.Debris:AddItem(clone, 5)
			clone.Parent = humanoidRootPart

			for _, child in pairs(clone:GetChildren()) do
				child.Enabled = true
			end

			wait(0.5)

			for _, child in pairs(clone:GetChildren()) do
				child.Enabled = false
			end
		end
	end
end