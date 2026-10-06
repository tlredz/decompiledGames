local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dialogGlobalEvent = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("DialogGlobalEvent")
script.Parent.MouseButton1Click:Connect(function()
	_G.DialogAnswer = "Yes"
	script.Parent.Parent.Visible = false
	dialogGlobalEvent:FireServer("DialogAnswer", "Yes")
end)