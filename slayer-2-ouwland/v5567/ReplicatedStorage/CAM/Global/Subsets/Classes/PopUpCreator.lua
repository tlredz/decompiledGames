local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local simplesignal2 = require(ReplicatedStorage.Packages.simplesignal)
local class = {}
class.__index = class
local count = 0
local PopUpCreator = {
	signal = simplesignal2.new()
}

function class:Destroy()
	if self.Result ~= nil then
		self.Result:Destroy()
	end

	PopUpCreator.signal:Fire(self.id)
end

function class.WaitResult(p, flag: boolean?)
	if p.Result == nil then
		return nil
	end

	if not flag then
		return p.Result:Wait()
	end

	local v = nil
	local v2 = false
	local resultConnection = p.Result:Connect(function(p2)
		v = p2
		v2 = true
	end)

	while not v2 do
		task.wait()
	end

	resultConnection:Disconnect()
	return v
end

local function resolveDefault(p)
	if p.Default ~= nil then
		return p.Default
	end

	local content = p.Content

	if type(content) ~= "table" or content.Options == nil then
		return "No"
	end

	local options = content.Options
	local option = options[#options]

	if type(option) == "table" then
		return option.Text
	end

	return option
end

local v = {}

function PopUpCreator.new(p)
	local v2 = p or v
	local object = setmetatable({
		id = count
	}, class)
	count += 1

	if v2.Type == "Question" or v2.Type == "CenterBottomQuestion" then
		object.Result = simplesignal.new()
	end

	PopUpCreator.signal:Fire(object.id, v2, object.Result)

	if object.Result ~= nil then
		local resultConnection = nil
		local thread = task.delay(v2.Timout or 5, function()
			if resultConnection then
				resultConnection:Disconnect()
			end

			local result = object.Result
			local v3 = v2
			local text

			if v3.Default == nil then
				local content = v3.Content

				if type(content) == "table" and content.Options ~= nil then
					local options = content.Options
					text = options[#options]

					if type(text) == "table" then
						text = text.Text
					end
				else
					text = "No"
				end
			else
				text = v3.Default
			end

			result:Fire(text)
			PopUpCreator.signal:Fire(object.id)
		end)
		resultConnection = object.Result:Once(function()
			task.cancel(thread)
		end)
	end

	return object
end

return PopUpCreator