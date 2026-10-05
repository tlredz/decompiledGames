local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Result = require(game.ReplicatedStorage.Packages.Result)
local Future = require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local metatable = getmetatable((Future.from(function()
	return false
end)))
local TypeUtil = {
	convert = function(p, callback)
		local v, v2 = callback(p)

		if v then
			return Result.ok(p)
		end

		assert(v2, (`Type checker failed for {p} but did not provide an error message`))
		return Result.err(v2)
	end
}
TypeUtil.Types = {
	IsoDate = function(value)
		if typeof(value) ~= "string" then
			return false, (`string expected, got "{typeof(value)}"`)
		end

		if DateTime.fromIsoDate(value) then
			return true
		end

		return false, (`couldn't parse "{value}" into DateTime.fromIsoDate`)
	end,
	BoxName = function(childName)
		if type(childName) ~= "string" then
			return false, (`expected box-name to be of type string, got type "{type(childName)}"`)
		end

		if game.ServerStorage.BoxData:FindFirstChild(childName) then
			return true
		end

		return false, (`no box found with name "{childName}"`)
	end,
	ItemId = function(...)
		local v = { ... }
		return function(value)
			if type(value) ~= "number" then
				return false, (`bad value type: "{typeof(value)}"`)
			end

			local dataFromId = ItemId.getDataFromId(value)

			if dataFromId:isErr() then
				return false, (`bad item-id "{value}": {dataFromId:unwrapErr().Type}`)
			end

			local unwrapped = dataFromId:unwrap()
			local v2 = #v == 0

			for _, v4 in v do
				if unwrapped.Type ~= v4 then
					continue
				end

				v2 = true
				break
			end

			if v2 then
				return true
			end

			return
				false,
				(`bad id-type for #{unwrapped.ItemId}{unwrapped.ItemId == value and "" or ` (redirected from #{value})`}: "{unwrapped.Type}". Expected {HttpService:JSONEncode(v)}`)
		end
	end,
	SpriteKey = function(value)
		if type(value) ~= "string" then
			return false, (`expected sprite-key to be of type string, got type "{type(value)}"`)
		end

		if Spritesheets.match(value):asNullable() then
			return true
		end

		return false, (`no sprite found at "{value}"`)
	end,
	Future = function(callback)
		return function(object)
			if typeof(object) ~= "table" or getmetatable(object) ~= metatable then
				return false, (`bad value: "{typeof(object)}"`)
			end

			return callback((object:await()))
		end
	end,
	Tuple = function(...)
		local v = { ... }
		return function(...)
			local v2 = { ... }

			if #v2 > #v then
				return false, (`expected max {#v} parameters, got {#v2}`)
			end

			for k, v3 in v do
				local v4, v5 = v3(v2[k])

				if not v4 then
					return false, (`parameter {k}: {v5}`)
				end
			end

			return true, nil
		end
	end,
	Function = function(callback, callback2, items)
		return function(callback3)
			if typeof(callback3) ~= "function" then
				return false, (`bad value: "{typeof(callback3)}"`)
			end

			for k, item in pairs(items) do
				local v, v2 = callback(unpack(item.inputs))

				if not v then
					return false, (`test {item.name or k} input: {v2}`)
				end

				local v3 = nil
				local v4 = item
				local success, result = pcall(function()
					v3 = { callback3(unpack(v4.inputs)) }
				end)

				if not success then
					return false, (`test {item.name or k} call: {result}`)
				end

				assert(v3, "unreachable")
				local v5, v6 = callback2(unpack(v3))

				if not v5 then
					return false, (`test {item.name or k} output: {v6}`)
				end
			end

			return true, nil
		end
	end,
	ImageData = Type.strictInterface({
		Image = Type.union(Type.string, function(p)
			if typeof(p) == "Content" then
				return true, nil
			end

			return false, (`bad value: "{typeof(p)}"`)
		end),
		ImageRectOffset = Type.optional(Type.Vector2),
		ImageRectSize = Type.optional(Type.Vector2)
	}),
	Sprite = Type.strictInterface({
		Image = Type.string,
		ImageRectOffset = Type.Vector2,
		ImageRectSize = Type.Vector2
	}),
	UserId = function(value)
		if typeof(value) == "number" then
			return Result.match(TypeUtil.convert(value, Type.integer), function(p: number)
				if RunService:IsStudio() == true then
					return true, nil
				end

				if p < 0 then
					return false, "userId cannot be negative"
				end

				return true, nil
			end, function(p)
				return false, p
			end)
		end

		return false, (`bad value: "{typeof(value)}"`)
	end,
	FrozenTable = function(list)
		if typeof(list) ~= "table" then
			return false, (`bad value: "{typeof(list)}"`)
		end

		if table.isfrozen(list) then
			return true, nil
		end

		return false, "table is not frozen"
	end,
	BetterLiteral = function(...)
		local v = { ... }
		return function(p)
			for _, v2 in v do
				if p == v2 then
					return true, nil
				end
			end

			return false, (`bad value: "{p}"`)
		end
	end,
	BetterUnion = function(items)
		return function(p)
			local count = 0
			local v = {}

			for k, item in pairs(items) do
				local v2, v3 = item(p)

				if v2 then
					count += 1
					v[k] = true
				else
					v[k] = v3
				end
			end

			if count == 1 then
				return true, nil
			end

			local v2 = {}

			for k, v3 in pairs(v) do
				if v3 ~= true then
					table.insert(v2, " - " .. k .. ": " .. tostring(v3))
				end
			end

			return false, table.concat(v2, "\n")
		end
	end,
	Metatable = function(p)
		return function(p2)
			if typeof(p2) ~= "table" then
				return false, (`bad metatable value: "{typeof(p2)}"`)
			end

			if getmetatable(p2) == p then
				return true, nil
			end

			return false, "bad metatable"
		end
	end,
	StrictInterface = function(items)
		return function(items2)
			if type(items2) ~= "table" then
				return false, (`expected table, got type "{type(items2)}"`)
			end

			local v = {}
			local v2 = {}

			for k, item in items do
				local v3, v4 = item(items2[k])

				if v3 then
					continue
				end

				v[k] = true
				table.insert(v2, (`bad field "{k}": {v4}`))
			end

			for k, _ in items2 do
				if v[k] or items[k] ~= nil then
					continue
				end

				table.insert(v2, (`unexpected field "{k}"`))
			end

			if #v2 > 0 then
				return false, table.concat(v2, "\n")
			end

			return true
		end
	end
}
return TypeUtil