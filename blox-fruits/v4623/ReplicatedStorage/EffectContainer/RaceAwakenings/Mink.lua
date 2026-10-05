local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local mink = FX:WaitForChild("RaceAwakenings").Mink

local function ScaleParticle(p, p2)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, p.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p2, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return function(data)
	if data.index == 1 then
		local clone = FX:WaitForChild("RaceEffects")[data.strength >= 2 and "MinkTornadoBigger" or "MinkTornadoSmaller"]:Clone()
		clone:SetPrimaryPartCFrame(CFrame.new(data.position))
		clone.Parent = workspace._WorldOrigin
		local v = {}

		if data.strength >= 0 then
			for _, descendant in pairs(clone:GetDescendants()) do
				if not descendant:GetAttribute("TimeLength") then
					continue
				end

				descendant:SetAttribute("TimeLength", descendant:GetAttribute("TimeLength") * 1.4)
				table.insert(v, descendant)
			end
		else
			for _, descendant in pairs(clone.ResizingTornado:GetDescendants()) do
				if not descendant:GetAttribute("TimeLength") then
					continue
				end

				descendant:SetAttribute("TimeLength", descendant:GetAttribute("TimeLength") * 1.4)
				table.insert(v, descendant)
			end

			table.insert(v, clone.ResizingTornado)
		end

		Util.Sound:Play("SpinWoosh2", data.position, nil, 1.5 + math.random(-42, 42) / 100, 0.75)
		local debris = Util.Debris
		local PlaySchemes = require(game.ReplicatedStorage.Common.InterpolationScheme.PlaySchemes)
		debris:AddItem(clone, PlaySchemes(v))
	elseif data.index == 2 then
		local reference = data.reference
		local root = data.root

		if not reference then
			return
		end

		local clone = mink.ZCharge.Attachment:Clone()
		clone.Parent = root
		local children = clone:GetChildren()
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		local v = Sound:Play("ElectricLoopable", root)
		local lastTime = tick()

		while wait() and reference.Parent do
			local v2 = tick() - lastTime

			if v2 > 0.45 then
				break
			end

			for _, v3 in pairs(children) do
				v3.Size = ScaleParticle(v3, 1 - v2 * 0.2)
			end
		end

		for _, v2 in pairs(children) do
			v2.Enabled = false
		end

		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:FadeOut(v, 0.05)
		wait(0.1)
		pcall(function()
			v:Stop()
			v:Destroy()
		end)
		wait(1.5)
		clone:Destroy()
	end
end