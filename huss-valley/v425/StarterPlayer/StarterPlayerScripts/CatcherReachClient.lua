local createVector = vector.create
local RunService = game:GetService("RunService")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ParticipantDirectory = require(chickenOrHero.Presentation:WaitForChild("ParticipantDirectory"))
local ReachPose = require(chickenOrHero.Presentation:WaitForChild("ReachPose"))
local ContactCatchConfig = require(chickenOrHero.Game:WaitForChild("ContactCatchConfig"))
local v = {}
local v2 = {}
local connections = {}
local total = 1

-- equivalent calls inferred from this helper; original call sites unknown
local function restore(state)
	if state.motor.Parent and state.applied and state.motor.Transform == state.applied then
		state.motor.Transform = state.base
	end

	state.applied = nil
end

table.insert(connections, RunService.PreAnimation:Connect(function()
	for _, v3 in v do
		restore(v3) -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, RunService.PreSimulation:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		table.clear(v2)

		for _, v3 in ParticipantDirectory.list() do
			v2[v3.UserId] = v3
			local character = v3.Character
			local torso = character and character:FindFirstChild("Torso")
			local rightShoulder = torso and torso:FindFirstChild("Right Shoulder")

			if not rightShoulder or v[character] then
				continue
			end

			v[character] = {
				character = character,
				motor = rightShoulder,
				torso = torso,
				weight = 0
			}
		end
	end

	for k, v3 in v do
		restore(v3) -- equivalent call inferred; original call site unknown

		if k.Parent and v3.motor.Parent then
			local reachTargetUserId = k:GetAttribute("ReachTargetUserId")
			local v4 = reachTargetUserId and v2[reachTargetUserId]
			local humanoidRootPart = v4 and v4.Character and v4.Character:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = k:FindFirstChild("HumanoidRootPart")
			local humanoid = k:FindFirstChildOfClass("Humanoid")

			if k:GetAttribute("DaggerEquipped") == true or not ContactCatchConfig.Enabled or not (humanoidRootPart2 and humanoid) or humanoid.Health <= 0 or humanoidRootPart2.Anchored or k:GetAttribute("MovementLocked") == true or k:GetAttribute("TackleActive") == true then
				v3.weight = 0
				v3.aim = nil
			else
				local reachPhase = k:GetAttribute("ReachPhase")
				local reachDirection = k:GetAttribute("ReachDirection")
				local v5

				if (reachPhase == "Windup" or reachPhase == "Active") and typeof(reachDirection) == "Vector3" then
					v5 = true
				elseif reachPhase == "Tracking" then
					if humanoidRootPart then
						if v4:GetAttribute("GameRole") == "Runner" and v4:GetAttribute("RunState") == "Active" then
							v5 = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= ContactCatchConfig.ReachDistance + 2
						else
							v5 = false
						end
					else
						v5 = humanoidRootPart
					end
				else
					v5 = false
				end

				local v6 = not v5 and 0 or reachPhase == "Tracking" and ContactCatchConfig.TrackingWeight or reachPhase == "Windup" and ContactCatchConfig.WindupWeight or 1
				v3.weight += (v6 - v3.weight) * (1 - math.exp(-ContactCatchConfig.ReachFadeRate * math.min(dt, 0.1)))

				if v5 then
					v3.aim = reachPhase == "Tracking" and humanoidRootPart.Position + createVector(0, 0.25, 0) or humanoidRootPart2.Position + reachDirection * 8 + createVector(
						0,
						0.25,
						0
					)
				end

				if not (v3.weight < 0.001) and v3.aim then
					local cFrame = v3.torso.CFrame
					local rootJoint = humanoidRootPart2:FindFirstChild("RootJoint")

					if rootJoint then
						cFrame = humanoidRootPart2.CFrame * rootJoint.C0 * rootJoint.Transform * rootJoint.C1:Inverse()
					end

					v3.base = v3.motor.Transform
					local transformed = ReachPose.transform(cFrame, v3.motor, v3.aim, v3.base)

					if v3.pose then
						transformed = v3.pose:Lerp(transformed, 1 - math.exp(math.min(dt, 0.1) * -26)) or transformed
					end

					v3.pose = transformed
					v3.applied = v3.base:Lerp(v3.pose, v3.weight)
					v3.motor.Transform = v3.applied
				end
			end
		else
			v[k] = nil
		end
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	for _, v3 in v do
		restore(v3) -- equivalent call inferred; original call site unknown
	end

	table.clear(v)
end)