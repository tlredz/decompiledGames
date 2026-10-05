return function()
	local parentModule = require(script.Parent)
	it("should load with all public APIs", function()
		local v = {
			createElement = "function",
			createFragment = "function",
			createRef = "function",
			forwardRef = "function",
			createBinding = "function",
			joinBindings = "function",
			mount = "function",
			unmount = "function",
			update = "function",
			oneChild = "function",
			setGlobalConfig = "function",
			createContext = "function",
			reify = "function",
			teardown = "function",
			reconcile = "function",
			Component = true,
			PureComponent = true,
			Portal = true,
			Children = true,
			Event = true,
			Change = true,
			Ref = true,
			None = true,
			UNSTABLE = true
		}
		expect(parentModule).to.be.ok()

		for k, v2 in pairs(v) do
			local v3

			if typeof(v2) == "string" then
				v3 = typeof(parentModule[k]) == v2
			else
				v3 = parentModule[k] ~= nil
			end

			if v3 then
				continue
			end

			local v4 = typeof(v2) == "boolean" and "present" or "of type " .. tostring(v2)
			local formatted = ("Expected public API member %q to be %s, but instead it was of type %s"):format(
				tostring(k),
				v4,
				(typeof(parentModule[k]))
			)
			error(formatted)
		end

		for k in pairs(parentModule) do
			if v[k] ~= nil then
				continue
			end

			local formatted = ("Found unknown public API key %q!"):format((tostring(k)))
			error(formatted)
		end
	end)
end