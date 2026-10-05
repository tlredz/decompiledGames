while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local Utils = require(game.ReplicatedStorage.Common.Utils)
local StarterGui = game:GetService("StarterGui")

function Utils.Network.Events.SystemMessage(p)
	StarterGui:SetCore("ChatMakeSystemMessage", p)
end

return {}