local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local assets = require(ReplicatedStorage.shared.utils.assets)
local module = require("../LocalDataState")
local module2 = require("../Utility")
local v = {
	[LuminescentCavern.Enums.Keystone.Sun] = {
		AssetId = "rbxassetid://110762083423689",
		Color = Color3.fromRGB(255, 204, 0)
	},
	[LuminescentCavern.Enums.Keystone.Cliff] = {
		AssetId = "rbxassetid://99104262817364",
		Color = Color3.fromRGB(195, 195, 195)
	},
	[LuminescentCavern.Enums.Keystone.Fossil] = {
		AssetId = "rbxassetid://78700341411043",
		Color = Color3.fromRGB(146, 89, 169)
	},
	[LuminescentCavern.Enums.Keystone.Turtle] = {
		AssetId = "rbxassetid://124997546822486",
		Color = Color3.fromRGB(107, 255, 132)
	},
	[LuminescentCavern.Enums.Keystone.Volcano] = {
		AssetId = "rbxassetid://79755083047257",
		Color = Color3.fromRGB(255, 128, 1)
	},
	[LuminescentCavern.Enums.Keystone.Mushroom] = {
		AssetId = "rbxassetid://85859680308897",
		Color = Color3.fromRGB(196, 255, 147)
	},
	[LuminescentCavern.Enums.Keystone.Skull] = {
		AssetId = "rbxassetid://131489306152628",
		Color = Color3.fromRGB(255, 85, 85)
	},
	[LuminescentCavern.Enums.Keystone.Lightning] = {
		AssetId = "rbxassetid://96265977214348",
		Color = Color3.fromRGB(255, 234, 0)
	},
	[LuminescentCavern.Enums.Keystone.Snowflake] = {
		AssetId = "rbxassetid://112659437216781",
		Color = Color3.fromRGB(129, 200, 230)
	}
}
local v2 = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.Pedestal,
	Ancestors = { Workspace }
})

function v2:SetDecalTexture(p2)
	if not (p2 and v[p2]) then
		warn("Invalid or missing enumKey for pedestal: ", self.Instance:GetFullName())
		return
	end

	local v3 = v[p2]
	local assetId = v3.AssetId
	local color = v3.Color
	local decal = self.Instance:FindFirstChild("DecalPart", true):FindFirstChild("Decal")

	if not decal then
		warn("DecalPart or Decal not found in pedestal: ", self.Instance:GetFullName())
		return
	end

	decal.Texture = assetId
	decal.Color3 = color
end

function v2:AffixDupeToPedestal(p2)
	local v3 = p2 .. " Keystone"
	local clone = assets.getAsync("item", v3):WaitForChild(v3):Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	clone:PivotTo(self.Instance.DecalPart.CFrame * CFrame.Angles(90, 0, 0))
	clone.Parent = self.Instance
end

function v2:Construct()
	local UID = self.Instance:GetAttribute("UID")

	if not UID then
		warn("Pedestal missing UID: ", self.Instance:GetFullName())
		return
	end

	local v3 = module:get()
	self.EnumKey = LuminescentCavern.Functions.GetPedestalItemRequirement(UID, v3)
	self:SetDecalTexture(self.EnumKey)
	self.DataObserver = module:observe(function(p)
		local pedestalItemRequirement = LuminescentCavern.Functions.GetPedestalItemRequirement(UID, p)

		if pedestalItemRequirement ~= self.EnumKey then
			self.EnumKey = pedestalItemRequirement
			self:SetDecalTexture(self.EnumKey)
		end

		if self.Instance:IsDescendantOf(Workspace) and module2.IsKeystonePlaced(p, self.EnumKey) then
			self:AffixDupeToPedestal(LuminescentCavern.Enums.Keystone[pedestalItemRequirement])

			if self.DataObserver then
				self.DataObserver()
				self.DataObserver = nil
			end
		end
	end, true)
end

function v2:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

return v2