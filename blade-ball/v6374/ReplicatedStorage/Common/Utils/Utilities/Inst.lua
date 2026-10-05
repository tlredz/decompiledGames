local Inst = {
	new = function(className: string, items, parent)
		local instance = Instance.new(className)

		if items then
			for k, item in items do
				if k == "Parent" then
					parent = parent or item
				else
					local v = string.match(k, "^%.(.+)$")

					if v then
						instance:AddTag(v)
					else
						local v2 = string.match(k, "^$(.+)$")

						if v2 then
							instance:SetAttribute(v2, item)
						else
							instance[k] = item
						end
					end
				end
			end
		end

		if parent then
			instance.Parent = parent
		end

		return instance
	end,
	name = function(className: string, name: string, parent)
		local instance = Instance.new(className)
		instance.Name = name

		if parent then
			instance.Parent = parent
		end

		return instance
	end,
	clone = function(instance, parent)
		local clone = instance:Clone()

		if parent then
			clone.Parent = parent
		end

		return clone
	end
}

function Inst.findOrCreate(name: string, p2: string, object)
	return object:QueryDescendants((`> {p2}[Name="{name}"]`))[1] or Inst.new(p2, {
		Name = name
	}, object)
end

function Inst.findFirstAncestor(parent, p: string)
	while parent do
		if parent.Name == p then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

function Inst.waitForQuery(object, p: string, p2: number?)
	local lastTime = os.clock()
	local v

	while true do
		v = object:QueryDescendants(p)

		if #v > 0 then
			break
		end

		if p2 and p2 < os.clock() - lastTime then
			return nil
		else
			task.wait()
		end
	end

	return v[1]
end

function Inst.waitForDescendant(instance, childName: string, p: number?)
	local lastTime = os.clock()
	local child

	while true do
		child = instance:FindFirstChild(childName, true)

		if child then
			break
		end

		if p and p < os.clock() - lastTime then
			return nil
		else
			task.wait()
		end
	end

	return child
end

return Inst