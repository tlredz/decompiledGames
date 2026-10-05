local Eyedropper = {}
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local UI = require(ReplicatedStorage.Modules.UI)
local Materials = require(ReplicatedStorage.Assets.Data.Materials)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- equivalent calls inferred from this helper; original call sites unknown
local function raycast(origin: Vector3, vector: Vector3, raycastParams)
	local filterDescendantsInstances = raycastParams.FilterDescendantsInstances
	local doRaycast

	doRaycast = function(vector2: Vector3, vector3: Vector3)
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)

		if not raycastResult then
			return nil
		end

		if not raycastResult.Instance or raycastResult.Instance.Transparency ~= 1 then
			return raycastResult
		end

		table.insert(filterDescendantsInstances, raycastResult.Instance)
		local position = raycastResult.Position
		local v = vector3 - (raycastResult.Position - vector2)

		if v.Magnitude > 0 then
			return doRaycast(position, v)
		end

		return raycastResult
	end

	return doRaycast(origin, vector)
end

local function getMaterialName(p)
	local v = p.MaterialVariant:gsub(" ", "")

	if Materials[v] then
		return v
	end

	return p.Material.Name
end

function Eyedropper.new(color: Color3)
	local object = setmetatable({}, {
		__index = Eyedropper
	})
	object.DefaultColor = color
	object.Color = color
	object.ColorUpdated = FastSignal.new()
	object.Clicked = FastSignal.new()
	object.Janitor = Janitor.new()
	object.Janitor:Add(RunService.Heartbeat:Connect(function()
		object:Update()
	end))
	object.Janitor:Add(UserInputService.InputBegan:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			object:Click()
		end
	end))
	object.Highlight = Instance.new("Highlight", script)
	object.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
	object.Highlight.FillTransparency = 0.7
	return object
end

function Eyedropper:GetObject()
	local unitRay = mouse.UnitRay
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	raycastParams.IgnoreWater = true

	if UI:IsMouseOnGui() then
		return nil
	end

	local v2 = raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams) -- equivalent call inferred; original call site unknown
	return v2 and v2.Instance
end

function Eyedropper:Click()
	local object = self:GetObject()

	if object then
		local clicked = self.Clicked
		local color = object.Color
		local name = object.MaterialVariant:gsub(" ", "")

		if not Materials[name] then
			name = object.Material.Name
		end

		clicked:Fire(color, name)
		script.Complete:Play()
	else
		self.Clicked:Fire(self.DefaultColor)
	end

	self:Destroy()
end

function Eyedropper:Update()
	local object2 = self:GetObject()
	local color

	if object2 then
		color = object2.Color
	else
		color = self.DefaultColor
	end

	if self.Color ~= color then
		self.Color = color
		local colorUpdated = self.ColorUpdated
		local color2 = self.Color
		local name

		if object2 then
			name = object2.MaterialVariant:gsub(" ", "")

			if not Materials[name] then
				name = object2.Material.Name
			end
		end

		colorUpdated:Fire(color2, name)
	end

	if object2 then
		UserInputService.MouseIcon = "rbxassetid://128848368210445"
		self.Highlight.Adornee = object2
	else
		UserInputService.MouseIcon = ""
		self.Highlight.Adornee = nil
	end
end

function Eyedropper:Destroy()
	if self.Janitor then
		self.Janitor:Destroy()
		self.Janitor = nil
	end

	if self.ColorUpdated then
		self.ColorUpdated:Destroy()
	end

	if self.Clicked then
		self.Clicked:Destroy()
	end

	if self.Highlight then
		self.Highlight:Destroy()
		self.Highlight = nil
	end

	UserInputService.MouseIcon = ""
end

return Eyedropper