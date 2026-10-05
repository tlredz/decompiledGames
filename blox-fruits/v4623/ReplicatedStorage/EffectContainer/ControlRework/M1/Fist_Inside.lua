local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("StarterPlayer")
game:GetService("ServerStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local shared = script.Parent.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
require(shared.Rocks)
local ObjectClass = require(shared:WaitForChild("ObjectClass"))
local camera = workspace.Camera
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage.Effect)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local domain = FX:WaitForChild("ControlRework").Domain
local M1 = FX:WaitForChild("ControlRework").M1
local random = Random.new()
local count = 0
return function(player)
	local _ = player.DataModelId
	local v = ObjectClass.Stored[player.DataModel] or ObjectClass.Selected
	local isSelectionLocked = ObjectClass:IsSelectionLocked()
	local player2 = player.Player
	local _ = player.Character

	if player.ForceThrow then
		local dataModel = player.DataModel
		local child = workspace._WorldOrigin["Cubes-Objects"]:FindFirstChild(player2.Name)

		if child then
			local child2 = child:FindFirstChild(dataModel)
			local v2 = child2 and ObjectClass.Stored[child2]

			if v2 then
				local model = v2.Model

				if not model.Parent then
					return
				end

				local position = model:GetPivot().Position
				local shootPoint = player.ShootPoint
				local ray, position2, normal = Util.Ray(position, (shootPoint - position).Unit * 700, {
					workspace._WorldOrigin,
					workspace.Characters,
					workspace.Enemies,
					workspace.CutParts
				})
				Util.Sound:Play(
					({ "CTRLFRT_Fist_Release_Small_0", "CTRLFRT_Fist_Release_Medium_0", "CTRLFRT_Fist_Release_Large_0" })[model:GetAttribute("SizeScale")] .. tostring(math.random(
						1,
						4
					)),
					model.PrimaryPart.Position
				)
				v2.ThrowData.RayCastResult = {
					Instance = ray,
					Position = position2,
					Normal = normal
				}
				v2:Throw(function(p)
					Effect.new("ControlRework.ObjectExplosion"):play({
						Position = p.Position,
						Normal = p.Normal,
						Object = v2.Custom and v2.Custom or v2.Model.Main,
						Energized = v2.Energized,
						Scale = 2.15 * v2:GetLayoutSize(),
						IsCustom = v2.Custom and true or false
					})
					v2:Destroy()
				end)
			end
		end
	end

	if player.Action == "Deselect" or player.Action == "Select" then
		if not isSelectionLocked and v and v.__type == ObjectClass.__type then
			v[player.Action](v)

			if not player.Holding then
				return
			end

			local holding = player.Holding

			repeat
				task.wait()
			until not (holding and holding.Value)

			local model = v.Model

			if not model.Parent then
				return
			end

			local Mouse = require(game.ReplicatedStorage.Mouse)
			local position = model:GetPivot().Position
			local p = Mouse.Hit.p
			local ray, position2, normal = Util.Ray(position, (p - position).Unit * 700, {
				workspace._WorldOrigin,
				workspace.Characters,
				workspace.Enemies,
				workspace.CutParts
			})
			local _ = {
				Instance = ray,
				Position = position2,
				Normal = normal
			}
			Util.Sound:Play(
				({ "CTRLFRT_Fist_Release_Small_0", "CTRLFRT_Fist_Release_Medium_0", "CTRLFRT_Fist_Release_Large_0" })[model:GetAttribute("SizeScale")] .. tostring(math.random(
					1,
					4
				)),
				model.PrimaryPart.Position
			)

			if model:FindFirstChild("Main") then
				model.Main:SetAttribute("SizeScale", model:GetAttribute("SizeScale"))
			end

			v:Throw(function(p2)
				Effect.new("ControlRework.ObjectExplosion"):play({
					Position = p2.Position,
					Normal = p2.Normal,
					Object = v.Custom and v.Custom or v.Model.Main,
					Energized = v.Energized,
					Scale = 2.15 * v:GetLayoutSize(),
					IsCustom = v.Custom and true or false
				})
				v:Destroy()
			end)
			ObjectClass:SetSelected(nil)
			ObjectClass:UnlockSelection()
			return
		end
	elseif player.Action == "SelectAll" then
		local v2 = {}

		for k, v3 in ObjectClass.Stored do
			if player.SelectedModels[k.Name] then
				table.insert(v2, v3)
			end
		end

		local v3 = -1
		ObjectClass:MultipleSelect(v2, function(object)
			v3 += 1
			local v4 = v3 / #v2
			local throwData = object.ThrowData
			local model = object.Model
			local mouseArea = object.Maid:GiveTask(ObjectClass:CreateMouseArea(object:GetLayoutSize(), object.Player))
			mouseArea.Main.Light:Destroy()
			local scale = mouseArea:GetScale()
			mouseArea:ScaleTo(0.01)
			VisualHelper:TweenScale(
				mouseArea,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, v3 * 0.07),
				scale
			)
			throwData.MouseArea = mouseArea
			throwData.MouseCFrameOffset = CFrame.Angles(0, 0, (math.rad(v4 * 360 + math.random(-35, 35))))
			throwData.MouseCFrameYOffset = CFrame.new(0, v4 * 155, 0)
			model:SetAttribute("MouseCFrameOffset", throwData.MouseCFrameOffset)
			model:SetAttribute("MouseCFrameYOffset", throwData.MouseCFrameYOffset)
		end)
		local renderSteppedConnection = nil

		local function Update(dt)
			local Mouse = require(game.ReplicatedStorage.Mouse)
			local p = Mouse.Hit.p
			local mouseLocation = UserInputService:GetMouseLocation()
			local screenPointToRay = camera:ScreenPointToRay(
				mouseLocation.X,
				mouseLocation.Y - GuiService:GetGuiInset().Y
			)
			local rayCast = MathHelper:RayCast(
				screenPointToRay.Origin,
				screenPointToRay.Direction * 2000,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
				Enum.RaycastFilterType.Exclude
			)

			for _, v4 in v2 do
				if v4.IsThrowing then
					renderSteppedConnection:Disconnect()
				end

				local throwData = v4.ThrowData
				local position = v4:GetPivot().Position
				local cframe = rayCast and CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) or CFrame.lookAt(
					p,
					position
				)
				local v5 = 0 + throwData.MouseCFrameYOffset.Y
				local position2 = (cframe * throwData.MouseCFrameOffset * throwData.MouseCFrameYOffset * CFrame.new(
					math.cos(v5) * 25,
					math.sin(v5) * 25,
					0
				)).Position
				local rayCast2 = MathHelper:RayCast(
					position,
					CFrame.lookAt(position, position2).LookVector * 2000,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies },
					Enum.RaycastFilterType.Exclude
				)

				if not rayCast2 then
					break
				end

				throwData.RayCastResult = rayCast2
				throwData.MouseArea:PivotTo(CFrame.lookAt(rayCast2.Position, rayCast2.Position + rayCast2.Normal) * CFrame.new(
					0,
					0,
					-1
				) * CFrame.Angles(-1.5707963267948966, 0, 0))
				local selectedUpdate = throwData.SelectedUpdate

				if not selectedUpdate then
					break
				end

				selectedUpdate(dt)
			end
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			Update(dt)
		end)
		local holding = player.Holding

		repeat
			task.wait()
		until not (holding and holding.Value)

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		for _, v4 in v2 do
			local model = v4.Model

			if not model.Parent then
				continue
			end

			local _ = model:GetPivot().Position
			print(model:GetFullName())
			Util.Sound:Play(
				({ "CTRLFRT_Fist_Release_Small_0", "CTRLFRT_Fist_Release_Medium_0", "CTRLFRT_Fist_Release_Large_0" })[model:GetAttribute("SizeScale")] .. tostring(math.random(
					1,
					4
				)),
				model.PrimaryPart.Position
			)
			local v5 = v4
			v4:Throw(function(p)
				if not v5.Model.Parent then
					return
				end

				Effect.new("ControlRework.ObjectExplosion"):play({
					Position = p.Position,
					Normal = p.Normal,
					Object = v5.Custom and v5.Custom or v5.Model.Main,
					Energized = v5.Energized,
					Scale = 2.15 * v5:GetLayoutSize(),
					IsCustom = v5.Custom and true or false
				})
				v5:Destroy()
			end)
		end

		ObjectClass:SetSelected(nil)
		ObjectClass:UnlockSelection()
		return
	end

	if isSelectionLocked then
		return
	end

	count += 1
	local _ = player.MousePos
	local mouseLocation = UserInputService:GetMouseLocation()
	camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y - GuiService:GetGuiInset().Y)
	local rayCastResult = player.RayCastResult

	if not (player.Proxy and rayCastResult) then
		return
	end

	local proxy = player.Proxy
	local cframe = CFrame.lookAt(rayCastResult.Position, rayCastResult.Position + rayCastResult.Normal)
	local cframe2 = CFrame.Angles(-1.5707963267948966, 0, 0)
	local clone = M1.FloorPattern:Clone()
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "ControlFruitVFXColor")
	VisualHelper:SetEnableAll(clone, true)
	local v2 = ObjectClass.new(player2, cframe, proxy)

	local function EmitExpansionExplosion(p: number)
		local clone2 = M1.ExpansionExplosion:Clone()
		clone2:ScaleTo(p * 1.5)
		clone2:PivotTo(clone:GetPivot())
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "ControlFruitVFXColor")
		clone2.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

		for i, child in clone2.Main.Layers:GetChildren() do
			child.Orientation *= 1.5
			local beam = child.Beam
			beam.Width0 *= 2
			beam.Width1 *= 2
			beam.Enabled = true
			local number = random:NextNumber(0.2, 0.3)
			VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
				Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
			})
			VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		for _, child in clone2.Main.CircleWinds:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		VisualHelper:EmitAll(clone2)
		Util.Debris:AddItem(clone2, 2)
	end

	local main = v2.Model.Main
	main.Color = rayCastResult.Instance.Color
	main.Material = rayCastResult.Instance.Material
	main:SetAttribute("IsControlPart", true)
	local v3 = ObjectClass.TemplateModel.Main.Size / 3
	local outline = main.Outline
	local transparency = outline.Decal.Transparency
	outline.Decal.Transparency = 1
	local flag = nil
	local thread = nil
	local size = nil
	local v5 = nil

	local function SmoothScaleTo(p: number)
		if thread then
			task.cancel(thread)
		end

		flag = true
		clone:ScaleTo(p)
		clone:PivotTo(cframe * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0))
		v2:ScaleTo(p)
		size = v3 * p
		v5 = cframe * CFrame.new(0, 0, -(size.Y / 2 + 0))
		v2:PivotTo(cframe * cframe2)
		v2:SetSize(createVector(0, 0, 0))
		VisualHelper:Tween(main, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
			Size = size * createVector(1.35, 0.3, 1.35),
			CFrame = main.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
		})
		thread = task.delay(0.1, function()
			VisualHelper:Tween(main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
				Size = size,
				CFrame = v5 * cframe2
			})
			task.wait(0.225)
			flag = false
		end)
		EmitExpansionExplosion(p)
	end

	SmoothScaleTo(1)
	local holding = player.Holding

	if holding.Value then
		local clone2 = domain.CameraEffectsHex:Clone()
		Util.SetParentOverrideWithColor(clone2, camera, player2, "ControlFruitVFXColor")

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(clone2, true)
			VisualHelper:EmitAll(clone2)
		end

		player.Holding.Changed:Once(function()
			holding = false
		end)
		local v6 = 1
		v2.Model:SetAttribute("SizeScale", v6)
		local v7 = {
			"CTRLFRT_Fist_CubeSpawn_Small_01",
			"CTRLFRT_Fist_CubeSpawn_Medium_01",
			"CTRLFRT_Fist_CubeSpawn_Large_01"
		}
		Util.Sound:Play(v7[v6], main.Position)
		local total = 0

		while holding and holding.Value do
			total += RunService.RenderStepped:Wait()
			clone2.CFrame = camera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)

			if total < 0.4 then
				continue
			end

			total = 0
			local v8 = v2:GetLayoutSize() + 1

			if v8 > 3 then
				continue
			end

			v2:SetLayout((`{v8}x{v8}`))
			SmoothScaleTo(v8)
			v6 += 1
			Util.Sound:Play(v7[v6], main.Position)
			v2.Model:SetAttribute("SizeScale", v6)
		end

		Util.Sound:Play(
			({ "CTRLFRT_Fist_CubeLift_Small_01", "CTRLFRT_Fist_CubeLift_Medium_01", "CTRLFRT_Fist_CubeLift_Large_01" })[v6],
			main.Position
		)
		clone2:Destroy()
	end

	while flag do
		RunService.RenderStepped:Wait()
	end

	EmitExpansionExplosion(v2:GetScale() * 1.25)
	v2:Flash()
	VisualHelper:Tween(main, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
		Size = size * createVector(1, 1, 1) * 1.55,
		CFrame = main.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
	})
	task.wait(0.05)
	outline.CFrame = main.CFrame
	VisualHelper:Tween(main, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
		Size = size
	})
	VisualHelper:Tween(outline.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Transparency = transparency
	})
	v2:SwitchMode("Planing")
	v2:ToggleBodyPattern(true)
	v2.PlaningCFrame = cframe * CFrame.new(0, 0, -(v2:GetSize().Y / 2 + math.random(35, 65))) * cframe2 * CFrame.Angles(
		0,
		math.rad((math.random(360))),
		(math.rad((math.random(-25, 25))))
	)
	local planingCFrame = v2.PlaningCFrame
	local now = tick()
	task.spawn(function()
		while v2 and v2.Model and v2.Model.Parent do
			local v6 = 1 - math.exp(-0.6 * task.wait())
			local v7 = time() - now
			local cframe3 = v2:GetPivot():Lerp(planingCFrame, v6)
			v2:PivotTo(CFrame.new(cframe3.Position + Vector3.new(0, math.sin(v7 * 2) * 0.12, 0)) * CFrame.fromOrientation(cframe3:ToOrientation()))
		end
	end)
	task.spawn(function()
		repeat
			task.wait()
		until not proxy or not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Exploding")

		if proxy:GetAttribute("Throwing") or not v2.Model.Parent or v2.IsThrowing then
			return
		end

		Effect.new("ControlRework.ObjectExplosion"):play({
			Object = v2.Model.Main,
			Energized = v2.Energized,
			Scale = 2.15 * v2:GetLayoutSize()
		})

		if v2 then
			v2:Destroy()
		end
	end)
	clone.Main.Lines.Enabled = false

	for _, child in clone.Main.Main:GetChildren() do
		child.Enabled = false
		child.TimeScale = 0.15
	end

	VisualHelper:SetEnableAll(clone.Main.Smokes)
	Util.Debris:AddItem(clone, 1)
end