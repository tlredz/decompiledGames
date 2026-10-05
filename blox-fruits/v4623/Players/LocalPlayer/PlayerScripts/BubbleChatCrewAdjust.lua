local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local childAddedConnection = nil

while true do
	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	childAddedConnection = playerGui:WaitForChild("BubbleChat", 9999999).ChildAdded:Connect(function(billboardGui)
		if billboardGui:IsA("BillboardGui") then
			if not billboardGui.Adornee then
				return
			end

			local infoBBG = billboardGui.Adornee.Parent and billboardGui.Adornee.Parent:FindFirstChild("HumanoidRootPart") and billboardGui.Adornee.Parent.HumanoidRootPart:FindFirstChild("InfoBBG")

			if not (infoBBG and infoBBG.Enabled and billboardGui.PlayerToHideFrom ~= game.Players.LocalPlayer) then
				return
			end

			local total = 0

			if infoBBG.Frame.Title.Visible then
				total += 1.5
			end

			local v

			if infoBBG.Frame.Logo.Visible then
				total = 0
				v = false
			else
				v = true
			end

			billboardGui.StudsOffsetWorldSpace = Vector3.new(0, total, 0)

			if not v then
				infoBBG.Enabled = false
				billboardGui.Destroying:Wait()
				infoBBG.Enabled = true
			end
		end
	end)

	while localPlayer.PlayerGui.ChildAdded:Wait().Name ~= "BubbleChat" do

	end
end