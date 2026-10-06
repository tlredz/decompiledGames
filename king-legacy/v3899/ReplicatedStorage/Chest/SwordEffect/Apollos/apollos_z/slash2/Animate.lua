local v = {
	"rbxassetid://10873259976",
	"rbxassetid://10873259479",
	"rbxassetid://10873258863",
	"rbxassetid://10873257668",
	"rbxassetid://10873257206",
	"rbxassetid://10873256741",
	"rbxassetid://10873255943",
	"rbxassetid://10873255261",
	"rbxassetid://10873254639",
	"rbxassetid://10873253903",
	"rbxassetid://10873253417",
	"rbxassetid://10873252670",
	"rbxassetid://10873252128",
	"rbxassetid://10873251680",
	"rbxassetid://10873251145",
	"rbxassetid://10873250776",
	"rbxassetid://10873250172",
	"rbxassetid://10873249697",
	"rbxassetid://10873249172",
	""
}
local v2 = {
	"rbxassetid://10873336964",
	"rbxassetid://10873336350",
	"rbxassetid://10873335868",
	"rbxassetid://10873335278",
	"rbxassetid://10873334723",
	"rbxassetid://10873333525",
	"rbxassetid://10873332920",
	"rbxassetid://10873332436",
	"rbxassetid://10873332050",
	"rbxassetid://10873331555",
	"rbxassetid://10873330860",
	"rbxassetid://10873330302",
	"rbxassetid://10873329852",
	"rbxassetid://10873329396",
	"rbxassetid://10873328899",
	"rbxassetid://10873328396",
	""
}

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v3 = math.floor(p * #v)
			script.Parent.Decal.Texture = v[v3]
			preload(v[v3])
		end)
		script.Parent.Decal.Texture = ""
	end)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)
			script.Parent.Decal2.Texture = v2[v3]
			preload(v2[v3])
		end)
		script.Parent.Decal2.Texture = ""
	end)
end