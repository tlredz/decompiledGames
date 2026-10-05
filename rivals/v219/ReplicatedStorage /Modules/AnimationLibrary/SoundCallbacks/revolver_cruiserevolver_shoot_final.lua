local v = {
	"rbxassetid://14417089307",
	"rbxassetid://14417089152",
	"rbxassetid://14417089046",
	"rbxassetid://14417088974"
}
return function(object, p, p2)
	object:CreateSound(v[math.random(#v)], 1, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://94299557217235", 1, 0.95 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://134815282110155", 1, 1, true, 10)
end