local React = require(script.Parent.Parent.React)
local Sift = require(script.Parent.Parent.Sift)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
require(script.Parent.types)

local function withErrorBoundary(p, p2)
	return (React.forwardRef(function(p3, ref)
		return React.createElement(ErrorBoundary, p2, {
			component = React.createElement(p, Sift.Dictionary.merge(p3, {
				ref = ref
			}))
		})
	end))
end

return withErrorBoundary