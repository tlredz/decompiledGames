local createVector = vector.create
local LightningModule = {}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

function Draw_Lightning(p, p2, parent, p3, list)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Material = Enum.Material.Neon

	if typeof(list) == "Color3" then
		part.Color = list or Color3.fromRGB(0, 170, 255)
	else
		part.Color = list[Random.new():NextInteger(1, #list)]
	end

	part.Parent = parent
	Debris:AddItem(part, 0.2)
	local magnitude = (p2 - p).Magnitude
	part.Size = Vector3.new(p3, p3, magnitude)
	part.CFrame = CFrame.new(p, p2) * CFrame.new(0, 0, -magnitude / 2)
	TweenService:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0, 0, magnitude),
		Transparency = 1
	}):Play()
end

function LightningModule.Bolt(p, p2, p3, p4, p5, p6)
	local v = {}

	for i = 0, p3 do
		local vector2 = Vector3.new(math.random(-p4, p4), 0, math.random(-p4, p4))
		local v2 = (i == 0 or i == p3) and createVector(0, 0, 0) or vector2
		table.insert(v, p + (p2 - p).Unit * i * (p2 - p).Magnitude / p3 + v2)
	end

	for i, _ in ipairs(v) do
		if v[i + 1] then
			Draw_Lightning(v[i], v[i + 1], workspace.CurrentCamera, p5, p6)
		end
	end
end

return LightningModule