local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local random = Random.new()
local v = {
	"rbxassetid://90949258869355",
	"rbxassetid://71595135050906",
	"rbxassetid://101239080838434",
	"rbxassetid://127193633200823",
	"rbxassetid://137404948830580",
	"rbxassetid://92916536646595",
	"rbxassetid://136466061701721",
	"rbxassetid://81912279607338",
	"rbxassetid://119304116377733",
	"rbxassetid://84633612058827",
	"rbxassetid://80503458387041",
	"rbxassetid://70738861148401",
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
	local clone = script2.Splash:Clone()
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
			local v2 = i * 8
			clone2.Mesh.Scale = createVector(4, 3, 4)
			clone2.Mesh.Offset = createVector(0, 2.55, 0)
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(#v * RunService.Heartbeat:Wait(), Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					Scale = Vector3.new(1 / i * 12, v2, 1 / i * 12),
					Offset = Vector3.new(0, v2 * 0.85, 0)
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
	task.delay(0.16, function()
		local clone2 = script2.VortexParticles:Clone()
		clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone2.Parent = workspace._WorldOrigin
		local clone3 = script2.WaterTwirl:Clone()
		clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
		clone3.Parent = workspace._WorldOrigin
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			clone3.CFrame *= CFrame.Angles(0, 0, (math.rad(-360 * dt)))
		end)

		for _ = 1, 7 do
			local clone4 = script2.Vortex:Clone()
			clone4.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				random:NextNumber(0, 6.283185307179586),
				0
			)
			clone4.Size = createVector(16, 6, 16)
			clone4.Parent = workspace._WorldOrigin
			TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Orientation = clone4.Orientation + createVector(0, 420, 0),
				Transparency = 1,
				Size = createVector(0, 1, 0)
			}):Play()
			task.delay(0.5, clone4.Destroy, clone4)
			task.wait(0.07)
		end

		task.wait(0.1)
		task.delay(ParticleState(clone3, false), function()
			heartbeatConnection:Disconnect()
			clone3:Destroy()
		end)
		task.wait((ParticleState(clone2, false)))
		clone2:Destroy()
	end)
end