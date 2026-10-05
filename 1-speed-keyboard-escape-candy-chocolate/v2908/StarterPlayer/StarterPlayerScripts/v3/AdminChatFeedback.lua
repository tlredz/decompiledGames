local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
ReplicatedStorage:WaitForChild("AdminFeedback").OnClientEvent:Connect(function(p, p2)
	local rBXGeneral = TextChatService:FindFirstChild("RBXGeneral", true)

	if rBXGeneral then
		rBXGeneral:DisplaySystemMessage("<font color='" .. p2 .. "'><b>[SYSTEM]</b> " .. p .. "</font>")
	end
end)