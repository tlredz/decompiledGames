local StarterGui = game:GetService("StarterGui")

while not pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end) do
	task.wait(1)
end