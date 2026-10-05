local function GetGifts()
	local owned = _G.PlayerData.Weapons.Owned

	for k, gifts in pairs(owned) do
		if k ~= "Gift" then
			continue
		end

		_G.Gifts = gifts
		break
	end
end

_G.Gifts = 0
_G.OfferEndTime = 1471244400
local v = _G.OfferEndTime - os.time()
_G.ShowItemPack = v > 0
_G.CanJump = true
local v2 = game.PlaceId == 5895823254 or game.PlaceId == 5928494131

repeat
	_G.PlayerData = game.ReplicatedStorage.Remotes.Extras.GetData2:InvokeServer()
	wait(0.1)
until _G.PlayerData ~= nil

local v3 = {}

local function UpdateData()
	local owned = _G.PlayerData.Weapons.Owned

	for k, gifts in pairs(owned) do
		if k ~= "Gift" then
			continue
		end

		_G.Gifts = gifts
		break
	end

	if not v2 then
		for _, v4 in pairs(_G.PlayerData.Toys.Owned) do
			if v3[v4] ~= nil then
				continue
			end

			table.insert(_G.PlayerData.Emotes.Owned, v4)
			v3[v4] = true
		end
	end
end

game.ReplicatedStorage.UpdateData2.OnClientEvent:connect(function(playerData, p)
	_G.PlayerData = playerData
	v3 = {}
	UpdateData()
	game.ReplicatedStorage.UpdateDataClient:Fire(p, playerData)
end)
game.ReplicatedStorage.UpdateDataClient.Event:connect(UpdateData)
game.ReplicatedStorage.UpdateData3.OnClientEvent:connect(function(playerData)
	_G.PlayerData = playerData
	v3 = {}
	UpdateData()
end)
UpdateData()

function _G.UpdateEmotes()
	UpdateData()
end