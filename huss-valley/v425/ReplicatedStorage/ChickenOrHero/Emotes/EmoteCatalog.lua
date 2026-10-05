local EmoteCatalog = {
	Enabled = true,
	ComingSoon = true,
	StudioPreview = false,
	PageSize = 6,
	MaxSeconds = 35,
	Entries = {}
}

local function add(id, name, clip, route, level, p6)
	table.insert(EmoteCatalog.Entries, {
		Id = id,
		Name = name,
		Clip = clip,
		Route = route,
		Level = level,
		Loop = p6 ~= false
	})
end

table.insert(EmoteCatalog.Entries, {
	Id = "IdleDance",
	Name = "Idle Dance",
	Clip = "Idle Dance",
	Route = "Starter",
	Level = nil,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "Shuffle",
	Name = "Shuffle",
	Clip = "Shuffle",
	Route = "Starter",
	Level = nil,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "AnimePose",
	Name = "Anime Pose",
	Clip = "Anime Pose",
	Route = "Starter",
	Level = nil,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "SnappySkipping",
	Name = "Snappy Skipping",
	Clip = "Snappy Skipping",
	Route = "Free",
	Level = 4,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "WavyGrooves",
	Name = "Wavy Grooves",
	Clip = "Wavy Grooves",
	Route = "Free",
	Level = 12,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "Jumpstyle",
	Name = "Jumpstyle",
	Clip = "Jumpstyle",
	Route = "Free",
	Level = 22,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "WibblyWobbly",
	Name = "Wibbly Wobbly",
	Clip = "Wibbly Wobbly",
	Route = "Premium",
	Level = 2,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "LoseIt",
	Name = "Lose It",
	Clip = "Lose it",
	Route = "Premium",
	Level = 4,
	Loop = false
})
table.insert(EmoteCatalog.Entries, {
	Id = "Skeleton",
	Name = "Skeleton",
	Clip = "Skeleton",
	Route = "Premium",
	Level = 7,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "BTSDance",
	Name = "BTS Dance",
	Clip = "BTS Dance",
	Route = "Premium",
	Level = 11,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "Flexer",
	Name = "Flexer",
	Clip = "Flexer",
	Route = "Premium",
	Level = 14,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "SkeletonGrooves",
	Name = "Skeleton Grooves",
	Clip = "Skeleton Grooves",
	Route = "Premium",
	Level = 17,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "Moongazer",
	Name = "Moongazer",
	Clip = "Moongazer",
	Route = "Premium",
	Level = 21,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "ElectroShuffle",
	Name = "Electro Shuffle",
	Clip = "Electro Shuffle",
	Route = "Premium",
	Level = 24,
	Loop = true
})
table.insert(EmoteCatalog.Entries, {
	Id = "CatDance",
	Name = "Cat Dance",
	Clip = "CatDance",
	Route = "Premium",
	Level = 28,
	Loop = true
})
local entriesById = {}

for _, entry in EmoteCatalog.Entries do
	entriesById[entry.Id] = entry
end

function EmoteCatalog.get(p)
	return entriesById[p]
end

function EmoteCatalog.owned(p, p2)
	local v = entriesById[p]

	if v == nil then
		return false
	elseif v.Route == "Starter" then
		return true
	elseif p2 == nil or p2.emotes == nil then
		return false
	else
		return p2.emotes[p] == true
	end
end

function EmoteCatalog.assetId(childName)
	local assets = script.Parent:FindFirstChild("Assets")
	local animation = assets and assets:FindFirstChild(childName)
	local animationId = animation and animation:IsA("Animation") and animation.AnimationId or ""
	return animationId:match("^rbxassetid://[1-9]%d*$") and animationId or nil
end

function EmoteCatalog.available(childName)
	if EmoteCatalog.ComingSoon then
		return false
	end

	if EmoteCatalog.assetId(childName) then
		return true
	end

	local clips = script.Parent:FindFirstChild("Clips")
	local studioPreview = EmoteCatalog.StudioPreview

	if not studioPreview then
		return studioPreview
	end

	local RunService = game:GetService("RunService")
	studioPreview = RunService:IsStudio()

	if studioPreview then
		if clips == nil then
			studioPreview = false
		else
			studioPreview = clips:FindFirstChild(childName) ~= nil
		end
	end

	return studioPreview
end

return EmoteCatalog