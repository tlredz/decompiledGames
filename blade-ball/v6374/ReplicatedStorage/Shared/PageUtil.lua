local PageUtil = {
	FirstItem = function(object)
		return object:GetCurrentPage()[1]
	end,
	PagesToTable = function(object)
		local currentPages = {}

		while true do
			table.insert(currentPages, object:GetCurrentPage())

			if object.IsFinished then
				break
			end

			object:AdvanceToNextPageAsync()
		end

		return currentPages
	end
}

function PageUtil.IterPageItems(p)
	local pagesToTable = PageUtil.PagesToTable(p)
	local v = 1
	local count = #pagesToTable
	return coroutine.wrap(function()
		while v <= count do
			for _, v2 in ipairs(pagesToTable[v]) do
				coroutine.yield(v2, v)
			end

			v += 1
		end
	end)
end

return PageUtil