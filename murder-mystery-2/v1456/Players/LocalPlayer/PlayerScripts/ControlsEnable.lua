local localPlayer = game.Players.LocalPlayer
local PlayerModule = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"))

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterAdded(_)
	PlayerModule:GetControls():Enable()
end

repeat
	task.wait()
until localPlayer.Character

local _ = localPlayer.Character
onCharacterAdded() -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(onCharacterAdded)