local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local Observer = require(parent.Graph.Observer)
local peek = require(parent.State.peek)
local castToState = require(parent.State.castToState)
local doCleanup = require(parent.Memory.doCleanup)
return {
	type = "SpecialKey",
	kind = "Children",
	stage = "descendants",
	apply = function(_, list, p, parent2)
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local updateChildren

		updateChildren = function()
			v2, v = v, v2
			v4, v3 = v3, v4
			local processChild

			processChild = function(items, p2: string?)
				local typeName = typeof(items)

				if typeName == "Instance" then
					v[items] = true

					if v2[items] == nil then
						items.Parent = parent2
					else
						v2[items] = nil
					end
				elseif castToState(items) then
					local currentItems = peek(items)

					if currentItems ~= nil then
						processChild(currentItems, p2)
					end

					local v5 = v4[items]

					if v5 == nil then
						v5 = {}
						Observer(v5, items):onChange(updateChildren)
					else
						v4[items] = nil
					end

					v3[items] = v5
				else
					if typeName ~= "table" then
						External.logWarn("unrecognisedChildType", typeName)
						return
					end

					for k, item in pairs(items) do
						local typeName2 = typeof(k)
						local v5 = nil

						if typeName2 == "string" then
							v5 = k
						elseif typeName2 == "number" and p2 ~= nil then
							v5 = p2 .. "_" .. k
						end

						processChild(item, v5)
					end
				end
			end

			if p ~= nil then
				processChild(p)
			end

			for k in pairs(v2) do
				k.Parent = nil
			end

			table.clear(v2)

			for _, v5 in pairs(v4) do
				doCleanup(v5)
			end

			table.clear(v4)
		end

		table.insert(list, function()
			p = nil
			updateChildren()
		end)
		updateChildren()
	end
}