local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "Teleport",
	Ancestors = { workspace }
})
local remoteFunction = Net:RemoteFunction("RequestTeleportCFrame")

function v:Request()
	local v2 = remoteFunction:InvokeServer(self.Instance.Name)

	if v2 then
		CutsceneController:Fade(2, 0.1, 0.1, self.Instance:GetAttribute("FadeColor"))
		task.wait(1)
		PlayerController:SetCFrame(v2 + createVector(0, 2.5, 0))
	end
end

function v:Construct()
	self.type = self.Instance:GetAttribute("Type") or "Touched"
	self.trove = Trove.new()
end

function v:Start()
	if self.type == "Touched" then
		self.trove:Add(self.Instance.Touched:Connect(function(otherPart)
			if otherPart.Name ~= "HumanoidRootPart" then
				return
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if not (playerFromCharacter and playerFromCharacter == localPlayer) then
				return
			end

			self:Request()
		end))
	elseif self.type == "Trigger" then
		self.trove:Add(self.Instance:FindFirstChildOfClass("ProximityPrompt").Triggered:Connect(function()
			self:Request()
		end))
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v