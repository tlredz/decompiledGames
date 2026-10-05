local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LoadingProgress = {}
LoadingProgress.__index = LoadingProgress

function LoadingProgress.new(gui, config)
	local object = setmetatable({
		gui = gui,
		config = config,
		elapsed = 0,
		finishing = false,
		alive = true
	}, LoadingProgress)
	object.fill = gui.Loading.Track.Fill
	object.shine = object.fill:FindFirstChild("Shine")
	object.fill.Size = UDim2.fromScale(0, 1)
	gui.Loading.Status.Text = "Ready for the chase?"
	object.connection = RunService.RenderStepped:Connect(function(dt)
		object.elapsed += dt

		if not object.finishing then
			local v2 = (1 - math.exp(-2.6 * object.elapsed / math.max(config.MinimumLoadingTime, 1))) * 0.97
			object.fill.Size = UDim2.fromScale(v2, 1)
		end

		if object.shine then
			object.shine.Offset = Vector2.new(object.elapsed % 2 / 2 * 2 - 1, 0)
		end
	end)
	return object
end

function LoadingProgress:complete()
	if not self.alive or self.finishing then
		return false
	end

	self.finishing = true
	self.tween = TweenService:Create(
		self.fill,
		TweenInfo.new(self.config.LoadingFinishTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Size = UDim2.fromScale(1, 1)
		}
	)
	local v = false
	local completedConnection = self.tween.Completed:Connect(function()
		v = true
	end)
	self.tween:Play()
	local v2 = os.clock() + self.config.LoadingFinishTime + 1

	while self.alive and not v and os.clock() < v2 do
		task.wait()
	end

	completedConnection:Disconnect()

	if not self.alive then
		return false
	end

	if not v then
		self.tween:Cancel()
	end

	self.fill.Size = UDim2.fromScale(1, 1)
	self.gui:SetAttribute("LoadingProgressFinishedAt", workspace:GetServerTimeNow())
	task.wait(self.config.LoadingFinishHold)
	return self.alive
end

function LoadingProgress:destroy()
	self.alive = false

	if self.connection then
		self.connection:Disconnect()
	end

	if self.tween then
		self.tween:Cancel()
	end
end

return LoadingProgress