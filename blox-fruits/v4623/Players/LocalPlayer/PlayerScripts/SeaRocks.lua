local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") == false then
	return
end

require(game.ReplicatedStorage.RockGenerator)