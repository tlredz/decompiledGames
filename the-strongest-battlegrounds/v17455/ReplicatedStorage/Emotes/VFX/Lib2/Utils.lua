local Utils = {
	FixMesh = function(_, parent)
		local highlight = Instance.new("Highlight")
		highlight.Parent = parent
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 1
		return highlight
	end,
	scaleModel = function(_, model, value)
		local v

		if typeof(model) == "Instance" then
			v = model:IsA("Model")
		else
			v = false
		end

		assert(v, "Input must be a Model")
		local v2

		if typeof(value) == "number" then
			v2 = value > 0
		else
			v2 = false
		end

		assert(v2, "Scale must be a positive number")

		local function scaleAttributes(descendant)
			local v3 = {
				"VertexColor",
				"Transparency",
				"delay",
				"Repeat",
				"time"
			}

			for k, v4 in descendant:GetAttributes() do
				if table.find(v3, k) then
					continue
				end

				if typeof(v4) == "Vector3" then
					descendant:SetAttribute(k, v4 * value)
				elseif typeof(v4) == "number" then
					descendant:SetAttribute(k, v4 * value)
				end
			end
		end

		model:ScaleTo(value)

		for _, descendant in model:GetDescendants() do
			scaleAttributes(descendant)
		end
	end,
	delta_weld = function(_, model, model2, p, duration)
		local heartbeatConnection = nil
		heartbeatConnection = game["Run Service"].Heartbeat:Connect(function()
			if not model2 then
				heartbeatConnection:Disconnect()
			end

			local cFrame = nil

			if typeof(model) == "function" then
				cFrame = model()
			elseif typeof(model) == "Instance" then
				if model:IsA("Model") then
					cFrame = model.PrimaryPart.CFrame
				else
					cFrame = model.CFrame
				end
			elseif typeof(model) == "CFrame" then
				cFrame = model
			end

			if model2:IsA("Model") then
				model2:PivotTo(cFrame * p)
			else
				model2.CFrame = cFrame * (p and p or CFrame.new())
			end
		end)

		if duration then
			task.delay(duration, function()
				if heartbeatConnection and typeof(heartbeatConnection) == "RBXScriptConnection" then
					heartbeatConnection:Disconnect()
				end
			end)
		end

		return {
			Destory = function()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
			end,
			Connection = heartbeatConnection
		}
	end,
	createinfo = function(_, object)
		local attributes = object:GetAttributes()
		return TweenInfo.new(
			attributes.time,
			Enum.EasingStyle[attributes.style],
			Enum.EasingDirection[attributes.direction],
			tonumber(attributes.Repeat),
			attributes.reverse,
			(tonumber(attributes.delay))
		)
	end,
	RaycastParams = {
		Map = function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Map }
			return raycastParams
		end
	},
	OverlapParams = {
		Map = function()
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Include
			overlapParams.FilterDescendantsInstances = { workspace.Map.FixedMap }
			return overlapParams
		end
	}
}

function Utils.RequestRaycastParams(p)
	assert(Utils.RaycastParams[p], "Requested raycast params does not exist - " .. p)
	return Utils.RaycastParams[p] ~= nil and Utils.RaycastParams[p]() or nil
end

function Utils.RequestOverlapParams(p)
	assert(Utils.OverlapParams[p], "Requested raycast params does not exist - " .. p)
	return Utils.OverlapParams[p] ~= nil and Utils.OverlapParams[p]() or nil
end

return Utils