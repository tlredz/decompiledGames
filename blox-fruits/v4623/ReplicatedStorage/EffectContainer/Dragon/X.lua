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

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function debrisPart(data, p, p2)
	local v = math.random(40, 100) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * math.random(100, 150)
	part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(math.random(10, 15) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = createVector(0.1, 0.1, 0.1)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	return part
end

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function explosionEffect(p, rayPos, rayNormal)
	Util.Sound:Play("ShortExplosion2", rayPos, nil, 1 + math.random(-20, 20) / 100, 1)

	if p then
		for _ = 1, math.random(4, 6) do
			debrisPart(p, rayPos, rayNormal)
		end
	end

	local clone = FX:WaitForChild("DragonEffects").DragonExplosion:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = CFrame.new(
		rayPos,
		rayPos + ((rayNormal == nil or not rayNormal) and createVector(0, 1, 0) or rayNormal)
	) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.Parent = workspace._WorldOrigin

	for k, v in pairs({
		Main = 1.2,
		BlackMain = 0.8,
		WindRings = 0.2,
		Smoke = 1,
		Rocks = 0.5,
		Bits = 1,
		Bubble = 0.5
	}) do
		ScaleParticle(clone[k], 15)
		clone[k]:Emit(v * 20)
	end
end

return function(player)
	local stage = player.Stage

	if stage == 1 then
		local character = player.Character or nil
		local _ = player.HoldValue or nil
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
				return
			end

			Util.Sound:Play("BigBangAttackCharge", humanoidRootPart.Position, nil, 2, 1)
			local attachment_2 = Instance.new("Attachment")
			attachment_2.Parent = humanoidRootPart
			local clone = FX:WaitForChild("DragonEffects").DragonGrabInitiate:Clone()
			clone.Parent = humanoidRootPart
			clone:Emit(2)
			Util.Debris:AddItem(clone, 1)
		end
	elseif stage == 2 then
		local humanoidRootPart = (player.Character or nil):FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
				return
			end

			Util.Sound:Play("DodgeQuick2", humanoidRootPart.Position, nil, 1 + math.random(-20, 20) / 100, 1)
			Util.Sound:Play("SetFire", humanoidRootPart.Position, nil, 1.2 + math.random(-20, 20) / 100, 1.2)
			local clone = FX:WaitForChild("DragonEffects").DragonDashTrail:Clone()
			Util.Debris:AddItem(clone, 5)

			for _, attachment in pairs(clone:GetChildren()) do
				if attachment:IsA("Attachment") then
					attachment.Position *= 3
				end
			end

			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -1)
			clone.Parent = _WorldOrigin
			local total = 0
			local lastTime = tick()
			spawn(function()
				while tick() - lastTime < 0.5 do
					clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
						0,
						0,
						(math.rad(total))
					)
					total += 10
					RunService.RenderStepped:Wait()
				end

				clone.Center.Fire.Enabled = false

				for _, trail in pairs(clone:GetChildren()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end

				wait(0.25)
				clone:Destroy()
			end)
		end
	elseif stage == 3 then
		local attackerChar = player.AttackerChar
		local attackerHum = player.AttackerHum
		local victimChar = player.VictimChar
		local victimHum = player.VictimHum
		local grabExists = player.GrabExists
		local rightHand = attackerChar:FindFirstChild("RightHand")
		local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 and grabExists then
			local play = Util.Sound:Play("BuddhaGrab", humanoidRootPart2.Position, nil, 2, 1)
			play.TimePosition = 0.2
			local clone = FX:WaitForChild("DragonEffects").DragonDragParticles:Clone()
			Util.Debris:AddItem(clone, 10)
			local fXAttachment = clone.FXAttachment
			clone.Position = humanoidRootPart2.Position
			clone.Parent = _WorldOrigin
			tick()

			while RunService.RenderStepped:Wait() and grabExists and grabExists.Parent and humanoidRootPart and humanoidRootPart2 and humanoidRootPart.Parent and humanoidRootPart.Parent and attackerHum and victimHum and not (victimHum.Health <= 0 or attackerHum.Health <= 0) do
				humanoidRootPart2.CFrame = rightHand.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				local ray, position, _ = Util.Ray(
					humanoidRootPart2.Position,
					CFrame.new(humanoidRootPart2.Position, humanoidRootPart2.Position + createVector(0, -1, 0)).lookVector.Unit * 5,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if ray then
					fXAttachment.Rock.Color = ColorSequence.new(ray.Color)
					clone.Position = position

					for _, child in pairs(fXAttachment:GetChildren()) do
						child.Enabled = true
					end
				else
					for _, child in pairs(fXAttachment:GetChildren()) do
						child.Enabled = false
					end
				end
			end

			if clone then
				clone:Destroy()
			end
		end
	elseif stage == 5 then
		local rayHit = player.RayHit
		local rayPos = player.RayPos
		local rayNormal = player.RayNormal

		if (rayPos - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
			return
		else
			explosionEffect(rayHit or nil, rayPos, rayNormal)
		end
	end
end