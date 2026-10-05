local function ancestryChanged(instance, callback)
	if instance and instance.Parent then
		local ancestryChangedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanup()
			if ancestryChangedConnection and ancestryChangedConnection.Connected then
				ancestryChangedConnection:Disconnect()
			end

			ancestryChangedConnection = nil
		end

		ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanup() -- equivalent call inferred; original call site unknown
				callback()
			end
		end)
		return cleanup
	else
		print(".AncestryChanged > Dead on arrival")
		task.spawn(callback)
		return function() end
	end
end

local function destroying(instance, callback)
	if instance and instance.Parent then
		local destroyingConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanup()
			if destroyingConnection and destroyingConnection.Connected then
				destroyingConnection:Disconnect()
			end

			destroyingConnection = nil
		end

		destroyingConnection = instance.Destroying:Connect(function()
			cleanup() -- equivalent call inferred; original call site unknown
			callback()
		end)
		return cleanup
	else
		print(".Destroying > Dead on arrival")
		task.spawn(callback)
		return function() end
	end
end

return {
	AncestryChanged = ancestryChanged,
	Destroying = destroying
}