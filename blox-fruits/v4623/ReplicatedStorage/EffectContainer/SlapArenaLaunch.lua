local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local script2 = script
local v = {
	"rbxassetid://109780355880762",
	"rbxassetid://106159633481242",
	"rbxassetid://101033441809380",
	"rbxassetid://122965202006354",
	"rbxassetid://137243732211733",
	"rbxassetid://137190996083338",
	"rbxassetid://74881420393347"
}
local random = Random.new()

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

local object = setmetatable({}, {
	__mode = "kv"
})
return function(data)
	local hrp = data.hrp

	local function getLaunchCFrame()
		local velocity = data.velocity or hrp.AssemblyLinearVelocity

		if velocity.Magnitude < 0.001 then
			velocity = hrp.CFrame.LookVector
		end

		return CFrame.lookAt(hrp.Position, hrp.Position + velocity)
	end

	if data.stop then
		if object[hrp] then
			object[hrp]:Destroy()
		end
	else
		local clone = script.Throw:Clone()
		object[hrp] = clone
		clone.Parent = workspace._WorldOrigin
		task.spawn(function()
			while clone.Parent do
				local v2 = clone
				local velocity = data.velocity or hrp.AssemblyLinearVelocity

				if velocity.Magnitude < 0.001 then
					velocity = hrp.CFrame.LookVector
				end

				v2.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + velocity)
				RunService.RenderStepped:Wait()
			end
		end)
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if os.clock() - lastTime2 >= 0.35 then
				lastTime2 = os.clock()
				local clone2 = script2.Mesh2:Clone()
				clone2.Mesh.Scale = createVector(8, 2, 8)
				local cframe = CFrame.Angles(1.5707963267948966, random:NextNumber(0, 6.283185307179586), 0)
				clone2.Parent = workspace._WorldOrigin
				task.spawn(function()
					while clone2.Parent do
						local v2 = clone2
						local velocity = data.velocity or hrp.AssemblyLinearVelocity

						if velocity.Magnitude < 0.001 then
							velocity = hrp.CFrame.LookVector
						end

						v2.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + velocity) * CFrame.new(0, 0, 15)
						RunService.RenderStepped:Wait()
					end
				end)
				task.spawn(function()
					TweenService:Create(
						clone2.Mesh,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Scale = createVector(15, 10, 15)
						}
					):Play()
					TweenService:Create(
						clone2.Weld,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							C0 = cframe * CFrame.new(0, 15, 0)
						}
					):Play()

					for _, texture in v do
						clone2.Decal.Texture = texture
						task.wait()
					end

					clone2:Destroy()
				end)
			end

			if os.clock() - lastTime < 0.15 then
				return
			end

			lastTime = os.clock()
			local cframe = CFrame.Angles(1.5707963267948966, random:NextNumber(0, 6.283185307179586), 0)
			local clone2 = script2.Mesh:Clone()
			clone2.Mesh.Scale = createVector(8, 5, 8)
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = createVector(12, 30, 12)
			}):Play()
			TweenService:Create(clone2.Weld, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = cframe * CFrame.new(0, 35, 0)
			}):Play()
			clone2.Parent = workspace._WorldOrigin
			local velocity = data.velocity or hrp.AssemblyLinearVelocity

			if velocity.Magnitude < 0.001 then
				velocity = hrp.CFrame.LookVector
			end

			clone2.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + velocity)

			for _, texture in v do
				local velocity2 = data.velocity or hrp.AssemblyLinearVelocity

				if velocity2.Magnitude < 0.001 then
					velocity2 = hrp.CFrame.LookVector
				end

				clone2.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + velocity2)
				clone2.Decal.Texture = texture
				task.wait()
			end

			clone2:Destroy()
		end)
		task.wait(data.launchTime)
		task.delay(ParticleState(clone, false), clone.Destroy, clone)
		heartbeatConnection:Disconnect()
	end
end