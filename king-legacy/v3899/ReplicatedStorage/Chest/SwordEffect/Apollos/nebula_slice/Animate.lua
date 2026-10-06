local createVector = vector.create
local v = {
	"rbxassetid://10667619527",
	"rbxassetid://10667619005",
	"rbxassetid://10667618513",
	"rbxassetid://10667618122",
	"rbxassetid://10667617692",
	"rbxassetid://10667617149",
	"rbxassetid://10667616590",
	"rbxassetid://10667616238",
	"rbxassetid://10667615847",
	"rbxassetid://10667615274",
	"rbxassetid://10667614686",
	"rbxassetid://10667613911",
	"rbxassetid://10667613165",
	"rbxassetid://10667612582",
	"rbxassetid://10667612157",
	"rbxassetid://10667611749",
	"rbxassetid://10667611393",
	"rbxassetid://10667610870",
	"rbxassetid://10667610237"
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
	script.Parent.slash:Play()
	script.Parent.star:Play()
	local mesh = script.Parent.Mesh
	mesh.Scale = createVector(-0, -0.45, -0.01)
	game.TweenService:Create(mesh, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(-0.75, -0.65, -0.01)
	}):Play()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)

			if script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v2]
			end

			preload(v[v2])

			if v2 == 10 then
				game.TweenService:Create(mesh, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = createVector(-0.75, -0, -0.01)
				}):Play()
			end
		end)

		if script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
end