local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Squash = require(ReplicatedStorage.Packages.Squash)
local KeycapStreamConfig = require(script.Parent.KeycapStreamConfig)
local KeycapRecordSchema = {
	NoneSentinel = "\0N"
}
local noneSentinel = KeycapRecordSchema.NoneSentinel

local function fixedPointAxis(p, p2: number)
	return {
		ser = function(p3, p4: number)
			p.ser(p3, (math.round(p4 * p2)))
		end,
		des = function(p3)
			return p.des(p3) / p2
		end
	}
end

local v = fixedPointAxis(Squash.i24(), KeycapStreamConfig.PositionScale)
local v2 = fixedPointAxis(Squash.u8(), KeycapStreamConfig.SizeScale)
KeycapRecordSchema.IdSerDes = Squash.u24()
KeycapRecordSchema.Schema = Squash.record({
	Id = KeycapRecordSchema.IdSerDes,
	Char = Squash.string(1),
	Color = Squash.Color3(),
	Position = Squash.Vector3(v),
	Size = Squash.Vector3(v2),
	Rotation = Squash.rotation(),
	KeyType = Squash.literal(noneSentinel, "Event"),
	MusicType = Squash.literal(noneSentinel, "MusicalKey", "MusicalKey2", "FlatKey")
})
return KeycapRecordSchema