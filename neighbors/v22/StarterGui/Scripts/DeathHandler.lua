local localPlayer = game.Players.LocalPlayer
local humanoid = localPlayer.Character:WaitForChild("Humanoid")
local VRService = game:GetService("VRService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local bindableEvent = Instance.new("BindableEvent", script)

-- equivalent calls inferred from this helper; original call sites unknown
local function handleSetStateEnabledDead(humanoid2)
	if VRService.VREnabled == true then
		humanoid2:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	else
		humanoid2:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
end

handleSetStateEnabledDead(humanoid) -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:connect(function(instance)
	handleSetStateEnabledDead(instance:WaitForChild("Humanoid")) -- equivalent call inferred; original call site unknown
end)
bindableEvent.Event:connect(function()
	return Network:fire("DoSafeReset")
end)

repeat
	local v = pcall(function()
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("ResetButtonCallback", bindableEvent)
	end)
	task.wait(1)
until v