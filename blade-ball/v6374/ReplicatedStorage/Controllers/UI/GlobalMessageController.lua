local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Net)
local messages = playerGui:WaitForChild("GlobalMessageUI"):WaitForChild("Messages")
local template = messages:WaitForChild("UIListLayout"):WaitForChild("Template")
local remoteEvent = v:RemoteEvent("GetGlobalMessages")
local GlobalMessageController = {}

function GlobalMessageController:Start()
	self.Queue = {}
	self.BatchQueue = {}
	self.Running = 0
	self.MaxListening = 3
	self.IsProcessing = false
	v:Connect("CreateGlobalMessages", function(p)
		self:EnqueueBatch(p)
	end)
	remoteEvent:FireServer()
end

function GlobalMessageController:DisplayMessage(data)
	if not (data and data.Message) then
		return warn("[GlobalMessage] Tried to display invalid message:", data)
	end

	local clone = template:Clone()
	local frame = clone.Frame
	clone.Name = "Message from " .. data.Caller
	local success, result = pcall(function()
		return {
			Name = data.CallerName or Players:GetNameFromUserIdAsync(data.Caller),
			Picture = Players:GetUserThumbnailAsync(
				data.Caller,
				Enum.ThumbnailType.AvatarBust,
				Enum.ThumbnailSize.Size180x180
			)
		}
	end)

	if success and result then
		frame.Title.Title.Text = `{result.Name} `
		frame.Picture.Picture.Image = result.Picture
	else
		frame.Title:Destroy()
		frame.Picture:Destroy()
	end

	frame.Message.Message.Text = data.Message

	if data.DoNotDisplayTitle then
		frame.Title.Visible = false
	end

	frame.GroupTransparency = 1
	clone.UIScale.Scale = 0
	clone.Parent = messages
	TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		GroupTransparency = 0
	}):Play()
	TweenService:Create(clone.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
		Scale = 1
	}):Play()
	ReplicatedStorage2.Assets.UI.Notification.Notification:Play()
	task.wait(data.Duration + 1)
	TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		GroupTransparency = 1,
		Rotation = 0
	}):Play()
	TweenService:Create(clone.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Scale = 0
	}):Play()
	task.wait(0.5)
	clone:Destroy()
end

function GlobalMessageController:_tryRunNext()
	if self.Running >= self.MaxListening then
		return
	end

	local v2 = table.remove(self.Queue, 1)

	if not v2 then
		return
	end

	self.Running += 1
	task.spawn(function()
		local success, result = pcall(function()
			self:DisplayMessage(v2)
		end)

		if not success then
			warn("[GlobalMessage] Error while displaying message:", result)
		end

		self.Running -= 1
		self:_tryRunNext()
	end)
end

function GlobalMessageController:Push(p)
	table.insert(self.Queue, p)
	self:_tryRunNext()
end

function GlobalMessageController:_processBatch(data)
	local duration = data.Duration - (workspace:GetServerTimeNow() - data.Timestamp)

	for _, message in data.Messages do
		self:Push({
			Caller = data.Caller,
			Message = message,
			Duration = duration,
			DoNotDisplayTitle = data.DoNotDisplayTitle
		})
		task.wait(#message / 13)
	end
end

function GlobalMessageController:_tryProcessNextBatch()
	if self.IsProcessing then
		return
	end

	local v2 = table.remove(self.BatchQueue, 1)

	if not v2 then
		return
	end

	self.IsProcessing = true
	task.spawn(function()
		self:_processBatch(v2)
		self.IsProcessing = false
		self:_tryProcessNextBatch()
	end)
end

function GlobalMessageController:EnqueueBatch(p)
	table.insert(self.BatchQueue, p)
	self:_tryProcessNextBatch()
end

return GlobalMessageController