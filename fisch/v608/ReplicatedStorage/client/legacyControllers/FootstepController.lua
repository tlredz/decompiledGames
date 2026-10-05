local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Trove = require(ReplicatedStorage.packages.Trove)
local localPlayer = Players.LocalPlayer
local FootstepController = {}
local maid = Trove.new()
local parent = workspace:FindFirstChild("footsteps")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "footsteps"
	parent.Parent = workspace
end

local v2 = 0

local function isColorInSandRange(p)
	local HSV, v3, v4 = p:ToHSV()
	local v5 = HSV * 360
	return v5 >= 25 and v5 <= 75 and v3 >= 0.1 and v3 <= 0.5 and v4 >= 0.6862745098039216 and v4 <= 1
end

local function shouldTriggerFootstep(instance)
	if CollectionService:HasTag(instance, "Sand") then
		return true
	end

	if instance.Material == Enum.Material.Sand then
		local HSV, v4, v5 = instance.Color:ToHSV()
		local v6 = HSV * 360

		if v6 >= 25 and v6 <= 75 and v4 >= 0.1 and v4 <= 0.5 and v5 >= 0.6862745098039216 then
			return v5 <= 1
		else
			return false
		end
	else
		return false
	end
end

local function cleanupOldest()
	if v2 < 20 then
		return
	end

	local v3 = parent:GetChildren()[1]

	if v3 then
		v3:Destroy()
	end
end

local function createFootstep(position, p)
	local v3 = not (v2 < 20) and parent:GetChildren()[1]

	if v3 then
		v3:Destroy()
	end

	local part = Instance.new("Part")
	part.Name = "Footstep"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1.1, 0.05, 1.1)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(p), 0)
	part.Parent = parent
	v2 += 1
	part.Destroying:Connect(function()
		v2 -= 1
	end)
	local decal = Instance.new("Decal")
	decal.Texture = "rbxassetid://123797072490722"
	decal.Face = Enum.NormalId.Top
	decal.Transparency = 0.6
	decal.Parent = part
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://95464558086837"
	sound.Volume = 0.5
	sound.RollOffMaxDistance = 30
	sound.Parent = part
	sound:Play()
	TweenService:Create(decal, TweenInfo.new(3, Enum.EasingStyle.Linear), {
		Transparency = 1
	}):Play()
	Debris:AddItem(part, 3)
end

function FootstepController:AttachCharacter(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local v3 = 0
	local v4 = nil
	local v5 = true
	maid:Clean()
	maid:Add(RunService.Heartbeat:Connect(function()
		if not instance.Parent then
			return
		end

		local v6 = humanoid.WalkSpeed / 16
		local v7

		if humanoidRootPart.AssemblyLinearVelocity.Magnitude > 2 then
			v7 = humanoid.MoveDirection.Magnitude > 0.1
		else
			v7 = false
		end

		if not v7 then
			v4 = nil
			return
		end

		v4 = v4 or tick()

		if tick() - v4 < 0.25 / v6 then
			return
		end

		local now = tick()

		if now - v3 < 0.32 / v6 then
			return
		end

		v3 = now
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude <= 0 then
			return
		end

		local v8 = humanoidRootPart.CFrame.RightVector * (v5 and -0.65 or 0.65)
		v5 = not v5
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { instance }
		local raycastResult = workspace:Raycast(humanoidRootPart.Position + v8, createVector(0, -6, 0), raycastParams)

		if not raycastResult then
			return
		end

		local instance2 = raycastResult.Instance
		local v9

		if CollectionService:HasTag(instance2, "Sand") then
			v9 = true
		elseif instance2.Material == Enum.Material.Sand then
			local HSV, v10, v11 = instance2.Color:ToHSV()
			local v12 = HSV * 360

			if v12 >= 25 and v12 <= 75 and v10 >= 0.1 and v10 <= 0.5 and v11 >= 0.6862745098039216 then
				v9 = v11 <= 1
			else
				v9 = false
			end
		else
			v9 = false
		end

		if not v9 then
			return
		end

		local v10 = math.deg((math.atan2(-moveDirection.X, -moveDirection.Z)))
		createFootstep(raycastResult.Position + createVector(0, 0.01, 0), v10)
	end))
end

function FootstepController:Start()
	if localPlayer.Character then
		self:AttachCharacter(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(function(character)
		self:AttachCharacter(character)
	end)
end

return FootstepController