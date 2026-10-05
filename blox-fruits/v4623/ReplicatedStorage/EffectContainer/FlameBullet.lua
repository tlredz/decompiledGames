local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local part = data.Part
	local cFrame = data.CFrame
	local duration = data.Duration or 1.5
	local scale = data.Scale or 30
	local length = data.Length or 400

	if not (part and part:IsDescendantOf(workspace)) then
		return
	end

	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 300 + length < magnitude then
		return
	end

	coroutine.resume(coroutine.create(function()
		local v = duration * 0.4
		local v2 = cFrame * CFrame.Angles(3.141592653589793, 0, 0)
		local clone = game.ReplicatedStorage.Assets.Models.FireMeshExplosion:Clone()
		clone.Root.Transparency = 1
		clone.Parent = _WorldOrigin
		clone:SetPrimaryPartCFrame(v2)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function iterate(fn)
			for _, child in pairs(clone:GetChildren()) do
				fn(child)
			end
		end

		local function fn(instance)
			if instance.Name == "Shock" then
				TweenService:Create(instance, TweenInfo.new(v * 0.5, Enum.EasingStyle.Quad), {
					Transparency = 1,
					Size = instance.Size.unit * scale + Vector3.new(0, scale * 0.5, 0),
					CFrame = instance.CFrame * CFrame.new(0, scale / 3, 0)
				}):Play()
			elseif instance.Name == "Wind" then
				local function effect(instance2, p)
					TweenService:Create(instance2, TweenInfo.new(v * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Quad), {
						Size = instance2.Size.unit * scale * 2.5 * (1 - p * 0.2)
					}):Play()
					TweenService:Create(instance2, TweenInfo.new(v * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Linear), {
						CFrame = instance2.CFrame * CFrame.new(0, (p - 1) * scale * 0.125, 0) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
					}):Play()
					delay(v * 0.6 * (1 - p * 0.2), function()
						TweenService:Create(instance2, TweenInfo.new(v * 0.4, Enum.EasingStyle.Quad), {
							Transparency = 1,
							Size = Vector3.new(scale * 1.75 * (1 - p * 0.1), 0, scale * 1.75 * (1 - p * 0.1))
						}):Play()
					end)
				end

				effect(instance, 1)
				local clone2 = instance:Clone()
				clone2.CFrame = instance.CFrame
				clone2.Parent = clone
				effect(clone2, 2)
				local clone3 = instance:Clone()
				clone3.CFrame = instance.CFrame
				clone3.Parent = clone
				effect(clone3, 3)
			end
		end

		iterate(fn) -- equivalent call inferred; original call site unknown
		wait(v)
		clone:Destroy()
	end))
	local clone = game.ReplicatedStorage.Assets.Models.FireBulletMesh:Clone()
	clone.Parent = _WorldOrigin

	-- equivalent calls inferred from this helper; original call sites unknown
	local function iterate2(fn)
		for _, child in pairs(clone:GetChildren()) do
			fn(child)
		end
	end

	local sizesByChild = {}

	for _, child in pairs(clone:GetChildren()) do
		sizesByChild[child] = child.Size
		child.Size = createVector(0.05, 0.05, 0.05)
	end

	local function fn(p)
		TweenService:Create(p, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = sizesByChild[p]
		}):Play()
	end

	iterate2(fn) -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local lastTime2 = tick()
	local total = 0
	local clones = {}

	while tick() - lastTime < duration do
		local v = (tick() - lastTime) / duration
		local v2 = tick() - lastTime2

		if not part:IsDescendantOf(workspace) then
			break
		end

		local v3 = cFrame * CFrame.new(0, length * v, 0) * CFrame.Angles(0, 3.141592653589793 * v * 6, 0) * CFrame.Angles(
			3.141592653589793,
			0,
			0
		)

		if tick() - lastTime > 0.1 then
			local v4 = 1 + (tick() - lastTime - 0.1) * 5

			for k, v5 in pairs(sizesByChild) do
				k.Size = v5 * v4
			end
		end

		clone:SetPrimaryPartCFrame(v3)
		total += v2

		if total > 0.07 then
			local clone2 = clone:Clone()
			clone2.Parent = _WorldOrigin
			clone2:SetPrimaryPartCFrame(clone:GetPrimaryPartCFrame() * CFrame.new(0, -scale / 10, 0))
			total = 0

			for _, child in pairs(clone2:GetChildren()) do
				TweenService:Create(child, TweenInfo.new(0.33, Enum.EasingStyle.Quad), {
					Transparency = 1,
					CFrame = child.CFrame * CFrame.new(0, -scale * 0.75, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
					Size = Vector3.new(child.Size.X * 0.25, child.Size.Y * 3, child.Size.Z * 0.25)
				}):Play()
			end

			table.insert(clones, clone2)
		end

		lastTime2 = tick()
		RunService.RenderStepped:Wait()
	end

	local function fn2(p)
		TweenService:Create(p, TweenInfo.new(0.33), {
			Transparency = 1,
			Size = createVector(0.05, 0.05, 0.05),
			CFrame = p.CFrame * CFrame.new(0, -length * 0.15, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		}):Play()
	end

	iterate2(fn2) -- equivalent call inferred; original call site unknown
	wait(0.33)
	clone:Destroy()
	wait(0.33)

	for _, v in pairs(clones) do
		v:Destroy()
	end
end