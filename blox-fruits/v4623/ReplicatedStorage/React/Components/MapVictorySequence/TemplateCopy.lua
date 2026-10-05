local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return React.forwardRef(function(p, callback)
	local ref = React.useRef(nil)
	React.useEffect(function()
		if not (p.Template and ref.current) then
			return function() end
		end

		local clone = p.Template:Clone()
		clone.Parent = ref.current

		if type(callback) == "table" then
			callback.current = clone
		elseif type(callback) == "function" then
			callback(clone)
		end

		return function()
			if type(callback) == "table" then
				callback.current = nil
			elseif type(callback) == "function" then
				callback(nil)
			end

			clone:Destroy()
		end
	end, { p.Template, ref.current })
	return createElement("Folder", RobloxTypes.mergeInstance({
		ref = ref
	}, p), {})
end)