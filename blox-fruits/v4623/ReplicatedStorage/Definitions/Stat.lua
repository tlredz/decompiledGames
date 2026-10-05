local Result = require(game.ReplicatedStorage.Packages.Result)
local Builders = require(script.Builders)
local DEFINITIONS = require(script.DEFINITIONS)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Types = require(script.Types)

local function findStat(p)
	return DEFINITIONS[p]
end

local v = FunctionCache.new(function(p, p2)
	if p.StatType ~= "Complex" then
		return nil
	end

	for _, variant in p.Variants do
		if variant.Index.Key == p2 then
			return variant
		end
	end

	return nil
end, function(p, p2)
	return (`{p.Key}_{p2}`)
end)

local function fn(p, variant)
	return v:call(p, variant)
end

function resolve(data)
	local definition = DEFINITIONS[data.Type]

	if not definition then
		return Result.err((`no definition for stat type: "{data.Type}"`))
	end

	if data.StatType == "Complex" then
		if definition.StatType ~= "Complex" then
			return Result.err((`stat "{data.Type}" is simple, but was indexed as complex`))
		end

		local variant = fn(definition, data.Variant)

		if variant then
			return Result.ok(table.freeze({
				Definition = definition,
				Variant = variant,
				DisplayName = definition.DisplayName,
				Description = variant.Description,
				EffectSuffix = variant.EffectSuffix,
				Icon = variant.Icon
			}))
		end

		return Result.err((`no variant "{data.Variant}" for stat "{data.Type}"`))
	elseif definition.StatType == "Simple" then
		return Result.ok(table.freeze({
			Definition = definition,
			Variant = nil,
			DisplayName = definition.DisplayName,
			Description = definition.Description,
			EffectSuffix = definition.EffectSuffix,
			Icon = definition.Icon
		}))
	else
		return Result.err((`stat "{data.Type}" is complex, but was indexed as simple`))
	end
end

local function getValueConstructor(p)
	return Builders.Value.get(p.ValueForm)
end

local Stat = {
	Types = Types,
	Builders = Builders,
	DEFINITIONS = DEFINITIONS,
	solve = function(data, p)
		local resolved = resolve(data)

		if resolved:isErr() then
			return Result.err(resolved:unwrapErr())
		end

		local unwrapped = resolved:unwrap()
		local definition = unwrapped.Definition
		local v2 = Builders.Value.get(definition.ValueForm)(p)

		if not v2:isErr() then
			local unwrapped2 = v2:unwrap()
			return Result.ok({
				Index = data,
				DisplayName = unwrapped.DisplayName,
				Icon = unwrapped.Icon,
				Description = unwrapped.Description,
				Text = unwrapped2.Text,
				Value = unwrapped2.Value,
				Modification = unwrapped2.Modification,
				FullText = `{unwrapped2.Text} {unwrapped.EffectSuffix}`
			})
		end

		if data.StatType == "Complex" then
			return Result.err((`failed to construct stat value for variant {data.Variant} of stat {data.Type}: {v2:unwrapErr()}`))
		end

		return Result.err((`failed to construct stat value for stat {data.Type}: {v2:unwrapErr()}`))
	end,
	fromLegacyName = function(value: string, variant: string?)
		if value:find(">") then
			variant = value:split(">")[2]
			value = value:split(">")[1]
		end

		if value:find("/") then
			variant = value:split("/")[2]
			value = value:split("/")[1]
		end

		if variant == nil then
			if value:find("Cooldown") then
				if value:find("Gun") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "Cooldown",
						Variant = "Gun"
					})))
				end

				if value:find("Sword") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "Cooldown",
						Variant = "Sword"
					})))
				end

				if value:find("Fruit") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "Cooldown",
						Variant = "Fruit"
					})))
				end

				if value:find("Melee") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "Cooldown",
						Variant = "Melee"
					})))
				else
					Result.err((`unknown variant for Cooldown in name: "{value}"`))
				end
			end

			if value:find("DashLength") then
				if value == "DashLength" then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "DashLength",
						Variant = "All"
					})))
				end

				if value:find("Ground") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "DashLength",
						Variant = "Ground"
					})))
				end

				if value:find("Air") then
					return Result.ok((table.freeze({
						StatType = "Complex",
						Type = "DashLength",
						Variant = "Air"
					})))
				else
					Result.err((`unknown variant for DashLength in name: "{value}"`))
				end
			end

			local simpleType, v2 = Types.SimpleType(value)

			if simpleType then
				return Result.ok((table.freeze({
					StatType = "Simple",
					Type = value
				})))
			end

			return Result.err((`unknown legacy stat: "{value}": {v2}`))
		else
			local variantType, v2 = Types.VariantType(variant)

			if not variantType then
				return Result.err((`unknown variant type: "{variant}": {v2}`))
			end

			local complexType, _ = Types.ComplexType(value)

			if complexType then
				return Result.ok((table.freeze({
					StatType = "Complex",
					Type = value,
					Variant = variant
				})))
			end

			if variant then
				return Result.err((`unknown legacy stat: "{value}" with variant "{variant}"`))
			end

			return Result.err((`unknown legacy stat: "{value}"`))
		end
	end,
	toLegacyName = function(data, format)
		local function solveAsArrow()
			if data.Type == "Cooldown" then
				if data.Variant == "All" then
					return Result.ok("AllCooldown")
				end

				if data.Variant == "Sword" then
					return Result.ok("SwordCooldown")
				end

				if data.Variant == "Fruit" then
					return Result.ok("FruitCooldown")
				end

				if data.Variant == "Melee" then
					return Result.ok("MeleeCooldown")
				end

				if data.Variant == "FlashStep" then
					return Result.ok("FlashstepCooldown")
				end

				if data.Variant == "Gun" then
					return Result.ok("GunCooldown")
				end

				return Result.err((`unknown variant for Cooldown: "{tostring(data.Variant)}"`))
			elseif data.Type == "DashLength" then
				if data.StatType ~= "Complex" then
					return Result.err("DashLength must be of Complex type")
				end

				if data.Variant == "All" then
					return Result.ok("DashLength")
				end

				if data.Variant == "Ground" then
					return Result.ok("DashLengthGround")
				end

				if data.Variant == "Air" then
					return Result.ok("DashLengthAir")
				end

				return Result.err((`unknown variant for DashLength: "{tostring(data.Variant)}"`))
			elseif data.StatType == "Simple" then
				local simpleType, v2 = Types.SimpleType(data.Type)

				if simpleType then
					return Result.ok(data.Type)
				end

				return Result.err((`unknown stat type for legacy name: "{data.Type}": {v2}`))
			else
				if data.StatType ~= "Complex" then
					return Result.err((`unknown stat type for legacy name: "{data.Type}"`))
				end

				local complexType, v2 = Types.ComplexType(data.Type)

				if not complexType then
					return Result.err((`unknown stat type for legacy name: "{data.Type}": {v2}`))
				end

				if data.Variant == nil then
					return Result.err((`missing variant for complex stat type: "{data.Type}"`))
				end

				return Result.ok((`{data.Type}>{data.Variant}`))
			end
		end

		local v2 = solveAsArrow()
		return Result.match(v2, function(value: string)
			if format == "Arrow" or format == "Slash" then
				if format == "Slash" then
					value = value:gsub(">", "/")
				end

				return Result.ok((table.freeze({
					Format = format,
					Value = value
				})))
			else
				local name = value:split("<")[1]
				local variant = value:split("<")[2]
				return Result.ok((table.freeze({
					Format = "Split",
					Name = name,
					Variant = variant
				})))
			end
		end, function(p2: string)
			return Result.err(p2)
		end)
	end
}

if not GlobalUtil.FFlags.IsUnitTest then
	return Stat
end

local v2 = {}
local v3 = {}

for k, v4 in DEFINITIONS do
	local fullType, v5 = Types.FullType(k)

	if not fullType then
		table.insert(v3, (`Invalid StatTypes.FullType "{k}": {v5}`))
	end

	if v4.StatType == "Complex" then
		for _, variant in v4.Variants do
			v2[`{k}>{variant.Index.Key}`] = true
		end
	else
		v2[k] = true
	end
end

for k in v2 do
	local v4 = Stat.fromLegacyName(k)

	if v4:isErr() then
		table.insert(v3, (`Failed to convert legacy name "{k}": {v4:unwrapErr()}`))
	else
		local unwrapped = v4:unwrap()
		local legacyName = Stat.toLegacyName(unwrapped, "Arrow")

		if legacyName:isErr() then
			table.insert(
				v3,
				(`Failed to convert back to legacy name from StatTypes.StatIndex for "{k}": {legacyName:unwrapErr()}`)
			)
		else
			local solve = Stat.solve(
				unwrapped,
				unwrapped.Type == "Energy" and "+1" or unwrapped.Type == "JumpHeight" and "+1" or 1
			)

			if solve:isErr() then
				table.insert(v3, (`Failed to solve StatTypes.StatValue for "{k}": {solve:unwrapErr()}`))
			end
		end
	end
end

if #v3 > 0 then
	error("Errors in StatDefinitions:\n" .. table.concat(v3, "\n"))
end

return Stat