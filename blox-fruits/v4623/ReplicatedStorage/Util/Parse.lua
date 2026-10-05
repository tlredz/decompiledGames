local HttpService = game:GetService("HttpService")
local Type = require(game.ReplicatedStorage.Packages.Type)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)

local function fn(value)
	if typeof(value) ~= "number" then
		return false, (`bad item id: {value} ({typeof(value)})`)
	end

	local dataFromId = ItemId.getDataFromId(value)

	if dataFromId:isOk() then
		return true, nil
	end

	return false, (`bad item id {value}: {dataFromId:unwrapErr()}`)
end

function roundToHuge(p: number)
	if p >= 9e18 then
		return 1e999
	end

	if p <= -9e18 then
		return -1e999
	end

	return p
end

local Parse = {
	Nil = function(value)
		if type(value) == "string" then
			if value:gsub("%s+", ""):len() <= 0 then
				return {
					Ok = true,
					Value = nil
				}
			end

			return {
				Ok = false,
				Message = `non-empty string: "{value}"`
			}
		elseif type(value) == "nil" then
			return {
				Ok = true,
				Value = nil
			}
		else
			return {
				Ok = false,
				Message = `non-nullable type "{type(value)}"`
			}
		end
	end,
	String = function(value)
		if type(value) ~= "string" then
			return {
				Ok = false,
				Message = `bad string type "{type(value)}"`
			}
		end

		if value:gsub("%s+", ""):len() > 0 then
			return {
				Ok = true,
				Value = value
			}
		end

		return {
			Ok = false,
			Message = `empty string: "{value}"`
		}
	end,
	Table = function(value)
		if type(value) == "table" then
			return {
				Ok = true,
				Value = value
			}
		end

		if type(value) ~= "string" then
			return {
				Ok = false,
				Message = `bad string type "{type(value)}"`
			}
		end

		local v = nil
		local success, result = pcall(function()
			v = HttpService:JSONDecode(value)
		end)

		if not success then
			return {
				Ok = false,
				Message = `string "{value}" to table decode failed: "{result}"`
			}
		end

		if v == nil then
			return {
				Ok = false,
				Message = `string decoded into nil table: "{value}"`
			}
		end

		return {
			Ok = true,
			Value = v
		}
	end
}

function Parse.HexString(p)
	local string2 = Parse.String(p)

	if string2.Ok == false then
		return string2
	end

	local value = string2.Value

	if value:sub(1, 1) ~= "#" then
		return {
			Ok = false,
			Message = `background color hex must start with #: "{value}"`
		}
	end

	if value:len() == 7 then
		return {
			Ok = true,
			Value = value
		}
	end

	return {
		Ok = false,
		Message = `bad background color length: "{value}", expected 7, got {value:len()}`
	}
end

function Parse.Color3(p)
	local hexString = Parse.HexString(p)

	if hexString.Ok == false then
		return hexString
	end

	return {
		Ok = true,
		Value = Color3.fromHex(hexString.Value)
	}
end

function Parse.Number(value)
	if typeof(value) == "number" then
		return {
			Ok = true,
			Value = roundToHuge(value)
		}
	end

	if typeof(value) ~= "string" then
		return {
			Ok = false,
			Message = `bad type: {typeof(value)}`
		}
	end

	local string2 = Parse.String(value)

	if string2.Ok == false then
		return string2
	end

	local v = string2.Value:gsub(",", ""):gsub("%$", "")

	if v:sub(-1) == "%" then
		local v2 = tonumber((v:sub(1, -2)))

		if v2 then
			return {
				Ok = true,
				Value = roundToHuge(v2 / 100)
			}
		end

		return {
			Ok = false,
			Message = `bad percentage string: "{value}"`
		}
	else
		local v2 = tonumber(v)

		if v2 then
			return {
				Ok = true,
				Value = roundToHuge(v2)
			}
		end

		return {
			Ok = false,
			Message = `bad number string: "{v}"`
		}
	end
end

function Parse.Boolean(value)
	if typeof(value) == "boolean" then
		return {
			Ok = true,
			Value = value
		}
	end

	if typeof(value) ~= "string" then
		return {
			Ok = false,
			Message = `bad type: {typeof(value)}`
		}
	end

	local string2 = Parse.String(value)

	if string2.Ok == false then
		return string2
	end

	local value2 = string2.Value

	if value2:upper() == "TRUE" or value2:upper() == "FALSE" then
		return {
			Ok = true,
			Value = value2:upper() == "TRUE"
		}
	end

	return {
		Ok = false,
		Message = `can't parse boolean from text: "{value}"`
	}
end

function Parse.And(callback, callback2, ...)
	local v = { callback2, ... }
	return function(p)
		local v2 = callback(p)

		if v2.Ok == false then
			return v2
		end

		for k, v3 in v do
			local v4, v5 = v3(v2.Value)

			if not v4 then
				return {
					Ok = false,
					Message = `rule #{k} failed: "{v5}"`
				}
			end
		end

		return {
			Ok = true,
			Value = v2.Value
		}
	end
end

function Parse.Or(callback, callback2, ...)
	local v = { callback2, ... }
	return function(p)
		local v2 = callback(p)

		if v2.Ok == false then
			return v2
		end

		local v3 = {}

		for _, v4 in v do
			local v5, v6 = v4(v2.Value)

			if v5 then
				return {
					Ok = true,
					Value = v2.Value
				}
			end

			if v6 then
				table.insert(v3, v6)
			end
		end

		return {
			Ok = false,
			Message = `rules failed: [{table.concat(v3, ",")}]"`
		}
	end
end

function Parse.Optional(callback)
	return function(p)
		local v = Parse.Nil(p)

		if v.Ok then
			return v
		end

		return callback(p)
	end
end

Parse.SpriteKey = Parse.And(Parse.String, function(value)
	if typeof(value) == "string" and (Spritesheets.MAP_WITH_EXT[value] or Spritesheets.MAP[value]) then
		return true, nil
	end

	return false, (`bad sprite key: "{value}"`)
end)

function Parse.Sprite(value)
	if typeof(value) ~= "string" then
		return {
			Ok = false,
			Message = `expected sprite key to be string, received "{type(value)}"`
		}
	end

	local v = Spritesheets.MAP_WITH_EXT[value] or Spritesheets.MAP[value]

	if v == nil then
		return {
			Ok = false,
			Message = `no sprite found at key "{value}"`
		}
	end

	return {
		Ok = true,
		Value = v
	}
end

Parse.RarityType = Parse.And(
	Parse.String,
	Type.literal("Common", "Uncommon", "Rare", "Legendary", "Mythical", "Premium")
)

function Parse.RarityDataFromType(p)
	local rarityType = Parse.RarityType(p)

	if rarityType.Ok == false then
		return rarityType
	end

	local value = rarityType.Value
	local v = RarityUtil.tryGetRarity(value)

	if v then
		return {
			Ok = true,
			Value = v
		}
	end

	return {
		Ok = false,
		Message = `no rarity data for type "{value}"`
	}
end

function Parse.RarityValueFromType(p)
	local rarityDataFromType = Parse.RarityDataFromType(p)

	if rarityDataFromType.Ok == false then
		return rarityDataFromType
	end

	return {
		Ok = true,
		Value = rarityDataFromType.Value.Value
	}
end

Parse.Integer = Parse.And(Parse.Number, function(value)
	if type(value) ~= "number" then
		return false, (`expected type "number", got type "{type(value)}"`)
	end

	if value % 1 == 0 or math.abs(value) == 1e999 then
		return true
	end

	return false, (`number "{value}" is not an integer`)
end)
Parse.UnsignedInteger = Parse.And(Parse.Integer, Type.numberMin(0))
Parse.ArrayIndex = Parse.And(Parse.Integer, Type.numberMinExclusive(0))
Parse.Percent = Parse.And(Parse.Number, Type.numberConstrained(0, 1))
Parse.ItemId = Parse.And(Parse.Integer, fn)
Parse.ItemIdType = Parse.And(Parse.String, function(value)
	local unwrapped = ItemId.getTypes():unwrap()

	if typeof(value) ~= "string" then
		return false, (`bad item id type: "{value}" ({typeof(value)})`)
	end

	if table.find(unwrapped, value) then
		return true, nil
	end

	return false, (`couldn't find id type "{value}"`)
end)

function Parse.ItemIdOfType(p)
	local v = {}

	for _, v2 in type(p) ~= "table" and { p } or p do
		local v3 = v2
		table.insert(v, function(value)
			if typeof(value) ~= "number" then
				return false, (`bad item id: {value} ({typeof(value)})`)
			end

			local dataFromId = ItemId.getDataFromId(value)

			if not dataFromId:isOk() then
				return false, (`bad item id {value}: {dataFromId:unwrapErr()}`)
			end

			if dataFromId:unwrap().Type == v3 then
				return true, nil
			end

			return false, (`expected type "{v3}" for #{value}, got "{dataFromId:unwrap().Type}"`)
		end)
	end

	return Parse.Or(Parse.ItemId, table.unpack(v))
end

Parse.ItemIdLabel = Parse.And(function(value)
	if type(value) ~= "string" then
		return {
			Ok = false,
			Message = `expected string, received type "{type(value)}"`
		}
	end

	local match = value:match("%[.-%-(%d+)%]")

	if not match then
		return {
			Ok = false,
			Message = `failed to extract item-id integer from "{value}"`
		}
	end

	local v = tonumber(match)

	if v then
		return {
			Ok = true,
			Value = v
		}
	end

	return {
		Ok = false,
		Message = `failed to parse item-id number str ({match}) from "{value}"`
	}
end, fn)

function Parse.Map(callback, callback2)
	return function(p)
		local table2 = Parse.Table(p)

		if table2.Ok == false then
			return table2
		end

		local v = {}

		for k, v2 in table2.Value do
			local v3 = callback(k)

			if v3.Ok == false then
				return v3
			end

			local v4 = callback2(v2)

			if v4.Ok == false then
				return {
					Ok = false,
					Message = `bad value for key "{v3.Value}": "{v4.Message}"`
				}
			end

			if v[v3.Value] ~= nil then
				return {
					Ok = false,
					Message = `duplicate key "{v3.Value}"`
				}
			end

			v[v3.Value] = v4.Value
		end

		return {
			Ok = true,
			Value = v
		}
	end
end

function Parse.Union(callback, callback2, ...)
	local v = { callback, callback2, ... }
	return function(p)
		local messages = {}

		for _, v2 in v do
			local v3 = v2(p)

			if v3.Ok == true then
				return {
					Ok = true,
					Value = v3.Value
				}
			else
				table.insert(messages, v3.Message)
			end
		end

		return {
			Ok = false,
			Message = `all unioned parsers failed: [{table.concat(messages, ",")}]"`
		}
	end
end

function Parse.Array(callback, flag: boolean?)
	local mapped = Parse.Map(Parse.ArrayIndex, callback)

	if flag ~= true then
		mapped = Parse.Union(mapped, function(p)
			local string2 = Parse.String(p)

			if string2.Ok ~= false then
				local v = string.split(string2.Value, ", ")
				return mapped(v)
			end

			if Parse.Nil(p).Ok == true then
				return {
					Ok = true,
					Value = {}
				}
			end

			return string2
		end)
	end

	return Parse.And(mapped, function(list)
		local count = 0

		for _, _ in list do
			count += 1
		end

		if #list == count then
			return true, nil
		end

		return false, (`array is not continuous, expected {count} keys, array length is {#list}`)
	end)
end

function Parse.OfSize(callback, callback2)
	return function(p)
		local v = callback(p)

		if v.Ok == false then
			return v
		end

		local v2, v3 = callback2(#v.Value)

		if v2 then
			return {
				Ok = true,
				Value = v.Value
			}
		end

		return {
			Ok = false,
			Message = `array was not a valid size: {v3}`
		}
	end
end

function Parse.StrictTranslate(p)
	return function(p2)
		local v = p[p2]

		if v == nil then
			return {
				Ok = false,
				Message = `unknown key: "{p2}"`
			}
		end

		return {
			Ok = true,
			Value = v
		}
	end
end

function Parse.PseudoEnumItem(p)
	local enumItems = PseudoEnum.getEnumItems(p)
	local literal = Type.literal(table.unpack(enumItems))
	return Parse.And(Parse.String, literal)
end

function Parse.Translate(p)
	return function(p2)
		local v = p[p2]

		if v == nil then
			return {
				Ok = true,
				Value = p2
			}
		end

		return {
			Ok = true,
			Value = v
		}
	end
end

function Parse.Any(p)
	if type(p) == "nil" then
		return {
			Ok = false,
			Message = "value is type \"nil\""
		}
	end

	return {
		Ok = true,
		Value = p
	}
end

function Parse.Chain(callback, callback2, ...)
	local v = { callback, callback2, ... }
	return function(value)
		for i, v2 in ipairs(v) do
			local v3 = v2(value)

			if v3.Ok == false then
				return {
					Ok = false,
					Message = `parse chain failed at index {i}: "{v3.Message}"`
				}
			else
				value = v3.Value
			end
		end

		return {
			Ok = true,
			Value = value
		}
	end
end

function Parse.Merge(callback, callback2, callback3, ...)
	local v = { callback2, callback3, ... }
	return function(p)
		local v2 = table.create(#v)

		for i, v3 in ipairs(v) do
			local v4 = v3(p)

			if v4.Ok == false then
				return {
					Ok = false,
					Message = `merge failed at index {i}: "{v4.Message}"`
				}
			else
				v2[i] = v4.Value
			end
		end

		return callback(table.unpack(v2, 1, #v2))
	end
end

function Parse.Static(p)
	return function(_)
		return {
			Ok = true,
			Value = p
		}
	end
end

function Parse.Interface(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	return function(p)
		local table2 = Parse.Table(p)

		if table2.Ok == false then
			return table2
		end

		local value = table2.Value
		local v2 = {}

		for _, v3 in v do
			local v4 = value[v3]
			local item = items[v3]

			if item == nil then
				continue
			end

			if v2[v3] ~= nil then
				return {
					Ok = false,
					Message = `duplicate key "{v3}"`
				}
			end

			local v5 = item(v4)

			if v5.Ok == false then
				return {
					Ok = false,
					Message = `bad value for key "{v3}": "{v5.Message}"`
				}
			else
				v2[v3] = v5.Value
			end
		end

		return {
			Ok = true,
			Value = v2
		}
	end
end

function Parse.StrictInterface(p)
	return function(p2)
		local table2 = Parse.Table(p2)

		if table2.Ok == false then
			return table2
		end

		local v = {}

		for k, v2 in table2.Value do
			local string2 = Parse.String(k)

			if string2.Ok == false then
				return string2
			end

			local v3 = p[string2.Value]

			if v3 == nil then
				return {
					Ok = false,
					Message = `unexpected key "{string2.Value}"`
				}
			end

			if v[string2.Value] ~= nil then
				return {
					Ok = false,
					Message = `duplicate key "{string2.Value}"`
				}
			end

			local v4 = v3(v2)

			if v4.Ok == false then
				return {
					Ok = false,
					Message = `bad value for key "{string2.Value}": "{v4.Message}"`
				}
			else
				v[string2.Value] = v4.Value
			end
		end

		return {
			Ok = true,
			Value = v
		}
	end
end

return Parse