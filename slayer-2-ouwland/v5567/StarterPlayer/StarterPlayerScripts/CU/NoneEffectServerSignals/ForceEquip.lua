local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
return function(p: number?)
	if p == nil then
		return
	end

	local items_Config = localPlayer:FindFirstChild("Items_Config")

	if items_Config == nil then
		return
	end

	local equipped = items_Config:FindFirstChild("Equipped")

	if equipped == nil then
		return
	end

	if equipped.Value ~= p then
		equipped.Value = p
	end
end