local module = require("./flags")
local module2 = require("./branch")
local module3 = require("./source")
local module4 = require("./effect")
local module5 = require("./timeout")
local v = module5()

local function values(callback, callback2)
	local count = 0
	local v2 = {}
	local v3 = module3({})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_output()
		local v4 = table.create(4)

		for _, v5 in v2 do
			table.insert(v4, v5.object)
		end

		v3(v4)
	end

	module4(function()
		local v4 = callback()
		local count2 = count
		count += 1
		local flag = false

		if module.strict then
			local v6 = {}

			for _, v7 in v4 do
				if v6[v7] then
					error("table source passed to `values()` contains duplicate values", 0)
				end

				v6[v7] = true
			end
		end

		for k, v6 in v4 do
			local v7 = v2[v6]

			if v7 == nil then
				local index_source = module3(k)
				local present = module3(false)
				local v10 = nil
				local v11 = v6
				local destroy, object = module2(function()
					local v16, v17 = callback2(v11, index_source, present)
					v10 = v17
					return v16
				end)
				present(true)
				v2[v6] = {
					destroy = destroy,
					object = object,
					index = k,
					index_source = index_source,
					count = count2,
					delay = v10 or 0,
					present = present,
					timeout = nil
				}
				flag = true
			else
				v7.count = count2

				if v7.index ~= k then
					if v7.timeout then
						v7.timeout.cancel = true
						v7.timeout = nil
						v7.present(true)
					end

					v7.index = k
					v7.index_source(k)
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
				v6.index = nil

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

return values