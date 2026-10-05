local createVector = vector.create
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
local _ = {
	CHASE_SPEED = 100,
	RETURN_SPEED = 50,
	DETECTION_RANGE_SQ = 4000000,
	STOP_DISTANCE = 12,
	UPDATE_RATE = 0.03,
	PHYSICS_WALL = 350,
	ID_WALK = "rbxassetid://180426354",
	ID_IDLE = "rbxassetid://180435571"
}
print("start!!!!")
local nPC_LolMonster = ReplicatedStorage:WaitForChild("NPC_LolMonster", 10)

if not nPC_LolMonster then
	return
end

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://180426354"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://180435571"
local pivot = nPC_LolMonster:GetPivot()
task.spawn(function()
	ContentProvider:PreloadAsync({ animation, animation2, nPC_LolMonster })
end)
local v = {}

local function startNPCLogic(instance, _)
	if v[instance] then
		return
	end

	v[instance] = true
	local clone = nPC_LolMonster:Clone()
	clone:PivotTo(pivot)
	clone.Parent = workspace
	local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
	local humanoid = clone:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local hitbox = clone:WaitForChild("Hitbox")
	local chaseMusic = humanoidRootPart:WaitForChild("ChaseMusic")
	humanoidRootPart.Anchored = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	local track = animator:LoadAnimation(animation)
	local track2 = animator:LoadAnimation(animation2)
	local v2 = "Idle"
	track2:Play()
	local touchedConnection = hitbox.Touched:Connect(function(otherPart)
		if otherPart.Parent == localPlayer.Character then
			local humanoid2 = otherPart.Parent:FindFirstChildOfClass("Humanoid")

			if humanoid2 and humanoid2.Health > 0 then
				humanoid2.Health = 0
			end
		end
	end)
	task.spawn(function()
		while clone.Parent and instance.Parent do
			local character = localPlayer.Character
			local humanoidRootPart2

			if character then
				humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
			end

			local position = humanoidRootPart.Position
			local v3 = not humanoidRootPart2 and createVector(0, -5000, 0) or humanoidRootPart2.Position or createVector(
				0,
				-5000,
				0
			)
			local vector2 = v3 - position
			local dot = vector2:Dot(vector2)
			local v4 = math.sqrt(dot)
			local vector3 = (position - pivot.Position) * createVector(1, 0, 1)
			local dot2 = vector3:Dot(vector3)

			if position.Y < pivot.Y - 50 then
				clone:PivotTo(pivot)
			end

			local pointToObjectSpace = instance.CFrame:PointToObjectSpace(v3)
			local v6 = math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2 and dot < 4000000 and "Chasing" or dot2 > 144 and "Returning" or "Idle"

			if v6 ~= v2 then
				if v6 == "Chasing" or v6 == "Returning" then
					humanoidRootPart.Anchored = false
					humanoid.WalkSpeed = v6 == "Chasing" and 100 or 50

					if not chaseMusic.IsPlaying then
						chaseMusic:Play()
					end

					track:Play()
					track2:Stop()
				elseif v6 == "Idle" then
					humanoidRootPart.Anchored = true
					humanoid:Move(createVector(0, 0, 0))
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

					if chaseMusic.IsPlaying then
						chaseMusic:Stop()
					end

					track:Stop(0.1)
					track2:Play()
					clone:PivotTo(pivot)
				end

				v2 = v6
			end

			if v2 == "Chasing" and humanoidRootPart2 then
				if v4 > 350 then
					humanoidRootPart.Anchored = true
					local unit = (v3 - position).Unit
					clone:PivotTo(CFrame.lookAt(position + unit * 100 * 0.03, v3))
				else
					humanoidRootPart.Anchored = false
					humanoid:MoveTo(humanoidRootPart2.Position)
				end
			elseif v2 == "Returning" then
				if v4 > 350 then
					humanoidRootPart.Anchored = true
					local unit = (pivot.Position - position).Unit
					clone:PivotTo(CFrame.lookAt(position + unit * 50 * 0.03, pivot.Position))
				else
					humanoidRootPart.Anchored = false
					humanoid:MoveTo(pivot.Position)
				end
			end

			task.wait(0.03)
		end

		touchedConnection:Disconnect()
		v[instance] = nil
		clone:Destroy()
	end)
end

local function onZoneDetected(p)
	startNPCLogic(p, p)
end

CollectionService:GetInstanceAddedSignal("LolMonster_AttackZone"):Connect(onZoneDetected)

for _, v2 in ipairs(CollectionService:GetTagged("LolMonster_AttackZone")) do
	task.spawn(onZoneDetected, v2)
end