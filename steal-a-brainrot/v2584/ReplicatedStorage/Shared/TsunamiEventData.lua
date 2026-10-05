local waveSpawnPart = script.WaveSpawnPart
local rotation = waveSpawnPart:GetPivot().Rotation
local TsunamiEventData = {}
TsunamiEventData.waveSpawnPart = waveSpawnPart
TsunamiEventData.initialUpgradeCost = 1000
TsunamiEventData.initialSpeed = 20

function TsunamiEventData.getUpgradeCost(p: number, p2: number)
	return (math.max(math.floor(1.1625 ^ (p + p2) * 1000), 1))
end

function TsunamiEventData.getTotalSpeed(p: number)
	return 20 + p
end

function TsunamiEventData.getExtraSpeed(p: number)
	return p
end

TsunamiEventData.upgrades = { 1, 5, 10 }
TsunamiEventData.products = {
	[1] = 3520721003,
	[5] = 3520721005,
	[10] = 3520721004
}

function TsunamiEventData.getWavePositionAtTime(data, p: number)
	local v = data.despawnsAt - data.spawnedAt
	return CFrame.new(data.initialPosition + Vector3.new(0, 0, data.distance * (p - data.spawnedAt) / v)) * rotation
end

return TsunamiEventData