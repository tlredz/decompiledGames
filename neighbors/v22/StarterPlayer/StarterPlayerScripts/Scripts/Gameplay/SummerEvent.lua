local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
game:GetService("CollectionService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local PlayerStates = require(game.ReplicatedStorage.Modules.PlayerStates)
local eventObjects = workspace:WaitForChild("PlacePrefab"):WaitForChild("Prefab"):WaitForChild("EventObjects")
local eventPaths = workspace:WaitForChild("PlacePrefab"):WaitForChild("Prefab"):WaitForChild("EventPaths")
local PlayerModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local activeChangedConnection = nil
local child = nil
local GetQuestObject

GetQuestObject = function()
	local summerQuestStage = localPlayer:GetAttribute("SummerQuestStage")
	local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")

	if summerQuestStage == 5 or summerQuestStage == 6 then
		return
	end

	if not currentInternalMap then
		repeat
			task.wait(1)
			currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")
		until currentInternalMap
	end

	local child2 = workspace.Places:FindFirstChild(currentInternalMap).Structure.EventInteraction:FindFirstChild((tostring(summerQuestStage - 1)))

	if child2 and child2.PrimaryPart:FindFirstChild("EventPrompt") then
		child2.PrimaryPart.EventPrompt.Enabled = false
	end

	child = workspace.Places:FindFirstChild(currentInternalMap).Structure.EventInteraction:FindFirstChild((tostring(summerQuestStage)))

	if not child then
		GetQuestObject()
	end
end

localPlayer:GetAttributeChangedSignal("SummerQuestStage"):Connect(function()
	if localPlayer:GetAttribute("SummerQuestStage") == 1 then
		return
	end

	controls:Enable()

	if activeChangedConnection then
		activeChangedConnection:Disconnect()
	end

	local instance = eventObjects:FindFirstChild((tostring(localPlayer:GetAttribute("SummerQuestStage") - 1)))
	local summerQuestStage = localPlayer:GetAttribute("SummerQuestStage")
	local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")

	if summerQuestStage ~= 6 then
		if not currentInternalMap then
			repeat
				task.wait(1)
				currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")
			until currentInternalMap
		end

		local child2 = workspace.Places:FindFirstChild(currentInternalMap).Structure.EventInteraction:FindFirstChild((tostring(summerQuestStage - 1)))

		if child2 and child2.PrimaryPart then
			local eventPrompt = child2.PrimaryPart:FindFirstChild("EventPrompt")

			if eventPrompt then
				eventPrompt.Enabled = false
			end
		end
	end

	if instance then
		if instance:IsA("MeshPart") then
			instance.Transparency = 1
		end

		if instance:IsA("Model") then
			for _, child2 in instance:GetChildren() do
				child2.Transparency = 1
			end
		end
	end
end)

local function TogglePrompt()
	local eventPrompt = child.PrimaryPart:FindFirstChild("EventPrompt")

	if not child:GetAttribute("Active") and localPlayer:GetAttribute("SummerQuestStage") == localPlayer:GetAttribute("LastSummerPrompt") then
		eventPrompt.Enabled = true
	end

	activeChangedConnection = child:GetAttributeChangedSignal("Active"):Connect(function()
		if child:GetAttribute("Active") == false then
			if not child:GetAttribute("Active") then
				eventPrompt.Enabled = true
			end
		else
			if localPlayer:GetAttribute("SummerQuestStage") == 3 or localPlayer:GetAttribute("SummerQuestStage") == 4 then
				return
			end

			eventPrompt.Enabled = false
		end
	end)

	if child.Name ~= "3" and child.Name ~= "4" then
		eventPrompt.Triggered:Connect(function()
			if localPlayer:GetAttribute("SummerQuestStage") ~= localPlayer:GetAttribute("LastSummerPrompt") or child:GetAttribute("Active") then
				return
			end

			controls:Disable()
			Network:fire("SummerQuest", child.Name)
		end)
		return
	end

	eventPrompt.ActionText = child.Name == "3" and "Lift (Hold)" or "Dig (Hold)"
	eventPrompt.ObjectText = child.Name == "3" and "Lift (Hold)" or "Dig (Hold)"

	if child.Name == "3" then
		eventPrompt.HoldDuration = 10
	end

	if child.Name == "4" then
		eventPrompt.HoldDuration = 15
	end

	eventPrompt.PromptButtonHoldEnded:Connect(function()
		controls:Enable()
		Network:fire("SummerQuest", child.Name, true)
	end)
	eventPrompt.PromptButtonHoldBegan:Connect(function()
		if localPlayer:GetAttribute("SummerQuestStage") ~= localPlayer:GetAttribute("LastSummerPrompt") or child:GetAttribute("Active") then
			return
		end

		controls:Disable()
		Network:fire("SummerQuest", child.Name)
	end)
end

local stateChangedConnection = nil
stateChangedConnection = localPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if localPlayer:GetAttribute("SummerQuestStage") == 5 or localPlayer:GetAttribute("SummerQuestStage") == 6 then
		if stateChangedConnection then
			stateChangedConnection:Disconnect()
		end
	else
		controls:Enable()

		if localPlayer:GetAttribute("State") == PlayerStates.Matched then
			if activeChangedConnection then
				activeChangedConnection:Disconnect()
			end

			GetQuestObject()
			TogglePrompt()
		end
	end
end)
local SetPathTrail

SetPathTrail = function(p, enabled)
	if eventPaths:FindFirstChild((tostring(p))) then
		for _, child2 in eventPaths:FindFirstChild((tostring(p))):GetChildren() do
			for _, emitter in child2:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = enabled
				end
			end
		end
	end

	if eventPaths:FindFirstChild((tostring(p - 1))) then
		SetPathTrail(p - 1, false)
	end
end

Network:listen("ToggleSummerPrompt", function()
	SetPathTrail(localPlayer:GetAttribute("SummerQuestStage"), true)

	if localPlayer:GetAttribute("SummerQuestStage") == 6 or localPlayer:GetAttribute("SummerQuestStage") == 5 then
		script.Success:Play()
		local instance = eventObjects:FindFirstChild((tostring(localPlayer:GetAttribute("SummerQuestStage") - 1)))

		if instance then
			if instance:IsA("MeshPart") or instance:IsA("BasePart") or instance:IsA("Part") then
				instance.Transparency = 1
			end

			if instance:IsA("Model") then
				for _, child2 in instance:GetChildren() do
					child2.Transparency = 1
				end
			end
		end
	else
		GetQuestObject()

		if child and child:FindFirstChild("EventPrompt") then
			child.PrimaryPart.EventPrompt.Enabled = false
		end

		if not child:GetAttribute("Active") and child:FindFirstChild("EventPrompt") then
			child.PrimaryPart.EventPrompt.Enabled = true
		end

		TogglePrompt()
		local instance = eventObjects:FindFirstChild((tostring(localPlayer:GetAttribute("SummerQuestStage"))))

		if instance then
			if instance:IsA("MeshPart") then
				instance.Transparency = 0
			end

			if instance:IsA("Model") then
				for _, child2 in instance:GetChildren() do
					child2.Transparency = 0
				end
			end
		end
	end
end)