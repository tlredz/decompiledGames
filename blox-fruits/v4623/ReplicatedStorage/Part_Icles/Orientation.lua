local createVector = vector.create
return function(p)
	function p.ApplyOrientation(_, state, p2, p3)
		local DISTANCE_EPSILON = 0.001
		local orientation = state.Orientation

		if not orientation or orientation == "None" or not (state.VisualPart and state.VisualPart.Parent) then
			return
		end

		local type = state.Type

		if type ~= "Part" and type ~= "Model" and type ~= "Attachment" then
			return
		end

		local v = type == "Model"
		local v2 = type == "Attachment"
		local _postUpdateCF = state._postUpdateCF or v and state.VisualPart:GetPivot() or state.VisualPart.CFrame
		local parent

		if v2 then
			parent = state.VisualPart.Parent

			if parent and parent:IsA("BasePart") then
				_postUpdateCF = parent.CFrame * _postUpdateCF
			else
				parent = nil
			end
		end

		local position = _postUpdateCF.Position
		local v3 = _postUpdateCF - position
		local baseDirection

		if state._lastOrientPos then
			baseDirection = (position - state._lastOrientPos) / math.max(p2, 0.0001)
		else
			baseDirection = state.BaseDirection or createVector(-0, -0, -1)
		end

		state._lastOrientPos = position
		local cframe

		if orientation == "FacingCamera" then
			if not p3 then
				return
			end

			local v4 = p3 - position

			if v4.Magnitude < DISTANCE_EPSILON then
				return
			else
				cframe = CFrame.lookAt(createVector(0, 0, 0), v4.Unit)
			end
		elseif orientation == "FacingCameraWorldUp" then
			if not p3 then
				return
			end

			local v4 = p3 - position
			local vector2 = Vector3.new(v4.X, 0, v4.Z)

			if vector2.Magnitude < DISTANCE_EPSILON then
				return
			else
				cframe = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit, createVector(0, 1, 0))
			end
		elseif orientation == "VelocityParallel" then
			if state.VelocityVectored or baseDirection.Magnitude < DISTANCE_EPSILON then
				return
			end

			local v4 = not p3 and createVector(0, 1, 0) or p3 - position or createVector(0, 1, 0)
			local v5 = v4.Magnitude < DISTANCE_EPSILON and createVector(0, 1, 0) or v4
			cframe = CFrame.lookAt(createVector(0, 0, 0), baseDirection.Unit, v5.Unit)
		elseif orientation == "VelocityPerpendicular" then
			if baseDirection.Magnitude < DISTANCE_EPSILON then
				return
			end

			local unit = baseDirection.Unit
			local cross = unit:Cross(createVector(0, 1, 0))

			if cross.Magnitude < DISTANCE_EPSILON then
				cross = unit:Cross(createVector(1, 0, 0))
			end

			cframe = CFrame.lookAt(createVector(0, 0, 0), cross.Unit, unit)
		else
			if not state._orientWarned then
				state._orientWarned = true
				warn("Part-Icles: unknown Orientation '" .. tostring(state.Orientation) .. "' on emitted particle  -  falling back to identity.")
			end

			return
		end

		local cFrame = CFrame.new(position) * cframe * v3

		if parent then
			cFrame = parent.CFrame:ToObjectSpace(cFrame)
		end

		if v then
			state.VisualPart:PivotTo(cFrame)
		else
			state.VisualPart.CFrame = cFrame
		end
	end
end