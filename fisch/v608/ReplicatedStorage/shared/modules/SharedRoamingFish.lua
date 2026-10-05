game:GetService("ServerScriptService")
game:GetService("ReplicatedStorage")
game:GetService("RunService")
local SharedRoamingFish = {}
SharedRoamingFish.CHUNK_SIZE = 100
SharedRoamingFish.CHUNK_SIZE_VERTICAL = 100
SharedRoamingFish.CHUNK_VERTICAL_OFFSET = -50
SharedRoamingFish.CHUNK_SIZE_VECTOR = vector.create(100, 100, 100)

function SharedRoamingFish.GetCurrentPosition(data, p: number?)
	if data.p then
		return CFrame.lookAlong(data.s, data.o)
	end

	local v = math.clamp(((p or workspace:GetServerTimeNow()) - data.b) / data.t, 0, 1)
	return CFrame.lookAlong(data.s + data.o * v, data.o)
end

function SharedRoamingFish.GetChunk(data)
	return (Vector3.new(data.X // 100, (data.Y + -50) // 100, data.Z // 100))
end

return SharedRoamingFish