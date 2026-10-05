local PerkService = require(game.ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("PerkService"))
game:GetService("UserInputService")
PerkService.PerkButton = script.Parent.Parent:WaitForChild("Perk")
local gamepadBinding = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext"):WaitForChild("GameplayContext"):WaitForChild("Perk"):WaitForChild("GamepadBinding")
gamepadBinding.KeyCode = Enum.KeyCode.ButtonR1