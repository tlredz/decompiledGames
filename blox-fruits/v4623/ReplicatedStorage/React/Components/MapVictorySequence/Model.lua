local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local TemplateCopy = require(game.ReplicatedStorage.React.Components.MapVictorySequence.TemplateCopy)
local createElement = React.createElement
return React.forwardRef(function(props, _)
	local ref = React.useRef(nil)
	local current = ref.current
	React.useEffect(function()
		if not (current and props.ResetPivot) then
			return function() end
		end

		local boundingBox = current:GetBoundingBox()
		local v = current.WorldPivot:Inverse() * boundingBox
		pcall(function()
			current.WorldPivot = boundingBox
		end)
		return function()
			pcall(function()
				current.WorldPivot *= v
			end)
		end
	end, { current, props.ResetPivot })

	if current and props.Template then
		pcall(function()
			local scale = props.Scale or props.Template:GetScale()

			if scale ~= current:GetScale() then
				current:ScaleTo(scale)
			end
		end)
		pcall(function()
			local cFrame = props.CFrame or props.Template:GetPivot()

			if cFrame ~= current:GetPivot() then
				current:PivotTo(cFrame)
			end
		end)
	end

	local mergeInstance = RobloxTypes.mergeInstance({}, props)
	mergeInstance.Template = props.Template
	mergeInstance.ref = ref
	return createElement(TemplateCopy, mergeInstance, {})
end)