local module = require("@game/ReplicatedStorage/Omni")
local Parties = {
	SyncEvent = module.Libs.GoodSignal.new(),
	DisbandedEvent = module.Libs.GoodSignal.new(),
	KickedEvent = module.Libs.GoodSignal.new(),
	LeftEvent = module.Libs.GoodSignal.new(),
	BrowseChangedEvent = module.Libs.GoodSignal.new()
}

function Parties.Left(p: string)
	Parties.LeftEvent:Fire(p)
end

function Parties.BrowseChanged(p: string)
	Parties.BrowseChangedEvent:Fire(p)
end

function Parties.Sync(p)
	Parties.SyncEvent:Fire(p)
end

function Parties.Disbanded(p: string)
	Parties.DisbandedEvent:Fire(p)
end

function Parties.Kicked(p: string)
	Parties.KickedEvent:Fire(p)
end

return Parties