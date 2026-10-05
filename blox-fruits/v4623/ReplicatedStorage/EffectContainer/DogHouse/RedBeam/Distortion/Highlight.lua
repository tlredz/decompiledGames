if script:FindFirstChild("SpawnedHighlight") then
	return
end

if not script:IsDescendantOf(game.ReplicatedStorage) then
	local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
	local clone = WrapHighlight(script:GetAttribute("Original")):Clone()
	clone.Parent = script.Parent
	local objectValue = Instance.new("ObjectValue", script)
	objectValue.Name = "SpawnedHighlight"
	objectValue.Value = clone
	script.Name = "__HighlightProxyWarning__"
end