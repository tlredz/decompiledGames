local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.EnumLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local viewModels = Players.LocalPlayer.PlayerScripts.Modules.ViewModels
local paintballSplatGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PaintballSplatGui")
local v = { "rbxassetid://17098901439", "rbxassetid://17098901515", "rbxassetid://16833617681" }
local Splats = {}
Splats.__index = Splats

function Splats.new(fighterInterface)
	local self = setmetatable({}, Splats)
	self.FighterInterface = fighterInterface
	self._splat_guis = {}
	self:_Init()
	return self
end

function Splats:Create(p, p2, childName, p3)
	if not self.FighterInterface:IsActive() then
		return
	end

	local child = childName and viewModels:FindFirstChild(childName, true)
	local module = child and require(child)

	for _ = 1, p3 and 20 or 1 do
		local v2 = 0.125 + 0.5 * math.random()
		local color = p3 and Color3.fromHSV(math.random(), 0.75, 1) or module and module:GetPaintballColor() or p2 or Color3.fromHSV(
			tick() * 2 % 1,
			0.75,
			1
		)
		local uDim

		if p3 then
			uDim = UDim2.new(
				v2 * 0.25 + (1 - v2 * 0.5) * math.random(),
				0,
				v2 * 0.25 + (1 - v2 * 0.5) * math.random(),
				0
			)
		else
			uDim = self:_GetScreenPosition(p)
		end

		local clone = paintballSplatGui:Clone()
		clone.Splat.Size = UDim2.new(v2, 0, v2, 0)
		clone.Splat.Position = uDim
		clone.Splat.ImageColor3 = color
		clone.Splat.Image = v[math.random(#v)]
		clone.Splat.Rotation = 360 * math.random()
		clone.Parent = self.FighterInterface:IsActive() and Players.LocalPlayer.PlayerGui or nil
		table.insert(self._splat_guis, clone)
		local v3 = clone.Splat
		task.delay(2.5, function()
			local imageTransparency = v3.ImageTransparency
			Utility:RenderstepForLoop(0, 100, 4, function(p4)
				local v5 = 1 - (1 - p4 / 100) ^ 5
				v3.ImageTransparency = imageTransparency + (1 - imageTransparency) * v5
			end)
			clone:Destroy()
			local index = table.find(self._splat_guis, clone)

			if index then
				table.remove(self._splat_guis, index)
			end
		end)

		if clone:IsDescendantOf(Players.LocalPlayer) then
			clone.Splat:TweenSize(UDim2.new(v2 * 0.5, 0, v2 * 0.5, 0), "In", "Quint", 3, true)
		end

		self.FighterInterface:CreateSound("rbxassetid://16835701807", 0.75, 1 + 0.4 * math.random(), script, true, 10)

		if p3 then
			wait(0.03 * math.random())
		end
	end
end

function Splats:Destroy()
	for _, v2 in pairs(self._splat_guis) do
		v2:Destroy()
	end

	self._splat_guis = {}
end

function Splats:_GetScreenPosition(p2)
	local v2, v3

	if p2 then
		v2, v3 = workspace.CurrentCamera:WorldToScreenPoint(p2)
	end

	if v3 then
		local screenPointToPosition = UILibrary:ScreenPointToPosition(v2, self.FighterInterface.Frame.AbsolutePosition)
		return UDim2.new(
			0,
			math.clamp(
				screenPointToPosition.X,
				self.FighterInterface.Frame.AbsoluteSize.X * 0.125,
				self.FighterInterface.Frame.AbsoluteSize.X * 0.875
			),
			0,
			(math.clamp(
				screenPointToPosition.Y,
				self.FighterInterface.Frame.AbsoluteSize.Y * 0.125,
				self.FighterInterface.Frame.AbsoluteSize.Y * 0.875
			))
		)
	end

	local v4 = Vector2.new(self.FighterInterface.Frame.AbsoluteSize.X, self.FighterInterface.Frame.AbsoluteSize.Y) * (0.8 + 0.4 * math.random()) * 0.5
	local v5 = math.random() * 3.141592653589793 * 2
	return UDim2.new(0.5, math.cos(v5) * v4.X, 0.5, math.sin(v5) * v4.Y)
end

function Splats:_Init()
	self.FighterInterface.ActiveChanged:Connect(function()
		for _, v2 in pairs(self._splat_guis) do
			v2.Parent = self.FighterInterface:IsActive() and Players.LocalPlayer.PlayerGui or nil
		end
	end)
end

return Splats