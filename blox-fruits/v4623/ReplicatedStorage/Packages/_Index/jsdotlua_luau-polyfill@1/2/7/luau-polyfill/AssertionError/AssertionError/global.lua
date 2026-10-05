local collections = require(script.Parent.Parent.Parent:WaitForChild("collections"))
local array = collections.Array
local object = collections.Object
local boolean = require(script.Parent.Parent.Parent:WaitForChild("boolean"))
local string2 = require(script.Parent.Parent.Parent:WaitForChild("string"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
local inspect = collections.inspect
local Error = require(script.Parent.Parent:WaitForChild("Error"))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild("instance-of"))
local v = {
	stderr = {
		isTTY = false,
		columns = 0,
		hasColors = function(...)
			return true
		end
	}
}

function ErrorCaptureStackTrace(p, ...)
	Error.captureStackTrace(p, ...)
end

local function removeColors(p)
	return p
end

local v2 = ""
local v3 = ""
local v4 = ""
local v5 = ""
local v6 = {
	deepStrictEqual = "Expected values to be strictly deep-equal:",
	strictEqual = "Expected values to be strictly equal:",
	strictEqualObject = "Expected \"actual\" to be reference-equal to \"expected\":",
	deepEqual = "Expected values to be loosely deep-equal:",
	notDeepStrictEqual = "Expected \"actual\" not to be strictly deep-equal to:",
	notStrictEqual = "Expected \"actual\" to be strictly unequal to:",
	notStrictEqualObject = "Expected \"actual\" not to be reference-equal to \"expected\":",
	notDeepEqual = "Expected \"actual\" not to be loosely deep-equal to:",
	notIdentical = "Values have same structure but are not reference-equal:",
	notDeepEqualUnequal = "Expected values not to be loosely deep-equal:"
}

local function copyError(p)
	local keys = object.keys(p)
	local result = {}

	for _, key in keys do
		result[key] = p[key]
	end

	result.message = p.message
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inspectValue(p)
	return inspect(p, {
		compact = false,
		customInspect = false,
		depth = 1000,
		maxArrayLength = 1e999,
		showHidden = false,
		showProxy = false,
		sorted = true,
		getters = true
	})
end

local function createErrDiff(actual, expected, operator)
	local v7 = ""
	local v8 = ""
	local v9 = ""
	local v10 = false
	local v11 = inspectValue(actual) -- equivalent call inferred; original call site unknown
	local parts = string2.split(v11, "\n")
	local parts2 = string2.split(inspect(expected, {
		compact = false,
		customInspect = false,
		depth = 1000,
		maxArrayLength = 1e999,
		showHidden = false,
		showProxy = false,
		sorted = true,
		getters = true
	}), "\n")
	local v12 = 0
	local v13 = ""
	local v14 = operator == "strictEqual" and (typeof(actual) == "table" and actual ~= nil and typeof(expected) == "table" and expected ~= nil or typeof(actual) == "function" and typeof(expected) == "function") and "strictEqualObject" or operator

	if #parts == 1 and #parts2 == 1 and parts[1] ~= parts2[1] then
		local part = parts[1]

		if boolean.toJSBoolean(false) then
		end

		local part2 = parts2[1]
		local v15 = string.len(part) + string.len(part2)

		if v15 <= 12 then
			if (typeof(actual) ~= "table" or actual == nil) and (typeof(expected) ~= "table" or expected == nil) and (actual ~= 0 or expected ~= 0) then
				return ([[
%s

]]):format(v6[v14]) .. ("%s !== %s\n"):format(parts[1], parts2[1])
			end
		elseif v14 ~= "strictEqualObject" and v15 < (not v.stderr.isTTY and 80 or v.stderr.columns) then
			while string.sub(part, v12 + 1, v12 + 1) == string.sub(part2, v12 + 1, v12 + 1) do
				v12 += 1
			end

			if v12 > 2 then
				v13 = ("\n  %s^"):format(string.rep(" ", v12))
				v12 = 0
			end
		end
	end

	local part = parts[#parts]
	local part2 = parts2[#parts2]
	local v15

	while true do
		if part ~= part2 then
			v15 = v12
			break
		end

		v15 = v12 + 1

		if v12 < 3 then
			v9 = ("\n  %s%s"):format(part, v9)
		else
			v7 = part
		end

		table.remove(parts)
		table.remove(parts2)

		if #parts == 0 or #parts2 == 0 then
			break
		end

		part = parts[#parts]
		part2 = parts2[#parts2]
		v12 = v15
	end

	local v16 = math.max(#parts, #parts2)

	if v16 == 0 then
		local parts3 = string2.split(v11, "\n")

		if #parts3 > 50 then
			parts3[47] = ("%s...%s"):format(v2, v5)

			while #parts3 > 47 do
				table.remove(parts3)
			end
		end

		return ([[
%s

]]):format("Values have same structure but are not reference-equal:") .. ("%s\n"):format(array.join(parts3, "\n"))
	else
		if v15 >= 5 then
			v9 = ("\n%s...%s%s"):format(v2, v5, v9)
			v10 = true
		end

		if v7 ~= "" then
			v9 = ("\n  %s%s"):format(v7, v9)
			v7 = ""
		end

		local total = 0
		local count = 0
		local v17 = v6[v14] .. ("\n%s+ actual%s %s- expected%s"):format(v3, v5, v4, v5)
		local formatted = (" %s...%s Lines skipped"):format(v2, v5)
		local formatted2 = ("%s+%s"):format(v3, v5)
		local count2 = #parts2
		local v18

		if #parts < v16 then
			formatted2 = ("%s-%s"):format(v4, v5)
			count2 = #parts
			v18 = parts2
		else
			v18 = parts
		end

		for i = 1, v16 do
			if count2 < i then
				if count > 2 then
					if count > 3 then
						if count > 4 then
							if count == 5 then
								v8 ..= ("\n  %s"):format(v18[i - 3])
								total += 1
							else
								v8 ..= ("\n%s...%s"):format(v2, v5)
								v10 = true
							end
						end

						v8 ..= ("\n  %s"):format(v18[i - 2])
						total += 1
					end

					v8 ..= ("\n  %s"):format(v18[i - 1])
					total += 1
				end

				count = 0

				if v18 == parts then
					v8 ..= ("\n%s %s"):format(formatted2, v18[i])
				else
					v7 ..= ("\n%s %s"):format(formatted2, v18[i])
				end

				total += 1
			else
				local part3 = parts2[i]
				local part4 = parts[i]
				local v19

				if part4 == part3 then
					v19 = false
				else
					v19 = not boolean.toJSBoolean(string2.endsWith(part4, ",")) or string2.slice(part4, 0, -1) ~= part3
				end

				if v19 and string2.endsWith(part3, ",") and string2.slice(part3, 0, -1) == part4 then
					part4 ..= ","
					v19 = false
				end

				if v19 then
					if count > 2 then
						if count > 3 then
							if count > 4 then
								if count == 5 then
									v8 ..= ("\n  %s"):format(parts[i - 3])
									total += 1
								else
									v8 ..= ("\n%s...%s"):format(v2, v5)
									v10 = true
								end
							end

							v8 ..= ("\n  %s"):format(parts[i - 2])
							total += 1
						end

						v8 ..= ("\n  %s"):format(parts[i - 1])
						total += 1
					end

					v8 ..= ("\n%s+%s %s"):format(v3, v5, part4)
					v7 ..= ("\n%s-%s %s"):format(v4, v5, part3)
					total += 2
					count = 0
				else
					v8 ..= v7
					v7 = ""
					count += 1

					if count <= 2 then
						v8 ..= ("\n  %s"):format(part4)
						total += 1
					end
				end
			end

			if total > 50 and i < v16 - 2 then
				return ([[
%s%s
%s
%s...%s%s
]]):format(v17, formatted, v8, v2, v5, v7) .. ("%s...%s"):format(v2, v5)
			end
		end

		return ("%s%s\n%s%s%s%s"):format(v17, not v10 and "" or formatted, v8, v7, v9, v13)
	end
end

local object2 = setmetatable({}, {
	__index = Error
})
object2.__index = object2

function object2:__tostring()
	return self:toString()
end

function object2.new(data)
	local message = data.message
	local operator = data.operator
	local stackStartFn = data.stackStartFn
	local actual = data.actual
	local expected = data.expected
	local v7

	if message == nil then
		if v.stderr.isTTY then
			if v.stderr:hasColors() then
				v2 = "\27[34m"
				v3 = "\27[32m"
				v5 = "\27[39m"
				v4 = "\27[31m"
			else
				v2 = ""
				v3 = ""
				v5 = ""
				v4 = ""
			end
		end

		if typeof(actual) == "table" and actual ~= nil and typeof(expected) == "table" and expected ~= nil and array.indexOf(
			object.keys(actual),
			"stack"
		) ~= -1 and instanceof(actual, Error) and array.indexOf(object.keys(expected), "stack") ~= -1 and instanceof(
			expected,
			Error
		) then
			local keys = object.keys(actual)
			local v8 = actual
			actual = {}

			for _, key in keys do
				actual[key] = v8[key]
			end

			actual.message = v8.message
			local keys2 = object.keys(expected)
			local v9 = expected
			expected = {}

			for _, key in keys2 do
				expected[key] = v9[key]
			end

			expected.message = v9.message
		end

		if operator == "deepStrictEqual" or operator == "strictEqual" then
			v7 = setmetatable(Error.new(createErrDiff(actual, expected, operator)), object2)
		elseif operator == "notDeepStrictEqual" or operator == "notStrictEqual" then
			local v8 = v6[operator]
			local parts = string2.split(inspect(actual, {
				compact = false,
				customInspect = false,
				depth = 1000,
				maxArrayLength = 1e999,
				showHidden = false,
				showProxy = false,
				sorted = true,
				getters = true
			}), "\n")
			local v9 = operator == "notStrictEqual" and (typeof(actual) == "table" and actual ~= nil or typeof(actual) == "function") and "Expected \"actual\" not to be reference-equal to \"expected\":" or v8

			if #parts > 50 then
				parts[47] = ("%s...%s"):format(v2, v5)

				while #parts > 47 do
					table.remove(parts)
				end
			end

			if #parts == 1 then
				v7 = setmetatable(Error.new(("%s%s%s"):format(v9, string.len(parts[1]) > 5 and [[


]] or " ", parts[1])), object2)
			else
				v7 = setmetatable(Error.new(([[
%s

%s
]]):format(v9, array.join(parts, "\n"))), object2)
			end
		else
			local v8 = inspectValue(actual) -- equivalent call inferred; original call site unknown
			local v9 = inspectValue(expected) -- equivalent call inferred; original call site unknown
			local v10 = v6[tostring(operator)]

			if operator == "notDeepEqual" and v8 == v9 then
				local formatted = ([[
%s

%s]]):format(v10, v8)

				if string.len(formatted) > 1024 then
					formatted = ("%s..."):format(string2.slice(formatted, 0, 1021))
				end

				v7 = setmetatable(Error.new(formatted), object2)
			else
				if string.len(v8) > 512 then
					v8 = ("%s..."):format(string2.slice(v8, 0, 509))
				end

				if string.len(v9) > 512 then
					v9 = ("%s..."):format(string2.slice(v9, 0, 509))
				end

				if operator == "deepEqual" then
					v8 = ([[
%s

%s

should loosely deep-equal

]]):format(v10, v8)
				else
					local v11 = v6[("%sUnequal"):format((tostring(operator)))]

					if boolean.toJSBoolean(v11) then
						v8 = ([[
%s

%s

should not loosely deep-equal

]]):format(v11, v8)
					else
						v9 = (" %s %s"):format(tostring(operator), v9)
					end
				end

				v7 = setmetatable(Error.new(("%s%s"):format(v8, v9)), object2)
			end
		end
	else
		v7 = setmetatable(Error.new((tostring(message))), object2)
	end

	v7.generatedMessage = not boolean.toJSBoolean(message)
	v7.name = "AssertionError [ERR_ASSERTION]"
	v7.code = "ERR_ASSERTION"
	v7.actual = actual
	v7.expected = expected
	v7.operator = operator
	ErrorCaptureStackTrace(v7, stackStartFn or object2.new)
	v7.name = "AssertionError"
	return v7
end

function object2:toString()
	return ("%s [%s]: %s"):format(self.name, self.code, self.message)
end

object2.name = "AssertionError"
return {
	AssertionError = object2
}