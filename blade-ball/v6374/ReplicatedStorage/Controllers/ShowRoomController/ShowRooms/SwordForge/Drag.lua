local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local Drag = {}
local v = nil
local v2 = false
local v3 = {}
local v4 = {}
local arcHandles = nil
local v5 = "Move"
local part = Instance.new("Part")
part.Name = "_drag_fake_part"
part.Transparency = 1
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Parent = workspace.CurrentCamera

local function clear()
	for _, v6 in v3 do
		v6:Destroy()
	end

	for _, v6 in v4 do
		v6:Destroy()
	end

	if arcHandles then
		arcHandles:Destroy()
	end

	v3 = {}
	v4 = {}
	arcHandles = nil
end

local function createMoveHandle(_, faces, color, _)
	local handles = Instance.new("Handles")
	handles.Adornee = part
	handles.Style = Enum.HandlesStyle.Movement
	handles.Faces = faces
	handles.Color3 = color
	handles.Parent = playerGui
	local cFrame = nil
	handles.MouseButton1Down:Connect(function(_)
		cFrame = v.CFrame
	end)
	handles.MouseDrag:Connect(function(p, p2)
		if not v then
			return
		end

		if v2 then
			v.CFrame = cFrame + Vector3.FromNormalId(p) * p2
		else
			v.CFrame = cFrame * CFrame.new(Vector3.FromNormalId(p) * p2)
		end
	end)
	handles.MouseButton1Up:Connect(function(_)
		cFrame = nil
	end)
	return handles
end

local function createScaleHandle(_, faces, color, _)
	local handles = Instance.new("Handles")
	handles.Adornee = part
	handles.Style = Enum.HandlesStyle.Resize
	handles.Faces = faces
	handles.Color3 = color
	handles.Parent = playerGui
	local size = nil
	handles.MouseButton1Down:Connect(function(_)
		size = v.Size
	end)
	handles.MouseDrag:Connect(function(p, p2)
		if v then
			local v6 = size + Vector3.FromNormalId(p):Abs() * p2
			v.Size = Vector3.new(math.max(0.1, v6.X), math.max(0.1, v6.Y), (math.max(0.1, v6.Z)))
		end
	end)
	handles.MouseButton1Up:Connect(function(_)
		size = nil
	end)
	return handles
end

local preRenderConnection = nil

function Drag.attach(p)
	if preRenderConnection and preRenderConnection.Connected then
		preRenderConnection:Disconnect()
	end

	preRenderConnection = RunService.PreRender:Connect(function()
		if v then
			part.Size = v.Size
			local v6 = part
			local cFrame2

			if v2 then
				cFrame2 = CFrame.new(v.Position)
			else
				cFrame2 = v.CFrame
			end

			v6.CFrame = cFrame2
		end
	end)
	v = p
	clear()
	part.Size = v.Size
	local v6 = part
	local cFrame3

	if v2 then
		cFrame3 = CFrame.new(v.Position)
	else
		cFrame3 = v.CFrame
	end

	v6.CFrame = cFrame3
	table.insert(
		v3,
		(createMoveHandle(p, Faces.new(Enum.NormalId.Left, Enum.NormalId.Right), Color3.new(1, 0, 0), "X"))
	)
	table.insert(
		v3,
		(createMoveHandle(p, Faces.new(Enum.NormalId.Top, Enum.NormalId.Bottom), Color3.new(0, 1, 0), "Y"))
	)
	table.insert(
		v3,
		(createMoveHandle(p, Faces.new(Enum.NormalId.Front, Enum.NormalId.Back), Color3.new(0, 0, 1), "Z"))
	)
	table.insert(
		v4,
		(createScaleHandle(p, Faces.new(Enum.NormalId.Left, Enum.NormalId.Right), Color3.new(1, 0.5, 0.5), "X"))
	)
	table.insert(
		v4,
		(createScaleHandle(p, Faces.new(Enum.NormalId.Top, Enum.NormalId.Bottom), Color3.new(0.5, 1, 0.5), "Y"))
	)
	table.insert(
		v4,
		(createScaleHandle(p, Faces.new(Enum.NormalId.Front, Enum.NormalId.Back), Color3.new(0.5, 0.5, 1), "Z"))
	)
	arcHandles = Instance.new("ArcHandles")
	arcHandles.Adornee = part
	arcHandles.Color3 = Color3.fromRGB(255, 170, 0)
	arcHandles.Parent = playerGui
	local cFrame = nil
	arcHandles.MouseButton1Down:Connect(function(_)
		cFrame = v.CFrame
	end)
	arcHandles.MouseDrag:Connect(function(p2, p3)
		if v then
			local v8 = cFrame

			if v2 then
				local position = v8.Position
				local cframe

				if p2 == Enum.Axis.X then
					cframe = CFrame.fromAxisAngle(createVector(1, 0, 0), p3)
				elseif p2 == Enum.Axis.Y then
					cframe = CFrame.fromAxisAngle(createVector(0, 1, 0), p3)
				else
					cframe = CFrame.fromAxisAngle(createVector(0, 0, 1), p3)
				end

				v.CFrame = CFrame.new(position) * cframe * CFrame.new(-position) * v8
			elseif p2 == Enum.Axis.X then
				v.CFrame = v8 * CFrame.Angles(p3, 0, 0)
			elseif p2 == Enum.Axis.Y then
				v.CFrame = v8 * CFrame.Angles(0, p3, 0)
			elseif p2 == Enum.Axis.Z then
				v.CFrame = v8 * CFrame.Angles(0, 0, p3)
			end
		end
	end)
	arcHandles.MouseButton1Up:Connect(function(_)
		cFrame = nil
	end)
	Drag.setMode(v5)
end

function Drag.setMode(p)
	v5 = p

	for _, v6 in v3 do
		v6.Visible = p == "Move"
	end

	for _, v6 in v4 do
		v6.Visible = p == "Scale"
	end

	if arcHandles then
		arcHandles.Visible = p == "Rotate"
	end
end

function Drag.toggleWorld()
	v2 = not v2
end

function Drag.detach()
	clear()
	v = nil

	if preRenderConnection and preRenderConnection.Connected then
		preRenderConnection:Disconnect()
		preRenderConnection = nil
	end
end

return Drag