local typeof2 = typeof
require(script.Parent.Parent.TextPlusTypes)
local class = {}
local Defaults = require(script.Parent.Defaults)
class.__index = class
local find = table.find
local remove = table.remove
local clear = table.clear
local Styles = require(script.Styles)
local clamp = math.clamp
local v = {
	Wiggle = 1.8,
	Fade = 1.8,
	Pop = 1.5
}

function updateSingle(p: string, p2, p3: number, p4: number, p5: number, color: Color3, color2: Color3, flag: boolean, p6: number, p7: number, value: number, udim: UDim2, udim2: UDim2, amplitude: number?, data)
	if Styles[p] == nil then
		return true
	end

	local v2

	if flag then
		local v3 = (v[p] or 1.6) * 10
		local v4 = not data and 0 or data.delaytime or 0
		local v5 = os.clock() - p7 - p3 * (p6 - 1)

		if v5 < v4 then
			return nil
		else
			v2 = (v5 - v4) / (p3 * v3 * (data ~= nil and data.stepfactor or value or 1))
		end
	else
		v2 = 1
	end

	local v3 = clamp(v2, 0, 1)
	local v4 = false
	local v5 = false

	if data ~= nil then
		amplitude = data.amplitude or amplitude

		if data.looped or data["repeat"] ~= nil and data["repeat"] < 0 then
			v3 = v2 % 1

			if data.reverse and math.floor(v2) % 2 == 1 then
				v3 = 1 - v3
				v5 = true
			else
				v5 = false
			end
		elseif data["repeat"] == nil then
			if data.reverse then
				if v2 <= 1 then
					local v6 = v2 * 2
					v3 = v6 > 1 and 1 or v6
					v5 = false
				elseif v2 <= 2 then
					v3 = 2 - v2
					v5 = true
				else
					v4 = true
				end
			end
		else
			local v6 = math.floor(v2)
			local v7 = v2 % 1

			if data.reverse then
				local v8 = data["repeat"] * 2
				local v9 = math.floor(v2 * 2)

				if v8 <= v9 then
					v4 = true
				else
					v3 = v2 * 2 % 1

					if v9 % 2 == 1 then
						v3 = 1 - v3
						v5 = true
					else
						v5 = false
					end
				end
			elseif data["repeat"] <= v6 then
				v4 = true
			else
				v3 = v7
				v5 = false
			end
		end
	end

	local v6 = Styles[p](p2, v3, p4, p5, color, color2, udim, udim2, amplitude, v5)

	if v4 or v6 == true or (data == nil or data["repeat"] == nil and data.looped == nil and data.reverse == nil) and v3 >= 1 then
		return true
	end

	return nil
end

function class:Destroy()
	local index = find(self.__Content.Animations, self)

	if index ~= nil then
		if self.__Content.CurrentAnimation == self then
			self.__Content.CurrentAnimation = nil
		end

		remove(self.__Content.Animations, index)
		self.__Content = nil
	end

	for i = self.Index, 1, -1 do
		self.Letters[i] = nil
	end

	self.Letters = nil

	if self.DefaultSize then
		clear(self.DefaultSize)
		self.DefaultSize = nil
	end

	if self.Indexes then
		clear(self.Indexes)
		self.Indexes = nil
	end

	if self.StylesCount ~= nil then
		for i = #self.StylesCount, 1, -1 do
			clear(self.StylesCount[i])
			self.StylesCount[i] = nil
		end

		clear(self.StylesCount)
		self.StylesCount = nil
	end

	self.nativeStyleCount = nil

	if self.DefaultPosition then
		clear(self.DefaultPosition)
		self.DefaultPosition = nil
	end

	if self.Settings ~= nil then
		clear(self.Settings)
		self.Settings = nil
	end

	self.Word.TextColor3 = self.color
	self.Amplitude = nil
	self.HasUpdate = nil
	self.Index = nil
	self.Progress = nil
	self.Started = nil
	self.StepFactor = nil
	self.Word = nil
	self.WordLength = nil
	self.color = nil
	self.step = nil
	self.transparency = nil
	self.StrokeTransparency = nil
	self.Style = nil
	self.StyleIsTable = nil
	setmetatable(self, nil)
	clear(self)
end

function class:Update()
	for i = 1, #self.Indexes do
		local index = self.Indexes[i]

		if not (index ~= nil and index ~= false) then
			continue
		end

		if self.StyleIsTable then
			for i2 = self.StylesCount[index].Count, 1, -1 do
				if typeof2(self.StylesCount[index].Styles[i2]) == "table" then
					if updateSingle(
						self.StylesCount[index].Styles[i2].style,
						index,
						self.step,
						self.transparency,
						self.stroketransparency,
						self.color,
						self.strokecolor,
						self.HasUpdate,
						i,
						self.Started,
						self.StepFactor,
						self.DefaultSize[i],
						self.DefaultPosition[i],
						self.Amplitude,
						self.StylesCount[index].Styles[i2]
					) then
						self.StylesCount[index].Count -= 1
						table.remove(self.StylesCount[index].Styles, i2)
					end
				elseif updateSingle(
					self.StylesCount[index].Styles[i2],
					index,
					self.step,
					self.transparency,
					self.stroketransparency,
					self.color,
					self.strokecolor,
					self.HasUpdate,
					i,
					self.Started,
					self.StepFactor,
					self.DefaultSize[i],
					self.DefaultPosition[i],
					self.Amplitude
				) then
					self.StylesCount[index].Count -= 1
					table.remove(self.StylesCount[index].Styles, i2)
				end

				if not (self.StylesCount[index] == nil or self.StylesCount[index].Count <= 0) then
					continue
				end

				self.Indexes[i] = false
				self.Progress += 1
				break
			end
		elseif updateSingle(
			self.Style,
			index,
			self.step,
			self.transparency,
			self.stroketransparency,
			self.color,
			self.strokecolor,
			self.HasUpdate,
			i,
			self.Started,
			self.StepFactor,
			self.DefaultSize[i],
			self.DefaultPosition[i],
			self.Amplitude
		) then
			self.Indexes[i] = false
			self.Progress += 1
		end

		if not (self.Progress >= self.WordLength) then
			continue
		end

		self:Destroy()
		break
	end
end

function class:AddLetter(p)
	self.Index += 1

	if self.HasUpdate then
		self.DefaultSize[self.Index] = p.Size
		self.DefaultPosition[self.Index] = p.Position
		self.Indexes[self.Index] = p
	end

	self.Letters[self.Index] = p

	if self.StyleIsTable then
		if self.StylesCount[p] == nil then
			self.StylesCount[p] = {
				Count = self.nativeStyleCount,
				Styles = {}
			}

			for i = self.nativeStyleCount, 1, -1 do
				self.StylesCount[p].Styles[i] = self.Style[i]
			end
		end

		for i = self.StylesCount[p].Count, 1, -1 do
			if typeof2(self.Style[i]) == "table" then
				if updateSingle(
					self.StylesCount[p].Styles[i].style,
					p,
					self.step,
					self.transparency,
					self.stroketransparency,
					self.color,
					self.strokecolor,
					self.HasUpdate,
					self.Index,
					self.Started,
					self.StepFactor,
					self.DefaultSize[self.Index],
					self.DefaultPosition[self.Index],
					self.Amplitude or 1,
					self.StylesCount[p].Styles[i]
				) then
					self.StylesCount[p].Count -= 1
					table.remove(self.StylesCount[p].Styles, i)
				end
			elseif updateSingle(
				self.StylesCount[p].Styles[i],
				p,
				self.step,
				self.transparency,
				self.stroketransparency,
				self.color,
				self.strokecolor,
				self.HasUpdate,
				self.Index,
				self.Started,
				self.StepFactor,
				self.DefaultSize[self.Index],
				self.DefaultPosition[self.Index],
				self.Amplitude or 1
			) then
				self.StylesCount[p].Count -= 1
				table.remove(self.StylesCount[p].Styles, i)
			end

			if not (self.StylesCount[p] == nil or self.StylesCount[p].Count < 0) then
				continue
			end

			self.StylesCount[p] = nil

			if self.HasUpdate then
				self.Indexes[self.Index] = false
			end

			self.Progress += 1
			break
		end
	elseif updateSingle(
		self.Style,
		p,
		self.step,
		self.transparency,
		self.stroketransparency,
		self.color,
		self.strokecolor,
		self.HasUpdate,
		self.Index,
		self.Started,
		self.StepFactor,
		p.Size,
		p.Position,
		self.Amplitude or 1
	) then
		if self.HasUpdate then
			self.Indexes[self.Index] = false
		end

		self.Progress += 1
	end

	if self.Progress >= self.WordLength then
		self:Destroy()
	end
end

return function(content, word, data, data2)
	local v2 = {
		__Content = content,
		Word = word,
		WordLength = (utf8.len(word.Text) or #word.Text) / (content.Chunks or content.Settings.Chunks or 1),
		Index = 0,
		Progress = 0,
		Style = data ~= nil and data.style or data2.Style or data2.style,
		Started = os.clock()
	}
	v2.StyleIsTable = typeof2(v2.Style) == "table"

	if v2.StyleIsTable then
		for _, v3 in ipairs(v2.Style) do
			if typeof2(v3) ~= "table" then
				continue
			end

			for k, v4 in pairs(v3) do
				v3[k] = nil
				v3[string.lower(k)] = v4
			end
		end

		v2.nativeStyleCount = #v2.Style
		v2.StylesCount = {}
	else
		v2.Style = Styles[v2.Style] == nil and "Default" or v2.Style or "Default"
	end

	v2.HasUpdate = v2.Style ~= nil and v2.Style ~= "Default"
	v2.Letters = {}

	if v2.HasUpdate then
		v2.Indexes = {}
		v2.DefaultSize = {}
		v2.DefaultPosition = {}
	end

	v2.Amplitude = data ~= nil and data.amplitude or data2.Amplitude or Defaults.Amplitude
	v2.StepFactor = data ~= nil and data.stepfactor or data2.StepFactor or Defaults.StepFactor
	v2.step = data ~= nil and data.step or data2.Step or Defaults.Step
	v2.transparency = data ~= nil and data.transparency or data2.Transparency or Defaults.Transparency
	v2.stroketransparency = data ~= nil and data.stroketransparency or data2.StrokeTransparency or Defaults.StrokeTransparency
	v2.color = data ~= nil and data.color or data2.Color or Defaults.Color
	v2.strokecolor = data ~= nil and data.strokecolor or data2.StrokeColor or Defaults.StrokeColor
	return (setmetatable(v2, class))
end