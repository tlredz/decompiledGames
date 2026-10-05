local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local rhythmLTM = Players.LocalPlayer.PlayerGui.RhythmLTM
local remoteEvent = v:RemoteEvent("PlaceTeleport")
return {
	Start = function(_)
		rhythmLTM.Inner.Close.Activated:Connect(function()
			v2:Close(rhythmLTM.Name)
		end)
		rhythmLTM.Inner.Play.Activated:Connect(function()
			remoteEvent:FireServer("Rhythm")
		end)
	end
}