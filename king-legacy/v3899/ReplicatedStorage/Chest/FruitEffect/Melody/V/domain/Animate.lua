local v = {
	"rbxassetid://82287459559325",
	"rbxassetid://139884254386848",
	"rbxassetid://104564513952598",
	"rbxassetid://99548492990348",
	"rbxassetid://138519271638962",
	"rbxassetid://77282519958723",
	"rbxassetid://81238265256730",
	"rbxassetid://138213104906169",
	"rbxassetid://135123221822198",
	"rbxassetid://76293183306936",
	"rbxassetid://132515564272444",
	"rbxassetid://76072372438544",
	"rbxassetid://84306811563607",
	"rbxassetid://100593281964021",
	"rbxassetid://73988355039851",
	"rbxassetid://109482863163683",
	"rbxassetid://128517427839002",
	"rbxassetid://111437246242401",
	"rbxassetid://112982437955261",
	"rbxassetid://137728698250543",
	"rbxassetid://77454845159608",
	"rbxassetid://75170189291949",
	"rbxassetid://105014606188996",
	"rbxassetid://76689293941090"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v,
			WaitTime = 0.015
		}, function(p)
			local v2 = math.floor(p * #v)
			preload(v[v2])

			if parent:FindFirstChild("Decal") then
				parent.Decal.Texture = v[v2]
			end
		end)
		parent.Transparency = 0
	end)
end