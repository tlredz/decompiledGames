local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local MessagePacingCore = require(ReplicatedStorage.Modules.ClientUI.MessagePacingCore)
local MessagingController = {}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false)
local size = nil
local size2 = nil
local now = tick()
local lastTime = tick()
local v = MessagePacingCore.new()
local count = 0
local flag = false

function MessagingController.ErrorMessage(text, value)
	local gui = GameContext.Gui
	local v2 = value or 1

	if gui.TextMessage then
		gui.TextMessage.Visible = false
	end

	if gui.ErrorMessage then
		if not size then
			size = gui.ErrorMessage.Size
		end

		gui.ErrorMessage.Size = UDim2.new(size.X.Scale * 0.9, 0, size.Y.Scale * 0.9, 0)
		gui.ErrorMessage.Visible = true
		gui.ErrorMessage.Text = text
	end

	Audio:PlayOne("Sounds.UI.Combat.CantUse")
	lastTime = tick()

	if gui.ErrorMessage then
		TweenService:Create(gui.ErrorMessage, tweenInfo, {
			Size = size
		}):Play()
	end

	task.spawn(function()
		task.wait(v2)

		if v2 <= tick() - lastTime and gui.ErrorMessage then
			gui.ErrorMessage.Visible = false
		end
	end)
end

local function popInText(p, size3, text)
	local gui = GameContext.Gui

	if gui.ErrorMessage then
		gui.ErrorMessage.Visible = false
	end

	p.Size = UDim2.new(size3.X.Scale * 0.9, 0, size3.Y.Scale * 0.9, 0)
	p.Visible = true
	p.Text = text
	p.TextScaled = true
	Audio:PlayOne("Sounds.UI.Buttons.Click")
	TweenService:Create(p, tweenInfo, {
		Size = size3
	}):Play()
end

local function showTextLine(text)
	local gui = GameContext.Gui
	local textMessage = gui.TextMessage

	if not size and gui.ErrorMessage then
		size = gui.ErrorMessage.Size
	end

	if textMessage and size then
		popInText(textMessage, size, text)
		return MessagePacingCore.holdSeconds(text)
	else
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pumpTextQueue()
	if flag then
		return
	end

	flag = true
	local v2 = count
	task.spawn(function()
		while v2 == count do
			local v3 = MessagePacingCore.take(v)

			if v3 then
				local success, result = pcall(showTextLine, v3)

				if success then
					if result then
						task.wait(result)
					end
				else
					warn("[MessagingController] could not show text line:", result)
				end
			else
				local gui = GameContext.Gui
				local textMessage = gui and gui.TextMessage

				if not textMessage then
					break
				end

				textMessage.Visible = false
				break
			end
		end

		if v2 == count then
			flag = false
		end
	end)
end

function MessagingController.QueueTextMessage(p)
	if MessagePacingCore.enqueue(v, p) then
		pumpTextQueue() -- equivalent call inferred; original call site unknown
	end
end

function MessagingController.TextMessage(text, p2)
	if p2 then
		local textMessageSelection = GameContext.Gui.TextMessageSelection

		if textMessageSelection and not size2 then
			size2 = textMessageSelection.Size
		end

		if not (textMessageSelection and size2) then
			return
		end

		popInText(textMessageSelection, size2, text)
		now = tick()
		local holdSeconds = MessagePacingCore.holdSeconds(text)
		task.spawn(function()
			task.wait(holdSeconds)

			if holdSeconds <= tick() - now then
				textMessageSelection.Visible = false
			end
		end)
	elseif MessagePacingCore.interrupt(v, text) then
		count += 1
		flag = false
		flag = true
		local v2 = count
		task.spawn(function()
			while v2 == count do
				local v3 = MessagePacingCore.take(v)

				if v3 then
					local success, result = pcall(showTextLine, v3)

					if success then
						if result then
							task.wait(result)
						end
					else
						warn("[MessagingController] could not show text line:", result)
					end
				else
					local gui = GameContext.Gui
					local textMessage = gui and gui.TextMessage

					if not textMessage then
						break
					end

					textMessage.Visible = false
					break
				end
			end

			if v2 == count then
				flag = false
			end
		end)
	end
end

function MessagingController.ClearTextMessages()
	local gui = GameContext.Gui

	if gui.TextMessage then
		gui.TextMessage.Visible = false
	end

	if gui.TextMessageSelection then
		gui.TextMessageSelection.Visible = false
	end

	if gui.ErrorMessage then
		gui.ErrorMessage.Visible = false
	end

	MessagePacingCore.clear(v)
	count += 1
	flag = false
	now = 0
end

function MessagingController.setup()
	GameContext.TextMessage = MessagingController.TextMessage
	GameContext.QueueTextMessage = MessagingController.QueueTextMessage
	GameContext.ErrorMessage = MessagingController.ErrorMessage
	GameContext.ClearTextMessages = MessagingController.ClearTextMessages
end

return MessagingController