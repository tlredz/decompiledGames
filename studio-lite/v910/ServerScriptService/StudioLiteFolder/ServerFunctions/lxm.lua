local Lxm = {}
Lxm.__index = Lxm
local Buffer = require(script.Buffer)
require(script.Types)
local lz4 = require(script.lz4)
local zstd = require(script.zstd)
local chunks = script.Chunks
local v = {
	["END\0"] = true,
	INST = true,
	META = true,
	PRNT = true,
	PROP = true,
	SIGN = true,
	SSTR = true
}
local modules = {
	INST = require(chunks.INST),
	META = require(chunks.META),
	PRNT = require(chunks.PRNT),
	PROP = require(chunks.PROP),
	SSTR = require(chunks.SSTR)
}

local function Chunk(object, count: number)
	local v3 = {
		InternalID = count,
		Header = object:read(4)
	}

	if not v[v3.Header] then
		print(string.byte(v3.Header, 1, 4))
		error((`Invalid chunk identifier {v3.Header} on chunk id {count}`))
	end

	local v4 = object:read(16, false)
	local v5 = string.unpack("<I4", (string.sub(v4, 1, 4)))
	local v6 = string.unpack("<I4", (string.sub(v4, 5, 8)))
	local v7 = string.sub(v4, 9, 12)
	local v8 = string.sub(v4, 13, 16)

	if v7 ~= "\0\0\0\0" then
		error((`Invalid chunk header on chunk id {count} of identifier {v3.Header}`))
	end

	local v9

	if v5 == 0 then
		v9 = object:read(v6 + 12)
	elseif v8 == "(\181/\253" then
		object:seek(12)
		v9 = zstd(object:read(v5))
	else
		v9 = lz4(object:read(v5 + 12))
	end

	v3.Data = Buffer(v9, false)

	function v3.Error(p, p2)
		error((`[{p.Header}:{p.InternalID}]: {p2}`))
	end

	return v3
end

local function procChunkType(p, p2: string, p3)
	local v3 = p[p2]
	local v4 = modules[p2]

	if v3 and v4 then
		for _, v5 in v3 do
			v4(v5, p3)
		end
	end
end

function Lxm.rbxm(_, p: string)
	local buffer = Buffer(p, false)

	if buffer:read(8) ~= "<roblox!" or buffer:read(6) ~= "\137\255\r\n\26\n" then
		error("Provided file does not match the header of an RBXM file.")
	end

	if buffer:read(2) ~= "\0\0" then
		error("Invalid RBXM version, if Roblox has released a newer version (unlikely), please let me know.")
	end

	local number = buffer:readNumber("<i4")
	local number2 = buffer:readNumber("<i4")
	local v4 = {
		ClassRefs = table.create(number),
		InstanceRefs = table.create(number2),
		Tree = {},
		Metadata = {},
		Strings = {}
	}
	local v7 = {}

	for k in v do
		v7[k] = {}
	end

	if buffer:read(8) ~= "\0\0\0\0\0\0\0\0" then
		error("2) Provided file does not match the header of an RBXM file.")
	end

	local lastTime = tick()
	local count = 0
	local v8 = 1

	while true do
		count += 1
		local chunk = Chunk(buffer, count)
		table.insert(v7[chunk.Header], chunk)

		if tick() - lastTime > 2 then
			lastTime = tick()
			print("Loading", v8)
			v8 += 1
			task.wait()
		end

		if chunk.Header ~= "END\0" then
			continue
		end

		task.wait()
		local META2 = v7.META
		local META3 = modules.META

		if META2 and META3 then
			for _, v10 in META2 do
				META3(v10, v4)
			end
		end

		task.wait()
		local SSTR2 = v7.SSTR
		local SSTR3 = modules.SSTR

		if SSTR2 and SSTR3 then
			for _, v10 in SSTR2 do
				SSTR3(v10, v4)
			end
		end

		task.wait()
		local INST2 = v7.INST
		local INST3 = modules.INST

		if INST2 and INST3 then
			for _, v10 in INST2 do
				INST3(v10, v4)
			end
		end

		task.wait()
		local PROP2 = v7.PROP
		local PROP3 = modules.PROP

		if PROP2 and PROP3 then
			for _, v10 in PROP2 do
				PROP3(v10, v4)
			end
		end

		task.wait()
		local PRNT2 = v7.PRNT
		local PRNT3 = modules.PRNT

		if PRNT2 and PRNT3 then
			for _, v10 in PRNT2 do
				PRNT3(v10, v4)
			end
		end

		return v4
	end
end

return Lxm