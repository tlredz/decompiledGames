local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local avatarEditorMessage = module.AvatarEditorMessage
local flying = module.Flying
local clientInfo = module.ClientInfo
wait(10)
flying:FireServer("CheckForServerOwner")
wait(1)
avatarEditorMessage:FireServer("EnteredGameLoadSlotNames")
wait(10)
clientInfo:FireServer("SetUpSettingSave")
wait(29)
flying:FireServer("CheckForServerOwner")
wait(1)
flying:FireServer("PCollisionPatch")