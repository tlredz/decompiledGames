local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Gamemodes = require(ReplicatedStorage.Assets.Data.Gamemodes)
local UI = require(ReplicatedStorage.Modules.UI)
local color = Color3.fromRGB(0, 255, 127)
local customServer = Players.LocalPlayer.PlayerGui:WaitForChild("CustomServer")
local parent = script.Parent
local info = parent.Info
local buttons = parent.Buttons
local slot = script.Slot
local list = parent.List
local v = nil

local function setGamemode(p: string)
	local gamemode = Gamemodes[p]

	if not gamemode then
		return
	end

	v = p
	local description = gamemode.Description or "This gamemode has no description!"
	info.Description.Text = `{description}\n\n<font transparency="0.5"><b>Note:</b> The Game Mode can be changed at anytime!</font>`
	info.Title.Text = gamemode.Display or p

	for _, frame in pairs(list:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if frame.Name == p then
			frame.BackgroundColor3 = color
		else
			frame.BackgroundColor3 = slot.BackgroundColor3
		end
	end
end

for k, gamemode in pairs(Gamemodes) do
	if gamemode.Unusable then
		continue
	end

	local clone = slot:Clone()
	clone.Name = k
	clone.Title.Text = gamemode.Display or k
	clone.Parent = list
	local v2 = k
	clone.Button.Activated:Connect(function()
		setGamemode(v2)
	end)
	UI:Bind(clone.Button)
	UI:AddShadowOnHover(clone)
end

buttons.Confirm.Button.Activated:Connect(function()
	if v then
		customServer.CustomServer:SetAttribute("CurrentGamemode", v)
	end

	parent.Visible = false
end)
buttons.Cancel.Button.Activated:Connect(function()
	setGamemode("Default")
	parent.Visible = false
end)

for _, frame in pairs(buttons:GetChildren()) do
	if not frame:IsA("Frame") then
		continue
	end

	UI:Bind(frame.Button)
	UI:AddShadowOnHover(frame)
end

customServer.CustomServer:GetAttributeChangedSignal("CurrentGamemode"):Connect(function()
	local currentGamemode = customServer.CustomServer:GetAttribute("CurrentGamemode")

	if v == currentGamemode then
		return
	end

	setGamemode(currentGamemode)
end)