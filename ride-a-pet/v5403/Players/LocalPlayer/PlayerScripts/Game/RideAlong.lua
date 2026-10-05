local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local rideAlong = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("RideAlong", 20)
local ride = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Prompts"):FindFirstChild("Ride")
local v = {}
local v2 = {}

local function IsFriend(p)
	if p == localPlayer then
		return false
	end

	if localPlayer.UserId < 0 or p.UserId < 0 then
		return true
	end

	local v3 = v2[p.UserId]

	if v3 and os.clock() - v3.Time < 60 then
		return v3.Value
	end

	local success, result = pcall(function()
		return localPlayer:IsFriendsWith(p.UserId)
	end)
	local v4 = success and result == true
	v2[p.UserId] = {
		Value = v4,
		Time = os.clock()
	}
	return v4
end

local function RiddenSeatOf(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint:IsA("Motor6D") and petMountJoint.Part1
	return part1, part1 and part1.Parent or nil
end

local function ReachFor(instance)
	local maxActivationDistance = ride and ride:IsA("ProximityPrompt") and ride.MaxActivationDistance or 15
	local instanceModel = instance and instance:FindFirstAncestorOfClass("Model")

	if not instanceModel then
		return maxActivationDistance
	end

	local success, result = pcall(function()
		return instanceModel:GetExtentsSize()
	end)

	if success then
		return (math.min(40, maxActivationDistance + result.Magnitude / 2))
	end

	return maxActivationDistance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemovePrompt(p)
	local v3 = v[p]

	if v3 then
		v[p] = nil
		v3:Destroy()
	end
end

local function AddPrompt(p, part1)
	if v[p] then
		return
	end

	local v3

	if ride and ride:IsA("ProximityPrompt") then
		v3 = ride:Clone()
	else
		v3 = Instance.new("ProximityPrompt")
		v3.HoldDuration = 0.5
		v3.MaxActivationDistance = 15
	end

	v3.Name = "RideAlongPrompt"
	v3.ActionText = "Ride"
	v3.ObjectText = p.DisplayName .. "'s Pet"
	v3.RequiresLineOfSight = false
	v3.MaxActivationDistance = ReachFor(part1)
	v3.Enabled = true
	v3.Parent = part1
	v3.Triggered:Connect(function(player)
		if player == localPlayer and rideAlong then
			rideAlong:FireServer(p)
		end
	end)
	v[p] = v3
end

local function Refresh()
	local v3 = localPlayer:GetAttribute("IsRiding") == true or localPlayer:GetAttribute("IsPassenger") == true

	for _, v4 in Players:GetPlayers() do
		if v4 == localPlayer then
			continue
		end

		local character = v4.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
		local part1 = petMountJoint and petMountJoint:IsA("Motor6D") and petMountJoint.Part1
		local parent = part1 and part1.Parent or nil
		local v5

		if parent then
			v5 = (parent:GetAttribute("PassengerCount") or 0) >= (parent:GetAttribute("MaxPassengers") or 1)
		else
			v5 = false
		end

		local v6 = not v3

		if v6 then
			if part1 == nil then
				v6 = false
			else
				v6 = not v5 and IsFriend(v4)
			end
		end

		if v6 then
			local v7 = v[v4]
			local v8 = v7 and v7.Parent ~= part1 and v[v4]

			if v8 then
				v[v4] = nil
				v8:Destroy()
			end

			AddPrompt(v4, part1)
			local v9 = v[v4]

			if v9 then
				local maxActivationDistance = ReachFor(part1)

				if v9.MaxActivationDistance ~= maxActivationDistance then
					v9.MaxActivationDistance = maxActivationDistance
				end
			end
		else
			RemovePrompt(v4) -- equivalent call inferred; original call site unknown
		end
	end
end

Players.PlayerRemoving:Connect(RemovePrompt)
localPlayer:GetAttributeChangedSignal("IsRiding"):Connect(Refresh)
localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(Refresh)
task.spawn(function()
	while true do
		local success, result = pcall(Refresh)

		if not success then
			warn("[RideAlong] " .. tostring(result))
		end

		task.wait(0.5)
	end
end)