local __StreamedObjects = game.ReplicatedStorage.__StreamedObjects
return function(value, p)
	local RunService = game:GetService("RunService")

	if RunService:IsServer() then
		if typeof(value) == "table" then
			local replicatedTag = value[1]:GetAttribute("ReplicatedTag")

			if not replicatedTag then
				local HttpService = game:GetService("HttpService")
				replicatedTag = HttpService:GenerateGUID(false)
			end

			for _, item in pairs(value) do
				local CollectionService = game:GetService("CollectionService")
				CollectionService:AddTag(item, replicatedTag)
				item:SetAttribute("ReplicatedTag", replicatedTag)
			end

			return {
				replicatedTag,
				#value,
				"__StreamedObject",
				true
			}
		else
			local replicatedTag = value:GetAttribute("ReplicatedTag")

			if not replicatedTag then
				local HttpService = game:GetService("HttpService")
				replicatedTag = HttpService:GenerateGUID(false)
				local folder = Instance.new("Folder", __StreamedObjects)
				folder.Name = replicatedTag
				local connections = {}
				connections[1] = value.Destroying:Once(function()
					folder:Destroy()

					for _, connection in pairs(connections) do
						connection:Disconnect()
					end

					connections = nil
				end)
				connections[2] = value.AncestryChanged:Connect(function(_, parent)
					if parent == nil then
						folder:Destroy()

						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						connections = nil
					end
				end)
			end

			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(value, replicatedTag)
			value:SetAttribute("ReplicatedTag", replicatedTag)
			return { replicatedTag, 1, "__StreamedObject" }
		end
	else
		if typeof(value) == "Instance" then
			return value
		end

		if not __StreamedObjects:FindFirstChild(value[1]) then
			return
		end

		local CollectionService = game:GetService("CollectionService")
		local tagged = CollectionService:GetTagged(value[1])

		if #tagged < value[2] then
			local thread = coroutine.running()
			local CollectionService2 = game:GetService("CollectionService")
			local connection = CollectionService2:GetInstanceAddedSignal(value[1]):Connect(function(p2)
				table.insert(tagged, p2)

				if #tagged >= value[2] then
					coroutine.resume(thread)
				end
			end)

			if not p then
				task.delay(2, coroutine.resume, thread)
			end

			coroutine.yield()
			connection:Disconnect()
		end

		if value[2] == 1 and not value[4] then
			return tagged[1]
		end

		return tagged
	end
end