local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TableUtil = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("TableUtil"))
local Result = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("Result"))
local MaterialIconsHD = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("MaterialIconsHD"))
require(ReplicatedFirst:WaitForChild("BuildInfo"))
local Spritesheets = require(script:WaitForChild("Spritesheets"))
setmetatable(table.clone(MaterialIconsHD.broken_image), {
	__tostring = function(...)
		return "ErrorSprite"
	end
})
local v = {}
table.freeze(v)
local data = script:WaitForChild("Data")

function toSpriteDefinition(p: string, point: Vector2, point2: Vector2)
	return p .. "|" .. tostring((math.round(point.X))) .. "," .. tostring((math.round(point.Y))) .. "|" .. tostring((math.round(point2.X))) .. "," .. tostring((math.round(point2.Y)))
end

local v2 = {}
local names = {}
local Spritesheets2 = {}

for _, moduleScript in data:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	assert(Spritesheets[moduleScript.Name] ~= nil, (`Missing spritesheet image for "{moduleScript.Name}"`))

	for k, frame in module.frames do
		assert(v2[k] == nil, (`Duplicate spritesheet key: "{k}" (under "{names[k]}" and "{moduleScript.Name}")`))
		names[k] = moduleScript.Name
		v2[k] = {
			Image = Spritesheets[moduleScript.Name],
			ImageRectOffset = Vector2.new(frame.frame.x, frame.frame.y),
			ImageRectSize = Vector2.new(frame.frame.w, frame.frame.h)
		}
		local v3 = k
		setmetatable(v2[k], {
			__tostring = function(...)
				return (`Sprite({v3})`)
			end
		})
	end
end

TableUtil.deepFreeze(v2)
Spritesheets2.MAP_WITH_EXT = v2
local MAP = {}
local names2 = {}

for _, moduleScript in data:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	assert(Spritesheets[moduleScript.Name] ~= nil, (`Missing spritesheet image for "{moduleScript.Name}"`))

	for k, frame in module.frames do
		local v4 = k:split(".png")[1]
		assert(MAP[v4] == nil, (`Duplicate spritesheet key: "{v4}" (under "{names2[v4]}" and "{moduleScript.Name}")`))
		names2[v4] = moduleScript.Name
		MAP[v4] = {
			Image = Spritesheets[moduleScript.Name],
			ImageRectOffset = Vector2.new(frame.frame.x, frame.frame.y),
			ImageRectSize = Vector2.new(frame.frame.w, frame.frame.h)
		}
		setmetatable(MAP[v4], {
			__tostring = function(...)
				return (`Sprite({v4})`)
			end
		})
	end
end

TableUtil.deepFreeze(MAP)
Spritesheets2.MAP = MAP
Spritesheets2.toSpriteDefinition = toSpriteDefinition
local v4 = {}

for k, v5 in Spritesheets2.MAP do
	assert(v5 ~= nil, (`Missing image data for "{k}"`))
	assert(typeof(v5.Image) == "string", (`Expected string image for "{k}", got {typeof(v5.Image)}`))
	local v6 = toSpriteDefinition(v5.Image, v5.ImageRectOffset or Vector2.zero, v5.ImageRectSize or Vector2.zero)
	v4[v6] = v4[v6] or {}
	table.insert(v4[v6], k)
end

TableUtil.deepFreeze(v4)
Spritesheets2._DEF_TO_KEYS = v4

function Spritesheets2.getKeys(data2)
	assert(typeof(data2) == "table", (`Expected table sprite, got {typeof(data2)}`))
	assert(typeof(data2.Image) == "string", (`Expected string image for sprite, got {typeof(data2.Image)}`))
	local v5 = toSpriteDefinition(
		data2.Image,
		data2.ImageRectOffset or Vector2.zero,
		data2.ImageRectSize or Vector2.zero
	)
	local v6 = Spritesheets2._DEF_TO_KEYS[v5]
	return v6 or v
end

local LEGACY = {}

for k, v6 in Spritesheets2.MAP do
	local v7 = k .. ".png"
	assert(v6 ~= nil, (`Missing image data for "{v7}"`))
	local image = v6.Image
	assert(typeof(image) == "string", (`Expected string image for "{v7}", got {typeof(image)}`))

	if LEGACY[image] == nil then
		LEGACY[image] = {}
	end

	assert(LEGACY[image] ~= nil, (`Missing legacy map for image "{image}"`))
	LEGACY[image][v7] = {
		v6.ImageRectOffset.X,
		v6.ImageRectOffset.Y,
		v6.ImageRectSize.X,
		v6.ImageRectSize.Y
	}
end

TableUtil.deepFreeze(LEGACY)
Spritesheets2.LEGACY = LEGACY

function Spritesheets2.match(p: string)
	local v6 = Spritesheets2.MAP[p] or Spritesheets2.MAP_WITH_EXT[p]

	if v6 then
		return Result.ok(v6)
	end

	return Result.err((`No spritesheet found for key "{p}"`))
end

return Spritesheets2