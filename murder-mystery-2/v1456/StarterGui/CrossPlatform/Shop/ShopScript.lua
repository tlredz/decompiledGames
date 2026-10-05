local _ = script.Parent
local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("DeviceService"))
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ProfileData"))
local shopPhone = script:WaitForChild("ShopPhone")
local shopDesktop = script:WaitForChild("ShopDesktop")
local shopConsole = script:WaitForChild("ShopConsole")

local function onInitialize()
	while localPlayer.PlayerGui:GetAttribute("Device") == nil do
		task.wait()
	end

	while not localPlayer.PlayerGui:FindFirstChild("MainGUI") do
		task.wait()
	end

	local flag

	if localPlayer.PlayerGui:GetAttribute("Device") == "Phone" then
		flag = true
	else
		flag = false
	end

	local isTenFootInterface = GuiService:IsTenFootInterface()

	if flag then
		shopPhone.Enabled = true
	elseif isTenFootInterface then
		shopConsole.Enabled = true
	else
		shopDesktop.Enabled = true
	end
end

onInitialize()