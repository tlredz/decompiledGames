for _, child in script:GetChildren() do
	task.defer(pcall, require, child)
end

return nil