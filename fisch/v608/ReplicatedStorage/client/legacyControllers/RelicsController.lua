local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local relicsXYZ = ReplicatedStorage.RelicsXYZ
local RelicsPlayer = require(relicsXYZ.RelicsPlayer)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local openMusicPlayer = ReplicatedStorage:WaitForChild("events"):WaitForChild("OpenMusicPlayer")
local toggleRelicsPlayer = ReplicatedStorage:WaitForChild("events"):WaitForChild("ToggleRelicsPlayer")
local v = nil
local RelicsController = {}

function RelicsController.GetPlayer(_)
	return v
end

function RelicsController:Open()
	if v then
		v:SetWindowState("Full")
	end
end

function RelicsController:Close()
	if v then
		v:SetWindowState("Hidden")
	end
end

function RelicsController.HasBoombox(_)
	return v and v:UserHasBoombox() or false
end

function RelicsController:Start()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RelicsPlayer"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v = RelicsPlayer.new(screenGui)
	v:SetEnabled(true)
	v:SetWindowState("Hidden")
	openMusicPlayer.OnClientEvent:Connect(function(flag: boolean)
		if flag then
			self:Open()
		else
			self:Close()
		end
	end)
	toggleRelicsPlayer.OnClientEvent:Connect(function(flag: boolean)
		v:SetPlaying(flag)
	end)
end

return RelicsController