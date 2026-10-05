local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)
local Policy = require(ReplicatedStorage.Shared.Policy)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyMachine(instance)
	instance:Destroy()

	if UseNewLobby() then
		task.spawn(function()
			local backBoard = workspace:WaitForChild("Spawn", 1000000):WaitForChild("BackBoard", 10)

			if backBoard then
				backBoard:Destroy()
			end
		end)
	end
end

return Observers.observeTag("CapsuleMachine", function(instance)
	local policyInfo = Policy:GetPolicyInfo()

	if ServerInfo.isLTMServer() or policyInfo and policyInfo.ArePaidRandomItemsRestricted then
		destroyMachine(instance) -- equivalent call inferred; original call site unknown
		return nil
	else
		local items = instance:WaitForChild("Items", 10)

		if not items then
			return nil
		end

		local parent = instance.Parent
		Replion.Client:AwaitReplion("Data", function(object)
			local function update()
				if object:GetExpect("TotalStats.Wins") >= 1 then
					instance.Parent = parent
				else
					instance.Parent = ReplicatedStorage
				end
			end

			object:OnChange("TotalStats.Wins", update)
			task.spawn(update)
		end)
		local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			items:PivotTo(items:GetPivot() * CFrame.Angles(0, dt * 0.2, 0))
		end)
		return function()
			postSimulationConnection:Disconnect()
		end
	end
end, { workspace, ReplicatedStorage })