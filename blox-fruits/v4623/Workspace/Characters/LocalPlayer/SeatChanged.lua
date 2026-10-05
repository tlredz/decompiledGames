local SeatUtil = require(game.ReplicatedStorage.Util.SeatUtil)
local humanoid = script.Parent:WaitForChild("Humanoid")
assert(humanoid:IsA("Humanoid"))
script.Destroying:Once(SeatUtil.bindHumanoid(humanoid))