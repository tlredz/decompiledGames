local shared2 = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared2.React)
require(shared2.Signal)
local RunContext = require(shared2.RunContext)
local TeleportService = game:GetService("TeleportService")
local parent = script.Parent
local useChanged = require(parent.useChanged)
local relicsXYZ

if RunContext.IsEdit then
	relicsXYZ = shared.RelicsXYZ
else
	relicsXYZ = setmetatable({}, {
		__index = function(p: string)
			return TeleportService:GetTeleportSetting((`RELICSxyz_{p}`))
		end,
		__newindex = function(p: string, p2)
			TeleportService:SetTeleportSetting(`RELICSxyz_{p}`, p2)
		end
	})
end

if not relicsXYZ and RunContext.IsEdit then
	relicsXYZ = {}
	shared.RelicsXYZ = relicsXYZ
end

local function useRestore(p: string, value, p2)
	local v = relicsXYZ[p]

	if v ~= nil and typeof(v) == "string" and typeof(value) == "number" then
		v = tonumber(v) or value
	end

	if v ~= nil then
		value = v
	end

	local state, setState

	if p2 then
		state, setState = useChanged(value, p2)
	else
		state, setState = React.useState(value)
	end

	local ref = React.useRef(nil)
	React.useEffect(function()
		if ref.current then
			task.cancel(ref.current)
		end

		ref.current = task.delay(0.1, function()
			relicsXYZ[p] = state
			ref.current = nil
		end)
		return function()
			if ref.current then
				task.cancel(ref.current)
				ref.current = nil
			end

			relicsXYZ[p] = state
		end
	end, { state })
	return state, setState
end

return useRestore