local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local DoubleJumpServer = {}
DoubleJumpServer.Id = {}

function DoubleJumpServer.Hold(player)
	if player ~= nil and player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		if player.Character:FindFirstChild("SHCS") == nil then
			return
		end

		local parent = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(player.Name) or player.Character
		local humanoidRootPart = player.Character.HumanoidRootPart
		local upVector = humanoidRootPart.CFrame.UpVector

		if parent:FindFirstChild("Blocking") ~= nil then
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "escapeiframe"
			stringValue.Parent = parent
			DebrisModule:AddItem(stringValue, 0.125)
		end

		EffectsEvent.ToOthersInRange(player, "Double_Jump_Effect", humanoidRootPart, upVector)
	end
end

function DoubleJumpServer.UnHold(_) end

function DoubleJumpServer.Cancel(_) end

return DoubleJumpServer