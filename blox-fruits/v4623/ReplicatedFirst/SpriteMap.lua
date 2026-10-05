local ReplicatedFirst = game:GetService("ReplicatedFirst")
local MaterialIconsHD = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("MaterialIconsHD"))
local BuildInfo = require(ReplicatedFirst:WaitForChild("BuildInfo"))
local GeneratedSource = require(script:WaitForChild("GeneratedSource"))
local Spritesheets = require(ReplicatedFirst:WaitForChild("Spritesheets"))
local clone = table.clone(MaterialIconsHD.broken_image)
setmetatable(clone, {
	__tostring = function(...)
		return "ErrorSprite"
	end
})
local SpriteMap = {
	All = {}
}

for k, v in GeneratedSource do
	if k == "All" then
		continue
	end

	SpriteMap[k] = {}
	assert(type(v) == "table", (`bad keymap at "{k}"`))

	for k2, _ in v do
		SpriteMap.All[k2] = Spritesheets.match(k2):asNullable()
		SpriteMap[k][k2] = SpriteMap.All[k2]
	end
end

local v = {
	__index = function(p, p2)
		local v2 = rawget(p, p2)

		if v2 ~= nil then
			return v2
		end

		if rawget(p, "All") then
			if BuildInfo.BRANCH ~= "live" then
				warn((`sprite folder "{p2}" doesn't exist, using "All"`))
			end

			return (rawget(p, "All"))
		else
			if BuildInfo.BRANCH ~= "live" then
				error((`missing sprite: {p2}`))
			end

			return clone
		end
	end
}
local makeStrictStatic

makeStrictStatic = function(list)
	if table.isfrozen(list) then
		return
	end

	for _, v2 in pairs(list) do
		if type(v2) == "table" then
			makeStrictStatic(v2)
		end
	end

	setmetatable(list, v)
	table.freeze(list)
end

makeStrictStatic(SpriteMap)
return SpriteMap