local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local v = {
	AnimSaves = true,
	InitialPoses = true
}
local v2 = {
	MeshPart = true,
	SpecialMesh = true,
	FileMesh = true,
	Decal = true,
	Texture = true,
	SurfaceAppearance = true,
	ParticleEmitter = true,
	Beam = true,
	Trail = true,
	Sound = true,
	Animation = false,
	ImageLabel = true,
	ImageButton = true,
	Sky = true,
	Shirt = true,
	Pants = true,
	ShirtGraphic = true
}
local total = 0
local count = 0

local function OnAssetFetched(p: string, p2)
	if p2 == Enum.AssetFetchStatus.Failure then
		count += 1
		warn("[Preload] Failed to preload: " .. p)
	end
end

local Collect

Collect = function(instance, children)
	for _, child in instance:GetChildren() do
		if v[child.Name] then
			continue
		end

		if v2[child.ClassName] then
			table.insert(children, child)
		end

		Collect(child, children)
	end
end

local function PreloadInstance(instance)
	task.spawn(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local instances = {}

		if v2[instance.ClassName] then
			table.insert(instances, instance)
		end

		Collect(instance, instances)

		if #instances == 0 then
			return
		end

		total += #instances
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(instances, OnAssetFetched)
		end)

		if not success then
			warn("[Preload] PreloadAsync error for " .. instance:GetFullName() .. ": " .. tostring(result))
		end
	end)
end

for _, v3 in CollectionService:GetTagged("Preload") do
	local v4 = v3
	task.spawn(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local v5 = {}

		if v2[v4.ClassName] then
			table.insert(v5, v4)
		end

		Collect(v4, v5)

		if #v5 == 0 then
			return
		end

		total += #v5
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v5, OnAssetFetched)
		end)

		if not success then
			warn("[Preload] PreloadAsync error for " .. v4:GetFullName() .. ": " .. tostring(result))
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Preload"):Connect(PreloadInstance)
task.delay(20, function()
	print(("[Preload] %d assets queued, %d asset fetches failed"):format(total, count))
end)