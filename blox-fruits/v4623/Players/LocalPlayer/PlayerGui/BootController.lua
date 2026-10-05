local Controller = require(script.Parent:WaitForChild("Main"):WaitForChild("DragonSelection"):WaitForChild("Controller"))
local _ = game.Players.LocalPlayer

local function openController(_)
	Controller:Open()
end

game.CollectionService:GetInstanceAddedSignal("IsClassicChoiceOpen"):Connect(openController)
game.CollectionService:GetInstanceAddedSignal("IsPermChoiceOpen"):Connect(openController)
task.spawn(openController)