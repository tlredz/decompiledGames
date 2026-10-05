local v = {
	"rbxassetid://14417089307",
	"rbxassetid://14417089152",
	"rbxassetid://14417089046",
	"rbxassetid://14417088974"
}
return function(object, _, _)
	object:CreateSound(v[math.random(#v)], 1, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://104731232227748", 1, 0.95 + 0.1 * math.random(), true, 10)
end