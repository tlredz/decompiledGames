local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local random = math.random
local rad = math.rad

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function handEffects(hand, holdValue)
	local function skyString()
		wait(0.05)
		local position = hand.CFrame.p + Vector3.new(math.random(-1, 1), -4, math.random(-1, 1))
		local clone = FX:WaitForChild("StringEffects").StringCageSummonRay:Clone()
		Util.Debris:AddItem(clone, 3)
		local clone2 = FX:WaitForChild("StringEffects").StringWind:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone.Position = position
		clone2.Position = position
		clone.Parent = _WorldOrigin
		clone2.Parent = _WorldOrigin
		local position2 = clone.Position + createVector(0, 100, 0)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Position = position2
			}
		)
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		local v5 = clone2.CFrame * CFrame.new(0, 10, 0)
		local v7 = rad((random(-20, 20)))
		local v9 = rad((random(-180, 180)))
		local v10 = random(-20, 20)
		local v11 = TweenService:Create(clone2, tweenInfo, {
			Size = createVector(10, 3, 10),
			CFrame = v5 * CFrame.Angles(v7, v9, (rad(v10))),
			Transparency = 1
		})
		Util.Sound:Play("StringShot", hand.Position, nil, 4 + math.random(-30, 30) / 100, 0.5)
		tween:Play()
		v11:Play()
		v11.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween.Completed:Connect(function()
			wait(0.5)
			clone:Destroy()
		end)
	end

	local v = false
	local parent = Util.Sound:Play("SeaBite", hand.Position, nil, 0.8 + math.random(-10, 10) / 100, 0.25)
	local echoSoundEffect = Instance.new("EchoSoundEffect")
	echoSoundEffect.Delay = 0.05
	echoSoundEffect.Feedback = 0.44
	local flangeSoundEffect = Instance.new("FlangeSoundEffect")
	flangeSoundEffect.Depth = 0.95
	flangeSoundEffect.Mix = 0.85
	flangeSoundEffect.Rate = 4
	echoSoundEffect.Parent = parent
	flangeSoundEffect.Parent = parent
	local clone = FX:WaitForChild("StringEffects").StringCastEffect:Clone()
	Util.Debris:AddItem(clone, 5)
	local innerSwirls = clone.InnerSwirls
	innerSwirls.Anchored = false
	local outerSwirls = clone.OuterSwirls
	outerSwirls.Anchored = false
	clone:SetPrimaryPartCFrame(hand.CFrame)
	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = hand
	weld.Part1 = innerSwirls
	local weld2 = Instance.new("Weld")
	weld2.Parent = clone
	weld2.Part0 = hand
	weld2.Part1 = outerSwirls
	clone.Parent = _WorldOrigin
	spawn(function()
		local tween = TweenService:Create(
			innerSwirls,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1
			}
		)
		local tween2 = TweenService:Create(
			outerSwirls,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween2:Play()
		tween.Completed:Connect(function()
			v = true
			clone:Destroy()
		end)

		while hand ~= nil and v == false do
			RunService.RenderStepped:Wait()
			weld.C0 *= CFrame.Angles(0, 0.13962634015954636, 0)
			weld2.C0 *= CFrame.Angles(0, -0.3141592653589793, 0)
		end
	end)
	skyString()
	skyString()
	skyString()
	skyString()
	skyString()
	skyString()

	while holdValue ~= nil and holdValue.Value == true and holdValue ~= nil and holdValue.Parent.Parent ~= nil do
		skyString()
	end

	wait(1)
	clone:Destroy()
end

local function stringCage(cFrame, cageSizeFactor)
	local tweens = {}

	for _ = 0, 5 do
		local _ = { -18, 18 }
		wait(0.05)
		local clone = FX:WaitForChild("StringEffects").StringCageSummonRay:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.Position = cFrame.p + Vector3.new(math.random(-1, 1), 100, math.random(-1, 1))
		clone.Parent = _WorldOrigin
		local position = (CFrame.new(clone.Position + createVector(0, -100, 0)) * CFrame.Angles(
			0,
			rad((random(-180, 180))),
			0
		) * CFrame.new(32 * cageSizeFactor, 0, 0)).p
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Position = position
			}
		)
		Util.Sound:Play("StringShot", cFrame.p, nil, 4 + math.random(-30, 30) / 100, 0.5)
		tween:Play()
		tween.Completed:Connect(function()
			wait(0.5)
			clone:Destroy()
		end)
	end

	local flag = true
	local v = false

	for _ = 1, math.floor(25 * cageSizeFactor) do
		RunService.RenderStepped:Wait()

		if flag then
			Util.Sound:Play("SpinWoosh", cFrame.p, nil, 1.5 + math.random(-20, 20) / 100, 0.5)
			flag = false
		else
			flag = true
		end

		local clone = FX:WaitForChild("StringEffects").StringArchBeam:Clone()
		Util.Debris:AddItem(clone, 10)

		for _, child in pairs(clone:GetChildren()) do
			if child:IsA("Attachment") then
				child.Position *= cageSizeFactor
			elseif child:IsA("Beam") then
				child.CurveSize0 *= cageSizeFactor
				child.CurveSize1 *= cageSizeFactor
			end
		end

		local stringEmitter = clone.StringEmitter
		local attachment0 = clone.Attachment0
		local attachment1 = clone.Attachment1
		local beam = clone.Beam
		clone.CFrame = cFrame * CFrame.Angles(
			rad((random(-180, 180))),
			rad((random(-180, 180))),
			(rad((random(-180, 180))))
		)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}
		)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				CFrame = clone.CFrame * CFrame.Angles(0, 6.440264939859076, 0)
			}
		)
		local tween3 = TweenService:Create(
			attachment0,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				Position = createVector(0, 0, 0)
			}
		)
		local tween4 = TweenService:Create(
			attachment1,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				Position = createVector(0, 0, 0)
			}
		)
		local tween5 = TweenService:Create(
			beam,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
			{
				CurveSize0 = 0,
				CurveSize1 = 0,
				Width0 = 0.01,
				Width1 = 0.01
			}
		)
		tween5.Completed:Connect(function()
			stringEmitter:Emit(1)

			if not v then
				v = true
				local character = game.Players.LocalPlayer.Character

				if character ~= nil then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and (humanoidRootPart.Position - cFrame.p).magnitude <= 32 * cageSizeFactor + 10 then
						Util.CameraShaker:ShakeOnce(10, 10, 0.2, 0.8)
					end
				end

				for i = 0, 3 do
					local clone2 = FX:WaitForChild("StringEffects").StringCurveMesh:Clone()
					Util.Debris:AddItem(clone2, 5)
					clone2.Color = Color3.new(1, 1, 1)
					clone2.Size = createVector(1, 1, 1)
					clone2.CFrame = cFrame * CFrame.Angles(
						rad((random(-180, 180))),
						rad((random(-180, 180))),
						(rad((random(-180, 180))))
					)
					local tween6 = TweenService:Create(
						clone2,
						TweenInfo.new(
							math.random(3, 6) / 10,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.Out,
							0,
							false,
							0
						),
						{
							Transparency = 1,
							Size = Vector3.new(65 * cageSizeFactor, 1, 65 * cageSizeFactor),
							CFrame = clone2.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
						}
					)
					tween6.Completed:Connect(function()
						clone2:Destroy()
					end)
					clone2.Parent = _WorldOrigin
					tween6:Play()
				end

				local clone2 = FX:WaitForChild("StringEffects").StringWind:Clone()
				clone2.CFrame = cFrame * CFrame.Angles(0, rad((random(-180, 180))), 0)
				clone2.Material = Enum.Material.Neon
				local tween6 = TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1,
						Size = Vector3.new(80 * cageSizeFactor, 30, 80 * cageSizeFactor),
						CFrame = clone2.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
					}
				)
				tween6.Completed:Connect(function()
					clone2:Destroy()
				end)
				clone2.Parent = _WorldOrigin
				tween6:Play()
			end

			wait(3)
			clone:Destroy()
		end)
		table.insert(tweens, tween3)
		table.insert(tweens, tween4)
		table.insert(tweens, tween5)
		table.insert(tweens, tween2)
		clone.Parent = _WorldOrigin
		tween:Play()
	end

	return tweens
end

return function(data)
	local cFrame = data.CFrame
	local hand = data.Hand or nil
	local holdValue = data.HoldValue or nil
	local cageSizeFactor = data.CageSizeFactor or nil

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	if hand then
		handEffects(hand, holdValue)
		return
	end

	local v = stringCage(cFrame, cageSizeFactor)
	Util.Sound:Play("CircleCreate", cFrame.p, nil, 1.2 + math.random(-20, 20) / 100, 1)

	for _, v2 in pairs(v) do
		v2:Play()
	end
end