local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Item.Item)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
return {
	Apply = function(p, p2, super, p3, p4: string)
		local clone = table.clone(super)
		local inherits = {}

		if p2 and not Object.InstanceOf(super, p2) then
			table.insert(inherits, p2)
		end

		table.insert(inherits, (getmetatable(super)))
		local v2 = {
			Inherits = inherits,
			__index = function(_, p5)
				if p3[p5] then
					return function(p6, ...)
						return p3[p5](p6[p4], ...)
					end
				end

				return super[p5]
			end
		}
		setmetatable(v2, super)
		setmetatable(clone, v2)
		clone[p4] = p
		p.super = super
		return clone
	end
}