local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local holoScene = FX:WaitForChild("DracoRace").HoloScene
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local _ = Util.BoatTween
local maid = Util.Maid
local CameraController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CameraController"))

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeInOutQuart(p)
	if p < 0.5 then
		return 8 * p ^ 4
	end

	return 1 - (-2 * p + 2) ^ 4 / 2
end

local function easeOutCubic(p)
	return p ^ 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeSine(p)
	return -(math.cos(3.141592653589793 * p) - 1) / 2
end

function easeInOutCubic(p)
	if p < 0.5 then
		return 4 * p * p * p
	end

	return 1 - math.pow(-2 * p + 2, 3) / 2
end

local keypoints = holoScene.BeamHolder.ProjectorBeam.Transparency.Keypoints
local v = {}

for _, keypoint in ipairs(keypoints) do
	table.insert(v, keypoint)
end

local function easeBeamTransparency(p: number)
	local v2 = {}

	for _, keypoint in ipairs(keypoints) do
		local time = keypoint.Time
		local value = keypoint.Value
		table.insert(v2, NumberSequenceKeypoint.new(time, value + (1 - value) * p, keypoint.Envelope))
	end

	return (NumberSequence.new(v2))
end

return function(p)
	local templeModel = p.TempleModel
	local holoModel = p.HoloModel

	if templeModel and templeModel.PrimaryPart ~= nil then
		local primaryPart = templeModel.PrimaryPart

		if (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).Magnitude > 1500 then
			return
		end

		local v2 = {}
		local part = Instance.new("Part")
		part.Size = Vector3.new()
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.CFrame = primaryPart.CFrame * CFrame.new(0, 20, 0)
		part.Parent = _WorldOrigin
		local clone = holoScene.Container.EntryPoint:Clone()
		clone.Parent = holoModel.Model.Model["PrehistoricIsland.035"]
		local clone2 = holoScene.Container.Grow:Clone()
		clone2.Parent = part
		holoModel:PivotTo(part.CFrame)
		local maid2 = maid.new()
		maid2:GiveTask(function()
			if part then
				part:Destroy()
			end

			if clone then
				clone:Destroy()
			end

			if clone2 then
				clone2:Destroy()
			end

			for _, list in pairs(v2) do
				for _, v3 in ipairs(list) do
					if not (v3 ~= nil and typeof(v3) == "table") then
						continue
					end

					for _, instance in ipairs(v3) do
						if instance:IsA("Beam") or instance:IsA("Attachment") then
							instance:Destroy()
						end
					end
				end
			end

			v2 = nil
		end)
		local currentCamera = workspace.CurrentCamera
		local v3 = CameraController.new(currentCamera, 1, 0.5)
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function releaseCamera()
			if flag then
				return
			end

			flag = true
			v3:FadeOut(0.5)
		end

		maid2:GiveTask(releaseCamera)
		local lastTime = os.clock()

		local function canRun()
			local currentCamera2 = currentCamera

			if currentCamera2 then
				if currentCamera.Parent == nil or holoModel == nil then
					return false
				else
					return primaryPart and primaryPart.Parent ~= nil
				end
			end

			return currentCamera2
		end

		local sound = Util.Sound
		local Players = game:GetService("Players")
		sound:Play("BF_Trial_Statue_Lights_Cutscene_01", Players.LocalPlayer)
		local descendants = templeModel:GetDescendants()

		for _, part2 in ipairs(descendants) do
			if not (part2:IsA("BasePart") and part2.Name == "Meshes/hydraaddition_Cylinder.030" and part2.Position.Y <= primaryPart.Position.Y + 250) then
				continue
			end

			if not (primaryPart.CFrame:pointToObjectSpace(part2.Position).Z <= 0) then
				continue
			end

			local clone3 = holoScene.Statues.LeftEye:Clone()
			local clone4 = holoScene.Statues.RightEye:Clone()
			local attachment = Instance.new("Attachment")
			local attachment2 = Instance.new("Attachment")
			local clone5 = holoScene.BeamHolder.ProjectorBeam:Clone()
			clone5.Parent = attachment
			clone5.Attachment0 = attachment
			clone5.Attachment1 = attachment2

			for _, v4 in ipairs({
				clone3,
				clone4,
				attachment,
				attachment2
			}) do
				v4.Parent = part2

				if v4 == attachment then
					v4.Position = createVector(0, 5, 0)
				end
			end

			v2[part2] = {
				false,
				false,
				{ clone3, clone4 },
				{ clone5, attachment, attachment2 }
			}
		end

		local orbs = {}
		task.spawn(function()
			local v4 = primaryPart.Position + createVector(0, 250, 0)

			for _ = 1, 80 do
				for k, v5 in pairs(v2) do
					if not (math.abs(k.Position.Y - v4.Y) <= 15 and v5[2] == false) then
						continue
					end

					v5[2] = true
					table.insert(orbs, v5[3][1].Orb)
					table.insert(orbs, v5[3][2].Orb)
					v5[3][1].Glint:Emit(1)
					v5[3][2].Glint:Emit(1)
				end

				v4 -= createVector(0, 3, 0)
				task.wait(0.05)
			end
		end)
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local v4 = 0.016666666666666666

		while true do
			local v5

			if currentCamera then
				if currentCamera.Parent == nil or holoModel == nil then
					v5 = false
				else
					v5 = primaryPart and primaryPart.Parent ~= nil
				end
			else
				v5 = currentCamera
			end

			if v5 then
				local v6 = os.clock() - lastTime

				if not (v6 > 6) then
					if os.clock() - lastTime2 > 0.5 then
						for _, v7 in ipairs(orbs) do
							v7:Emit(1)
						end

						lastTime2 = os.clock()
					end

					if v6 > 1 and v6 < 4.5 and os.clock() - lastTime3 > 0.4 then
						clone2.Particle:Emit(1)
						lastTime3 = os.clock()
					end

					local lerped = (primaryPart.CFrame * CFrame.new(0, 150, 50)):lerp(
						primaryPart.CFrame * CFrame.new(0, 35, 50) * CFrame.Angles(0.5235987755982988, 0, 0),
						(easeInOutCubic(v6 / 6))
					)
					part.CFrame = (primaryPart.CFrame * CFrame.new(0, 150, 0) * CFrame.Angles(0, 2.6179938779914944, 0)):lerp(
						primaryPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(0, 2.6179938779914944, 0) * CFrame.Angles(
							0,
							math.rad(v6 * 3),
							0
						),
						(easeInOutQuart(v6 / 6))
					)
					v3:SetCFrame(CFrame.new(lerped.p, part.Position))
					holoModel:PivotTo(part.CFrame)
					holoModel:ScaleTo(0.01 + 2.95 * easeSine(math.min(1, v6 / 6)))

					for k, v12 in pairs(v2) do
						local v13 = math.abs(k.Position.Y - part.Position.Y)

						if v13 <= 50 then
							math.clamp(v13 / 50, 0, 1)

							if v12[1] == false then
								v12[1] = true
							end

							v12[4][1].Enabled = v12[2]
							v12[4][3].WorldPosition = part.Position
							v12[4][1].Transparency = easeBeamTransparency(math.clamp(v13 / 50, 0, 1))
							v12[4][1].Width1 = 5 + 30 * math.clamp(v13 / 50, 0, 1)
						else
							v12[1] = false
							v12[4][1].Enabled = v12[2]
						end
					end

					v4 = RunService.RenderStepped:Wait()
					continue
				end
			end

			local lastTime4 = os.clock()

			while true do
				local v6

				if currentCamera then
					if currentCamera.Parent == nil or holoModel == nil then
						v6 = false
					else
						v6 = primaryPart and primaryPart.Parent ~= nil
					end
				else
					v6 = currentCamera
				end

				if v6 and not (os.clock() - lastTime4 > 1) then
					if os.clock() - lastTime2 > 0.5 then
						for _, v7 in ipairs(orbs) do
							v7:Emit(1)
						end

						lastTime2 = os.clock()
					end

					local v7 = primaryPart.CFrame * CFrame.new(0, 35, 50)
					part.CFrame *= CFrame.Angles(0, math.rad(v4 * 0.1 * 60), 0)
					v3:SetCFrame(CFrame.new(v7.p, part.Position))
					holoModel:PivotTo(part.CFrame)

					for k, v8 in pairs(v2) do
						local v9 = math.abs(k.Position.Y - part.Position.Y)

						if v9 <= 50 then
							if v8[1] == false then
								v8[1] = true
							end

							v8[4][1].Enabled = v8[2]
							v8[4][3].WorldPosition = part.Position
							v8[4][1].Transparency = easeBeamTransparency(math.clamp(v9 / 50, 0, 1))
							v8[4][1].Width1 = 5 + 30 * math.clamp(v9 / 50, 0, 1)
						else
							v8[1] = false
							v8[4][1].Enabled = v8[2]
						end
					end

					v4 = RunService.RenderStepped:Wait()
				else
					releaseCamera() -- equivalent call inferred; original call site unknown
					local now = os.clock()
					local now2 = os.clock() - 1
					holoModel.Model.Model.EntryBase.Transparency = 0.6
					holoModel.Model.Model.EntryDoor.Transparency = 0.6

					while true do
						local v7

						if currentCamera then
							if currentCamera.Parent == nil or holoModel == nil then
								v7 = false
							else
								v7 = primaryPart and primaryPart.Parent ~= nil
							end
						else
							v7 = currentCamera
						end

						if v7 then
							local _ = os.clock() - lastTime4 - now

							if holoModel and holoModel.Parent ~= nil then
								if os.clock() - lastTime2 > 0.5 then
									for _, v8 in ipairs(orbs) do
										v8:Emit(1)
									end

									lastTime2 = os.clock()
								end

								if os.clock() - now2 > 1 then
									Util.Sound:Play("BF_Trial_Minimap_Blip_01", primaryPart)
									clone.Ping:Emit(1)
									clone.PingRing:Emit(1)
									now2 = os.clock()
								end

								part.CFrame *= CFrame.Angles(0, math.rad(v4 * 0.1 * 60), 0)
								holoModel:PivotTo(part.CFrame)

								for k, v8 in pairs(v2) do
									local v9 = math.abs(k.Position.Y - part.Position.Y)

									if v9 <= 50 then
										if v8[1] == false then
											v8[1] = true
										end

										v8[4][1].Enabled = v8[2]
										v8[4][3].WorldPosition = part.Position
										v8[4][1].Transparency = easeBeamTransparency(math.clamp(v9 / 50, 0, 1))
										v8[4][1].Width1 = 5 + 30 * math.clamp(v9 / 50, 0, 1)
									else
										v8[1] = false
										v8[4][1].Enabled = v8[2]
									end
								end

								v4 = RunService.RenderStepped:Wait()
								continue
							end
						end

						maid2:DoCleaning()
						orbs = nil
						break
					end

					break
				end
			end

			break
		end
	end
end