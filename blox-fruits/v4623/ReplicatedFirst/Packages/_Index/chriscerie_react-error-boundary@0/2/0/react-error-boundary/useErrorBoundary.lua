local React = require(script.Parent.Parent.React)
local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)
local assertErrorBoundaryContext = require(script.Parent.assertErrorBoundaryContext)

local function useErrorBoundary()
	local v = assertErrorBoundaryContext(React.useContext(ErrorBoundaryContext))
	local state, setState = React.useState({
		error = nil,
		hasError = false
	})
	local v2 = React.useMemo(function()
		return table.freeze({
			resetBoundary = function()
				v.resetErrorBoundary()
				setState({
					hasError = false
				})
			end,
			showBoundary = function(error2)
				setState({
					error = error2,
					hasError = true
				})
			end
		})
	end, { v, v.resetErrorBoundary })

	if state.hasError then
		error(state.error)
	end

	return v2
end

return useErrorBoundary