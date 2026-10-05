local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
require(game.ReplicatedStorage.Spritesheets)
local v = {}

for k, v2 in IdMap.Material do
	if not (type(k) == "string" and k ~= "" and type(v2) == "number") then
		continue
	end

	v[k] = v2
end

local frozen = table.freeze(v)
local MaterialSprite = {
	config = function(p: string)
		local v2 = frozen[p]

		if not v2 then
			return nil
		end

		local match = ItemConfig.match(v2)

		if match:isErr() then
			return nil
		end

		return (match:unwrap())
	end
}

function MaterialSprite.sprite(p: string)
	local config = MaterialSprite.config(p)

	if config then
		return config.Display.Sprite
	end

	return nil
end

function MaterialSprite:paint(p2: string?)
	local v2

	if p2 then
		v2 = MaterialSprite.sprite(p2)
	end

	if v2 then
		self.Image = v2.Image
		self.ImageRectOffset = v2.ImageRectOffset
		self.ImageRectSize = v2.ImageRectSize
		self.Visible = true
	else
		self.Image = ""
		self.Visible = false
	end
end

return MaterialSprite