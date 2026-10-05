if script:FindFirstChild("SpawnedHighlight") then
	return
end

if not script:IsDescendantOf(game.ReplicatedStorage) then
	local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
	local clone = WrapHighlight(script:GetAttribute("Original")):Clone()
	local fillColor = script:FindFirstChild("FillColor")

	if fillColor and fillColor:IsA("Color3Value") then
		clone.FillColor = fillColor.Value
	end

	local outlineColor = script:FindFirstChild("OutlineColor")

	if outlineColor and outlineColor:IsA("Color3Value") then
		clone.OutlineColor = outlineColor.Value
	end

	clone.Parent = script.Parent
	local objectValue = Instance.new("ObjectValue", script)
	objectValue.Name = "SpawnedHighlight"
	objectValue.Value = clone
	script.Name = "__HighlightProxyWarning__"
end