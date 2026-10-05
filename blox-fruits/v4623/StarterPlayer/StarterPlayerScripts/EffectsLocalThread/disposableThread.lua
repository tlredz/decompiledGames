local script2 = nil
local clone = nil
local v2 = nil
local v3 = nil
local eventConnection = nil
eventConnection = script.run.Event:Connect(function(instance, p, p2)
	script2 = instance

	if v2 and v2[2] then
		local v4 = v2[2]
		warn("ran func on gc'd module")

		if typeof(v4) == "function" then
			v4(p, p2)
		else
			v4.new(p):Run()
		end
	else
		if not clone then
			clone = instance:Clone()
			clone.Parent = instance.Parent
			clone.Name ..= " (copy)"
			local module = require(clone)
			v3 = module
			local ancestryChangedConnection = nil
			ancestryChangedConnection = script2.AncestryChanged:Connect(function(_, parent)
				if not parent then
					print("Client cleaning up module:", clone, script2)

					if not clone then
						return
					end

					clone:Destroy()
					Instance.new("Folder")
					v2 = setmetatable({ clone, v3 }, {
						__mode = "v"
					})
					local getfenv_2 = getfenv(v3)
					getfenv_2.script = script2
					script2 = nil
					clone = nil
					v3 = nil
					local total = 0
					local total2 = 0

					while v2[2] do
						total += task.wait()

						if not (total > 10) then
							continue
						end

						total2 += total
						warn("still waiting for module", v2[1], v2[2], "to be collected for", total2)
						total = 0
					end

					eventConnection:Disconnect()
					eventConnection = nil
					ancestryChangedConnection:Disconnect()
					ancestryChangedConnection = nil
					script:Destroy()
				end
			end)
		end

		if typeof(require(clone)) == "function" then
			local module = require(clone)
			module(p, p2)
		else
			local module = require(clone)
			module.new(p):Run()
		end
	end
end)