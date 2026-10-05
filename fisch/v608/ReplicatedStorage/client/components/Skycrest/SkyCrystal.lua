local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
local SharedIdolFavor = require(ReplicatedStorage.shared.modules.SharedIdolFavor)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local v = {
	0,
	3,
	5,
	8,
	12,
	15,
	20,
	30,
	40,
	50
}
local v2 = {
	"Lighthouse Sky Crystal",
	"Aquatic Sky Crystal",
	"Campfire Sky Crystal",
	"Icy Sky Crystal",
	"Skull Sky Crystal",
	"Living Sky Crystal",
	"Mountain Sky Crystal",
	"Prismatic Sky Crystal",
	"Divine Sky Crystal",
	"Infernal Sky Crystal"
}
local v3 = Component.new({
	Tag = "SkyCrystal",
	Ancestors = { workspace }
})
Random.new()

function v3:Construct()
	self.Trove = Trove.new()
	self.Active = false
	self.Root = self.Instance:WaitForChild("Root")
	self.CrystalId = self.Instance:GetAttribute("CrystalId")
	self.Prompt = self.Instance:FindFirstChildWhichIsA("ProximityPrompt")
	self.IsPlacedModel = self.Instance:GetAttribute("PlacedModel")
end

function v3:Update()
	local active = false
	local v5 = DataController.PlayerDataReplicator:TryIndex({ "Skycrest", "SkyCrystalsPlaced" })
	local enabled

	if v5 then
		if self.IsPlacedModel then
			active = v5[self.CrystalId]
			enabled = DataController.HasItem(v2[self.CrystalId], nil, true)
		else
			active = not v5[self.CrystalId]

			if active then
				if SharedIdolFavor.GetLevel(localPlayer) >= v[self.CrystalId] then
					active = not DataController.HasItem(v2[self.CrystalId], nil, true)
				else
					active = false
				end
			end

			enabled = active
		end
	else
		enabled = false
	end

	self.Active = active

	for _, v7 in self.Instance:QueryDescendants("BasePart, Decal, ParticleEmitter, Beam") do
		v7.LocalTransparencyModifier = active and 0 or 1
	end

	if self.Prompt then
		self.Prompt.Enabled = enabled
	end
end

function v3.RenderSteppedUpdate(data, p: number)
	if data.Active and not data.IsPlacedModel then
		data.Root.CFrame *= CFrame.fromOrientation(0, p * 0.7853981633974483, 0)
	end
end

function v3:Start()
	DataController.PlayerDataReplicator:WaitForLoaded()
	self.Trove:Add(DataController.PlayerDataReplicator:Listen({ "Skycrest", "SkyCrystalsPlaced" }, function()
		self:Update()
	end))
	self.Trove:Add(DataController.PlayerDataReplicator:Listen({ "Skycrest", "Favor", "Level" }, function()
		self:Update()
	end))
	self.Trove:Add(DataController.InventoryReplicator:ListenKeys({ "Inventory" }, function(_, p)
		if p and p.name == v2[self.CrystalId] then
			self:Update()
		end
	end))
	self:Update()
end

function v3.Stop(p)
	p.Trove:Clean()
end

return v3