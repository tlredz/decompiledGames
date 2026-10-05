local _ = script.Parent.MoneyDestroyer5000.RemoteEvent
local localPlayer = game.Players.LocalPlayer

local function handlePrompt(proximityPrompt)
	proximityPrompt.Triggered:Connect(function()
		if localPlayer.PlayerGui:FindFirstChild("BillboardEditUI") then
			return
		end

		local clone = script.BillboardEditUI:Clone()
		clone.Promptobj.Value = proximityPrompt.Parent.Parent
		clone.Parent = localPlayer.PlayerGui
	end)
	proximityPrompt.PromptHidden:Connect(function()
		local billboardEditUI = localPlayer.PlayerGui:FindFirstChild("BillboardEditUI")

		if billboardEditUI then
			billboardEditUI:Destroy()
		end
	end)
end

for _, proximityPrompt in script.Parent:GetDescendants() do
	if proximityPrompt.Name == "Screen" then
		proximityPrompt.Parent.SurfaceGui.Adornee = proximityPrompt
	elseif proximityPrompt:IsA("ProximityPrompt") then
		handlePrompt(proximityPrompt)
	end
end

script.Parent.DescendantAdded:Connect(function(proximityPrompt)
	if proximityPrompt.Name == "Screen" then
		proximityPrompt.Parent.SurfaceGui.Adornee = proximityPrompt
		return
	end

	if not proximityPrompt:IsA("ProximityPrompt") then
		return
	end

	handlePrompt(proximityPrompt)
end)