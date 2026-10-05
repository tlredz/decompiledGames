local localPlayer = game.Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ValleyPanels = require(chickenOrHero.Presentation:WaitForChild("ValleyPanels"))
local movementGuardEvent = chickenOrHero.Presentation:WaitForChild("MovementGuardEvent")
local screen = ValleyPanels.screen(localPlayer, "ValleyFairPlay", 85)
local panel, v, v2 = ValleyPanels.panel(screen, "Warning", 620, 360)
ValleyPanels.text(v, "Eyebrow", "HUSS VALLEY  /  FAIR PLAY", 28, 24, 505, 24, 12, ValleyPanels.Gold)
local text = ValleyPanels.text(v, "Title", "FAIR PLAY WARNING", 28, 65, 555, 52, 27, ValleyPanels.Gold)
text.Font = Enum.Font.GothamBold
local text2 = ValleyPanels.text(v, "Message", "", 28, 127, 560, 145, 17)
text2.TextYAlignment = Enum.TextYAlignment.Top
local button = ValleyPanels.button(v, "Acknowledge", "I UNDERSTAND", 28, 297, 564, 40, Color3.fromRGB(87, 57, 43))
button.Modal = true
v2.Visible = false
button.Activated:Connect(function()
	panel.Visible = false
	localPlayer:SetAttribute("FairPlayNoticeOpen", nil)
end)
local v3 = ValleyPanels.make("Frame", screen, "StaffAlert", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 100),
	Size = UDim2.fromOffset(350, 156),
	BackgroundColor3 = ValleyPanels.Ink,
	BorderSizePixel = 0,
	Visible = false
})
ValleyPanels.corner(v3, 12)
ValleyPanels.stroke(v3, ValleyPanels.Gold, 0.3)
ValleyPanels.text(v3, "Label", "MODERATION · REVIEW REQUEST", 14, 10, 290, 20, 11, ValleyPanels.Gold)
local text3 = ValleyPanels.text(v3, "Message", "", 14, 37, 320, 65, 13)
text3.TextYAlignment = Enum.TextYAlignment.Top
local button2 = ValleyPanels.button(v3, "Dismiss", "DISMISS", 14, 115, 100, 28)
local button3 = ValleyPanels.button(v3, "Watch", "SPECTATE", 124, 115, 211, 28, Color3.fromRGB(43, 80, 93))
local userId = nil
local now = nil
button2.Activated:Connect(function()
	v3.Visible = false
end)
button3.Activated:Connect(function()
	if localPlayer:GetAttribute("InMatch") == true then
		text3.Text = "Return to the lobby to spectate. Use ;anticheat <player> for evidence."
		return
	end

	chickenOrHero.Presentation.SpectateEvent:FireServer("Start", userId)
	v3.Visible = false
end)
movementGuardEvent.OnClientEvent:Connect(function(p, data)
	if type(data) ~= "table" then
		return
	end

	if p == "Warning" then
		text.Text = data.title
		text2.Text = data.message
		panel.Visible = true
		localPlayer:SetAttribute("FairPlayNoticeOpen", true)
	elseif p == "Staff" then
		userId = data.userId
		text3.Text = data.message
		v3.Visible = true
		now = os.clock()
		local v4 = now
		task.delay(18, function()
			if now == v4 then
				v3.Visible = false
			end
		end)
	end
end)
script.Destroying:Connect(function()
	localPlayer:SetAttribute("FairPlayNoticeOpen", nil)
	screen:Destroy()
end)