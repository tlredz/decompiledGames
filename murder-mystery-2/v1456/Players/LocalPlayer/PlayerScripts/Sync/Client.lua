local replicatedStorage = game.ReplicatedStorage
local v = game.PlaceId == 5895823254 or game.PlaceId == 5928494131

local function FixSyncData()
	_G.Database.Weapons = _G.Database.Item

	if not v then
		for k, toy in pairs(_G.Database.Toys) do
			_G.Database.Emotes[k] = toy
		end
	end
end

_G.LoadedImages = {}
_G.Database = replicatedStorage.GetSyncData:InvokeServer()
_G.Database.Weapons = _G.Database.Item
FixSyncData()