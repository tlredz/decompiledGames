local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.ParticleTween)
local CraterHandler = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterHandler)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local v2 = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.25,
	SustainTime = 10,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.15, 0.15, 0.15),
	PositionInfluence = createVector(1, 1, 1)
}
local AuraEffects = require(script.Parent.AuraEffects)
game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(game.Players.LocalPlayer.Name)

local function folderAlive(instance)
	return instance ~= nil and instance.Parent ~= nil and instance:GetAttribute("Cancelled") ~= true
end

return function(instance, p, position: Vector3)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" then
		return
	end

	local rightHand = instance:FindFirstChild("RightHand")
	instance:FindFirstChild("LeftHand")
	local name = string.format("%s SerpentSlashEffects", instance.Name)
	local name2 = string.format("%s SerpentSlashSnake", instance.Name)
	local name3 = name2 .. " Flight"
	local name4 = string.format("%s SerpentSlashSuccessEffects", instance.Name)

	local function destroySnakes()
		for _, child in parent:GetChildren() do
			if child.Name == name2 or child.Name == name3 then
				child:Destroy()
			end
		end
	end

	if p == "Start" then
		destroySnakes()
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
		DebrisModule:AddItem(folder, 7.5)
		AuraEffects.TurnOnAura(instance)
		local clone = assets.Snake:Clone()
		clone.Cube.CFrame = humanoidRootPart.CFrame * CFrame.new(1.89013671875, -3.1768875122070312, 7.566436767578125) * CFrame.fromEulerAnglesYXZ(
			-1.2545078027065802e-14,
			3.141592502593994,
			-1.6292032967157866e-7
		)
		clone.Parent = parent
		clone.Name = name2
		DebrisModule:AddItem(clone, 7.5)
		vfxUtility.WeldConstraint(clone.Cube, humanoidRootPart)
		local snakeStartup = script.Animations["Snake Startup"]
		local track = clone.AnimationController:LoadAnimation(snakeStartup)
		track:Play()
		task.delay(1.08, function()
			track:AdjustSpeed(0)
		end)
		local clone2 = assets.Jump:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -10, 0)
		clone2.Parent = folder
		vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 3)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		vfxUtility.PlaySound(sounds, "PS2snakeSSleapstart", humanoidRootPart, true)
		local clone3 = assets.BeamsSwirl:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame)
		clone3.Parent = folder
		DebrisModule:AddItem(clone3, 3)
		local clone4 = assets.Wind:Clone()
		clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 3, 0)
		clone4.Parent = folder
		DebrisModule:AddItem(clone4, 3)

		for _, beam in clone4:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.2), {
				Width0 = width0,
				Width1 = width1
			}):Play()
			local v7 = beam
			task.delay(beam:GetAttribute("EmitDuration"), function()
				TweenService:Create(v7, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		task.spawn(function()
			for i = 1, 4 do
				local v7 = folder
				local v8

				if v7 == nil or v7.Parent == nil then
					v8 = false
				else
					v8 = v7:GetAttribute("Cancelled") ~= true
				end

				if not v8 then
					break
				end

				for _, descendant in clone3["Section" .. i]:GetDescendants() do
					if descendant:IsA("Beam") then
						descendant.Enabled = true
						local width0 = descendant.Width0
						local width1 = descendant.Width1
						descendant.Width0 = 0
						descendant.Width1 = 0
						TweenService:Create(descendant, TweenInfo.new(0.2), {
							Width0 = width0,
							Width1 = width1
						}):Play()
						local v9 = descendant
						task.delay(descendant:GetAttribute("EmitDuration"), function()
							TweenService:Create(v9, TweenInfo.new(0.5), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end)
					end

					if descendant:IsA("MeshPart") then
						TweenService:Create(descendant, TweenInfo.new(1), {
							CFrame = descendant.CFrame * CFrame.Angles(0, 4.363323129985824, 0)
						}):Play()
					end
				end

				task.wait(0.15)
			end
		end)
		task.spawn(function()
			local cFrame = humanoidRootPart.CFrame

			for i = 1, 5 do
				local v7 = folder
				local v8

				if v7 == nil or v7.Parent == nil then
					v8 = false
				else
					v8 = v7:GetAttribute("Cancelled") ~= true
				end

				if not v8 then
					break
				end

				local v9 = math.random(8, 15)
				local total = 0
				local v11 = math.random(4, 9)
				local v12 = i * 2.5
				local clone5 = assets.SnakeTrail:Clone()
				clone5.Parent = folder
				local now = os.clock()
				local heartbeatConnection = nil
				local v16 = i * 1.5707963267948966
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					local v18 = folder
					local v19

					if v18 == nil or v18.Parent == nil then
						v19 = false
					else
						v19 = v18:GetAttribute("Cancelled") ~= true
					end

					if v19 then
						total += dt * v11
						v12 += 0.1
						clone5.CFrame = cFrame + Vector3.new(
							v9 * math.sin(total + v16),
							v12,
							v9 * math.cos(total + v16)
						)

						if os.clock() - now >= 1 then
							heartbeatConnection:Disconnect()
							vfxUtility.EnableAll(clone5, false)
							DebrisModule:AddItem(clone5, 2)
						end
					else
						heartbeatConnection:Disconnect()
						vfxUtility.EnableAll(clone5, false)
					end
				end)
				task.wait(0.05)
			end
		end)
		task.delay(0.5, function()
			local v7 = folder
			local v8

			if v7 == nil or v7.Parent == nil then
				v8 = false
			else
				v8 = v7:GetAttribute("Cancelled") ~= true
			end

			if not v8 then
				return
			end

			Cam_Shaker(rightHand.Position, "tinyshake_less_aggresive_preset")
			local clone5 = assets.SwordChargeEmit:Clone()
			clone5.CFrame = rightHand.CFrame
			clone5.Parent = folder
			vfxUtility.EmitAll(clone5:GetDescendants(), vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone5, 2)
			local clone6 = assets.SwordThrowCharge:Clone()
			clone6.CFrame = rightHand.CFrame
			clone6.Parent = folder
			vfxUtility.EnableAll(clone6, true, vfxUtility.Owned(instance))
			vfxUtility.WeldConstraint(clone6, rightHand)
		end)
	elseif p == "Cancel" then
		AuraEffects.TurnOffAura(instance)
		destroySnakes()

		if parent:FindFirstChild(name) then
			local child = parent:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Cancelled", true)
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)
			vfxUtility.EnableAll(child, false)
		end

		if parent:FindFirstChild(name4) then
			local folder = parent:FindFirstChild(name4)
			folder.Name = "_"
			folder:SetAttribute("Cancelled", true)
			folder:SetAttribute("Active", false)
			DebrisModule:AddItem(folder, 2.5)
			vfxUtility.EnableAll(folder, false)

			for _, sound in pairs(folder:GetDescendants()) do
				if table.find({ "MeshPart", "Part", "BasePart" }, sound.ClassName) and sound.Transparency ~= 1 then
					TweenService:Create(sound, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
				end

				if not (sound:IsA("Sound") and sound.IsPlaying) then
					continue
				end

				TweenService:Create(sound, TweenInfo.new(0.1), {
					Volume = 0
				}):Play()
				local v7 = sound
				task.delay(0.1, function()
					if v7 and v7.IsPlaying then
						v7:Stop()
					end
				end)
			end
		end
	elseif p == "Shoot" then
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")

		if typeof(position) == "Instance" then
			position = position.Position
		end

		vfxUtility.PlaySound(sounds, "PS2snakeSSshoot", rightHand, true)
		local clone = assets.SwordThrow:Clone()
		clone.CFrame = CFrame.new(rightHand.Position, position)
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		destroySnakes()
		local clone2 = assets.Snake:Clone()
		clone2.Parent = parent
		clone2.Name = name3
		clone2.Cube.Anchored = true
		clone2.Cube.CFrame = CFrame.new(rightHand.Position, position) * CFrame.Angles(0, 3.141592653589793, 0)
		local snakeLoop = script.Animations["Snake Loop"]
		clone2.AnimationController:LoadAnimation(snakeLoop):Play()
		TweenService:Create(clone2.Cube, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			CFrame = CFrame.lookAlong(position, clone.CFrame.LookVector) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		DebrisModule:AddItem(clone2, 0.25)
	elseif p == "Explode" then
		local clone = assets.SwordImpact:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = parent
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		vfxUtility.PlaySound(sounds, "PS2snakeSSgroundimp", clone, true)

		for _, beam in clone:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.2), {
				Width0 = width0,
				Width1 = width1
			}):Play()
			local v7 = beam
			task.delay(beam:GetAttribute("EmitDuration"), function()
				TweenService:Create(v7, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		CraterHandler.new("Crater", clone.CFrame * CFrame.new(0, 5, 0), {
			BlockSize = { 2, 4 },
			Radius = 12,
			Range = 59,
			PartCount = 12,
			Angle = { 45, 90 },
			Height = { -2, -1.5 },
			Tilt = { -14, 14 },
			HoldTime = 1,
			FlourishTypes = {
				Exit = "Melt",
				ExitDivision = "Iterate",
				ExitSpeed = 2
			}
		})
		CraterHandler.new("Break", clone.CFrame * CFrame.new(0, 5, 0), {
			PartCount = 10,
			BlockSize = { 0.5, 1.5 },
			Range = 15,
			Height = { 30, 60 },
			Radius = 15,
			HoldTime = 1.5
		})
		Cam_Shaker(clone.Position, "medium_shake_preset")
		AuraEffects.TurnOffAura(instance)
	elseif p == "Success" then
		AuraEffects.TurnOnAura(instance)
		local folder = Instance.new("Folder")
		folder.Name = name4
		folder.Parent = parent
		DebrisModule:AddItem(folder, 10)
		folder:SetAttribute("Active", true)
		local clone = assets.SwordImpact:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = folder
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2.25)
		Cam_Shaker(clone.Position, "medium_shake_preset")
		vfxUtility.PlaySound(sounds, "PS2snakeSSgroundimp", clone, true)
		local v7 = vfxUtility.PlaySound(sounds, "PS2snakeSScombo", humanoidRootPart, true)
		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, v2)
		local connections = {}

		local function fn()
			for _, connection in connections do
				connection:Disconnect()
			end

			if cam_Shaker then
				cam_Shaker:Stop()
				cam_Shaker:Destroy()
				cam_Shaker = nil
			end

			if v7 and v7.IsPlaying then
				v7:Stop()
			end
		end

		table.insert(connections, folder.AttributeChanged:Connect(fn))
		table.insert(connections, folder.Destroying:Connect(fn))

		for _, beam in clone:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.2), {
				Width0 = width0,
				Width1 = width1
			}):Play()
			local v9 = beam
			task.delay(beam:GetAttribute("EmitDuration"), function()
				TweenService:Create(v9, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		CraterHandler.new("Crater", clone.CFrame * CFrame.new(0, 5, 0), {
			BlockSize = { 2, 4 },
			Radius = 12,
			Range = 59,
			PartCount = 12,
			Angle = { 45, 90 },
			Height = { -2, -1.5 },
			Tilt = { -14, 14 },
			HoldTime = 1,
			FlourishTypes = {
				Exit = "Melt",
				ExitDivision = "Iterate",
				ExitSpeed = 2
			}
		})
		CraterHandler.new("Break", clone.CFrame * CFrame.new(0, 5, 0), {
			PartCount = 10,
			BlockSize = { 0.5, 1.5 },
			Range = 15,
			Height = { 30, 60 },
			Radius = 15,
			HoldTime = 1.5
		})

		if instance and instance:FindFirstChild("Basic Katana") and instance:FindFirstChild("Basic Katana"):FindFirstChild("Right"):FindFirstChild("Plane") then
			for _, beam in instance:FindFirstChild("Basic Katana"):FindFirstChild("Right"):FindFirstChild("Plane"):GetDescendants() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.4), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end
		end

		local clone2 = assets.Huge_Snake:Clone()
		clone2.Cube.CFrame = humanoidRootPart.CFrame * CFrame.new(2.848, -6.723, 16.212) * CFrame.fromEulerAnglesYXZ(
			0,
			3.141592653589793,
			-0
		)
		clone2.Parent = folder
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(clone2.PrimaryPart, humanoidRootPart)
		local snakeAttack = script.Animations["Snake Attack"]
		local track = clone2.AnimationController:LoadAnimation(snakeAttack)
		track:Play()
		local clone3 = assets.Slashes:Clone()
		clone3.CFrame = humanoidRootPart.CFrame
		clone3.Parent = folder
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(clone3, humanoidRootPart)
		task.wait(2.25)

		if not (folder:IsDescendantOf(workspace) and folder:GetAttribute("Active")) then
			return
		end

		if cam_Shaker then
			cam_Shaker:Stop()
			cam_Shaker:Destroy()
			cam_Shaker = nil
		end

		vfxUtility.EnableAll(clone3, false)
		DebrisModule:AddItem(clone3, 3)
		task.wait(0.25)

		if not (folder:IsDescendantOf(workspace) and folder:GetAttribute("Active")) then
			return
		end

		local clone4 = assets.LeftToRightSlash:Clone()
		clone4:PivotTo(CFrame.lookAlong(
			humanoidRootPart.Position + createVector(0, 1, 0),
			humanoidRootPart.CFrame.LookVector
		) * CFrame.Angles(0, -0.7853981633974483, 0))
		clone4.Parent = folder
		vfxUtility.EmitAll(clone4:GetDescendants(), vfxUtility.Owned(instance))
		Cam_Shaker(rightHand.Position, "activate_shake")
		AuraEffects.TurnOffAura(instance)
		task.wait(0.4)

		if folder:IsDescendantOf(workspace) and folder:GetAttribute("Active") then
			track:Stop()
			DebrisModule:AddItem(clone2, 0.1)
			TweenService:Create(clone2.Cube, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
		end
	end
end