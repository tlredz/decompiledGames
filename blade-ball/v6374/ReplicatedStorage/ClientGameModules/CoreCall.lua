local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local v = require3(ReplicatedStorage2:WaitForChild("ServerInfo"))

local function CoreCall(p, flag: boolean)
	if p == Enum.CoreGuiType.PlayerList and flag and v.isTutorialServer() then
		return
	end

	task.spawn(function()
		for _ = 1, 10 do
			if pcall(StarterGui.SetCoreGuiEnabled, StarterGui, p, flag) then
				break
			else
				task.wait(1)
			end
		end
	end)
end

return CoreCall