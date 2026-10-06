local Spritesheet = {}
Spritesheet.__index = Spritesheet

function Spritesheet.new(texture)
	local v = {}
	setmetatable(v, Spritesheet)
	v.Texture = texture
	v.Sprites = {}
	return v
end

function Spritesheet.AddSprite(p, p2, position, size)
	p.Sprites[p2] = {
		Position = position,
		Size = size
	}
end

function Spritesheet.GetSprite(p, _, p2)
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

return Spritesheet