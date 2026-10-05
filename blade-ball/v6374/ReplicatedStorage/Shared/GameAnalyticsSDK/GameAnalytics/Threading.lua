local Threading = {
	_canSafelyClose = true,
	_endThread = false,
	_isRunning = false,
	_blocks = {},
	_scheduledBlock = nil,
	_hasScheduledBlockRun = true
}
local Logger = require(script.Parent.Logger)
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function getScheduledBlock()
	local now = tick()

	if Threading._hasScheduledBlockRun or Threading._scheduledBlock == nil or not (Threading._scheduledBlock.deadline <= now) then
		return nil
	end

	Threading._hasScheduledBlockRun = true
	return Threading._scheduledBlock
end

local function run()
	task.spawn(function()
		Logger:d("Starting GA thread")

		while not Threading._endThread do
			Threading._canSafelyClose = false

			if #Threading._blocks ~= 0 then
				for _, _block in pairs(Threading._blocks) do
					local success, result = pcall(_block.block)

					if not success then
						Logger:e(result)
					end
				end

				Threading._blocks = {}
			end

			local scheduledBlock = getScheduledBlock() -- equivalent call inferred; original call site unknown

			if scheduledBlock ~= nil then
				local success, result = pcall(scheduledBlock.block)

				if not success then
					Logger:e(result)
				end
			end

			Threading._canSafelyClose = true
			task.wait(1)
		end

		Logger:d("GA thread stopped")
	end)
	game:BindToClose(function()
		if RunService:IsStudio() then
			return
		end

		task.wait(1)

		if not Threading._canSafelyClose then
			repeat
				task.wait()
			until Threading._canSafelyClose
		end

		task.wait(3)
	end)
end

function Threading:scheduleTimer(p, block)
	if self._endThread then
		return
	end

	if not self._isRunning then
		self._isRunning = true
		run()
	end

	local scheduledBlock = {
		block = block,
		deadline = tick() + p
	}

	if self._hasScheduledBlockRun then
		self._scheduledBlock = scheduledBlock
		self._hasScheduledBlockRun = false
	end
end

function Threading:performTaskOnGAThread(block)
	if self._endThread then
		return
	end

	if not self._isRunning then
		self._isRunning = true
		run()
	end

	self._blocks[#self._blocks + 1] = {
		block = block
	}
end

function Threading:stopThread()
	self._endThread = true
end

return Threading