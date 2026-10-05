local createVector = vector.create
local v = {
	X = 0,
	Y = 0,
	Z = 0,
	W = 1
}
local TrackerRole = require(script.Parent.Parent:WaitForChild("Data"):WaitForChild("TrackerRole"))
local StringDeserializer = require(script.Parent:WaitForChild("StringDeserializer"))
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function WarnOnce(formatted: string)
	if v2[formatted] then
		return
	end

	v2[formatted] = true
	warn(formatted)
end

return function(p: string)
	local v3 = StringDeserializer.new(p)
	local number = v3:ReadNumber()
	local number2 = v3:ReadNumber()

	if number ~= 1 and number ~= 2 then
		WarnOnce(`Enigma protocol version {number} is unsupported and might not work as expected. Supported versions: 1, 2`) -- equivalent call inferred; original call site unknown
	end

	local result = {}

	if number == 1 then
		for _ = 1, number2 do
			local trackerRole = TrackerRole[v3:ReadNumber() + 1] or "Unsupported"
			local vector3 = v3:ReadVector3()
			local quaternion = v3:ReadQuaternion()
			local vector32 = v3:ReadVector3()
			table.insert(result, {
				TrackerRole = trackerRole,
				FloorRelativeCFrame = CFrame.new(
					vector3.X,
					vector3.Y,
					vector3.Z,
					quaternion.X,
					quaternion.Y,
					quaternion.Z,
					quaternion.W
				),
				FloorRelativeVelocity = vector32
			})
		end
	else
		for _ = 1, number2 do
			local v4 = v
			local trackerRole = "Unsupported"
			local v6 = createVector(0, 0, 0)
			local floorRelativeVelocity = createVector(0, 0, 0)

			for _ = 1, v3:ReadNumber() do
				local number3 = v3:ReadNumber()
				local number4 = v3:ReadNumber()

				if number3 == 0 then
					trackerRole = TrackerRole[v3:ReadNumber() + 1] or "Unsupported"
				elseif number3 == 1 then
					v6 = v3:ReadVector3()
				elseif number3 == 2 then
					v4 = v3:ReadQuaternion()
				elseif number3 == 3 then
					floorRelativeVelocity = v3:ReadVector3()
				else
					local v8 = {}

					for _ = 1, number4 do
						table.insert(v8, v3:ReadString())
					end

					WarnOnce(`Unsupported property id {number3} sent with {number4} values: {table.concat(v8, "|")}`) -- equivalent call inferred; original call site unknown
				end
			end

			table.insert(result, {
				TrackerRole = trackerRole,
				FloorRelativeCFrame = CFrame.new(v6.X, v6.Y, v6.Z, v4.X, v4.Y, v4.Z, v4.W),
				FloorRelativeVelocity = floorRelativeVelocity
			})
		end
	end

	return result
end