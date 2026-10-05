local Trove = require(script.Parent.Parent.Trove)
require(script.Parent.Streamable)
return {
	Compound = function(items, callback)
		local maid = Trove.new()
		local v = Trove.new()
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Check()
			if flag then
				return
			end

			for _, item in pairs(items) do
				if not item.Instance then
					return
				end
			end

			flag = true
			callback(items, v)
		end

		local function Cleanup()
			if not flag then
				return
			end

			flag = false
			v:Clean()
		end

		for _, item in pairs(items) do
			maid:Add(item:Observe(function(_, object)
				Check() -- equivalent call inferred; original call site unknown
				object:Add(Cleanup)
			end))
		end

		maid:Add(Cleanup)
		return maid
	end
}