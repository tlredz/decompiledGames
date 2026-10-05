local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
localPlayer:GetAttributeChangedSignal("ExemptFromAntiCheat"):Connect(function()
	local exemptFromAntiCheat = localPlayer:GetAttribute("ExemptFromAntiCheat") or false

	for _, part in CollectionService:GetTagged("GameBoundary") do
		if part:IsA("BasePart") then
			part.CanCollide = not exemptFromAntiCheat
		end
	end
end)