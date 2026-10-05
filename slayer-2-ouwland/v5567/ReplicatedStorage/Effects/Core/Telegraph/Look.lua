return {
	Resolve = {
		Normal = {
			Color = Color3.fromRGB(226, 46, 38),
			Fill = 0.75,
			Rim = 0.4
		},
		GuardBreak = {
			Color = Color3.fromRGB(255, 188, 40),
			Fill = 0.6,
			Rim = 0.2
		},
		Pierce = {
			Color = Color3.fromRGB(196, 92, 255),
			Fill = 0.6,
			Rim = 0.2
		}
	},
	Plate = {
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.82,
		Thickness = 0.05
	},
	Glow = {
		Material = Enum.Material.Neon,
		Brighten = 0.25,
		Thickness = 0.16
	},
	Edge = {
		Depth = 0.5,
		Transparency = 0.3,
		Thickness = 0.24
	},
	RimThickness = 0.04,
	Highlight = {
		Transparency = 0.3,
		Dim = 0.7,
		Pulse = 0.32
	},
	Fade = 0.25,
	Lift = 0.15,
	Seed = 0.1,
	Part = function(parent, shape, size: Vector3, color: Color3, material, transparency: number)
		local part = Instance.new("Part")
		part.Shape = shape
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = material
		part.Color = color
		part.Transparency = transparency
		part.Size = size
		part.Parent = parent
		return part
	end
}