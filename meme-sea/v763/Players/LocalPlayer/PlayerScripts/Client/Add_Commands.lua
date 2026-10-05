local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local admin_Commands = secretEvents:WaitForChild("Admin_Commands")
local player_Commands = miscEvents:WaitForChild("Player_Commands")
local v = { "/hideui", "/showui", "/defaultsky" }

while localPlayer:GetAttribute("LoadedData") == nil and localPlayer:GetAttribute("LoadedData") ~= true do
	task.wait(0.1)
end

local function Add_Commands()
	for _, textChatCommand in ipairs(TextChatService:GetChildren()) do
		if textChatCommand:IsA("TextChatCommand") and textChatCommand:GetAttribute("Admin_Command") then
			textChatCommand:Destroy()
		end
	end

	for _, primaryAlias in ipairs(v) do
		local name = tostring(primaryAlias):gsub("/", "")

		if TextChatService:FindFirstChild(name) then
			continue
		end

		local textChatCommand = Instance.new("TextChatCommand")
		textChatCommand.Name = name
		textChatCommand.PrimaryAlias = primaryAlias
		textChatCommand:SetAttribute("Admin_Command", true)
		textChatCommand.Parent = TextChatService
		textChatCommand.Triggered:Connect(function(_, value)
			player_Commands:Fire("Run_Command", string.split(value, " ")[1])
		end)
	end

	local v2 = admin_Commands:InvokeServer("Get_Commands")

	if v2 then
		for _, primaryAlias in ipairs(v2) do
			local name = tostring(primaryAlias):gsub("/", "")

			if TextChatService:FindFirstChild(name) then
				continue
			end

			local textChatCommand = Instance.new("TextChatCommand")
			textChatCommand.Name = name
			textChatCommand.PrimaryAlias = primaryAlias
			textChatCommand:SetAttribute("Admin_Command", true)
			textChatCommand.Parent = TextChatService
			textChatCommand.Triggered:Connect(function(_, value)
				admin_Commands:InvokeServer("Run_Command", value)
				local v5 = string.split(value, " ")[1]

				if v5 == "/recd" then
					player_Commands:Fire("Run_Command", "/recd")
				end
			end)
		end
	end
end

Add_Commands()