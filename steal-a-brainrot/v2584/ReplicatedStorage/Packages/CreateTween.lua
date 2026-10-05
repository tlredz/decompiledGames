local TweenService = game:GetService("TweenService")
return function(p, p2, p3, flag: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	if flag ~= false then
		tween:Play()
	end

	return tween
end