local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetDisplayText = require(ReplicatedStorage.Shared.Modules.AssetDisplayText)
local AssetInfoBillboard = require(ReplicatedStorage.Shared.Modules.AssetInfoBillboard)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local discard = VFX.Discard
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local AssetInvertedModelPresentation = require(ReplicatedStorage.Shared.Modules.AssetInvertedModelPresentation)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local AssetPalette = require(ReplicatedStorage.Shared.Util.AssetPalette)
local Assets2 = require(ReplicatedStorage.Data.Assets)
local personalities = Assets2.Personalities
local AssetRigFactory = require(ReplicatedStorage.Shared.Modules.AssetRigFactory)
local Physics = require(ReplicatedStorage.Shared.Utils.Physics)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local AssetSounds = require(ReplicatedStorage.Shared.Util.AssetSounds)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local v = {
	Name = "Handle",
	Size = vector.create(0.2, 0.2, 0.2),
	Transparency = 1,
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	Anchored = false,
	Massless = true
}
local v2 = {
	["Cave Dragon"] = "HumanoidRootPart",
	Warden = "HumanoidRootPart",
	["Eternal Lunar Dragon"] = "HumanoidRootPart",
	Unicorn = "HumanoidRootPartXZBoundsBottomY"
}
local v3 = {
	HumanoidRootPartXZBoundsBottomY = function(p, instance)
		local v4, v5 = ModelBounds(p)
		return instance.CFrame.Rotation + Vector3.new(
			instance.Position.X,
			v4.Position.Y - v5.Y * 0.5,
			instance.Position.Z
		)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function pinHandleContract(p)
	p.RequiresHandle = true
	p.CanBeDropped = false
end

local function stamp(instance, items)
	for _, item in items do
		instance:SetAttribute(item[1], item[2])
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function copyAttribute(instance, attributeName: string, p)
	if instance:GetAttribute(attributeName) ~= p then
		instance:SetAttribute(attributeName, p)
	end
end

local function ensureGrip(parent)
	local handle = parent:FindFirstChild("Handle")

	if handle and handle:IsA("BasePart") then
		return handle
	end

	local part = Instance.new("Part")

	for k, v4 in v do
		part[k] = v4
	end

	part.Parent = parent
	pinHandleContract(parent) -- equivalent call inferred; original call site unknown
	return part
end

local function seatRigOnGrip(tool, folder, value: number?, p: string?)
	local v4 = value or 1
	assert(v4, "luau")
	local v5 = assert(folder.PrimaryPart, (`{folder:GetFullName()} cannot be gripped without a root`))
	local pivot = folder:GetPivot()
	local grip = ensureGrip(tool)
	local cFrame

	if p then
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart", true)
		local v6

		if humanoidRootPart == nil then
			v6 = false
		else
			v6 = humanoidRootPart:IsA("BasePart")
		end

		assert(v6, (`{folder:GetFullName()} is missing the root its grip is anchored to`))
		local v7 = v3[p]

		if v7 then
			cFrame = v7(folder, humanoidRootPart)
		else
			cFrame = humanoidRootPart.CFrame
		end
	else
		local v6, v7 = ModelBounds(folder)
		cFrame = v6 * CFrame.new(0, v7.Y * -0.5, v4 * (v7.Z * 0.1))
	end

	folder:PivotTo(grip.CFrame * cFrame:ToObjectSpace(pivot))
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = v5
	weldConstraint.Part1 = grip
	weldConstraint.Parent = v5
	return grip
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ownedGamepassesFor(instance)
	if not Constants.IS_SERVER then
		return nil
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local unsafeGetProfileAwait, v4 = require(ServerScriptService.Library.Database).UnsafeGetProfileAwait(instance)

	if unsafeGetProfileAwait and v4 then
		return v4.Gamepasses
	end

	return nil
end

return {
	Build = function(data, p: string, instance)
		assert(AssetItem.AssetItemData(data))
		t.strict(t.string)(p)
		local category = data.Category
		local v4 = Assets.Directory[category]
		local settleFields = AssetPalette.SettleFields(category, data.EyeColor, data.ColorSeed, data.ColorIndex)
		local joined = table.concat(data.Mutations, ", ")
		local displayName = v4.DisplayName or category
		local tool = Instance.new("Tool")
		tool.Name = AssetDisplayText.ForRecord(data)
		pinHandleContract(tool) -- equivalent call inferred; original call site unknown

		for _, v5 in {
			{ "GuardTransparencyExcluded", true },
			{ "UID", p },
			{ "Mutations", joined },
			{ "BaseMutation", data.BaseMutation },
			{ "DisplayName", displayName },
			{ "Weight", AssetRigFactory.Mass(category, data.Scale) },
			{ "Scale", data.Scale },
			{ "EyeColor", settleFields.EyeColor },
			{ "ColorSeed", settleFields.ColorSeed },
			{ "ColorIndex", settleFields.ColorIndex },
			{ "Category", v4._id },
			{ "Favorite", data.IsFavorite or false },
			{ "ItemType", "Asset" }
		} do
			tool:SetAttribute(v5[1], v5[2])
		end

		CollectionService:AddTag(tool, "AssetTool")
		local configuration = Instance.new("Configuration")
		configuration.Name = "Configuration"
		configuration.Parent = tool

		for _, v5 in {
			{ "mutations", joined },
			{ "baseMutation", data.BaseMutation },
			{ "displayName", displayName },
			{ "scale", data.Scale },
			{ "eyeColor", settleFields.EyeColor },
			{ "colorSeed", settleFields.ColorSeed },
			{ "colorIndex", settleFields.ColorIndex },
			{ "rarity", v4.Rarity._id },
			{ "money", data.GeneratedMoney or 0 }
		} do
			configuration:SetAttribute(v5[1], v5[2])
		end

		local v5 = ownedGamepassesFor(instance) -- equivalent call inferred; original call site unknown

		for _, v6 in {
			{ "perSecond", AssetEarnings.LiveRatePerSecond(data, v5) },
			{ "perSecondDisplay", AssetEarnings.RatePerSecond(data, v5) }
		} do
			configuration:SetAttribute(v6[1], v6[2])
		end

		local grip = ensureGrip(tool)
		local v6 = nil
		local v7 = nil
		local v8 = nil

		local function mirrorTags()
			local mutations = tool:GetAttribute("Mutations")
			local baseMutation = tool:GetAttribute("BaseMutation")
			copyAttribute(configuration, "mutations", mutations) -- equivalent call inferred; original call site unknown
			copyAttribute(configuration, "baseMutation", baseMutation) -- equivalent call inferred; original call site unknown

			if v6 then
				copyAttribute(v6, "Mutations", mutations) -- equivalent call inferred; original call site unknown
				copyAttribute(v6, "BaseMutation", baseMutation) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dropCard()
			if v7 then
				discard(v7, 0)
				v7 = nil
				v8 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dropRig()
			dropCard() -- equivalent call inferred; original call site unknown

			if v6 then
				discard(v6, 0)
				v6 = nil
			end
		end

		local function ensureRig()
			if v6 and v6.Parent == tool and grip.Parent == tool then
				return v6
			end

			dropRig() -- equivalent call inferred; original call site unknown
			local v9 = data.Personality == personalities.Personalities.InvertedModel
			local clone = data

			if v9 then
				clone = table.clone(data)
				clone.Mutations = table.clone(data.Mutations)
				clone.Personality = personalities.Personalities.Normal
			end

			local folder = AssetRigFactory.BuildActive(p, clone, true, true)
			Physics.DisableAllPhysics(folder)
			Physics.SetAnchored(folder, false)
			grip = seatRigOnGrip(tool, folder, nil, v2[category])

			if v9 then
				AssetInvertedModelPresentation.Invert(folder)
				Physics.SetAnchored(folder, false)
			end

			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part:SetAttribute("KillPartIgnore", true)
				end
			end

			v6 = folder
			folder.Parent = tool
			mirrorTags()
			return folder
		end

		local function refreshCaptions()
			local displayName2 = configuration:GetAttribute("displayName") or ""
			local scale = configuration:GetAttribute("scale")
			local v9 = typeof(scale) ~= "number" and 1 or scale
			local mass = AssetRigFactory.Mass(category, v9)
			local mutationList = AssetSounds.ParseMutationList(tool:GetAttribute("Mutations") or "")
			local baseMutation = tool:GetAttribute("BaseMutation")
			mirrorTags()
			tool:SetAttribute("Weight", mass)
			tool.Name = AssetDisplayText.WithMass(displayName2, mutationList, baseMutation, mass)

			if not v7 then
				return
			end

			AssetInfoBillboard.WriteTitle(v7, displayName2, mutationList, baseMutation)

			if not v8 then
				return
			end

			local perSecondDisplay = configuration:GetAttribute("perSecondDisplay")

			if typeof(perSecondDisplay) ~= "number" then
				perSecondDisplay = configuration:GetAttribute("perSecond")
			end

			v8.Text = `${Simple.FormatCompact(perSecondDisplay)}/s`
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ensureCard()
			local rig = ensureRig()

			if v7 then
				return
			end

			local v9, _, v10 = AssetInfoBillboard.Attach(rig, category, data)

			if not v9 then
				return
			end

			v7 = v9
			v9.MaxDistance *= 2.8
			v9.Enabled = true
			v8 = v10
			refreshCaptions()
		end

		local function rebuildCard()
			mirrorTags()

			if v7 then
				dropCard() -- equivalent call inferred; original call site unknown
				ensureCard() -- equivalent call inferred; original call site unknown
			end

			refreshCaptions()
		end

		local v9 = {
			configuration:GetAttributeChangedSignal("perSecondDisplay"):Connect(refreshCaptions),
			configuration:GetAttributeChangedSignal("perSecond"):Connect(refreshCaptions),
			configuration:GetAttributeChangedSignal("displayName"):Connect(refreshCaptions),
			configuration:GetAttributeChangedSignal("scale"):Connect(refreshCaptions),
			tool:GetAttributeChangedSignal("Mutations"):Connect(rebuildCard),
			tool:GetAttributeChangedSignal("BaseMutation"):Connect(rebuildCard),
			tool.Equipped:Connect(function()
				ensureCard() -- equivalent call inferred; original call site unknown
				refreshCaptions()
			end),
			tool.Unequipped:Connect(dropRig)
		}
		tool.Destroying:Connect(function()
			for _, connection in v9 do
				connection:Disconnect()
			end

			dropRig() -- equivalent call inferred; original call site unknown
		end)
		tool.Parent = instance:WaitForChild("Backpack")
		return tool
	end
}