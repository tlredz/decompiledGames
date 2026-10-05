local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("HttpService")
game:GetService("CollectionService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local parent = script.Parent
local utility = parent.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(parent.Rocks)
local parent2 = script.Parent
require(parent2:WaitForChild("HexsStormClass"))
local Maid = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Maid"))
local lightningBoltShafi = Util.LightningBoltShafi
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("ControlRework").M1
local objectClass = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("ObjectClass")
Random.new()

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local mouseArea = objectClass:WaitForChild("MouseArea")
local model = Instance.new("Model", workspace._WorldOrigin)
model.Name = "Cubes-Objects"
local ObjectClass = {
	TemplateModel = objectClass:WaitForChild("Model"),
	Stored = {},
	Folder = model
}
ObjectClass.__index = ObjectClass
ObjectClass.__type = "Object"

local function ownerNameFor(value)
	if typeof(value) == "Instance" then
		return value.Name
	end

	if type(value) ~= "table" then
		return "Unknown"
	end

	if type(value.Name) == "string" then
		return value.Name
	end

	if typeof(value.Character) == "Instance" then
		return value.Character.Name
	end

	return "Unknown"
end

function ObjectClass.new(player, cframe: CFrame?, proxy, custom, p)
	local maid = Maid.new()
	local name

	if typeof(player) == "Instance" then
		name = player.Name
	elseif type(player) == "table" then
		if type(player.Name) == "string" then
			name = player.Name
		else
			name = typeof(player.Character) ~= "Instance" and "Unknown" or player.Character.Name
		end
	else
		name = "Unknown"
	end

	if not model:FindFirstChild(name) then
		local model2 = Instance.new("Model")
		model2.Name = name
		model2.Parent = model
	end

	local model2 = custom and Instance.new("Model") or maid:GiveTask(p or ObjectClass.TemplateModel:Clone())
	Util.SetParentOverrideWithColor(model2, model:FindFirstChild(name), player, "ControlFruitVFXColor")

	if proxy then
		model2.Name = proxy.Name
	end

	if custom then
		model2:SetAttribute("CustomModel", true)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Name = "Main"
		part.Size = custom.Size
		part:SetAttribute("IsControlPart", true)
		part.Parent = model2
		model2.PrimaryPart = part
	end

	local shaders

	if not custom then
		shaders = model2.Main.Shaders:GetChildren() or nil
	end

	local object = setmetatable({
		Maid = maid,
		Player = player,
		Model = model2,
		Shaders = shaders,
		Proxy = proxy,
		Bolts = {},
		ThrowData = {},
		Custom = custom
	}, ObjectClass)
	ObjectClass.Stored[model2] = object

	if custom then
		local v3 = (custom.Size.X + custom.Size.Y + custom.Size.Z) / 1.6

		if v3 >= 125 then
			model2:SetAttribute("TrueScale", 3 + (v3 - 125) / 125)
			model2:SetAttribute("SizeScale", 3)
			object:SetLayout("3x3")
		elseif v3 >= 65 then
			model2:SetAttribute("TrueScale", 2 + (v3 - 65) / 60)
			model2:SetAttribute("SizeScale", 2)
			object:SetLayout("2x2")
		else
			model2:SetAttribute("TrueScale", 1 + v3 / 65)
			model2:SetAttribute("SizeScale", 1)
			object:SetLayout("1x1")
		end

		object:AddDragable()
		object:PivotTo(cframe)
		object:SwitchMode("Planing", true)
		return object
	else
		object:SwitchMode("Idle", true)
		object:SetLayout("1x1")
		object:AddDragable()
		object:PivotTo(cframe)
		return object
	end
end

function ObjectClass.MultipleSelect(_, items, callback)
	for _, item in items do
		item:Select(true)

		if callback then
			callback(item)
		end
	end

	ObjectClass:SetSelected(items)
end

function ObjectClass.ApplyModelColor(_, p, color: Color3)
	local main = p.Main
	local outline = main:FindFirstChild("Outline")

	if outline then
		outline.Decal.Color3 = color
	end

	local bodyPattern = main:FindFirstChild("BodyPattern")

	if bodyPattern then
		for _, child in bodyPattern:GetChildren() do
			child.Color = ColorSequence.new(color)
		end
	end

	local children = main.Shaders:GetChildren()

	for _, v in children do
		if v:FindFirstChild("Fill") then
			v.Fill.BackgroundColor3 = color
		end

		for _, v2 in { v.Grid, v.HardEdge, v.SoftEdge } do
			v2.ImageColor3 = color
		end
	end
end

function ObjectClass:SetSelected(selected)
	local selected2 = ObjectClass.Selected

	if selected2 then
		if selected2.__type == ObjectClass.__type then
			selected2:Deselect()
		else
			for _, v in selected2 do
				v:Deselect()
			end
		end
	end

	ObjectClass.Selected = selected
end

function ObjectClass.GetObjectsSelectedList(_)
	return ObjectClass.LockedSelection and ObjectClass.Selected or { ObjectClass.Selected }
end

function ObjectClass.LockSelection(_)
	ObjectClass.LockedSelection = true

	for _, v in ObjectClass.Stored do
		if not v.IsThrowing then
			v:RemoveDragable()
		end
	end
end

function ObjectClass.UnlockSelection(_)
	ObjectClass.LockedSelection = nil

	for _, v in ObjectClass.Stored do
		if not v.IsThrowing then
			v:AddDragable()
		end
	end
end

function ObjectClass.IsSelectionLocked(_)
	return ObjectClass.LockedSelection
end

function ObjectClass:CreateMouseArea(value: number?, p)
	local clone = mouseArea:Clone()
	clone:ScaleTo((value or 1) * 1.75)
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, p, "ControlFruitVFXColor")
	Util.Sound:Play("CTRLFRT_Fist_Cube_Selected_Looped_Indicator_01", clone.PrimaryPart)

	for _, surfaceGui in clone.Main:GetChildren() do
		if not surfaceGui:IsA("SurfaceGui") then
			continue
		end

		VisualHelper:Tween(
			surfaceGui.Edge,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				ImageTransparency = 0.5
			}
		)
		VisualHelper:Tween(
			surfaceGui.InnerGradient,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				ImageTransparency = 0.3
			}
		)
		VisualHelper:Tween(
			surfaceGui.AnimateGradient,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.fromScale(0.9, 0.9),
				ImageTransparency = 0.3
			}
		)
		VisualHelper:Tween(
			surfaceGui.BorderShader,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				ImageTransparency = 0.96
			}
		)
		VisualHelper:Tween(
			surfaceGui.BorderShader,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Rotation = surfaceGui.BorderShader.Rotation + 360
			}
		)
		VisualHelper:Tween(
			surfaceGui.InnerEngine,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.fromScale(0.23, 0.23)
			}
		)
		VisualHelper:Tween(
			surfaceGui.InnerEngine,
			TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Rotation = surfaceGui.InnerEngine.Rotation + 360
			}
		)
		VisualHelper:Tween(surfaceGui.Mark, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Rotation = surfaceGui.Mark.Rotation + 360
		})
		VisualHelper:Tween(
			surfaceGui.Mark2,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.fromScale(1.2, 1.2)
			}
		)
		VisualHelper:Tween(
			surfaceGui.Mark3,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.fromScale(0.72, 0.72)
			}
		)
		VisualHelper:Tween(
			surfaceGui.OutEngine,
			TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Rotation = surfaceGui.OutEngine.Rotation + 360
			}
		)
		VisualHelper:Tween(
			surfaceGui.ExtraOutEngine,
			TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Rotation = surfaceGui.OutEngine.Rotation + 360
			}
		)
	end

	return clone
end

function ObjectClass:Select(flag: boolean?)
	if not flag then
		ObjectClass:SetSelected(self)
	end

	self.Selected = true
	local throwData = self.ThrowData
	local player = self.Player
	local Mouse = require(game.ReplicatedStorage.Mouse)
	local v = self.Maid:GiveTask(objectClass.SelectionBox:Clone())
	v.SelectionBox.Adornee = v
	v.Size = self.Model.Main.Size * 1.3
	v.Weld.Part1 = self.Model.Main
	Util.SetParentOverrideWithColor(v, self.Model, player, "ControlFruitVFXColor")
	throwData.SelectionBox = v
	local playerGui

	if typeof(player) == "Instance" and player:IsA("Player") then
		playerGui = player:FindFirstChild("PlayerGui")
	end

	if not playerGui then
		return
	end

	local selectedGUI = self.Maid:GiveTask(objectClass.SelectedGUI:Clone())
	selectedGUI.Adornee = self.Model.Main
	Util.SetParentOverrideWithColor(selectedGUI, playerGui, player, "ControlFruitVFXColor")
	local size = selectedGUI.Size
	local v3 = self:GetLayoutSize() / 3
	selectedGUI.Size = UDim2.new()
	VisualHelper:Tween(selectedGUI, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Size = UDim2.fromScale(size.X.Scale * v3, size.Y.Scale * v3)
	})
	VisualHelper:Tween(
		selectedGUI.Main.IconA,
		TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Rotation = selectedGUI.Main.IconA.Rotation - 360
		}
	)
	VisualHelper:Tween(
		selectedGUI.Main.IconB,
		TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
		{
			ImageTransparency = 1,
			Size = UDim2.fromScale(0.85, 0.85)
		}
	)
	VisualHelper:Tween(
		selectedGUI.Main.IconD,
		TweenInfo.new(4.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Rotation = selectedGUI.Main.IconD.Rotation + 360
		}
	)
	local size2 = selectedGUI.Main.Hex.Size
	selectedGUI.Main.Hex.Size = UDim2.new()
	local size3 = selectedGUI.Main.Bubble.Size
	selectedGUI.Main.Bubble.Size = UDim2.new()
	local size4 = selectedGUI.Main.MiniBubble.Size
	selectedGUI.Main.MiniBubble.Size = UDim2.new()
	self.Maid:GiveTask(task.delay(0.1, function()
		VisualHelper:Tween(selectedGUI.Main.Hex, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Size = size2
		})
		VisualHelper:Tween(selectedGUI.Main.Bubble, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Size = size3
		})
		VisualHelper:Tween(selectedGUI.Main.MiniBubble, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Size = size4,
			ImageTransparency = 1
		})
		task.wait(0.1)
		VisualHelper:Tween(selectedGUI.Main.Hex, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		})
		VisualHelper:Tween(selectedGUI.Main.Bubble, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		})
	end))
	throwData.SelectedGUI = selectedGUI

	function throwData.SelectedUpdate(p: number)
		v.Weld.C0 *= CFrame.Angles(0, p, p)
	end

	if flag then
		return
	end

	local mouseArea2 = self.Maid:GiveTask(ObjectClass:CreateMouseArea(self:GetLayoutSize(), player))
	throwData.MouseArea = mouseArea2

	local function Update(p: number)
		local position = Mouse.Hit.Position
		local position2 = self:GetPivot().Position
		local rayCast = MathHelper:RayCast(position2, (position - position2).Unit * 700, {
			workspace._WorldOrigin,
			workspace.CutParts,
			workspace.Characters,
			workspace.Enemies
		})

		if not rayCast then
			print("wait this dude dont got a ray? im dead")
			return
		end

		throwData.RayCastResult = rayCast
		mouseArea2:PivotTo(CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.new(0, 0, -1) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		))
		v.Weld.C0 *= CFrame.Angles(0, p, p)
	end

	Update(0)
	throwData.Connection = self.Maid:GiveTask(RunService.PostSimulation:Connect(Update))
end

function ObjectClass:Deselect()
	ObjectClass.Selected = nil
	self.Selected = nil
	local throwData = self.ThrowData
	throwData.SelectedUpdate = nil
	local mouseArea2 = throwData.MouseArea
	local selectionBox = throwData.SelectionBox
	local selectedGUI = throwData.SelectedGUI
	local connection = throwData.Connection

	if selectionBox then
		selectionBox:Destroy()
	end

	if selectedGUI then
		VisualHelper:Tween(selectedGUI, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
			Size = UDim2.new()
		})
		Util.Debris:AddItem(selectedGUI, 0.5)
	end

	if not connection then
		return
	end

	connection:Disconnect()

	if self.IsThrowing then
		return
	end

	mouseArea2:Destroy()
end

function ObjectClass:SwitchMode(mode: string, flag: boolean)
	if not self.Custom then
		for _, shader in self.Shaders do
			local grid = shader.Grid
			grid.ImageTransparency = 0.13
			shader.HardEdge.UIGradient.Enabled = mode == "Planing"

			-- equivalent calls inferred from this helper; original call sites unknown
			local function SetTexture()
				grid.Image = `rbxassetid://{mode == "Idle" and 86987716747968 or 106467816216353}`
			end

			if flag then
				SetTexture() -- equivalent call inferred; original call site unknown
			else
				VisualHelper:Tween(
					grid,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
					{
						ImageTransparency = 1
					}
				)
				self.Maid:GiveTask(task.delay(0.25, SetTexture))
			end
		end
	end

	self.Mode = mode
end

function ObjectClass.GetLayout(p)
	return p.Layout
end

function ObjectClass:GetLayoutSize(p: string?)
	if self.Custom then
		return self.Model:GetAttribute("TrueScale")
	end

	local v = p or self.Layout
	return v and tonumber((string.sub(v, -1))) or 0
end

function ObjectClass:SetLayout(layout: string)
	self.Layout = layout
	local v = 3 / self:GetLayoutSize()

	if not self.Custom then
		for _, shader in self.Shaders do
			shader.Grid.Size = UDim2.fromScale(v, v)
		end
	end

	self.Model:SetAttribute("LayoutScale", v)
end

function ObjectClass:ToggleDarkLayers(flag: boolean)
	if self.Custom then
		local main = self.Model and self.Model:FindFirstChild("Main")

		if main then
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(28, 28, 31)
			highlight.FillTransparency = 0.25
			highlight.OutlineTransparency = 1
			highlight.Parent = main
			highlight.Adornee = main
			Util.Debris:AddItem(highlight, 3)
		end
	else
		for _, shader in self.Shaders do
			shader.Dark.Visible = true
			shader.Dark.BackgroundTransparency = flag and 1 or 0
			VisualHelper:Tween(shader.Dark, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				BackgroundTransparency = flag and 0 or 1
			})
		end
	end
end

function ObjectClass.ToggleBodyPattern(p, flag: boolean)
	VisualHelper:SetEnableAll(p.Model.Main.BodyPattern, flag)
end

function ObjectClass:GetMode()
	return self.Mode
end

function ObjectClass:ToggleBolts(energized: boolean)
	if self.Custom then
		return
	end

	self.Energized = energized

	if energized then
		local layoutSize = self:GetLayoutSize()

		local function NewBolt(child, point, value: number?)
			local v = lightningBoltShafi.new(
				child,
				point,
				(value or 4) * layoutSize,
				0.75 * layoutSize,
				workspace._WorldOrigin
			)
			local curveSize = 5 * layoutSize
			local curveSize2 = -5 * layoutSize
			v.CurveSize0 = curveSize
			v.CurveSize1 = curveSize2
			v.MinRadius = 1
			v.MaxRadius = 3
			v.Frequency = 0.4 * layoutSize
			v.AnimationSpeed = math.random(5, 9)
			local maxThicknessMultiplier = 0.3 + math.random() * 0.75
			v.MinThicknessMultiplier = 0.1
			v.MaxThicknessMultiplier = maxThicknessMultiplier
			v.MinTransparency = 0
			v.MaxTransparency = 1
			v.PulseSpeed = 40
			v.PulseLength = 1000000
			v.FadeLength = 0.2
			local player = self.Player
			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
			})

			if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
				colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
			end

			v.Color = colorSequence
			v.ContractFrom = 0.5
			v.ColorOffsetSpeed = 3
			return v
		end

		for _, child in self.Model.Main.Bolts:GetChildren() do
			table.insert(self.Bolts, (NewBolt(child, child.Point)))
		end
	else
		for _, bolt in self.Bolts do
			bolt:Destroy()
		end

		table.clear(self.Bolts)
	end
end

function ObjectClass:OnDomeUpdate(p: number, p2: number)
	local planingCFrame = self.PlaningCFrame

	if self.IsThrowing or not planingCFrame then
		return
	end

	local v = 1 - math.exp(p2 * -0.6)
	local cframe = self:GetPivot():Lerp(planingCFrame, v)
	self:PivotTo(CFrame.new(cframe.Position + Vector3.new(0, math.sin(p * 2) * 0.12)) * CFrame.Angles(cframe:ToEulerAnglesXYZ()))
end

function ObjectClass:PivotTo(cframe: CFrame?)
	self.Model:PivotTo(cframe or CFrame.new())
end

function ObjectClass:GetPivot()
	return self.Model:GetPivot()
end

function ObjectClass:ScaleTo(p2: number)
	self.Model:ScaleTo(p2)
end

function ObjectClass:GetScale()
	return self.Model:GetScale()
end

function ObjectClass.GetSize(p)
	return p.Model.Main.Size
end

function ObjectClass.SetSize(p, size: Vector3)
	p.Model.Main.Size = size
end

function ObjectClass:RemoveDragable() end

function ObjectClass:AddDragable() end

function ObjectClass:GetFromInstance(p2)
	return self.Stored[p2]
end

function ObjectClass:EnergizeNearbyObjects(p)
	local fromInstance = self:GetFromInstance(p)

	if not fromInstance then
		return
	end

	local position = fromInstance:GetPivot().Position
	local v = {}

	for _, v2 in self.Stored do
		if not ((not v2.Energized or v2 == fromInstance) and (position - v2:GetPivot().Position).Magnitude <= 200) then
			continue
		end

		table.insert(v, v2)
	end

	local function NewBolt(p2, p3, player, _: number?)
		local v2 = lightningBoltShafi.new(p2, p3, 15, 1 + math.random() * 0.85, workspace._WorldOrigin)
		local curveSize = math.random(5, 10)
		local curveSize2 = math.random(-10, -5)
		v2.CurveSize0 = curveSize
		v2.CurveSize1 = curveSize2
		v2.MinRadius = 1
		v2.MaxRadius = 15
		v2.Frequency = 0.7
		v2.AnimationSpeed = math.random(4.5, 8.5)
		local maxThicknessMultiplier = 0.3 + math.random() * 0.75
		v2.MinThicknessMultiplier = 0.1
		v2.MaxThicknessMultiplier = maxThicknessMultiplier
		v2.MinTransparency = 0
		v2.MaxTransparency = 1
		v2.PulseSpeed = 40
		v2.PulseLength = 1000000
		v2.FadeLength = 0.2
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
		})

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
		end

		v2.Color = colorSequence
		v2.ContractFrom = 0.5
		v2.ColorOffsetSpeed = 3
		return v2
	end

	task.spawn(function()
		local v2 = nil

		for k, v3 in v do
			if not v3.Energized then
				v3:ToggleBolts(true)
			end

			v3:Flash()
			local v4 = v3.Maid:GiveTask(Instance.new("Attachment"))
			v4.Parent = v3.Model.Main
			Util.Debris:AddItem(v4, 5)

			if v2 then
				local v5 = {}
				table.insert(v5, (v3.Maid:GiveTask((NewBolt(v4, v2, v3.Player)))))
				table.insert(v5, (v3.Maid:GiveTask((NewBolt(v4, v2, v3.Player)))))
				v3.Maid:GiveTask(task.delay(0.3 + k * 0.2, function()
					for k2, v7 in v5 do
						v7:Destroy()
						task.wait(0.03)
					end
				end))
			end

			local clone = objectClass.Pulse:Clone()
			clone:PivotTo(v3:GetPivot())
			Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, v3.Player, "ControlFruitVFXColor")
			local beams = clone.Main.Beams
			VisualHelper:Tween(beams, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Orientation = beams.Orientation + createVector(0, 360, 0)
			})
			v2 = v4

			for _, beam in beams:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local width0 = beam:GetAttribute("Width0") or beam.Width0
				local width1 = beam:GetAttribute("Width1") or beam.Width0
				beam:SetAttribute("Width0", width0)
				beam:SetAttribute("Width1", width1)
				beam.Width0 = width0
				beam.Width1 = width1
				beam.Enabled = true
				VisualHelper:Tween(beam, TweenInfo.new(0.1 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			VisualHelper:EmitAll(clone)
			Util.Debris:AddItem(clone, 3)
			task.wait(0.1)
		end
	end)
	return #v > 0
end

function ObjectClass:Flash()
	local _ = self.FlashThread

	if self.FlashThread then
		task.cancel(self.FlashThread)
	end

	local main = self.Model.Main
	local material = main.Material
	local color = main.Color
	local neon = Enum.Material.Neon
	local player = self.Player
	local color2 = Color3.fromRGB(103, 144, 255)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	main.Material = neon
	main.Color = color2
	main.CanCollide = false
	local localPlayer = game.Players.LocalPlayer
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if main and main.Parent then
				local pointToObjectSpace = main.CFrame:PointToObjectSpace(humanoidRootPart.Position)
				local v = createVector(2, 2, 2) + main.Size * 0.5
				local v2

				if math.abs(pointToObjectSpace.X) <= v.X and math.abs(pointToObjectSpace.Y) <= v.Y then
					v2 = math.abs(pointToObjectSpace.Z) <= v.Z
				else
					v2 = false
				end

				if v2 then
					return
				end

				main.CanCollide = true

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
		self.Maid:GiveTask(function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end)
	end

	self.FlashThread = self.Maid:GiveTask(task.delay(0.05, function()
		local main2 = main
		main.Material = material
		main2.Color = color
	end))
end

function ObjectClass:Throw(callback)
	local throwData = self.ThrowData
	local rayCastResult = throwData.RayCastResult

	if not rayCastResult then
		local ray = Util.Ray
		local position = self.Model.Main.Position
		local v = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local _, position3, v3 = ray(position, createVector(-0, -500, -0), v)
		rayCastResult = {
			Position = position3,
			Normal = v3 or createVector(0, 1, 0)
		}
		self.ThrowData.RayCastResult = rayCastResult
	end

	if not rayCastResult or self.IsThrowing or self:GetMode() ~= "Planing" then
		return
	end

	self.IsThrowing = true
	self:RemoveDragable()

	if self.Energized then
		self:ToggleDarkLayers(true)
	end

	self.Model.Main.CanCollide = false

	if self.Custom then
		local custom = self.Custom
		local clone = custom:Clone()

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			elseif descendant:IsA("BodyMover") or descendant:IsA("Constraint") then
				descendant:Destroy()
			end
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CFrame = custom.CFrame
		clone.Name = "Main"
		clone.Parent = self.Model
		custom:SetAttribute("Destroying", true)
		custom.LocalTransparencyModifier = 1

		for _, part in custom:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end

		self.Custom = clone
	end

	local pivot = self:GetPivot()
	local eulerAnglesYXZ, v, v2 = pivot:ToEulerAnglesYXZ()
	local position = pivot.Position
	local position2 = rayCastResult.Position
	local magnitude = (position - position2).Magnitude
	local v3 = math.clamp(magnitude / 180, 0.3, 15)
	local v4 = magnitude / 100 * 0.32288591161895097
	local v5 = position:Lerp(position2, 0.5) + Vector3.new(0, 100 + magnitude / 15)
	local clone = nil
	local mouseArea2 = throwData.MouseArea
	local v6 = not mouseArea2 and 1 or mouseArea2:GetScale() or 1

	if mouseArea2 then
		mouseArea2:ScaleTo(v6 / 2)
		VisualHelper:TweenScale(mouseArea2, TweenInfo.new(0.3, Enum.EasingStyle.Back), v6)
	end

	self.Maid:GiveTask(VisualHelper:TweenNumberValue(1, TweenInfo.new(v3, Enum.EasingStyle.Linear), function(p)
		local v7 = p * v4
		self:PivotTo(CFrame.new(MathHelper:QuadBezier(p, position, v5, position2) + Vector3.new(
			0,
			math.noise((position.X + position.Z + os.clock() * 2) * 0.1) * 45
		)) * CFrame.Angles(eulerAnglesYXZ, v + v7, v2 + v7))

		if not clone and p > 0.05 then
			clone = M1.Impulse:Clone()
			clone:ScaleTo(self:GetScale() * 0.7)
			clone:PivotTo(CFrame.lookAt(position, self:GetPivot().Position))
			Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, self.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(
				clone.Main.Beams,
				TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = clone.Main.Beams.Orientation - createVector(0, 0, 360)
				}
			)

			for _, child in clone.Main.Beams:GetChildren() do
				VisualHelper:Tween(child.BeamMain, TweenInfo.new(0.1 + math.random() * 0.15, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			VisualHelper:EmitAll(clone)
			Util.Debris:AddItem(clone, 1)
		end

		if p > 0.5 and mouseArea2 then
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
			VisualHelper:TweenScale(mouseArea2, tweenInfo, v6 + 0.2)
			VisualHelper:SetEnableAll(mouseArea2, false)

			for _, v8 in { mouseArea2.Main.CircleInnerBeam.Beam1, mouseArea2.Main.CircleInnerBeam.Beam2 } do
				v8.Enabled = true
				VisualHelper:Tween(v8, tweenInfo, {
					Brightness = 0
				})
			end

			for _, child in mouseArea2.Main.Top:GetChildren() do
				VisualHelper:Tween(child, tweenInfo, {
					ImageTransparency = 1
				})
			end

			Util.Debris:AddItem(mouseArea2, tweenInfo.Time + 0.3)
			mouseArea2 = nil
		end

		if p < 1 then
			return
		end

		self.IsThrowing = false
		self:AddDragable()

		if not callback then
			return
		end

		callback(rayCastResult)
	end))
end

function ObjectClass.IsSliceModel(p, flag: boolean?)
	local sliceModel = p.Model:GetAttribute("SliceModel")

	if sliceModel and flag then
		warn((`You can’t use this method on a slice model of type: {p.Model.Name}`))
	end

	return sliceModel
end

function ObjectClass:Destroy()
	if self.Selected == self then
		self:Deselect()
	end

	self.ThrowData.SelectedUpdate = nil
	self:ToggleBolts(false)
	ObjectClass.Stored[self.Model] = nil

	if self.Model then
		self.Model:Destroy()
	end

	self.Maid:DoCleaning()
end

return ObjectClass