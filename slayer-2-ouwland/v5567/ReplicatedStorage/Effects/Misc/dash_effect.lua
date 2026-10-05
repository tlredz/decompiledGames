local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Utility = require(game.ReplicatedStorage.CAM.Global.Utility)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Terrain }
raycastParams.IgnoreWater = false

local function isWaterHit(raycastResult: RaycastResult?, p)
	if raycastResult ~= nil and raycastResult.Material == Enum.Material.Water then
		return true
	end

	local parent = p ~= nil and p.Parent or nil
	return parent ~= nil and parent:GetAttribute("SwimState") == 2
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local modulesByName = {}

for _, moduleScript in pairs(script.Ignore:GetChildren()) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local v = {}
return function(instance, p, p2, value)
	if instance ~= nil and (instance.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 150 and p ~= nil then
		local v2 = not instance.Parent and 0 or instance.Parent:GetAttribute("dashAddY") or 0
		local v3 = instance.CFrame * CFrame.new(0, 1, 0).Position
		local raycastResult = workspace:Raycast(v3, createVector(0, -7, 0), raycastParams)
		local v4

		if raycastResult == nil or raycastResult.Material ~= Enum.Material.Water then
			local parent

			if instance ~= nil then
				parent = instance.Parent or nil
			end

			if parent == nil then
				v4 = false
			else
				v4 = parent:GetAttribute("SwimState") == 2
			end
		else
			v4 = true
		end

		if v4 then
			if script:FindFirstChild("Dash_Sound_Water") == nil then
				v4 = false
			else
				v4 = script:FindFirstChild("Part_Water") ~= nil
			end
		end

		if value == nil then
			local accessories = instance.Parent:FindFirstChild("Accessories")

			if accessories and accessories:FindFirstChild("CustomRig") then
				local settings = accessories.CustomRig:FindFirstChild("Settings")

				if settings then
					local customDashEffect = settings:FindFirstChild("CustomDashEffect")

					if customDashEffect ~= nil then
						value = customDashEffect.Value
					end
				end
			end
		end

		local v5

		if value == nil or not modulesByName[value] then
			v5 = false
		else
			v5 = modulesByName[value](instance, p, p2) == true
		end

		if not v5 then
			local clone = v4 and script.Dash_Sound_Water:Clone() or script.Dash_Sound:Clone()
			clone.Parent = instance
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
		end

		if not v5 and instance.Parent:FindFirstChild("RightHand") and instance.Parent:FindFirstChild("LeftHand") and instance.Parent:FindFirstChild("RightFoot") and instance.Parent:FindFirstChild("LeftFoot") then
			local clone = script.PartT:Clone()
			clone.Weld.Part1 = instance.Parent.RightHand
			clone.Parent = instance.Parent.RightHand
			DebrisModule:AddItem(clone, 0.8)
			local clone2 = script.PartT:Clone()
			clone2.Weld.Part1 = instance.Parent.LeftHand
			clone2.Parent = instance.Parent.LeftHand
			DebrisModule:AddItem(clone2, 0.8)
			local clone3 = script.PartT:Clone()
			clone3.Weld.Part1 = instance.Parent.RightFoot
			clone3.Parent = instance.Parent.RightFoot
			DebrisModule:AddItem(clone3, 0.8)
			local clone4 = script.PartT:Clone()
			clone4.Weld.Part1 = instance.Parent.LeftFoot
			clone4.Parent = instance.Parent.LeftFoot
			DebrisModule:AddItem(clone4, 0.8)
			task.spawn(function()
				local WAIT_INTERVAL = 0.015
				task.wait(0.1)

				for _ = 1, 2 do
					if p2 == true then
						local cFrame = instance.CFrame
						local clone5 = script.Ring:Clone()
						clone5.CFrame = CFrame.new(cFrame.Position, cFrame.Position + p * 3) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
						clone5.Parent = workspace.Debree
						local v6 = clone5.Size * 2
						TweenService:Create(clone5, tweenInfo, {
							Size = Vector3.new(v6.X, 0, v6.Z),
							Transparency = 1
						}):Play()
						DebrisModule:AddItem(clone5, 0.3)
					end

					task.wait(0.105)
				end

				if clone ~= nil and clone:FindFirstChild("Trail") ~= nil then
					clone.Trail.Enabled = false
				end

				task.wait(WAIT_INTERVAL)

				if clone2 ~= nil and clone2:FindFirstChild("Trail") then
					clone2.Trail.Enabled = false
				end

				task.wait(WAIT_INTERVAL)

				if clone3 ~= nil and clone3:FindFirstChild("Trail") ~= nil then
					clone3.Trail.Enabled = false
				end

				task.wait(WAIT_INTERVAL)

				if clone4 ~= nil and clone4:FindFirstChild("Trail") ~= nil then
					clone4.Trail.Enabled = false
				end
			end)
		end

		if v5 then
			if value == nil then
				v5 = false
			else
				v5 = v[value] == true
			end
		end

		if not v5 and raycastResult ~= nil and raycastResult.Instance ~= nil then
			local clone = v4 and script.Part_Water:Clone() or script.Part:Clone()

			if v4 ~= true then
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end
				end
			end

			clone.Weld.Part1 = instance
			clone.Weld.C1 = CFrame.new(0, v2, 0) * clone.Weld.C1
			clone.Parent = instance
			local v6 = 0
			local parent = instance.Parent

			if parent then
				local humanoid = parent:FindFirstChild("Humanoid")

				if humanoid then
					v6 = 2 - humanoid.HipHeight
				end
			end

			local raycastResult2 = workspace:Raycast(
				v3 + createVector(0, 2, 0) + p * 8,
				createVector(0, -10, 0),
				raycastParams
			)

			if raycastResult2 then
				v6 += (raycastResult2.Position.Y - raycastResult.Position.Y) * 0.8
			end

			if clone:FindFirstChild("Attachment") then
				local vector2 = clone.Attachment.WorldPosition + Vector3.new(0, v2, 0)

				if Utility.IsMeshRig(instance.Parent) then
					vector2 = Vector3.new(vector2.X, raycastResult.Position.Y, vector2.Z)
				end

				clone.Attachment.WorldCFrame = CFrame.new(vector2, vector2 + p * 3) * CFrame.Angles(
					0,
					-1.5707963267948966,
					0
				)
				vfxUtility.EmitAll(clone.Attachment, vfxUtility.Owned(instance))
			end

			DebrisModule:AddItem(clone, 2)
			local v7 = false

			local function Stop()
				if v7 == false then
					v7 = true

					for _, emitter in pairs(clone:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end
			end

			task.spawn(function()
				local v8 = false

				while instance ~= nil and clone ~= nil and clone.Parent ~= nil and v7 == false do
					local velocity = instance.Velocity
					local v9 = Vector3.new(velocity.X, 0, velocity.Z).Magnitude <= 10

					if v8 ~= v9 then
						v8 = v9

						for _, emitter in pairs(clone:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = not v9
							end
						end
					end

					task.wait()
				end
			end)
			task.delay(v4 and 0.46 or 0.48, function()
				Stop()
			end)
		end
	end
end