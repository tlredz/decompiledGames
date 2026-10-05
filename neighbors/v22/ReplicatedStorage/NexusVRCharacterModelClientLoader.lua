local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local nexusVRCharacterModel = ReplicatedStorage:WaitForChild("NexusVRCharacterModel")
local NexusBufferedReplication = require(nexusVRCharacterModel:WaitForChild("Packages"):WaitForChild("NexusBufferedReplication"))
local CameraService = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("CameraService"))
local instance = CameraService.GetInstance()
local CharacterService = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("CharacterService"))
local instance2 = CharacterService.GetInstance()
local ControlService = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("ControlService"))
local instance3 = ControlService.GetInstance()
local DefaultCursorService = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("DefaultCursorService"))
local instance4 = DefaultCursorService.GetInstance()
local EnigmaService = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("EnigmaService"))
local instance5 = EnigmaService.GetInstance()
local Settings = require(nexusVRCharacterModel:WaitForChild("State"):WaitForChild("Settings"))
local instance6 = Settings.GetInstance()
local BufferProtocol = require(nexusVRCharacterModel:WaitForChild("Util"):WaitForChild("BufferProtocol"))
local updateInputs = nexusVRCharacterModel:WaitForChild("UpdateInputs")
local replicationReady = nexusVRCharacterModel:WaitForChild("ReplicationReady")
local playerBufferedRemoteEventReceiver = NexusBufferedReplication.Receiver.PlayerBufferedRemoteEventReceiver
local NexusVRCore = require(ReplicatedStorage:WaitForChild("NexusVRCore"))
local baseScreenGui = NexusVRCore.BaseScreenGui

if baseScreenGui then
	local __new = baseScreenGui.__new

	function baseScreenGui.__new(...)
		warn([[
Using the bundled (automically loaded) Nexus VR Core with Nexus VR Character Model is deprecated.
It is recommended to move to a fixed version, which can be downloaded from GitHub.]])
		return __new(...)
	end
end

instance6:SetDefaults(HttpService:JSONDecode(nexusVRCharacterModel:WaitForChild("Configuration").Value))
local v = {}
playerBufferedRemoteEventReceiver.new(updateInputs, function(p)
	return BufferProtocol.Deserialize(p)
end):OnDataReceived(function(p, data)
	if p == Players.LocalPlayer then
		return
	end

	local updateTime = data.UpdateTime

	if updateTime then
		if v[p] and updateTime < v[p] then
			return
		else
			v[p] = updateTime
		end
	end

	local character = instance2:GetCharacter(p)

	if character then
		character:UpdateFromInputs(data.HeadCFrame, data.LeftHandCFrame, data.RightHandCFrame, data.CurrentWalkspeed, {
			LeftFoot = data.LeftFootCFrame,
			RightFoot = data.RightFootCFrame
		})
	end
end)
Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
end)
replicationReady:FireServer()
RunService.Stepped:Connect(function()
	instance2:RefreshAllCharacters()
end)
local v2 = false
UserInputService.InputBegan:Connect(function(input)
	if not v2 and input.KeyCode == Enum.KeyCode.F9 and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) and instance6:GetSetting("Output.AllowClientToOutputLoadedMessage") ~= false then
		v2 = true
		print((`Nexus VR Character Model version {instance6:GetSetting("Version.Tag")} ({instance6:GetSetting("Version.Commit")}) is loaded.`))
	end
end)

while not UserInputService.VREnabled do
	UserInputService:GetPropertyChangedSignal("VREnabled"):Wait()
	warn("VR was detected later than when Nexus VR Character Model loaded. This may be a Roblox bug.")
end

task.spawn(function()
	for _ = 1, 600 do
		if pcall(function()
			StarterGui:SetCore("VREnableControllerModels", false)
			instance4:SetCursorState("Detect")
		end) then
			break
		else
			task.wait(0.1)
		end
	end
end)
local character = Players.LocalPlayer.Character

while not character do
	character = Players.LocalPlayer.CharacterAdded:Wait()
end

if character:WaitForChild("Humanoid").RigType == Enum.HumanoidRigType.R6 then
	local R6Message = require(nexusVRCharacterModel:WaitForChild("UI"):WaitForChild("R6Message"))
	R6Message.new():Open()
else
	instance3:SetActiveController(instance6:GetSetting("Movement.DefaultMovementMethod"))
	instance:SetActiveCamera(instance6:GetSetting("Camera.DefaultCameraOption"))
	local MainMenu = require(nexusVRCharacterModel:WaitForChild("UI"):WaitForChild("MainMenu"))
	MainMenu.GetInstance():SetUpOpening()

	if instance6:GetSetting("Extra.NexusVRBackpackEnabled") ~= false then
		task.defer(function()
			local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))
			NexusVRBackpack:Load()
		end)
	end

	if instance6:GetSetting("Extra.EnigmaEnabled") ~= false then
		instance5:Enable()
	end

	RunService:BindToRenderStep("NexusVRCharacterModelUpdate", Enum.RenderPriority.Camera.Value - 1, function()
		instance3:UpdateCharacter()
	end)

	if instance6:GetSetting("DisableFadeOutViewOnCollision") == true then
		VRService.FadeOutViewOnCollision = false
	end
end