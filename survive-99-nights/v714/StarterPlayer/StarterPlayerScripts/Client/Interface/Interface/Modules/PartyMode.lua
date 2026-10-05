local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local TextChatService = game:GetService("TextChatService")
local partyMessage = Client.Interface.PartyMessage
local count = 0
local v = {
	ForyxeV = "rbxassetid://122232503121548",
	Cracky4 = "rbxassetid://137944888373492",
	Viridial = "rbxassetid://112591559595292"
}
local v2 = {
	ForyxeV = Color3.fromRGB(250, 208, 0),
	Cracky4 = Color3.fromRGB(255, 237, 190),
	Viridial = Color3.fromRGB(0, 170, 57)
}
Client.Events.BroadcastPartyMessage:Connect(function(text, p)
	count += 1
	local v3 = count
	partyMessage.NameLabel.Text = text
	partyMessage.NameLabel.TextColor3 = v2[text] or Color3.fromRGB(255, 204, 0)
	partyMessage.ImageLabel.Image = v[text] or "rbxassetid://110799641909962"
	partyMessage.TextLabel.Text = ": " .. p
	Client.Sound.Play("GlobalMessage", {
		Duplicate = true
	})
	task.spawn(function()
		TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"):DisplaySystemMessage("<font color='#FF00FF'>" .. text .. ": " .. p .. "</font>")
	end)
	partyMessage.Visible = true
	task.delay(8, function()
		if count == v3 then
			partyMessage.Visible = false
		end
	end)
end)
return {}