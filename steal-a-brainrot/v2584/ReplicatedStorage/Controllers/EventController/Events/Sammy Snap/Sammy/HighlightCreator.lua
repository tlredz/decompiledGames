local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerData = require(ReplicatedStorage.Datas.ServerData)

if script:IsDescendantOf(workspace) then
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"

	if ServerData.IsTsunamiServer() then
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	else
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	end

	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 12, 12)
	highlight.Parent = script.Parent
end