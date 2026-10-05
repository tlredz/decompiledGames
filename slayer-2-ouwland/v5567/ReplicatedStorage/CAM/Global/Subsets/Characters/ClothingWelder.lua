-- equivalent calls inferred from this helper; original call sites unknown
local function tint_skin_parts(instance, clone)
	local bodyColors = instance:FindFirstChildOfClass("BodyColors")

	if bodyColors == nil then
		return
	end

	for _, v in clone:QueryDescendants("BasePart[$Color=bc],SurfaceAppearance[$Color=bc]") do
		v.Color = bodyColors.TorsoColor3
	end
end

return {
	AddClothingTo = function(instance, parent, instance2)
		if parent:FindFirstChild(instance2.Name) ~= nil then
			return
		end

		local clone = instance2:Clone()

		for _, child in ipairs(clone:GetChildren()) do
			local child2 = instance:FindFirstChild(child:FindFirstChild("CorName") ~= nil and child.CorName.Value or child.Name)

			if not (child2 ~= nil and child:FindFirstChild("Weld") ~= nil) then
				continue
			end

			if child:FindFirstChild("Tang") ~= nil then
				child.Tang:Destroy()
			end

			local weld = child.Weld
			local v = child:FindFirstChild("CorrespondingSize") ~= nil
			local v2

			if v then
				if child:FindFirstChild("Ds") == nil then
					local vector3Value = Instance.new("Vector3Value")
					vector3Value.Value = child.Size
					vector3Value.Name = "Ds"
					vector3Value.Parent = child
				end

				local value = child.CorrespondingSize.Value
				v2 = child2.Size / value
				child.Size = child.Ds.Value * v2
			end

			local clone2 = weld:Clone()
			clone2.Name = "Tang"
			clone2.Parent = child
			clone2.Part1 = child
			clone2.Part0 = child2

			if not v then
				continue
			end

			local C0 = clone2.C0
			local p = C0.p
			local v3 = C0 - p
			local v4 = p * v2
			clone2.C0 = CFrame.new(v4) * v3
			local C1 = clone2.C1
			local p2 = C1.p
			local v5 = C1 - p2
			local v6 = p2 * v2
			clone2.C1 = CFrame.new(v6) * v5
		end

		tint_skin_parts(instance, clone) -- equivalent call inferred; original call site unknown
		clone.Parent = parent
		return clone
	end
}