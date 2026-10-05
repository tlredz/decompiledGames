local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterHandler = require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.Craters.CraterEffects)
local _ = Players.LocalPlayer
local assets = script:FindFirstChild("Assets")
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
require(modules.Effects.BoatTween)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Map }
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(instance, p, _)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if humanoidRootPart then
		if p == "Start" then
			if not debree:FindFirstChild(name) then
				local folder = Instance.new("Folder")
				folder.Name = name
				folder.Parent = debree
				DebrisModule:AddItem(folder, 12)
			end

			if v[instance] then
				v[instance] = nil
			end

			v[instance] = {}
			local v3 = v[instance]
			local child = debree:FindFirstChild(name)
			child:SetAttribute("Active", true)
			local clone = assets.EightFoldsStartup:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.6, 0) * CFrame.Angles(-1.5707963267948966, 0, 0))
			clone.Parent = child
			vfxUtility.EmitAll(clone.Part3, vfxUtility.Owned(instance))
			vfxUtility.EmitAll(clone.Part, vfxUtility.Owned(instance))
			vfxUtility.PlaySound(sounds, "PS2thunderbreath8Flaunch", humanoidRootPart, true)
			table.insert(v3, vfxUtility.PlaySound(sounds, "PS2thunderbreath8Fholdloop", humanoidRootPart))

			if workspace:Raycast(humanoidRootPart.Position, createVector(0, -10, 0), raycastParams2) then
				vfxUtility.EmitAll(clone.GroundParticleEmit, vfxUtility.Owned(instance))
			end

			local clone2 = assets.ConstantBubble:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = child
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
			vfxUtility.TweenBeams(clone2, {
				Time = 0.25
			})
			local cFrame = humanoidRootPart.CFrame
			local clone3 = assets.Dash:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = child

			local function CheckForObjectsAbove(cFrame2, p2)
				local v4 = cFrame2 * CFrame.new(0, math.random(-2, p2), 0)
				local magnitude = (cFrame2.Position - v4.Position).Magnitude
				local raycastResult = workspace:Raycast(
					cFrame2.Position,
					(v4.Position - cFrame2.Position).Unit * magnitude,
					raycastParams2
				)

				if raycastResult then
					magnitude = (cFrame2.Position - raycastResult.Position).Magnitude
				end

				return cFrame2 * CFrame.new(0, magnitude, 0)
			end

			local function CheckForObjectsAround(p2, p3)
				local v4 = p2 * CFrame.new(Random.new():NextNumber(-15, 15), 0, Random_Number(-15, 15))
				local v5 = CFrame.new(p2.Position, v4.Position) * CFrame.new(0, 0, -p3)
				local magnitude = (p2.Position - v5.Position).Magnitude
				local raycastResult = workspace:Raycast(
					p2.Position,
					(v5.Position - p2.Position).Unit * magnitude,
					raycastParams2
				)

				if raycastResult then
					magnitude = (p2.Position - raycastResult.Position).Magnitude
				end

				return CFrame.new(p2.Position, v5.Position) * CFrame.new(0, 0, -magnitude)
			end

			local function CheckForObjectsBetweenGoalAndThunder(p2, p3)
				local magnitude = (p2.Position - p3.Position).Magnitude
				local raycastResult = workspace:Raycast(
					p2.Position,
					(p3.Position - p2.Position).Unit * magnitude,
					raycastParams2
				)

				if raycastResult then
					magnitude = (raycastResult.Position - p2.Position).Magnitude
				end

				return CFrame.new(p2.Position, p3.Position) * CFrame.new(0, 0, -magnitude)
			end

			local cFrame3 = cFrame

			while child ~= nil and child.Parent ~= nil and child:GetAttribute("Active") do
				if not humanoidRootPart then
					return
				end

				local v5 = math.random(20, 25)
				cFrame3 = CheckForObjectsBetweenGoalAndThunder(
					cFrame3,
					CheckForObjectsAround(CheckForObjectsAbove(cFrame, v5), v5)
				)
				TweenService:Create(clone3, TweenInfo.new(0.035, Enum.EasingStyle.Quint), {
					CFrame = cFrame3
				}):Play()
				task.delay(0.03325, function()
					vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
				end)
				task.wait(0.035)
			end
		elseif p == "End" then
			local child = debree:FindFirstChild(name)
			local v3 = v[instance]

			if v3 then
				for _, v4 in v3 do
					v4:Destroy()
				end
			end

			if child then
				child.Name = "_"
				child:SetAttribute("Active", nil)
				DebrisModule:AddItem(child, 2)
				local eightFoldsStartup = child:FindFirstChild("EightFoldsStartup")

				if eightFoldsStartup then
					DebrisModule:AddItem(eightFoldsStartup, 1)
					vfxUtility.EnableAll(eightFoldsStartup, false)
					vfxUtility.TweenLight(eightFoldsStartup, {
						Time = 0.1,
						Off = true
					})
				end

				local constantBubble = child:FindFirstChild("ConstantBubble")

				if constantBubble then
					vfxUtility.EnableAll(constantBubble, false)
					vfxUtility.TweenBeams(constantBubble, {
						Time = 0.25,
						Off = true
					})
					DebrisModule:AddItem(constantBubble, 2)
				end

				local clone = assets.ThunderBolt:Clone()
				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.6, 0) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				))
				clone.Parent = child
				vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone, 4)
				vfxUtility.PlaySound(sounds, "PS2thunderbreath8Fend", humanoidRootPart, true)

				for _, beam in clone:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(0.1), {
						Width0 = width0,
						Width1 = width1
					}):Play()
					local v4 = beam
					task.delay(0.4, function()
						TweenService:Create(v4, TweenInfo.new(0.15), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end

				for i, child2 in clone.Meshes.Twirl:GetChildren() do
					local random_Number = Random_Number(0.25, 0.5) -- equivalent call inferred; original call site unknown
					local v5 = child2
					local v6 = i
					local v7 = child2
					local connection = RunService.Heartbeat:Connect(function()
						local v7 = v5
						local cFrame = v7.CFrame
						local v10 = math.random(1, 2) % v6 == 0
						v7.CFrame = cFrame * CFrame.Angles(0, math.rad(2.3 * 1), 0)
					end)
					task.delay(random_Number / 2, function()
						TweenService:Create(
							v7,
							TweenInfo.new(Random.new():NextNumber(0.1, 0.2), Enum.EasingStyle.Exponential),
							{
								Transparency = 1
							}
						):Play()
						task.delay(0.4, function()
							connection:Disconnect()
						end)
					end)
				end

				TweenService:Create(clone.Meshes.MeshSpecial.Start, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = clone.Meshes.MeshSpecial.End.Position,
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Meshes.MeshSpecial.Start.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Scale = clone.Meshes.MeshSpecial.End.Mesh.Scale
				}):Play()
				TweenService:Create(
					clone.Meshes.MeshSpecial.StartBlack,
					TweenInfo.new(0.125, Enum.EasingStyle.Linear),
					{
						Position = clone.Meshes.MeshSpecial.End.Position,
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone.Meshes.MeshSpecial.StartBlack.Mesh,
					TweenInfo.new(0.125, Enum.EasingStyle.Linear),
					{
						Scale = clone.Meshes.MeshSpecial.End.Mesh.Scale
					}
				):Play()
				DebrisModule:AddItem(clone.Meshes.MeshSpecial.Start, 0.1)
				DebrisModule:AddItem(clone.Meshes.MeshSpecial.StartBlack, 0.125)
				CraterHandler.new("Crater", CFrame.new(humanoidRootPart.Position) * CFrame.new(0, 3, 0), {
					BlockSize = { 4, 6 },
					Radius = 40,
					PartCount = 25,
					Angle = { 45, 69 },
					Height = { -1.5, -1 },
					Tilt = { -10, 10 },
					HoldTime = 1.5,
					FlourishTypes = {
						Exit = "Melt",
						ExitDivision = "Iterate",
						ExitSpeed = 1
					},
					Range = 30
				})
				CraterHandler.new("Crater", CFrame.new(humanoidRootPart.Position) * CFrame.new(0, 3, 0), {
					BlockSize = { 5, 7 },
					Radius = 60,
					PartCount = 45,
					Angle = { 45, 69 },
					Height = { -1.5, -1 },
					Tilt = { -10, 10 },
					HoldTime = 1.5,
					FlourishTypes = {
						Exit = "Melt",
						ExitDivision = "Iterate",
						ExitSpeed = 1
					},
					Range = 30
				})
				CraterHandler.new("Break", CFrame.new(humanoidRootPart.Position) * CFrame.new(0, 3, 0), {
					PartCount = 35,
					BlockSize = { 0.5, 2.5 },
					Range = 30,
					Height = { 30, 150 },
					Radius = 60,
					HoldTime = 1.5
				})
				Cam_Shaker(humanoidRootPart.Position, "medium_shake_preset")
			end
		elseif p == "Cancel" then
			local child = debree:FindFirstChild(name)
			local v3 = v[instance]

			if child then
				child.Name = "_"
				child:SetAttribute("Active", nil)
				DebrisModule:AddItem(child, 2)

				for _, child2 in child:GetChildren() do
					vfxUtility.EnableAll(child2, false)
					vfxUtility.TweenLight(child2, {
						Time = 0.1,
						Off = true
					})
				end
			end

			if v3 then
				for _, v4 in v3 do
					v4:Destroy()
				end

				v[instance] = nil
			end
		end
	end
end