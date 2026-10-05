local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local script2 = script
local _WorldOrigin = workspace._WorldOrigin
return function(p)
	local root = p.Root
	local timestamp = p.Timestamp

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local v = math.max(0.1, 1.111 - (Util.MasterClock:GetTime() - timestamp))
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, v + 0.5)
	local cFrame = root.CFrame
	local clone = script2.Phase1.Tornado:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Weld.Part0 = root
	local clone2 = script2.Phase1.Tornado2:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	clone2.Weld.Part0 = root

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local descendantsByDescendant = {}
	local weldsByWeld = {}

	for _, weld in pairs(clone2:GetChildren()) do
		local v2 = 1

		if not weld:IsA("Weld") then
			if weld.Name == "SpinA" then
				v2 = 2
			elseif weld.Name == "SpinB" then
				v2 = 2.25
			elseif weld.Name == "SpinC" then
				v2 = 2.5
			elseif weld.Name == "SpinD" then
				v2 = 2.75
			elseif weld.Name == "SpinE" then
				v2 = 3
			else
				v2 = v2
			end
		end

		if weld:IsA("Weld") and weld.Name ~= "Weld" then
			weldsByWeld[weld] = weld
			weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(
				0,
				math.rad((math.random(-90, 90))),
				0
			)
		end

		weld:SetAttribute("Tweening", false)

		for _, descendant in pairs(weld:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendantsByDescendant[descendant] = descendant
				descendant.CurveSize0 *= v2
				descendant.CurveSize1 *= v2
				descendant.Width0 *= v2
				descendant.Width1 *= v2
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * v2,
					descendant.Position.Y * v2,
					descendant.Position.Z * v2
				)
			end
		end
	end

	local v2 = Util.Sound:Play("SpinningWithWindFast", root)
	local lastTime = tick()

	while true do
		for _, v3 in pairs(weldsByWeld) do
			if v3:GetAttribute("Tweening") ~= false then
				continue
			end

			local v4 = v3
			task.spawn(function()
				v4:SetAttribute("Tweening", true)
				local v5 = math.random(50, 150)
				local v6 = math.random(5, 15) / 200
				local tween = TweenService:Create(
					v4,
					TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = v4.Part0.CFrame:ToObjectSpace(v4.Part1.CFrame) * CFrame.Angles(0, math.rad(v5), 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v4:SetAttribute("Tweening", false)
			end)
		end

		RunService.Heartbeat:Wait()

		if not (v <= tick() - lastTime) then
			continue
		end

		Util.Sound:FadeOut(v2, 0.33)

		for _, v3 in pairs(descendantsByDescendant) do
			TweenService:Create(v3, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		break
	end
end