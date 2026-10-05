local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local clientGameModules = ReplicatedStorage2.ClientGameModules
local _ = ReplicatedStorage2.Common
local _ = ReplicatedStorage2.Packages
local v2 = require3(clientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local buttonB = Enum.KeyCode.ButtonB
return {
	Start = function(_)
		v.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed then
				return
			end

			if input.KeyCode == buttonB and v2._currentGui and not v3.UI then
				v2:CloseCurrent(true)
				ReplicatedStorage2.Misc.click:Play()
			end
		end)
	end
}