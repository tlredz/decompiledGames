local Players = game:GetService("Players")
game:GetService("UserInputService")
game:GetService("ContextActionService")
game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local LocalVehicleSeating = {
	OnExitFunctions = {}
}
local parent = script.Parent.Parent
parent:WaitForChild("Animations")
local remotes = parent.Remotes
local exitSeat = remotes:WaitForChild("ExitSeat")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getLocalHumanoid()
	if localPlayer.Character then
		return localPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

function LocalVehicleSeating.ExitSeat()
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if not localHumanoid then
		return false
	end

	local parent2 = localHumanoid.Parent

	if parent2.Humanoid.Sit == true then
		for _, v2 in ipairs(parent2.HumanoidRootPart:GetJoints()) do
			if v2.Name ~= "SeatWeld" then
				continue
			end

			local promptLocation = v2.Part0:FindFirstChild("PromptLocation")

			if not promptLocation then
				continue
			end

			local proximityPrompt = promptLocation:FindFirstChildWhichIsA("ProximityPrompt")

			if not (proximityPrompt and proximityPrompt.Name == "EndorsedVehicleProximityPromptV1") then
				continue
			end

			for _, onExitFunction in pairs(LocalVehicleSeating.OnExitFunctions) do
				onExitFunction(v2.Part0)
			end

			exitSeat:FireServer()

			for _, v3 in pairs(v) do
				v3:Stop()
			end

			return true
		end
	end
end

function LocalVehicleSeating.OnSeatExitEvent(p)
	table.insert(LocalVehicleSeating.OnExitFunctions, p)
end

function LocalVehicleSeating.DisconnectFromSeatExitEvent(p)
	local onExitFunctions = {}

	for _, onExitFunction in ipairs(LocalVehicleSeating.OnExitFunctions) do
		if onExitFunction ~= p then
			table.insert(onExitFunctions, onExitFunction)
		end
	end

	LocalVehicleSeating.OnExitFunctions = onExitFunctions
end

-- equivalent calls inferred from this helper; original call sites unknown
local function antiTrip()
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if localHumanoid then
		localHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

remotes.ExitSeat.OnClientEvent:Connect(function(p)
	for _, onExitFunction in pairs(LocalVehicleSeating.OnExitFunctions) do
		onExitFunction(nil)
	end

	if p then
		antiTrip() -- equivalent call inferred; original call site unknown
	end
end)
return LocalVehicleSeating