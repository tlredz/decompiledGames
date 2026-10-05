local Pool = require(script.Parent.Pool)
local NestedEmit = {
	walk = function(object, p, p2, parentAlive, data, callback)
		local parentCloneMap = Pool._cloneMaps and Pool._cloneMaps[p2]
		local visit

		visit = function(instance)
			if instance:GetAttribute("Transformed") then
				if callback then
					callback(instance)
				end

				local v2 = {}

				if data then
					v2.ChainCtx = data.ChainCtx
					v2.EmitIndex = data.EmitIndex
					v2.EmitCount = data.EmitCount
					v2._playToken = data._playToken
				end

				v2._parentAlive = parentAlive
				v2._parentCloneMap = parentCloneMap
				object:EnableEmit(instance, p2, v2)
			else
				for _, child in instance:GetChildren() do
					visit(child)
				end
			end
		end

		visit(p)
	end
}

function NestedEmit:walkWithScale(p2, p3, p4, p5, p6, p7)
	if not p6 then
		NestedEmit.walk(self, p2, p3, p4, p5)
		return
	end

	self._parentScaleMap = self._parentScaleMap or {}
	local scaleMapKeys = {}
	NestedEmit.walk(self, p2, p3, p4, p5, function(p8)
		self._parentScaleMap[p8] = p6
		scaleMapKeys[#scaleMapKeys + 1] = p8
	end)
	p7._scaleMapKeys = scaleMapKeys
end

return NestedEmit