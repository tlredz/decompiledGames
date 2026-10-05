local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local tween = Util.Tween
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local loadTexture = misc.LoadTexture
local _ = misc.ScaleModel
local v = {
	"rbxassetid://7904955547",
	"rbxassetid://7904957119",
	"rbxassetid://7904960317",
	"rbxassetid://7904961838",
	"rbxassetid://7904963416",
	"rbxassetid://7904965317",
	"rbxassetid://7904967714",
	"rbxassetid://7904969412",
	"rbxassetid://7904971049",
	"rbxassetid://7904972833",
	"rbxassetid://7904975548",
	"rbxassetid://7904977120",
	"rbxassetid://7904978532",
	"rbxassetid://7904980208",
	"rbxassetid://7904982132",
	"rbxassetid://7904984424",
	""
}
return function(data)
	local anchor = data.Anchor or data.Root
	local cFrame = data.CFrame or CFrame.new()
	local duration = data.Duration or data.Lifetime or 0.25
	local scale = data.Scale or 1
	local speed = data.Speed or 1
	local color = data.Color or Color3.fromRGB(510, 510, 242)
	local vectorOffset = data.VectorOffset or Vector3.new()
	local transparency = data.Transparency
	local color2

	if typeof(color) == "table" then
		color2 = color[1] or color
	else
		color2 = color
	end

	if typeof(color) == "table" then
		color = color[2] or color
	end

	local clone = dough.Models.Shockwaves["2"]:Clone()

	if clone.PrimaryPart == nil then
		clone.PrimaryPart = clone:GetChildren()[1]
	end

	local mesh = clone.PrimaryPart.Mesh
	local v3 = mesh.Scale / 55
	mesh.Scale = v3 * 0.1

	for _, child in pairs(clone:GetChildren()) do
		for _, decal in pairs(child:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			if transparency then
				decal.Transparency = transparency
			end

			decal.Color3 = color2
		end
	end

	local cframe = CFrame.Angles(0, Random.new():NextNumber(-3.141592653589793, 3.141592653589793), 0)
	clone:SetPrimaryPartCFrame(cFrame * cframe)
	clone.Parent = _WorldOrigin
	TweenService:Create(mesh, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = v3 * scale
	}):Play()
	local v4 = 0
	distributedLoop:add(function(p, p2)
		if not clone:IsDescendantOf(workspace) then
			return true
		end

		local v5 = math.min(1, p / duration)
		v4 = v4 % 6.283185307179586 + 6.283185307179586 * speed * p2
		local v6 = cFrame

		if anchor then
			v6 = anchor.CFrame * cFrame
		end

		local quad = tween.ease.inout.quad(v5, 0, 1, 1)
		local quad2 = tween.ease.out.quad(v5, 0, 1, 1)
		local lerped = color2:Lerp(color, quad)

		for _, child in pairs(clone:GetChildren()) do
			for _, decal in pairs(child:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Color3 = lerped
				end
			end
		end

		clone:SetPrimaryPartCFrame((v6 + vectorOffset * quad2) * cframe * CFrame.Angles(0, v4, 0))
	end)
	loadTexture(clone.PrimaryPart, v, (math.max(0.016666666666666666, duration / #v)))
	clone:Destroy()
end