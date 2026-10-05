local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("IcePuzzle/UpdateIceState", -1)
Net:RemoteEvent("IcePuzzle/UnlockRod", -1)
local v = Component.new({
	Tag = "IcePuzzle"
})
local v2 = { 0.5, 18.128 }
local v3 = { 396.582, 405.031 }

function v:EnablePrompt()
	local promptTemplate = self.Instance:WaitForChild("Crystalized Rod"):WaitForChild("Root"):WaitForChild("PromptTemplate")
	promptTemplate.Enabled = true
end

function v:SetMelting(p2: number, value: number)
	local v4 = p2 / (value or 10)
	local v5 = v2[1]
	local v6 = v2[2]
	local v7 = v3[1]
	local v8 = v3[2]
	local v9 = v5 + (v6 - v5) * v4
	local v10 = v7 + (v8 - v7) * v4
	self.Ice.Size = Vector3.new(self.Ice.Size.X, v9, self.Ice.Size.Z)
	self.Ice.Position = Vector3.new(self.DefaultIcePosition.X, v10, self.DefaultIcePosition.Z)
end

function v:Construct()
	self.trove = Trove.new()
end

function v:Start()
	self.Vfx = self.Instance:WaitForChild("VFX")
	self.Ice = self.Instance:WaitForChild("Ice")
	self.DefaultIcePosition = self.Ice.Position
	local promptTemplate = self.Instance:WaitForChild("Crystalized Rod"):WaitForChild("Root"):WaitForChild("PromptTemplate")
	promptTemplate.Enabled = false
	local icePuzzlePass = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("IcePuzzlePass")

	if icePuzzlePass.Value ~= true then
		self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: number, p2: number)
			if icePuzzlePass.Value ~= true then
				self:SetMelting(p, p2)
				return
			end

			self:SetMelting(0, 10)
			self:EnablePrompt()
		end))
		return
	end

	self:EnablePrompt()
	self:SetMelting(0, 10)
end

function v.Stop(p)
	p.trove:Destroy()
end

return v