local createVector = vector.create
local FXCreator = require(game.ReplicatedStorage.FXCreator)
local v = FXCreator.Build()
return function(p)
	local cFrame = p.CFrame

	if v.Distance(cFrame.p) > 300 then
		return
	end

	local ball = v.Create.Ball({
		CFrame = cFrame
	})
	local animator = v.Animator(ball, 150)
	animator.Size({
		From = createVector(1, 1, 1),
		To = createVector(50, 50, 50),
		Time = 1.5,
		Tween = v.Tween.ease.out.expo
	})
	animator.Custom({
		Function = function(p2)
			ball.Color = Color3.fromHSV(p2, 1, 1)
		end,
		Time = 2,
		Tween = v.Tween.ease.out.quad
	})
	animator.Transparency({
		From = 0,
		To = 1,
		Time = 2
	})
	ball:SetDuration(2)
	ball:AddToWorld()
end