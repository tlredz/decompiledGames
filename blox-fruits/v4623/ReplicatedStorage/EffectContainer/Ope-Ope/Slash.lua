local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local opeOpe = game.ReplicatedStorage["Ope-Ope"]
return function(list)
	local cFrame, v2, v3, v4 = unpack(list)
	local clone = opeOpe.Effects.Slash:Clone()
	clone.CFrame = cFrame
	clone.Mesh.Scale = Vector3.new()
	clone.Mesh.VertexColor = Vector3.new(v4.r, v4.g, v4.b)
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		CFrame = cFrame * CFrame.new(0, 0, -v2 / 2),
		Transparency = 1
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(0.1, 0.4, 0.072) * v2
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	tween2:Play()
end