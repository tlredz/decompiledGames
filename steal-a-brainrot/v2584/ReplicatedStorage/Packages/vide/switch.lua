local branch = require(script.Parent.branch)
local source = require(script.Parent.source)
local effect = require(script.Parent.effect)
local timeout = require(script.Parent.timeout)
local v = timeout()

local function switch_map(callback, p)
	local v2 = {}
	local v3 = source(nil)

	local function update_output()
		local v4 = {}

		for _, v5 in v2 do
			table.insert(v4, v5.object)
		end

		if not v4[2] then
			if v4[1] then
				v4 = v4[1]
			else
				v4 = nil
			end
		end

		v3(v4)
	end

	effect(function()
		local v4 = callback()

		for k, v5 in v2 do
			if k == v4 then
				continue
			end

			v5.present(false)

			if v5.delay == 0 then
				v5.destroy()
				v2[k] = nil
			elseif v5.timeout == nil then
				local v6 = v5
				local v7 = k
				v5.timeout = v(v5.delay, function()
					v6.destroy()
					v2[v7] = nil
					update_output()
				end)
			end
		end

		if v4 ~= nil then
			local v5 = v2[v4]

			if v5 then
				v5.present(true)

				if v5.timeout then
					v5.timeout.cancel = true
					v5.timeout = nil
				end
			else
				local v6 = p[v4]

				if v6 ~= nil then
					if type(v6) ~= "function" then
						error("map must map a value to a function", 0)
					end

					local present = source(false)
					local v8 = nil
					local destroy, object = branch(function()
						local v11, v12 = v6(present)
						v8 = v12
						return v11
					end)
					present(true)
					v2[v4] = {
						destroy = destroy,
						object = object,
						delay = v8 or 0,
						present = present,
						timeout = nil
					}
				end
			end
		end

		update_output()
	end)
	return v3
end

local function switch(callback)
	return function(p)
		return (switch_map(callback, p))
	end
end

return switch