local createVector = vector.create
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local parent = script.Parent
local PianoModule = {
	Seat = parent.Bench.Seat,
	Origin = parent.KeyBox,
	Camera = { parent.CameraA, parent.CameraB, parent.CameraC },
	Zone = 45,
	DefaultSoundFont = 1
}

local function IsBlack(p)
	local v = (p - 1) % 12 + 1

	if v % 12 == 2 or v % 12 == 5 or v % 12 == 7 or v % 12 == 10 or v % 12 == 0 then
		return true
	end
end

if not isClient then
	return PianoModule
end

local Tween = require(script.Tween)
local keys = parent.Keys
local v = {}
local v2 = {}
local v3 = nil

for _, child in pairs(keys:GetChildren()) do
	v[child] = parent:GetPivot():ToObjectSpace(child.CFrame)
end

local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.04363323129985824)
local cframe2 = CFrame.fromEulerAnglesYXZ(0, 0, 0.026179938779914945)
local tweenInfo = TweenInfo.new(0.1)
local v4 = nil
local v5 = CFrame.fromEulerAnglesYXZ(0, 0, 1.2217304763960306) * CFrame.fromEulerAnglesYXZ(0, -1.5707963267948966, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function setAttachmentWorldCFrame(p, p2)
	p.CFrame = p.Parent.CFrame:toObjectSpace(p2)
end

local trails = parent.Trails
local v6 = false
local v7 = {}

local function renderTrails()
	if v6 == true then
		return
	end

	v6 = true
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if #v7 == 0 or not v6 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
			v6 = false
		else
			local v8 = dt * 2
			local v9 = #v7 - 75
			local v10 = 1

			for i, v11 in ipairs(v7) do
				local trail = v11.trail

				if v9 > 0 then
					v7[i] = nil
					trail:Destroy()
					v9 -= 1
				else
					local note = v11.note
					local keyCode = v11.keyCode
					local origin = v11.origin
					local state = v11.state

					if state == 1 then
						trail.Size = Vector3.new(trail.Size.X, math.min(trail.Size.Y + v8, 5), trail.Size.Z)
						trail.CFrame *= CFrame.new(0, v8 / 2, 0)

						if trail.Size.Y >= 5 then
							v11.state = 3
						elseif v2[note] ~= keyCode then
							v11.state = 2
						end
					elseif state == 2 then
						trail.CFrame *= CFrame.new(0, v8, 0)

						if origin:ToObjectSpace(trail.CFrame).Position.Y >= 5 - trail.Size.Y / 2 then
							v11.state = 3
						end
					elseif state == 3 then
						trail.Size = Vector3.new(trail.Size.X, math.max(trail.Size.Y - v8, 0), trail.Size.Z)
						trail.CFrame *= CFrame.new(0, v8 / 2, 0)

						if trail.Size.Y < 0.1 then
							v7[i] = nil
							trail:Destroy()
							continue
						end
					end

					if v10 ~= i then
						v7[v10] = v11
						v7[i] = nil
					end

					v10 += 1
				end
			end
		end
	end)
end

function PianoModule.AnimateKeyDown(_, keyCode2, p2, p3, _, _, _)
	local note2 = math.clamp(p2 + p3 + 15, 1, 88)
	v2[note2] = keyCode2
	local key = keys[note2]
	local worldSpace = parent:GetPivot():ToWorldSpace(v[key])
	local v12 = (p2 - 1) % 12 + 1
	Tween:Play(key, tweenInfo, {
		CFrame = worldSpace * ((v12 % 12 == 2 or v12 % 12 == 5 or v12 % 12 == 7 or v12 % 12 == 10 or v12 % 12 == 0 or nil) and cframe2 or cframe)
	})
	local part = Instance.new("Part")
	part.Material = Enum.Material.Neon
	part.Transparency = 0.4
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = Vector3.new(key.Size.X, 0.1, 0)
	part.CFrame = parent:GetPivot():ToWorldSpace(v[key]) * CFrame.new(0, key.Size.Y / 2, 0.025 - key.Size.Z / 2)
	part.Parent = trails
	table.insert(v7, {
		trail = part,
		note = note2,
		keyCode = keyCode2,
		origin = part.CFrame,
		state = 1
	})

	if not v6 and v6 ~= true then
		v6 = true
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if #v7 == 0 or not v6 then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
				v6 = false
			else
				local v13 = dt * 2
				local v14 = #v7 - 75
				local v15 = 1

				for i, v16 in ipairs(v7) do
					local trail = v16.trail

					if v14 > 0 then
						v7[i] = nil
						trail:Destroy()
						v14 -= 1
					else
						local note = v16.note
						local keyCode = v16.keyCode
						local origin = v16.origin
						local state = v16.state

						if state == 1 then
							trail.Size = Vector3.new(trail.Size.X, math.min(trail.Size.Y + v13, 5), trail.Size.Z)
							trail.CFrame *= CFrame.new(0, v13 / 2, 0)

							if trail.Size.Y >= 5 then
								v16.state = 3
							elseif v2[note] ~= keyCode then
								v16.state = 2
							end
						elseif state == 2 then
							trail.CFrame *= CFrame.new(0, v13, 0)

							if origin:ToObjectSpace(trail.CFrame).Position.Y >= 5 - trail.Size.Y / 2 then
								v16.state = 3
							end
						elseif state == 3 then
							trail.Size = Vector3.new(trail.Size.X, math.max(trail.Size.Y - v13, 0), trail.Size.Z)
							trail.CFrame *= CFrame.new(0, v13 / 2, 0)

							if trail.Size.Y < 0.1 then
								v7[i] = nil
								trail:Destroy()
								continue
							end
						end

						if v15 ~= i then
							v7[v15] = v16
							v7[i] = nil
						end

						v15 += 1
					end
				end
			end
		end)
	end

	local cFrame = nil
	local leftLowerIKAttachment

	if v4 then
		local v13 = note2 <= 44

		if v13 then
			leftLowerIKAttachment = v4.leftLowerIKAttachment
		else
			leftLowerIKAttachment = v4.rightLowerIKAttachment
		end

		local v14 = (note2 - (v13 and 1 or 44)) / 44

		if v4.rigType == Enum.HumanoidRigType.R6 then
			local v15 = v14 * 60 + (v13 and -15 or 45) * (v13 and 1 or -1)
			leftLowerIKAttachment.CFrame = leftLowerIKAttachment:GetAttribute("originCFrame") * CFrame.fromEulerAnglesYXZ(
				0,
				0,
				(math.rad(v15))
			)
			cFrame = leftLowerIKAttachment.CFrame
			Tween:Play(leftLowerIKAttachment, tweenInfo, {
				CFrame = cFrame * CFrame.fromEulerAnglesYXZ(-0.08726646259971647, 0, 0)
			})
		elseif v4.rigType == Enum.HumanoidRigType.R15 then
			local v15

			if v13 then
				v15 = v4.leftUpperIKAttachment
			else
				v15 = v4.rightUpperIKAttachment
			end

			v15.CFrame = CFrame.new(v14 * 3 + (v13 and -5 or 2), -1.5, -2.5)
			setAttachmentWorldCFrame(leftLowerIKAttachment, key.CFrame * v5) -- equivalent call inferred; original call site unknown
			cFrame = leftLowerIKAttachment.CFrame
			Tween:Play(leftLowerIKAttachment, tweenInfo, {
				CFrame = cFrame - createVector(0, 0.5, 0)
			})
		end
	end

	local total = 0

	while v2[note2] ~= keyCode2 and total < 0.1 or v2[note2] == keyCode2 and total < 4 do
		total += RunService.Heartbeat:Wait()
	end

	Tween:Play(key, tweenInfo, {
		CFrame = parent:GetPivot():ToWorldSpace(v[key])
	})

	if v4 then
		Tween:Play(leftLowerIKAttachment, tweenInfo, {
			CFrame = cFrame
		})
	end
end

function PianoModule.AnimateKeyUp(_, p)
	for k, v8 in pairs(v2) do
		if v8 == p then
			v2[k] = nil
		end
	end
end

function PianoModule.AnimateSustainDown(_, _, p)
	if p == nil then
		return
	end

	local total = 0
	local now = os.clock()
	v3 = now

	while v3 ~= now and total < 0.1 or v3 == now and total < 4 do
		total += RunService.Heartbeat:Wait()
	end
end

function PianoModule.AnimateSustainUp(_, _)
	v3 = nil
end

function PianoModule.ResetEffects()
	table.clear(v2)
	v3 = nil

	for i = 1, 88 do
		local key = keys[i]
		Tween:Play(key, tweenInfo, {
			CFrame = originCFrames[key]
		})
	end

	v6 = false

	for _, v8 in ipairs(v7) do
		v8.trail:Destroy()
	end

	table.clear(v7)
end

local Players = game:GetService("Players")

local function getOccupant(seat)
	if seat.Occupant then
		return seat.Occupant
	end

	local seatWeld = seat:FindFirstChild("SeatWeld")

	if seatWeld and seatWeld.Part1 and seatWeld.Part1.Parent and seatWeld.Part1.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(seatWeld.Part1.Parent.Name) then
		return seatWeld.Part1.Parent.Humanoid
	end
end

local seat = PianoModule.Seat
local playerFromCharacter

if getOccupant(seat) then
	playerFromCharacter = Players:GetPlayerFromCharacter(getOccupant(seat).Parent) or nil
else
	playerFromCharacter = nil
end

local function createIKData(playerFromCharacter2)
	local character = playerFromCharacter2.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local rigType = humanoid.RigType

	if not humanoid then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local iKControl = Instance.new("IKControl")
	local iKControl2 = Instance.new("IKControl")
	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")
	local iKControl3 = Instance.new("IKControl")
	local iKControl4 = Instance.new("IKControl")
	local attachment3 = Instance.new("Attachment")
	local attachment4 = Instance.new("Attachment")
	iKControl.Parent = humanoid
	iKControl2.Parent = humanoid
	attachment.Parent = humanoidRootPart
	attachment2.Parent = humanoidRootPart
	iKControl3.Parent = humanoid
	iKControl4.Parent = humanoid
	attachment3.Parent = humanoidRootPart
	attachment4.Parent = humanoidRootPart
	iKControl3.Target = attachment3
	iKControl4.Target = attachment4

	if rigType == Enum.HumanoidRigType.R6 then
		attachment3.CFrame *= CFrame.fromEulerAnglesYXZ(1.0471975511965976, 0, 0)
		attachment4.CFrame *= CFrame.fromEulerAnglesYXZ(1.0471975511965976, 0, 0)
		attachment3:SetAttribute("originCFrame", attachment3.CFrame)
		attachment4:SetAttribute("originCFrame", attachment4.CFrame)
		iKControl3.EndEffector = character:FindFirstChild("Left Arm")
		iKControl4.EndEffector = character:FindFirstChild("Right Arm")
		iKControl3.ChainRoot = character:FindFirstChild("Left Arm")
		iKControl4.ChainRoot = character:FindFirstChild("Right Arm")
	elseif rigType == Enum.HumanoidRigType.R15 then
		setAttachmentWorldCFrame(attachment3, keys:FindFirstChild(22).CFrame * v5) -- equivalent call inferred; original call site unknown
		setAttachmentWorldCFrame(attachment4, keys:FindFirstChild(66).CFrame * v5) -- equivalent call inferred; original call site unknown
		iKControl.Parent = humanoid
		iKControl2.Parent = humanoid
		attachment.Parent = humanoidRootPart
		attachment2.Parent = humanoidRootPart
		attachment.CFrame = CFrame.new(-3, -1.5, -2.5)
		attachment2.CFrame = CFrame.new(3, -1.5, -2.5)
		iKControl.Target = attachment
		iKControl2.Target = attachment2
		iKControl.EndEffector = character:FindFirstChild("LeftLowerArm")
		iKControl2.EndEffector = character:FindFirstChild("RightLowerArm")
		iKControl.ChainRoot = character:FindFirstChild("LeftUpperArm")
		iKControl2.ChainRoot = character:FindFirstChild("RightUpperArm")
		iKControl3.EndEffector = character:FindFirstChild("LeftHand")
		iKControl4.EndEffector = character:FindFirstChild("RightHand")
		iKControl3.ChainRoot = character:FindFirstChild("LeftLowerArm")
		iKControl4.ChainRoot = character:FindFirstChild("RightLowerArm")
		iKControl3.Type = Enum.IKControlType.Position
		iKControl4.Type = Enum.IKControlType.Position
	end

	v4 = {
		rigType = humanoid.RigType,
		leftUpperIKControl = iKControl,
		rightUpperIKControl = iKControl2,
		leftUpperIKAttachment = attachment,
		rightUpperIKAttachment = attachment2,
		leftLowerIKControl = iKControl3,
		rightLowerIKControl = iKControl4,
		leftLowerIKAttachment = attachment3,
		rightLowerIKAttachment = attachment4
	}
end

local function destroyIKData()
	if not v4 then
		return
	end

	for _, v8 in pairs(v4) do
		if typeof(v8) == "Instance" then
			v8:Destroy()
		end
	end

	v4 = nil
end

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	local occupant = getOccupant(seat)
	local v8

	if occupant then
		v8 = Players:GetPlayerFromCharacter(occupant.Parent)
	end

	playerFromCharacter = v8
	destroyIKData()

	if playerFromCharacter then
		createIKData(playerFromCharacter)
	end
end)

if playerFromCharacter then
	createIKData(playerFromCharacter)
end

return PianoModule