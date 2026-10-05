local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local IconBuilder = require(game.ReplicatedStorage.Definitions.Stat.Builders.IconBuilder)
local ValueBuilder = require(game.ReplicatedStorage.Definitions.Stat.Builders.ValueBuilder)
local VariantBuilder = require(game.ReplicatedStorage.Definitions.Stat.Builders.VariantBuilder)
local Types = require(game.ReplicatedStorage.Definitions.Stat.Types)

local function copy(data)
	local v = {
		_Current = {
			Key = data._Current.Key,
			DisplayName = data._Current.DisplayName,
			ValueForm = data._Current.ValueForm,
			Description = data._Current.Description,
			EffectSuffix = data._Current.EffectSuffix,
			Icon = data._Current.Icon,
			Variants = table.clone(data._Current.Variants)
		},
		setDisplayName = data.setDisplayName,
		setValueForm = data.setValueForm,
		setDescription = data.setDescription,
		setEffectSuffix = data.setEffectSuffix,
		setIcon = data.setIcon,
		insertVariant = data.insertVariant,
		build = data.build
	}
	table.freeze(v)
	return v
end

local StatBuilder = {
	Icon = IconBuilder,
	Variant = VariantBuilder,
	Value = ValueBuilder,
	Builder = {}
}

function StatBuilder.Builder.new(p)
	return {
		_Current = {
			Key = p,
			Variants = {}
		},
		setDisplayName = function(self, displayName: string)
			assert(displayName ~= "", (`stat "{self._Current.Key}" needs a non-empty display name`))
			local v = copy(self)
			v._Current.DisplayName = displayName
			TableUtil.deepFreeze(v)
			return v
		end,
		setValueForm = function(self, valueForm)
			local valueForm2, v = Types.ValueForm(valueForm)
			assert(valueForm2, (`expected a value form, received an invalid value: {v}`))
			local v2 = copy(self)
			v2._Current.ValueForm = valueForm
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setDescription = function(self, description: string)
			assert(description ~= "", (`stat "{self._Current.Key}" needs a non-empty description`))
			local v = copy(self)
			v._Current.Description = description
			TableUtil.deepFreeze(v)
			return v
		end,
		setEffectSuffix = function(self, effectSuffix: string)
			assert(effectSuffix ~= "", (`stat "{self._Current.Key}" needs a non-empty effect suffix`))
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
		insertVariant = function(self, p3)
			local variantDefinition, v = Types.VariantDefinition(p3)
			assert(variantDefinition, (`expected a built variant definition, received an invalid value: {v}`))
			local v2 = copy(self)
			assert(
				p3.Index.Stat == v2._Current.Key,
				(`variant "{p3.Index.Key}" is indexed to stat "{p3.Index.Stat}" but was assigned to stat "{v2._Current.Key}"`)
			)

			for _, variant in v2._Current.Variants do
				assert(
					variant.Index.Key ~= p3.Index.Key,
					(`stat "{v2._Current.Key}" already has a variant at key "{p3.Index.Key}"`)
				)
			end

			table.insert(v2._Current.Variants, p3)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		build = function(p2)
			local _Current = p2._Current
			local key = _Current.Key
			local displayName = _Current.DisplayName
			local valueForm = _Current.ValueForm
			assert(displayName ~= nil, (`need to assign a display name to stat "{key}" before build`))
			assert(valueForm ~= nil, (`need to assign a value form to stat "{key}" before build`))

			local function finish(p3)
				setmetatable(p3, {
					__tostring = function(...)
						return (`StatDef({key})`)
					end
				})
				TableUtil.deepFreeze(p3)
				local statDefinition, v = Types.StatDefinition(p3)
				assert(statDefinition, (`stat "{key}" built into an invalid definition: {v}`))
				return p3
			end

			if #_Current.Variants > 0 then
				local v

				if _Current.Icon == nil and _Current.Description == nil then
					v = _Current.EffectSuffix == nil
				else
					v = false
				end

				assert(
					v,
					(`stat "{key}" has variants, so its icon, description and effect suffix belong to each variant`)
				)
				return (finish({
					_AddressType = "Stat",
					StatType = "Complex",
					Key = key,
					DisplayName = displayName,
					ValueForm = valueForm,
					Variants = table.clone(_Current.Variants)
				}))
			else
				local description = _Current.Description
				local effectSuffix = _Current.EffectSuffix
				local icon = _Current.Icon
				assert(description ~= nil, (`need to assign a description to stat "{key}" before build`))
				assert(effectSuffix ~= nil, (`need to assign an effect suffix to stat "{key}" before build`))
				assert(icon ~= nil, (`need to assign an icon to stat "{key}" before build`))
				return (finish({
					_AddressType = "Stat",
					StatType = "Simple",
					Key = key,
					DisplayName = displayName,
					ValueForm = valueForm,
					Description = description,
					EffectSuffix = effectSuffix,
					Icon = icon
				}))
			end
		end
	}
end

function StatBuilder.Builder.fromDefinition(data)
	local v = StatBuilder.Builder.new(data.Key):setDisplayName(data.DisplayName):setValueForm(data.ValueForm)

	if data.StatType ~= "Complex" then
		return (v:setDescription(data.Description):setEffectSuffix(data.EffectSuffix):setIcon(data.Icon))
	end

	for _, variant in data.Variants do
		v = v:insertVariant(variant)
	end

	return v
end

return StatBuilder