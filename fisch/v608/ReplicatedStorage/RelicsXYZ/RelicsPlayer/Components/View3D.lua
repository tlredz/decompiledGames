local createVector = vector.create
local parent = script.Parent.Parent
local hooks = parent.Hooks
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
local ReactRoblox = require(shared.ReactRoblox)
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local useAttribute = require(hooks.useAttribute)
local useSignal = require(hooks.useSignal)
local useClock = require(hooks.useClock)
local useLayoutEffect = React.useLayoutEffect
local useEffect = React.useEffect
local useRef = React.useRef
local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local function isInsideAccessory(descendant, instance)
	local parent2 = descendant.Parent

	while parent2 and parent2 ~= instance do
		if parent2:IsA("Accessory") then
			return true
		else
			parent2 = parent2.Parent
		end
	end

	return false
end

local function getPivotTarget(model)
	if model:IsA("WorldModel") then
		return model:FindFirstChildWhichIsA("Model") or model:FindFirstChildWhichIsA("BasePart", true)
	end

	if model:IsA("Model") or model:IsA("BasePart") then
		return model
	end

	return nil
end

local function getAbsoluteExtents(model)
	if model:IsA("Model") then
		local v = 1e999
		local v2 = 1e999
		local v3 = 1e999
		local v4 = -1e999
		local v5 = -1e999
		local v6 = -1e999

		for _, descendant in model:GetDescendants() do
			if isInsideAccessory(descendant, model) then
				continue
			end

			if descendant:IsA("BasePart") then
				local halfSize = descendant.Size / 2
				local cFrame = descendant.CFrame
				local v8 = { cFrame:PointToWorldSpace(-halfSize), cFrame:PointToWorldSpace(halfSize) }

				for _, v9 in ipairs(v8) do
					v = math.min(v, v9.X)
					v2 = math.min(v2, v9.Y)
					v3 = math.min(v3, v9.Z)
					v4 = math.max(v4, v9.X)
					v5 = math.max(v5, v9.Y)
					v6 = math.max(v6, v9.Z)
				end
			elseif descendant:IsA("Attachment") then
				local worldPosition = descendant.WorldPosition
				v = math.min(v, worldPosition.X)
				v2 = math.min(v2, worldPosition.Y)
				v3 = math.min(v3, worldPosition.Z)
				v4 = math.max(v4, worldPosition.X)
				v5 = math.max(v5, worldPosition.Y)
				v6 = math.max(v6, worldPosition.Z)
			end
		end

		if v == 1e999 then
			return createVector(0, 0, 0)
		end

		return (Vector3.new(v4 - v, v5 - v2, v6 - v3))
	else
		if not model:IsA("BasePart") or model:FindFirstAncestorWhichIsA("Accessory") then
			return createVector(0, 0, 0)
		end

		return model.Size
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDepthForWidth(viewportSize: Vector2, fieldOfView: number, p: number, p2: number?)
	local v = viewportSize.X / viewportSize.Y

	if v ~= v then
		return 0
	end

	local v2 = math.max(1, viewportSize.X)
	local v3 = p2 or math.max(1, viewportSize.Y)
	local v4 = v * math.tan(math.rad(fieldOfView) / 2)
	return -(v2 * -0.5 * p / (v3 * v4))
end

local function View3D(data)
	local model = data.Model
	local ref = useRef(nil)
	local v2 = useRef(nil)
	local viewportRef = useRef(nil)
	local viewOffset = data.ViewOffset or CFrame.identity

	if data.ViewportRef then
		viewportRef = data.ViewportRef
	end

	local v3 = useAttribute(model, "ZoomScale", function(value)
		return typeof(value) == "number" and value or nil
	end) or data.ZoomScale or 1
	local ambient = useAttribute(model, "Ambient", function(p)
		return typeof(p) == "Color3" and p or nil
	end) or data.Ambient
	useEffect(function()
		local v5 = model and getPivotTarget(model)

		if v5 then
			v5:PivotTo(viewOffset)
		end
	end, { model, viewOffset })
	local fieldOfView = data.FieldOfView or 70
	local modelSize = data.ModelSize
	local state, setState = React.useState(createVector(0, 0, 0))
	local state2, setState2 = React.useState(0)
	local v5 = useRef(1)

	local function requestSizeRecalc(...)
		setState2(function(p)
			return p + 1
		end)
	end

	useSignal(model and model.DescendantAdded, requestSizeRecalc)
	useSignal(model and model.DescendantRemoving, requestSizeRecalc)
	useLayoutEffect(function()
		local current = viewportRef.current
		local current2 = ref.current

		if model then
			local v6 = model

			if data.RenderInWorld then
				current = current2 or current
			end

			v6.Parent = current
		end

		return function()
			if model then
				model.Parent = nil
			end
		end
	end, { model, data.RenderInWorld })
	useEffect(function()
		local v6

		if modelSize then
			v6 = modelSize
		elseif model then
			if model:IsA("WorldModel") or model:IsA("Model") then
				v6 = getAbsoluteExtents(model)
			else
				v6 = not model:IsA("BasePart") and createVector(0, 0, 0) or model.Size
			end
		else
			v6 = createVector(0, 0, 0)
		end

		setState(v6)
	end, { model, modelSize, state2 })
	React.useEffect(function()
		if not (model and data.RenderInWorld) then
			return
		end

		local currentCamera = workspace.CurrentCamera
		local GUID = HttpService:GenerateGUID(false)
		RunService:BindToRenderStep(GUID, 1000, function()
			local current = viewportRef.current

			if not current then
				return
			end

			local absoluteSize = current.AbsoluteSize
			local v6 = current.AbsolutePosition + absoluteSize / 2
			local v7 = math.max(state.X, state.Y, state.Z)

			if v7 <= 0 then
				return
			end

			local v8 = math.min(absoluteSize.X, absoluteSize.Y)
			local viewportSize = currentCamera.ViewportSize
			local v9 = viewportSize.X / viewportSize.Y
			local v10 = math.abs(v6.X / viewportSize.X - 0.5) * 2
			local v11 = 1 + (v9 - 1) * v10
			local depthForWidth = getDepthForWidth(currentCamera.ViewportSize, currentCamera.FieldOfView, v7, v8) -- equivalent call inferred; original call site unknown
			local v12 = depthForWidth * v3 * v11
			local screenPointToRay = currentCamera:ScreenPointToRay(v6.X, v6.Y, v12)
			local v13 = CFrame.lookAlong(
				screenPointToRay.Origin,
				screenPointToRay.Direction,
				currentCamera.CFrame.UpVector
			) * CFrame.Angles(0, 3.141592653589793, 0)
			local pivotTarget = getPivotTarget(model)

			if pivotTarget then
				pivotTarget:PivotTo(v13)
			end
		end)
		return function()
			RunService:UnbindFromRenderStep(GUID)
		end
	end, {
		model,
		data.RenderInWorld,
		state,
		v3
	})
	useClock(30, function()
		local current = v2.current
		local current2 = viewportRef.current

		if not (current and model and current2) then
			return
		end

		if model:IsA("Model") or model:IsA("WorldModel") then
			local scale = model:GetScale()

			if scale ~= v5.current then
				v5.current = scale
				requestSizeRecalc()
			end
		end

		local v6 = math.max(state.X, state.Y, state.Z)

		if v6 <= 0 then
			return
		end

		local absoluteSize = current2.AbsoluteSize
		local v7 = fieldOfView
		local v8 = absoluteSize.X / absoluteSize.Y
		local v9

		if v8 == v8 then
			local v10 = math.max(1, absoluteSize.X)
			local v11 = math.max(1, absoluteSize.Y)
			local v12 = v8 * math.tan(math.rad(v7) / 2)
			v9 = -(v10 * -0.5 * v6 / (v11 * v12))
		else
			v9 = 0
		end

		if not math.isfinite(v9) or v9 <= 0 then
			return
		end

		current.CFrame = cframe - cframe.LookVector * v9 * v3
	end, {
		model,
		v3,
		state,
		fieldOfView
	})
	return React.createElement("ViewportFrame", {
		[React.Tag] = Util.ClassNames("View3d", data[React.Tag]),
		Ambient = ambient,
		LightColor = data.LightColor,
		BackgroundColor3 = data.EdgeColor,
		BackgroundTransparency = data.BackgroundTransparency or 0,
		LightDirection = data.LightDirection,
		Size = data.Size,
		ImageTransparency = data.Transparency,
		CurrentCamera = v2,
		AnchorPoint = data.AnchorPoint,
		LayoutOrder = data.LayoutOrder,
		ImageColor3 = data.TintColor,
		Position = data.Position,
		ZIndex = data.ZIndex,
		ref = viewportRef
	}, {
		Camera = React.createElement("Camera", {
			FieldOfView = data.FieldOfView,
			ref = v2
		}),
		Portal = data.RenderInWorld and ReactRoblox.createPortal({
			Render = React.createElement("Folder", {
				Archivable = false,
				ref = ref
			})
		}, workspace.CurrentCamera),
		Sky = data.UseSkybox and React.createElement("Sky", {
			SkyboxUp = data.SkyboxUp or data.SkyboxImg,
			SkyboxDn = data.SkyboxDn or data.SkyboxImg,
			SkyboxLf = data.SkyboxLf or data.SkyboxImg,
			SkyboxRt = data.SkyboxRt or data.SkyboxImg,
			SkyboxFt = data.SkyboxFt or data.SkyboxImg,
			SkyboxBk = data.SkyboxBk or data.SkyboxImg
		})
	}, data.children)
end

return React.memo(View3D)