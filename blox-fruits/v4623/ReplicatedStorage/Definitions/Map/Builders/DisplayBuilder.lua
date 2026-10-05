local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = table.clone(data._Current),
		setName = data.setName,
		setIcon = data.setIcon,
		setColor = data.setColor,
		setPosition = data.setPosition,
		setDiameter = data.setDiameter,
		build = data.build
	}
	table.freeze(v)
	return v
end

local DisplayBuilder = {
	Builder = {}
}

function DisplayBuilder.Builder.new()
	return {
		_Current = {},
		setName = function(self, name: string?)
			local v = copy(self)
			v._Current.Name = name
			TableUtil.deepFreeze(v)
			return v
		end,
		setIcon = function(self, icon, iconOutline, sketchIcon, neonIcon)
			local v = copy(self)
			v._Current.Icon = icon
			v._Current.IconOutline = iconOutline
			v._Current.SketchIcon = sketchIcon
			v._Current.NeonIcon = neonIcon
			TableUtil.deepFreeze(v)
			return v
		end,
		setColor = function(self, color: Color3)
			local v = copy(self)
			v._Current.Color = color
			TableUtil.deepFreeze(v)
			return v
		end,
		setPosition = function(self, position: Vector2)
			local v = copy(self)
			v._Current.Position = position
			TableUtil.deepFreeze(v)
			return v
		end,
		setDiameter = function(self, diameter: number)
			assert(diameter > 0, (`display diameter must be above 0, received {diameter}`))
			local v = copy(self)
			v._Current.Diameter = diameter
			TableUtil.deepFreeze(v)
			return v
		end,
		build = function(p)
			local _Current = p._Current
			local icon = _Current.Icon
			local iconOutline = _Current.IconOutline
			local sketchIcon = _Current.SketchIcon
			local neonIcon = _Current.NeonIcon
			local color = _Current.Color
			local position = _Current.Position
			local diameter = _Current.Diameter
			assert(icon ~= nil, "need to assign an icon to the display definition before build")
			assert(iconOutline ~= nil, "need to assign an icon outline to the display definition before build")
			assert(color ~= nil, "need to assign a color to the display definition before build")
			assert(position ~= nil, "need to assign a position to the display definition before build")
			assert(diameter ~= nil, "need to assign a diameter to the display definition before build")
			assert(sketchIcon ~= nil, "need to assign a sketched icon to the display definition before build")
			assert(neonIcon ~= nil, "need to assign a neon icon to the display definition before build")
			local v = {
				Name = _Current.Name,
				Icon = icon,
				IconOutline = iconOutline,
				SketchIcon = sketchIcon,
				NeonIcon = neonIcon,
				Color = color,
				Position = position,
				Diameter = diameter
			}
			TableUtil.deepFreeze(v)
			local islandDisplayDefinition, v2 = Types.IslandDisplayDefinition(v)
			assert(islandDisplayDefinition, (`built an invalid island display definition: {v2}`))
			return v
		end
	}
end

function DisplayBuilder.Builder.fromDefinition(data)
	return DisplayBuilder.Builder.new():setName(data.Name):setIcon(
		data.Icon,
		data.IconOutline,
		data.SketchIcon,
		data.NeonIcon
	):setColor(data.Color):setPosition(data.Position):setDiameter(data.Diameter)
end

return DisplayBuilder