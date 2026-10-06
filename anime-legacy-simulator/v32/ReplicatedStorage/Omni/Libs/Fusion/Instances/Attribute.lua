local parent = script.Parent.Parent
require(parent.Types)
local checkLifetime = require(parent.Memory.checkLifetime)
local Observer = require(parent.Graph.Observer)
local castToState = require(parent.State.castToState)
local peek = require(parent.State.peek)
local v = {}

local function Attribute(p: string)
	local v2 = v[p]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "Attribute",
			stage = "self",
			apply = function(_, p2, p3, instance)
				if not castToState(p3) then
					instance:SetAttribute(p, p3)
					return
				end

				checkLifetime.bOutlivesA(
					p2,
					instance,
					p3.scope,
					p3.oldestTask,
					checkLifetime.formatters.boundAttribute,
					p
				)
				Observer(p2, p3):onBind(function()
					instance:SetAttribute(p, peek(p3))
				end)
			end
		}
		v[p] = v2
	end

	return v2
end

return Attribute