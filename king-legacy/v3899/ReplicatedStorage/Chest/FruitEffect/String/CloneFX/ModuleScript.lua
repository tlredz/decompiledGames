local fx = script.Parent.fx
game:GetService("TweenService")
return function()
	local v = script.Parent.PrimaryPart.CFrame * CFrame.new(0, -3, 0)
	local pointLight = fx.PointLight
	pointLight.Brightness = 0
	pointLight.Range = 0
	task.spawn(function()
		wait()
		wait(0.65)
		fx.Attachment.line:Emit(5)
		fx.Attachment.Sparks:Emit(25)
		fx.Attachment.big:Emit(1)
	end)

	for i = 1, 15 do
		local clone = script.Parent.circleweb:Clone()
		clone.CFrame = v * CFrame.new(0, i * 0.35, 0)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2.25)
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript(i)
		task.wait()
	end
end