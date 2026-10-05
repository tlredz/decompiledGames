local v = {
	run = game:GetService("RunService"),
	players = game:GetService("Players"),
	gui = game:GetService("GuiService"),
	light = game:GetService("Lighting")
}
local modules = script.Parent:WaitForChild("Modules")
local rooms = script.Parent.Parent:WaitForChild("Rooms")
local Utilities = require(modules:WaitForChild("Utilities"))
require(modules:WaitForChild("Types"))
local localPlayer = v.players.LocalPlayer
local cframe = CFrame.fromEulerAnglesXYZ(0, 3.141592653589793, 0)
local MainModule = {}
MainModule.__index = MainModule
local class = {}
class.__index = class

function MainModule.Setup(maxRadius: number, childName: string?)
	assert(typeof(maxRadius) == "number", "radius must be a number.")
	assert(typeof(childName) == "string" or not childName, "roomsType must be a string or nil.")
	local object = setmetatable({}, MainModule)
	object.Disconnect = Instance.new("BindableEvent")
	object.MaxRadius = maxRadius

	if childName then
		local child = rooms:FindFirstChild(childName)
		assert(child, "Invalid rooms type: ", childName)
		object.Rooms = child:GetChildren()
	else
		object.Rooms = {}

		for _, model in pairs(rooms:GetDescendants()) do
			if model:IsA("Model") then
				table.insert(rooms, model)
			end
		end
	end

	local function renderFrame()
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local bases = {}

		for _, window in pairs(object.Windows) do
			table.insert(bases, window.Base)
		end

		local cFrame = currentCamera.CFrame
		local v2 = {}

		for _, v3 in bases do
			if (v3.Position - cFrame.Position).Magnitude < object.MaxRadius then
				table.insert(v2, v3)
			end
		end

		if not v2 then
			return
		end

		for _, window in pairs(object.Windows) do
			if not window.Running then
				continue
			end

			local base = window.Base
			local camera = window.Camera

			if base and camera then
				if table.find(v2, base) then
					local magnitude = (base.Position - cFrame.Position).Magnitude

					if object.MaxRadius - 1 <= magnitude then
						window.Gui.Enabled = false
					else
						local surfaceInfo, v3 = Utilities.getSurfaceInfo(base)
						local objectSpace = surfaceInfo:ToObjectSpace(cFrame)

						if objectSpace.Z > 0 then
							window.Gui.Enabled = false
						else
							local worldToScreenPoint, cframe2 = Utilities.worldToScreenPoint(currentCamera, surfaceInfo)

							if math.abs((math.deg(Vector3.new(cframe2:ToOrientation()).Y))) < 1500 / currentCamera.FieldOfView + 18 then
								window.Gui.Enabled = false
							else
								local worldToScreenSize = Utilities.worldToScreenSize(
									currentCamera,
									surfaceInfo.Position,
									v3.Magnitude
								)

								if Utilities.isCircleVisible(worldToScreenPoint, worldToScreenSize / 2, currentCamera) then
									window.Viewport.ImageTransparency = Utilities.lerp(
										magnitude / (object.MaxRadius - 1),
										1,
										window.Visibility
									)
									window.Gui.Enabled = true
									local roomOrigin = window.RoomOrigin
									local v4 = roomOrigin * cframe * objectSpace
									local camData = Utilities.computeCamData(v4, roomOrigin * cframe, v3, currentCamera)

									for k, v5 in pairs(camData) do
										camera[k] = v5
									end
								else
									window.Gui.Enabled = false
								end
							end
						end
					end
				end
			else
				local index = table.find(object.Windows, base)

				if index then
					table.remove(object.Windows, index)
				end
			end
		end
	end

	object.Windows = {}

	if workspace.CurrentCamera then
		object.MainRunner = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(renderFrame)
	end

	object.SecondaryRunner = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if workspace.CurrentCamera then
			object.MainRunner = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(renderFrame)
		else
			object.MainRunner:Disconnect()
		end
	end)
	return object
end

function MainModule.AddWindow(data, p, value: number?)
	local ambient = v.light.Ambient
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Parent = localPlayer.PlayerGui
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Adornee = p
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = value or 1024
	surfaceGui.ClipsDescendants = true
	surfaceGui.LightInfluence = 0
	surfaceGui.MaxDistance = data.MaxRadius
	local camera = Instance.new("Camera")
	camera.Parent = surfaceGui
	camera.CameraType = Enum.CameraType.Scriptable
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Parent = surfaceGui
	viewportFrame.CurrentCamera = camera
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.Position = UDim2.fromScale(0, 0)
	viewportFrame.AnchorPoint = Vector2.zero
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.ImageTransparency = 1
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	viewportFrame.LightDirection = -v.light:GetSunDirection()
	viewportFrame.Ambient = Color3.new((ambient.R + 1) / 2, (ambient.G + 1) / 2, (ambient.B + 1) / 2)
	local clone = nil
	local v2 = {}

	for _, room in data.Rooms do
		if room.Name == p.Name then
			clone = room:Clone()
		end
	end

	if not clone then
		warn((`{p.Name} room does not exist`))
		return
	end

	clone.Parent = viewportFrame
	v2.Camera = camera
	v2.Base = p
	v2.RoomOrigin = clone.PrimaryPart.CFrame
	v2.Viewport = viewportFrame
	v2.Running = true
	v2.Visibility = 0
	v2.Gui = surfaceGui
	clone.PrimaryPart:Destroy()
	table.insert(data.Windows, v2)
	local object = setmetatable({}, class)
	object.connections = {}
	object._data = v2
	object.self = data
	table.insert(object.connections, v.light.LightingChanged:Connect(function(p2)
		if p2 then
			return
		end

		local ambient2 = v.light.Ambient
		viewportFrame.LightDirection = -v.light:GetSunDirection()
		viewportFrame.Ambient = Color3.new((ambient2.R + 1) / 2, (ambient2.G + 1) / 2, (ambient2.B + 1) / 2)
	end))
	return object
end

function class:ToggleRunning(running: boolean?)
	if typeof(running) ~= "boolean" then
		running = not self._data.Running
	end

	self._data.Running = running
end

function class.ToggleVisible(p, visible: boolean?)
	if not p.Viewport then
		return
	end

	if typeof(visible) ~= "boolean" then
		visible = not p.Viewport.Visible
	end

	p.Viewport.Visible = visible
end

function class:SetTransparency(visibility: number)
	assert(typeof(visibility) == "number", "amnt must be a number.")
	self._data.Visibility = visibility
	self._data.Gui.LightInfluence = visibility / 2
	self._data.Gui.Brightness = (1 - visibility) * 10
end

function class:Disconnect()
	if self._data.Gui then
		self._data.Gui:Destroy()
	end

	pcall(function()
		if not self.self.Windows then
			return
		end

		local index = table.find(self.self.Windows, self._data)
		table.remove(self.self.Windows, index)
	end)
	pcall(function()
		for _, connection in pairs(self.connections) do
			connection:Disconnect()
		end
	end)
end

function MainModule:RunOnAll(callback, ...)
	for _, window in pairs(self.Windows) do
		callback({
			_data = window,
			self = self
		}, ...)
	end
end

function MainModule:Disconnect()
	if not self.MainRunner.Connected then
		return
	end

	self.MainRunner:Disconnect()
	self.SecondaryRunner:Disconnect()
	self.Disconnect:Fire()
end

function MainModule:ChangeMaxRadius(p: number)
	self.MaxRadius = p
	self:RunOnAll(function(p2)
		p2._data.Gui.MaxDistance = p
	end)
end

function MainModule:ToggleAllRunning(flag: boolean?)
	self:RunOnAll(class.ToggleRunning, flag)
end

function MainModule:ToggleAllVisible(flag: boolean?)
	self:RunOnAll(class.ToggleVisible, flag)
end

function MainModule:SetAllTransparency(p: number)
	self:RunOnAll(class.SetTransparency, p)
end

function MainModule:DisconnectWindows()
	self:RunOnAll(class.Disconnect)
end

return MainModule