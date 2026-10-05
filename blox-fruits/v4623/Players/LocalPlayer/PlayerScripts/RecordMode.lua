-- equivalent calls inferred from this helper; original call sites unknown
local function process(text: string)
	if text == "/youtube" then
		game.Players.LocalPlayer.PlayerGui.Main.Enabled = not game.Players.LocalPlayer.PlayerGui.Main.Enabled
	end
end

local TextChatService = game:GetService("TextChatService")
TextChatService.SendingMessage:Connect(function(p)
	process(p.Text) -- equivalent call inferred; original call site unknown
end)