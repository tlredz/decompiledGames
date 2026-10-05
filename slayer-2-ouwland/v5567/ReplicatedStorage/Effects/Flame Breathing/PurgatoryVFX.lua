local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local currentCamera = workspace.CurrentCamera
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {
	{ 0, 60 },
	{ 0.18, 46.42857142857143 },
	{ 0.24, 63.42857142857143 },
	{ 0.25, 69.57142857142857 },
	{ 0.31, 91.75 },
	{ 0.33, 94.25 },
	{ 0.39, 85.4 },
	{ 0.41, 77 },
	{ 0.42, 100 },
	{ 1.03, 78.125 },
	{ 1.09, 77.6896551724138 },
	{ 1.32, 98.3103448275862 },
	{ 1.37, 98.6072769165039 },
	{ 1.38, 98.66666666666667 },
	{ 1.41, 96.33333333333333 },
	{ 1.47, 57 },
	{ 1.53, 25.76923076923077 },
	{ 2, 39.23076923076923 },
	{ 2.06, 41.8 },
	{ 2.15, 32.2 },
	{ 2.21, 33 },
	{ 2.27, 41 },
	{ 2.33, 53.33333333333333 },
	{ 2.39, 70 },
	{ 2.4, 65 },
	{ 2.45, 77.5 },
	{ 2.51, 86.22222222222223 },
	{ 3.12, 94.77777777777777 },
	{ 3.18, 101.14285714285714 },
	{ 3.19, 102.85714285714286 },
	{ 3.25, 109.125 },
	{ 3.3, 111 },
	{ 3.31, 35 },
	{ 3.39, 56.81818181818182 },
	{ 3.45, 68.36 },
	{ 4.04, 89.64 },
	{ 4.1, 81.92307692307692 },
	{ 4.2, 45 },
	{ 4.21, 35 },
	{ 4.28, 56 },
	{ 4.34, 60 },
	{ 4.46, 40 },
	{ 4.58, 40.751748251748246 },
	{ 4.57, 39.36363636363636 },
	{ 5.03, 47.69230769230769 },
	{ 5.13, 70 },
	{ 5.15, 55 },
	{ 5.24, 67.75 },
	{ 5.3, 69 },
	{ 5.38, 61 },
	{ 5.44, 52.333333333333336 },
	{ 5.5, 41 },
	{ 5.51, 28 },
	{ 6.01, 38 },
	{ 6.04, 38.875 },
	{ 6.07, 38.6875 },
	{ 6.13, 37.25 },
	{ 6.28, 31 },
	{ 6.29, 41 }
}
local v2 = {
	{ 0, "FlameStartup" },
	{ 0.24, "Launch" },
	{ 0.4, "TorsoFake" },
	{
		2.01,
		"CameraZoom",
		CFrame.new(0.806625783, -2.06820297, -31.0989704, 0, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, 0)
	},
	{ 4.22, "BeamSlash1" },
	{ 4.23, "BloodHits", CFrame.new(-0.630000114, -2.49998403, -68.7074966, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
	{ 5.13, "BeamSlash2" },
	{ 5.19, "BloodHits2", CFrame.new(-0.630000114, -2.49998403, -68.7074966, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
	{ 6.27, "BeamSlash3" },
	{ 6.29, "BloodHits2", CFrame.new(-0.630000114, -2.49998403, -68.7074966, 1, 0, 0, 0, 1, 0, 0, 0, 1) }
}
local v3 = {
	{ 1.43, "Purgatory1" },
	{ 4.13, "Purgatory2" }
}
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer, true)
local ImpactFrames = require(ReplicatedStorage.CAM.Client.Modules.Effects.ImpactFrames)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
return function(parent, p: string, list)
	if parent == nil then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 then
		return
	end

	if p == "Jump" then
		local clone = script.Parent["Flame Tiger HoldVFX"].Jump:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		local clone2 = script.PS2flameULTlaunch:Clone()
		clone2.Parent = clone
		clone2:Play()
		Ouwmit.Emit(clone, Ouwmit.Owned(parent))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
	elseif p == "Cutscene" then
		local v4 = 0
		local clone = script.PS2flameULT:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local clone2 = script.Highlight:Clone()
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 3.31)

		if parent == game.Players.LocalPlayer.Character or table.find(list, game.Players.LocalPlayer.Character) then
			task.spawn(function()
				local v5 = 0

				for _, v6 in ipairs(v3) do
					task.wait(v6[1] - v5)
					v5 = v6[1]
					ImpactFrames.PlaySet({
						FrameRate = 0.03333333333333333,
						FramesSetName = v6[2]
					})
				end
			end)
			task.spawn(function()
				local numberValue = Instance.new("NumberValue")
				numberValue.Name = "FOV"
				local v5 = nil
				local v6 = 0
				local renderSteppedConnection = nil

				for i, v7 in ipairs(v) do
					task.wait(v7[1] - v6)
					v6 = v7[1]
					v5 = v7[2]

					if i ~= 1 then
						continue
					end

					numberValue.Parent = getvaluesfolder
					numberValue.Value = v7[2]
					renderSteppedConnection = RunService.RenderStepped:Connect(function()
						local v8 = v5 - numberValue.Value

						if v8 ~= 0 then
							numberValue.Value += v8 * 0.2
						end
					end)
				end

				renderSteppedConnection:Disconnect()
				numberValue:Destroy()
			end)
		end

		for _, v5 in ipairs(v2) do
			task.wait(v5[1] - v4)
			v4 = v5[1]

			if v5[2] == "TorsoFake" then
				local upperTorso = parent:FindFirstChild("UpperTorso")

				if upperTorso ~= nil then
					local clone3 = script.TorsoFake:Clone()
					clone3:PivotTo(upperTorso.CFrame)
					clone3.Parent = workspace.Debree
					local weld = Instance.new("Weld", clone3)
					weld.Part1 = clone3.TorsoFake
					weld.Part0 = upperTorso
					Ouwmit.Emit(clone3, Ouwmit.Owned(parent))
					DebrisModule:AddItem(clone3, 4)
				end
			else
				local clone3 = script:FindFirstChild(v5[2]):Clone()
				clone3.Parent = workspace.Debree

				if v5[3] == nil then
					clone3:PivotTo(humanoidRootPart.CFrame)
				else
					clone3.CFrame = humanoidRootPart.CFrame * v5[3]
				end

				Ouwmit.Emit(clone3, Ouwmit.Owned(parent))
				DebrisModule:AddItem(clone3, 4)
			end
		end
	end
end