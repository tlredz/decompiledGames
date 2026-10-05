local createVector = vector.create
require(script.Parent.Util)
local Worldspace = require(script.Parent.Worldspace)
local Viewport = {}

local function CreateViewport()
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Ambient = Color3.new(1, 1, 1)
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	viewportFrame.LightDirection = createVector(0, 2, 0)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	local camera = Instance.new("Camera")
	camera.FieldOfView = 5
	camera.CFrame = CFrame.new(0, 400, 0) * CFrame.fromOrientation(-1.5707963267948966, -1.5707963267948966, 0)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	return viewportFrame
end

local v = {
	Size = function(p)
		p.Instance.Size = p.Size
	end,
	Position = function(p)
		p.Instance.Position = p.Position
	end,
	Zoom = function(p)
		p.Instance.CurrentCamera.FieldOfView = p.Zoom
	end,
	Color = function(p)
		p.Instance.ImageColor3 = p.Color
	end,
	Transparency = function(p)
		p.Instance.ImageTransparency = p.Transparency
	end,
	Parent = function(state)
		if state.Parent == nil and state._InitializeParent == true then
			state._ScreenGui = Instance.new("ScreenGui")
			state._ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
			state._ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			state._ScreenGui.Name = "CircularProgress"
			state.Instance.Parent = state._ScreenGui
			state.Parent = state._ScreenGui
			state._InitializeParent = false
		else
			if state.Instance.Parent == state._ScreenGui then
				state.Instance.Parent = nil
				state._ScreenGui:Destroy()
			end

			state.Instance.Parent = state.Parent
		end
	end
}

function Viewport.new(items)
	local v2 = {
		_WorldspaceCircle = Worldspace.new(),
		Size = UDim2.fromScale(0.4, 0.4),
		Position = UDim2.fromScale(0, 0),
		Zoom = 5,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0,
		Parent = nil
	}

	if items then
		for k, item in pairs(items) do
			v2[k] = item
		end
	end

	v2._ScreenGui = true
	v2._WorldspaceCircle.Parent = CreateViewport(v2)
	v2.Instance = v2._WorldspaceCircle.Parent

	for _, v3 in pairs(v) do
		v3(v2)
	end

	return (setmetatable({}, {
		__index = function(_, p, _)
			if v2[p] ~= nil then
				return v2[p]
			end

			if Viewport[p] ~= nil then
				return Viewport[p]
			end

			if v2._WorldspaceCircle[p] == nil then
				return
			else
				return v2._WorldspaceCircle[p]
			end
		end,
		__newindex = function(_, p, p2)
			if v2[p] == p2 then
				return
			end

			if v[p] then
				v2[p] = p2
				v[p](v2)
			elseif v2._WorldspaceCircle[p] ~= nil then
				v2[p] = p2
				v2._WorldspaceCircle[p] = p2
			end
		end
	}))
end

function Viewport.fromWorldspace(p)
	return Worldspace.new(p)
end

function Viewport:Tween(p2, p3)
	self._TweenService:Tween(p2, p3)
end

function Viewport:Destroy()
	self.Instance:Destroy()
	self._WorldspaceCircle:Destroy()
	setmetatable(self, nil)
end

return Viewport