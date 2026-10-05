local FayeUtility = require(script.Parent.Parent.Misc.FayeUtility)
local Compile = require(script.Parent.Parent.Compile)
return function(state, list, callback)
	function state.receiverFunc(...)
		if state.Entries == nil then
			callback(...)
			return
		end

		for i = 1, state.Entries.Count do
			local entry = state.Entries[i]

			if not (entry.Instance ~= nil and entry.Instance.Thread ~= nil) then
				continue
			end

			local cleanThread = entry.Instance.CleanThread or entry.Instance.Thread

			if entry.Thread ~= nil then
				FayeUtility.CallDestroy(entry.Thread)
			end

			if state.IsState then
				entry.Thread = cleanThread:Extend()
			end

			local v, v2 = callback(entry.Thread or cleanThread, entry.Instance.Instance, ...)
			local v3 = state.IsState and {
				Instance = entry.Instance.Instance,
				Thread = entry.Thread
			} or entry.Instance

			if v == nil then
				FayeUtility.CallDestroy(entry.Thread)
				entry.Thread = nil
			elseif entry.Index == nil or FayeUtility.tof(entry.Index) == FayeUtility.numbertxt then
				if v2 == nil then
					Compile(
						v3,
						(FayeUtility.tof(v) ~= FayeUtility.tabletxt or v.__type ~= nil or not v) and { v } or v,
						entry.Thread
					)
				else
					Compile(v3, {
						[v] = v2
					}, entry.Thread)
				end
			else
				Compile(v3, {
					[entry.Index] = v
				}, entry.Thread)
			end
		end
	end

	if list ~= nil then
		if state.Connections == nil then
			state.Connections = {
				Count = 0
			}
		end

		if FayeUtility.tof(list) == FayeUtility.tabletxt and list.Connect == nil then
			for _, v in ipairs(list) do
				state.Connections[state.Connections.Count + 1] = v:Connect(state.receiverFunc, state.Connections)
				state.Connections.Count += 1
			end
		else
			state.Connections[state.Connections.Count + 1] = list:Connect(state.receiverFunc, state.Connections)
			state.Connections.Count += 1
		end
	end
end