local module = require("./luau-buff")
local resizeIfNeeded = module.resizeIfNeeded
local _ = module.readi8
local _ = module.writei8
local readi16 = module.readi16
local writei16 = module.writei16
local readi32 = module.readi32
local writei32 = module.writei32
local readu8 = module.readu8
local writeu8 = module.writeu8
local readu16 = module.readu16
local writeu16 = module.writeu16
local readu32 = module.readu32
local writeu32 = module.writeu32
local readf32 = module.readf32
local writef32 = module.writef32
local readf64 = module.readf64
local writef64 = module.writef64
local readstring = module.readstring
local writestring = module.writestring
local fns = {
	none = {}
}

function fns.none.write(_, _: nil) end

function fns.none.read(_)
	return nil
end

fns["nil"] = fns.none
fns.string = {}

function fns.string.read(p)
	return readstring(p, (readu32(p)))
end

function fns.string.write(p, list: string)
	writeu32(p, #list)
	writestring(p, list)
end

fns.boolean = {}

function fns.boolean.read(p)
	return readu8(p) == 1
end

function fns.boolean.write(p, flag: boolean)
	writeu8(p, flag and 1 or 0)
end

fns.buffer = {}

function fns.buffer:read()
	local v2 = readu32(self)
	local buf = buffer.create(v2)
	buffer.copy(buf, 0, self.buffer, self.cursor, v2)
	self.cursor += v2
	return buf
end

function fns.buffer:write(buf: buffer)
	local v2 = buffer.len(buf)
	writeu32(self, v2)
	resizeIfNeeded(self, v2)
	buffer.copy(self.buffer, self.cursor, buf, 0, v2)
	self.cursor += v2
end

fns.BrickColor = {}

function fns.BrickColor.read(p)
	return BrickColor.new(readu16(p))
end

function fns.BrickColor.write(p, p2)
	writeu16(p, p2.Number)
end

fns.CFrame = {}

function fns.CFrame.read(p)
	return CFrame.new(module.readf32(p), module.readf32(p), module.readf32(p)) * CFrame.Angles(
		module.readf32(p),
		module.readf32(p),
		module.readf32(p)
	)
end

function fns.CFrame.write(p, cframe: CFrame)
	module.resizeIfNeeded(p, 24)
	module.writef32(p, cframe.X)
	module.writef32(p, cframe.Y)
	module.writef32(p, cframe.Z)
	local eulerAnglesXYZ, v2, v3 = cframe:ToEulerAnglesXYZ()
	module.writef32(p, eulerAnglesXYZ)
	module.writef32(p, v2)
	module.writef32(p, v3)
end

fns.Color3 = {}

function fns.Color3.read(p)
	return Color3.new(readf32(p), readf32(p), readf32(p))
end

function fns.Color3.write(p, color: Color3)
	writef32(p, color.R)
	writef32(p, color.G)
	writef32(p, color.B)
end

fns.ColorSequenceKeypoint = {}

function fns.ColorSequenceKeypoint.read(p)
	return ColorSequenceKeypoint.new(readf32(p), fns.Color3.read(p))
end

function fns.ColorSequenceKeypoint.write(p, p2)
	writef32(p, p2.Time)
	fns.Color3.write(p, p2.Value)
end

fns.ColorSequence = {}

function fns.ColorSequence.read(p)
	local v2 = readu32(p)
	local v3 = table.create(v2)

	for i = 1, v2 do
		v3[i] = fns.ColorSequenceKeypoint.read(p)
	end

	return ColorSequence.new(v3)
end

function fns.ColorSequence.write(p, sequence)
	local keypoints = sequence.Keypoints
	writeu32(p, #keypoints)

	for _, keypoint in keypoints do
		fns.ColorSequenceKeypoint.write(p, keypoint)
	end
end

fns.Content = {}

function fns.Content.read(p)
	local v2 = readu8(p)
	local v3 = Enum.ContentSourceType:FromValue(v2)
	assert(v3, (`Invalid ContentSourceType of value {v2}`))

	if v3 == Enum.ContentSourceType.None then
		return Content.none
	end

	if v3 == Enum.ContentSourceType.Uri then
		return Content.fromUri(fns.string.read(p))
	end

	error((`Unsupported ContentSourceType "{v3.Name}"`))
end

function fns.Content.write(p, p2)
	local sourceType = p2.SourceType

	if sourceType == Enum.ContentSourceType.None then
		writeu8(p, sourceType.Value)
		return
	end

	if sourceType ~= Enum.ContentSourceType.Uri then
		error((`Unsupported ContentSourceType "{sourceType.Name}"`))
		return
	end

	writeu8(p, sourceType.Value)
	fns.string.write(p, assert(p2.Uri))
end

fns.DateTime = {}

function fns.DateTime.read(p)
	return DateTime.fromUnixTimestampMillis(readf64(p))
end

function fns.DateTime.write(p, p2)
	writef64(p, p2.UnixTimestampMillis)
end

fns.Enum = {}

function fns.Enum.read(p)
	return Enum[fns.string.read(p)]
end

function fns.Enum.write(p, p2)
	fns.string.write(p, (tostring(p2)))
end

fns.EnumItem = {}

function fns.EnumItem.read(p)
	local v2 = fns.Enum.read(p)
	local v3 = readu32(p)
	return (assert(v2:FromValue(v3), (`No EnumItem with Value {v3} found as a member of {tostring(v2)}`)))
end

function fns.EnumItem.write(p, p2)
	fns.Enum.write(p, p2.EnumType)
	writeu32(p, p2.Value)
end

fns.Font = {}

function fns.Font.read(p)
	local v2 = fns.string.read(p)

	if v2:match("^%w+://") then
		return Font.new(v2, Enum.FontWeight:FromValue(readu32(p)), Enum.FontStyle:FromValue(readu32(p)))
	end

	return Font.fromName(v2, Enum.FontWeight:FromValue(readu32(p)), Enum.FontStyle:FromValue(readu32(p)))
end

function fns.Font.write(p, data)
	fns.string.write(p, data.Family)
	writeu32(p, data.Weight.Value)
	writeu32(p, data.Style.Value)
end

fns.NumberRange = {}

function fns.NumberRange.read(p)
	return NumberRange.new(readf32(p), readf32(p))
end

function fns.NumberRange.write(p, range: NumberRange)
	writef32(p, range.Min)
	writef32(p, range.Max)
end

fns.NumberSequenceKeypoint = {}

function fns.NumberSequenceKeypoint.read(p)
	return NumberSequenceKeypoint.new(readf32(p), readf32(p), readf32(p))
end

function fns.NumberSequenceKeypoint.write(p, data)
	writef32(p, data.Time)
	writef32(p, data.Value)
	writef32(p, data.Envelope)
end

fns.NumberSequence = {}

function fns.NumberSequence.read(p)
	local v2 = readu32(p)
	local v3 = table.create(v2)

	for i = 1, v2 do
		v3[i] = fns.NumberSequenceKeypoint.read(p)
	end

	return NumberSequence.new(v3)
end

function fns.NumberSequence.write(p, sequence)
	local keypoints = sequence.Keypoints
	writeu32(p, #keypoints)

	for _, keypoint in keypoints do
		fns.NumberSequenceKeypoint.write(p, keypoint)
	end
end

fns.PhysicalProperties = {}

function fns.PhysicalProperties.read(p)
	return PhysicalProperties.new(readf32(p), readf32(p), readf32(p), readf32(p), readf32(p))
end

function fns.PhysicalProperties.write(p, data)
	writef32(p, data.Density)
	writef32(p, data.Friction)
	writef32(p, data.Elasticity)
	writef32(p, data.FrictionWeight)
	writef32(p, data.ElasticityWeight)
end

fns.Ray = {}

function fns.Ray.read(p)
	return Ray.new(Vector3.new(readf32(p), readf32(p), readf32(p)), (Vector3.new(readf32(p), readf32(p), readf32(p))))
end

function fns.Ray.write(p, ray: Ray)
	local origin = ray.Origin
	local direction = ray.Direction
	writef32(p, origin.X)
	writef32(p, origin.Y)
	writef32(p, origin.Z)
	writef32(p, direction.X)
	writef32(p, direction.Y)
	writef32(p, direction.Z)
end

fns.Rect = {}

function fns.Rect.read(p)
	return Rect.new(fns.Vector2.read(p), fns.Vector2.read(p))
end

function fns.Rect.write(p, rect: Rect)
	fns.Vector2.write(p, rect.Min)
	fns.Vector2.write(p, rect.Max)
end

fns.Region3 = {}

function fns.Region3.read(p)
	return Region3.new(fns.Vector3.read(p), fns.Vector3.read(p))
end

function fns.Region3.write(p, instance)
	local position = instance.CFrame.Position
	local v2 = position - instance.Size / 2
	local v3 = position + instance.Size / 2
	fns.Vector3.write(p, v2)
	fns.Vector3.write(p, v3)
end

fns.TweenInfo = {}

function fns.TweenInfo.read(p)
	return TweenInfo.new(
		readf32(p),
		Enum.EasingStyle:FromValue(readu32(p)),
		Enum.EasingDirection:FromValue(readu32(p)),
		readi32(p),
		readu8(p) == 1,
		readf32(p)
	)
end

function fns.TweenInfo.write(p, data)
	writef32(p, data.Time)
	writeu32(p, data.EasingStyle.Value)
	writeu32(p, data.EasingDirection.Value)
	writei32(p, data.RepeatCount)
	writeu8(p, data.Reverses and 1 or 0)
	writef32(p, data.DelayTime)
end

fns.UDim = {}

function fns.UDim.read(p)
	return UDim.new(readf32(p), readi32(p))
end

function fns.UDim.write(p, udim: UDim)
	writef32(p, udim.Scale)
	writei32(p, udim.Offset)
end

fns.UDim2 = {}

function fns.UDim2.read(p)
	return UDim2.new(fns.UDim.read(p), fns.UDim.read(p))
end

function fns.UDim2.write(p, udim: UDim2)
	fns.UDim.write(p, udim.X)
	fns.UDim.write(p, udim.Y)
end

fns.Vector2int16 = {}

function fns.Vector2int16.read(p)
	return Vector2int16.new(readi16(p), readi16(p))
end

function fns.Vector2int16.write(p, p2)
	writei16(p, p2.X)
	writei16(p, p2.Y)
end

fns.Vector2 = {}

function fns.Vector2.read(p)
	return Vector2.new(readf32(p), readf32(p))
end

function fns.Vector2.write(p, point: Vector2)
	writef32(p, point.X)
	writef32(p, point.Y)
end

fns.Vector3int16 = {}

function fns.Vector3int16.read(p)
	return Vector3int16.new(readi16(p), readi16(p), readi16(p))
end

function fns.Vector3int16.write(p, data)
	writei16(p, data.X)
	writei16(p, data.Y)
	writei16(p, data.Z)
end

fns.Vector3 = {}

function fns.Vector3.read(p)
	return (Vector3.new(readf32(p), readf32(p), readf32(p)))
end

function fns.Vector3.write(p, vector: Vector3)
	writef32(p, vector.X)
	writef32(p, vector.Y)
	writef32(p, vector.Z)
end

for k, fn in module.fns do
	fns[k] = fns[k] or fn
end

local v2 = {
	fns = fns
}

for k, v3 in module do
	v2[k] = v2[k] or v3
end

return (table.freeze(v2))