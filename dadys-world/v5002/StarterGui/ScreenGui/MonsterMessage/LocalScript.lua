local position = script.Parent.Position
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local monsterDialogueEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("MonsterDialogueEvent")
local CharacterInfo = require(ReplicatedStorage.StoryScripts.CharacterInfo)
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function editposition()
	if script.Parent.Parent.Menu.Decoding.Value == true then
		TweenService:Create(script.Parent, tweenInfo, {
			Position = position + UDim2.new(0, 0, -0.15, 0)
		}):Play()
	else
		TweenService:Create(script.Parent, tweenInfo, {
			Position = position
		}):Play()
	end
end

script.Parent.Parent.Menu.Decoding:GetPropertyChangedSignal("Value"):Connect(function()
	editposition()
end)
editposition()
local lastTime = tick()
local v = nil
local v2 = nil
local v3 = false
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateDialogue(p, text, duration, _, _)
	if CharacterInfo[p] then
		local function CreateDialogueBox()
			lastTime = tick()
			Audio:Play(CharacterInfo[p].TalkSound, {
				Volume = CharacterInfo[p].Volume,
				PlaybackSpeed = CharacterInfo[p].PlaybackSpeed * math.random(95, 105) / 100,
				Parent = script.Parent
			})

			if v then
				v:Pause()
				v:Destroy()
				v3 = true
			end

			if v2 then
				v2:Pause()
				v2:Destroy()
				v3 = true
			end

			script.Parent.Message.Text = text
			script.Parent.Message.TextColor3 = CharacterInfo[p].Color
			script.Parent.Message.Font = CharacterInfo[p].CharacterFont
			script.Parent.Message.TextTransparency = 1
			script.Parent.Message.TextStrokeTransparency = 1
			script.Parent.Background.ImageTransparency = 1
			v = TweenService:Create(script.Parent.Message, tweenInfo2, {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			})
			v2 = TweenService:Create(script.Parent.Background, tweenInfo2, {
				ImageTransparency = 0.2
			})
			v:Play()
			v2:Play()
			task.spawn(function()
				task.wait(duration)

				if duration <= tick() - lastTime then
					v3 = false

					if v then
						v:Pause()
						v:Destroy()
					end

					if v2 then
						v2:Pause()
						v2:Destroy()
					end

					v = TweenService:Create(script.Parent.Message, tweenInfo3, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					})
					v2 = TweenService:Create(script.Parent.Background, tweenInfo3, {
						ImageTransparency = 1
					})
					v:Play()
					v2:Play()
				end
			end)
		end

		CreateDialogueBox()
	end
end

monsterDialogueEvent.OnClientEvent:Connect(function(p, text, duration, p2, p3, p4)
	print(p, text, duration, p2, p3, p4)
	CreateDialogue(p, text, duration) -- equivalent call inferred; original call site unknown
end)