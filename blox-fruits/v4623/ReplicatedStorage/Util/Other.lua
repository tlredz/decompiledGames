return {
	hrpFromPart = function(parent)
		if parent == nil then
			return nil
		end

		if not (parent:IsDescendantOf(workspace.Enemies) or parent:IsDescendantOf(workspace.Characters)) then
			return
		end

		local humanoidRootPart

		repeat
			humanoidRootPart = parent.Parent:FindFirstChild("HumanoidRootPart")
			parent = parent.Parent
		until humanoidRootPart or parent == workspace

		return humanoidRootPart
	end
}