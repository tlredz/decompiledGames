local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local PlayerData = require(shared.PlayerData)
local parent = script.Parent
local useSignal = require(parent.useSignal)

local function usePlayerData(...)
	local v = { ... }
	local joined = table.concat(v, " | ")
	local v2 = PlayerData.Get()
	local state, setState = React.useState(joined)

	if joined and state ~= joined then
		setState(joined)
	end

	local state2, setState2 = React.useState(v2.CurrentData)
	local state3, setState3 = React.useState(v2.IsLoaded)
	local ref = React.useRef(nil)
	useSignal(v2.Loaded, function(p)
		if state3 ~= p then
			setState3(p)
			setState2(v2.CurrentData)
		end
	end, {})
	useSignal(v2.Updated, function(p)
		local flag

		if #v > 0 then
			flag = false

			for _, v4 in ipairs(v) do
				if p.Path:sub(1, #v4) ~= v4 then
					continue
				end

				flag = true
				break
			end
		else
			flag = true
		end

		if flag then
			if ref.current then
				return
			else
				ref.current = task.delay(0.1, function()
					local clone = table.clone(v2.CurrentData)
					ref.current = nil
					setState2(clone)
				end)
			end
		end
	end, { state })
	return state2, state3
end

return usePlayerData