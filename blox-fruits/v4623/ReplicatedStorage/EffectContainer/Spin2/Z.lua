local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local script2 = script
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
return function(p)
	local root = p.Root
	local holding = p.Holding

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local cFrame = root.CFrame
	local clone = script2.Phase1.Slashes:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Weld.Part0 = root
	local v = Util.Sound:Play("Spinning", root)
	local lastTime = tick()
	local descendants = clone:GetDescendants()
	local lastTime2 = tick()

	while true do
		for _, emitter in pairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if tick() - lastTime > 0.04 then
			Util.Sound:Play("QuickSlice", clone.CFrame, 10, 1.75, 0.085)
			lastTime = tick()
		end

		if tick() - lastTime2 > 0.175 and not (root and root:IsDescendantOf(workspace) and holding and holding.Value and holding:IsDescendantOf(workspace)) then
			Util.Sound:FadeOut(v, 0.3)
			task.delay(2, function()
				folder:Destroy()
			end)
			break
		else
			task.wait(math.random(5, 15) / 300)
		end
	end
end