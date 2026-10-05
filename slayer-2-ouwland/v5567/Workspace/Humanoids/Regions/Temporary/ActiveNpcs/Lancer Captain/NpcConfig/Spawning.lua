local Spawning = {
	Appearance = {},
	DespawnDistance = 150,
	LastSpawned = 0,
	SpawnTime = 1,
	Entity = nil,
	HumanoidDefaults = {
		RunSpeed = 25
	},
	ChosenSpawnLocation = nil,
	Locations = { vector.create(3076.962, 51.4, 584.305) },
	Cache = {}
}

function Spawning.ClearCache()
	if Spawning.Cache ~= nil then
		for k, connection in pairs(Spawning.Cache) do
			local typeName = typeof(connection)

			if typeName == "RBXScriptConnection" then
				connection:Disconnect()
			end

			if typeName == "table" and connection.Destroy ~= nil or typeName == "Instance" then
				connection:Destroy()
			end

			Spawning.Cache[k] = nil
		end

		Spawning.Cache = {}
	end
end

return Spawning