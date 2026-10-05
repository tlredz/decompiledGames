local localPlayer = game.Players.LocalPlayer
local Server = require(game.ReplicatedStorage.Modules.Server)
local Network = require(game.ReplicatedStorage.Modules.Network)
require(game.ReplicatedStorage.Modules.UI)
local tabs = script.Parent:WaitForChild("Tabs")

if not Server:IsOpenWorld() then
	local protection_2 = tabs:WaitForChild("Protection")
	protection_2.Visible = false
	return
end

local party = tabs:WaitForChild("Party")
party.Visible = false
local protection = tabs:WaitForChild("Protection")
local cross = script:WaitForChild("Cross")
local counter = script:WaitForChild("Counter")

local function update()
	cross.Visible = not localPlayer:GetAttribute("Protected")
end

protection.Button.MouseButton1Click:connect(function()
	Network:fire("ToggleProtected")
end)
task.delay(3, function()
	protection.BackgroundColor3 = Color3.fromRGB(96, 205, 255)
end)
cross.Parent = protection
counter.Parent = protection
localPlayer:GetAttributeChangedSignal("Protected"):connect(update)
localPlayer:GetAttributeChangedSignal("ProtectedCounter"):connect(function()
	counter.Text = localPlayer:GetAttribute("ProtectedCounter") or ""
end)