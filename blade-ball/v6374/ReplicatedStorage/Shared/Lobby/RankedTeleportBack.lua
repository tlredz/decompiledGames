local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.UniverseIds)
local v2 = require3(ReplicatedStorage2.ServerInfo)
return function(instance)
	local billboardGui = instance:WaitForChild("AttachmentBillboard"):WaitForChild("BillboardGui")
	local attachment = instance:WaitForChild("Attachment")
	local proximityPrompt = attachment:WaitForChild("ProximityPrompt")

	if v2.isRankedLobbyServer() then
		proximityPrompt.Enabled = true
		proximityPrompt.ObjectText = "RETURN TO GAME"
		proximityPrompt.Triggered:Connect(function(player)
			ReplicatedStorage2.Remotes.ProServerNoti:FireClient(player, "tping")
			pcall(function()
				TeleportService:TeleportAsync(v.Default.PlaceId, { player })
			end)
		end)
		local rankedLabel = billboardGui:FindFirstChild("RankedLabel")

		if rankedLabel then
			rankedLabel.Text = "GO BACK"
			rankedLabel.TextColor3 = Color3.fromRGB(0, 255, 75)
			rankedLabel.UIStroke.Color = Color3.fromRGB(0, 125, 0)
		end

		instance.Color = Color3.fromRGB(0, 255, 75)
		instance.SurfaceLight.Color = Color3.fromRGB(0, 255, 75)
		instance.CanTouch = false
	else
		proximityPrompt:Destroy()
		attachment:Destroy()
	end
end