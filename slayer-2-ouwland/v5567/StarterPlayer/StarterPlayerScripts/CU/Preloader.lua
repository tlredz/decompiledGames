local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local v = {}
local animations = {}
local v2 = {
	Current = 0,
	Max = 0
}

for _, tag in ipairs({ "anims_preload_tag_priority", "anims_preload_tag" }) do
	for _, animation in ipairs(CollectionService:GetTagged(tag)) do
		if not animation:IsA("Animation") or animation.AnimationId == "" or v[animation] then
			continue
		end

		v[animation] = true
		table.insert(animations, animation)
	end
end

v2.Max = #animations

for i = 1, #animations, 25 do
	local v3 = {}

	for i2 = i, math.min(i + 24, #animations) do
		table.insert(v3, animations[i2])
	end

	local success, result = pcall(function()
		ContentProvider:PreloadAsync(v3, function()
			v2.Current += 1
		end)
	end)

	if not success then
		warn("Preload batch failed:", result)
	end

	task.wait(0.1)
end