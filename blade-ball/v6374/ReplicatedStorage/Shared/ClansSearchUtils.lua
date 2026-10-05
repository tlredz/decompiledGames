local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.ClansData)
local v2 = {
	Public = 0,
	Private = 1,
	[0] = "Public",
	[1] = "Private"
}

function firstToUpper(value)
	return string.gsub(value, "^%l", string.upper)
end

local function writeStringToBuffer(buf: buffer, str: string, offset: number, p: number?)
	local v3

	if p == 16 then
		buffer.writeu16(buf, offset, #str)
		v3 = offset + 2
	else
		buffer.writeu8(buf, offset, #str)
		v3 = offset + 1
	end

	buffer.writestring(buf, v3, str)
	return v3 + #str
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeU32ToBuffer(buf: buffer, value: number, offset: number)
	buffer.writeu32(buf, offset, value)
	return offset + 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeU8ToBuffer(buf: buffer, value: number, offset: number)
	buffer.writeu8(buf, offset, value)
	return offset + 1
end

local function writeClanInfoToBuffer(buf: buffer, item)
	local clanEmblem = item.clanEmblem
	local description = item.description
	local id = item.id
	local members = item.members
	local owner = item.owner
	local v3 = firstToUpper(item.privacySettings)
	local tag = item.tag
	local title = item.title
	local clanLevel = item.clanLevel
	local requirements = item.requirements or {}
	local v4 = #clanEmblem + #description + #id + #owner + #tag + #title + 18
	local v5 = buffer.len(buf)
	local buf2 = buffer.create(v5 + v4)
	buffer.copy(buf2, 0, buf, 0)
	local v6 = writeU8ToBuffer(buf2, #members, v5) -- equivalent call inferred; original call site unknown
	local v7 = writeU8ToBuffer(buf2, v2[v3] or 1, v6) -- equivalent call inferred; original call site unknown
	local v8 = writeU8ToBuffer(buf2, clanLevel, v7) -- equivalent call inferred; original call site unknown
	local v9 = writeU32ToBuffer(buf2, requirements.wins or 0, v8) -- equivalent call inferred; original call site unknown
	local v10 = writeU32ToBuffer(buf2, requirements.kills or 0, v9) -- equivalent call inferred; original call site unknown
	local v11 = writeU8ToBuffer(buf2, #clanEmblem, v10) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf2, v11, clanEmblem)
	local v12 = v11 + #clanEmblem
	buffer.writeu16(buf2, v12, #description)
	local v13 = v12 + 2
	buffer.writestring(buf2, v13, description)
	local v14 = v13 + #description
	local v15 = writeU8ToBuffer(buf2, #id, v14) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf2, v15, id)
	local v16 = v15 + #id
	local v17 = writeU8ToBuffer(buf2, #owner, v16) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf2, v17, owner)
	local v18 = v17 + #owner
	local v19 = writeU8ToBuffer(buf2, #tag, v18) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf2, v19, tag)
	local v20 = v19 + #tag
	local v21 = writeU8ToBuffer(buf2, #title, v20) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf2, v21, title)
	v21 += #title
	return buf2
end

return table.freeze({
	decodeSearchResult = function(buf: buffer)
		local pages = buffer.readu16(buf, 0)
		local total = 2
		local v4 = buffer.len(buf)
		local clans = table.create(pages * v.ClansPerPage)

		local function readString(p: number?)
			local v6

			if p == 16 then
				v6 = buffer.readu16(buf, total)
				total += 2
			else
				v6 = buffer.readu8(buf, total)
				total += 1
			end

			local v7 = buffer.readstring(buf, total, v6)
			total += v6
			return v7
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function readU8()
			local v6 = buffer.readu8(buf, total)
			total += 1
			return v6
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function readU32()
			local v6 = buffer.readu32(buf, total)
			total += 4
			return v6
		end

		while total < v4 do
			local members = readU8() -- equivalent call inferred; original call site unknown
			local u8 = readU8() -- equivalent call inferred; original call site unknown
			local clanLevel = readU8() -- equivalent call inferred; original call site unknown
			local wins = readU32() -- equivalent call inferred; original call site unknown
			local kills = readU32() -- equivalent call inferred; original call site unknown
			local u82 = readU8() -- equivalent call inferred; original call site unknown
			local clanEmblem = buffer.readstring(buf, total, u82)
			total += u82
			local v13 = buffer.readu16(buf, total)
			total += 2
			local description = buffer.readstring(buf, total, v13)
			total += v13
			local u83 = readU8() -- equivalent call inferred; original call site unknown
			local id = buffer.readstring(buf, total, u83)
			total += u83
			local u84 = readU8() -- equivalent call inferred; original call site unknown
			local owner = buffer.readstring(buf, total, u84)
			total += u84
			local u85 = readU8() -- equivalent call inferred; original call site unknown
			local tag = buffer.readstring(buf, total, u85)
			total += u85
			local u86 = readU8() -- equivalent call inferred; original call site unknown
			local title = buffer.readstring(buf, total, u86)
			total += u86
			table.insert(clans, {
				clanEmblem = clanEmblem,
				clanLevel = clanLevel,
				description = description,
				id = id,
				members = members,
				owner = owner,
				privacySettings = v2[u8],
				tag = tag,
				title = title,
				requirements = {
					wins = wins,
					kills = kills
				}
			})
		end

		return {
			pages = pages,
			clans = clans
		}
	end,
	encodeSearchResult = function(value: number, items)
		local buf = buffer.create(2)
		buffer.writeu16(buf, 0, value)

		for _, item in items do
			buf = writeClanInfoToBuffer(buf, item)
		end

		return buf
	end
})