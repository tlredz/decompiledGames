game:GetService("Debris")
local v = {
	Pitch = 1,
	Speed = 1,
	Accent = 1,
	Voice = "TTZ"
}
return {
	Btn = 1,
	SortOrder = 9,
	Val = "TTS",
	Desc = "text to shenanigans",
	Callback = function(p)
		if p == true then
			local TextChatService = game:GetService("TextChatService")

			function TextChatService.OnBubbleAdded(data, instance)
				if data.Status ~= Enum.TextChatMessageStatus.Success or instance == nil and data.TextSource == nil then
					return
				end

				local child = data.TextSource and game.Players:FindFirstChild(data.TextSource.Name)

				if child then
					local _ = child.Character:GetAttribute("Pitch") or 1
					local TextToZee = require(script.TextToZee)
					task.spawn(TextToZee.TTS, data.Text, child.Character.PrimaryPart, v)
				elseif instance and instance:IsA("Instance") then
					local TextToZee = require(script.TextToZee)
					task.spawn(TextToZee.TTS, data.Text, instance, v)
				end
			end
		else
			local TextChatService = game:GetService("TextChatService")
			TextChatService.OnBubbleAdded = nil
		end
	end
}