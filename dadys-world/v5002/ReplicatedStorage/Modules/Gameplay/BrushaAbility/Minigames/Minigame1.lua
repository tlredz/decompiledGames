local RunService = game:GetService("RunService")
local v = {
	Index = 1,
	DisplayName = "Option 1 — Paint the Canvas",
	Description = "Sweep the brush around to fill the meter and lay down the painting. No time limit."
}

if RunService:IsServer() then
	function v:setup()
		self.state = {}
		return true
	end

	function v.start(_) end

	function v.yield(p)
		local parentModule = require(script.Parent.Parent)
		return parentModule.PromptClient(p)
	end

	function v.run(p)
		v.start(p)
		return v.yield(p)
	end

	function v.interrupt(_, _) end

	function v:cleanup()
		self.state = nil
	end

	return v
else
	local TweenService = game:GetService("TweenService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local MinigameShell = require(script.Parent.Parent.MinigameShell)
	local Audio = require(ReplicatedStorage.SharedUtils.Audio)
	local v2 = {
		KeyboardAndMouse = "Swipe back and forth to paint!",
		Touch = "Swipe back and forth to paint!",
		Gamepad = "Move right thumbstick back and forth to paint!"
	}

	local function addStroke(state)
		state.index += 1
		Audio:Play("Sounds.Toon.Brusha.Ability", {
			PlaybackSpeed = 1.8 + math.random() * 0.40000000000000013
		})
		state.shell:notifySwipe()
		local v3 = state.shell.paintInfo.Sequence[state.index]

		if not v3 then
			return
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Stroke" .. state.index
		imageLabel.Image = v3.Image
		imageLabel.ImageColor3 = v3.Color or Color3.fromRGB(255, 255, 255)
		imageLabel.Size = UDim2.fromScale(1.2, 1.2)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = 1
		imageLabel.Rotation = (math.random() - 0.5) * 15
		imageLabel.ZIndex = state.index
		imageLabel.Parent = state.shell.canvas
		table.insert(state.strokes, imageLabel)
		TweenService:Create(imageLabel, TweenInfo.new(0.2), {
			Size = UDim2.fromScale(1, 1),
			Rotation = 0,
			ImageTransparency = 0
		}):Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setProgressBar(p)
		p.shell:setTimer(p.progress, 1)
	end

	local function finish(state, success, reason)
		if state.finishing then
			return
		end

		state.finishing = true
		state.success = success
		state.reason = reason

		if state.session and state.session.report then
			state.session.report(success)
		end

		state.shell:playOutro(success, state.strokes, function()
			state.resolved = true
		end)
	end

	function v:setup()
		local shell, v4 = MinigameShell.open(self)

		if not shell then
			warn("[BrushaMinigame1] cannot run: " .. tostring(v4))
			return false
		end

		local sequence = shell.paintInfo.Sequence

		if sequence and #sequence ~= 0 then
			shell:setHint(v2)
			shell:showDirectionIndicator()
			shell:setSwipeDirection(true)
			shell:showBaselineGhost()
			shell:showSwipeHint()
			local clock = shell.timerBar and shell.timerBar:FindFirstChild("Clock")

			if clock then
				clock.Visible = false
			end

			self.state = {
				session = self,
				shell = shell,
				total = #sequence,
				index = 0,
				progress = 0,
				lastAlpha = nil,
				strokes = {},
				finishing = false,
				resolved = false,
				success = false
			}
			return true
		else
			warn("[BrushaMinigame1] PaintInfo has no Sequence — cannot run")
			shell:close()
			return false
		end
	end

	function v.start(p)
		local state = p.state

		if not state then
			return
		end

		setProgressBar(state) -- equivalent call inferred; original call site unknown
		state.shell:setProgress(0, state.total)
		state.heartbeat = RunService.Heartbeat:Connect(function(dt)
			local lastAlpha = state.shell:update(dt)

			if state.finishing or dt <= 0 then
				return
			end

			if not state.lastAlpha then
				state.lastAlpha = lastAlpha
				return
			end

			local magnitude = (lastAlpha - state.lastAlpha).Magnitude
			state.lastAlpha = lastAlpha

			if magnitude / dt < 0.05 or not state.shell:containsAlpha(state.shell.canvas, lastAlpha) then
				return
			end

			local v4 = 1.9

			if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
				v4 *= 2.2
			end

			local v5 = math.min(magnitude, 6 * dt) * v4
			state.progress = math.min(state.progress + v5 / 6, 1)
			setProgressBar(state) -- equivalent call inferred; original call site unknown

			if lastAlpha.X <= 0.35 then
				state.shell:setSwipeDirection(true)
			elseif lastAlpha.X >= 0.65 then
				state.shell:setSwipeDirection(false)
			end

			local v7 = math.floor(state.progress * state.total)

			while state.index < v7 do
				addStroke(state)
				state.shell:setProgress(state.index, state.total)
			end

			if state.index >= state.total then
				finish(state, true)
			end
		end)
	end

	function v.yield(data)
		local state = data.state

		if not state then
			return false
		end

		while not state.resolved do
			if data.aborted and not state.finishing then
				finish(state, false, data.abortReason)
			end

			task.wait(0.05)
		end

		return state.success == true
	end

	function v.run(p)
		v.start(p)
		return v.yield(p)
	end

	function v.interrupt(p, reason)
		local state = p.state

		if state then
			finish(state, false, reason)
		end
	end

	function v:cleanup()
		local state = self.state

		if not state then
			return
		end

		self.state = nil

		if state.heartbeat then
			state.heartbeat:Disconnect()
		end

		state.shell:close()
	end

	return v
end