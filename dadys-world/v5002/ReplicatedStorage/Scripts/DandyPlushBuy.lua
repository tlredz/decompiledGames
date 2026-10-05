local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace.InGamePlayers:FindFirstChild(localPlayer.Name)
local v = false

if child then
	local trinkets = child:WaitForChild("Trinkets")
	local trinket1 = trinkets:WaitForChild("Trinket1")
	local trinket2 = trinkets:WaitForChild("Trinket2")

	if trinket1.Value == "DandyPlush" then
		v = (false or 1) * 0.5
	end

	if trinket2.Value == "DandyPlush" then
		v = (v or 1) * 0.5
	end

	if v then
		script.Parent.ObjectText = math.round(script.Value.Value * v) .. " Tapes"
	end
end