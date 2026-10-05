wait(0.2)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
workspace:WaitForChild(localPlayer.Name):WaitForChild("Humanoid")
local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local maxy = module.Maxy
local parent = script.Parent
local container = parent:WaitForChild("Container")
local close = parent:WaitForChild("Header"):WaitForChild("CategoryTabs"):WaitForChild("Close")
local scrollingFrame = container:WaitForChild("ScrollingFrame")
local v = false

for _, child in pairs(scrollingFrame:GetChildren()) do
	if not child:isA("ImageButton") then
		continue
	end

	local v2 = child
	child.MouseButton1Click:connect(function()
		local name = v2.Name

		if v == false then
			v = true
			maxy:FireServer("RequestDealerVehicle", name)
		end

		wait(0.2)
		v = false
	end)
end

close.MouseButton1Click:Connect(function()
	script.Parent.Parent.Visible = false
end)