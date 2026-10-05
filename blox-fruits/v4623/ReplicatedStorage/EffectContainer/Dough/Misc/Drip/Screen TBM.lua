local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
require(ReplicatedStorage.Effect.Container.Dough.Util.Drip.Screen)
return function(_) end