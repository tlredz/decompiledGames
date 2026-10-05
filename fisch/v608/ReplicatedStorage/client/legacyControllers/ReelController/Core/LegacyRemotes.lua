game:GetService("UserInputService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.Hook)
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.library.fish)
local events = ReplicatedStorage:WaitForChild("events")
local remoteEvent = Net:RemoteEvent("ProgressModifier", -1)
local remoteEvent2 = Net:RemoteEvent("ResilienceModifier", -1)
require("../Types")
local LegacyRemotes = {}
LegacyRemotes.__index = LegacyRemotes

function LegacyRemotes.new(current)
	local object = setmetatable({}, LegacyRemotes)
	object.current = current
	object.trove = current.trove:Extend()
	return object
end

function LegacyRemotes.Start(p)
	Random.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function impact(reel_bar, _: UDim2, p2: number, p3: number, flag: boolean?, p4: number?)
		p.current.fx:Shake(reel_bar, 0.8, p2, p3, flag, p4)
	end

	p.trove:Add(events:WaitForChild("debug_hammerhit").OnClientEvent:Connect(function(value)
		p.current:AddProgress(value or 30)
		local reel_bar = p.current.reel_bar
		local _ = p.current.reel_bar.Position
		impact(reel_bar, nil, 0.8, 0.025, true, nil) -- equivalent call inferred; original call site unknown
	end))
	p.trove:Add(events:WaitForChild("debug_swordhit").OnClientEvent:Connect(function(value, p2)
		if p2 then
			task.spawn(function()
				for _ = 1, 10 do
					p.current:WaitLogic(0.1)
					p.current:AddProgress(10)
				end
			end)
		else
			p.current:AddProgress(value or 99)
		end

		local reel_bar = p.current.reel_bar
		local _ = p.current.reel_bar.Position
		p.current.fx:Shake(reel_bar, 0.8, 0.8, 0.02, not p2, nil)
	end))
	p.trove:Add(events:WaitForChild("debug_daggerhit").OnClientEvent:Connect(function()
		p.current:AddProgress(55)
	end))
	p.trove:Add(events:WaitForChild("debug_guitar").OnClientEvent:Connect(function(p2)
		p.current:AddProgress(p2 and 10 or 5)
	end))
	p.trove:Add(events:WaitForChild("debug_giveprogress").OnClientEvent:Connect(function(p2)
		p.current:AddProgress(p2)
	end))
	p.trove:Add(remoteEvent.OnClientEvent:Connect(function(p2, p3)
		if p2 == 1 then
			p.current:AddModifier("progressefficiency", "add", p3)
		elseif p2 == 2 then
			p.current:AddModifier("progress", "add", p3)
		end
	end))
	p.trove:Add(remoteEvent2.OnClientEvent:Connect(function(p2: number)
		p.current:AddModifier("resilience", "multiply", p2)
	end))
	p.trove:Add(p.current.OnReady:Once(function()
		if p.current.data.TimedBoosts then
			for _, timedBoost in p.current.data.TimedBoosts do
				local v = timedBoost
				p.current:DelayLogic(timedBoost.Delay or 0, function()
					if not (p.current and p.current.active) then
						return
					end

					if v.ProgressIcon then
						task.spawn(function()
							local clone = script.Seraphic:Clone()
							clone.Image = v.ProgressIcon
							clone.ImageColor3 = v.ProgressIconColor or Color3.new(1, 1, 1)
							clone.Visible = true
							clone.Parent = p.current.reel_progress

							for i = 1, 3 do
								local clone2 = clone:Clone()
								clone2.Name = "SeraphicClone"
								clone2.Parent = p.current.reel_progress
								local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
								p.current.renderTweens:Create(clone2, tweenInfo, {
									ImageTransparency = 1
								}):Play()
								p.current.renderTweens:Create(clone2.UIScale, tweenInfo, {
									Scale = 1.5
								}):Play()
								p.current:DelayRender(tweenInfo.Time, function()
									if clone2 then
										clone2:Destroy()
									end
								end)
								p.current:WaitRender(1)
								p.current.renderTweens:Create(clone, tweenInfo, {
									ImageTransparency = 1
								}):Play()
								p.current:DelayRender(tweenInfo.Time, function()
									clone.Visible = false
									clone.ImageTransparency = 0
								end)
							end
						end)
					end

					if v.ShakeIntensity ~= 0 then
						p.current.fx:SpawnShake(
							p.current.reel_bar,
							v.ShakeIntensity or 0.8,
							v.ShakeTime or 0.8,
							0.025,
							v.ShakeRotates,
							v.ShakeIntensityDecay
						)
					end

					local split = v.Split or 1

					for i = 1, split do
						if p.current and p.current.active then
							local finalMult = i == split and v.FinalMult or 1
							p.current:AddProgress((v.Progress or 30) / split * finalMult)
							p.current:WaitLogic(v.SplitInterval or 0.1)
						else
							break
						end
					end
				end)
			end
		end

		if p.current.data.RepeatedBoosts then
			for _, repeatedBoost in p.current.data.RepeatedBoosts do
				local v = repeatedBoost
				task.spawn(function()
					local random = p.current:GetRandom(v.SeedOffset or 10)

					while p.current and p.current.active do
						p.current:WaitLogic(random:NextNumber(v.MinInterval, v.MaxInterval))
						p.current:DelayLogic(v.ExtraDelay or 0, function()
							if not (p.current and p.current.active) then
								return
							end

							if v.ShakeIntensity ~= 0 then
								p.current.fx:SpawnShake(
									p.current.reel_bar,
									v.ShakeIntensity or 0.25,
									v.ShakeTime or 0.25,
									0.025,
									v.ShakeRotates,
									v.ShakeIntensityDecay
								)
							end

							p.current:AddProgress(v.Progress or 30)
						end)
					end
				end)
			end
		end
	end))
end

function LegacyRemotes:Disable()
	self.Disabled = true
end

function LegacyRemotes.Stop(p)
	p.trove:Clean()
end

function LegacyRemotes.Tick(_, _: number) end

return LegacyRemotes