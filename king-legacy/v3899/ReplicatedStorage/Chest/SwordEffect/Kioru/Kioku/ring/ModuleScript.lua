local createVector = vector.create
local TweenService = game:GetService("TweenService")
local v = {}

function create_arm(p, p2)
	local part = Instance.new("Part")
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(96, 130, 255)
	part.Size = createVector(2, 1, 0)
	part.CFrame = p.CFrame * p2
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1)
	v[#v + 1] = part
	TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = part.CFrame * CFrame.new(0, 0, -25),
		Size = createVector(2, 1, 50)
	}):Play()
	task.spawn(function()
		for i = 1, 3 do
			local part2 = Instance.new("Part")
			part2.Material = Enum.Material.Neon
			part2.Color = Color3.fromRGB(96, 130, 255)
			part2.Size = createVector(1, 1, 1)
			part2.CFrame = part.CFrame * CFrame.new(0, 0, i * -8)
			part2.Parent = workspace.Effects
			_G.PU:Dust(part2, 1)
			v[#v + 1] = part2
			TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20, 1, 1)
			}):Play()
			wait()
		end
	end)
end

return function(cFrame)
	v = {}
	local clone = script.Parent:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	clone.Size = createVector(0, 1, 0)
	clone.Transparency = 0
	clone.Color = Color3.fromRGB(96, 130, 255)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(30, 1, 30)
	}):Play()
	v[#v + 1] = clone
	wait(0.1)

	for i = 1, 4 do
		create_arm(clone, CFrame.Angles(0, 1.5707963267948966 * i, 0) * CFrame.new(0, 0, -15))
	end

	wait(0.4)

	for _, v2 in pairs(v) do
		local v3 = v2
		task.spawn(function()
			game.TweenService:Create(v3, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(20, 27, 53)
			}):Play()
			wait(0.1)
			TweenService:Create(v3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end
end