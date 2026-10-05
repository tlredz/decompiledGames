local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local DashServer = {}
DashServer.Id = {}

function DashServer.Hold(player)
	if player ~= nil and player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		local SHCS = player.Character:FindFirstChild("SHCS")

		if SHCS == nil then
			return
		end

		local parent = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(player.Name) or player.Character
		local CK = SHCS:GetAttribute("CK")
		local humanoidRootPart = player.Character.HumanoidRootPart
		local lookVector = humanoidRootPart.CFrame.lookVector

		if CK == "S" then
			lookVector *= -1
		end

		if CK == "A" then
			lookVector = humanoidRootPart.CFrame.rightVector * -1
		end

		if CK == "D" then
			lookVector = humanoidRootPart.CFrame.rightVector
		end

		local v2 = "Land"
		local position = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(position, createVector(0, -10, 0), raycastParams)

		if parent:FindFirstChild("Blocking") ~= nil then
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "escapeiframe"
			stringValue.Parent = parent
			DebrisModule:AddItem(stringValue, Config.BLOCK_ESCAPE_IFRAME_DURATION)
		end

		if raycastResult == nil or raycastResult.Instance == nil then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "AIRDASHASD123"
			boolValue.Parent = parent
			DebrisModule:AddItem(boolValue, Config.AIR_DASH_FLAG_DURATION)
			v2 = "Air"
		end

		EffectsEvent.ToOthersInRange(
			player,
			"dash_effect",
			humanoidRootPart,
			lookVector,
			v2 == "Air",
			Config.ResolveCustomDash(player)
		)
	end
end

function DashServer.UnHold(_) end

function DashServer.Cancel(_) end

return DashServer