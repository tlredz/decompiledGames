local React = require(game.ReplicatedStorage.Packages.React)
return function(p, callback)
	local useState = React.useState
	local v

	if p then
		v = callback(p)
	end

	local state, setState = useState(v)
	local ref = React.useRef(state)
	ref.current = state
	React.useEffect(function()
		if p then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function tryUpdate()
				if p then
					local current = callback(p)

					if current ~= ref.current then
						ref.current = current
						setState(current)
					end
				elseif ref.current ~= nil then
					ref.current = nil
					setState(nil)
				end
			end

			local changedConnection = p.Changed:Connect(tryUpdate)
			tryUpdate() -- equivalent call inferred; original call site unknown
			return function()
				changedConnection:Disconnect()
			end
		elseif ref.current ~= nil then
			setState(nil)
		end
	end, { p })
	return state
end