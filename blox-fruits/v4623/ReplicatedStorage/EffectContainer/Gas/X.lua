local _ = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Util = require(ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local X = FX:WaitForChild("Gas").X
local _WorldOrigin = workspace._WorldOrigin

local function CreateGasRings(root, cframe, folder, p)
	local ringA = nil
	local cFrame = nil
	local v2 = cframe * (root.CFrame - root.Position)
	local v3 = false
	local v4 = {}

	local function track(clone, p2, p3)
		table.insert(v4, {
			clone,
			p2,
			p3,
			0
		})
		local v5 = v4[#v4]
		v5[1].CFrame = CFrame.new(root.Position) * v5[2]
	end

	task.spawn(function()
		local v5 = 0

		while not v3 do
			for _, v6 in pairs(v4) do
				v6[1].CFrame = CFrame.new(root.Position) * v6[2] * CFrame.Angles(0, math.rad(v6[4]), 0)

				if v6[3] then
					v6[4] += v5 * 170 / 0.125
				end
			end

			v5 = task.wait()
		end
	end)

	if p == 1 then
		cFrame = v2 * CFrame.Angles(0, 0, 0.7853981633974483)
		ringA = X.Phase1.RingA
	elseif p == 2 then
		cFrame = v2 * CFrame.Angles(0.2617993877991494, 0, -0.6108652381980153)
		ringA = X.Phase1.RingB
	elseif p == 3 then
		cFrame = v2 * CFrame.Angles(-0.3490658503988659, 0, 0.7853981633974483)
		ringA = X.Phase1.RingC
	end

	local clone = ringA.SpinTrail:Clone()
	clone.CFrame = root.CFrame * cFrame
	track(clone, cFrame, true)
	clone.Parent = folder

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local clone2 = nil

	for i = 1, 4 do
		if i == 4 then
			clone2 = ringA.GasRing:Clone()
			clone2.CFrame = cFrame
			track(clone2, cFrame)
			clone2.Parent = folder

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = true
				end
			end
		end

		task.wait(0.125)
	end

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.delay(1, function()
		clone:Destroy()
	end)
	v3 = true
	task.wait(0.25)

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	local clone3 = ringA.Explosion:Clone()
	clone3.CFrame = clone2.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v5 = emitter
		task.spawn(function()
			if v5:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v5:GetAttribute("EmitDelay"))
			end

			v5:Emit(v5:GetAttribute("EmitCount"))
		end)
	end
end

return function(p)
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	if p.Holding then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local clone = X.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		local v = Util.Sound:Play("BF_GASFRUIT_UNTR_BurstingVapor_ChargeLoop_01", root)
		local descendantsByDescendant = {}

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("Attachment") and descendant.Name == "Attachment" then
				descendantsByDescendant[descendant] = descendant
			end
		end

		while true do
			for _, v2 in pairs(descendantsByDescendant) do
				v2.WorldCFrame *= CFrame.Angles(0.008726646259971648, 0.008726646259971648, 0.008726646259971648)
			end

			clone.CFrame = CFrame.new(root.Position)
			task.wait()

			if p.Holding:IsDescendantOf(workspace) and p.Holding.Value then
				continue
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			task.wait(5)
			folder:Destroy()
			return
		end
	else
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		task.delay(7, function()
			folder:Destroy()
		end)
		Util.Sound:Play("BF_GASFRUIT_UNTR_Bursting_Vapor_Fire_01", root)
		task.spawn(function()
			local cframe = CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				(math.rad((math.random(-90, 90))))
			)

			for i = 1, 3 do
				if i == 2 then
					for _ = 1, 2 do
						local v = i
						task.spawn(function()
							cframe = CFrame.Angles(
								math.rad((math.random(-90, 90))),
								math.rad((math.random(-90, 90))),
								(math.rad((math.random(-90, 90))))
							)
							CreateGasRings(root, cframe, folder, v)
						end)
					end
				else
					local v = i
					task.spawn(function()
						CreateGasRings(root, cframe, folder, v)
					end)
				end

				task.wait(0.15)
			end
		end)
	end
end