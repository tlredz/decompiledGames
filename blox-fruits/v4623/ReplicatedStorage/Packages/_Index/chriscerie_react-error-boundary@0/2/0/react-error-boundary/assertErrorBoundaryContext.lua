require(script.Parent.ErrorBoundaryContext)

local function assertErrorBoundaryContext(p)
	if not p or typeof(p.didCatch) ~= "boolean" or typeof(p.resetErrorBoundary) ~= "function" then
		error("ErrorBoundaryContext not found")
	end

	return p
end

return assertErrorBoundaryContext