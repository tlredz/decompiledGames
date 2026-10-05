local PartConstants = require(script.Parent.PartConstants)
return function(p)
	function p.ReapplyLink(_, state)
		local link = state.Link

		if not link then
			return
		end

		if not link.Parent then
			state.Link = nil
			return
		end

		local _localWorldCF = state._localWorldCF

		if not (_localWorldCF and (state.VisualPart and state.VisualPart.Parent)) then
			return
		end

		local type = state.Type

		if type ~= "Part" and type ~= "Model" and type ~= "Attachment" then
			return
		end

		if type == "Attachment" then
			local parent = state.VisualPart.Parent

			if not parent then
				return
			end

			local _rigidLocalParentCF = state.LinkMode == "RigidLocal" and (state._rigidLocalParentCF or CFrame.new()) or PartConstants.resolveLinkCFrame(link)
			local cframe = (parent:IsA("BasePart") and parent.CFrame or CFrame.new()):ToObjectSpace(_rigidLocalParentCF)

			if state.LinkMode == "Follow" or state.LinkMode == "Pivot" then
				cframe = CFrame.new(cframe.Position)
			end

			state.VisualPart.CFrame = cframe * _localWorldCF
		else
			local _rigidLocalParentCF = state.LinkMode == "RigidLocal" and (state._rigidLocalParentCF or CFrame.new()) or PartConstants.resolveLinkCFrame(link)
			local position = _rigidLocalParentCF.Position
			local linkMode = state.LinkMode
			local cFrame

			if linkMode == "WeldWithoutRotation" then
				local vectorToWorldSpace = _rigidLocalParentCF:VectorToWorldSpace(_localWorldCF.Position)
				local v2 = _localWorldCF - _localWorldCF.Position
				cFrame = CFrame.new(position + vectorToWorldSpace) * v2
			elseif linkMode == "Follow" or linkMode == "Pivot" then
				cFrame = CFrame.new(position) * _localWorldCF
			else
				cFrame = _rigidLocalParentCF * _localWorldCF
			end

			if type == "Model" then
				state.VisualPart:PivotTo(cFrame)
			else
				state.VisualPart.CFrame = cFrame
			end
		end
	end
end