local UserInputService = game:GetService("UserInputService")

local function update()
	local _, _ = pcall(function()
		return game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not UserInputService.TouchEnabled)
	end)
end

task.wait(3)
local _, _ = pcall(function()
	return game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not UserInputService.TouchEnabled)
end)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):connect(update)