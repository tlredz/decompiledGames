local createVector = vector.create
local RunService = game:GetService("RunService")
local v = {}

local function adjustVelocity(p)
	if p.Magnitude > 1 then
		return p.Unit
	end

	return p
end

local function check(instance)
	if v[instance] then
		return
	end

	v[instance] = {
		con = {},
		active = {
			timer = 0,
			direction = nil
		},
		animator = nil
	}
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 3)

	if not humanoidRootPart then
		return
	end

	local lowerTorso = instance:WaitForChild("LowerTorso", 3)

	if not lowerTorso then
		return
	end

	local root = lowerTorso:WaitForChild("Root", 3)

	if not root then
		return
	end

	local upperTorso = instance:WaitForChild("UpperTorso", 3)

	if not upperTorso then
		return
	end

	local humanoid = instance:WaitForChild("Humanoid", 3)

	if not humanoid then
		return
	end

	local animator = humanoid:WaitForChild("Animator", 3)

	if not (animator and v[instance] ~= nil) then
		return
	end

	v[instance].animator = animator

	local function run()
		local v2 = v[instance]

		while v2.active.timer - os.clock() > 0 and v2.active.direction and v2.animator.Parent == humanoid do
			local v3 = v2.active.timer - os.clock()
			local cFrame = humanoidRootPart.CFrame
			local v4 = cFrame - cFrame.Position
			local transform = root.Transform
			local rotation = CFrame.new(createVector(0, 0, 0), v2.active.direction).Rotation
			lowerTorso.CanCollide = false
			upperTorso.CanCollide = false

			if not (v3 < 0.01) then
				if v3 < 0.1 then
					root.Transform = (v4:inverse() * rotation * transform):Lerp(transform, 1 - v3 / 0.1)
				else
					root.Transform = v4:inverse() * rotation * transform
				end
			end

			RunService.PreSimulation:Wait()
		end

		lowerTorso.CanCollide = true
		upperTorso.CanCollide = true
		v2.active.direction = nil
	end

	table.insert(v[instance].con, humanoidRootPart:GetAttributeChangedSignal("LastDetectedPriority"):Connect(function()
		if humanoidRootPart:GetAttribute("LastDetectedKnockback") then
			if not (instance:IsDescendantOf(workspace) and instance:FindFirstChild("HumanoidRootPart") and instance:FindFirstChild("Stun") and humanoidRootPart:GetAttribute("LastDetectedTimestamp")) then
				return
			end

			if not humanoidRootPart:GetAttribute("LastDetectedDuration") then
				return
			end

			local lastDetectedVelocity = humanoidRootPart:GetAttribute("LastDetectedVelocity")
			local v2 = humanoidRootPart:GetAttribute("LastDetectedDuration") - (workspace:GetServerTimeNow() - humanoidRootPart:GetAttribute("LastDetectedTimestamp"))

			if lastDetectedVelocity.Magnitude > 1 then
				lastDetectedVelocity = lastDetectedVelocity.Unit
			end

			local direction = -lastDetectedVelocity + humanoidRootPart.CFrame.LookVector * 0.012345
			local v4 = v[instance].active.direction ~= nil
			v[instance].active.direction = direction
			v[instance].active.timer = os.clock() + v2

			if v2 > 0 and not v4 then
				task.spawn(run)
			end
		else
			v[instance].active.timer = 0
			v[instance].active.direction = nil
		end
	end))
	table.insert(v[instance].con, humanoidRootPart:GetAttributeChangedSignal("LastDetectedTimestamp"):Connect(function()
		if not (humanoidRootPart:GetAttribute("LastDetectedTimestamp") and humanoidRootPart:GetAttribute("LastDetectedDuration")) then
			return
		end

		if humanoidRootPart:GetAttribute("LastDetectedKnockback") and v[instance].active.direction then
			if not instance:FindFirstChild("Stun") then
				return
			end

			local lastDetectedVelocity = humanoidRootPart:GetAttribute("LastDetectedVelocity")
			local v2 = humanoidRootPart:GetAttribute("LastDetectedDuration") - (workspace:GetServerTimeNow() - humanoidRootPart:GetAttribute("LastDetectedTimestamp"))

			if lastDetectedVelocity.Magnitude > 1 then
				lastDetectedVelocity = lastDetectedVelocity.Unit
			end

			local direction = -lastDetectedVelocity + humanoidRootPart.CFrame.LookVector * 0.012345
			v[instance].active.direction = direction
			v[instance].active.timer = os.clock() + v2
		end
	end))
end

for _, childName in pairs({ "Characters", "Enemies" }) do
	workspace:WaitForChild(childName)
	workspace[childName].ChildAdded:Connect(function(child)
		check(child)
	end)
	workspace[childName].ChildRemoved:Connect(function(child)
		if v[child] then
			for _, connection in pairs(v[child].con) do
				connection:Disconnect()
			end
		end

		v[child] = nil
	end)

	for _, child in pairs(workspace[childName]:GetChildren()) do
		local v2 = child
		task.spawn(function()
			check(v2)
		end)
	end
end