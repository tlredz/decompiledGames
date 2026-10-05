local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local tweenInfo = TweenInfo.new(1)

local function updateReadyStatusTimer(gui, text)
	local margin = gui.SelectionFrame:FindFirstChild("Margin")

	if not margin then
		return
	end

	local bottomFrame = margin:FindFirstChild("BottomFrame")

	if not bottomFrame then
		return
	end

	local readyStatus = bottomFrame:FindFirstChild("ReadyStatus")

	if not readyStatus then
		return
	end

	local gameStarting = readyStatus:FindFirstChild("GameStarting")

	if not gameStarting then
		return
	end

	local v = string.match(text, "Round will begin in%.%.%. (%d+)") or string.match(text, "Voting ends in%.%.%. (%d+)")

	if v then
		gameStarting.Text = "Round starts in " .. v .. "s"
	elseif text == "All players ready! Round beginning..." then
		gameStarting.Text = "READY!"
	elseif text == "Round beginning..." then
		gameStarting.Text = "START"
	end
end

local function playPanicTick()
	if workspace.Info.Panic.Value ~= true then
		return
	end

	local playbackSpeed = 0.6 * (1 + (40 - workspace.Info.PanicTimer.Value) / 40)

	if workspace.Info.PanicTimer.Value <= 10 then
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.Tick", {
			PlaybackSpeed = playbackSpeed
		})
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TickDanger")
	else
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.Tick", {
			PlaybackSpeed = playbackSpeed
		})
	end
end

return {
	setup = function()
		local gui = GameContext.Gui
		local message = gui.Menu.Message
		local v = nil
		local v2 = nil
		local v3 = false
		local lastTime = tick()
		workspace.Info.Message.Changed:Connect(function(text)
			if v then
				v:Pause()
				v:Destroy()
			end

			if v2 then
				v2:Pause()
				v2:Destroy()
				v3 = true
			end

			message.Visible = true
			message.Transparency = 0.5
			message.TextTransparency = 0
			message.Text = text
			lastTime = tick()
			v = TweenService:Create(message, tweenInfo, {
				Transparency = 1
			})
			v2 = TweenService:Create(message, tweenInfo, {
				TextTransparency = 1
			})
			updateReadyStatusTimer(gui, text)
			message.Visible = text ~= ""
			playPanicTick()
			task.spawn(function()
				task.wait(6)

				if tick() - lastTime < 6 then
					return
				end

				local info = workspace:FindFirstChild("Info")

				if info and info:GetAttribute("PersistentMessage") and info:GetAttribute("InBreakRoom") then
					return
				end

				v3 = false
				v:Play()
				v2:Play()
				task.delay(1, function()
					if not v3 then
						message.Visible = false
					end
				end)
			end)
		end)
	end
}