local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.Definitions.Stat.Types)
require(game.ReplicatedStorage.Util.TypeUtil)

local function copy(data)
	local v = {
		_Current = table.clone(data._Current),
		setMain = data.setMain,
		setModifier = data.setModifier,
		setVariant = data.setVariant,
		build = data.build
	}
	table.freeze(v)
	return v
end

local IconBuilder = {
	Builder = {}
}

function IconBuilder.Builder.new()
	return {
		_Current = {},
		setMain = function(self, main)
			local v = copy(self)
			v._Current.Main = main
			TableUtil.deepFreeze(v)
			return v
		end,
		setModifier = function(self, modifier, modifierColor: Color3?)
			local v = copy(self)
			v._Current.Modifier = modifier
			v._Current.ModifierColor = modifierColor
			TableUtil.deepFreeze(v)
			return v
		end,
		setVariant = function(self, variant, variantColor: Color3?)
			local v = copy(self)
			v._Current.Variant = variant
			v._Current.VariantColor = variantColor
			TableUtil.deepFreeze(v)
			return v
		end,
		build = function(p)
			local _Current = p._Current
			local main = _Current.Main
			assert(main ~= nil, "need to assign a main sprite to the icon before build")
			local v = {
				Main = main,
				Modifier = _Current.Modifier,
				ModifierColor = _Current.ModifierColor,
				Variant = _Current.Variant,
				VariantColor = _Current.VariantColor
			}
			TableUtil.deepFreeze(v)
			local statIcon, v2 = Types.StatIcon(v)
			assert(statIcon, (`built an invalid stat icon: {v2}`))
			return v
		end
	}
end

function IconBuilder.Builder.fromDefinition(data)
	local v = IconBuilder.Builder.new():setMain(data.Main)

	if data.Modifier then
		v = v:setModifier(data.Modifier, data.ModifierColor)
	end

	if data.Variant then
		return (v:setVariant(data.Variant, data.VariantColor))
	end

	return v
end

return IconBuilder