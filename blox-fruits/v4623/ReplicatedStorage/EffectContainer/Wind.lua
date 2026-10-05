local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local quint = Util.Tween.ease.out.quint
local renderDistance = Util.RenderDistance
local ray = Util.Ray
local RunService = game:GetService("RunService")
local v = {
	"rbxassetid://2526525791",
	"rbxassetid://2526525823",
	"rbxassetid://2526525854",
	"rbxassetid://2526525887",
	"rbxassetid://2526525912",
	"rbxassetid://2526525932",
	"rbxassetid://2526525961"
}
local v2 = {}
RunService:BindToRenderStep("Wind", Enum.RenderPriority.Last.Value + 1005, function(p)
	for k, v3 in pairs(v2) do
		local v4 = math.min(v3.Duration, tick() - v3.Start)

		if v3.RenderDistance:WithinRange(p) then
			local mode = v3.Mode

			if mode == "Mesh" then
				local v5 = quint(v4, 0, 1, 1)
				local scale = createVector(0.1, 0.15, 0.1) * v3.Size * 4 * v5
				local part = v3.Parts[1]
				part.Mesh.Scale = scale
				part.Transparency = v5 ^ 2
				local part2 = v3.Parts[2]
				part2.Mesh.Scale = scale
				part2.Transparency = v5 ^ 2
			elseif mode == "Animated" then
				local v5 = v4 / v3.Duration
				v3.Parts[1].Beam.Texture = v[math.ceil(v5 * #v)]
				v3.Parts[2].Beam.Texture = v[math.ceil(v5 * #v)]
			elseif mode == "Curved" then
				local v5 = quint(v4, 0, 1, 1)

				for i = 1, 2 do
					local size = createVector(1, 1, 1) * v3.Size * (i / 3 + 1) * (0.25 + v5 * 0.75)
					local part = v3.Parts[i]
					part.Size = size
					part.CFrame = v3.CFrame * CFrame.new(0, 0, (i == 1 and -1 or 1) * v3.Size / 5 + v3.Size * v5 * 0.7) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					part.Transparency = 0.3 + ((i * 0.1 + 0.9) * v5) ^ 1.5 * 0.7
				end
			end
		end

		if v4 ~= v3.Duration then
			continue
		end

		v3.Parts[1]:Destroy()
		v3.Parts[2]:Destroy()
		v2[k] = nil
	end
end)
local _WorldOrigin = workspace._WorldOrigin
local Wind = {}
Wind.__index = Wind

function Wind.new(instance)
	local cFrame = instance.CFrame
	local size = instance.Size or 4
	local duration = instance.Duration or 1
	local color = instance.Color or Color3.new(1, 1, 1)
	return (setmetatable({
		Size = size,
		Duration = duration,
		CFrame = cFrame,
		Mode = instance.Mode or "Mesh",
		Color = color
	}, {
		__index = Wind
	}))
end

function Wind:Run()
	local cFrame = self.CFrame
	local size = self.Size
	local _ = self.Duration
	local mode = self.Mode
	local renderDistance2 = renderDistance.new(cFrame.p, 100, 150 + size * 15, 0.15)

	if renderDistance2.value(cFrame.p) > math.min(150 + size * 15, 400) then
		return self
	end

	local v4, v5, _ = ray(cFrame.p, Vector3.new(0, -size * 3, 0), { workspace.Enemies, workspace.Characters })

	if v4 then
		self.Parts = {}

		for i = -1, 1, 2 do
			local clone = nil

			if mode == "Mesh" then
				cFrame = CFrame.new(v5, v5 + cFrame.lookVector * createVector(1, 0, 1))
				clone = ReplicatedStorage.Assets.Models.Wave:Clone()
				clone.CFrame = cFrame * CFrame.new(i * size * 1.33, 0, 0) * CFrame.Angles(0, i / 5, -i / 3)
				clone.Mesh.Scale = createVector(0.1, 0.1, 0.1)
			elseif mode == "Animated" then
				cFrame = CFrame.new(v5, v5 + cFrame.lookVector * createVector(1, 0, 1))
				clone = ReplicatedStorage.Assets.Models.WaveAnimated:Clone()
				clone.CFrame = cFrame * CFrame.new(i * size * 1.33, 0, 0) * CFrame.Angles(0, i / 5, -i / 3)
				clone.Beam.Texture = v[1]
				clone.Beam.Width0 = size * 5
				clone.Beam.Width1 = size * 5
				clone.Attachment1.Position = createVector(0, 0, 0)
				clone.Attachment0.Position = Vector3.new(0, size * 3.5, 0)
			elseif mode == "Curved" then
				cFrame = CFrame.new(v5, v5 + cFrame.lookVector)
				clone = game.ReplicatedStorage.Assets.Models.CurvedRing:Clone()
				clone.Size = createVector(0.05, 0.05, 0.05)
				clone.Transparency = 1
				clone.CFrame = cFrame * CFrame.new(0, 0, i * size / 5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			end

			clone.Color = self.Color
			clone.Parent = _WorldOrigin
			self.Parts[#self.Parts + 1] = clone
		end

		self.Start = tick()
		self.RenderDistance = renderDistance2
		table.insert(v2, self)
	end

	self.Enabled = v4 ~= nil
	return self
end

return Wind