local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(instance, vector2: Vector3, p)
	local primaryPart

	if instance ~= nil then
		primaryPart = instance.PrimaryPart or nil
	end

	if primaryPart == nil then
		return
	end

	local cframe = CFrame.new(primaryPart.Position, vector2)

	if (cframe.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	if p == "First" then
		local folder = Instance.new("Folder")
		folder.Name = "Effects"
		folder.Parent = parent
		DebrisModule:AddItem(folder, 4)
		local clone = script.Strike1:Clone()
		clone:PivotTo(primaryPart.CFrame)
		clone.Parent = folder
		local raycastResult = workspace:Raycast(
			primaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local emit = Ouwmit.Emit
		local owned = Ouwmit.Owned
		local getDustColorSettings = vfxUtility.GetDustColorSettings
		local v2

		if raycastResult ~= nil then
			v2 = raycastResult.Instance or nil
		end

		emit(clone, owned(instance, getDustColorSettings(v2)))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.DXbanditDOUBLEslash1:Clone()
		clone2.Parent = primaryPart
		DebrisModule:AddItem(clone2, clone2.TimeLength)
		clone2:Play()
		Cam_Shaker(cframe.Position, "activate_shake")
		task.delay(0.1, function()
			local clone3 = script.SlashEmithorizontal:Clone()
			clone3.CFrame = cframe * CFrame.new(-0.0758056640625, -0.2365574836730957, -6.6212158203125) * CFrame.fromEulerAnglesYXZ(
				-0,
				0,
				1.5626753568649292
			)
			clone3.Parent = folder
			vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone3, 5)
			local clone4 = script.SlashHorizontal:Clone()
			clone4.CFrame = cframe * CFrame.new(0.3232421875, -0.46233105659484863, -4.83160400390625) * CFrame.fromEulerAnglesYXZ(
				-0,
				3.141592653589793,
				-1.5966670513153076
			)
			clone4.Parent = folder
			vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone4, 4)
			task.wait(0.3)
			TweenService:Create(clone4, TweenInfo.new(0.8), {
				CFrame = cframe * CFrame.new(0, 1, -50) * CFrame.fromEulerAnglesYXZ(
					-0,
					3.141592653589793,
					-1.5966670513153076
				)
			}):Play()
			task.wait(0.6)
			vfxUtility.EnableAll(clone4, false)
		end)
	end

	if p == "Second" then
		local folder = Instance.new("Folder")
		folder.Name = "Effects"
		folder.Parent = parent
		DebrisModule:AddItem(folder, 6)
		local clone = script.Strike2:Clone()
		clone:PivotTo(primaryPart.CFrame)
		clone.Parent = folder
		local raycastResult = workspace:Raycast(
			primaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local emit = Ouwmit.Emit
		local owned = Ouwmit.Owned
		local getDustColorSettings = vfxUtility.GetDustColorSettings
		local v2

		if raycastResult ~= nil then
			v2 = raycastResult.Instance or nil
		end

		emit(clone, owned(instance, getDustColorSettings(v2)))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script["DXbanditDOUBLEslash2 (1)"]:Clone()
		clone2.Parent = primaryPart
		DebrisModule:AddItem(clone2, clone2.TimeLength)
		clone2:Play()
		local clone3 = script.SlashEmit:Clone()
		clone3.CFrame = cframe * CFrame.new(0.37518310546875, 0.32558369636535645, -6.08648681640625) * CFrame.fromEulerAnglesYXZ(
			-0.009249215014278889,
			-0.03944389149546623,
			0.03670426458120346
		)
		clone3.Parent = folder
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 5)
		local clone4 = script.SlashVertical:Clone()
		clone4.CFrame = cframe * CFrame.new(-0.24566650390625, 0.57169508934021, -4.7041015625) * CFrame.fromEulerAnglesYXZ(
			-0.006969744805246592,
			3.141592653589793,
			0.008442672900855541
		)
		clone4.Parent = folder
		vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 4)
		local drag = clone4.Drag
		task.spawn(function()
			for _ = 1, 14 do
				local drag2 = drag
				local random = Random.new()
				local v4 = TweenService
				coroutine.wrap(function()
					for i = 1, 3 do
						local v8 = drag2.WorldCFrame * CFrame.new(0, 2, 0) * CFrame.new(
							1.5 + random:NextNumber(-1, 1),
							0,
							0
						)
						local raycastResult2 = workspace:Raycast(
							v8.Position,
							createVector(0, -5, 0),
							RaycastHelper.Crater
						)

						if raycastResult2 then
							local clone5 = script.Rock:Clone()
							clone5.Parent = folder
							clone5.CFrame = CFrame.lookAt(
								raycastResult2.Position,
								raycastResult2.Position + raycastResult2.Normal
							) * CFrame.new(0, 0, 1)
							clone5.Size = createVector(0, 0, 0)
							clone5.Color = raycastResult2.Instance.Color
							clone5.Material = raycastResult2.Material
							local number = random:NextNumber(0.7, 1)
							local v9

							if random:NextNumber(1, 3) == 3 then
								v9 = v4:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
									Size = createVector(1, 1, 1) * number,
									CFrame = clone5.CFrame * CFrame.new(0, 0, random:NextNumber(-1, -0.5)) * CFrame.Angles(
										random:NextNumber(-180, 180),
										random:NextNumber(-180, 180),
										random:NextNumber(-180, 180)
									)
								})
							else
								v9 = v4:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
									Size = createVector(1, 1, 1) * number,
									CFrame = clone5.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
										random:NextNumber(-180, 180),
										random:NextNumber(-180, 180),
										random:NextNumber(-180, 180)
									)
								})
							end

							v9:Play()
							local v10 = i
							coroutine.wrap(function()
								v9.Completed:Wait()
								task.wait(2)
								task.wait(v10 / 5)
								v9:Destroy()
								local v12 = v4:Create(
									clone5,
									TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
									{
										Size = createVector(0, 0, 0),
										Position = clone5.Position + createVector(0, -2, 0),
										Orientation = createVector(0, 0, 0)
									}
								)
								v12:Play()
								v12.Completed:Wait()
								v12:Destroy()
								clone5:Destroy()
							end)()
						end

						task.wait(0.015)
					end
				end)()
				local drag3 = drag2
				local v9 = random
				local v10 = v4
				coroutine.wrap(function()
					for i = 1, 3 do
						local v11 = drag3.WorldCFrame * CFrame.new(0, 2, 0) * CFrame.new(
							-1.5 - v9:NextNumber(-1, 1),
							0,
							0
						)
						local raycastResult2 = workspace:Raycast(
							v11.Position,
							createVector(0, -5, 0),
							RaycastHelper.Crater
						)

						if raycastResult2 then
							local clone5 = script.Rock:Clone()
							clone5.Parent = folder
							clone5.CFrame = CFrame.lookAt(
								raycastResult2.Position,
								raycastResult2.Position + raycastResult2.Normal
							) * CFrame.new(0, 0, 1)
							clone5.Size = createVector(0, 0, 0)
							clone5.Color = raycastResult2.Instance.Color
							clone5.Material = raycastResult2.Material
							local number = v9:NextNumber(0.7, 1)
							local v12

							if v9:NextNumber(1, 3) == 3 then
								v12 = v10:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
									Size = createVector(1, 1, 1) * number,
									CFrame = clone5.CFrame * CFrame.new(0, 0, v9:NextNumber(-1, -0.5)) * CFrame.Angles(
										v9:NextNumber(-180, 180),
										v9:NextNumber(-180, 180),
										v9:NextNumber(-180, 180)
									)
								})
							else
								v12 = v10:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
									Size = createVector(1, 1, 1) * number,
									CFrame = clone5.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
										v9:NextNumber(-180, 180),
										v9:NextNumber(-180, 180),
										v9:NextNumber(-180, 180)
									)
								})
							end

							v12:Play()
							local v13 = i
							coroutine.wrap(function()
								v12.Completed:Wait()
								task.wait(2)
								task.wait(v13 / 5)
								v12:Destroy()
								local v15 = v10:Create(
									clone5,
									TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
									{
										Size = createVector(0, 0, 0),
										Position = clone5.Position + createVector(0, -2, 0),
										Orientation = createVector(0, 0, 0)
									}
								)
								v15:Play()
								v15.Completed:Wait()
								v15:Destroy()
								clone5:Destroy()
							end)()
						end

						task.wait(0.015)
					end
				end)()
				task.wait(0.05)
			end
		end)
		TweenService:Create(clone4, TweenInfo.new(0.8), {
			CFrame = cframe * CFrame.new(0, 1, -50) * CFrame.fromEulerAnglesYXZ(
				-0.006969744805246592,
				3.141592653589793,
				0.008442672900855541
			)
		}):Play()
		Cam_Shaker(cframe.Position, "Medium_tiny_shake_preset")
		task.wait(0.6)
		vfxUtility.EnableAll(clone4, false)
	end
end