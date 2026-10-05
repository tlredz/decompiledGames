local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local effects = game.ReplicatedStorage["Ope-Ope"].Effects
return function(list)
	local cFrame, v2, v3, v4 = unpack(list)
	local clone = effects.Wind:Clone()
	clone.Color = v4 or Color3.new(1, 1, 1)
	local mesh = clone.Mesh
	mesh.VertexColor = Vector3.new(clone.Color.r, clone.Color.g, clone.Color.b) * 2
	local scale = mesh.Scale
	mesh.Scale = Vector3.new()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		Transparency = 1,
		CFrame = cFrame * CFrame.new(0, v2 / 2, 2 * v2)
	})
	local tween2 = TweenService:Create(mesh, tweenInfo, {
		Scale = scale * v2
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	tween2:Play()
end