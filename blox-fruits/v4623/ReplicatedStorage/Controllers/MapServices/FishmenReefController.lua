local FishmenReefController = {}
local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getIfCurrentRealmHasTagAsync("IsFirstSea") == false then
	return FishmenReefController
end

require(game.ReplicatedStorage.Controllers.MapServices.SubmergedIslandController.MapComponents.BubbleReef)
return FishmenReefController