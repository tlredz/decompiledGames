game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local _ = workspace.CurrentCamera
return function(p)
	local type = p.Type
	_G.CamShake(type)
end