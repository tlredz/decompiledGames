local GuiService = game:GetService("GuiService")
GuiService:SetInspectMenuEnabled(false)
GuiService:InspectPlayerFromHumanoidDescription(
	workspace:WaitForChild("MainStage"):WaitForChild("Nitro"):WaitForChild("Humanoid"):WaitForChild("HumanoidDescription"),
	""
)
GuiService:SetInspectMenuEnabled(true)
wait(0.2)
script:Destroy()