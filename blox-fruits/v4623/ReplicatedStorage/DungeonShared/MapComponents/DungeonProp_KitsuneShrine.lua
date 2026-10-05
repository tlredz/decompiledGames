require(game.ReplicatedStorage.DungeonShared)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Maid = require(game.ReplicatedStorage.Util.Maid)
local RunService2 = game:GetService("RunService")
RunService2:IsClient()
require(game.ReplicatedStorage.DungeonShared.MapComponents.Util)
local Component = require(game.ReplicatedStorage.Modules.Component)
local new = Component.new
local v = {
	Tag = "DungeonProp_KitsuneShrine",
	Ancestors = { workspace.Map },
	Extensions = 0
}
local BaseMapComponent = require(script.Parent.BaseMapComponent)
v.Extensions = { BaseMapComponent }
local v2 = new(v)

function v2:Start()
	self.Maid = Maid.new()
	assert(self.Maid)

	if isServer then
		assert(self.Instance):SetAttribute("KitsuneMarkActive", false)
		local neonShrinePart = self.Instance:FindFirstChild("NeonShrinePart")

		if neonShrinePart and neonShrinePart:IsA("BasePart") then
			neonShrinePart.Color = Color3.fromRGB(27, 27, 27)
		end
	end

	assert(self.Instance)
end

function v2:Stop()
	if self.Maid then
		self.Maid:DoCleaning()
		self.Maid = nil
	end
end

function v2.ActivateKitsuneMark(p)
	print("Activating Kitsune Mark on shrine:", p.Instance and p.Instance:GetFullName())
	p.Instance:SetAttribute("KitsuneMarkActive", true)
	local neonShrinePart = p.Instance:FindFirstChild("NeonShrinePart")

	if neonShrinePart and neonShrinePart:IsA("BasePart") then
		neonShrinePart.Color = Color3.fromRGB(0, 255, 238)
	end
end

function v2.DeactivateKitsuneMark(p)
	print("Deactivating Kitsune Mark on shrine:", p.Instance and p.Instance:GetFullName())
	p.Instance:SetAttribute("KitsuneMarkActive", false)
	local neonShrinePart = p.Instance:FindFirstChild("NeonShrinePart")

	if neonShrinePart and neonShrinePart:IsA("BasePart") then
		neonShrinePart.Color = Color3.fromRGB(27, 27, 27)
	end
end

return v2