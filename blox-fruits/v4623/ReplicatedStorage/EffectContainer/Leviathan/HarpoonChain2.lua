local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local harpoonChain2 = FX:WaitForChild("Leviathan").HarpoonChain2

local function constrainAngle(p, p2, p3, p4)
	local rightVector = p.RightVector
	local v = math.acos((rightVector:Dot(p4)))

	if v < math.rad(p2) then
		rightVector:Cross(p4)
		return p
	end

	if math.rad(p3) < v then
		rightVector:Cross(p4)
	end

	return p
end

return function(p)
	local cannonBall = p.CannonBall
	local cannon = p.Cannon

	if (cannon.Seat.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local maid = Util.Maid.new()
	local part0 = cannon.Seat.TubeWeld.Part0
	local clones = {}
	local cFrame = nil
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep("HarpoonFollow2", Enum.RenderPriority.Camera.Value - 2, function()
		if not cannonBall.Parent then
			local RunService2 = game:GetService("RunService")
			return RunService2:UnbindFromRenderStep("HarpoonFollow2")
		end

		if cFrame then
			workspace.CurrentCamera.CFrame = cFrame
		end
	end)
	local RunService2 = game:GetService("RunService")
	RunService2:BindToRenderStep("HarpoonFollow", Enum.RenderPriority.Camera.Value + 2, function()
		if cannonBall.Parent then
			cFrame = workspace.CurrentCamera.CFrame
		else
			local RunService3 = game:GetService("RunService")
			return RunService3:UnbindFromRenderStep("HarpoonFollow")
		end
	end)
	cannonBall.Weld.C0 = cannonBall.CFrame:ToObjectSpace(CFrame.new(
		cannonBall.Position,
		cannonBall.Position + cannonBall.Velocity
	) * CFrame.Angles(0, -1.5707963267948966, 0))
	local v = { cannonBall.Harpoon.Position - cannonBall.Harpoon.CFrame.RightVector * -8, part0.Position }
	local v2 = 0

	while cannonBall.Parent do
		cannonBall.Weld.C0 = cannonBall.CFrame:ToObjectSpace(CFrame.new(
			cannonBall.Position,
			cannonBall.Position + cannonBall.Velocity
		) * CFrame.Angles(0, -1.5707963267948966, 0))
		local v3 = { cannonBall.Harpoon.Position - cannonBall.Harpoon.CFrame.RightVector * -8, part0.Position }
		v2 = math.max(
			v2 + ({ (v3[1] - v[1]).Magnitude, (v3[2] - v3[1]).Magnitude - (v[2] - v[1]).Magnitude })[2],
			(v3[2] - v3[1]).Magnitude
		)
		local v4 = math.floor(math.max(v2 - #clones * 8.6, 0) / 8.6)

		if v4 > 0 then
			v = v3

			for _ = 1, v4 do
				local clone = harpoonChain2.Chain1:Clone()
				clone.Anchored = true
				clone.CanCollide = false

				if clones[#clones] then
					clone.CFrame = clones[#clones].CFrame * CFrame.new(-4.3, 0, 0)
				else
					clone.CFrame = part0.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, 1.5707963267948966, 0)
				end

				clone.Parent = workspace._WorldOrigin
				clone.Color = Color3.fromHSV(math.random(), 1, math.random() * 0.5 + 0.5)
				maid:GiveTask(clone)
				table.insert(clones, clone)
			end
		else
			v = v3
		end

		local v5 = cannonBall.Harpoon.Position - cannonBall.Harpoon.CFrame.RightVector * -8
		local rightVectors = {}

		for i = 1, #clones do
			local v6 = clones[i]

			if not rightVectors[i] then
				rightVectors[i] = v6.CFrame.RightVector
			end

			local v7 = v6.Position + v6.CFrame.RightVector * -4.3

			if (v7 - v5).Magnitude < 0.2 then
				break
			end

			local cframe = CFrame.new(v5, v7)
			local cframe2 = CFrame.new(cframe.Position + cframe.LookVector * 4.3, v5)
			local v8 = rightVectors[i]
			local rightVector = cframe2.RightVector
			local v9 = math.acos((rightVector:Dot(v8)))

			if v9 < 0 then
				rightVector:Cross(v8)
			elseif v9 > 1.5707963267948966 then
				rightVector:Cross(v8)
			end

			v6.CFrame = cframe2 * CFrame.Angles(0, 1.5707963267948966, 0)
			v5 = cframe.Position + cframe.LookVector * 8.6
		end

		task.wait()
	end

	maid:DoCleaning()
end