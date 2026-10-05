local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Blade").M1.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local CreateBlade = require(script.Parent.Modules.CreateBlade)

local function FireSlash(cFrame, folder, p, player)
	local clone = assets.Phase1.SlashModel:Clone()
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")
	local v = math.random(90, 110) / 100
	Util.Sound:Play("Slice.SliceM1", cFrame.Position, nil, v)
	task.spawn(function()
		task.wait(0.01)

		for i = 100, 225, 25 do
			clone:ScaleTo(i / 100)
			RunService.Heartbeat:Wait()
		end
	end)

	for _, beam in pairs(slash:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local startDelay = beam:GetAttribute("StartDelay")
		local v2 = beam
		local v3 = beam:GetAttribute("EndDelay")
		task.spawn(function()
			TweenService:Create(v2, TweenInfo.new(v3 / 3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = v2.Width0 * 3,
				Width1 = v2.Width1 * 3
			})
			task.wait(startDelay)
		end)
	end

	local clone2 = assets.Phase1.StartImpact:Clone()
	clone2.Slash2:Destroy()
	clone2.CFrame = slash.CFrame * (p and CFrame.Angles(0, 3.141592653589793, 0) or CFrame.new())
	Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")
	clone2.Attachment.WindSlice:Emit(1)
	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
	local clone3 = assets.Phase1.StartImpact:Clone()
	clone3.CFrame = slash.CFrame
	Util.SetParentOverrideWithColor(clone3, folder, player, "BladeFruitVFXColor")

	for _, emitter in clone3:GetDescendants() do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "WindSlice") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(slash, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = cFrame * CFrame.new(0, 0, -30)
	})
	tween:Play()
	tween.Completed:Wait()

	for _, effect in pairs(slash:GetDescendants()) do
		if effect:IsA("Beam") then
			local v2 = effect
			task.spawn(function()
				local v3 = v2:GetAttribute("EndDelay") * 0.5
				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v2:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end

	local clone4 = assets.Phase1.ProjectileEnd:Clone()
	clone4.CFrame = slash.CFrame
	Util.SetParentOverrideWithColor(clone4, folder, player, "BladeFruitVFXColor")

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
end

return function(data)
	local root = data.Root
	local player = data.player
	local cFrame = data.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 3)

	if data.Combo == 1 then
		local blade = CreateBlade(root.Parent.LeftLowerArm, folder, nil, player)
		task.delay(0.25, function()
			blade:Shrink()
		end)
		FireSlash(
			cFrame * CFrame.Angles(math.rad(math.random(-90, 90) / 100), 0, 1.7802358370342162),
			folder,
			true,
			player
		)
	elseif data.Combo == 2 then
		local blade = CreateBlade(root.Parent.RightLowerArm, folder, CFrame.Angles(0, 3.141592653589793, 0), player)
		task.delay(0.25, function()
			blade:Shrink()
		end)
		FireSlash(
			cFrame * CFrame.Angles(math.rad(math.random(-90, 90) / 100), 0, 1.361356816555577),
			folder,
			nil,
			player
		)
	end
end