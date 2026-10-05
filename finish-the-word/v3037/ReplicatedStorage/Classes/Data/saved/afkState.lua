local import = _G.import("class")
local import2 = _G.import("modelUtil")
local v = import.new()

function v:new()
	self.AfkRewards = {
		_Insertable = true
	}
end

function v:postShell()
	import2.getAttribute(workspace, "Mode"):andThen(function(p2)
		if p2 == "AFK" then
			return
		end

		self.AfkRewards = {}
	end)
end

return v