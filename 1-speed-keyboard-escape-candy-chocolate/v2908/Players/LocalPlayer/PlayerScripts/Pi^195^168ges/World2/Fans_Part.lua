local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCharacter()
	character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	overlapParams.FilterDescendantsInstances = { character.PrimaryPart }
end

updateCharacter() -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(function()
	updateCharacter() -- equivalent call inferred; original call site unknown
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function initFans(part)
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not (part and part.Parent) then
			renderSteppedConnection:Disconnect()
			return
		end

		if not (character and humanoidRootPart) then
			return
		end

		if #workspace:GetPartsInPart(part, overlapParams) > 0 then
			local magnitude = humanoidRootPart.AssemblyLinearVelocity.Magnitude
			local lookVector = part.CFrame.LookVector
			local assemblyMass = humanoidRootPart.AssemblyMass
			local v = lookVector * ((magnitude < 148 and 15000 or 25) * assemblyMass)
			humanoidRootPart.AssemblyLinearVelocity += v / assemblyMass * dt
		end
	end)
end

for _, part in ipairs(CollectionService:GetTagged("FanEffect")) do
	if not part:IsA("BasePart") then
		continue
	end

	local renderSteppedConnection = nil
	local v = part
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not (v and v.Parent) then
			renderSteppedConnection:Disconnect()
			return
		end

		if not (character and humanoidRootPart) then
			return
		end

		if #workspace:GetPartsInPart(v, overlapParams) > 0 then
			local magnitude = humanoidRootPart.AssemblyLinearVelocity.Magnitude
			local lookVector = v.CFrame.LookVector
			local assemblyMass = humanoidRootPart.AssemblyMass
			local v2 = lookVector * ((magnitude < 148 and 15000 or 25) * assemblyMass)
			humanoidRootPart.AssemblyLinearVelocity += v2 / assemblyMass * dt
		end
	end)
end

CollectionService:GetInstanceAddedSignal("FanEffect"):Connect(function(part)
	if part:IsA("BasePart") then
		initFans(part) -- equivalent call inferred; original call site unknown
	end
end)