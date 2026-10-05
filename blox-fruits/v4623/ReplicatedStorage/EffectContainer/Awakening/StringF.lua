local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function groundEffects(position, ray)
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

	if ray then
		rock.Color = ColorSequence.new(ray.Color)
		dust.Color = ColorSequence.new(ray.Color)
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

local function stringRay(parent)
	local position = parent.Position
	local clone = FX:WaitForChild("StringEffects").StringFlight:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Position = position
	local startAttachment = clone.StartAttachment
	Util.Debris:AddItem(startAttachment, 1.5)
	startAttachment.Parent = parent
	local hitAttachment = clone.HitAttachment
	local stringCore = clone.StringCore
	local stringLayer = clone.StringLayer
	startAttachment.Orientation = Vector3.new(0, math.random(-180, 180), 0)
	local ray, worldPosition, _ = Util.Ray(
		position,
		-CFrame.new(position).upVector.Unit * 25,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local v2 = {
		-8 * (parent.Position - worldPosition).magnitude / 10,
		8 * (parent.Position - worldPosition).magnitude / 10
	}
	local curveSize = v2[math.random(1, #v2)]

	if not ray then
		worldPosition += Vector3.new(math.random(-15, 15), math.random(-10, 25), math.random(-15, 15))
	end

	hitAttachment.WorldPosition = worldPosition
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		stringCore,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CurveSize0 = curveSize,
			CurveSize1 = curveSize / 2
		}
	)
	local tween2 = TweenService:Create(
		stringLayer,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CurveSize0 = curveSize,
			CurveSize1 = curveSize / 2
		}
	)
	spawn(function()
		local lastTime = tick()
		local total = 0

		while tick() - lastTime <= 0.5 do
			local v4 = (tick() - lastTime) / 0.5
			total += (1 - total) * v4
			stringCore.Transparency = NumberSequence.new(total)
			stringLayer.Transparency = NumberSequence.new(total)
			startAttachment.WorldPosition = parent.Position
			hitAttachment.WorldPosition = worldPosition
			RunService.RenderStepped:Wait()
		end
	end)
	tween:Play()
	tween2:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
		startAttachment:Destroy()
	end)
	startAttachment.WorldPosition = parent.Position
end

local function mainEffect(player)
	local character = player.Character or nil
	local stage = player.Stage

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
			return
		end

		local rightHand = character:FindFirstChild("RightHand")
		local leftHand = character:FindFirstChild("LeftHand")

		if humanoidRootPart then
			local ray, position, v2 = Util.Ray(
				humanoidRootPart.Position,
				-CFrame.new(humanoidRootPart.Position).upVector.Unit * 25,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if stage == 1 then
				if ray then
					local clone = FX:WaitForChild("StringEffects").StringFlightShockwave:Clone()
					Util.Debris:AddItem(clone, 2)
					clone.CFrame = CFrame.new(position, position + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Parent = _WorldOrigin
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(22, 3, 22),
							CFrame = clone.CFrame * CFrame.new(0, 2, 0),
							Transparency = 1
						}
					)
					tween:Play()
					tween.Completed:Connect(function()
						clone:Destroy()
					end)
				end
			else
				if rightHand and leftHand then
					stringRay(rightHand)
					stringRay(rightHand)
					stringRay(leftHand)
					stringRay(leftHand)
				end

				if ray then
					local v3 = groundEffects(position, ray)
					spawn(function()
						while v3 ~= nil do
							RunService.RenderStepped:Wait()
							local ray2, position2, _ = Util.Ray(
								humanoidRootPart.Position,
								-CFrame.new(humanoidRootPart.Position).upVector.Unit * 25,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if not ray2 then
								break
							end

							v3.Position = position2
						end
					end)
				end
			end
		end
	end
end

return function(player)
	local rootPart = player.RootPart or nil
	local character = player.Character or nil
	local _ = player.HoldState or nil

	if rootPart then
		Util.Sound:Play("Leap", rootPart.Position, nil, 1.2 + math.random(-22, 22) / 100, 0.8)
		local v = Util.Sound:Play("KiDashLoop", rootPart, nil, 1, 0.2)
		tick()
		local v2 = false

		while player.HoldValue and player.HoldValue.Value == true and rootPart ~= nil and player.HoldValue.Parent ~= nil and player.HoldValue.Parent.Parent ~= nil do
			wait(0.1)
			mainEffect({
				Character = character,
				Stage = v2 and 2 or 1
			})
			v2 = true
		end

		Util.Sound:Play("SpinWoosh", rootPart.Position, nil, 1.2 + math.random(-20, 20) / 100, 0.5)

		if v then
			v:Destroy()
		end
	end
end