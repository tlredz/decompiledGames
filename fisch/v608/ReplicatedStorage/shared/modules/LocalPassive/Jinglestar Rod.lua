local JinglestarRod = {}
game:GetService("ContentProvider")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function JinglestarRod.Morph(p, p2, object)
	object:Preload(script:GetChildren())
	task.spawn(function()
		object:WaitUntilReady()
		local over = game.Players.LocalPlayer.PlayerGui:WaitForChild("over")
		local playerbar = p2.playerbar
		local backgroundColor3 = playerbar.BackgroundColor3
		local bell = script.Bell
		local clone = script.ChristmasBell:Clone()
		p.reelTrove:Add(clone)
		clone.Parent = over
		object.OnMinigameEnd:Once(function()
			clone:Destroy()
		end)
		local uIScale = clone.UIScale
		local now = 0
		local count = 0
		local flag = true
		local v = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function CancelTween()
			if v then
				v:Cancel()
			end
		end

		local function JingleDaBellz(p3: number)
			bell:Play()
			bell.PlaybackSpeed = p3 == 1 and 1.15 or 1
			CancelTween() -- equivalent call inferred; original call site unknown
			clone.Rotation = p3 == 1 and -30 or 30
			v = object.renderTweens:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0
			})
			v:Play()
		end

		object.trove:Add(object.OnBarDirectionChange:Connect(function(p3: number)
			if not object.active or object.isPaused or object.logicPaused then
				return
			end

			if flag then
				local v2 = tick() - now < 0.1

				if not v2 then
					JingleDaBellz(p3)
				end

				if tick() - now <= 0.5 and not v2 then
					count += 1
				else
					if v2 then
						flag = false
						object:DelayLogic(0.5, function()
							flag = true
						end)
						CancelTween() -- equivalent call inferred; original call site unknown
						script.Break:Play()
						clone.Rotation = -10
						clone.ImageColor3 = Color3.fromRGB(150, 150, 150)
						uIScale.Scale = 1.3
						object.renderTweens:Create(clone, TweenInfo.new(0.5), {
							Rotation = 0,
							ImageColor3 = Color3.fromRGB(255, 255, 255)
						}):Play()
						object.renderTweens:Create(uIScale, TweenInfo.new(0.5), {
							Scale = 1
						}):Play()
					end

					count = 0
				end

				clone.Streak.Text = count
			end

			now = tick()

			if count >= 10 then
				flag = false
				object:DelayLogic(2, function()
					flag = true
				end)
				object:AddProgress(20)
				clone.Streak.Text = "!!"
				playerbar.BackgroundColor3 = Color3.fromRGB(255, 236, 94)
				TweenService:Create(playerbar, TweenInfo.new(1), {
					BackgroundColor3 = backgroundColor3
				}):Play()
				CancelTween() -- equivalent call inferred; original call site unknown
				clone.Rotation = 0
				uIScale.Scale = 1.5
				TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1
				}):Play()
				count = 0
			end
		end))
	end)
end

setmetatable(JinglestarRod, module)
return JinglestarRod