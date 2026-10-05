local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
require(shared.Promise)
local Marketplace = require(shared.Marketplace)
local v = {}

local function useProductInfo(value: number?, p)
	local v2 = value or 0
	local v3 = p or Enum.InfoType.Asset
	local formatted = `{v3.Name}_{v2}`
	local state, setState = React.useState(function()
		local v4 = v[formatted]

		if v4 and v4:getStatus() == "Completed" then
			return v4:expect()
		end

		return nil
	end)
	React.useEffect(function()
		local v4 = v[formatted]

		if not v4 then
			v4 = Marketplace.GetProductInfo(v2, v3)
			v[formatted] = v4
		end

		local v5 = v4:andThen(function(p2)
			if p2 and state ~= p2 then
				setState(p2)
			else
				setState(nil)
			end
		end):catch(function()
			setState(nil)
		end)
		return function()
			v5:cancel()
		end
	end, { v2, v3 })
	return state
end

return useProductInfo