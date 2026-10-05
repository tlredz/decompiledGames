local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JumpHeightManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("JumpHeightManager"))
local v = workspace:FindFirstChild("Candys")
local localPlayer = Players.LocalPlayer

if not v then
	v = Instance.new("Folder")
	v.Name = "Candys"
	v.Parent = workspace
end

local overlapParams = OverlapParams.new()
overlapParams:AddToFilter(v)
overlapParams.FilterType = Enum.RaycastFilterType.Include
local folder = Instance.new("Folder")
folder.Name = "JellySounds"
folder.Parent = SoundService
local v2 = {}
local v3 = {
	BASE_DETECTION_SIZE = createVector(2.5, 5, 2.5),
	LERP_SPEED_DOWN = 20,
	LERP_SPEED_UP = 8,
	HOLD_TIME = 0.15,
	VELOCITY_PADDING = 1.2,
	SOUND_COOLDOWN = 0.03,
	MAX_PLAYABLE_SOUNDS = 5,
	SOUND_ID = "rbxassetid://97921748945256",
	PITCH_MIN = 0.85,
	PITCH_MAX = 1.15,
	MIN_SCALE = 0.3,
	BOUNCE_POWER = 80,
	BOUNCE_COOLDOWN = 0.3
}

for i = 1, 5 do
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://97921748945256"
	sound.Parent = folder
	v2[i] = sound
end

local v4 = 0
local SOUND_COOLDOWN = 0

local function playSound()
	if SOUND_COOLDOWN > 0 then
		return
	end

	SOUND_COOLDOWN = 0.03
	v4 = v4 % 5 + 1
	local v5 = v2[v4]
	v5.PlaybackSpeed = 0.85 + math.random() * 0.29999999999999993
	v5:Play()
end

local v5 = {}
local v6 = 0
local v7 = nil
RunService.RenderStepped:Connect(function(dt: number)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	if humanoid ~= v7 then
		v7 = humanoid
		JumpHeightManager.setHumanoid(humanoid)
	end

	SOUND_COOLDOWN = math.max(0, SOUND_COOLDOWN - dt)
	v6 = math.max(0, v6 - dt)
	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local v8 = createVector(2.5, 5, 2.5) + Vector3.new(
		math.abs(assemblyLinearVelocity.X) * dt * 1.2,
		0,
		math.abs(assemblyLinearVelocity.Z) * dt * 1.2
	)
	local v9 = -(humanoid.HipHeight + humanoidRootPart.Size.Y / 2)
	local v10 = humanoidRootPart.CFrame * CFrame.new(0, v9 - 1, 0)
	local partBoundsInBox = workspace:GetPartBoundsInBox(v10, v8, overlapParams)

	for _, v11 in partBoundsInBox do
		if not v5[v11] then
			v5[v11] = {
				originalSize = v11.Size,
				originalCFrame = v11.CFrame,
				scaleY = 1,
				state = "SQUISHING",
				holdTimer = 0
			}
		end
	end

	local v11 = {}
	local v12 = {}

	for k, v13 in v5 do
		if k.Parent then
			if v13.state == "SQUISHING" then
				v13.scaleY = 0.3 + (v13.scaleY - 0.3) * math.exp(-20 * dt)

				if v13.scaleY <= 0.32 then
					v13.scaleY = 0.3
					v13.state = "HOLDING"
					v13.holdTimer = 0.15

					if v6 <= 0 then
						v6 = 0.3
						JumpHeightManager.set("Bounce", 80, 100)
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						task.delay(0.1, function()
							JumpHeightManager.release("Bounce")
						end)

						if not (SOUND_COOLDOWN > 0) then
							SOUND_COOLDOWN = v3.SOUND_COOLDOWN
							v4 = v4 % v3.MAX_PLAYABLE_SOUNDS + 1
							local v14 = v2[v4]
							v14.PlaybackSpeed = v3.PITCH_MIN + math.random() * (v3.PITCH_MAX - v3.PITCH_MIN)
							v14:Play()
						end
					end
				end
			elseif v13.state == "HOLDING" then
				v13.holdTimer -= dt

				if v13.holdTimer <= 0 then
					v13.state = "RESTORING"
				end
			elseif v13.state == "RESTORING" then
				v13.scaleY = (v13.scaleY - 1) * math.exp(-8 * dt) + 1

				if v13.scaleY >= 0.99 then
					k.Size = v13.originalSize
					table.insert(v11, k)
					table.insert(v12, v13.originalCFrame)
					v5[k] = nil
					continue
				end
			end

			local Y = v13.originalSize.Y
			local v14 = Y / 2 * (v13.scaleY - 1)
			k.Size = Vector3.new(v13.originalSize.X, Y * v13.scaleY, v13.originalSize.Z)
			table.insert(v11, k)
			table.insert(v12, v13.originalCFrame + Vector3.new(0, v14, 0))
		else
			v5[k] = nil
		end
	end

	if #v11 > 0 then
		workspace:BulkMoveTo(v11, v12, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)