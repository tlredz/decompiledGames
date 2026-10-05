game:GetService("ReplicatedStorage")
local module = require("./chrono/Shared/Config")
module.SetConfig("DEFAULT_NORMAL_TICK_DISTANCE", 100)
module.SetConfig("DEFAULT_HALF_TICK_DISTANCE", 300)
module.SetConfig("REPLICATE_DEATHS", "PLAYER_CHARACTERS")
module.SetConfig("PLAYER_REPLICATION", "AUTOMATIC")
module.RegisterEntityType("PLAYER", {
	NAME = "PLAYER",
	MODEL_REPLICATION_MODE = "NATIVE_WITH_LOCK",
	BUFFER = 0,
	TICK_RATE = 0.05,
	ASSEMBLY_ROOT_PART_CHECK = true
})
return nil