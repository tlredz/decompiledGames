local module = require("@game/ReplicatedStorage/Omni")
local Guilds = {
	Updated = module.Libs.GoodSignal.new()
}

function Guilds.Sync(p: string)
	Guilds.Updated:Fire(p)
end

return Guilds