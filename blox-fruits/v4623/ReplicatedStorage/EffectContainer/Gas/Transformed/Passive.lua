local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.Passive.Assets
local _ = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailSpin(humanoidRootPart, folder, p)
	local spinTrails = assets.Phase1.SpinTrails
	local clone = assets.Phase1.TrailHolder:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Anchored = true
	clone.Parent = folder
	local v = 0
	local v2 = {}
	local v3 = 0.016666666666666666

	while p.Enabled do
		clone.CFrame = CFrame.new(humanoidRootPart.Position)

		if p.LastFloor and v - tick() <= 0 then
			v = 0.15 + tick()
			local clone2 = spinTrails["Trail" .. tostring((math.random(1, #spinTrails:GetChildren())))]:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = clone
			clone2.Anchored = true
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 1
			numberValue.Parent = folder
			TweenService:Create(numberValue, TweenInfo.new(1.15), {
				Value = 0
			}):Play()

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			clone2.SpinTrail2.WeldConstraint.Enabled = false
			clone2.SpinTrail2.CFrame = clone2.CFrame * CFrame.new(
				math.random(-50, -35),
				math.random(5, 25),
				math.random(10, 25)
			)
			clone2.SpinTrail2.WeldConstraint.Enabled = true
			clone2.Weld.C0 = clone2.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			local v4 = math.random(1, 3)

			if v4 == 1 then
				clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(129, 74, 248), Color3.fromRGB(89, 100, 255))
			elseif v4 == 2 then
				clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(80, 124, 221), Color3.fromRGB(76, 115, 255))
			elseif v4 == 3 then
				clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(53, 64, 156), Color3.fromRGB(111, 64, 214))
			end

			local v5 = math.random(7, 10)
			clone2.SpinTrail2.Attach0.Position = Vector3.new(v5, 0, 0)
			clone2.SpinTrail2.Attach1.Position = Vector3.new(-v5, 0, 0)
			clone2.Trail.Lifetime = math.random(15, 30) / 100
			v2[clone2] = { math.random(12, 17) * 0.9, numberValue, math.random(1, 360) }
		end

		for k, v4 in pairs(v2) do
			local v5 = v4[1]
			local v6 = v4[2]

			if v6.Value <= 0 then
				v2[k] = nil
				k.Trail.Enabled = false
				local v7 = v6
				local v8 = k
				task.delay(1, function()
					v7:Destroy()
					v8:Destroy()
				end)
			elseif p.LastFloor then
				if not k.Trail.Enabled then
					k.Trail.Enabled = true
				end

				v4[3] += v5 * v3 * 60
				k.CFrame = clone.CFrame * CFrame.new(0, -33.333 + v6.Value, 0) * CFrame.Angles(0, math.rad(v4[3]), 0)
			else
				k.Trail.Enabled = false
			end
		end

		v3 = task.wait(0.01)
	end

	for folder2, _ in pairs(v2) do
		for _, effect in pairs(folder2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function makeProxyPartAtBone(attachment, clone)
	local cframe = CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. attachment.Name
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = cframe
	attachment2.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	rigidConstraint.Parent = part
	part.Transparency = 1
	part.Parent = clone
	return part
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(player)
	local character = player.Character
	local rig = player.Rig
	local v = player.Backpack == nil
	local boss = player.Boss
	local folder = Instance.new("Folder")
	folder.Parent = workspace._WorldOrigin
	local humanoidRootPart = character.HumanoidRootPart
	local cFrame = humanoidRootPart.CFrame
	local clone = assets.Phase1.GasArea:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Anchored = false
	clone.Weld.Part1 = humanoidRootPart
	local clone2 = nil
	task.spawn(function()
		clone2 = assets.Phase1.GasAreaMouth:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder
		local proxyPartAtBone = makeProxyPartAtBone(rig.RootPart.Root.LowerTorso.UpperTorso.Head, clone2)
		clone2.Anchored = false
		clone2.Weld.Part1 = proxyPartAtBone
	end)
	local clone3 = nil
	task.spawn(function()
		local highpoly060 = rig["high poly.060"]
		clone3 = assets.Phase1.GasAreaSword:Clone()
		clone3.CFrame = highpoly060.CFrame
		clone3.Parent = folder
		local proxyPartAtBone = makeProxyPartAtBone(
			rig.RootPart.Root.LowerTorso.UpperTorso["Upperarm.r"]["Lowerarm.r"]["Hand.r"],
			clone3
		)
		clone3.Anchored = false
		clone3.Weld.Part1 = proxyPartAtBone
	end)
	local clone4 = assets.Phase1.GasDomain2:Clone()
	clone4.CFrame = cFrame
	clone4.Parent = folder
	local v2 = {
		Enabled = true,
		LastFloor = false
	}
	local v3 = Util.Sound:Play("BF_GASFRUIT_TSFM_Idle_01", humanoidRootPart)
	local v4 = nil
	task.spawn(function()
		local v5 = boss and 100 or 50
		local emittersByEmitter = {}

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emittersByEmitter[emitter] = emitter
			emitter.Enabled = false
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v6 = false

		while (v or player.Backpack and (player.Backpack:FindFirstChild("Gas-Gas") or character:FindFirstChild("Gas-Gas"))) and player.Rig:IsDescendantOf(character) and humanoidRootPart:IsDescendantOf(workspace) do
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 1, 0),
				createVector(0, 1, 0) * -v5,
				raycastParams
			)

			if raycastResult and humanoidRootPart.Parent:GetAttribute("CastingTransformedGasF") == nil then
				v2.LastFloor = true
				clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal

				if v6 == false then
					v6 = true

					if not v4 then
						v4 = Util.Sound:Play("BF_GASFRUIT_TSFM_Walking_01", humanoidRootPart)
					end

					for _, v7 in pairs(emittersByEmitter) do
						v7.Enabled = true
					end
				end
			else
				v2.LastFloor = false

				if v6 == true then
					v6 = false

					if v4 then
						Util.Sound:FadeOut(v4, 0.2)
						v4 = nil
					end

					for _, v7 in pairs(emittersByEmitter) do
						v7.Enabled = false
					end
				end
			end

			task.wait(0.07)
		end

		v2.Enabled = false

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		if v4 then
			Util.Sound:FadeOut(v4, 0.2)
			v4 = nil
		end

		for _, v7 in pairs(emittersByEmitter) do
			v7.Enabled = false
		end

		pcall(function()
			clone.Weld:Destroy()
		end)
		clone.Anchored = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(4)
		folder:Destroy()
	end)
	task.spawn(function()
		TrailSpin(humanoidRootPart, folder, v2)
	end)
end