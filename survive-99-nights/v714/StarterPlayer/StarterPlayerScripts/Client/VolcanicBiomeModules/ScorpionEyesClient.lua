local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local config = {
	GazeStiffness = 9,
	MaxPitch = 0.5235987755982988,
	BlinkMin = 2.5,
	BlinkMax = 6,
	BlinkCloseTime = 0.07,
	BlinkHold = 0.03,
	BlinkOpenTime = 0.11,
	BlinkSquash = 0.06,
	BlinkDip = 0.035,
	DoubleBlinkChance = 0.25,
	DoubleBlinkGap = 0.06,
	WaverPeriod = 3.8,
	WaverTint = Color3.new(0.92, 0.82, 0.68),
	UpdateRate = 20,
	FarUpdateRate = 6,
	FarDistance = 90,
	CullDistance = 260
}
local ScorpionEyesClient = {
	Config = config
}
local v2 = {}
local v3 = {}
local head = nil

function BlinkClosedness(p)
	if p <= 0 then
		return 0
	end

	local blinkCloseTime = config.BlinkCloseTime
	local blinkHold = config.BlinkHold
	local blinkOpenTime = config.BlinkOpenTime

	if p < blinkCloseTime then
		local v4 = p / blinkCloseTime
		return v4 * v4
	end

	if p < blinkCloseTime + blinkHold then
		return 1
	end

	local v4 = (p - blinkCloseTime - blinkHold) / blinkOpenTime

	if v4 >= 1 then
		return 0
	end

	local v5 = v4 - 1
	return -(v5 * v5 * (2.70158 * v5 + 1.70158))
end

function GazeFrame(p, p2)
	return CFrame.lookAt(p, p + p2, createVector(0, 1, 0))
end

function BuildPart(instance, cframe)
	local cFrame = instance.CFrame
	local v4 = { cFrame.RightVector, cFrame.UpVector, cFrame.LookVector }
	local v5 = -1
	local axisIndex = 2

	for k, v7 in pairs(v4) do
		local Y = math.abs(v7.Y)

		if not (v5 < Y) then
			continue
		end

		axisIndex = k
		v5 = Y
	end

	return {
		part = instance,
		restLocal = cframe:ToObjectSpace(cFrame),
		baseSize = instance.Size,
		baseColour = instance.Color,
		axisIndex = axisIndex,
		axisSign = v4[axisIndex].Y >= 0 and 1 or -1
	}
end

function OriginFrame(p)
	local root = p.root

	if root and root.Parent then
		return root.CFrame
	end

	return p.restOrigin
end

function Restore(p)
	local v4 = OriginFrame(p)
	local v5 = GazeFrame(v4.Position, v4.LookVector)

	for _, part in pairs(p.parts) do
		local part2 = part.part

		if not part2.Parent then
			continue
		end

		part2.Size = part.baseSize
		part2.Color = part.baseColour
		part2.CFrame = v5 * part.restLocal
	end
end

function CollectParts(p)
	local model = p.model
	local primaryPart = model.PrimaryPart
	local cFrame = primaryPart and primaryPart.CFrame or model:GetPivot()
	local v4 = GazeFrame(cFrame.Position, cFrame.LookVector)
	local parts = {}

	for _, part in pairs(model:GetDescendants()) do
		if not (part:IsA("BasePart") and part ~= primaryPart) then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		table.insert(parts, BuildPart(part, v4))
	end

	p.root = primaryPart
	p.restOrigin = cFrame
	p.parts = parts
	p.dirty = false
	p.gaze = cFrame.LookVector
end

function Register(model)
	if not model:IsA("Model") or v2[model] then
		return
	end

	local now = os.clock()
	local v4 = {
		model = model,
		root = nil,
		restOrigin = CFrame.identity,
		parts = {},
		gaze = createVector(1, 0, 0),
		waverPhase = math.random() * 3.141592653589793 * 2,
		nextUpdate = 0,
		lastOrigin = nil,
		lastGaze = nil,
		wasClosed = false,
		nextBlink = now + math.random() * config.BlinkMax,
		blinkStart = nil,
		doubleQueued = false,
		lastUpdate = now,
		awake = true,
		dirty = false
	}
	v2[model] = v4
	CollectParts(v4)

	local function markDirty(part)
		if part:IsA("BasePart") then
			v4.dirty = true
		end
	end

	v3[model] = { model.DescendantAdded:Connect(markDirty), model.DescendantRemoving:Connect(markDirty) }
end

function Unregister(p)
	local v4 = v2[p]

	if not v4 then
		return
	end

	v2[p] = nil
	local v5 = v3[p]

	if v5 then
		for _, connection in pairs(v5) do
			connection:Disconnect()
		end

		v3[p] = nil
	end

	Restore(v4)
end

function GazeTargetPosition()
	if head and head.Parent then
		return head.Position
	end

	head = nil
	local character = localPlayer.Character

	if not character then
		return nil
	end

	head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	return head and head.Position or nil
end

function Step()
	local DISTANCE_EPSILON = 0.0001
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local cFrame = currentCamera.CFrame
	local position = cFrame.Position
	local now = os.clock()
	local v4 = config.BlinkCloseTime + config.BlinkHold + config.BlinkOpenTime
	local v5 = 6.283185307179586 / config.WaverPeriod
	local waverTint = config.WaverTint
	local v6 = GazeTargetPosition()

	for k, v7 in pairs(v2) do
		if k.Parent then
			if v7.dirty then
				Restore(v7)
				CollectParts(v7)
			end

			if #v7.parts ~= 0 then
				local lastOrigin = OriginFrame(v7)
				local position2 = lastOrigin.Position
				local magnitude = (position2 - position).Magnitude

				if config.CullDistance < magnitude or cFrame:PointToObjectSpace(position2).Z > 4 then
					if v7.awake then
						Restore(v7)
						v7.awake = false
					end
				else
					v7.awake = true

					if v7.blinkStart == nil then
						if now < v7.nextUpdate then
							continue
						else
							v7.nextUpdate = now + 1 / math.max(
								config.FarDistance < magnitude and config.FarUpdateRate or config.UpdateRate,
								1
							)
						end
					end

					local v9 = math.min(now - v7.lastUpdate, 0.25)
					v7.lastUpdate = now
					local v10 = 0

					if v7.blinkStart then
						local v11 = now - v7.blinkStart

						if v4 <= v11 then
							v7.blinkStart = nil

							if v7.doubleQueued then
								v7.doubleQueued = false
								v7.blinkStart = now + config.DoubleBlinkGap
							else
								v7.nextBlink = now + config.BlinkMin + math.random() * (config.BlinkMax - config.BlinkMin)
							end
						else
							v10 = BlinkClosedness(v11)
						end
					elseif v7.nextBlink <= now then
						v7.blinkStart = now
						v7.doubleQueued = math.random() < config.DoubleBlinkChance
					end

					if v6 then
						local v11 = v6 - position2
						local vector2 = Vector3.new(v11.X, 0, v11.Z)

						if vector2.Magnitude < DISTANCE_EPSILON then
							vector2 = Vector3.new(v7.gaze.X, 0, v7.gaze.Z)

							if vector2.Magnitude < DISTANCE_EPSILON then
								vector2 = Vector3.new(lastOrigin.LookVector.X, 0, lastOrigin.LookVector.Z)
							end
						end

						if vector2.Magnitude > DISTANCE_EPSILON then
							local unit = vector2.Unit
							local v12 = math.clamp(
								math.atan2(v11.Y, vector2.Magnitude),
								-config.MaxPitch,
								config.MaxPitch
							)
							local unit2 = unit * math.cos(v12) + createVector(0, 1, 0) * math.sin(v12)
							local lerped = v7.gaze:Lerp(unit2, 1 - math.exp(-config.GazeStiffness * v9))

							if lerped.Magnitude > DISTANCE_EPSILON then
								unit2 = lerped.Unit or unit2
							end

							v7.gaze = unit2
						end
					end

					local v12 = v7.lastOrigin ~= lastOrigin or v7.lastGaze == nil or not (v7.lastGaze:Dot(v7.gaze) > 0.999999) or v10 ~= 0 or v7.wasClosed
					v7.wasClosed = v10 ~= 0
					v7.lastOrigin = lastOrigin
					v7.lastGaze = v7.gaze
					local v13

					if v12 then
						v13 = GazeFrame(position2, v7.gaze) or nil
					end

					local v14 = 0.5 - math.cos(now * v5 + v7.waverPhase) * 0.5

					for _, part in pairs(v7.parts) do
						local part2 = part.part

						if v12 then
							local cFrame2 = v13 * part.restLocal

							if v10 ~= 0 then
								cFrame2 -= ({ cFrame2.RightVector, cFrame2.UpVector, cFrame2.LookVector })[part.axisIndex] * (part.axisSign * config.BlinkDip * v10)
							end

							part2.CFrame = cFrame2
						end

						if v10 == 0 then
							if part2.Size ~= part.baseSize then
								part2.Size = part.baseSize
							end
						else
							local baseSize = part.baseSize
							local v15 = 1 - v10 * (1 - config.BlinkSquash)
							local X

							if part.axisIndex == 1 then
								X = baseSize.X * v15
							else
								X = baseSize.X
							end

							local Y

							if part.axisIndex == 2 then
								Y = baseSize.Y * v15
							else
								Y = baseSize.Y
							end

							local v16

							if part.axisIndex == 3 then
								v16 = baseSize.Z * v15
							else
								v16 = baseSize.Z
							end

							part2.Size = Vector3.new(X, Y, v16)
						end

						local baseColour = part.baseColour
						part2.Color = baseColour:Lerp(
							Color3.new(
								baseColour.R * waverTint.R,
								baseColour.G * waverTint.G,
								baseColour.B * waverTint.B
							),
							v14
						)
					end
				end
			end
		else
			Unregister(k)
		end
	end
end

function ScorpionEyesClient.Init()
	Client.Utility.ForAllTagged("ScorpionEyes", Register, Unregister)
	RunService.Heartbeat:Connect(Step)
end

return ScorpionEyesClient