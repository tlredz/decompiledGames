local greenteaConstructorsSet = {}

local function highlightWrap(p: string, p2: string?)
	if p2 then
		return (`$${p2}$:{p}:${p2}$$`)
	end

	return p
end

local function lineLengthOf(value: string)
	local v2 = 0

	for k in string.gmatch(value, "[^\n]+") do
		if v2 < #k then
			v2 = #k
		end
	end

	return v2
end

local function spaceLengthOf(value: string)
	local v2 = nil

	for k in string.gmatch(value, "[^\n]+") do
		local match = k:match("^ *")

		if not v2 or #match < #v2 then
			v2 = match
		end
	end

	return #v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tabFirst(value: string)
	return "    " .. value:gsub("\n", "\n    ")
end

local function tabSecond(value: string)
	return value:gsub("\n", "\n    ")
end

local function parseRange(value)
	if typeof(value) == "table" then
		if typeof(value.min) == "number" and typeof(value.max) == "number" and (value.minExclusive == nil or typeof(value.minExclusive) == "boolean") and (value.maxExclusive == nil or typeof(value.maxExclusive) == "boolean") then
			local v2 = {
				min = value.min,
				minExclusive = 0,
				max = 0,
				maxExclusive = 0
			}
			local minExclusive

			if value.min then
				minExclusive = value.minExclusive or false
			else
				minExclusive = false
			end

			v2.minExclusive = minExclusive
			v2.max = value.max
			v2.maxExclusive = value.max and value.maxExclusive or false
			return v2
		else
			error("invalid range table")
		end
	end

	local max = tonumber(value)

	if max then
		return {
			min = nil,
			minExclusive = false,
			max = max,
			maxExclusive = false
		}
	end

	assert(type(value) == "string", "analysis hint")
	local match, v3, v4, v5 = value:match("^%s*([%[%(])%s*(.-),%s*(.-)%s*([%]%)])%s*$")

	if not match then
		error("invalid range string, expected format: one of \"[min, max]\", \"(min, max)\", \"[min, max)\", \"(min, max]\", or \"max\" (leave min/max empty for no limit)")
	end

	local minExclusive2 = match == "("
	local maxExclusive = v5 == ")"
	local min

	if v3 == "" then
		minExclusive2 = false
	else
		min = tonumber(v3)

		if not min then
			error((`invalid number for min in range string: {v3}`))
		end
	end

	local max2

	if v4 == "" then
		maxExclusive = false
	else
		max2 = tonumber(v4)

		if not max2 then
			error((`invalid number for max in range string: {v4}`))
		end
	end

	return {
		min = min,
		minExclusive = minExclusive2,
		max = max2,
		maxExclusive = maxExclusive
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function displayRange(data)
	if data.min or data.max then
		local v2 = data.minExclusive and "(" or "["
		local v3 = data.maxExclusive and ")" or "]"
		return v2 .. (data.min or "") .. ", " .. (data.max or "") .. v3
	else
		return "[-inf, inf]"
	end
end

local function checkRange(p: number, data)
	if data.min then
		if data.minExclusive then
			if p <= data.min then
				return false
			end
		elseif p < data.min then
			return false
		end
	end

	if not data.max then
		return true
	end

	if data.maxExclusive then
		if data.max <= p then
			return false
		end
	elseif data.max < p then
		return false
	end

	return true
end

local GreenTea = {
	__greenteaConstructorsSet = greenteaConstructorsSet
}
local v2 = {
	__tostring = function(object)
		if object.ok then
			return "ok"
		end

		return object:formatErr()
	end
}

local function newCauseTuple(...)
	return {
		__tuple = table.pack(...)
	}
end

local function expandCauseTuple(p)
	if type(p) == "table" and p.__tuple then
		return unpack(p.__tuple, 1, p.__tuple.n)
	end

	return p
end

local cause = {}

local function causeFormatErr(data, ...)
	if data.ok then
		return "ok"
	end

	return (data.encompassingType or data.errs[#data.errs].type):formatErr(data)
end

function cause.new(ok: boolean, errs)
	return (setmetatable({
		ok = ok,
		errs = errs,
		formatErr = causeFormatErr
	}, v2))
end

function cause.ok()
	return cause.new(true, {})
end

function cause.extendOk(p)
	if p then
		return p
	end

	return cause.new(true, {})
end

function cause.err(p, input, message: string?)
	return cause.new(false, {
		{
			type = p,
			input = input,
			message = message
		}
	})
end

function cause.extendErr(p, p2, input, message: string?)
	if not p then
		return cause.new(false, {
			{
				type = p2,
				input = input,
				message = message
			}
		})
	end

	table.insert(p.errs, {
		type = p2,
		input = input,
		message = message
	})
	return p
end

function cause.errs(p)
	return cause.new(false, p)
end

function cause.extendErrs(p, list)
	if not p then
		return cause.new(false, list)
	end

	table.move(list, 1, #list, #p.errs + 1, p.errs)
	return p
end

local class = {}
class.__index = class

function class:matches(...)
	local _matches = self._matches(...)
	_matches.encompassingType = self
	return _matches.ok, _matches
end

function class:assert(...)
	local matches, v4 = self:matches(...)

	if not matches then
		error(v4:formatErr())
	end

	return ...
end

function class:format()
	return self._format({}, 80, {})
end

function class.wrapFn(p, callback)
	assert(typeof(callback) == "function", "fn must be a function")
	assert(p.fn ~= nil, "self must be a GreenTea.fn type")
	return function(...)
		p.fn.args:assert(...)
		return p.fn.returns:assert(callback(...))
	end
end

function class.type(p)
	return p
end

local function isStringUnicode(p: string)
	return utf8.len(p) ~= nil
end

local function truncate(p: number, value: string)
	if utf8.len(value) == nil then
		return "<invalid unicode>"
	end

	if #value < p then
		return value
	end

	local v4 = {}

	for k, v5 in utf8.graphemes(value) do
		table.insert(v4, (value:sub(k, v5)))

		if p <= #v4 then
			return (`[{table.concat(v4, "")}...]`)
		end
	end

	return value
end

function class:__call(...)
	local matches, v4 = self:matches(...)

	if matches then
		return true
	end

	return false, (tostring(v4))
end

function class:__tostring()
	return (`GreenTea.Type({self:format()})`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tostringLiteral(value)
	if typeof(value) == "string" then
		return string.format("%q", value)
	end

	return (tostring(value))
end

local displayInputType

displayInputType = function(...)
	local v4, typeName

	if select("#", ...) <= 1 then
		local v5 = ...

		if v5 and typeof(v5) == "table" and v5.__tuple then
			return displayInputType(expandCauseTuple(v5))
		end

		if typeof(...) == "string" then
			v4 = string.format("%q", ...)
		else
			v4 = tostring(...)
		end

		typeName = typeof(...)
	else
		local v5 = {}
		local v6 = {}
		local typeNames = {}

		for i = 1, select("#", ...) do
			local v7 = select(i, ...)
			table.insert(v5, GreenTea.typeof(v7))
			local v8 = tostringLiteral(v7) -- equivalent call inferred; original call site unknown
			table.insert(v6, v8)
			table.insert(typeNames, (typeof(v7)))
		end

		typeName = `({table.concat(typeNames, ", ")})`
		v4 = `({table.concat(v6, ", ")})`
	end

	local v5 = truncate(20, v4)
	return (`{truncate(20, typeName)} ({v5})`)
end

function class:formatErr(p2)
	local err = p2.errs[1]
	local v4

	if err.message then
		v4 = err.message:gsub("$input", displayInputType(err.input))
	else
		v4 = `expected {err.type:format()}, got {displayInputType(err.input)}`
	end

	local v5 = {}

	for k, err2 in p2.errs do
		if err2.message or k == 1 then
			v5[err2.type] = `error{k}`
		end
	end

	local formatted = `\n{self._format(v5, 80, {})}\n`
	local v6 = {}

	for k in formatted:gmatch("%$%$error(%d+)%$:") do
		table.insert(v6, (tonumber(k)))
	end

	for i = #v6, 1, -1 do
		local v7 = v6[i]
		local v8 = p2.errs[v7]
		formatted = formatted:gsub(
			`([^\n]*)$$error{v7}$:(.*):$error{v7}$$([^\n]*)\n(.*)$`,
			function(value: string, value2: string, p3: string, value3: string)
				local v10

				if value2:find("\n", 1, true) == nil then
					v10 = (" "):rep(#value:gsub("%$%$error%d+%$:", ""):gsub(":%$error%d+%$%$", "")) .. ("^"):rep(#value2)
				else
					local formatted2 = `{value}{value2}{p3}`
					local v11 = 0

					for k in string.gmatch(formatted2, "[^\n]+") do
						if v11 < #k then
							v11 = #k
						end
					end

					local v12 = spaceLengthOf(formatted2)
					v10 = (" "):rep(v12) .. ("^"):rep(v11 - v12)
				end

				if v8.message then
					v10 = `{v10} $$error{v7}$$`
				end

				local matches = {}

				while true do
					local match, v11 = value3:match([[
^([^
]*)
(.*)$]])

					if not (match and v11 and match:match("^%s*^")) then
						break
					end

					table.insert(matches, match)
					value3 = v11
				end

				if matches[1] then
					return (`{value}{value2}{p3}\n{table.concat(matches, "\n")}\n{v10}\n{value3}`)
				end

				return (`{value}{value2}{p3}\n{v10}\n{value3}`)
			end
		)
	end

	for k, err2 in p2.errs do
		if not err2.message then
			continue
		end

		local v7 = err2.message:gsub("$input", displayInputType(err2.input))
		formatted = formatted:gsub(`%$%$error{k}%$%$`, v7)
	end

	return (`{v4}{formatted:gsub([[

(%s*)(^+) ([^
]+)]], function(list, list2, list3)
		if #list + #list2 + #list3 + 1 <= 80 then
			return nil
		end

		return (`\n{list}{list2}\n{string.rep(" ", #list)}{list3}`)
	end):sub(1, -2)}`)
end

function GreenTea.isGreenTeaType(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

GreenTea.isGtType = GreenTea.isGreenTeaType

local function newBasicType(p: string, flag: boolean?)
	return function()
		local v4 = nil
		local typeof2

		if not flag then
			typeof2 = p
		end

		local v8

		if flag then
			v8 = p
		end

		v4 = {
			kind = "basic",
			basic = {
				typeof = typeof2,
				type = v8
			},
			_matches = function(p2, ...)
				if (flag and type(p2) or typeof(p2)) == p then
					return cause.ok()
				end

				return cause.err(v4, p2, (`expected {p}, got $input`))
			end,
			_format = function(p2, _: number, _)
				local v9 = p
				local v10 = p2[v4]

				if v10 then
					return (`$${v10}$:{v9}:${v10}$$`)
				end

				return v9
			end
		}
		return (setmetatable(v4, class))
	end
end

GreenTea.__newBasicType = newBasicType

function GreenTea.any(p)
	local allowNil = p and p.allowNil
	local v4 = nil
	v4 = {
		kind = "any",
		any = {
			allowNil = allowNil or nil
		},
		_matches = function(p2, ...)
			if allowNil or p2 ~= nil then
				return cause.ok()
			end

			return cause.err(v4, p2, "expected non-nil, got nil")
		end,
		_format = function(p2, _: number, _)
			local v5 = p2[v4]

			if v5 then
				return (`$${v5}$:any:${v5}$$`)
			end

			return "any"
		end
	}
	return (setmetatable(v4, class))
end

function GreenTea.unknown(p)
	local allowNil = p and p.allowNil
	local v4 = nil
	v4 = {
		kind = "unknown",
		unknown = {
			allowNil = allowNil or nil
		},
		_matches = function(p2, ...)
			if allowNil or p2 ~= nil then
				return cause.ok()
			end

			return cause.err(v4, p2, "expected non-nil, got nil")
		end,
		_format = function(p2, _: number, _)
			local v5 = p2[v4]

			if v5 then
				return (`$${v5}$:unknown:${v5}$$`)
			end

			return "unknown"
		end
	}
	return (setmetatable(v4, class))
end

function GreenTea.never()
	local v4 = nil
	v4 = {
		kind = "never",
		_matches = function(p, ...)
			return cause.err(v4, p, "expected never, got $input")
		end,
		_format = function(p, _: number, _)
			local v5 = p[v4]

			if v5 then
				return (`$${v5}$:never:${v5}$$`)
			end

			return "never"
		end
	}
	return (setmetatable(v4, class))
end

function GreenTea.boolean()
	return nil
end

local v4 = nil
local v5 = "boolean"

function GreenTea.boolean()
	local v6 = nil
	local typeof2

	if not v4 then
		typeof2 = v5
	end

	local v10

	if v4 then
		v10 = v5
	end

	v6 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v10
		},
		_matches = function(p, ...)
			if (v4 and type(p) or typeof(p)) == v5 then
				return cause.ok()
			end

			return cause.err(v6, p, (`expected {v5}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v11 = v5
			local v12 = p[v6]

			if v12 then
				return (`$${v12}$:{v11}:${v12}$$`)
			end

			return v11
		end
	}
	return (setmetatable(v6, class))
end

GreenTea.bool = GreenTea.boolean

function GreenTea.Instance()
	return nil
end

local v6 = nil
local v7 = "Instance"

function GreenTea.Instance()
	local v8 = nil
	local typeof2

	if not v6 then
		typeof2 = v7
	end

	local v12

	if v6 then
		v12 = v7
	end

	v8 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v12
		},
		_matches = function(p, ...)
			if (v6 and type(p) or typeof(p)) == v7 then
				return cause.ok()
			end

			return cause.err(v8, p, (`expected {v7}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v13 = v7
			local v14 = p[v8]

			if v14 then
				return (`$${v14}$:{v13}:${v14}$$`)
			end

			return v13
		end
	}
	return (setmetatable(v8, class))
end

local v8 = {
	"dead",
	"normal",
	"running",
	"suspended"
}

function GreenTea.coroutine(p)
	local status, joined

	if p and p.status then
		status = {}

		if type(p.status) == "string" then
			status[p.status] = true
		elseif type(p.status) == "table" then
			for _, v10 in p.status do
				status[v10] = true
			end
		end

		local v10 = {}

		for k, _ in status do
			if not table.find(v8, k) then
				error((`{k} is not a valid coroutine status`))
			end

			table.insert(v10, k)
		end

		table.sort(v10)
		joined = table.concat(v10, " | ")

		if #v10 > 1 then
			joined = `({joined})`
		end
	else
		status = nil
		joined = "any"
	end

	local v10 = nil
	v10 = {
		kind = "thread",
		thread = {
			status = status
		},
		_matches = function(p2, ...)
			if type(p2) ~= "thread" then
				return cause.err(v10, p2, "expected thread, got $input")
			end

			if status then
				local v11 = coroutine.status(p2)

				if not status[v11] then
					return cause.err(v10, p2, (`expected thread with status {joined}, got thread with status {v11}`))
				end
			end

			return cause.ok()
		end,
		_format = function(p2, _: number, _)
			if status then
				local formatted = `thread<status: {joined}>`
				local v11 = p2[v10]

				if v11 then
					return (`$${v11}$:{formatted}:${v11}$$`)
				end

				return formatted
			else
				local v11 = p2[v10]

				if v11 then
					return (`$${v11}$:thread:${v11}$$`)
				end

				return "thread"
			end
		end
	}
	return (setmetatable(v10, class))
end

GreenTea.thread = GreenTea.coroutine

function GreenTea.buffer()
	return nil
end

local v9 = nil
local v10 = "buffer"

function GreenTea.buffer()
	local v11 = nil
	local typeof2

	if not v9 then
		typeof2 = v10
	end

	local v15

	if v9 then
		v15 = v10
	end

	v11 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v15
		},
		_matches = function(p, ...)
			if (v9 and type(p) or typeof(p)) == v10 then
				return cause.ok()
			end

			return cause.err(v11, p, (`expected {v10}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v16 = v10
			local v17 = p[v11]

			if v17 then
				return (`$${v17}$:{v16}:${v17}$$`)
			end

			return v16
		end
	}
	return (setmetatable(v11, class))
end

local flag = true
local v11 = "userdata"

function GreenTea.userdata()
	local v12 = nil
	local typeof2

	if not flag then
		typeof2 = v11
	end

	local v16

	if flag then
		v16 = v11
	end

	v12 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v16
		},
		_matches = function(p, ...)
			if (flag and type(p) or typeof(p)) == v11 then
				return cause.ok()
			end

			return cause.err(v12, p, (`expected {v11}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v17 = v11
			local v18 = p[v12]

			if v18 then
				return (`$${v18}$:{v17}:${v18}$$`)
			end

			return v17
		end
	}
	return (setmetatable(v12, class))
end

local v12 = nil
local v13 = "Vector2"

function GreenTea.Vector2()
	local v14 = nil
	local typeof2

	if not v12 then
		typeof2 = v13
	end

	local v18

	if v12 then
		v18 = v13
	end

	v14 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v18
		},
		_matches = function(p, ...)
			if (v12 and type(p) or typeof(p)) == v13 then
				return cause.ok()
			end

			return cause.err(v14, p, (`expected {v13}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v19 = v13
			local v20 = p[v14]

			if v20 then
				return (`$${v20}$:{v19}:${v20}$$`)
			end

			return v19
		end
	}
	return (setmetatable(v14, class))
end

local flag2 = true
local v14 = "vector"

function GreenTea.vector()
	local v15 = nil
	local typeof2

	if not flag2 then
		typeof2 = v14
	end

	local v19

	if flag2 then
		v19 = v14
	end

	v15 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v19
		},
		_matches = function(p, ...)
			if (flag2 and type(p) or typeof(p)) == v14 then
				return cause.ok()
			end

			return cause.err(v15, p, (`expected {v14}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v20 = v14
			local v21 = p[v15]

			if v21 then
				return (`$${v21}$:{v20}:${v21}$$`)
			end

			return v20
		end
	}
	return (setmetatable(v15, class))
end

local v15 = nil
local v16 = "Vector3"

function GreenTea.Vector3()
	local v17 = nil
	local typeof2

	if not v15 then
		typeof2 = v16
	end

	local v21

	if v15 then
		v21 = v16
	end

	v17 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v21
		},
		_matches = function(p, ...)
			if (v15 and type(p) or typeof(p)) == v16 then
				return cause.ok()
			end

			return cause.err(v17, p, (`expected {v16}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v22 = v16
			local v23 = p[v17]

			if v23 then
				return (`$${v23}$:{v22}:${v23}$$`)
			end

			return v22
		end
	}
	return (setmetatable(v17, class))
end

local v17 = nil
local v18 = "CFrame"

function GreenTea.CFrame()
	local v19 = nil
	local typeof2

	if not v17 then
		typeof2 = v18
	end

	local v23

	if v17 then
		v23 = v18
	end

	v19 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v23
		},
		_matches = function(p, ...)
			if (v17 and type(p) or typeof(p)) == v18 then
				return cause.ok()
			end

			return cause.err(v19, p, (`expected {v18}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v24 = v18
			local v25 = p[v19]

			if v25 then
				return (`$${v25}$:{v24}:${v25}$$`)
			end

			return v24
		end
	}
	return (setmetatable(v19, class))
end

local v19 = nil
local v20 = "Color3"

function GreenTea.Color3()
	local v21 = nil
	local typeof2

	if not v19 then
		typeof2 = v20
	end

	local v25

	if v19 then
		v25 = v20
	end

	v21 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v25
		},
		_matches = function(p, ...)
			if (v19 and type(p) or typeof(p)) == v20 then
				return cause.ok()
			end

			return cause.err(v21, p, (`expected {v20}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v26 = v20
			local v27 = p[v21]

			if v27 then
				return (`$${v27}$:{v26}:${v27}$$`)
			end

			return v26
		end
	}
	return (setmetatable(v21, class))
end

local v21 = nil
local v22 = "UDim"

function GreenTea.UDim()
	local v23 = nil
	local typeof2

	if not v21 then
		typeof2 = v22
	end

	local v27

	if v21 then
		v27 = v22
	end

	v23 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v27
		},
		_matches = function(p, ...)
			if (v21 and type(p) or typeof(p)) == v22 then
				return cause.ok()
			end

			return cause.err(v23, p, (`expected {v22}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v28 = v22
			local v29 = p[v23]

			if v29 then
				return (`$${v29}$:{v28}:${v29}$$`)
			end

			return v28
		end
	}
	return (setmetatable(v23, class))
end

local v23 = nil
local v24 = "UDim2"

function GreenTea.UDim2()
	local v25 = nil
	local typeof2

	if not v23 then
		typeof2 = v24
	end

	local v29

	if v23 then
		v29 = v24
	end

	v25 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v29
		},
		_matches = function(p, ...)
			if (v23 and type(p) or typeof(p)) == v24 then
				return cause.ok()
			end

			return cause.err(v25, p, (`expected {v24}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v30 = v24
			local v31 = p[v25]

			if v31 then
				return (`$${v31}$:{v30}:${v31}$$`)
			end

			return v30
		end
	}
	return (setmetatable(v25, class))
end

local v25 = nil
local v26 = "Ray"

function GreenTea.Ray()
	local v27 = nil
	local typeof2

	if not v25 then
		typeof2 = v26
	end

	local v31

	if v25 then
		v31 = v26
	end

	v27 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v31
		},
		_matches = function(p, ...)
			if (v25 and type(p) or typeof(p)) == v26 then
				return cause.ok()
			end

			return cause.err(v27, p, (`expected {v26}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v32 = v26
			local v33 = p[v27]

			if v33 then
				return (`$${v33}$:{v32}:${v33}$$`)
			end

			return v32
		end
	}
	return (setmetatable(v27, class))
end

local v27 = nil
local v28 = "Rect"

function GreenTea.Rect()
	local v29 = nil
	local typeof2

	if not v27 then
		typeof2 = v28
	end

	local v33

	if v27 then
		v33 = v28
	end

	v29 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v33
		},
		_matches = function(p, ...)
			if (v27 and type(p) or typeof(p)) == v28 then
				return cause.ok()
			end

			return cause.err(v29, p, (`expected {v28}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v34 = v28
			local v35 = p[v29]

			if v35 then
				return (`$${v35}$:{v34}:${v35}$$`)
			end

			return v34
		end
	}
	return (setmetatable(v29, class))
end

local v29 = nil
local v30 = "Region3"

function GreenTea.Region3()
	local v31 = nil
	local typeof2

	if not v29 then
		typeof2 = v30
	end

	local v35

	if v29 then
		v35 = v30
	end

	v31 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v35
		},
		_matches = function(p, ...)
			if (v29 and type(p) or typeof(p)) == v30 then
				return cause.ok()
			end

			return cause.err(v31, p, (`expected {v30}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v36 = v30
			local v37 = p[v31]

			if v37 then
				return (`$${v37}$:{v36}:${v37}$$`)
			end

			return v36
		end
	}
	return (setmetatable(v31, class))
end

local v31 = nil
local v32 = "BrickColor"

function GreenTea.BrickColor()
	local v33 = nil
	local typeof2

	if not v31 then
		typeof2 = v32
	end

	local v37

	if v31 then
		v37 = v32
	end

	v33 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v37
		},
		_matches = function(p, ...)
			if (v31 and type(p) or typeof(p)) == v32 then
				return cause.ok()
			end

			return cause.err(v33, p, (`expected {v32}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v38 = v32
			local v39 = p[v33]

			if v39 then
				return (`$${v39}$:{v38}:${v39}$$`)
			end

			return v38
		end
	}
	return (setmetatable(v33, class))
end

local v33 = nil
local v34 = "Font"

function GreenTea.Font()
	local v35 = nil
	local typeof2

	if not v33 then
		typeof2 = v34
	end

	local v39

	if v33 then
		v39 = v34
	end

	v35 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v39
		},
		_matches = function(p, ...)
			if (v33 and type(p) or typeof(p)) == v34 then
				return cause.ok()
			end

			return cause.err(v35, p, (`expected {v34}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v40 = v34
			local v41 = p[v35]

			if v41 then
				return (`$${v41}$:{v40}:${v41}$$`)
			end

			return v40
		end
	}
	return (setmetatable(v35, class))
end

local v35 = nil
local v36 = "Enum"

function GreenTea.Enum()
	local v37 = nil
	local typeof2

	if not v35 then
		typeof2 = v36
	end

	local v41

	if v35 then
		v41 = v36
	end

	v37 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v41
		},
		_matches = function(p, ...)
			if (v35 and type(p) or typeof(p)) == v36 then
				return cause.ok()
			end

			return cause.err(v37, p, (`expected {v36}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v42 = v36
			local v43 = p[v37]

			if v43 then
				return (`$${v43}$:{v42}:${v43}$$`)
			end

			return v42
		end
	}
	return (setmetatable(v37, class))
end

local v37 = nil
local v38 = "EnumItem"

function GreenTea.EnumItem()
	local v39 = nil
	local typeof2

	if not v37 then
		typeof2 = v38
	end

	local v43

	if v37 then
		v43 = v38
	end

	v39 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v43
		},
		_matches = function(p, ...)
			if (v37 and type(p) or typeof(p)) == v38 then
				return cause.ok()
			end

			return cause.err(v39, p, (`expected {v38}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v44 = v38
			local v45 = p[v39]

			if v45 then
				return (`$${v45}$:{v44}:${v45}$$`)
			end

			return v44
		end
	}
	return (setmetatable(v39, class))
end

function GreenTea.none()
	return nil
end

local v39 = nil
local v40 = "nil"

function GreenTea.none()
	local v41 = nil
	local typeof2

	if not v39 then
		typeof2 = v40
	end

	local v45

	if v39 then
		v45 = v40
	end

	v41 = {
		kind = "basic",
		basic = {
			typeof = typeof2,
			type = v45
		},
		_matches = function(p, ...)
			if (v39 and type(p) or typeof(p)) == v40 then
				return cause.ok()
			end

			return cause.err(v41, p, (`expected {v40}, got $input`))
		end,
		_format = function(p, _: number, _)
			local v46 = v40
			local v47 = p[v41]

			if v47 then
				return (`$${v47}$:{v46}:${v47}$$`)
			end

			return v46
		end
	}
	return (setmetatable(v41, class))
end

function GreenTea.literal(value)
	local v41 = tostringLiteral(value) -- equivalent call inferred; original call site unknown
	local v42 = nil
	v42 = {
		kind = "literal",
		literal = {
			value = value
		},
		_matches = function(p, ...)
			if p == value then
				return cause.ok()
			end

			return cause.err(v42, p, (`expected literally {v41}, got $input`))
		end,
		_format = function(p, _: number, _)
			local selected

			if typeof(value) == "string" then
				selected = v41
			else
				selected = `literal<{v41}>`
			end

			local v44 = p[v42]

			if v44 then
				return (`$${v44}$:{selected}:${v44}$$`)
			end

			return selected
		end
	}
	return (setmetatable(v42, class))
end

local v41 = {
	"spec",
	"t",
	"d",
	"story",
	"storybook",
	"bench"
}

function GreenTea.withCustom(p, typechecker, name: string?)
	if not name then
		local v42, v43, v44 = debug.info(typechecker, "sln")
		local v45 = v42 or "unknown"
		local v46 = v43 or 0
		name = v44 or ""

		if name == "" then
			local match, v47 = v45:match("([^%.]+)%.(.-)$")

			if match and v47 then
				if table.find(v41, v47) then
					name = `{match}.{v47}:{v46}`
				else
					name = `{v47}:{v46}`
				end
			else
				name = `{v45}:{v46}`
			end
		end
	end

	assert(name, "analysis hint")
	local v42

	if p == nil then
		v42 = nil
	else
		v42 = GreenTea.typeof(p)
	end

	local v43 = nil
	v43 = {
		kind = "custom",
		custom = {
			typechecker = typechecker,
			name = name,
			type = v42
		},
		_matches = function(p3, ...)
			if v42 then
				local _matches = v42._matches(p3)

				if not _matches.ok then
					return cause.extendErr(_matches, v43, p3)
				end
			end

			local v44, v45 = typechecker(p3)

			if v44 then
				return cause.ok()
			end

			return cause.err(v43, p3, v45)
		end,
		_format = function(p3, p4: number, p5)
			if p5[v43] then
				return "<cyclic>"
			end

			p5[v43] = true
			local formatted = `custom<{name}>`
			local v44 = p3[v43]

			if v44 then
				formatted = `$${v44}$:{formatted}:${v44}$$`
			end

			if not v42 then
				return formatted
			end

			local _format = v42._format(p3, p4 - 1, p5)
			local formatted2 = `{_format} & {formatted}`

			if p4 < #formatted2 then
				return tabSecond(`{_format} & {formatted}`)
			end

			return formatted2
		end
	}
	return (setmetatable(v43, class))
end

function GreenTea.custom(callback, p: string?)
	return GreenTea.withCustom(nil, callback, p)
end

GreenTea.__highlightWrap = highlightWrap
GreenTea.__Type = class
GreenTea.__Cause = cause

function GreenTea.number(data)
	local range = data and data.range and parseRange(data.range)
	local v43 = nil
	v43 = {
		kind = "number",
		number = {
			range = range,
			integer = data and data.integer,
			nan = data and data.nan
		},
		_matches = function(value, ...)
			if typeof(value) ~= "number" then
				return cause.err(v43, value, "expected number, got $input")
			end

			if data then
				if range then
					local range2 = range
					local v45

					if range2.min then
						if range2.minExclusive then
							if value <= range2.min then
								v45 = false
							elseif range2.max then
								if range2.maxExclusive then
									v45 = not (range2.max <= value)
								else
									v45 = not (range2.max < value)
								end
							else
								v45 = true
							end
						elseif value < range2.min then
							v45 = false
						elseif range2.max then
							if range2.maxExclusive then
								v45 = not (range2.max <= value)
							else
								v45 = not (range2.max < value)
							end
						else
							v45 = true
						end
					elseif range2.max then
						if range2.maxExclusive then
							v45 = not (range2.max <= value)
						else
							v45 = not (range2.max < value)
						end
					else
						v45 = true
					end

					if not v45 then
						return cause.err(v43, value, (`input out of range (input: {value})`))
					end
				end

				if data.integer and math.floor(value) ~= value then
					return cause.err(v43, value, (`input is not an integer (input: {value})`))
				end
			end

			if data and data.nan or value == value then
				return cause.ok()
			end

			return cause.err(v43, value, "input is NaN")
		end,
		_format = function(p, _: number, _)
			if data then
				local v44 = {}

				if data.integer then
					table.insert(v44, "integer")
				end

				if data.nan then
					table.insert(v44, "NaN allowed")
				end

				if range then
					local v47 = displayRange(range) -- equivalent call inferred; original call site unknown
					table.insert(v44, (`range {v47}`))
				end

				if #v44 ~= 0 then
					local formatted = `number<{table.concat(v44, ", ")}>`
					local v45 = p[v43]

					if v45 then
						return (`$${v45}$:{formatted}:${v45}$$`)
					end

					return formatted
				end
			end

			local v44 = p[v43]

			if v44 then
				return (`$${v44}$:number:${v44}$$`)
			end

			return "number"
		end
	}
	return (setmetatable(v43, class))
end

local function countGraphemes(list: string)
	if #list == 0 then
		return 0
	end

	local count = 0

	for _ in utf8.graphemes(list) do
		count += 1
	end

	return count
end

function GreenTea.string(data)
	local bytes = data and data.bytes and parseRange(data.bytes)
	local graphemes = data and data.graphemes and parseRange(data.graphemes)

	if graphemes and not bytes then
		error("graphemes limit requires bytes limit. Graphemes have no upper limit on size, so if only graphemes limit is set, the byte limit is practically infinite. If you really want infinite byte length, set bytes to `[0, inf]`")
	end

	local v44 = nil
	v44 = {
		kind = "string",
		string = {
			pattern = data and data.pattern,
			bytes = bytes,
			graphemes = graphemes,
			unicode = data and data.unicode
		},
		_matches = function(value, ...)
			if typeof(value) ~= "string" then
				return cause.err(v44, value, "expected string, got $input")
			end

			if not data then
				return cause.ok()
			end

			if data.unicode and utf8.len(value) == nil then
				return cause.err(v44, value, "input is not unicode")
			end

			if bytes then
				local count = #value
				local bytes2 = bytes
				local v46

				if bytes2.min then
					if bytes2.minExclusive then
						if count <= bytes2.min then
							v46 = false
						elseif bytes2.max then
							if bytes2.maxExclusive then
								v46 = not (bytes2.max <= count)
							else
								v46 = not (bytes2.max < count)
							end
						else
							v46 = true
						end
					elseif count < bytes2.min then
						v46 = false
					elseif bytes2.max then
						if bytes2.maxExclusive then
							v46 = not (bytes2.max <= count)
						else
							v46 = not (bytes2.max < count)
						end
					else
						v46 = true
					end
				elseif bytes2.max then
					if bytes2.maxExclusive then
						v46 = not (bytes2.max <= count)
					else
						v46 = not (bytes2.max < count)
					end
				else
					v46 = true
				end

				if not v46 then
					return cause.err(
						v44,
						value,
						(`input length out of range (#input: {#value} from #{truncate(15, tostringLiteral(value))})`)
					)
				end
			end

			if graphemes then
				local count

				if #value == 0 then
					count = 0
				else
					count = 0

					for _ in utf8.graphemes(value) do
						count += 1
					end
				end

				if not count then
					return cause.err(v44, value, "input is not a valid unicode string")
				end

				local graphemes2 = graphemes
				local v46

				if graphemes2.min then
					if graphemes2.minExclusive then
						if count <= graphemes2.min then
							v46 = false
						elseif graphemes2.max then
							if graphemes2.maxExclusive then
								v46 = not (graphemes2.max <= count)
							else
								v46 = not (graphemes2.max < count)
							end
						else
							v46 = true
						end
					elseif count < graphemes2.min then
						v46 = false
					elseif graphemes2.max then
						if graphemes2.maxExclusive then
							v46 = not (graphemes2.max <= count)
						else
							v46 = not (graphemes2.max < count)
						end
					else
						v46 = true
					end
				elseif graphemes2.max then
					if graphemes2.maxExclusive then
						v46 = not (graphemes2.max <= count)
					else
						v46 = not (graphemes2.max < count)
					end
				else
					v46 = true
				end

				if not v46 then
					return cause.err(
						v44,
						value,
						(`input length out of range (# graphemes: {count} from {truncate(15, tostringLiteral(value))})`)
					)
				end
			end

			if data.pattern and not string.match(value, data.pattern) then
				return cause.err(
					v44,
					value,
					(`input does not match pattern (input: {truncate(15, tostringLiteral(value))})`)
				)
			end

			return cause.ok()
		end,
		_format = function(p, _: number, _)
			if data then
				local v45 = {}

				if data.unicode then
					table.insert(v45, "unicode")
				end

				if graphemes then
					local v48 = displayRange(graphemes) -- equivalent call inferred; original call site unknown
					table.insert(v45, (`graphemes {v48}`))
				end

				if bytes then
					local v48 = displayRange(bytes) -- equivalent call inferred; original call site unknown
					table.insert(v45, (`bytes {v48}`))
				end

				if data.pattern then
					table.insert(v45, (`pattern "{data.pattern:gsub("[\r\n\t]", {
						["\r"] = "\\r",
						["\n"] = "\\n",
						["\t"] = "\\t"
					})}"`))
				end

				if #v45 ~= 0 then
					local formatted = `string<{table.concat(v45, ", ")}>`
					local v46 = p[v44]

					if v46 then
						return (`$${v46}$:{formatted}:${v46}$$`)
					end

					return formatted
				end
			end

			local v45 = p[v44]

			if v45 then
				return (`$${v45}$:string:${v45}$$`)
			end

			return "string"
		end
	}
	return (setmetatable(v44, class))
end

function GreenTea.isTypeof(p: string, _)
	local v42 = nil
	return (function()
		local v43 = nil
		local typeof2

		if not v42 then
			typeof2 = p
		end

		local v47

		if v42 then
			v47 = p
		end

		v43 = {
			kind = "basic",
			basic = {
				typeof = typeof2,
				type = v47
			},
			_matches = function(p2, ...)
				if (v42 and type(p2) or typeof(p2)) == p then
					return cause.ok()
				end

				return cause.err(v43, p2, (`expected {p}, got $input`))
			end,
			_format = function(p2, _: number, _)
				local v48 = p
				local v49 = p2[v43]

				if v49 then
					return (`$${v49}$:{v48}:${v49}$$`)
				end

				return v48
			end
		}
		return (setmetatable(v43, class))
	end)()
end

function GreenTea.isType(p: string, _)
	local v42 = nil
	return (function()
		local v43 = nil
		local typeof2

		if not v42 then
			typeof2 = p
		end

		local v47

		if v42 then
			v47 = p
		end

		v43 = {
			kind = "basic",
			basic = {
				typeof = typeof2,
				type = v47
			},
			_matches = function(p2, ...)
				if (v42 and type(p2) or typeof(p2)) == p then
					return cause.ok()
				end

				return cause.err(v43, p2, (`expected {p}, got $input`))
			end,
			_format = function(p2, _: number, _)
				local v48 = p
				local v49 = p2[v43]

				if v49 then
					return (`$${v49}$:{v48}:${v49}$$`)
				end

				return v48
			end
		}
		return (setmetatable(v43, class))
	end)()
end

local function fn(...)
	return ...
end

function GreenTea.vararg(p, p2)
	local length = p2 and p2.length and parseRange(p2.length)
	local typeof2 = GreenTea.typeof(p)
	local v43 = nil
	v43 = {
		kind = "vararg",
		vararg = {
			type = typeof2,
			length = length
		},
		_matches = function(...)
			local v44 = table.pack(...)
			local v45 = {}
			local v46 = false

			for i = v44.n, 1, -1 do
				if v44[i] ~= nil then
					break
				end

				v44.n -= 1
			end

			if length then
				local n = v44.n
				local length2 = length
				local v48

				if length2.min then
					if length2.minExclusive then
						if n <= length2.min then
							v48 = false
						elseif length2.max then
							if length2.maxExclusive then
								v48 = not (length2.max <= n)
							else
								v48 = not (length2.max < n)
							end
						else
							v48 = true
						end
					elseif n < length2.min then
						v48 = false
					elseif length2.max then
						if length2.maxExclusive then
							v48 = not (length2.max <= n)
						else
							v48 = not (length2.max < n)
						end
					else
						v48 = true
					end
				elseif length2.max then
					if length2.maxExclusive then
						v48 = not (length2.max <= n)
					else
						v48 = not (length2.max < n)
					end
				else
					v48 = true
				end

				if not v48 then
					local v49 = {
						type = v43,
						input = table.pack(...),
						message = 0
					}
					local v52 = displayRange(length) -- equivalent call inferred; original call site unknown
					v49.message = `expected input count to be within range {v52}`
					table.insert(v45, v49)
					return cause.new(false, v45)
				end
			end

			if typeof2.kind == "any" or typeof2.kind == "unknown" then
				return cause.ok()
			end

			for i = 1, v44.n do
				local _matches = typeof2._matches(v44[i])

				if _matches.ok then
					continue
				end

				table.move(_matches.errs, 1, #_matches.errs, #v45 + 1, v45)
				v46 = true
			end

			if not v46 then
				return cause.ok()
			end

			table.insert(v45, 1, {
				type = v43,
				input = table.pack(...)
			})
			return cause.new(false, v45)
		end,
		_format = function(p3, p4: number, p5)
			if p5[v43] then
				return "<cyclic>"
			end

			p5[v43] = true
			local formatted = `...{typeof2._format(p3, p4 - 3, p5)}`
			local v44 = p3[v43]

			if v44 then
				return (`$${v44}$:{formatted}:${v44}$$`)
			end

			return formatted
		end
	}
	return (setmetatable(v43, class))
end

local function simplifyGtTuples(...)
	local v42 = table.pack(...)

	for i = 1, v42.n do
		local v43 = v42[i]

		if not GreenTea.isGtType(v43) then
			continue
		end

		if v43.tuple then
			if i == v42.n then
				v42[i] = nil
				table.move(v43.tuple.contents, 1, #v43.tuple.contents, i, v42)
				v42.n += #v43.tuple.contents - 1

				if v43.tuple.vararg then
					table.insert(v42, v43.tuple.vararg)
					v42.n += 1
				end
			else
				v42[i] = v43.tuple.contents[1] or v43.tuple.vararg or GreenTea.none()
			end
		elseif v43.vararg and i ~= v42.n then
			v42[i] = v43.vararg.type
		end
	end

	return fn(unpack(v42, 1, v42.n))
end

function GreenTea.tuple(...)
	local contents = table.pack(simplifyGtTuples(...))

	for i = 1, contents.n do
		if contents[i] == nil then
			error("nil types are not allowed implicitly in tuples; specify explicitly or fix your arguments to not have nil")
		end

		contents[i] = GreenTea.typeof(contents[i])
	end

	contents.n = nil
	local vararg

	if contents[#contents] and contents[#contents].kind == "vararg" then
		vararg = contents[#contents]
		contents[#contents] = nil
	else
		vararg = nil
	end

	local v44 = nil
	v44 = {
		kind = "tuple",
		tuple = {
			contents = contents,
			vararg = vararg
		},
		_matches = function(...)
			local v45 = table.pack(...)
			local v46 = {}
			local flag3 = false

			for i = v45.n, 1, -1 do
				if v45[i] ~= nil then
					break
				end

				v45.n -= 1
			end

			for k, v47 in contents do
				local v48 = v45[k]
				local _matches = v47._matches(v48)

				if _matches.ok then
					continue
				end

				table.move(_matches.errs, 1, #_matches.errs, #v46 + 1, v46)
				flag3 = true
			end

			if flag3 then
				table.insert(v46, 1, {
					type = v44,
					input = newCauseTuple(...)
				})
				return cause.new(false, v46)
			end

			if v45.n <= #contents then
				return cause.ok()
			end

			if vararg then
				return vararg._matches(select(#contents + 1, ...))
			end

			return cause.errs({
				{
					type = v44,
					input = v45[#contents + 1]
				},
				{
					type = v44,
					input = newCauseTuple(...),
					message = `expected a tuple of {#contents} elements, got {v45.n} elements from $input`
				}
			})
		end,
		_format = function(p, p2: number, p3)
			if p3[v44] then
				return "<cyclic>"
			end

			p3[v44] = true
			local v45 = {}

			for _, v46 in ipairs(contents) do
				local v47

				if v46._needsParens then
					v47 = `({v46._format(p, p2 - 4, p3)})`
				else
					v47 = `{v46._format(p, p2 - 2, p3)}`
				end

				table.insert(v45, v47)
			end

			if vararg then
				table.insert(v45, vararg._format(p, p2 - 3, p3))
			end

			local formatted = `{table.concat(v45, ", ")}`
			local v46 = 0

			for k in string.gmatch(formatted, "[^\n]+") do
				if v46 < #k then
					v46 = #k
				end
			end

			if p2 < v46 or string.find(formatted, "\n", 1, true) then
				local formatted2 = ([[
(
%*
)]]):format(tabFirst(table.concat(v45, ",\n")))
				local v47 = p[v44]

				if v47 then
					return (`$${v47}$:{formatted2}:${v47}$$`)
				end

				return formatted2
			else
				local formatted2 = `({table.concat(v45, ", ")})`
				local v47 = p[v44]

				if v47 then
					return (`$${v47}$:{formatted2}:${v47}$$`)
				end

				return formatted2
			end
		end
	}
	return fn((setmetatable(v44, class)))
end

function GreenTea.args(...)
	return (GreenTea.tuple(...))
end

function GreenTea.returns(...)
	return (GreenTea.tuple(...))
end

function GreenTea.fn(args, callback2)
	assert(GreenTea.isGtType(args), "args must be a GreenTea type. Use GreenTea.args to specify args.")
	assert(GreenTea.isGtType(callback2), "returns must be a GreenTea type. Use GreenTea.returns returns.")
	assert(args.tuple, "args must be a GreenTea tuple type. Use GreenTea.args to specify args.")
	assert(callback2.tuple, "returns must be a GreenTea tuple type. Use GreenTea.returns returns.")
	local v42 = nil
	v42 = {
		kind = "function",
		fn = {
			args = args,
			returns = callback2
		},
		_matches = function(callback3, ...)
			if typeof(callback3) == "function" then
				return cause.ok()
			end

			return cause.err(v42, callback3, "expected function")
		end,
		_format = function(p, p2: number, p3)
			if p3[v42] then
				return "<cyclic>"
			end

			p3[v42] = true
			local v43 = {}

			for _, content in args.tuple.contents do
				table.insert(v43, content._format(p, p2 - 1, p3))
			end

			if args.tuple.vararg then
				table.insert(v43, args.tuple.vararg._format(p, p2 - 1, p3))
			end

			local v44 = {}

			for _, content in callback2.tuple.contents do
				table.insert(v44, content._format(p, p2 - 1, p3))
			end

			if callback2.tuple.vararg then
				table.insert(v44, callback2.tuple.vararg._format(p, p2 - 1, p3))
			end

			local v45

			if #v43 == 0 then
				v45 = "() ->"
			else
				v45 = `({table.concat(v43, ", ")}) ->`
				local v46 = 0

				for k in string.gmatch(v45, "[^\n]+") do
					if v46 < #k then
						v46 = #k
					end
				end

				if v46 > 80 or v45:find("\n", 1, true) then
					v45 = ([[
(
%*
) ->]]):format(tabFirst(table.concat(v43, ",\n")))
				end
			end

			local vararg = callback2.tuple.vararg or callback2.tuple.contents[#callback2.tuple.contents]
			local v46

			if #v44 == 0 then
				v46 = "()"
			elseif #v44 == 1 and not vararg.__needsParens then
				v46 = v44[1]
			else
				v46 = `({table.concat(v44, ", ")})`
				local v47 = 0

				for k in string.gmatch(v46, "[^\n]+") do
					if v47 < #k then
						v47 = #k
					end
				end

				if v47 > 80 or v46:find("\n", 1, true) then
					v46 = (`({table.concat(v44, ",\n")})`):gsub("\n", "\n    ")
				end
			end

			local formatted = `{v45} {v46}`
			local v47 = 0

			for k in string.gmatch(formatted, "[^\n]+") do
				if v47 < #k then
					v47 = #k
				end
			end

			if p2 < v47 or string.find(formatted, "\n", 1, true) then
				local formatted2 = ("%*\n%*"):format(v45, tabFirst(v46))
				local v48 = p[v42]

				if v48 then
					return (`$${v48}$:{formatted2}:${v48}$$`)
				end

				return formatted2
			else
				local v48 = p[v42]

				if v48 then
					return (`$${v48}$:{formatted}:${v48}$$`)
				end

				return formatted
			end
		end
	}
	return (setmetatable(v42, class))
end

function GreenTea.anyfn()
	return (GreenTea.fn(GreenTea.args(GreenTea.vararg(GreenTea.any({
		allowNil = true
	}))), GreenTea.returns(GreenTea.vararg(GreenTea.any({
		allowNil = true
	})))))
end

function GreenTea.tuplePacked(...)
	return (GreenTea.fn(GreenTea.args(), GreenTea.returns(...)))
end

function GreenTea.table(items, data)
	local array

	if data then
		array = data.array or nil
	else
		array = nil
	end

	local count2

	if data and data.count then
		count2 = parseRange(data.count)
	else
		count2 = nil
	end

	local raw = data and data.raw or nil
	local contents = {}
	local v44 = nil
	local v45 = {}
	local v46 = nil

	for k, item in items do
		if typeof(k) == "table" and GreenTea.isGtType(k) then
			if v44 then
				error("Only one indexer can be specified")
			else
				v44 = GreenTea.typeof(k)
				v46 = GreenTea.typeof(item)
			end
		elseif raw then
			contents[k] = GreenTea.typeof(item)
		elseif typeof(k) == "number" then
			if v44 then
				error("Only one indexer can be specified")
			end

			v44 = GreenTea.number()
			table.insert(v45, GreenTea.typeof(item))
		elseif typeof(k) == "string" then
			contents[k] = GreenTea.typeof(item)
		else
			error("Tables must be defined as arrays or dictionaries with string keys")
		end
	end

	if #v45 > 0 then
		if #v45 == 1 then
			v46 = v45[1]
		else
			v46 = GreenTea.union(table.unpack(v45))
		end
	end

	if array and (not v44 or v44.kind ~= "number") then
		error("If array is true, the table must have an indexer with number keys")
	end

	local v47 = nil
	v47 = {
		kind = "table",
		table = {
			contents = contents,
			indexer = v44 and ({
				key = v44,
				value = v46
			} or nil) or nil,
			array = array,
			count = count2,
			raw = raw
		},
		_matches = function(items2, ...)
			if typeof(items2) ~= "table" then
				return cause.err(v47, items2, "expected table")
			end

			local v48 = {}
			local count = 0
			local v49 = 0

			for k, v50 in contents do
				local item = items2[k]
				local _matches = v50._matches(item)

				if not _matches.ok then
					return cause.extendErr(_matches, v47, items2)
				end

				v48[k] = true
			end

			for k, item in items2 do
				if v48[k] then
					continue
				end

				local v50 = contents[k]

				if v50 then
					local _matches = v50._matches(item)

					if not _matches.ok then
						return cause.extendErr(_matches, v47, items2)
					end
				elseif v44 then
					assert(v46, "analysis hint")
					count += 1

					if count2 then
						local v51 = count2
						local v52

						if v51.min then
							if v51.minExclusive then
								if count <= v51.min then
									v52 = false
								elseif v51.max then
									if v51.maxExclusive then
										v52 = not (v51.max <= count)
									else
										v52 = not (v51.max < count)
									end
								else
									v52 = true
								end
							elseif count < v51.min then
								v52 = false
							elseif v51.max then
								if v51.maxExclusive then
									v52 = not (v51.max <= count)
								else
									v52 = not (v51.max < count)
								end
							else
								v52 = true
							end
						elseif v51.max then
							if v51.maxExclusive then
								v52 = not (v51.max <= count)
							else
								v52 = not (v51.max < count)
							end
						else
							v52 = true
						end

						if not v52 then
							local err = cause.err
							local v53 = v47
							local v56 = displayRange(count2) -- equivalent call inferred; original call site unknown
							return err(
								v53,
								items2,
								(`expected number of items to be in range {v56}, but we saw {count} (or more) items`)
							)
						end
					end

					local _matches = v44._matches(k)

					if not _matches.ok then
						return cause.extendErr(_matches, v47, items2)
					end

					local _matches2 = v46._matches(item)

					if not _matches2.ok then
						return cause.extendErr(_matches2, v47, items2)
					end

					if typeof(k) == "number" then
						v49 = math.max(v49, k)

						if array then
							if k < 1 then
								return cause.err(
									v47,
									items2,
									(`key {k} is less than 1, but we expected a contiguous array`)
								)
							end

							if math.floor(k) ~= k then
								return cause.err(
									v47,
									items2,
									(`key {k} is not an integer, but we expected a contiguous array`)
								)
							end

							if k ~= k then
								return cause.err(v47, items2, (`key {k} is NaN, but we expected a contiguous array`))
							end
						end
					end
				end
			end

			if count2 then
				local v50 = count2
				local v51

				if v50.min then
					if v50.minExclusive then
						if count <= v50.min then
							v51 = false
						elseif v50.max then
							if v50.maxExclusive then
								v51 = not (v50.max <= count)
							else
								v51 = not (v50.max < count)
							end
						else
							v51 = true
						end
					elseif count < v50.min then
						v51 = false
					elseif v50.max then
						if v50.maxExclusive then
							v51 = not (v50.max <= count)
						else
							v51 = not (v50.max < count)
						end
					else
						v51 = true
					end
				elseif v50.max then
					if v50.maxExclusive then
						v51 = not (v50.max <= count)
					else
						v51 = not (v50.max < count)
					end
				else
					v51 = true
				end

				if not v51 then
					local err = cause.err
					local v52 = v47
					local v55 = displayRange(count2) -- equivalent call inferred; original call site unknown
					return err(
						v52,
						items2,
						(`expected number of items to be in range {v55}, but we saw only {count} items`)
					)
				end
			end

			if not array or count == v49 then
				return cause.ok()
			end

			assert(v46, "analysis hint")
			local _matches = v46._matches(nil)

			if not _matches.ok then
				return cause.extendErr(
					_matches,
					v47,
					items2,
					(`expected contiguous array, but we saw only {count} items when the max index was {v49}`)
				)
			end

			return cause.ok()
		end,
		_format = function(p, p2: number, p3)
			if p3[v47] then
				return "<cyclic>"
			end

			p3[v47] = true
			local v48 = {}

			if array then
				table.insert(v48, "@array")
			end

			if count2 then
				local v51 = displayRange(count2) -- equivalent call inferred; original call site unknown
				table.insert(v48, (`@count {v51}`))
			end

			if v44 then
				assert(v46, "analysis hint")

				if v44.kind == "number" then
					table.insert(v48, v46._format(p, p2 - 1, p3))
				else
					local _format = v44._format(p, p2 - 3, p3)
					local _format2 = v46._format(p, p2 - 1, p3)
					local formatted = `[{_format}]: {_format2}`
					local v49 = 0

					for k in string.gmatch(formatted, "[^\n]+") do
						if v49 < #k then
							v49 = #k
						end
					end

					if p2 < v49 then
						formatted = `[{_format}]:\n{_format2}`
					end

					table.insert(v48, formatted)
				end
			end

			for k, v49 in contents do
				local v50 = tostring(k)
				local _format = v49._format(p, p2 - 3, p3)
				local formatted = `{v50}: {_format}`
				local v51 = 0

				for k2 in string.gmatch(formatted, "[^\n]+") do
					if v51 < #k2 then
						v51 = #k2
					end
				end

				if p2 < v51 then
					formatted = `{v50}: {_format}`
				end

				table.insert(v48, formatted)
			end

			if #v48 == 0 then
				local v49 = p[v47]

				if v49 then
					return (`$${v49}$:\{}:${v49}$$`)
				end

				return "{}"
			else
				local formatted = `\{ {table.concat(v48, ", ")} }`
				local v49 = 0

				for k in string.gmatch(formatted, "[^\n]+") do
					if v49 < #k then
						v49 = #k
					end
				end

				if p2 < v49 or string.find(formatted, "\n", 1, true) then
					local formatted2 = ([[
{
%*
}]]):format(tabFirst(table.concat(v48, ",\n")))
					local v50 = p[v47]

					if v50 then
						return (`$${v50}$:{formatted2}:${v50}$$`)
					end

					return formatted2
				else
					local v50 = p[v47]

					if v50 then
						return (`$${v50}$:{formatted}:${v50}$$`)
					end

					return formatted
				end
			end
		end
	}
	return (setmetatable(v47, class))
end

GreenTea.struct = GreenTea.table

function GreenTea.anyTable(p)
	return GreenTea.table({
		[GreenTea.any()] = GreenTea.any()
	}, {
		count = p and p.count
	})
end

function GreenTea.array(p, p2)
	return GreenTea.table({ GreenTea.typeof(p) }, {
		array = true,
		count = p2 and p2.count
	})
end

function GreenTea.dictionary(p, p2, p3)
	return GreenTea.table({
		[GreenTea.typeof(p)] = GreenTea.typeof(p2)
	}, {
		count = p3 and p3.count
	})
end

function GreenTea.union(...)
	local typeofs = table.pack(...)

	for i = typeofs.n, 1, -1 do
		if typeofs[i] ~= nil then
			break
		end

		typeofs.n -= 1
	end

	local typeofs2 = {}
	local typeofs3 = {}

	for i = 1, typeofs.n do
		if typeofs[i] == nil then
			error("implicit nil type not allowed in union; specify explicitly or fix your arguments to not have nil")
		end

		local typeof2 = GreenTea.typeof(typeofs[i])
		typeofs[i] = typeof2

		if typeof2.basic and (typeof2.basic.type == "nil" or typeof2.basic.typeof == "nil") then
			table.insert(typeofs2, typeof2)
		else
			table.insert(typeofs3, typeof2)
		end
	end

	typeofs.n = nil
	assert(#typeofs > 0, "union must have at least one type")
	local v42 = nil
	v42 = {
		kind = "union",
		union = {
			contents = typeofs,
			optional = #typeofs2 > 0
		},
		_needsParens = true,
		_matches = function(input, ...)
			local v43 = {}

			for _, v44 in typeofs do
				local _matches = v44._matches(input)

				if _matches.ok then
					return _matches
				else
					table.move(_matches.errs, 1, #_matches.errs, #v43 + 1, v43)
				end
			end

			table.insert(v43, 1, {
				type = v42,
				input = input,
				message = "input did not match any union member"
			})
			return cause.errs(v43)
		end,
		_format = function(p, p2: number, p3)
			if p3[v42] then
				return "<cyclic>"
			end

			p3[v42] = true

			if #typeofs3 == 0 then
				return "nil"
			end

			if #typeofs3 == 1 then
				if #typeofs2 > 0 then
					local v43 = typeofs3[1]
					local selected

					if v43._needsParens then
						selected = `({v43._format(p, p2 - 3, p3)})?`
					else
						selected = `{v43._format(p, p2 - 1, p3)}?`
					end

					local v45 = p[v42]

					if v45 then
						return (`$${v45}$:{selected}:${v45}$$`)
					end

					return selected
				else
					local _format = typeofs3[1]._format(p, p2, p3)
					local v43 = p[v42]

					if v43 then
						return (`$${v43}$:{_format}:${v43}$$`)
					end

					return _format
				end
			else
				local v43 = {}

				for _, v44 in typeofs do
					local v45

					if v44._needsParens then
						v45 = `({v44._format(p, p2 - 4, p3)})`
					else
						v45 = `{v44._format(p, p2 - 2, p3)}`
					end

					table.insert(v43, v45)
				end

				local joined = table.concat(v43, " | ")
				local v44 = 0

				for k in string.gmatch(joined, "[^\n]+") do
					if v44 < #k then
						v44 = #k
					end
				end

				if p2 < v44 or string.find(joined, "\n", 1, true) then
					local v45 = v43[1] .. tabFirst("\n| " .. table.concat(v43, "\n| ", 2))
					local v46 = p[v42]

					if v46 then
						return (`$${v46}$:{v45}:${v46}$$`)
					end

					return v45
				else
					local v45 = p[v42]

					if v45 then
						return (`$${v45}$:{joined}:${v45}$$`)
					end

					return joined
				end
			end
		end
	}
	return (setmetatable(v42, class))
end

function GreenTea.intersection(...)
	local contents = table.pack(...)

	for i = contents.n, 1, -1 do
		if contents[i] ~= nil then
			break
		end

		contents.n -= 1
	end

	for i = 1, contents.n do
		if contents[i] == nil then
			error("implicit nil type not allowed in intersection; specify explicitly or fix your arguments to not have nil")
		end

		contents[i] = GreenTea.typeof(contents[i])
	end

	contents.n = nil
	assert(#contents > 0, "intersection must have at least one type")
	local v43 = nil
	v43 = {
		kind = "intersection",
		intersection = {
			contents = contents
		},
		_needsParens = true,
		_matches = function(input, ...)
			local v44 = {}
			local v45 = false

			for _, v46 in contents do
				local _matches = v46._matches(input)

				if _matches.ok then
					continue
				end

				table.move(_matches.errs, 1, #_matches.errs, #v44 + 1, v44)
				v45 = true
			end

			if not v45 then
				return cause.ok()
			end

			table.insert(v44, 1, {
				type = v43,
				input = input,
				message = "input did not match all intersection members"
			})
			return cause.errs(v44)
		end,
		_format = function(p, p2: number, p3)
			if p3[v43] then
				return "<cyclic>"
			end

			p3[v43] = true

			if #contents == 0 then
				return "()"
			end

			if #contents == 1 then
				local _format = contents[1]._format(p, p2, p3)
				local v44 = p[v43]

				if v44 then
					return (`$${v44}$:{_format}:${v44}$$`)
				end

				return _format
			else
				local v44 = {}

				for _, v45 in contents do
					local v46

					if v45._needsParens then
						v46 = `({v45._format(p, p2 - 4, p3)})`
					else
						v46 = `{v45._format(p, p2 - 2, p3)}`
					end

					table.insert(v44, v46)
				end

				local joined = table.concat(v44, " & ")
				local v45 = 0

				for k in string.gmatch(joined, "[^\n]+") do
					if v45 < #k then
						v45 = #k
					end
				end

				if p2 < v45 or string.find(joined, "\n", 1, true) then
					local v46 = v44[1] .. tabFirst("\n& " .. table.concat(v44, "\n& ", 2))
					local v47 = p[v43]

					if v47 then
						return (`$${v47}$:{v46}:${v47}$$`)
					end

					return v46
				else
					local v46 = p[v43]

					if v46 then
						return (`$${v46}$:{joined}:${v46}$$`)
					end

					return joined
				end
			end
		end
	}
	return (setmetatable(v43, class))
end

function GreenTea.optional(p)
	return (GreenTea.union(p, GreenTea.none()))
end

GreenTea.oneOf = GreenTea.union
GreenTea.allOf = GreenTea.intersection
GreenTea.opt = GreenTea.optional

function GreenTea.typeof(value, options)
	if GreenTea.isGtType(value) then
		return value
	end

	if greenteaConstructorsSet[value] then
		local v42 = greenteaConstructorsSet[value]
		error((`Attempt to use a GreenTea constructor without calling it: you used {v42}; did you mean to use {v42}() instead?`))
	end

	local v42 = options or {}

	if typeof(value) == "table" then
		local v43 = {}

		for k, item in pairs(value) do
			if v42[item] then
				v43[k] = v42[item]
			end

			v43[k] = GreenTea.typeof(item, v42)
		end

		if typeof((getmetatable(value))) == "table" then
			setmetatable(v43, (getmetatable(value)))
		end

		return (GreenTea.table(v43))
	else
		if typeof(value) == "function" then
			return (GreenTea.anyfn())
		end

		if typeof(value) == "string" then
			return (GreenTea.string())
		end

		if typeof(value) == "number" then
			return (GreenTea.number())
		end

		return (GreenTea.isTypeof(typeof(value), value))
	end
end

function GreenTea.typecast(p)
	assert(GreenTea.isGtType(p), "value must be a GreenTea type")
	return p
end

GreenTea.asGreenTeaType = GreenTea.typecast
GreenTea.asGtType = GreenTea.typecast

local function castTuple(...)
	return ...
end

local _ = {
	type = function(p)
		return castTuple(p)
	end
}

function GreenTea.build(...)
	local v42 = select("#", ...) > 1

	if v42 then
		v42 = false

		for i = 2, select("#", ...) do
			if select(i, ...) == nil then
				continue
			end

			v42 = true
			break
		end
	end

	local v43

	if v42 then
		v43 = GreenTea.tuple(...)
	else
		v43 = GreenTea.typeof((castTuple(...)))
	end

	function v43.type(_)
		return v43
	end

	return v43
end

function GreenTea.meta(p, items)
	local typeof2 = GreenTea.typeof(p)
	typeof2.meta = typeof2.meta or {}
	assert(typeof2.meta, "analysis hint")

	for k, item in items do
		typeof2.meta[k] = item
	end

	return typeof2
end

return GreenTea