local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local hide

hide = function(folder)
	if folder:IsA("BasePart") or folder:IsA("Decal") then
		folder.Transparency = 1
	end

	for _, descendant in folder:GetDescendants() do
		hide(descendant)
	end
end

if ServerInfo.isRankedMatchServer() or ServerInfo.isNoAbilityRankedMatchServer() then
	hide(script.Parent)
end