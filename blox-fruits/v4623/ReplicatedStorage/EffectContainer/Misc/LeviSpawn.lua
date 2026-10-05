local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local _ = Util.Debris
local _ = Util.Sound
local _ = Util.Luno.Misc
local _ = Util.PartCache

local function getCFrameFromAngleAndSegments(cframe, p, i)
	if p > 3 or p < -3 then
		p = math.rad(p)
	end

	local midpoint = (p + p * i) / 2
	local v2 = p / 2 * i
	local v3 = math.sin(3.141592653589793 - v2) * 557.33627 / math.sin(p / 2)
	return cframe * CFrame.Angles(0, midpoint, 0) * CFrame.new(0, 0, -v3) * CFrame.Angles(0, midpoint - p, 0)
end

local function getLeviathanParts()
	local childrenBySegmentId = {}

	for _, child in pairs(workspace.Enemies:GetChildren()) do
		if not child.Name:match("Leviathan") then
			continue
		end

		if child.Name == "Leviathan" then
			childrenBySegmentId["5"] = child
		else
			childrenBySegmentId[tostring((child:GetAttribute("SegmentId")))] = child
		end
	end

	return childrenBySegmentId
end

local v = {}
local v2 = {
	Appear = function(_)
		v = {}

		for i = 1, 5 do
			local v3 = {
				Model = game.ReplicatedStorage.Assets.Models.Leviathan:Clone(),
				Anims = {}
			}
			v3.Model.Parent = workspace

			for _, part in pairs(v3.Model:GetDescendants()) do
				if part:IsA("MeshPart") then
					part.Transparency = 1
				end

				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
			end

			if i > 1 and i < 5 then
				v3.Anims.RingIdle = v3.Model.Humanoid.Animator:LoadAnimation(v3.Model.Animations.RingIdleStill)
				v3.Anims.RingIdle:Play()
			elseif i == 5 then
				v3.Anims.HeadIdle = v3.Model.Humanoid.Animator:LoadAnimation(v3.Model.Animations.HeadIdle)
				v3.Anims.HeadIdle:Play()
			elseif i == 1 then
				v3.Anims.TailIdle = v3.Model.Humanoid.Animator:LoadAnimation(v3.Model.Animations.TailIdle)
				v3.Anims.TailIdle:Play()
			end

			v3.Model:SetPrimaryPartCFrame(getCFrameFromAngleAndSegments(CFrame.new(20000, -4, 15000), 30, i) + Vector3.new(
				0,
				i == 5 and 0 or -100,
				0
			))
			table.insert(v, v3)
		end
	end,
	Hurt = function(list)
		tick()
		local v3 = list[1][4]

		if not v3 or (v3.PrimaryPart.CFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 3000 then
			return
		end

		local v4 = math.max(list[2] - workspace:GetServerTimeNow(), 0)
		task.wait(v4)
		local currentCamera = workspace.CurrentCamera
		local RunService = game:GetService("RunService")
		RunService:UnbindFromRenderStep("CinematicCam")
		local RunService2 = game:GetService("RunService")
		RunService2:BindToRenderStep("CinematicCam", Enum.RenderPriority.Camera + 2, function()
			currentCamera.CFrame = v3.HumanoidRootPart.CFrame * CFrame.new(0, 190, -946) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
		end)
		local track = v[5].Humanoid.Animator:LoadAnimation(v[5].Animations.Hurt)
		local track2 = v[5].Humanoid.Animator:LoadAnimation(v[5].Animations.MainBackward)
		track:Play()
		task.wait(3)
		track:Stop(1)
		track2:Start(1)
		local v5 = list[1][4]
		local cFrame = v5.HumanoidRootPart.CFrame
		local track3 = list[1][4].Humanoid.Animator:LoadAnimation(list[1][4].Animations.Hit)
		track3.Looped = false
		track3:Play()

		for i = 1, 3 do
			local v6 = list[1][i]
			local TweenService = game:GetService("TweenService")
			TweenService:Create(v6.HumanoidRootPart, TweenInfo.new(1.7), {
				CFrame = v6.HumanoidRootPart.CFrame * CFrame.new(0, -400, 0)
			}):Play()
		end

		task.wait(2.2)
		track3:AdjustSpeed(0.3)
		local total = 0

		while total < 2 do
			local v6 = task.wait()
			total += v6
			v5.HumanoidRootPart.Weld.C0 *= CFrame.Angles(0, math.rad(v6 * 600), 0) * CFrame.new(0, -320 * v6, 0)
		end

		track3:Stop()
		v5.HumanoidRootPart.Weld.C0 = CFrame.new(0, -690, 320) * CFrame.Angles(0.8726646259971648, 0, 0)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(v5.HumanoidRootPart.Weld, TweenInfo.new(2), {
			C0 = CFrame.new(0, 0, 320)
		}):Play()
		v5.Humanoid.Animator:LoadAnimation(v5.Animations.Run):Play()
		local total2 = 0

		while total2 < 1 do
			total2 += task.wait()
			currentCamera.CFrame = cFrame * CFrame.Angles(0, math.rad(total2 * 180), 0) * CFrame.new(
				0,
				190 - total2 * 70,
				total2 * 900 + -946
			) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(math.rad(total2 * -20), 0, 0)
		end

		wait(1)
		currentCamera.CameraType = Enum.CameraType.Custom
	end,
	Hurt2 = function(_)
		for _, v3 in pairs(v) do
			for _, part in pairs(v3.Model:GetChildren()) do
				if part:IsA("MeshPart") then
					part.Transparency = 0
				end
			end
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = v[5].Model.PrimaryPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(
			0,
			200,
			600
		)
		v[5].Model.Humanoid.Animator:LoadAnimation(v[5].Model.Animations.Panic):Play()
		task.wait(8)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end,
	Escape = function(list)
		local _, v3 = unpack(list)

		if workspace:GetServerTimeNow() < v3 then
			task.wait(workspace:GetServerTimeNow() - v3)
		end

		for _, v4 in pairs(v) do
			v4.Looped = false
			v4.Anims.Appear:GetMarkerReachedSignal("End"):Wait()
			v4.Model:Destroy()
		end
	end,
	Refresh = function(_)
		for _, v3 in pairs(v) do
			for _, part in pairs(v3.Model:GetChildren()) do
				if part:IsA("MeshPart") then
					part.Transparency = 1
				end
			end
		end

		local function fix(child)
			if not child.Name:match("Leviathan") then
				return
			end

			local animator = child:WaitForChild("Humanoid"):WaitForChild("Animator")
			local v3 = {
				child.Animations.RingSnakeMotion.AnimationId,
				child.Animations.TailIdle.AnimationId,
				child.Animations.HeadIdle.AnimationId
			}
			local SyncAnims = require(game.ReplicatedStorage.Util.SyncAnims)
			SyncAnims(
				animator,
				{
					child.Animations.RingSnakeMotion.AnimationId,
					child.Animations.TailIdle.AnimationId,
					child.Animations.HeadIdle.AnimationId
				}
			)

			for _, v4 in pairs(child.Humanoid.Animator:GetPlayingAnimationTracks()) do
				if not table.find(v3, v4.Animation.AnimationId) then
					v4:Stop()
				end
			end
		end

		for _, child in pairs(workspace.Enemies:GetChildren()) do
			fix(child)
		end
	end,
	Died = function(_) end,
	HarpoonHit = function(_) end,
	UpdatePositions = function(list)
		local v3, v4, v5, v6 = unpack(list)
		local count = #v3
		local v7 = #v3 - 1

		if v5 then
			for k, v8 in pairs(v) do
				if v7 < k and k ~= 5 then
					for _, part in pairs(v8.Model:GetChildren()) do
						if part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end
				else
					if k == 5 then
						k = count
					end

					for _, anim in pairs(v8.Anims) do
						anim:Stop()
					end

					v8.Model:SetPrimaryPartCFrame(v3[k].CFrame - createVector(0, 100, 0))
					v8.Anims.Appear = v8.Model.Humanoid.Animator:LoadAnimation(v8.Model.Animations.MainForward)
					v8.Anims.StayUnder = v8.Model.Humanoid.Animator:LoadAnimation(v8.Model.Animations.MainForward)
					v8.Anims.StayUnder:Play(0.1, 1, 0)
					v8.Anims.StayUnder.Priority = Enum.AnimationPriority.Movement
					local v9 = v8
					v8.Anims.Appear.DidLoop:Connect(function()
						v9.Anims.Appear:AdjustSpeed(0)
					end)
					v8.Looped = true

					if k == count then
						v8.Anims.Appear:Play(0, 1, 0)
					else
						v8.Anims.Appear:Play(0, 1, (k == 1 and 2 or 1) * v6 or 1)
						v8.Anims.Appear.TimePosition = 1 + 0.1 * math.random()
					end

					v8.Anims.Appear.Looped = true
					v8.Anims.Appear.Priority = Enum.AnimationPriority.Action
					local v10 = v8
					task.spawn(function()
						while task.wait() and v10.Anims.Appear.IsPlaying do
							local timeOfKeyframe = 1e999
							pcall(function()
								timeOfKeyframe = v10.Anims.Appear:GetTimeOfKeyframe("TailLoopEnds")
							end)

							if timeOfKeyframe < v10.Anims.Appear.TimePosition and v10.Looped then
								v10.Anims.Appear.TimePosition = v10.Anims.Appear:GetTimeOfKeyframe("TailLoopStarts")
							end
						end
					end)
				end
			end
		end

		if workspace:GetServerTimeNow() < v4 then
			task.wait(workspace:GetServerTimeNow() - v4)
		end

		local RunService = game:GetService("RunService")
		RunService.PreAnimation:Wait()

		if v5 then
			for i, v8 in ipairs(v) do
				if not (i == 5 or i <= v7) then
					continue
				end

				if i == 5 then
					i = count
				end

				for _, part in pairs(v8.Model:GetChildren()) do
					if part:IsA("MeshPart") then
						part.Transparency = 0
					end
				end

				if i == 1 then
					v8.Looped = false
				elseif i == count then
					v8.Anims.Appear:AdjustSpeed(v6 or 1)
				end
			end
		else
			for i, v8 in ipairs(v) do
				if not (i == 5 or i <= v7) then
					continue
				end

				if i == 5 then
					i = count
				end

				if i == count then
					v8.Anims.Appear.TimePosition = 0
					v8.Anims.Appear:AdjustSpeed(v6 or 1)
				else
					local v9 = i + 1
					local v10 = v7 < v9 and 5 or v9
					v8.Anims.Appear.TimePosition = v[v10].Anims.Appear.TimePosition
					v8.Anims.Appear:AdjustSpeed((i == 1 and 2 or 1) * v6 or 1)
				end

				v8.Model:SetPrimaryPartCFrame(v3[i].CFrame - createVector(0, 100, 0))
			end
		end
	end
}
return function(list)
	local v3 = list[1]
	table.remove(list, 1)
	return v2[v3](list)
end