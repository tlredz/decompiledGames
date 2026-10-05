local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetPalette = require(ReplicatedStorage.Shared.Util.AssetPalette)
local Assets = require(ReplicatedStorage.Data.Assets)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggScaling = require(ReplicatedStorage.Shared.Util.EggScaling)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local ParasiteVisual = require(script.Parent.ParasiteVisual)
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.Types)
local eggRarityVFX = ReplicatedStorage.Assets.Particles.EggRarityVFX
local EggRenderer = {}

local function exceedsPlacedCollisionBounds(vector: Vector3)
	return vector.X > 20 or vector.Y > 20 or vector.Z > 20
end

local function rarityVfxSource(p: number)
	local v = -1
	local v2 = nil

	for _, child in eggRarityVFX:GetChildren() do
		local v3, v4 = string.match(child.Name, "^RarityNumber(%d+)(%+?)$")
		assert(v3 ~= nil, (`EggRarityVFX child "{child.Name}" is not named RarityNumber<n>[+]`))
		local v5 = tonumber(v3)
		local v6

		if v4 == "+" then
			v6 = v5 <= p
		else
			v6 = p == v5
		end

		if not (v6 and v < v5) then
			continue
		end

		v2 = child
		v = v5
	end

	return v2
end

local function attachRarityVfx(clone, rank: number)
	local v = rarityVfxSource(rank)

	if v == nil then
		return
	end

	local hitbox = clone:FindFirstChild("Hitbox")
	assert(hitbox ~= nil, (`Egg model {clone.Name} is missing its Hitbox`))
	assert(hitbox:IsA("BasePart"), (`Egg model {clone.Name} Hitbox must be a BasePart`))
	local v2 = math.max(v:GetAttribute("HitboxSizeY") or 5, 1)
	local model = Instance.new("Model")

	for _, child in v:GetChildren() do
		local clone_2 = child:Clone()
		clone_2.Parent = model
	end

	model:ScaleTo(hitbox.Size.Y / v2)

	for _, child in model:GetChildren() do
		child.Parent = hitbox
	end

	model:Destroy()
end

function EggRenderer.GetTemplate(data)
	assert(Eggs.SchemaValidation.SavedEgg(data), "Invalid saved egg record")
	return EggRecords.EggModelTemplate(data.AssetCategory, data.Mutations, data.BaseMutation, data.EggSkin)
end

function EggRenderer.DisableCollisions(folder)
	t.strict(t.instanceIsA("Model"))(folder)

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

function EggRenderer.ApplyPlacedCollisionPolicy(folder)
	t.strict(t.instanceIsA("Model"))(folder)
	local _, size = ModelBounds(folder)

	if folder.PrimaryPart then
		size = folder.PrimaryPart.Size or size
	end

	local v = not (size.X > 20 or size.Y > 20 or size.Z > 20)

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = v and part.Transparency < 1
		end
	end
end

function EggRenderer.RenderVisual(data, tool, flag: boolean?)
	t.strict(t.Instance)(tool)
	t.strict(t.number)(data.OwnerUserId)
	t.strict(t.string)(data.UID)
	t.strict(t.string)(data.ModelName)
	assert(Eggs.SchemaValidation.SavedEgg(data.Record), "Invalid saved egg record")
	local v = Assets.Directory[data.Record.AssetCategory]
	assert(v ~= nil, (`Missing asset config for category {data.Record.AssetCategory}`))
	local egg = v.Egg
	local clone = EggRenderer.GetTemplate(data.Record):Clone()
	clone.Name = data.ModelName
	attachRarityVfx(clone, v.Rarity.Rank)
	local scale = clone:GetScale()
	local assetCategory = data.Record.AssetCategory
	local v2

	if data.ScaleMultiplier then
		v2 = EggScaling.LiftToFloor(scale, data.ScaleMultiplier, assetCategory)
	else
		v2 = EggScaling.PreGrowthVisual(scale, data.Record.AssetScale, assetCategory)
	end

	local v3 = math.clamp(data.ScaleAlpha or 1, 0.5, 1)
	clone:ScaleTo(EggScaling.LiftToFloor(scale, v2 * v3, assetCategory))

	if Mutations.EggModelName(data.Record.Mutations, data.Record.BaseMutation) == nil then
		AssetPalette.PaintModel(
			clone,
			data.Record.AssetCategory,
			data.Record.AssetEyeColor,
			data.Record.AssetColorSeed,
			data.Record.AssetColorIndex
		)
	end

	local primaryPart = clone.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	local v4, v5 = ModelBounds(clone)
	local v6 = v4.Position.Y - v5.Y * 0.5
	local Y = primaryPart.CFrame.Position.Y
	primaryPart.PivotOffset = CFrame.new(0, v6 - Y, 0)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = part.Transparency ~= 1
		part.CanTouch = false
		part.Massless = true
		part.Anchored = not tool:IsA("Tool") and part == primaryPart
	end

	if flag then
		EggRenderer.ApplyPlacedCollisionPolicy(clone)
	end

	clone.Parent = tool
	ParasiteVisual.Attach(clone, data.Record.HasParasite)
	return {
		Model = clone,
		VisibleParts = { primaryPart },
		Config = egg
	}
end

function EggRenderer.GetAuthoredScale(p)
	assert(Eggs.SchemaValidation.SavedEgg(p), "Invalid saved egg record")
	local scale = EggRenderer.GetTemplate(p):GetScale()
	assert(scale > 0, (`Egg model {p.AssetCategory} scale must be greater than 0`))
	return scale
end

function EggRenderer.GetVisibleBounds(p)
	assert(Eggs.SchemaValidation.SavedEgg(p), "Invalid saved egg record")
	assert(Assets.Directory[p.AssetCategory] ~= nil, (`Missing asset config for category {p.AssetCategory}`))
	local template = EggRenderer.GetTemplate(p)
	local authoredScale = EggRenderer.GetAuthoredScale(p)
	local _, v = ModelBounds(template)
	return v / authoredScale
end

return EggRenderer