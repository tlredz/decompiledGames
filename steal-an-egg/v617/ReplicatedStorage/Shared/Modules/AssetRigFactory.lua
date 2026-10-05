local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetInvertedModelPresentation = require(ReplicatedStorage.Shared.Modules.AssetInvertedModelPresentation)
local SpecialLuckyBlockAsset = require(ReplicatedStorage.Shared.Util.SpecialLuckyBlockAsset)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local AssetPalette = require(ReplicatedStorage.Shared.Util.AssetPalette)
local Assets2 = require(ReplicatedStorage.Data.Assets)
local personalities = Assets2.Personalities
local Retry = require(ReplicatedStorage.Shared.Utils.Retry)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local AssetModels = require(ReplicatedStorage.Shared.Modules.AssetModels)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local AssetRigFactory = {
	Scale = function(value: number)
		if typeof(value) == "number" then
			return (math.max(value, 0))
		end

		return 1
	end
}

function AssetRigFactory.RigScale(p: string, p2: number)
	return AssetRigFactory.Scale(p2) * AssetModels.GetBaseModelScale(p)
end

function AssetRigFactory.Mass(p: string, p2: number)
	return (tonumber(Assets.Directory[p].ModelWeight) or 1) * AssetRigFactory.Scale(p2)
end

function AssetRigFactory.Resize(instance, p: string, p2: number)
	local rigScale = AssetRigFactory.RigScale(p, p2)
	instance:ScaleTo(rigScale)
	return rigScale
end

function AssetRigFactory.Extents(p)
	assert(AssetItem.AssetItemData(p))
	local visibleBoundsData = AssetModels.GetVisibleBoundsData(p.Category)
	assert(visibleBoundsData.TemplateScale > 0, (`template scale for {p.Category} is not above zero`))
	return visibleBoundsData.Size / visibleBoundsData.TemplateScale
end

function AssetRigFactory.Build(data, flag: boolean?)
	assert(AssetItem.AssetItemData(data))
	local category = data.Category
	local clone = assert(AssetModels.Resolve(category), (`{category} has no rig template`)):Clone()
	clone.PrimaryPart = clone:FindFirstChild("Segment1", true) or clone.PrimaryPart
	assert(clone.PrimaryPart, (`the {category} rig template names no primary part`))

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local v2 = part.Transparency == 1
		part.Anchored = false
		part.CanQuery = not v2

		if v2 or flag then
			part.CanCollide = false
		end
	end

	local settleFields = AssetPalette.SettleFields(category, data.EyeColor, data.ColorSeed, data.ColorIndex)
	AssetPalette.PaintModel(clone, category, settleFields.EyeColor, settleFields.ColorSeed, settleFields.ColorIndex)

	for _, v2 in Mutations.Sanitize(data.Mutations) do
		Mutations.ApplyTo(clone, v2, settleFields.ColorSeed)
	end

	AssetRigFactory.Resize(clone, category, data.Scale)

	if data.Personality == personalities.Personalities.InvertedModel then
		AssetInvertedModelPresentation.Invert(clone)
	end

	return clone
end

function AssetRigFactory:Strip(flag: boolean?, flag2: boolean?)
	t.strict(t.instanceIsA("Model"))(self)
	local primaryPart = self.PrimaryPart or self:FindFirstChild("HumanoidRootPart", true)
	local descendants = {}

	for _, descendant in ipairs(self:GetDescendants()) do
		local v2 = descendant:IsA("AnimationController") or descendant:IsA("Animator")
		local isA = descendant:IsA("Bone")

		if v2 and not flag2 or isA and not flag or descendant:IsA("Humanoid") then
			descendants[#descendants + 1] = descendant
		end
	end

	local lastTime = os.clock()

	for i, v2 in ipairs(descendants) do
		v2:Destroy()

		if not (i < #descendants and os.clock() - lastTime >= 0.002) then
			continue
		end

		task.wait()
		lastTime = os.clock()
	end

	if primaryPart and primaryPart:IsA("BasePart") then
		self.PrimaryPart = primaryPart
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIdleOnceInWorld(instance, animator, idle)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, instance2)
		if not (instance2 and instance2:IsDescendantOf(workspace)) and instance2 ~= workspace then
			return
		end

		ancestryChangedConnection:Disconnect()
		local v2, v3 = Retry(function()
			return animator:LoadAnimation(idle)
		end):await()

		if not v2 then
			v:AtError():Log((`idle track refused to load on {instance.Name}: {v3}`))
			return
		end

		v3.Looped = true
		v3.Priority = Enum.AnimationPriority.Idle
		v3:Play()
	end)
end

local function replaceRigController(instance, _id)
	local animationController = instance:FindFirstChildWhichIsA("AnimationController", true)

	if animationController then
		local animator = animationController:FindFirstChildWhichIsA("Animator")

		if animator then
			animator:Destroy()
		end

		animationController:Destroy()
	end

	local animationController2 = Instance.new("AnimationController")
	animationController2.Name = "AnimationController"
	animationController2.Parent = instance:WaitForChild("Model")
	local animator = Instance.new("Animator")

	if Constants.IS_SERVER then
		animator:SetAttribute("ActiveAssetRarity", _id)
	end

	animator.Parent = animationController2
	return animator
end

function AssetRigFactory.BuildActive(UID: string?, p, flag: boolean?, flag2: boolean?, flag3: boolean?)
	t.strict(t.optional(t.string))(UID)
	local v2 = AssetRigFactory.Build(p, true)
	local assert_2 = assert(v2.PrimaryPart, "a freshly built rig lost its primary part")
	assert_2.Anchored = true
	v2:SetAttribute("SpecialLuckyBlockAsset", SpecialLuckyBlockAsset.Matches(p))
	local v3 = Assets.Directory[p.Category]
	local idle = v3.Animations.Idle

	if flag and idle and v2:GetAttribute("AnimationsDisabled") ~= true then
		assert(idle, (`{p.Category} was asked to animate without an idle track`))
		playIdleOnceInWorld(v2, replaceRigController(v2, v3.Rarity._id), idle) -- equivalent call inferred; original call site unknown

		if UID then
			v2:SetAttribute("UID", UID)
		end

		return v2
	else
		AssetRigFactory.Strip(v2, v2:GetAttribute("DontRemoveBones") or flag2, flag3)

		if UID then
			v2:SetAttribute("UID", UID)
		end

		return v2
	end
end

function AssetRigFactory.BuildWandering(ownerUserId: number, UID: string, p, parent)
	t.strict(t.number)(ownerUserId)
	t.strict(t.string)(UID)
	t.strict(t.Instance)(parent)
	assert(AssetItem.AssetItemData(p))
	local folder = AssetRigFactory.Build(p, true)
	folder.Name = `{ownerUserId}_{UID}`
	local v2 = assert(folder.PrimaryPart, (`the {p.Category} rig has no primary part`))
	local v3, v4 = ModelBounds(folder)
	v2.PivotOffset = CFrame.new(0, v3.Position.Y - v4.Y * 0.5 - v2.Position.Y, 0)

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = part.Transparency ~= 1
		part.CanTouch = false
		part.Massless = true
		part.Anchored = false
	end

	v2.Anchored = true
	folder:SetAttribute("UID", UID)
	folder:SetAttribute("OwnerUserId", ownerUserId)
	folder.Parent = parent
	return folder
end

return AssetRigFactory