local TurnIntoFrog = {}
local localPlayer = game.Players.LocalPlayer
require(localPlayer.PlayerScripts.Client)
local cFrame = nil
local name = nil

function TurnIntoFrog.Init()
	localPlayer.CharacterRemoving:Connect(function(character)
		cFrame = workspace.CurrentCamera.CFrame
		name = character.Name
	end)
	localPlayer.CharacterAdded:Connect(function()
		if name and name == "Frog" then
			for _ = 1, 5 do
				task.wait()
				workspace.CurrentCamera.CFrame = cFrame
			end
		end
	end)
end

return TurnIntoFrog