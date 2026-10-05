local React = require(game.ReplicatedStorage.Packages.React)
return function(instance, callback)
	local useState = React.useState
	local v

	if instance then
		local flag = true

		for _, child in instance:GetChildren() do
			v = callback(child)

			if not v then
				continue
			end

			flag = false
			break
		end

		if flag then
			v = nil
		end
	end

	local state, setState = useState(v)
	React.useEffect(function()
		if not instance then
			return
		end

		local childAddedConnection = instance.ChildAdded:Connect(function(child)
			local v2 = child ~= state and callback(child)

			if v2 then
				setState(v2)
			end
		end)

		local function tryUpdate()
			local v2 = false

			for _, child in instance:GetChildren() do
				if child ~= state then
					continue
				end

				v2 = true
				break
			end

			if not v2 then
				local v4 = false

				for _, child in instance:GetChildren() do
					local v6 = callback(child)

					if not v6 then
						continue
					end

					setState(v6)
					v4 = true
					break
				end

				if not v4 then
					setState(nil)
				end
			end
		end

		local childRemovedConnection = instance.ChildRemoved:Connect(function(child)
			if child == state then
				setState(nil)
			end
		end)
		tryUpdate()
		return function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
		end
	end, { instance, state })
	return state
end