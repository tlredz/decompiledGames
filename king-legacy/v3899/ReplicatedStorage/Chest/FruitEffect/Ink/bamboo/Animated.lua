local createVector = vector.create
local v = {
	"rbxassetid://10497996752",
	"rbxassetid://10497996409",
	"rbxassetid://10497995962",
	"rbxassetid://10497995611",
	"rbxassetid://10497995306",
	"rbxassetid://10497995028",
	"rbxassetid://10497994729",
	"rbxassetid://10497994476",
	"rbxassetid://10497994223",
	"rbxassetid://10497993900",
	"rbxassetid://10497993524",
	"rbxassetid://10497992925",
	"rbxassetid://10497992495",
	"rbxassetid://10497992125",
	"rbxassetid://10497991706",
	"rbxassetid://10497991375",
	"rbxassetid://10497991117",
	"rbxassetid://10497990708"
}

function preload(childName)
	if not workspace["preload เอาไว้ load texture"]:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace["preload เอาไว้ load texture"]
		decal.Texture = childName
	end
end

return function()
	local mesh = script.Parent.Mesh
	mesh.Scale = Vector3.new()
	mesh.Offset = Vector3.new()
	game.TweenService:Create(mesh, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(0.58764994, 0.87285, 0.91539997),
		Offset = createVector(-1.15, 20.699999, -1.15)
	}):Play()
	local attachment = script.Parent.Attachment
	local attachment2 = script.Parent.Attachment2
	attachment.ink:Emit(20)
	attachment.ink_big:Emit(2)
	attachment.ink_splash1:Emit(12)
	attachment.ink_splash2:Emit(12)
	attachment.Smoke2:Emit(3)
	attachment.Smoke:Emit(3)
	attachment.ring:Emit(1)
	attachment2.ring2:Emit(2)
	task.spawn(function()
		for i = 1, #v do
			if script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[i]
			end

			preload(v[i])
			task.wait(0.03)
		end

		if script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
end