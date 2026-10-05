local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local TemplateCopy = require(game.ReplicatedStorage.React.Components.MapVictorySequence.TemplateCopy)
local createElement = React.createElement
return React.forwardRef(function(props, _)
	local ref = React.useRef(nil)
	local current = ref.current
	local ref2 = React.useRef(props.Template)
	ref2.current = props.Template
	React.useEffect(function()
		if current and props.ResetPivot then
			local pivotOffset = current.PivotOffset
			current.PivotOffset = CFrame.new(0, 0, 0)
			return function()
				pcall(function()
					current.PivotOffset = pivotOffset
				end)
			end
		else
			if current and ref2.current then
				pcall(function()
					current.PivotOffset = ref2.current.PivotOffset
				end)
			end

			return function() end
		end
	end, { current, props.ResetPivot })

	if current and props.Template then
		pcall(function()
			local size = (props.Size or props.Template.Size) * (props.Scale or 1)

			if current.Size ~= size and size then
				current.Size = size
			end
		end)
		pcall(function()
			local cFrame = props.CFrame or props.Template.CFrame

			if current.CFrame ~= cFrame then
				current.CFrame = cFrame
			end
		end)
		pcall(function()
			local material = props.Material or props.Template.Material

			if current.Material ~= material and material then
				current.Material = material
			end
		end)
		pcall(function()
			local transparency = props.Transparency or props.Template.Transparency

			if current.Transparency ~= transparency and transparency then
				current.Transparency = transparency
			end
		end)
	end

	local mergeInstance = RobloxTypes.mergeInstance({}, props)
	mergeInstance.Template = props.Template
	mergeInstance.ref = ref
	return createElement(TemplateCopy, mergeInstance, {})
end)