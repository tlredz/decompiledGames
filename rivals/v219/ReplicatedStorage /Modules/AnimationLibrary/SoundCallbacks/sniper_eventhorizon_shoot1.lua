local v = {
	"rbxassetid://124463680760542",
	"rbxassetid://93542288707517",
	"rbxassetid://110622947899700",
	"rbxassetid://96443038656377"
}
local v2 = { "rbxassetid://77109116351775", "rbxassetid://134101368984038" }
return function(object, _, _)
	object:CreateSound("rbxassetid://17672502566", 0.875, 0.725 + 0.05 * math.random(), true, 10)
	object:CreateSound(v[math.random(#v)], 0.875, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound(v2[math.random(#v2)], 0.875, 0.6 + 0.1 * math.random(), true, 10)
end