local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local React = require(game.ReplicatedStorage.Packages.React)
local Option = require(game.ReplicatedStorage.Packages.Option)
return function(tag: string?, flag: boolean?)
	local ref = React.useRef(nil)
	local _, setState = React.useState(HttpService:GenerateGUID(false))
	local v = React.useCallback(function(current)
		ref.current = current

		if flag then
			setState(HttpService:GenerateGUID(false))
		end
	end, { flag })
	React.useEffect(function()
		if tag == nil then
			return function() end
		end

		local current = ref.current
		local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
			if current ~= p then
				v(p)
			end
		end)
		local none = Option.none()
		local none2 = Option.none()
		local none3 = Option.none()

		if current then
			none3 = Option.some(current.AncestryChanged:Connect(function(instance)
				if not instance:IsDescendantOf(game) then
					v(nil)
				end
			end))
			none = Option.some(CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
				if current == p then
					v(nil)
				end
			end))
			none2 = Option.some(current.Destroying:Connect(function()
				v(nil)
			end))
		end

		local v2 = CollectionService:GetTagged(tag)[1]

		if v2 and current ~= v2 then
			v(v2)
		end

		return function()
			connection:Disconnect()
			none3:inspect(function(connection2)
				connection2:Disconnect()
			end)
			none2:inspect(function(connection2)
				connection2:Disconnect()
			end)
			none:inspect(function(connection2)
				connection2:Disconnect()
			end)
		end
	end, { tag, ref.current, v })
	return ref
end