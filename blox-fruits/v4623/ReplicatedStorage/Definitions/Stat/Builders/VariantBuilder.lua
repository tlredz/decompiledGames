local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local IconBuilder = require(game.ReplicatedStorage.Definitions.Stat.Builders.IconBuilder)
local Types = require(game.ReplicatedStorage.Definitions.Stat.Types)

local function copy(data)
	local v = {
		_Current = {
			Index = table.clone(data._Current.Index),
			Description = data._Current.Description,
			EffectSuffix = data._Current.EffectSuffix,
			Icon = data._Current.Icon
		},
		setDescription = data.setDescription,
		setEffectSuffix = data.setEffectSuffix,
		setIcon = data.setIcon,
		build = data.build
	}
	table.freeze(v)
	return v
end

local VariantBuilder = {
	Icon = IconBuilder,
	Builder = {}
}

function VariantBuilder.Builder.new(p, stat)
	return {
		_Current = {
			Index = {
				Key = p,
				Stat = stat
			}
		},
		setDescription = function(self, description: string)
			assert(description ~= "", (`variant "{self._Current.Index.Key}" needs a non-empty description`))
			local v = copy(self)
			v._Current.Description = description
			TableUtil.deepFreeze(v)
			return v
		end,
		setEffectSuffix = function(self, effectSuffix: string)
			assert(effectSuffix ~= "", (`variant "{self._Current.Index.Key}" needs a non-empty effect suffix`))
			local v = copy(self)
			v._Current.EffectSuffix = effectSuffix
			TableUtil.deepFreeze(v)
			return v
		end,
		setIcon = function(self, icon)
			local statIcon, v = Types.StatIcon(icon)
			assert(statIcon, (`expected a built stat icon, received an invalid value: {v}`))
			local v2 = copy(self)
			v2._Current.Icon = icon
			TableUtil.deepFreeze(v2)
			return v2
		end,
		build = function(p3)
			local _Current = p3._Current
			local key = _Current.Index.Key
			local description = _Current.Description
			local effectSuffix = _Current.EffectSuffix
			local icon = _Current.Icon
			assert(description ~= nil, (`need to assign a description to variant "{key}" before build`))
			assert(effectSuffix ~= nil, (`need to assign an effect suffix to variant "{key}" before build`))
			assert(icon ~= nil, (`need to assign an icon to variant "{key}" before build`))
			local v = {
				_AddressType = "Variant",
				Index = {
					Key = key,
					Stat = _Current.Index.Stat
				},
				Description = description,
				EffectSuffix = effectSuffix,
				Icon = icon
			}
			setmetatable(v, {
				__tostring = function(...)
					return (`VariantDef({_Current.Index.Stat}>{key})`)
				end
			})
			TableUtil.deepFreeze(v)
			local variantDefinition, v2 = Types.VariantDefinition(v)
			assert(variantDefinition, (`variant "{key}" built into an invalid definition: {v2}`))
			return v
		end
	}
end

function VariantBuilder.Builder.fromDefinition(data)
	return VariantBuilder.Builder.new(data.Index.Key, data.Index.Stat):setDescription(data.Description):setEffectSuffix(data.EffectSuffix):setIcon(data.Icon)
end

return VariantBuilder