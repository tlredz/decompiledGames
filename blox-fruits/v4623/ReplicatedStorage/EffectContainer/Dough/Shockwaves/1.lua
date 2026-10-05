local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local loadTexture = misc.LoadTexture
local _ = misc.ScaleModel
local v = {
	"rbxassetid://8314350294",
	"rbxassetid://8314344719",
	"rbxassetid://8313780127",
	"rbxassetid://8313725039",
	"rbxassetid://8313797644",
	"rbxassetid://8313742436",
	"rbxassetid://8313749259",
	"rbxassetid://8313756846",
	"rbxassetid://8313761878",
	"rbxassetid://8313768156",
	"rbxassetid://8313773106",
	"rbxassetid://8313780127",
	"rbxassetid://8314338712",
	"rbxassetid://8314340888",
	"rbxassetid://8314344719",
	"rbxassetid://8314350294",
	""
}
return function(data)
	local cFrame = data.CFrame or CFrame.new()
	local duration = data.Duration or data.Lifetime or 0.3
	local scale = data.Scale or 1
	local speed = data.Speed or 1
	local color = data.Color or Color3.fromRGB(2555, 255, 0)
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

	local clone = dough.Models.Shockwaves["1"]:Clone()
	local decal = clone.PrimaryPart.Decal
	local mesh = clone.PrimaryPart.Mesh
	local v3 = mesh.Scale / 40

	if transparency then
		decal.Transparency = transparency
	end

	decal.Color3 = color2
	mesh.Scale = v3 * 0.1
	local cframe = CFrame.Angles(0, Random.new():NextNumber(-3.141592653589793, 3.141592653589793), 0)
	clone:SetPrimaryPartCFrame(cFrame * cframe)
	clone.Parent = _WorldOrigin
	TweenService:Create(mesh, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = v3 * scale
	}):Play()
	local v4 = 0
	distributedLoop:add(function(p, p2)
		local v5 = math.min(1, p / duration)
		local quad = Util.Tween.ease["in"].quad(v5, 0, 1, 1)
		local lerped = color2:Lerp(color, (Util.Tween.ease.out.quad(v5, 0, 1, 1)))

		if not clone:IsDescendantOf(workspace) then
			return true
		end

		v4 = v4 % 6.283185307179586 + 6.283185307179586 * speed * p2
		decal.Color3 = lerped
		clone:SetPrimaryPartCFrame(cFrame * cframe * CFrame.Angles(0, v4, 0) + vectorOffset * quad)
	end)
	loadTexture(clone.PrimaryPart, v, (math.max(0.016666666666666666, duration / #v)))
	clone:Destroy()
end