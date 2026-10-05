local BufferManager = {}
BufferManager.__index = BufferManager

function BufferManager.new(createFunc)
	local self = setmetatable({
		pool = {},
		createFunc = createFunc
	}, BufferManager)

	if not script:FindFirstChild("Cache") then
		local folder = Instance.new("Folder")
		folder.Name = "Cache"
		folder.Parent = script
	end

	return self
end

function BufferManager.get(p)
	if #p.pool > 0 then
		return table.remove(p.pool)
	end

	return p.createFunc()
end

function BufferManager.release(p, p2)
	table.insert(p.pool, p2)
	p2.Parent = script.Cache
end

return BufferManager