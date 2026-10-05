local module = require("./roblox-buff")
local v = {
	[0] = "nil",
	[1] = "false",
	[2] = "true",
	[3] = "string",
	[4] = "i8",
	[5] = "u8",
	[6] = "i16",
	[7] = "u16",
	[8] = "i32",
	[9] = "u32",
	[10] = "f32",
	[11] = "f64",
	[21] = "array",
	[22] = "arrayfixed",
	[23] = "dictionary",
	[24] = "dictionaryfixed",
	[25] = "tablemixed",
	[31] = "buffer"
}

for k, v2 in {
	"Axes",
	"BrickColor",
	"CatalogSearchParams",
	"Color3",
	"ColorSequenceKeypoint",
	"ColorSequence",
	"Content",
	"DateTime",
	"DockWidgetPluginGuiInfo",
	"Enum",
	"EnumItem",
	"Faces",
	"FloatCurveKey",
	"Font",
	"Instance",
	"NumberRange",
	"NumberSequenceKeypoint",
	"NumberSequence",
	"OverlapParams",
	"Path2DControlPoint",
	"PathWaypoint",
	"PhysicalProperties",
	"Random",
	"Ray",
	"RaycastParams",
	"RotationCurveKey",
	"Secret",
	"SharedTable",
	"TweenInfo",
	"UDim",
	"UDim2",
	"Vector2int16",
	"Vector2",
	"Rect",
	"Vector3int16",
	"Vector3",
	"CFrame",
	"Region3"
} do
	v[k + 100] = v2
end

local v2 = {}

for k, v3 in v do
	v2[v3] = k
end

local v3 = {}

local function identifyType(value)
	if type(value) == "number" then
		if value % 1 ~= 0 then
			return v2.f64
		end

		if value >= 0 then
			if value < 256 then
				return v2.u8
			end

			if value < 65536 then
				return v2.u16
			end

			if value < 4294967296 then
				return v2.u32
			end
		else
			if value >= -128 then
				return v2.i8
			end

			if value >= -32768 then
				return v2.i16
			end

			if value >= -2147483648 then
				return v2.i32
			end
		end

		return v2.f64
	else
		if type(value) == "string" then
			return v2.string
		end

		if type(value) == "boolean" then
			return value and v2["true"] or v2["false"]
		end

		if type(value) == "nil" then
			return v2["nil"]
		end

		if type(value) == "table" then
			local typeNames = {}
			local v4 = false
			local typeNames2 = {}
			local count = 0
			local v5 = 0

			for k, item in value do
				local typeName = typeof(k)

				if not table.find(typeNames, typeName) then
					table.insert(typeNames, typeName)
				end

				if typeName == "number" then
					v4 = v4 or k % 1 ~= 0

					if v5 < k then
						v5 = k or v5
					end
				end

				local typeName2 = typeof(item)

				if not table.find(typeNames2, typeName2) then
					table.insert(typeNames2, typeName2)
				end

				count += 1
			end

			if #typeNames ~= 1 then
				return v2.tablemixed
			end

			if typeNames[1] == "number" then
				if not v4 and v5 == count and value[count] then
					return #typeNames2 == 1 and v2.fixedarray or v2.array
				end
			elseif typeNames[1] == "string" then
				return #typeNames2 == 1 and v2.fixeddictionary or v2.dictionary
			end

			return v2.tablemixed
		else
			if v2[typeof(value)] then
				return v2[typeof(value)]
			end

			error((`Failed to identify value of type "{typeof(value)}"`))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getIdFns(p: number)
	local v4 = v[p]
	return v3[v4] or module.fns[v4]
end

v3["false"] = {}

v3["false"].write = function(_, _) end

v3["false"].read = function(_)
	return false
end

v3["true"] = {}

v3["true"].write = function(_, _) end

v3["true"].read = function(_)
	return true
end

v3.array = {}

function v3.array.write(p, list)
	module.writeu32(p, #list)

	for _, v4 in list do
		local v5 = identifyType(v4)
		local idFns = getIdFns(v5) -- equivalent call inferred; original call site unknown
		module.writeu8(p, v5)
		idFns.write(p, v4)
	end
end

function v3.array.read(p)
	local readu32 = module.readu32(p)
	local result = table.create(readu32)

	for i = 1, readu32 do
		result[i] = (getIdFns(module.readu8(p))).read(p)
	end

	return result
end

v3.arrayfixed = {}

function v3.arrayfixed.write(p, list)
	local v4 = identifyType(list[1])
	local idFns = getIdFns(v4) -- equivalent call inferred; original call site unknown
	module.writeu32(p, #list)
	module.writeu8(p, v4)

	for _, v5 in list do
		idFns.write(p, v5)
	end
end

function v3.arrayfixed.read(p)
	local readu32 = module.readu32(p)
	local result = table.create(readu32)
	local idFns = getIdFns(module.readu8(p)) -- equivalent call inferred; original call site unknown

	for i = 1, readu32 do
		result[i] = idFns.read(p)
	end

	return result
end

v3.dictionary = {}

function v3.dictionary.write(p, items)
	local count = 0

	for _ in items do
		count += 1
	end

	module.writeu32(p, count)

	for k, item in items do
		module.fns.string.write(p, k)
		local v4 = identifyType(item)
		local idFns = getIdFns(v4) -- equivalent call inferred; original call site unknown
		module.writeu8(p, v4)
		idFns.write(p, item)
	end
end

function v3.dictionary.read(p)
	local result = {}

	for _ = 1, module.readu32(p) do
		local v4 = module.fns.string.read(p)
		result[v4] = (getIdFns(module.readu8(p))).read(p)
	end

	return result
end

v3.dictionaryfixed = {}

function v3.dictionaryfixed.write(p, items)
	local _, v4 = next(items)
	local v5 = identifyType(v4)
	local idFns = getIdFns(v5) -- equivalent call inferred; original call site unknown
	local count = 0

	for _ in items do
		count += 1
	end

	module.writeu32(p, count)
	module.writeu8(p, v5)

	for k, item in items do
		module.fns.string.write(p, k)
		idFns.write(p, item)
	end
end

function v3.dictionaryfixed.read(p)
	local readu32 = module.readu32(p)
	local idFns = getIdFns(module.readu8(p)) -- equivalent call inferred; original call site unknown
	local result = {}

	for _ = 1, readu32 do
		result[module.fns.string.read(p)] = idFns.read(p)
	end

	return result
end

v3.tablemixed = {}

function v3.tablemixed.write(p, items)
	local count = 0

	for _ in items do
		count += 1
	end

	module.writeu32(p, count)

	for k, item in items do
		local v4 = identifyType(k)
		local idFns = getIdFns(v4) -- equivalent call inferred; original call site unknown
		module.writeu8(p, v4)
		idFns.write(p, k)
		local v5 = identifyType(item)
		local idFns2 = getIdFns(v5) -- equivalent call inferred; original call site unknown
		module.writeu8(p, v5)
		idFns2.write(p, item)
	end
end

function v3.tablemixed.read(p)
	local result = {}

	for _ = 1, module.readu32(p) do
		local v4 = (getIdFns(module.readu8(p))).read(p)
		result[v4] = (getIdFns(module.readu8(p))).read(p)
	end

	return result
end

local RobloxBuffDyn = {}

function RobloxBuffDyn.writeData(p, p2)
	local v4 = identifyType(p2)
	local idFns = getIdFns(v4) -- equivalent call inferred; original call site unknown
	module.writeu8(p, v4)
	idFns.write(p, p2)
end

function RobloxBuffDyn.readData(p)
	return ((getIdFns(module.readu8(p))).read(p))
end

function RobloxBuffDyn.encode(p)
	local v4 = module.create(0)
	local v5 = identifyType(p)
	local idFns = getIdFns(v5) -- equivalent call inferred; original call site unknown
	module.writeu8(v4, v5)
	idFns.write(v4, p)
	return v4.buffer
end

function RobloxBuffDyn.decode(buf: buffer)
	local frombuffer = module.frombuffer(buf)
	return ((getIdFns(module.readu8(frombuffer))).read(frombuffer))
end

return RobloxBuffDyn