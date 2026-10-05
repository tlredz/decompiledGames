local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(game.ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Assets.Data.Store.Skins)
local v = Network:invoke("FetchEmotes")

for k, v2 in next, v, nil do
	v2.Name = k
end

return v