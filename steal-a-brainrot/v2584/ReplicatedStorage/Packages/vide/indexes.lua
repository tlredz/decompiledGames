require(script.Parent.flags)
local branch = require(script.Parent.branch)
local source = require(script.Parent.source)
local effect = require(script.Parent.effect)
local timeout = require(script.Parent.timeout)
local v = timeout()

local function indexes(callback, callback2)
	local count = 0
	local v2 = {}
	local v3 = source({})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_output()
		local v4 = table.create(4)

		for _, v5 in v2 do
			table.insert(v4, v5.object)
		end

		v3(v4)
	end

	effect(function()
		local v4 = callback()
		local count2 = count
		count += 1
		local flag = false

		for k, v6 in v4 do
			local v7 = v2[k]

			if v7 == nil then
				local value_source = source(v6)
				local present = source(false)
				local v10 = nil
				local v12 = k
				local destroy, object = branch(function()
					local v16, v17 = callback2(value_source, v12, present)
					v10 = v17
					return v16
				end)
				present(true)
				v2[k] = {
					destroy = destroy,
					object = object,
					value = v6,
					value_source = value_source,
					count = count2,
					delay = v10 or 0,
					present = present,
					timeout = nil
				}
				flag = true
			else
				v7.count = count2

				if v7.value ~= v6 then
					if v7.timeout then
						v7.timeout.cancel = true
						v7.timeout = nil
						v7.present(true)
					end

					v7.value = v6
					v7.value_source(v6)
				end
			end
		end

		for k, v6 in v2 do
			if not (v6.count < count2) then
				continue
			end

			v6.present(false)

			if v6.delay == 0 then
				v6.destroy()
				v2[k] = nil
				flag = true
			else
				v6.value = nil

				if v6.timeout == nil then
					local v7 = v6
					local v8 = k
					v6.timeout = v(v6.delay, function()
						v7.destroy()
						v2[v8] = nil
						update_output() -- equivalent call inferred; original call site unknown
					end)
				end
			end
		end

		if flag then
			update_output() -- equivalent call inferred; original call site unknown
		end
	end)
	return v3
end

return indexes