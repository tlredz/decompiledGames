local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))

if not FlagUtil.getUserFlag("UserAllowAbilityControls") then
	return
end

local Players = game:GetService("Players")
local abilityManagerActor = nil
local humanoid = nil
local bindableEvent = Instance.new("BindableEvent")
local evaluateStateMachineChangedConnection = nil
local flag = false

local function characterAdded(character)
	abilityManagerActor = nil
	humanoid = nil

	if evaluateStateMachineChangedConnection then
		evaluateStateMachineChangedConnection:Disconnect()
		evaluateStateMachineChangedConnection = nil
	end

	if character then
		abilityManagerActor = character:FindFirstChild("AbilityManagerActor")
		humanoid = character:FindFirstChildOfClass("Humanoid")

		while not humanoid do
			character.ChildAdded:wait()
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end

		bindableEvent:Fire()
		evaluateStateMachineChangedConnection = humanoid:GetPropertyChangedSignal("EvaluateStateMachine"):Connect(function()
			bindableEvent:Fire()
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lazyInit()
	if flag then
		return
	end

	flag = true
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		localPlayer.characterAdded:Connect(characterAdded)

		if localPlayer.Character then
			characterAdded(localPlayer.Character)
		end
	end
end

local AvatarAbilitiesInterface = {}

function AvatarAbilitiesInterface.isEnabled()
	lazyInit() -- equivalent call inferred; original call site unknown
	return abilityManagerActor ~= nil and humanoid and not humanoid.EvaluateStateMachine
end

function AvatarAbilitiesInterface.GetEnabledChangedSignal()
	lazyInit() -- equivalent call inferred; original call site unknown
	return bindableEvent.Event
end

return AvatarAbilitiesInterface