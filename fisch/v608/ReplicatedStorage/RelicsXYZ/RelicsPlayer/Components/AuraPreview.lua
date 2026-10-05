local parent = script.Parent.Parent
local parent2 = parent.Parent
local components = parent.Components
local View3D = require(components.View3D)
local hooks = parent.Hooks
local useAuras = require(hooks.useAuras)
local useAuraSetup = require(hooks.useAuraSetup)
local shared = parent2.Shared
local React = require(shared.React)

local function AuraPreview(props)
	local v = useAuras()
	local state, setState = React.useState(nil)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local effect = props.Effect

		if not effect then
			local v2 = v[props.Aura or ""]

			if v2 then
				local effect2 = v2.Effect

				if effect2 then
					effect = effect2:Clone()
				end
			end
		end

		setState(effect or nil)
	end, { v, props.Aura, props.Effect })
	local model = useAuraSetup(state, nil, ref, 0.03)
	return React.createElement(View3D, {
		Model = model,
		RenderInWorld = true,
		ZoomScale = 1,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		ZIndex = props.ZIndex or 1,
		ViewportRef = ref
	})
end

return AuraPreview