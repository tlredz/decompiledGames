local createVector = vector.create
local cfg = {
	Pretty = true,
	IndentChar = " ",
	IndentSize = 2
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isInt(p: number)
	return math.abs(p - math.round(p)) < 1e-6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roundTo(p: number, p2: number)
	return math.round(p * p2) / p2
end

local function formatNum(p: number, p2: number)
	local v3 = roundTo(p, 10 ^ p2) -- equivalent call inferred; original call site unknown

	if v3 == 0 and p ~= 0 then
		return (tostring(p))
	end

	local v4, _ = string.format("%." .. p2 .. "f", v3):gsub("%.?0+$", "")

	if v4 == "" or v4 == "-" then
		return "0"
	end

	return v4
end

local function isValidId(value: string)
	return value:match("^[a-zA-Z_][a-zA-Z0-9_]*$") == value
end

local function makeIndent(value: string, p: number, p2: number)
	return string.rep(value, p * p2)
end

local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function serialize(p, p2)
	local callback = v2[typeof(p)]

	if callback then
		return callback(p, p2)
	end

	return (`[{typeof(p)}]`)
end

v2["nil"] = function(_: nil, _)
	return "nil"
end

function v2.boolean(flag: boolean, _)
	if flag then
		return "true"
	end

	return "false"
end

function v2.number(p: number, p2)
	if p == 1e999 then
		return "math.huge"
	elseif p == -1e999 then
		return "-math.huge"
	end

	if p ~= p then
		return "0/0"
	end

	local v3

	if p2.cfg.Pretty then
		local v4 = roundTo(p, 1000000) -- equivalent call inferred; original call site unknown

		if v4 == 0 and p ~= 0 then
			v3 = tostring(p)
		else
			local v5, _ = string.format("%." .. 6 .. "f", v4):gsub("%.?0+$", "")
			v3 = (v5 == "" or v5 == "-") and "0" or v5
		end

		if not v3 then
			return (tostring(p))
		end
	else
		return (tostring(p))
	end

	return v3
end

function v2.string(p: string, _)
	return string.format("%q", p)
end

v2["function"] = function(_)
	return "[function]"
end

function v2.Instance(instance)
	if instance.Parent then
		return (`[{instance.ClassName} {instance:GetFullName()}]`)
	end

	return (`[{instance.ClassName}]`)
end

function v2.table(list, state)
	local metatable = getmetatable(list)

	if metatable and metatable.__tostring then
		local v3 = tostring(list)
		local indentChar = state.cfg.IndentChar
		local indentSize = state.cfg.IndentSize
		local depth = state.depth
		return v3:gsub("\n", "\n" .. string.rep(indentChar, indentSize * depth))
	else
		if state.seen[list] then
			return "{...}"
		end

		state.seen[list] = true
		local v3 = {}
		local v4 = 0

		for k in pairs(list) do
			if typeof(k) == "number" and isInt(k) and k > 0 then
				v4 = math.max(v4, k)
			end

			table.insert(v3, k)
		end

		local v5

		if #v3 == v4 then
			v5 = #v3 > 0
		else
			v5 = false
		end

		for i = 1, v4 do
			if list[i] ~= nil then
				continue
			end

			v5 = false
			break
		end

		state.depth += 1
		local pretty = state.cfg.Pretty
		local v6

		if pretty then
			local indentChar = state.cfg.IndentChar
			local indentSize = state.cfg.IndentSize
			local depth = state.depth
			v6 = "\n" .. string.rep(indentChar, indentSize * depth) or ""
		else
			v6 = ""
		end

		local v7

		if pretty then
			local indentChar = state.cfg.IndentChar
			local indentSize = state.cfg.IndentSize
			local depth = state.depth
			v7 = ",\n" .. string.rep(indentChar, indentSize * depth) or ","
		else
			v7 = ","
		end

		local v8 = {}

		if v5 then
			for i = 1, v4 do
				local v10 = serialize(list[i], state) -- equivalent call inferred; original call site unknown
				v8[i] = v10
			end
		else
			local order = state.order
			local v9 = {}

			for i, v10 in ipairs(v3) do
				v9[v10] = i
			end

			local v10 = {}

			for _, v11 in ipairs(v3) do
				table.insert(v10, { v11, list[v11] })
			end

			if order then
				table.sort(v10, function(a, b)
					local v11 = not order[a[1]] and 1e999 or order[a[1]].Index or 1e999
					local v12 = not order[b[1]] and 1e999 or order[b[1]].Index or 1e999
					return v11 ~= v12 and v11 < v12 or v9[a[1]] < v9[b[1]]
				end)
			end

			for _, v11 in ipairs(v10) do
				local v12 = v11[1]
				local v13 = v11[2]
				local child

				if order and order[v12] then
					child = order[v12].Child or nil
				end

				local order2 = state.order
				state.order = child

				if typeof(v12) ~= "string" or v12:match("^[a-zA-Z_][a-zA-Z0-9_]*$") ~= v12 or not v12 then
					local v15 = serialize(v12, state) -- equivalent call inferred; original call site unknown
					v12 = `[{v15}]`
				end

				local v14 = serialize(v13, state) -- equivalent call inferred; original call site unknown
				table.insert(v8, pretty and `{v12} = {v14}` or `{v12}={v14}`)
				state.order = order2
			end
		end

		state.depth -= 1
		state.seen[list] = nil

		if #v8 == 0 then
			return "{}"
		end

		if not pretty then
			return "{" .. table.concat(v8, v7) .. "}"
		end

		local indentChar = state.cfg.IndentChar
		local indentSize = state.cfg.IndentSize
		local depth = state.depth
		local v9 = "\n" .. string.rep(indentChar, indentSize * depth)
		return "{" .. v6 .. table.concat(v8, v7) .. "," .. v9 .. "}"
	end
end

function v2.Color3(color: Color3, p)
	local v3 = color.R * 255
	local v4 = color.G * 255
	local v5 = color.B * 255
	local v6 = "fromRGB"
	local R, G, B

	if isInt(v3) and isInt(v4) and isInt(v5) then
		R = math.round(v3)
		G = math.round(v4)
		B = math.round(v5)
	else
		R = color.R
		G = color.G
		B = color.B
		v6 = "new"
	end

	if p.cfg.Pretty then
		local v8 = serialize(R, p) -- equivalent call inferred; original call site unknown
		local v9 = serialize(G, p) -- equivalent call inferred; original call site unknown
		local v10 = serialize(B, p) -- equivalent call inferred; original call site unknown
		return (`Color3.{v6}({v8}, {v9}, {v10})`)
	else
		local v8 = serialize(R, p) -- equivalent call inferred; original call site unknown
		local v9 = serialize(G, p) -- equivalent call inferred; original call site unknown
		local v10 = serialize(B, p) -- equivalent call inferred; original call site unknown
		return (`Color3.{v6}({v8},{v9},{v10})`)
	end
end

function v2.Vector3(vector2: Vector3, p)
	if vector2 == createVector(0, 0, 0) then
		return "Vector3.zero"
	elseif vector2 == createVector(1, 1, 1) then
		return "Vector3.one"
	elseif vector2 == createVector(1, 0, 0) then
		return "Vector3.xAxis"
	elseif vector2 == createVector(0, 1, 0) then
		return "Vector3.yAxis"
	elseif vector2 == createVector(0, 0, 1) then
		return "Vector3.zAxis"
	end

	if p.cfg.Pretty then
		local v4 = serialize(vector2.X, p) -- equivalent call inferred; original call site unknown
		local v5 = serialize(vector2.Y, p) -- equivalent call inferred; original call site unknown
		local v6 = serialize(vector2.Z, p) -- equivalent call inferred; original call site unknown
		return (`Vector3.new({v4}, {v5}, {v6})`)
	else
		local v4 = serialize(vector2.X, p) -- equivalent call inferred; original call site unknown
		local v5 = serialize(vector2.Y, p) -- equivalent call inferred; original call site unknown
		local v6 = serialize(vector2.Z, p) -- equivalent call inferred; original call site unknown
		return (`Vector3.new({v4},{v5},{v6})`)
	end
end

function v2.Vector2(point: Vector2, p)
	if point == Vector2.zero then
		return "Vector2.zero"
	end

	if point == Vector2.one then
		return "Vector2.one"
	end

	if point == Vector2.xAxis then
		return "Vector2.xAxis"
	end

	if point == Vector2.yAxis then
		return "Vector2.yAxis"
	end

	if p.cfg.Pretty then
		local v4 = serialize(point.X, p) -- equivalent call inferred; original call site unknown
		local v5 = serialize(point.Y, p) -- equivalent call inferred; original call site unknown
		return (`Vector2.new({v4}, {v5})`)
	else
		local v4 = serialize(point.X, p) -- equivalent call inferred; original call site unknown
		local v5 = serialize(point.Y, p) -- equivalent call inferred; original call site unknown
		return (`Vector2.new({v4},{v5})`)
	end
end

function v2.CFrame(cframe: CFrame, p)
	if cframe == CFrame.identity then
		return "CFrame.identity"
	end

	local position = cframe.Position
	local orientation, v3, v4 = cframe:ToOrientation()
	local magnitude = position.Magnitude
	local _, _, _, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cframe:GetComponents()
	local v14 = math.abs(v5 - 1) > 1e-6 or math.abs(v9 - 1) > 1e-6 or math.abs(v13 - 1) > 1e-6 or math.abs(v6) > 1e-6 or math.abs(v7) > 1e-6 or math.abs(v8) > 1e-6 or math.abs(v10) > 1e-6 or math.abs(v11) > 1e-6 or math.abs(v12) > 1e-6
	local v15 = magnitude > 1e-6
	local pretty = p.cfg.Pretty
	local v16, v17, X, v18, v19, Y, v20, v21, Z, v22, v23

	if pretty then
		local v25 = roundTo(position.X, 1000000) -- equivalent call inferred; original call site unknown
		local v26 = serialize(v25, p) -- equivalent call inferred; original call site unknown
		local v27 = roundTo(position.Y, 1000000) -- equivalent call inferred; original call site unknown
		local v28 = serialize(v27, p) -- equivalent call inferred; original call site unknown
		local v29 = roundTo(position.Z, 1000000) -- equivalent call inferred; original call site unknown
		local v30 = serialize(v29, p) -- equivalent call inferred; original call site unknown
		v16 = `CFrame.new({v26}, {v28}, {v30})`

		if not v16 then
			v17 = "CFrame.new(%*,%*,%*)"
			X = position.X
			v18 = v2[typeof(X)]

			if v18 then
				v19 = v18(X, p)
			else
				v19 = `[{typeof(X)}]`
			end

			Y = position.Y
			v20 = v2[typeof(Y)]

			if v20 then
				v21 = v20(Y, p)
			else
				v21 = `[{typeof(Y)}]`
			end

			Z = position.Z
			v22 = v2[typeof(Z)]

			if v22 then
				v23 = v22(Z, p)
			else
				v23 = `[{typeof(Z)}]`
			end

			v16 = v17:format(v19, v21, v23)
		end
	else
		v17 = "CFrame.new(%*,%*,%*)"
		X = position.X
		v18 = v2[typeof(X)]

		if v18 then
			v19 = v18(X, p)
		else
			v19 = `[{typeof(X)}]`
		end

		Y = position.Y
		v20 = v2[typeof(Y)]

		if v20 then
			v21 = v20(Y, p)
		else
			v21 = `[{typeof(Y)}]`
		end

		Z = position.Z
		v22 = v2[typeof(Z)]

		if v22 then
			v23 = v22(Z, p)
		else
			v23 = `[{typeof(Z)}]`
		end

		v16 = v17:format(v19, v21, v23)
	end

	local v24, v25, v26, v27, v28, v29, v30, v31

	if pretty then
		local v33 = roundTo(math.deg(orientation), 1000000) -- equivalent call inferred; original call site unknown
		local v34 = serialize(v33, p) -- equivalent call inferred; original call site unknown
		local v35 = roundTo(math.deg(v3), 1000000) -- equivalent call inferred; original call site unknown
		local v36 = serialize(v35, p) -- equivalent call inferred; original call site unknown
		local v37 = roundTo(math.deg(v4), 1000000) -- equivalent call inferred; original call site unknown
		local v38 = serialize(v37, p) -- equivalent call inferred; original call site unknown
		v24 = `CFrame.fromOrientation(math.rad({v34}), math.rad({v36}), math.rad({v38}))`

		if not v24 then
			v25 = "CFrame.fromOrientation(%*,%*,%*)"
			v26 = v2[typeof(orientation)]

			if v26 then
				v27 = v26(orientation, p)
			else
				v27 = `[{typeof(orientation)}]`
			end

			v28 = v2[typeof(v3)]

			if v28 then
				v29 = v28(v3, p)
			else
				v29 = `[{typeof(v3)}]`
			end

			v30 = v2[typeof(v4)]

			if v30 then
				v31 = v30(v4, p)
			else
				v31 = `[{typeof(v4)}]`
			end

			v24 = v25:format(v27, v29, v31)
		end
	else
		v25 = "CFrame.fromOrientation(%*,%*,%*)"
		v26 = v2[typeof(orientation)]

		if v26 then
			v27 = v26(orientation, p)
		else
			v27 = `[{typeof(orientation)}]`
		end

		v28 = v2[typeof(v3)]

		if v28 then
			v29 = v28(v3, p)
		else
			v29 = `[{typeof(v3)}]`
		end

		v30 = v2[typeof(v4)]

		if v30 then
			v31 = v30(v4, p)
		else
			v31 = `[{typeof(v4)}]`
		end

		v24 = v25:format(v27, v29, v31)
	end

	if not v15 then
		return v24
	end

	if v14 then
		return v16 .. (pretty and " * " or "*") .. v24 or v16
	end

	return v16
end

function v2.EnumItem(p, _)
	return (`Enum.{tostring(p.EnumType)}.{p.Name}`)
end

local v3 = {
	DEFAULT_CONFIG = cfg,
	Pretty = function(p, data)
		local cfg2 = {
			Pretty = data and data.Pretty or cfg.Pretty,
			IndentChar = data and data.IndentChar or cfg.IndentChar,
			IndentSize = data and data.IndentSize or cfg.IndentSize,
			Order = data and data.Order or cfg.Order
		}
		return serialize(p, {
			cfg = cfg2,
			depth = 0,
			order = cfg2.Order,
			seen = {}
		})
	end,
	Serialize = function(p, cfg2)
		return serialize(p, {
			cfg = cfg2,
			depth = 0,
			order = cfg2.Order,
			seen = {}
		})
	end,
	Default = function(p)
		return serialize(p, {
			cfg = cfg,
			depth = 0,
			order = cfg.Order,
			seen = {}
		})
	end
}

function v3.DefaultArgs(...)
	local v4 = table.pack(...)
	local v5 = {}

	for i = 1, v4.n do
		if i > 1 then
			table.insert(v5, ", ")
		end

		table.insert(v5, v3.Default(v4[i]))
	end

	return table.concat(v5)
end

function v3.DefaultArgsPrefix(...)
	local v4 = table.pack(...)
	local v5 = {}

	for i = 1, v4.n do
		table.insert(v5, ", ")
		table.insert(v5, v3.Default(v4[i]))
	end

	return table.concat(v5)
end

function v3.CompileOrder(list)
	assert(type(list) == "table")
	assert(#list ~= 0 or next(list) == nil)
	local result = {}

	for i, v4 in ipairs(list) do
		if type(v4) == "table" then
			local key = v4.Key
			assert(type(key) == "string")
			result[key] = {
				Index = i,
				Child = v3.CompileOrder(v4.Value)
			}
		else
			result[v4] = {
				Index = i
			}
		end
	end

	return result
end

return table.freeze(v3)