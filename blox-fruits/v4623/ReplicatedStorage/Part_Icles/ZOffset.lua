return function(p)
	function p.ApplyZOffset(_, data, p2)
		local zOffset = data.ZOffset

		if not zOffset or zOffset == 0 or not p2 then
			return
		end

		if not (data.VisualPart and data.VisualPart.Parent) then
			return
		end

		local type = data.Type

		if type ~= "Part" and type ~= "Model" and type ~= "Attachment" then
			return
		end

		local v = type == "Model"
		local v2 = type == "Attachment"
		local _postUpdateCF = data._postUpdateCF or v and data.VisualPart:GetPivot() or data.VisualPart.CFrame
		local parent

		if v2 then
			parent = data.VisualPart.Parent

			if parent and parent:IsA("BasePart") then
				_postUpdateCF = parent.CFrame * _postUpdateCF
			else
				parent = nil
			end
		end

		local position = _postUpdateCF.Position
		local v3 = p2 - position
		local magnitude = v3.Magnitude

		if magnitude < 0.001 then
			return
		end

		local v4 = position + v3 / magnitude * zOffset
		local cFrame = CFrame.new(v4) * (_postUpdateCF - position)

		if parent then
			cFrame = parent.CFrame:ToObjectSpace(cFrame)
		end

		if v then
			data.VisualPart:PivotTo(cFrame)
		else
			data.VisualPart.CFrame = cFrame
		end
	end
end