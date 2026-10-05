return function(folder)
	local descendants = folder:GetDescendants()
	local count = descendants and #descendants or 0
	local v2 = {}

	if descendants then
		assert(v2, "bad dictionary")

		for _, touchTransmitter in pairs(descendants) do
			if touchTransmitter:IsA("TouchTransmitter") then
				count -= 1
			else
				v2[touchTransmitter.Name] = (v2[touchTransmitter.Name] or 0) + 1
			end
		end
	end

	local v3 = {
		count = count,
		dictionary = 0,
		Destroy = 0
	}
	v3.dictionary = v2 or {}

	function v3.Destroy()
		warn("destroy never initialized")
	end

	local function descendantAdded(touchTransmitter)
		if touchTransmitter:IsA("TouchTransmitter") or not v2 then
			return
		end

		v2[touchTransmitter.Name] = (v2[touchTransmitter.Name] or 0) + 1

		if v3 then
			v3.count += 1
		end
	end

	local function descendantRemoving(touchTransmitter)
		if touchTransmitter:IsA("TouchTransmitter") or not v2 then
			return
		end

		local v4 = v2[touchTransmitter.Name]

		if v4 then
			if v4 <= 1 then
				v2[touchTransmitter.Name] = nil
			else
				local v5 = v2
				local name = touchTransmitter.Name
				v5[name] -= 1
			end
		end

		if v3 then
			v3.count -= 1
		end
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(descendantAdded)
	assert(v3, "bad tracker")

	function v3.Destroy()
		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
		end

		descendantAddedConnection = nil
		descendants = nil
		v2 = nil
		v3 = nil
	end

	return v3
end