local function IsEqual(value, value2)
	if rawequal(value, value2) then
		return true
	end

	return type(value) == "number" and type(value2) == "number" and value ~= value and value2 ~= value2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsASCII(value: string)
	for i = 1, string.len(value) do
		local v = string.byte(value, i)

		if v < 32 or v > 126 then
			return false
		end
	end

	return true
end

local function IsFinite(p: number)
	return p == p and p ~= 1e999 and p ~= -1e999
end

local function IsInteger(p: number)
	return math.floor(p) == p and p ~= 1e999 and p ~= -1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LuaString(p: string)
	local v, _ = string.format("%q", p):gsub("\n", "n")
	return v
end

local function StringRep(value)
	if type(value) == "string" then
		return LuaString(value)
	end

	if typeof(value) == "Instance" then
		return value:GetFullName()
	end

	return (tostring(value))
end

local function SafeKeyStringRep(value)
	if type(value) == "number" or type(value) == "boolean" then
		return (`{value}`)
	end

	if type(value) == "string" then
		local v = utf8.len(value)

		if not v then
			return "InvalidUTF8"
		end

		-- equivalent call inferred; original call site unknown
		if not IsASCII(value) then
			return "NonASCII"
		end

		if v > 30 then
			return (`{LuaString(string.sub(value, 1, 30))}...{v - 30}`)
		else
			return LuaString(value)
		end
	elseif typeof(value) == "Instance" then
		return value:GetFullName()
	else
		return (`UnknownType({typeof(value)})`)
	end
end

local function StripErrorSource(p)
	local v = tostring(p)
	local v2, v3 = string.match(v, "^(.*:%d+): (.+)$")

	if v2 then
		return v3 or v
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ParseError(result)
	local v = tostring(result)
	local v2, v3 = string.match(v, "^(.*:%d+): (.+)$")

	if v2 then
		v = v3 or v
	end

	local v4
	v, v4 = string.match(v, "^(.+) $(%[.+)$")

	if v and v4 then
	end

	return v, v4
end

local function MakeError(p: string, p2: string)
	return (`{p} ${p2}`)
end

local v = {
	IsCFrameFinite = function(cframe: CFrame)
		local components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = cframe:GetComponents()
		local v13 = components + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12
		return v13 == v13 and v13 ~= 1e999 and v13 ~= -1e999
	end,
	IsVector2Finite = function(point: Vector2)
		local v2 = point.X + point.Y
		return v2 == v2 and v2 ~= 1e999 and v2 ~= -1e999
	end,
	IsVector3Finite = function(vector: Vector3)
		local v2 = vector.X + vector.Y + vector.Z
		return v2 == v2 and v2 ~= 1e999 and v2 ~= -1e999
	end
}

function v.Array(callback)
	v.Function(callback)
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local v2 = rawlen(items)
		local count = 0

		for k, item in pairs(items) do
			count += 1

			if k ~= count then
				error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end

			if v2 < count then
				error(`IndexOverflow ${`[{count}]`}`, 2)
			end

			local success, result = pcall(callback, item)

			if success then
				continue
			end

			local error2, v4 = ParseError(result) -- equivalent call inferred; original call site unknown
			error(`{error2} ${`[{count}]{v4 or ""}`}`, 2)
		end

		if v2 ~= count then
			error("LengthMismatch", 2)
		end

		return items
	end
end

function v.ArrayCoerce(callback)
	v.Function(callback)
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local v2 = rawlen(items)
		local count = 0
		local result = {}

		for k, item in pairs(items) do
			count += 1

			if k ~= count then
				error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end

			if v2 < count then
				error(`IndexOverflow ${`[{count}]`}`, 2)
			end

			local success, result2 = pcall(callback, item)

			if not success then
				local error2, v4 = ParseError(result2) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`[{count}]{v4 or ""}`}`, 2)
			end

			result[k] = result2
		end

		if v2 ~= count then
			error("LengthMismatch", 2)
		end

		return result
	end
end

function v.UniqueArray(callback)
	v.Function(callback)
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local v2 = rawlen(items)
		local count = 0
		local v3 = {}

		for k, item in pairs(items) do
			count += 1

			if k ~= count then
				error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end

			if v2 < count then
				error(`IndexOverflow ${`[{count}]`}`, 2)
			end

			if v3[item] then
				error(`UniqueArray ${`[{count}]`}`, 2)
			end

			v3[item] = true

			if not v3[item] then
				error(`InvalidKey ${`[{count}]`}`, 2)
			end

			local success, result = pcall(callback, item)

			if success then
				continue
			end

			local error2, v5 = ParseError(result) -- equivalent call inferred; original call site unknown
			error(`{error2} ${`[{count}]{v5 or ""}`}`, 2)
		end

		if v2 ~= count then
			error("LengthMismatch", 2)
		end

		return items
	end
end

function v.UniqueArrayCoerce(callback)
	v.Function(callback)
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local v2 = rawlen(items)
		local count = 0
		local v3 = {}
		local result = {}

		for k, item in pairs(items) do
			count += 1

			if k ~= count then
				error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end

			if v2 < count then
				error(`IndexOverflow ${`[{count}]`}`, 2)
			end

			if v3[item] then
				error(`UniqueArray ${`[{count}]`}`, 2)
			end

			v3[item] = true

			if not v3[item] then
				error(`InvalidKey ${`[{count}]`}`, 2)
			end

			local success, result2 = pcall(callback, item)

			if not success then
				local error2, v5 = ParseError(result2) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`[{count}]{v5 or ""}`}`, 2)
			end

			result[k] = result2
		end

		if v2 ~= count then
			error("LengthMismatch", 2)
		end

		return result
	end
end

function v.Map(callback, callback2, value: number?)
	v.Function(callback)
	v.Function(callback2)
	v.Optional(v.IntegerPositive)(value)
	local v2 = value or 1e999
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local count = 0

		for k, item in pairs(items) do
			count += 1

			if v2 < count then
				error(`LengthLimit({v2})`, 2)
			end

			local success, result = pcall(callback, k)

			if not success then
				local error2, v4 = ParseError(result) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`<{SafeKeyStringRep(k)}>{v4 or ""}`}`, 2)
			end

			local success2, result2 = pcall(callback2, item)

			if success2 then
				continue
			end

			local error3, v4 = ParseError(result2) -- equivalent call inferred; original call site unknown
			error(`{error3} ${`[{SafeKeyStringRep(k)}]{v4 or ""}`}`, 2)
		end

		return items
	end
end

function v.MapCoerce(callback, callback2, value: number?)
	v.Function(callback)
	v.Function(callback2)
	v.Optional(v.IntegerPositive)(value)
	local v2 = value or 1e999
	return function(items)
		if type(items) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items) ~= nil then
			error("metatable", 2)
		end

		local count = 0
		local result = {}

		for k, item in pairs(items) do
			count += 1

			if v2 < count then
				error(`LengthLimit({v2})`, 2)
			end

			local success, result2 = pcall(callback, k)

			if not success then
				local error2, v4 = ParseError(result2) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`<{SafeKeyStringRep(k)}>{v4 or ""}`}`, 2)
			end

			local success2, result3 = pcall(callback2, item)

			if not success2 then
				local error2, v4 = ParseError(result3) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`[{SafeKeyStringRep(k)}]{v4 or ""}`}`, 2)
			end

			result[result2] = result3
		end

		return result
	end
end

function v.Table(items)
	v.NoMetatable(items)

	for _, item in pairs(items) do
		v.Function(item)
	end

	local clone = table.clone(items)
	return function(items2)
		if type(items2) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items2) ~= nil then
			error("metatable", 2)
		end

		if rawlen(clone) ~= rawlen(items2) then
			error("LengthMismatch", 2)
		end

		for k, _ in pairs(items2) do
			if not clone[k] then
				error(`UnknownKey ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end
		end

		for k, callback in pairs(clone) do
			local item = items2[k]
			local success, result = pcall(callback, item)

			if success then
				continue
			end

			local error2, v3 = ParseError(result) -- equivalent call inferred; original call site unknown
			local fullName

			if type(k) == "string" then
				local v5
				fullName, v5 = string.format("%q", k):gsub("\n", "n")
			elseif typeof(k) == "Instance" then
				fullName = k:GetFullName()
			else
				fullName = tostring(k)
			end

			error(`{error2} ${`[{fullName}]{v3 or ""}`}`, 2)
		end

		return items2
	end
end

function v.TablePermissive(items)
	v.NoMetatable(items)

	for _, item in pairs(items) do
		v.Function(item)
	end

	local clone = table.clone(items)
	return function(p)
		if type(p) ~= "table" then
			error("table", 2)
		end

		if getmetatable(p) ~= nil then
			error("metatable", 2)
		end

		if rawlen(clone) ~= rawlen(p) then
			error("LengthMismatch", 2)
		end

		for k, callback in pairs(clone) do
			local v2 = p[k]
			local success, result = pcall(callback, v2)

			if success then
				continue
			end

			local error2, v4 = ParseError(result) -- equivalent call inferred; original call site unknown
			local fullName

			if type(k) == "string" then
				local v6
				fullName, v6 = string.format("%q", k):gsub("\n", "n")
			elseif typeof(k) == "Instance" then
				fullName = k:GetFullName()
			else
				fullName = tostring(k)
			end

			error(`{error2} ${`[{fullName}]{v4 or ""}`}`, 2)
		end

		return p
	end
end

function v.TableCoerce(items)
	v.NoMetatable(items)

	for _, item in pairs(items) do
		v.Function(item)
	end

	local clone = table.clone(items)
	return function(items2)
		if type(items2) ~= "table" then
			error("table", 2)
		end

		if getmetatable(items2) ~= nil then
			error("metatable", 2)
		end

		if rawlen(clone) ~= rawlen(items2) then
			error("LengthMismatch", 2)
		end

		local result = {}

		for k, _ in pairs(items2) do
			if not clone[k] then
				error(`UnknownKey ${`[{SafeKeyStringRep(k)}]`}`, 2)
			end
		end

		for k, callback in pairs(clone) do
			local item = items2[k]
			local success, result2 = pcall(callback, item)

			if not success then
				local error2, v3 = ParseError(result2) -- equivalent call inferred; original call site unknown
				local fullName

				if type(k) == "string" then
					local v5
					fullName, v5 = string.format("%q", k):gsub("\n", "n")
				elseif typeof(k) == "Instance" then
					fullName = k:GetFullName()
				else
					fullName = tostring(k)
				end

				error(`{error2} ${`[{fullName}]{v3 or ""}`}`, 2)
			end

			result[k] = result2
		end

		return result
	end
end

function v.IsASCII(value: string)
	if type(value) == "string" then
		for i = 1, string.len(value) do
			local v3 = string.byte(value, i)

			if v3 < 32 or v3 > 126 then
				return false
			end
		end

		return true
	else
		return false
	end
end

function v.IsFinite(value: number)
	return type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999
end

function v.IsInteger(value: number)
	return type(value) == "number" and math.floor(value) == value and value ~= 1e999 and value ~= -1e999
end

function v.IsCFrameFinite(cframe: CFrame)
	if typeof(cframe) == "CFrame" then
		local components, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cframe:GetComponents()
		local v14 = components + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13

		if v14 == v14 and v14 ~= 1e999 then
			return v14 ~= -1e999
		else
			return false
		end
	else
		return false
	end
end

function v.IsVector2Finite(point: Vector2)
	if typeof(point) == "Vector2" then
		local v3 = point.X + point.Y

		if v3 == v3 and v3 ~= 1e999 then
			return v3 ~= -1e999
		else
			return false
		end
	else
		return false
	end
end

function v.Optional(callback)
	if type(callback) ~= "function" then
		error("function", 2)
	end

	return function(p)
		if p == nil then
			return nil
		end

		local success, result = pcall(callback, p)

		if success then
			return result
		end

		local v2 = tostring(result)
		local v3, v4 = string.match(v2, "^(.*:%d+): (.+)$")

		if v3 then
			v2 = v4 or v2
		end

		error(v2, 2)
		return result
	end
end

function v.Default(callback, p)
	if type(callback) ~= "function" then
		error("function", 2)
	end

	local v2 = callback(p)
	return function(p2)
		if p2 == nil then
			return v2
		end

		local success, result = pcall(callback, p2)

		if success then
			return result
		end

		local v3 = tostring(result)
		local v4, v5 = string.match(v3, "^(.*:%d+): (.+)$")

		if v4 then
			v3 = v5 or v3
		end

		error(v3, 2)
		return result
	end
end

function v.AnyOf(...)
	local v2 = table.pack(...)

	for i = 1, v2.n do
		assert(type(v2[i]) == "function", "function")
	end

	assert(v2.n > 0)
	return function(p)
		for i = 1, v2.n do
			local success, result = pcall(v2[i], p)

			if success then
				return result
			end
		end

		error("AnyOf", 2)
	end
end

function v.AllOf(...)
	local v2 = table.pack(...)

	for i = 1, v2.n do
		assert(type(v2[i]) == "function", "function")
	end

	assert(v2.n > 0)
	return function(p)
		for i = 1, v2.n do
			local success, result = pcall(v2[i], p)

			if success then
				continue
			end

			local v3 = tostring(result)
			local v4, v5 = string.match(v3, "^(.*:%d+): (.+)$")

			if v4 then
				v3 = v5 or v3
			end

			error(v3, 2)
		end

		return p
	end
end

function v.AnyTable(p)
	if type(p) ~= "table" then
		error("table", 2)
	end

	return p
end

function v.Number(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	return value
end

function v.Boolean(flag: boolean)
	if type(flag) ~= "boolean" then
		error("boolean", 2)
	end

	return flag
end

function v.Buffer(buf: buffer)
	if type(buf) ~= "buffer" then
		error("buffer", 2)
	end

	return buf
end

function v.Function(callback)
	if type(callback) ~= "function" then
		error("function", 2)
	end

	return callback
end

function v.Thread(thread: thread)
	if type(thread) ~= "thread" then
		error("thread", 2)
	end

	return thread
end

function v.String(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	if not utf8.len(value) then
		error("UTF8", 2)
	end

	return value
end

function v.RawString(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	return value
end

function v.Any(p)
	return p
end

function v.Equals(p)
	return function(value)
		local v2 = p

		if not rawequal(value, v2) and (type(value) ~= "number" or type(v2) ~= "number" or value == value or v2 == v2) then
			error("Equals", 2)
		end

		return value
	end
end

function v.Set(list)
	v.Array(v.Any)
	local v2 = {}

	for _, v3 in ipairs(list) do
		if v3 ~= v3 then
			error("InvalidKeyNaN", 2)
		end

		v2[v3] = true

		if not v2[v3] then
			error("InvalidKey", 2)
		end
	end

	return function(p)
		if not v2[p] then
			error("Set", 2)
		end

		return p
	end
end

function v.Pattern(p: string)
	v.String(p)
	return function(value)
		if type(value) ~= "string" then
			error("string", 2)
		end

		if not utf8.len(value) then
			error("UTF8", 2)
		end

		if not string.find(value, p) then
			error("Pattern", 2)
		end

		return value
	end
end

function v.NoMetatable(p)
	if type(p) ~= "table" then
		error("table", 2)
	end

	if getmetatable(p) ~= nil then
		error("metatable", 2)
	end

	return p
end

function v.Finite(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if value == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Finite", 2)
	end

	return value
end

function v.FinitePositive(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if value == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Finite", 2)
	end

	if not (value > 0) then
		error("Positive", 2)
	end

	return value
end

function v.FiniteNonNegative(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if value == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Finite", 2)
	end

	if not (value >= 0) then
		error("NonNegative", 2)
	end

	return value
end

function v.Positive(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	if not (value > 0) then
		error("Positive", 2)
	end

	return value
end

function v.NonNegative(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	if not (value >= 0) then
		error("NonNegative", 2)
	end

	return value
end

function v.Real(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	if value ~= value then
		error("Real", 2)
	end

	return value
end

function v.Range(p: number, p2: number)
	v.Real(p)
	v.Real(p2)

	if not (p <= p2) then
		error("a<=b", 2)
	end

	return function(value)
		if type(value) ~= "number" then
			error("number", 2)
		end

		if not (p <= value and value <= p2) then
			error(`Range({p},{p2})`, 2)
		end

		return value
	end
end

function v.Integer(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if math.floor(value) == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Integer", 2)
	end

	return value
end

function v.Unsigned32(p: number)
	if bit32.bor(p, 0) ~= p then
		error("Unsigned32", 2)
	end

	return p
end

function v.IntegerPositive(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if math.floor(value) == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Integer", 2)
	end

	if not (value >= 1) then
		error("Positive", 2)
	end

	return value
end

function v.Index(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if math.floor(value) == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Integer", 2)
	end

	if not (value >= 1) then
		error("Positive", 2)
	end

	return value
end

function v.IntegerNonNegative(value: number)
	if type(value) ~= "number" then
		error("number", 2)
	end

	local v2

	if math.floor(value) == value and value ~= 1e999 then
		v2 = value ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		error("Integer", 2)
	end

	if not (value >= 0) then
		error("NonNegative", 2)
	end

	return value
end

function v.IntegerRange(p: number, p2: number)
	v.Integer(p)
	v.Integer(p2)

	if not (p <= p2) then
		error("a<=b", 2)
	end

	return function(value)
		if type(value) ~= "number" then
			error("number", 2)
		end

		local v2

		if math.floor(value) == value and value ~= 1e999 then
			v2 = value ~= -1e999
		else
			v2 = false
		end

		if not v2 then
			error("Integer", 2)
		end

		if not (p <= value and value <= p2) then
			error(`Range({p},{p2})`, 2)
		end

		return value
	end
end

function v.UInt32()
	return function(value)
		if type(value) ~= "number" then
			error("number", 2)
		end

		if bit32.bor(value, 0) ~= value then
			error("UInt32", 2)
		end

		return value
	end
end

function v.StringRange(p: number, p2: number)
	v.Integer(p)
	v.Integer(p2)

	if not (p <= p2) then
		error("a<=b", 2)
	end

	return function(value)
		if type(value) ~= "string" then
			error("string", 2)
		end

		local v2 = utf8.len(value)

		if not v2 then
			error("UTF8", 2)
		end

		if not (p <= v2 and v2 <= p2) then
			error(`StringRange({p},{p2})`, 2)
		end

		return value
	end
end

function v.ASCII(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	for i = 1, string.len(value) do
		local v2 = string.byte(value, i)

		if v2 < 32 or v2 > 126 then
			error("ASCII", 2)
		end
	end

	return value
end

function v.ASCIIRange(p: number, p2: number)
	v.Integer(p)
	v.Integer(p2)

	if not (p <= p2) then
		error("a<=b", 2)
	end

	return function(value)
		if type(value) ~= "string" then
			error("string", 2)
		end

		local v2 = string.len(value)

		if not (p <= v2 and v2 <= p2) then
			error(`ASCIIRange({p},{p2})`, 2)
		end

		for i = 1, v2 do
			local v3 = string.byte(value, i)

			if v3 < 32 or v3 > 126 then
				error("ASCII", 2)
			end
		end

		return value
	end
end

function v.CFrame(cframe: CFrame)
	if typeof(cframe) ~= "CFrame" then
		error("CFrame", 2)
	end

	return cframe
end

function v.CFrameFinite(cframe: CFrame)
	if typeof(cframe) ~= "CFrame" then
		error("CFrame", 2)
	end

	local components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = cframe:GetComponents()
	local v13 = components + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12
	local v14

	if v13 == v13 and v13 ~= 1e999 then
		v14 = v13 ~= -1e999
	else
		v14 = false
	end

	if not v14 then
		error("CFrameFinite", 2)
	end

	return cframe
end

function v.Vector2(point: Vector2)
	if typeof(point) ~= "Vector2" then
		error("Vector2", 2)
	end

	return point
end

function v.Vector2Finite(point: Vector2)
	if typeof(point) ~= "Vector2" then
		error("Vector2", 2)
	end

	local v2 = point.X + point.Y
	local v3

	if v2 == v2 and v2 ~= 1e999 then
		v3 = v2 ~= -1e999
	else
		v3 = false
	end

	if not v3 then
		error("Vector2Finite", 2)
	end

	return point
end

function v.Vector2Unit(point: Vector2)
	if typeof(point) ~= "Vector2" then
		error("Vector2", 2)
	end

	local v2 = point.X + point.Y
	local v3

	if v2 == v2 and v2 ~= 1e999 then
		v3 = v2 ~= -1e999
	else
		v3 = false
	end

	if not v3 then
		error("Vector2Finite", 2)
	end

	if math.abs(point.Magnitude - 1) > 1e-6 then
		error("Vector2Unit", 2)
	end

	return point
end

function v.Vector3(vector: Vector3)
	if typeof(vector) ~= "Vector3" then
		error("Vector3", 2)
	end

	return vector
end

function v.Vector3Finite(vector: Vector3)
	if typeof(vector) ~= "Vector3" then
		error("Vector3", 2)
	end

	local v2 = vector.X + vector.Y + vector.Z
	local v3

	if v2 == v2 and v2 ~= 1e999 then
		v3 = v2 ~= -1e999
	else
		v3 = false
	end

	if not v3 then
		error("Vector3Finite", 2)
	end

	return vector
end

function v.Vector3Unit(vector: Vector3)
	if typeof(vector) ~= "Vector3" then
		error("Vector3", 2)
	end

	local v2 = vector.X + vector.Y + vector.Z
	local v3

	if v2 == v2 and v2 ~= 1e999 then
		v3 = v2 ~= -1e999
	else
		v3 = false
	end

	if not v3 then
		error("Vector3Finite", 2)
	end

	if math.abs(vector.Magnitude - 1) > 1e-6 then
		error("Vector3Unit", 2)
	end

	return vector
end

function v.Vector3Positive(vector: Vector3)
	if typeof(vector) ~= "Vector3" then
		error("Vector3", 2)
	end

	local v2 = vector.X + vector.Y + vector.Z
	local v3

	if v2 == v2 and v2 ~= 1e999 then
		v3 = v2 ~= -1e999
	else
		v3 = false
	end

	if not v3 then
		error("Vector3Finite", 2)
	end

	if vector.X <= 0 or vector.Y <= 0 or vector.Z <= 0 then
		error("Vector3Positive")
	end

	return vector
end

function v.Vector3int16(p)
	if typeof(p) ~= "Vector3int16" then
		error("Vector3int16", 2)
	end

	return p
end

function v.Vector2int16(p)
	if typeof(p) ~= "Vector2int16" then
		error("Vector2int16", 2)
	end

	return p
end

function v.Region3(p)
	if typeof(p) ~= "Region3" then
		error("Region3", 2)
	end

	return p
end

function v.Region3int16(p)
	if typeof(p) ~= "Region3int16" then
		error("Region3int16", 2)
	end

	return p
end

function v.UDim(udim: UDim)
	if typeof(udim) ~= "UDim" then
		error("UDim", 2)
	end

	return udim
end

function v.UDim2(udim: UDim2)
	if typeof(udim) ~= "UDim2" then
		error("UDim2", 2)
	end

	return udim
end

function v.Rect(rect: Rect)
	if typeof(rect) ~= "Rect" then
		error("Rect", 2)
	end

	return rect
end

function v.PhysicalProperties(p)
	if typeof(p) ~= "PhysicalProperties" then
		error("PhysicalProperties", 2)
	end

	return p
end

function v.Storable(value, options)
	if not (type(value) ~= "boolean" and type(value) ~= "number") then
		return value
	end

	if type(value) == "string" then
		if not utf8.len(value) then
			error("UTF8", 2)
			return value
		end
	else
		if type(value) == "buffer" then
			return value
		end

		if type(value) == "table" then
			if type(value) ~= "table" then
				error("table", 2)
			end

			if getmetatable(value) ~= nil then
				error("metatable", 2)
			end

			local v2 = options or {}

			if v2[value] then
				error("Loop", 2)
			end

			v2[value] = true
			local v3 = rawlen(value)

			if v3 > 0 then
				local count = 0

				for k, item in pairs(value) do
					count += 1

					if k ~= count then
						error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
					end

					if v3 < count then
						error(`IndexOverflow ${`[{count}]`}`, 2)
					end

					local success, result = pcall(v.Storable, item, v2)

					if success then
						continue
					end

					local error2, v5 = ParseError(result) -- equivalent call inferred; original call site unknown
					error(`{error2} ${`[{count}]{v5 or ""}`}`, 2)
				end

				if v3 ~= count then
					error("LengthMismatch", 2)
					return value
				end
			else
				for k, item in pairs(value) do
					if type(k) ~= "string" then
						error(`KeyString ${`[{SafeKeyStringRep(k)}]`}`, 2)
					end

					if not utf8.len(k) then
						error(`KeyUTF8 ${`[{SafeKeyStringRep(k)}]`}`, 2)
					end

					local success, result = pcall(v.Storable, item, v2)

					if success then
						continue
					end

					local error2, v5 = ParseError(result) -- equivalent call inferred; original call site unknown
					error(`{error2} ${`[{SafeKeyStringRep(k)}]{v5 or ""}`}`, 2)
				end

				return value
			end
		else
			error("Storable", 2)
		end
	end

	return value
end

local v2 = {
	boolean = true,
	number = true,
	string = true,
	buffer = true,
	Color3 = true,
	Instance = true,
	NumberRange = true,
	Rect = true,
	Region3 = true,
	Region3int16 = true,
	UDim = true,
	UDim2 = true,
	CFrame = true,
	Vector2 = true,
	Vector2int16 = true,
	Vector3 = true,
	Vector3int16 = true,
	EnumItem = true
}
table.freeze(v2)

function v.Networkable(value, options)
	if type(value) == "string" then
		if not utf8.len(value) then
			error("UTF8", 2)
			return value
		end
	elseif type(value) == "table" then
		if type(value) ~= "table" then
			error("table", 2)
		end

		if getmetatable(value) ~= nil then
			error("metatable", 2)
		end

		local v3 = options or {}

		if v3[value] then
			error("Loop", 2)
		end

		v3[value] = true
		local v4 = rawlen(value)

		if v4 > 0 then
			local count = 0

			for k, item in pairs(value) do
				count += 1

				if k ~= count then
					error(`IndexMismatch ${`[{SafeKeyStringRep(k)}]`}`, 2)
				end

				if v4 < count then
					error(`IndexOverflow ${`[{count}]`}`, 2)
				end

				local success, result = pcall(v.Networkable, item, v3)

				if success then
					continue
				end

				local error2, v6 = ParseError(result) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`[{count}]{v6 or ""}`}`, 2)
			end

			if v4 ~= count then
				error("LengthMismatch", 2)
				return value
			end
		else
			for k, item in pairs(value) do
				if type(k) ~= "string" then
					error(`KeyString ${`[{SafeKeyStringRep(k)}]`}`, 2)
				end

				if not utf8.len(k) then
					error(`KeyUTF8 ${`[{SafeKeyStringRep(k)}]`}`, 2)
				end

				local success, result = pcall(v.Networkable, item, v3)

				if success then
					continue
				end

				local error2, v6 = ParseError(result) -- equivalent call inferred; original call site unknown
				error(`{error2} ${`[{SafeKeyStringRep(k)}]{v6 or ""}`}`, 2)
			end

			return value
		end
	elseif not v2[typeof(value)] then
		error("Networkable", 2)
	end

	return value
end

function v.Enum(p)
	if typeof(p) ~= "Enum" then
		error("Enum", 2)
	end

	return function(p2)
		if typeof(p2) ~= "EnumItem" then
			error("EnumItem", 2)
		end

		if p2.EnumType ~= p then
			error(tostring(p), 2)
		end

		return p2
	end
end

function v.EnumValue(object)
	if typeof(object) ~= "Enum" then
		error("Enum", 2)
	end

	local v3 = {}

	for _, v4 in ipairs(object:GetEnumItems()) do
		v3[v4.Value] = v4
	end

	return function(value)
		if typeof(value) ~= "number" then
			error("number", 2)
		end

		if not v3[value] then
			error("EnumValue", 2)
		end

		return value
	end
end

function v.Player(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		error("Player", 2)
	end

	return player
end

function v.BasePart(part)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		error("BasePart", 2)
	end

	return part
end

function v.Part(part)
	if typeof(part) ~= "Instance" or not part:IsA("Part") then
		error("Part", 2)
	end

	return part
end

function v.MeshPart(part)
	if typeof(part) ~= "Instance" or not part:IsA("MeshPart") then
		error("MeshPart", 2)
	end

	return part
end

function v.Model(model)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		error("Model", 2)
	end

	return model
end

function v.Animation(animation)
	if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
		error("Animation", 2)
	end

	return animation
end

function v.Humanoid(humanoid)
	if typeof(humanoid) ~= "Instance" or not humanoid:IsA("Humanoid") then
		error("Humanoid", 2)
	end

	return humanoid
end

function v.ParticleEmitter(emitter)
	if typeof(emitter) ~= "Instance" or not emitter:IsA("ParticleEmitter") then
		error("ParticleEmitter", 2)
	end

	return emitter
end

function v.Sound(sound)
	if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		error("Sound", 2)
	end

	return sound
end

function v.Instance(instance)
	if typeof(instance) ~= "Instance" then
		error("Instance", 2)
	end

	return instance
end

function v.InstanceOf(p: string)
	v.String(p)
	return function(instance)
		if typeof(instance) ~= "Instance" then
			error("Instance", 2)
		end

		if not instance:IsA(p) then
			error(p, 2)
		end

		return instance
	end
end

function v.InstanceClass(message: string)
	v.String(message)
	return function(instance)
		if typeof(instance) ~= "Instance" then
			error("Instance", 2)
		end

		if instance.ClassName ~= message then
			error(message, 2)
		end

		return instance
	end
end

function v.HexLower(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	for i = 1, string.len(value) do
		local v3 = string.byte(value, i)

		if not (v3 >= 48 and v3 <= 57 or v3 >= 97 and v3 <= 102) then
			error("HexLower", 2)
		end
	end

	return value
end

function v.HexUpper(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	for i = 1, string.len(value) do
		local v3 = string.byte(value, i)

		if not (v3 >= 48 and v3 <= 57 or v3 >= 65 and v3 <= 70) then
			error("HexUpper", 2)
		end
	end

	return value
end

function v.UUIDStripped(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	local v3 = string.len(value)

	if v3 ~= 32 then
		error("Length32", 2)
	end

	for i = 1, v3 do
		local v4 = string.byte(value, i)

		if not (v4 >= 48 and v4 <= 57 or v4 >= 97 and v4 <= 102) then
			error("HexLower", 2)
		end
	end

	return value
end

function v.UUID(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	if string.len(value) ~= 36 then
		error("Length36", 2)
	end

	if not value:find("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
		error("UUID", 2)
	end

	return value
end

function v.Base64(value: string)
	if type(value) ~= "string" then
		error("string", 2)
	end

	if string.len(value) % 4 ~= 0 then
		error("Base64Length", 2)
	end

	if not string.match(value, "^[A-Za-z0-9+/]*=?=?$") or string.match(value, "[^=]=+[^=]") then
		error("Base64", 2)
	end

	return value
end

function v.ToNumber(callback)
	return function(p)
		local v3 = tonumber(p)

		if not v3 then
			error("tonumber", 2)
		end

		local success, result = pcall(callback, v3)

		if success then
			return result
		end

		local v4 = tostring(result)
		local v5, v6 = string.match(v4, "^(.*:%d+): (.+)$")

		if v5 then
			v4 = v6 or v4
		end

		error(v4, 2)
		return result
	end
end

function v.IsoDate(p: string)
	if not DateTime.fromIsoDate(p) then
		error("IsoDate", 2)
	end

	return p
end

return table.freeze(v)