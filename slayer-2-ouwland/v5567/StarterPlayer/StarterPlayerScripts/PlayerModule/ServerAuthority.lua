local ServerAuthority = {}
ServerAuthority.__index = ServerAuthority
local ControlModule = require(script.Parent:WaitForChild("ControlModule"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local playerModuleEventBus = CommonUtils.get("PlayerModuleEventBus")
local userFlag = flagUtil.getUserFlag("UserDisableForceLocalHumanoidPrediction")
local _ = {
	SERVER_AUTHORITY_CHANGED = "SERVER_AUTHORITY_CHANGED",
	INPUTS_SETUP = "INPUTS_SETUP"
}
local isServerAuthority = false

function ServerAuthority.PredictLocalHumanoid()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onCharacterAdded(character)
		RunService:SetPredictionMode(character:WaitForChild("HumanoidRootPart"), Enum.PredictionMode.On)
	end

	if not Players.LocalPlayer.Character then
		Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
		return
	end

	onCharacterAdded(Players.LocalPlayer.Character) -- equivalent call inferred; original call site unknown
end

function ServerAuthority:initialize()
	self.isServerAuthority = isServerAuthority
end

function ServerAuthority.Initialize()
	if not userFlag and RunService:IsClient() then
		ServerAuthority.PredictLocalHumanoid()
	end

	if not playerModuleEventBus.data.inputsSetupComplete and RunService:IsServer() then
		playerModuleEventBus:subscribe("INPUTS_SETUP"):Wait()
	end

	ControlModule:InitializeServerAuthority()
	isServerAuthority = true
end

return ServerAuthority