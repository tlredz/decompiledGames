local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage.Util)
local Effect = require(ReplicatedStorage.Effect)
Effect.new("ShakeCam")
local superhumanV2Travel = Effect.new("SuperhumanV2.Travel")
local FX = require(ReplicatedStorage.FX)
local _WorldOrigin = workspace._WorldOrigin

local function groundEffects(position, rayMap)
	local clone = FX:WaitForChild("StringEffects").StringFlightGroundParticles:Clone()
	Util.Debris:AddItem(clone, 1)
	clone.Position = position
	local fXAttachment = clone.FXAttachment
	local kiImpact = fXAttachment.KiImpact
	local kiSpikes = fXAttachment.KiSpikes
	kiImpact.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 5),
		NumberSequenceKeypoint.new(0.5, 3.55),
		NumberSequenceKeypoint.new(1, 12.5)
	})
	kiSpikes.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 7.5), NumberSequenceKeypoint.new(1, 15) })
	local rock = fXAttachment.Rock
	local dust = fXAttachment.Dust
	clone.Parent = _WorldOrigin

	if rayMap then
		rock.Color = ColorSequence.new(rayMap.Color)
		dust.Color = ColorSequence.new(rayMap.Color)
	end

	spawn(function()
		for _ = 0, 2 do
			RunService.RenderStepped:Wait(0.1)
			kiImpact:Emit(1)
			kiSpikes:Emit(1)
			rock:Emit(1)
			dust:Emit(2)
		end
	end)
	return clone
end

return function(player)
	local _ = player.Mouse
	local character = player.Character
	local indicator = player.Indicator
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local position = primaryPart.Position
	local rayMap, position3, _ = Util.RayMap(position, createVector(-0, -1, -0) * primaryPart.Size.Magnitude * 2)

	if rayMap then
		groundEffects(position3, rayMap)
	end

	local direction = player.Direction
	local v2 = position + direction * 175 + createVector(0, 300, 0)
	local _, v3, _ = Util.RayMap(position, v2 - position)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(createVector(0, 0, 0), direction) + position
	attachment.Parent = workspace.Terrain
	local rightGripAttachment = character:FindFirstChild("RightHand"):FindFirstChild("RightGripAttachment")
	local v4 = {}

	for _ = 1, 2 do
		local clone = script.String:Clone()
		clone.Transparency = NumberSequence.new(0)
		clone.Attachment0 = rightGripAttachment
		clone.Attachment1 = attachment
		clone.Parent = attachment
		table.insert(v4, clone)
	end

	for _, child in pairs(script.SpawnParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = rightGripAttachment
		clone:Emit(clone:GetAttribute("EmitCount"))
		Util.Debris:AddItem(clone, clone.Lifetime.Max)
	end

	local v5 = 0
	superhumanV2Travel:replicate({
		Root = primaryPart,
		IgnoreTrail = true,
		Scale = 2,
		Duration = 1
	})
	local clone = script.Motion:Clone()
	clone.CFrame = primaryPart.CFrame
	clone.Size = createVector(2, 2, 2) * primaryPart.Size.Magnitude
	clone.Parent = _WorldOrigin
	local v6 = nil
	local worldPosition = nil
	local attachment2 = nil
	local position2 = primaryPart.Position
	Util.DistributedLoop:add(function(p, p2)
		local v7 = math.min(1, p / 1)
		local v8 = math.clamp(p - 0.5, 0, 1)
		local v9 = math.sin(3.141592653589793 * v8)
		local v10 = math.sin(3.141592653589793 * v7)
		Util.Tween.point(1, 0, v9)
		Util.Tween.point(1, 0, v10)
		v5 = v5 % 6.283185307179586 + 25.132741228718345 * p2
		local v11 = math.sin(v5)

		for k, v12 in pairs(v4) do
			v12.CurveSize0 = (k % 2 == 0 and 1 or -1) * v11 * 5 * (1 - v7)
			v12.CurveSize1 = v12.CurveSize0
		end

		attachment.CFrame = CFrame.new(createVector(0, 0, 0), direction) + position:Lerp(
			v3,
			Util.Tween.ease.out.quad(v7, 0, 1, 1)
		)
		clone.CFrame = CFrame.new(primaryPart.Position, position2) * CFrame.Angles(0, 3.141592653589793, 0)
		position2 = primaryPart.Position

		if indicator and not indicator:IsDescendantOf(workspace) then
			if not worldPosition then
				worldPosition = rightGripAttachment.WorldPosition
			end

			if not attachment2 then
				attachment2 = Instance.new("Attachment")
				attachment2.CFrame = CFrame.new(createVector(0, 0, 0), direction) + worldPosition
				attachment2.Parent = workspace.Terrain

				for _, v12 in pairs(v4) do
					v12.Attachment0 = attachment2
				end

				v6 = p
			end
		end

		if attachment2 then
			local v12 = math.min(1, (p - v6) / 0.5)
			attachment2.Position = worldPosition:Lerp(v3, v12)
		end

		if v7 == 1 then
			local v12 = math.min(1, (p - 1) / 0.5)

			if v12 == 1 then
				clone:Destroy()
				attachment:Destroy()

				if attachment2 then
					attachment2:Destroy()
				end

				for k, v13 in pairs(v4) do
					v13:Destroy()
					v4[k] = nil
				end

				return true
			else
				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, v13 in pairs(v4) do
					v13.Width0 = (1 - v12) * 1
					v13.Width1 = v13.Width0
				end
			end
		end
	end)
	Util.Sound:Play("WhipQuick", rightGripAttachment, nil, 2)
end