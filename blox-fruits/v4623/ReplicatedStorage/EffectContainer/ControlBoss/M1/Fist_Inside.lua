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
local object = setmetatable({}, {
	__mode = "k"
})
return function(player)
	local _ = player.DataModelId
	local v = player.Proxy and object[player.Proxy] or ObjectClass.Stored[player.DataModel] or ObjectClass.Selected
	local isSelectionLocked = ObjectClass:IsSelectionLocked()
	local player2 = player.Player
	local _ = player.Character

	if player.Action == "AIHighlight" then
		local proxy = player.Proxy
		local v2 = proxy and object[proxy]

		if not (v2 and v2.Model and v2.Model.Parent) then
			return
		end

		pcall(function()
			v2:Flash()
		end)
		local main = v2.Model:FindFirstChild("Main", true)

		if main and main:IsA("BasePart") then
			local size = main.Size
			VisualHelper:Tween(main, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = size * 1.12
			})
			task.delay(0.08, function()
				if main and main.Parent then
					VisualHelper:Tween(main, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Size = size
					})
				end
			end)
			local outline = main:FindFirstChild("Outline")
			local decal = outline and outline:FindFirstChild("Decal")

			if decal and decal:IsA("Decal") then
				local transparency = decal.Transparency
				decal.Transparency = math.min(transparency, 0.15)
				task.delay(0.15, function()
					if decal and decal.Parent then
						VisualHelper:Tween(decal, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
							Transparency = transparency
						})
					end
				end)
			end
		end

		local v3 = math.clamp(tonumber(v2.Model:GetAttribute("SizeScale")) or 1, 1, 3)
		local v4 = {
			"CTRLFRT_Fist_CubeLift_Small_01",
			"CTRLFRT_Fist_CubeLift_Medium_01",
			"CTRLFRT_Fist_CubeLift_Large_01"
		}
		pcall(function()
			local position = v2.Model.PrimaryPart and v2.Model.PrimaryPart.Position or v2:GetPivot().Position
			Util.Sound:Play(v4[v3], position)
		end)
	elseif player.Action == "AIAimStart" then
		local proxy = player.Proxy
		local v2 = proxy and object[proxy]

		if not (v2 and v2.Model and v2.Model.Parent) then
			return
		end

		local targetHRP = player.TargetHRP

		if not (targetHRP and targetHRP.Parent) then
			return
		end

		v2.ThrowData = v2.ThrowData or {}
		local throwData = v2.ThrowData
		local followTime = player.FollowTime or 1
		local aimSpeed = player.AimSpeed or 55

		-- equivalent calls inferred from this helper; original call sites unknown
		local function groundRC(position: Vector3)
			local v4 = position + createVector(0, 200, 0)
			local v5 = { workspace.Map }
			return MathHelper:RayCast(v4, createVector(0, -1200, 0), v5, Enum.RaycastFilterType.Include)
		end

		local function pivotIndicatorFromRC(rayCastResult: RaycastResult)
			local mouseArea = throwData.MouseArea

			if mouseArea and mouseArea.Parent then
				throwData.RayCastResult = rayCastResult
				mouseArea:PivotTo(CFrame.lookAt(rayCastResult.Position, rayCastResult.Position + rayCastResult.Normal) * CFrame.new(
					0,
					0,
					-1
				) * CFrame.Angles(-1.5707963267948966, 0, 0))
			end
		end

		local mouseArea = throwData.MouseArea

		if not (mouseArea and mouseArea.Parent) then
			mouseArea = v2.Maid:GiveTask(ObjectClass:CreateMouseArea(v2:GetLayoutSize()))
			throwData.MouseArea = mouseArea
		end

		if throwData.AIAimConn then
			throwData.AIAimConn:Disconnect()
			throwData.AIAimConn = nil
		end

		local rayCastResult2 = groundRC(targetHRP.Position) -- equivalent call inferred; original call site unknown
		local position2

		if rayCastResult2 then
			position2 = rayCastResult2.Position
			throwData.TargetPosition = position2
			pivotIndicatorFromRC(rayCastResult2)
		else
			position2 = targetHRP.Position
			throwData.TargetPosition = position2
		end

		local lastTime = tick()
		throwData.AIAimConn = RunService.RenderStepped:Connect(function(dt)
			local v4 = math.clamp(dt, 0, 0.05)

			if not (mouseArea and mouseArea.Parent) then
				return
			end

			if not (v2 and v2.Model and v2.Model.Parent) then
				return
			end

			if not (targetHRP and targetHRP.Parent) then
				return
			end

			local rayCastResult = groundRC(targetHRP.Position) -- equivalent call inferred; original call site unknown
			local v6 = (rayCastResult and rayCastResult.Position or targetHRP.Position) - position2
			local magnitude = v6.Magnitude

			if magnitude > 0.001 then
				local v7 = math.min(magnitude, aimSpeed * v4)
				position2 += v6.Unit * v7
			end

			throwData.TargetPosition = position2
			local rayCastResult3 = groundRC(position2) -- equivalent call inferred; original call site unknown

			if rayCastResult3 then
				pivotIndicatorFromRC(rayCastResult3)
			elseif rayCastResult then
				pivotIndicatorFromRC(rayCastResult)
			end

			if followTime <= tick() - lastTime then
				throwData.AILockedPos = position2
				throwData.TargetPosition = position2

				if throwData.AIAimConn then
					throwData.AIAimConn:Disconnect()
					throwData.AIAimConn = nil
				end
			end
		end)
	elseif player.Action == "AIThrow" then
		local proxy = player.Proxy
		local v2 = proxy and object[proxy]

		if not (v2 and v2.Model and v2.Model.Parent and player.MousePos) then
			return
		end

		pcall(function()
			proxy:SetAttribute("Throwing", true)
		end)
		v2.ThrowData = v2.ThrowData or {}
		local throwData = v2.ThrowData

		if v2.GetMode and v2:GetMode() ~= "Planing" then
			pcall(function()
				v2:SwitchMode("Planing", true)
			end)
		end

		local position = v2:GetPivot().Position
		local mousePos = player.MousePos
		local v4 = mousePos + createVector(0, 250, 0)
		local v5 = { workspace.Map, workspace.Terrain, workspace._WorldOrigin }
		local rayCast = MathHelper:RayCast(v4, createVector(0, -1200, 0), v5, Enum.RaycastFilterType.Include)

		if not rayCast then
			local v6 = mousePos - position
			rayCast = MathHelper:RayCast(
				position,
				(v6.Magnitude < 0.001 and createVector(0, -1, 0) or v6.Unit) * 2000,
				{ workspace.Map, workspace.Terrain, workspace._WorldOrigin },
				Enum.RaycastFilterType.Include
			)
		end

		if not rayCast then
			return
		end

		throwData.RayCastResult = rayCast
		throwData.TargetPosition = mousePos
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
		object[proxy] = nil
	else
		if player.Action == "Deselect" or player.Action == "Select" then
			local v2

			if v then
				if v.__type == ObjectClass.__type then
					v2 = not isSelectionLocked or player.Proxy
				else
					v2 = false
				end
			else
				v2 = v
			end

			if v2 then
				v[player.Action](v)

				if player.Action == "Select" then
					v.ThrowData = v.ThrowData or {}

					if player.MousePos then
						v.ThrowData.TargetPosition = player.MousePos
					end

					if player.RayCastResult then
						v.ThrowData.RayCastResult = player.RayCastResult
					end
				end

				if not player.Holding then
					return
				end

				local holding = player.Holding

				repeat
					task.wait()
				until not (holding and holding.Value)

				local model = v.Model
				local position = model:GetPivot().Position
				local v3

				if player.MousePos then
					v3 = player.MousePos
				end

				local v4 = v3 - position
				local v5 = v4.Magnitude < 0.001 and createVector(0, -1, 0) or v4.Unit
				local _, _, _ = Util.Ray(position, v5 * 700, {
					workspace._WorldOrigin,
					model.Parent.Parent,
					workspace.Characters,
					workspace.Enemies
				})
				local v6 = {
					"CTRLFRT_Fist_Release_Small_0",
					"CTRLFRT_Fist_Release_Medium_0",
					"CTRLFRT_Fist_Release_Large_0"
				}
				local v7 = v6[math.clamp(tonumber(model:GetAttribute("SizeScale")) or 1, 1, #v6)]

				if v7 and model.PrimaryPart then
					Util.Sound:Play(v7 .. tostring(math.random(1, 4)), model.PrimaryPart.Position)
				end

				v:Throw(function(p)
					print("throlw sped")
					Effect.new("ControlRework.ObjectExplosion"):play({
						Position = p.Position,
						Normal = p.Normal,
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
				if not player.SelectedModels or player.SelectedModels[k.Name] then
					table.insert(v2, v3)
				end
			end

			local v3 = -1
			ObjectClass:MultipleSelect(v2, function(object2)
				v3 += 1
				local v4 = v3 / #v2
				local throwData = object2.ThrowData
				local model = object2.Model
				local mouseArea = object2.Maid:GiveTask(ObjectClass:CreateMouseArea(object2:GetLayoutSize()))
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
				local mousePos, rayCastResult

				if player.MousePos and player.RayCastResult then
					mousePos = player.MousePos
					rayCastResult = player.RayCastResult
				end

				for _, v4 in v2 do
					if v4.IsThrowing then
						renderSteppedConnection:Disconnect()
					end

					local throwData = v4.ThrowData
					local position = v4:GetPivot().Position
					local cframe

					if rayCastResult then
						cframe = CFrame.lookAt(rayCastResult.Position, rayCastResult.Position + rayCastResult.Normal)
					else
						cframe = CFrame.lookAt(mousePos, position)
					end

					local v5 = 0 + throwData.MouseCFrameYOffset.Y
					local position2 = (cframe * throwData.MouseCFrameOffset * throwData.MouseCFrameYOffset * CFrame.new(
						math.cos(v5) * 25,
						math.sin(v5) * 25,
						0
					)).Position
					local rayCast = MathHelper:RayCast(
						position,
						CFrame.lookAt(position, position2).LookVector * 2000,
						{ workspace.Map },
						Enum.RaycastFilterType.Include
					)

					if not rayCast then
						break
					end

					throwData.RayCastResult = rayCast
					throwData.MouseArea:PivotTo(CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.new(
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
				local _ = model:GetPivot().Position
				local v5 = {
					"CTRLFRT_Fist_Release_Small_0",
					"CTRLFRT_Fist_Release_Medium_0",
					"CTRLFRT_Fist_Release_Large_0"
				}
				local v6 = v5[math.clamp(tonumber(model:GetAttribute("SizeScale")) or 1, 1, #v5)]

				if v6 and model.PrimaryPart then
					Util.Sound:Play(v6 .. tostring(math.random(1, 4)), model.PrimaryPart.Position)
				end

				local v7 = v4
				v4:Throw(function(p)
					Effect.new("ControlRework.ObjectExplosion"):play({
						Position = p.Position,
						Normal = p.Normal,
						Object = v7.Custom and v7.Custom or v7.Model.Main,
						Energized = v7.Energized,
						Scale = 2.15 * v7:GetLayoutSize(),
						IsCustom = v7.Custom and true or false
					})
					v7:Destroy()
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
		clone.Parent = workspace._WorldOrigin
		VisualHelper:SetEnableAll(clone, true)
		local v2 = ObjectClass.new(player2, cframe, proxy)
		object[proxy] = v2
		local v3 = not proxy and 1 or proxy:GetAttribute("SizeScale") or 1
		v2.Model:SetAttribute("SizeScale", v3)

		local function EmitExpansionExplosion(p: number)
			local clone2 = M1.ExpansionExplosion:Clone()
			clone2:ScaleTo(p * 1.5)
			clone2:PivotTo(clone:GetPivot())
			clone2.Parent = workspace._WorldOrigin
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
		local v4 = ObjectClass.TemplateModel.Main.Size / 3
		local outline = main.Outline
		local transparency = outline.Decal.Transparency
		outline.Decal.Transparency = 1
		local flag = nil
		local thread = nil
		local size = nil
		local v6 = nil

		local function SmoothScaleTo(p: number)
			if thread then
				task.cancel(thread)
			end

			flag = true
			clone:ScaleTo(p)
			clone:PivotTo(cframe * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0))
			v2:ScaleTo(p)
			size = v4 * p
			v6 = cframe * CFrame.new(0, 0, -(size.Y / 2 + 0))
			v2:PivotTo(cframe * cframe2)
			v2:SetSize(createVector(0, 0, 0))
			VisualHelper:Tween(main, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = size * createVector(1.35, 0.3, 1.35),
				CFrame = main.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
			})
			thread = task.delay(0.1, function()
				VisualHelper:Tween(main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = size,
					CFrame = v6 * cframe2
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
			clone2.Parent = camera
			VisualHelper:SetEnableAll(clone2, true)
			VisualHelper:EmitAll(clone2)
			player.Holding.Changed:Once(function()
				holding = false
			end)
			local sizeScale = v2.Model:GetAttribute("SizeScale") or 1
			v2.Model:SetAttribute("SizeScale", sizeScale)
			local v7 = {
				"CTRLFRT_Fist_CubeSpawn_Small_01",
				"CTRLFRT_Fist_CubeSpawn_Medium_01",
				"CTRLFRT_Fist_CubeSpawn_Large_01"
			}
			Util.Sound:Play(v7[sizeScale], main.Position)
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
				sizeScale += 1
				Util.Sound:Play(v7[sizeScale], main.Position)
				v2.Model:SetAttribute("SizeScale", sizeScale)
			end

			Util.Sound:Play(
				({
					"CTRLFRT_Fist_CubeLift_Small_01",
					"CTRLFRT_Fist_CubeLift_Medium_01",
					"CTRLFRT_Fist_CubeLift_Large_01"
				})[sizeScale],
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
		local lastTime = tick()
		task.spawn(function()
			while true do
				local v7 = tick() - lastTime
				local cframe3 = v2:GetPivot():Lerp(planingCFrame, 0.01)
				v2:PivotTo(CFrame.new(cframe3.Position + Vector3.new(0, math.sin(v7 * 2) * 0.12)) * CFrame.Angles(cframe3:ToEulerAnglesXYZ()))
				task.wait()
			end
		end)
		task.spawn(function()
			repeat
				task.wait()
			until not proxy or not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Exploding")

			object[proxy] = nil

			if proxy:GetAttribute("Throwing") then
				return
			end

			pcall(function()
				Effect.new("ControlRework.ObjectExplosion"):play({
					Object = v2.Model.Main,
					Energized = v2.Energized,
					Scale = 2.15 * v2:GetLayoutSize()
				})
			end)

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
end