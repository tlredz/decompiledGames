local React = require(script.Parent.Parent.React)
local Collections = require(script.Parent.Parent.Collections)
local ErrorBoundaryContext = require(script.Parent.ErrorBoundaryContext)
require(script.Parent.types)
local frozen = table.freeze({
	didCatch = false,
	error = nil
})
local frozen2 = table.freeze({
	didCatch = false,
	error = React.None
})

local function hasArrayChanged(resetKeys, resetKeys2)
	local v = resetKeys or {}
	local v2 = resetKeys2 or {}

	if v and v2 then
		return #v ~= #v2 or Collections.Array.some(v, function(p, p2)
			return not Collections.Object.is(p, v2[p2])
		end)
	end

	return false
end

local extended = React.Component:extend("ErrorBoundary")

function extended:init()
	self.state = frozen

	function self.resetErrorBoundary(...)
		local args = { ... }

		if self.state.error then
			if self.props.onReset then
				self.props.onReset({
					args = args,
					reason = "imperative-api"
				})
			end

			self:setState(frozen2)
		end
	end
end

function extended.getDerivedStateFromError(error)
	return {
		didCatch = true,
		error = error
	}
end

function extended.componentDidCatch(p, p2, p3)
	if p.props.onError then
		p.props.onError(p2, p3)
	end
end

function extended.componentDidUpdate(object, p, p2)
	local didCatch = object.state.didCatch
	local resetKeys = object.props.resetKeys

	if didCatch and p2.error and hasArrayChanged(p.resetKeys, resetKeys) then
		if object.props.onReset then
			object.props.onReset({
				next = resetKeys,
				prev = p.resetKeys,
				reason = "keys"
			})
		end

		object:setState(frozen2)
	end
end

function extended.render(props)
	local children = props.props.children
	local fallbackRender = props.props.fallbackRender
	local fallbackComponent = props.props.FallbackComponent
	local fallback = props.props.fallback
	local didCatch = props.state.didCatch
	local error = props.state.error

	if didCatch then
		local frozen3 = table.freeze({
			error = error,
			resetErrorBoundary = props.resetErrorBoundary
		})

		if fallback and React.isValidElement(fallback) then
			children = fallback
		elseif typeof(fallbackRender) == "function" then
			children = fallbackRender(frozen3)
		elseif fallbackComponent then
			children = React.createElement(fallbackComponent, frozen3)
		else
			error("react-error-boundary requires either a fallback, fallbackRender, or FallbackComponent prop")
		end
	end

	return React.createElement(ErrorBoundaryContext.Provider, {
		value = {
			didCatch = didCatch,
			error = error,
			resetErrorBoundary = props.resetErrorBoundary
		}
	}, children)
end

return extended