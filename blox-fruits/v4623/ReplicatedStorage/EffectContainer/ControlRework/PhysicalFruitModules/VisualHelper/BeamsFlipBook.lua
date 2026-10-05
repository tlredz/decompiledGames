local Bezier = require(script.Bezier)
local Trove = require(script.Trove)
local BeamsFlipBook = {}
BeamsFlipBook.__index = BeamsFlipBook

function BeamsFlipBook.new(value: number?, value2: number?, flag: boolean?, texture: string?)
	return (setmetatable({
		Beams = {},
		Frames = value or 16,
		Fps = value2 or 24,
		Looped = flag or false,
		Texture = texture
	}, BeamsFlipBook))
end

function BeamsFlipBook.Insert(data, instance)
	if not (instance.Attachment0 and instance.Attachment1) then
		return warn("The beam needs to have both attachments set!")
	end

	local wrap = Enum.TextureMode.Wrap
	local texture = data.Texture or instance.Texture
	instance.TextureSpeed = 0
	instance.TextureMode = wrap
	instance.Texture = texture

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateLength()
		instance.TextureLength = Bezier:GetBeamTotalTextureLength(instance) * data.Frames
	end

	local maid = Trove.new()

	for i = 0, 1 do
		maid:Add(instance:GetPropertyChangedSignal((`CurveSize{i}`)):Connect(UpdateLength))
		maid:Add(instance[`Attachment{i}`]:GetPropertyChangedSignal("CFrame"):Connect(UpdateLength))
	end

	UpdateLength() -- equivalent call inferred; original call site unknown
	data.Beams[instance] = maid
	return data
end

function BeamsFlipBook.Remove(p, p2)
	local beam = p.Beams[p2]

	if beam then
		beam:Destroy()
	end

	p.Beams[p2] = nil
	return p
end

function BeamsFlipBook:Play()
	self:Stop()
	self:UnFreeze()
	self.PlayingThread = task.spawn(function()
		repeat
			for i = 0, self.Frames do
				if self.Freezed then
					coroutine.yield()
				end

				local v = i / self.Frames
				local v2 = v == 1

				for k in self:GetBeams() do
					k.Enabled = not v2
					k:SetTextureOffset(v)
				end

				task.wait(1 / self.Fps)
			end
		until not self.Looped
	end)
end

function BeamsFlipBook:Stop()
	if not self:IsPlaying() then
		return
	end

	task.cancel(self.PlayingThread)
end

function BeamsFlipBook:IsPlaying()
	return typeof(self.PlayingThread) == "thread" and coroutine.status(self.PlayingThread) ~= "dead"
end

function BeamsFlipBook:Freeze()
	self.Freezed = true
end

function BeamsFlipBook:UnFreeze()
	if self.Freezed and self:IsPlaying() and coroutine.status(self.PlayingThread) == "suspended" then
		coroutine.resume(self.PlayingThread)
	end

	self.Freezed = nil
end

function BeamsFlipBook:GetBeams()
	return self.Beams
end

function BeamsFlipBook:ToggleBeams(enabled: boolean)
	for k in self:GetBeams() do
		k.Enabled = enabled
	end
end

function BeamsFlipBook:Destroy()
	self:Stop()

	for _, v in self:GetBeams() do
		v:Destroy()
	end

	table.clear(self)
end

return BeamsFlipBook