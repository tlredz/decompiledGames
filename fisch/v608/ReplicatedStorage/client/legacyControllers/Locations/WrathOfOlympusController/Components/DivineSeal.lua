local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("DivineSeal/ForcedBreak", -1)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local v = Component.new({
	Tag = "DivineSeal",
	Ancestors = { Workspace }
})

local function hideInstantly(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if descendant:GetAttribute("OriginalTransparency") == nil then
				descendant:SetAttribute("OriginalTransparency", descendant.Transparency)
			end

			if descendant:GetAttribute("OriginalCanCollide") == nil then
				descendant:SetAttribute("OriginalCanCollide", descendant.CanCollide)
			end

			descendant.Transparency = 1
			descendant.CanCollide = false
		elseif descendant:IsA("ParticleEmitter") then
			if descendant:GetAttribute("OriginalEnabled") == nil then
				descendant:SetAttribute("OriginalEnabled", descendant.Enabled)
			end

			descendant.Enabled = false
		end
	end
end

local function showInstantly(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if descendant:GetAttribute("OriginalTransparency") ~= nil then
				descendant.Transparency = descendant:GetAttribute("OriginalTransparency")
			end

			if descendant:GetAttribute("OriginalCanCollide") ~= nil then
				descendant.CanCollide = descendant:GetAttribute("OriginalCanCollide")
			end
		elseif descendant:IsA("ParticleEmitter") and descendant:GetAttribute("OriginalEnabled") ~= nil then
			descendant.Enabled = descendant:GetAttribute("OriginalEnabled")
		end
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.godName = self.Instance:GetAttribute("GodName")

	if typeof(self.godName) == "string" and self.godName ~= "" then
		return
	end

	warn("[DivineSeal] Missing GodName attribute:", self.Instance:GetFullName())
end

function v.Start(data)
	local v2 = false
	data.trove:Add(playerDataReplicator:Observe({ "WrathOfOlympus", "DivineSealsBroken", data.godName }, function(p, _)
		if p == true and not v2 then
			hideInstantly(data.Instance)
		elseif not p then
			showInstantly(data.Instance)
		end

		v2 = true
	end))
	data.trove:Add(remoteEvent.OnClientEvent:Connect(function(p)
		if p == data.godName then
			hideInstantly(data.Instance)
		end
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v