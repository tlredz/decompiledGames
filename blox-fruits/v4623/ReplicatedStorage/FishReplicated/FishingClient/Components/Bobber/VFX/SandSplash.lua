local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local random = Random.new()
local v = {
	"rbxassetid://70848403641506",
	"rbxassetid://137570926666768",
	"rbxassetid://140065786938831",
	"rbxassetid://106506995308537",
	"rbxassetid://84738692701107",
	"rbxassetid://76224944365328",
	"rbxassetid://114660699515015",
	"rbxassetid://103678015143320",
	"rbxassetid://79496099757546",
	"rbxassetid://133477045603158",
	"rbxassetid://87806059631045",
	"rbxassetid://100791451116498",
	"rbxassetid://125691409393722",
	""
}

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local script2 = script
return function(p)
	local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams) or {
		Position = Vector3.new(p.X, -3, p.Z),
		Normal = createVector(0, 1, 0)
	}

	if raycastResult then
		local clone = script2.SandSplash:Clone()
		clone.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone.Parent = workspace._WorldOrigin
		task.delay(ParticleState(clone), clone.Destroy, clone)
		task.spawn(function()
			for i = 1, 2 do
				local clone2 = script2.WaterMesh:Clone()
				clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					random:NextNumber(0, 6.283185307179586),
					0
				)
				clone2.Parent = workspace._WorldOrigin
				local v2 = i * 4.5
				clone2.Mesh.Scale = createVector(0, 1, 0)
				clone2.Mesh.Offset = createVector(0, 0.85, 0)
				TweenService:Create(
					clone2.Mesh,
					TweenInfo.new(#v * RunService.Heartbeat:Wait(), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Scale = Vector3.new(1 / i * 9.5, v2, 1 / i * 9.5),
						Offset = Vector3.new(0, v2 * 0.85, 0)
					}
				):Play()
				TweenService:Create(
					clone2.Decal,
					TweenInfo.new(#v * RunService.Heartbeat:Wait(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Color3 = Color3.new(0.980392, 0.784314, 0.470588)
					}
				):Play()
				task.spawn(function()
					for k, texture in v do
						clone2.Decal.Texture = texture
						task.wait()
					end

					clone2:Destroy()
				end)
				random:NextNumber(0.07, 0.12)
			end
		end)
	end

	task.wait(0.5)
end