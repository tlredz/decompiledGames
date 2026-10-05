local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.packages.Trove)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local StarcallerCry = {}
local _ = {
	Failed = 1,
	Success = 2
}
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
local random = Random.new()

function StarcallerCry.CreateModel(p, _)
	local child = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild(p.VfxModelName)

	if not child then
		warn((`Failed to find model for vfx {p.VfxModelName}!`))
		return nil
	end

	local clone = child:Clone()
	clone:ScaleTo(clone:GetScale() * (p.ModelScale or 1))

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.CastShadow = false
	end

	return clone
end

function StarcallerCry:PlaySound(p, p2)
	if not (self and p) then
		return
	end

	local child = fishing:FindFirstChild(self)

	if not child then
		return
	end

	fx:PlaySound(child, p, false, "FishingSound", p2)
end

function StarcallerCry.CreateVfx(object, maid, p, p2, data)
	local flag = false

	if v[p] then
		v[p]:Clean()
	end

	local maid2 = object:Extend()
	v[p] = maid2
	maid:Add(function()
		flag = true
		task.delay(10, function()
			maid2:Clean()
		end)
	end)
	maid2:Add(function()
		flag = true
		v[p] = nil
		v3[p] = nil
		v2[p] = nil
		v4[p] = nil
	end)
	local v5 = data.Owner == localPlayer
	local model = StarcallerCry.CreateModel(p2, data)
	model:PivotTo(data.Center)
	maid2:Add(model)
	v3[p] = model
	v4[p] = data.Root

	if model:FindFirstChild("OuterDistortion") then
		model.OuterDistortion.Transparency = 100
		model.OuterDistortion.Size = createVector(128, 128, 128)
	end

	local core = model.Core
	core.Size = createVector(0.01, 0.01, 0.01)

	for _, child in core.ExtraShading:GetChildren() do
		child.ImageTransparency = 1
	end

	if flag then
		model:Destroy()
		return
	end

	if not v5 then
		if model:FindFirstChild("OuterDistortion") then
			model.OuterDistortion.Size = createVector(32, 32, 32)
		end

		model:ScaleTo(model:GetScale() * 0.5)
	end

	model.Parent = workspace.active.debrisfx
	core.Spawn:Play()
	core.Idle:Play()
	TweenService:Create(core, TweenInfo.new(2, Enum.EasingStyle.Quart), {
		CFrame = data.Center + createVector(0, 15, 0),
		Size = createVector(10, 10, 10)
	}):Play()

	if model:FindFirstChild("OuterDistortion") then
		TweenService:Create(model.OuterDistortion, TweenInfo.new(2, Enum.EasingStyle.Quart), {
			Size = createVector(25, 25, 25),
			Transparency = 3
		}):Play()
	end

	for _, child in core.ExtraShading:GetChildren() do
		TweenService:Create(child, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
	end

	for _, v6 in data.Fish do
		local itemData = v6
		task.spawn(function()
			local v8 = FishModel.Create({
				Name = itemData.Name,
				ItemData = itemData,
				ResizeArgs = {
					MaxSize = 10
				},
				RemoveScripts = false,
				CastShadow = false
			})

			if flag then
				v8:Destroy()
				return
			end

			v8:PivotTo(data.Center + Vector3.new(math.random(-50, 50), -25, math.random(-50, 50)))
			local center = v8:WaitForChild("Center")
			center.Anchored = true
			v8.Parent = model
			local v9 = random:NextUnitVector() * 10
			local v10 = (random:NextUnitVector() * createVector(1, 1, 0)).Unit * random:NextNumber(45, 70)
			local v11 = random:NextUnitVector() * random:NextNumber(45, 70)
			local identity = CFrame.identity
			local identity2 = CFrame.identity
			local identity3 = CFrame.identity
			local v12 = 0.75
			maid2:Add(RunService.RenderStepped:Connect(function(dt)
				if v2[p] == 2 then
					v9 = createVector(0, 0, 0)
				elseif v2[p] == 1 then
					v12 -= dt

					if v12 <= 0 then
						center.Anchored = false
					end

					return
				end

				identity *= CFrame.fromOrientation(math.rad(v10.X * dt), math.rad(v10.Y * dt), (math.rad(v10.Z * dt)))
				identity2 *= CFrame.fromOrientation(math.rad(v11.X * dt), math.rad(v11.Y * dt), (math.rad(v11.Z * dt)))
				local v13 = center
				local smoothDamp, v14 = TweenService:SmoothDamp(
					center.CFrame,
					(core.CFrame + identity * v9) * identity2,
					identity3,
					1,
					nil,
					dt
				)
				v13.CFrame = smoothDamp
				identity3 = v14
			end))
		end)
	end
end

function StarcallerCry.EndVfx(_, _, p: string, p2: number)
	local folder = v3[p]

	if not folder then
		return
	end

	v2[p] = p2
	local v5 = v[p]

	if p2 == 2 then
		TweenService:Create(folder.Core.Idle, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			PlaybackSpeed = 2,
			Volume = 0
		}):Play()
		local scale = folder:GetScale()
		local cFrame = folder.Core.CFrame
		local v6 = v4[p]
		local total = 0

		while true do
			total += RunService.RenderStepped:Wait()

			if not folder:FindFirstChild("Core") then
				break
			end

			local value = TweenService:GetValue(total, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			folder:ScaleTo((math.max(scale * (1 - value), 0.01)))
			local core = folder.Core
			local v7

			if v6 then
				v7 = CFrame.new(v6.Position) or cFrame
			else
				v7 = cFrame
			end

			core.CFrame = cFrame:Lerp(v7, value)

			if total >= 1 then
				break
			end
		end

		if v5 then
			v5:Clean()
		end
	elseif p2 == 1 then
		TweenService:Create(folder.Core, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = createVector(0.01, 0.01, 0.01)
		}):Play()

		if folder:FindFirstChild("OuterDistortion") then
			TweenService:Create(
				folder.OuterDistortion,
				TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{
					Size = createVector(0.01, 0.01, 0.01),
					Transparency = 1
				}
			):Play()
		end

		TweenService:Create(folder.Core.Idle, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			PlaybackSpeed = 0
		}):Play()

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Light") then
				TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Brightness = 0
				}):Play()
			end
		end

		for _, child in folder.Core.ExtraShading:GetChildren() do
			TweenService:Create(child, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
		end

		task.delay(5, function()
			if v5 then
				v5:Clean()
			end
		end)
	end
end

return StarcallerCry