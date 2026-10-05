local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local maid = require3(ReplicatedStorage2.Packages.Trove).new()
local v = { "MoonMap", "ZeroGravityArena" }
local GravityController = {}

function GravityController.Start(_)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateGravity()
		maid:Destroy()
		local character = localPlayer.Character

		if character and character:IsDescendantOf(workspace.Alive) and GravityController:IsGravityEnabled() then
			GravityController:ApplyGravity()
		end
	end

	workspace:GetAttributeChangedSignal("CurrentlySelectedMap"):Connect(function()
		if #workspace.Balls:GetChildren() == 0 then
			workspace.Balls.ChildAdded:Wait()
		end

		updateGravity() -- equivalent call inferred; original call site unknown
	end)
	workspace:GetAttributeChangedSignal("ForceGravityType"):Connect(updateGravity)
	task.defer(updateGravity)
	local childAddedConnection = nil
	local childRemovedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearConnections()
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end

		if childRemovedConnection then
			childRemovedConnection:Disconnect()
			childRemovedConnection = nil
		end
	end

	workspace.Alive.ChildAdded:Connect(function(child)
		task.defer(OnCharacterAdded, child)
		local character = localPlayer.Character

		if character and child == character then
			clearConnections() -- equivalent call inferred; original call site unknown
			childAddedConnection = character.ChildAdded:Connect(function(child2)
				if child2.Name == "HellHookUser" then
					updateGravity() -- equivalent call inferred; original call site unknown
				end
			end)
			childRemovedConnection = character.ChildRemoved:Connect(function(child2)
				if child2.Name == "HellHookUser" then
					updateGravity() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end)
	workspace.Dead.ChildAdded:Connect(function(child)
		task.defer(OnCharacterRemoved, child)
		clearConnections() -- equivalent call inferred; original call site unknown
	end)
	local character = localPlayer.Character

	if character then
		OnCharacterAdded(character)
	end
end

function GravityController:IsGravityEnabled()
	if localPlayer.Character:FindFirstChild("HellHookUser") then
		return false
	end

	local adminForceGravityType = workspace:GetAttribute("AdminForceGravityType")

	if adminForceGravityType ~= nil then
		return true, adminForceGravityType
	end

	local forceGravityType = workspace:GetAttribute("ForceGravityType")

	if forceGravityType ~= nil then
		return true, forceGravityType
	end

	local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

	if table.find(v, currentlySelectedMap) then
		return true, "Low"
	end

	return false
end

function GravityController:ApplyGravity()
	local isGravityEnabled, v2 = GravityController:IsGravityEnabled()

	if not isGravityEnabled then
		return
	end

	local v3 = v2 or "Low"
	local character = localPlayer.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or character:FindFirstChild("Gravity", true) then
		return
	end

	local v4

	if v3 == "ExtraLow" then
		v4 = 0.25484199796126406
	elseif v3 == "Low" then
		v4 = 0.5
	elseif v3 == "Mid" then
		v4 = -1.529051987767584
	elseif v3 == "High" then
		v4 = -2
	else
		v4 = 1
	end

	local bodyForce = Instance.new("BodyForce")
	maid:Add(bodyForce)
	bodyForce.Name = "Gravity"
	bodyForce.Force = createVector(0, 0, 0)

	local function updateForce()
		RunService.PostSimulation:Wait()
		bodyForce.Force = createVector(0, 1, 0) * (humanoidRootPart.AssemblyMass * (workspace.Gravity * v4))
	end

	task.spawn(updateForce)
	bodyForce.Parent = humanoidRootPart
	maid:Add(humanoidRootPart:GetPropertyChangedSignal("AssemblyMass"):Connect(updateForce))
	maid:Add(character:GetAttributeChangedSignal("Dead"):Once(function()
		maid:Destroy()
	end))
end

function OnCharacterAdded(p)
	if not GravityController:IsGravityEnabled() then
		return
	end

	if p == localPlayer.Character then
		GravityController:ApplyGravity()
	end
end

function OnCharacterRemoved(p)
	local character = localPlayer.Character

	if character and p == character then
		maid:Destroy()
	end
end

return GravityController