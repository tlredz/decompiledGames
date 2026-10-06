local ModuleScriptSpritesheet = {}
ModuleScriptSpritesheet.__index = ModuleScriptSpritesheet

function ModuleScriptSpritesheet.new(texture)
	local v = {}
	setmetatable(v, ModuleScriptSpritesheet)
	v.Texture = texture
	v.Sprites = {}
	return v
end

function ModuleScriptSpritesheet.AddSprite(p, p2, position, size)
	p.Sprites[p2] = {
		Position = position,
		Size = size
	}
end

function ModuleScriptSpritesheet.GetSprite(p, _, p2)
	if not p2 then
		warn("Image name cannot be nil")
		return false
	end

	local sprite = p.Sprites[p2]

	if sprite then
		return {
			ImageRectOffset = sprite.Position,
			ImageRectSize = sprite.Size,
			Image = p.Texture
		}
	end

	warn("Could not find sprite for: " .. p2)
	return false
end

return ModuleScriptSpritesheet