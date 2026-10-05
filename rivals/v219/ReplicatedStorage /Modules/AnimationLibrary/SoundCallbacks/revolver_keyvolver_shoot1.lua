local v = {
	"rbxassetid://14417089307",
	"rbxassetid://14417089152",
	"rbxassetid://14417089046",
	"rbxassetid://14417088974"
}
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 1, 0.75 + 0.125 * math.random(), true, 10)
	object:CreateSound(v[math.random(#v)], 1, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13483008798", 1.25, 2, true, 10)
	object:CreateSound("rbxassetid://90757583550672", 0.625, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
end