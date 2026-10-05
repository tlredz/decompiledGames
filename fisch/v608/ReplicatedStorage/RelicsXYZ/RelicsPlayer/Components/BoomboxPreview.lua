local createVector = vector.create
local parent = script.Parent.Parent
require(parent.State)
local shared = parent.Parent.Shared
local components = parent.Components
local View3D = require(components.View3D)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local useSignal = require(hooks.useSignal)
local useUgcSkins = require(hooks.useUgcSkins)
local useStyleSheet = require(hooks.useStyleSheet)
local useBoomboxData = require(hooks.useBoomboxData)
local React = require(shared.React)

local function BoomboxPreview(props)
	local v = useStyleSheet("Icons", "string")
	local v2 = useBoomboxData()
	local v3 = useUgcSkins()[props.Skin or "Default"]
	local state, setState = React.useState(v3 and v3.TextureId)
	local state2, setState2 = React.useState(v3 and v3.Accessory)
	local state3, setState3 = React.useState(v3 and v3.RenderOffset)
	local state4, setState4 = React.useState(v3 and v3.RenderZoomScale)
	local state5, setState5 = React.useState(nil)
	local state6, setState6 = React.useState(nil)
	local v4 = React.useState(function()
		return math.random() * 3.141592653589793 * 2
	end)
	React.useEffect(function()
		if v2 then
			if state5 and state5 ~= v2.Model then
				state5:Destroy()
			end

			setState5(v2.Model)
		end
	end, { v2 })
	React.useEffect(function()
		if state6 then
			return function()
				state6:Destroy()
			end
		end
	end, { state6 })
	React.useEffect(function()
		if not (state5 and v3) then
			setState6(nil)
		elseif v3.Accessory then
			local model = Instance.new("Model")
			local meshPart = v3.Accessory:FindFirstChildWhichIsA("MeshPart")

			if meshPart then
				local clone = meshPart:Clone()
				clone.Name = "Handle"
				clone.Parent = model
				model.PrimaryPart = clone
			end

			setState6(model)
		else
			setState6((state5:Clone()))
		end
	end, { state5, state2, v3 })
	useSignal(v3 and v3.Changed, function(p)
		if p == "Accessory" then
			local accessory = v3 and v3.Accessory
			setState2(accessory)
		elseif p == "TextureId" then
			local textureId = v3 and v3.TextureId
			setState(textureId)
		elseif p == "RenderOffset" then
			local renderOffset = v3 and v3.RenderOffset
			setState3(renderOffset)
		elseif p == "RenderZoomScale" then
			local renderZoomScale = v3 and v3.RenderZoomScale
			setState4(renderZoomScale)
		end
	end, { v3 })
	React.useEffect(function()
		if not state6 or state2 then
			return
		end

		local meshPart = state6:FindFirstChildOfClass("MeshPart")

		if not meshPart then
			return
		end

		if state and state > 0 then
			local textureID = meshPart.TextureID

			if not meshPart:GetAttribute("DefaultSkin") then
				meshPart:SetAttribute("DefaultSkin", textureID)
			end

			meshPart.TextureID = `rbxassetid://{state}`
		else
			local defaultSkin = meshPart:GetAttribute("DefaultSkin")

			if type(defaultSkin) == "string" then
				meshPart.TextureID = defaultSkin
			else
				meshPart:SetAttribute("DefaultSkin", meshPart.TextureID)
			end
		end
	end, { state6, state2, state })
	useClock(30, function()
		if state6 then
			local v5 = (os.clock() + v4) % 6.283185307179586
			local cframe = CFrame.Angles(0, v5 + 3.141592653589793, 0)
			local primaryPart = state3 and state6.PrimaryPart

			if primaryPart then
				primaryPart.PivotOffset = state3
			end

			state6:PivotTo(cframe)
		end
	end, { state6, state3 })
	local createElement = React.createElement
	local v6 = {
		Model = state6,
		FieldOfView = 5,
		ZoomScale = state4 or props.ZoomScale or 1.2,
		ZIndex = props.ZIndex,
		UseSkybox = true,
		SkyboxImg = props.SkyboxImg or v("Image-Background"),
		Size = 0,
		Position = 0,
		AnchorPoint = 0,
		Ambient = 0,
		LightColor = 0,
		LightDirection = createVector(0.5, 0, 1),
		EdgeColor = 0,
		TintColor = 0,
		Transparency = 0.1,
		BackgroundTransparency = 0
	}
	local size

	if props.ViewportScale then
		size = UDim2.fromScale(props.ViewportScale, props.ViewportScale)
	else
		size = props.Size
	end

	v6.Size = size
	v6.Position = UDim2.fromScale(0.5, 0.5)
	v6.AnchorPoint = Vector2.new(0.5, 0.5)
	v6.Ambient = Color3.new(0.75, 0.7, 0.75)
	v6.LightColor = Color3.new(1, 1, 1)
	v6.EdgeColor = Color3.fromHex("#c592af")
	v6.TintColor = Color3.fromHex("#ffffff")
	v6.BackgroundTransparency = props.BackgroundTransparency
	return createElement(View3D, v6, {
		Aspect = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1
		})
	})
end

return BoomboxPreview