local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local v = {
	[2] = 0.143,
	[3] = 0.19,
	[4] = 0.19,
	[5] = 0.119,
	[6] = 0.19,
	[7] = 0.143,
	[99] = 0.262
}
local v2 = {
	[1] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[2] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[3] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[4] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[5] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[6] = CFrame.new(
		0.000122070312,
		-2.81992388,
		0.000244140625,
		-1.00582838e-7,
		0,
		1.00000441,
		0,
		1,
		0,
		-1.00000441,
		0,
		-1.04308128e-7
	),
	[7] = CFrame.new(
		0.0000610351562,
		-1.92927074,
		-0.0675048828,
		-1.1920929e-7,
		6.75251899e-9,
		1.00000441,
		-0.258820176,
		0.965925753,
		-2.23517418e-8,
		-0.965929985,
		-0.258819014,
		-8.94069672e-8
	),
	[99] = CFrame.new(0.000122070312, -0.569923878, -0.36114502, 0, 0, 1, 0, 1, 0, -1, 0, 0)
}
local v3 = {}
local v4 = {
	[4] = CFrame.new(1.02490234, -2.45000029, -6, 0.040637821, 0, -0.999173939, 0, 1, 0, 0.999173939, 0, 0.040637821),
	[5] = CFrame.new(1.02490234, -1.32500041, -6, 0.999999881, 0, 0, 0, 1, 0, 0, 0, 0.999999881)
}
local v5 = {
	[7] = 0.148
}
local v6 = {
	[4] = "activate_shakelessaggresive",
	[5] = "activate_shake"
}
os.clock()
return function(adornee, p, p2, _)
	if adornee == nil then
		return
	end

	local humanoidRootPart = adornee:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) >= 100 then
		return
	end

	local v7 = p2 and 99 or p

	if v7 == 4 or v7 == 5 then
		local isAxeAndMaceWeapon = adornee:FindFirstChild("IsAxeAndMaceWeapon", true)

		if isAxeAndMaceWeapon ~= nil then
			local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball
			local ballThing = ball:FindFirstChild("BallThing")

			if ballThing == nil then
				ballThing = script.Slashes.BallThing:Clone()
				ballThing.Parent = ball
			end

			ballThing.Value.Value = v7
			task.delay(1, function()
				local value = ballThing:FindFirstChild("Value")

				if value ~= nil and value.Value == v7 then
					Ouwmit.Enable(ballThing, false)
					task.wait(1)
					ballThing:Destroy()
				end
			end)
		end
	end

	local pS2stoneM1CYCLEswing1

	if v7 == 99 then
		pS2stoneM1CYCLEswing1 = script.Sound:FindFirstChild("PS2stoneM1CYCLEswing1")
	elseif v7 <= 5 then
		pS2stoneM1CYCLEswing1 = script.Sound:FindFirstChild("PS2stoneM1CYCLEswing" .. v7)
	else
		pS2stoneM1CYCLEswing1 = script.Sound:FindFirstChild("PS2stoneM1CYCLEslam" .. v7 - 5)
	end

	if pS2stoneM1CYCLEswing1 ~= nil then
		local clone = pS2stoneM1CYCLEswing1:Clone()

		if v5[v7] then
			task.delay(v5[v7], function()
				clone.Parent = humanoidRootPart
				clone:Play()
				DebrisModule:AddItem(clone, clone.TimeLength)
			end)
		else
			clone.Parent = humanoidRootPart
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
		end
	end

	local v8 = v[v7] or 0.286
	ManuelCancel.new(adornee, v8):Connect(function() end)
	task.wait(v8)

	if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
		return
	end

	local child = script.Slashes:FindFirstChild("Slash" .. v7)

	if child ~= nil then
		local color = nil
		local clone = child:Clone()
		clone.Parent = workspace.Debree
		local cFrame = humanoidRootPart.CFrame

		if v7 ~= nil and v2[v7] then
			cFrame *= v2[v7]
		end

		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -10, RaycastHelper.Crater)

		if raycastResult == nil or raycastResult.Position == nil or raycastResult.Instance == nil then
			if clone.VFX:FindFirstChild("raycastdust") ~= nil then
				clone.VFX.raycastdust:Destroy()
			end
		else
			local _ = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			color = raycastResult.Instance.Color
		end

		local child2 = script.Slashes:FindFirstChild("High" .. v7)

		if child2 ~= nil then
			local clone2 = child2:Clone()
			clone2.Parent = clone
			clone2.Adornee = adornee
		end

		clone:PivotTo(cFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(adornee, color ~= nil and ({
			Color = color,
			ColorWhitelist = "raycastdust",
			ColorBlacklist = { "grass_blade14", "NewAtlasgrass" }
		} or nil) or nil))
		DebrisModule:AddItem(clone, 2)
		local child3 = script.Slashes:FindFirstChild("Ground" .. v7)

		if child3 ~= nil and color ~= nil then
			local clone2 = child3:Clone()

			if v6[v7] then
				Cam_Shaker(humanoidRootPart.Position, v6[v7])
			end

			task.wait(v3[v7] or 0.095)
			local cFrame2 = humanoidRootPart.CFrame

			if v7 and v4[v7] then
				cFrame2 *= CFrame.new(0, 0.1, 0) * v4[v7]
			end

			clone2.Parent = workspace.Debree
			clone2:PivotTo(cFrame2)
			DebrisModule:AddItem(clone2, 2)
			Ouwmit.Emit(clone2, Ouwmit.Owned(adornee, {
				Color = color,
				ColorWhitelist = { "Dust", "raycastdust" },
				ColorBlacklist = { "grass_blade14", "NewAtlasgrass", "GroundShatter" }
			}))
			OuwCraters.Scales({
				Center = clone2.GroundImpact.CFrame,
				Duration = 1.5,
				ScaleMult = v7 == 4 and 0.45 or 0.75,
				Radius = v7 == 4 and 3.5 or 6
			})
		end
	end
end