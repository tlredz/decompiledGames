local ButtonActions = require(script.Parent.ButtonActions)
local ButtonHints = require(script.Parent.ButtonHints)
return {
	FromHint = function(parent, childName, p, p2)
		local name = p == "L1" and "上一分类按钮" or p == "R1" and "下一分类按钮" or "手柄输入按钮"
		local parent2 = parent:FindFirstChild(name)

		if not parent2 then
			local child = parent:FindFirstChild(childName)
			assert(child, "Missing edit-state shortcut: " .. childName)
			parent2 = Instance.new("ImageButton")
			parent2.Name = name

			for _, v3 in {
				"AnchorPoint",
				"Position",
				"Size",
				"SizeConstraint",
				"Rotation",
				"ZIndex",
				"LayoutOrder"
			} do
				parent2[v3] = child[v3]
			end

			parent2.BackgroundTransparency = 1
			parent2.Image = ""
			parent2.Parent = parent
			local clone = child:Clone()
			clone.Name = "手柄" .. p
			clone.AnchorPoint = Vector2.zero
			clone.Position = UDim2.fromScale(0, 0)
			clone.SizeConstraint = Enum.SizeConstraint.RelativeXY
			clone.Size = UDim2.fromScale(1, 1)
			clone.Parent = parent2
			child:Destroy()
		end

		ButtonHints.Shortcut(parent2, p)

		if not ButtonActions.Has(parent2) then
			ButtonActions.Bind(parent2, p2)
		end

		return parent2
	end
}