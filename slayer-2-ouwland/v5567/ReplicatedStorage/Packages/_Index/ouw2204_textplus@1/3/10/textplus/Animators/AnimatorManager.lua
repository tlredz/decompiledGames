local class = {}
class.__index = class
require(script.Parent.Parent.TextPlusTypes)
local Defaults = require(script.Parent.Defaults)
local AnimatorClass = require(script.Parent.AnimatorClass)
local TextPlusUtility = require(script.Parent.Parent.TextPlusUtility)
local insert = table.insert
local sub = string.sub
local min = math.min

-- equivalent calls inferred from this helper; original call sites unknown
local function utf8len(list: string)
	return utf8.len(list) or #list
end

-- equivalent calls inferred from this helper; original call sites unknown
local function utf8sub(word: string, p: number, p2: number)
	local v = utf8.offset(word, p)
	local v2 = utf8.offset(word, p2 + 1)

	if v == nil then
		return ""
	end

	if not v2 then
		return (sub(word, v))
	end

	return (sub(word, v, v2 - 1))
end

local typeof2 = typeof
local left = Enum.TextXAlignment.Left
local top = Enum.TextYAlignment.Top
local tostring2 = tostring
local fromScale = UDim2.fromScale
local fromOffset = UDim2.fromOffset

function Terminate(instance)
	instance.__Broke = true

	if instance.Animations == nil or #instance.Animations == 0 then
		instance:Destroy()
	else
		instance.__DeleteWhenDone = true
	end
end

local Styles = require(script.Parent.Parent.Animators.AnimatorClass.Styles)
local uDim = UDim2.fromScale(1, 1)
return function(instance, timer: number, point: Vector2, flag: boolean)
	if instance.LastRunSuccessful == false and instance.__Broke == nil or instance == nil or instance.Container == nil or instance.Container.Parent == nil then
		instance:Destroy()
		return
	end

	instance.LastRunSuccessful = false

	if (instance.Timer == nil or instance.Timer + timer > (instance.CurrentStep or instance.Settings.Step or Defaults.Step) / (instance.CurrentSpeed or instance.Settings.Speed or Defaults.Speed)) and instance.__Broke == nil then
		if instance.Sequence[instance.CurrentIndex] == nil then
			Terminate(instance)
			return
		end

		local flag2 = false
		local flag3 = false
		local flag4 = false
		local flag5 = false

		if instance.List == nil then
			local text = instance.Sequence[instance.CurrentIndex]

			if typeof2(text) == "table" then
				if text.Params then
					instance.CurrentSize = text.Params.size
					instance.Params = text.Params
					instance.CurrentStep = text.Params.step
					instance.Chunks = text.Params.chunks
					instance.CurrentScale = text.Params.scale
					instance.CurrentColor = text.Params.color
					instance.CurrentTransparency = text.Params.transparency
					instance.CurrentSpeed = text.Params.speed
					instance.CurrentAmplitude = text.Params.amplitude
					instance.CurrentFontFace = text.Params.fontface
					instance.CurrentFont = text.Params.font
					instance.CurrentStrokeColor = text.Params.strokecolor
					instance.CurrentStrokeTransparency = text.Params.stroketransparency
				end

				text = text.Text
			end

			local splitWordsAndSpaces, count2 = TextPlusUtility.splitWordsAndSpaces(text)
			instance.List = splitWordsAndSpaces
			instance.Count = count2
		end

		local textSizeInit = instance.TextSizeInit

		if textSizeInit == nil then
			textSizeInit = instance.CurrentSize or instance.Settings.Size

			if instance.Settings.Scaled then
				textSizeInit = min(min(point.Y, 100) * (instance.CurrentScale or instance.Settings.Scale or 1), 100)
			end
		end

		if instance.Count == nil or instance.Count == 0 then
			if instance.CurrentIndex >= instance.SequenceCount then
				Terminate(instance)
				return
			end

			flag2 = true

			if instance.List ~= nil then
				table.clear(instance.List)
			end

			instance.Count = nil
			instance.List = nil
		elseif instance.CurrentIndexPosition > instance.Count then
			flag2 = true
			instance.CurrentIndexPosition = 1
			instance.Count = nil

			if instance.List ~= nil then
				table.clear(instance.List)
			end

			instance.List = nil
		elseif instance.List == nil then
			flag3 = true
		else
			if instance.Word == nil then
				flag5 = true
				instance.Word = instance.List[instance.CurrentIndexPosition]
				instance.WordLength = utf8len(instance.Word)

				if instance.Params ~= nil then
					local imageLabel, uDim2, word2, wordLength, v, wordLength2, v2, v3, word, v5, idValue, word3, chunks, wordLength3

					if instance.Word == "#" then
						if instance.Word == "#" and instance.Params then
							if instance.Params.img ~= nil then
								imageLabel = Instance.new("ImageLabel")
								imageLabel.AutoLocalize = false
								imageLabel.Name = "img - " .. instance.Params.img

								if instance.Settings.Scaled and flag then
									uDim2 = fromScale(textSizeInit / point.X, textSizeInit / point.Y)
								else
									uDim2 = fromOffset(textSizeInit, textSizeInit)
								end

								imageLabel.Size = uDim2
								imageLabel.Parent = instance.Container
								imageLabel.BackgroundTransparency = 1
								imageLabel.Image = "rbxassetid://" .. instance.Params.img
								instance.Word = nil
								flag5 = false
								flag3 = true
							end
						else
							word2 = instance.Word
							wordLength = instance.WordLength
							v = min(2, wordLength)
							wordLength2 = instance.WordLength
							v2 = utf8.offset(word2, v)
							v3 = utf8.offset(word2, wordLength2 + 1)

							if v2 == nil then
								word = ""
							elseif v3 then
								v5 = v3 - 1
								word = sub(word2, v2, v5)
							else
								word = sub(word2, v2)
							end

							if word ~= nil then
								idValue = instance:GetIdValue(word)

								if idValue ~= nil then
									word = tostring2(idValue) or word
								end

								instance.Word = word
								word3 = instance.Word
								instance.WordLength = utf8len(word3)
								chunks = instance.Chunks or instance.Settings.Chunks or 1
								wordLength3 = instance.WordLength
								instance.CurrentCharacterPosition = min(chunks, wordLength3)
								instance.PrevCharacterPosition = nil
							end
						end
					else
						local word4 = instance.Word
						local v6 = utf8.offset(word4, 1)
						local v7 = utf8.offset(word4, 2)
						local v8

						if v6 == nil then
							v8 = ""
						elseif v7 then
							v8 = sub(word4, v6, v7 - 1)
						else
							v8 = sub(word4, v6)
						end

						if v8 == "#" then
							if instance.Word == "#" and instance.Params then
								if instance.Params.img ~= nil then
									imageLabel = Instance.new("ImageLabel")
									imageLabel.AutoLocalize = false
									imageLabel.Name = "img - " .. instance.Params.img

									if instance.Settings.Scaled and flag then
										uDim2 = fromScale(textSizeInit / point.X, textSizeInit / point.Y)
									else
										uDim2 = fromOffset(textSizeInit, textSizeInit)
									end

									imageLabel.Size = uDim2
									imageLabel.Parent = instance.Container
									imageLabel.BackgroundTransparency = 1
									imageLabel.Image = "rbxassetid://" .. instance.Params.img
									instance.Word = nil
									flag5 = false
									flag3 = true
								end
							else
								word2 = instance.Word
								wordLength = instance.WordLength
								v = min(2, wordLength)
								wordLength2 = instance.WordLength
								v2 = utf8.offset(word2, v)
								v3 = utf8.offset(word2, wordLength2 + 1)

								if v2 == nil then
									word = ""
								elseif v3 then
									v5 = v3 - 1
									word = sub(word2, v2, v5)
								else
									word = sub(word2, v2)
								end

								if word ~= nil then
									idValue = instance:GetIdValue(word)

									if idValue ~= nil then
										word = tostring2(idValue) or word
									end

									instance.Word = word
									word3 = instance.Word
									instance.WordLength = utf8len(word3)
									chunks = instance.Chunks or instance.Settings.Chunks or 1
									wordLength3 = instance.WordLength
									instance.CurrentCharacterPosition = min(chunks, wordLength3)
									instance.PrevCharacterPosition = nil
								end
							end
						end
					end
				end

				if flag5 then
					local chunks = instance.Chunks or instance.Settings.Chunks or 1
					instance.CurrentCharacterPosition = min(chunks, instance.WordLength)
					instance.PrevCharX = 0
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = instance.Word
					textLabel.AutoLocalize = false
					textLabel.Parent = instance.Container
					textLabel.TextTransparency = 1
					textLabel.TextSize = textSizeInit
					textLabel.Text = instance.Word
					textLabel.TextXAlignment = instance.Settings.XAlignment or left
					textLabel.TextYAlignment = instance.Settings.YAlignment or top
					textLabel.BackgroundTransparency = 1

					if instance.Settings.FontFace == nil and instance.CurrentFontFace == nil then
						textLabel.Font = instance.CurrentFont or instance.Settings.Font or Enum.Font.SourceSans
					else
						textLabel.FontFace = instance.CurrentFontFace or instance.Settings.FontFace
					end

					textLabel.TextColor3 = instance.Settings.Color or Color3.new(1, 1, 1)
					local Xs = table.create(instance.WordLength)

					for i = 1, instance.WordLength do
						local text = utf8sub(instance.Word, 1, i) -- equivalent call inferred; original call site unknown
						textLabel.Text = text
						Xs[i] = textLabel.TextBounds.X
					end

					textLabel.Text = instance.Word
					instance.CharWidths = Xs
					local textBounds = textLabel.TextBounds

					if instance.Settings.Scaled and flag then
						textLabel.Size = fromScale(textBounds.X / point.X, textBounds.Y / point.Y)
						textLabel.TextScaled = true
					else
						textLabel.Size = fromOffset(textBounds.X, textBounds.Y)
					end

					instance.WordInstance = textLabel
					local absoluteContentSize = instance.ListObject.AbsoluteContentSize

					if instance.Settings.Overfill or not (absoluteContentSize.Y > point.Y) then
						if instance.Settings.WordStepped ~= nil then
							instance.Settings.WordStepped(instance, instance.Word)
						end

						if string.match(instance.Word, "%s+") == instance.Word then
							instance.Word = nil
							instance.CurrentAnimation = nil
							flag3 = true
						else
							local currentAnimation = AnimatorClass(
								instance,
								instance.WordInstance,
								instance.Params or nil,
								instance.Settings
							)
							insert(instance.Animations, currentAnimation)
							instance.CurrentAnimation = currentAnimation
						end
					else
						textLabel.Parent = nil
						textLabel:Destroy()
						instance.Word = nil
						Terminate(instance)
						instance.CurrentAnimation = nil
						return
					end
				end
			end

			if instance.Word ~= nil then
				if instance.CurrentCharacterPosition > instance.WordLength then
					instance.CharWidths = nil
					instance.Word = nil
					instance.WordLength = nil
					instance.CurrentCharTxt = nil
					instance.CurrentCharacterPosition = nil
					instance.PrevCharacterPosition = nil
					instance.CurrentAnimation = nil
					flag3 = true
				else
					flag4 = true
					local v2 = utf8sub(
						instance.Word,
						(instance.PrevCharacterPosition or 0) + 1,
						instance.CurrentCharacterPosition
					) -- equivalent call inferred; original call site unknown
					local textLabel = Instance.new("TextLabel")
					textLabel.AutoLocalize = false

					if instance.Settings.LetterStepped ~= nil then
						instance.Settings.LetterStepped(instance, v2, instance.Word)
					end

					textLabel.Name = v2
					textLabel.Size = fromScale(15, 1)
					textLabel.TextTransparency = 1
					local currentColor = instance.CurrentColor or instance.Settings.Color or Defaults.Color
					local currentTransparency = instance.CurrentTransparency or instance.Settings.Transparency or Defaults.Transparency
					local currentStrokeTransparency = instance.CurrentStrokeTransparency or instance.Settings.StrokeTransparency or Defaults.StrokeTransparency
					local currentStrokeColor = instance.CurrentStrokeColor or instance.Settings.StrokeColor or Defaults.StrokeColor
					textLabel.TextTransparency = currentTransparency

					if instance.CurrentAnimation ~= nil then
						if instance.CurrentAnimation.StyleIsTable then
							for _, v3 in ipairs(instance.CurrentAnimation.Style) do
								if typeof2(v3) == "table" then
									Styles[v3.style](
										textLabel,
										0,
										currentTransparency,
										currentStrokeTransparency,
										currentColor,
										currentStrokeColor,
										uDim,
										uDim,
										1,
										false
									)
								else
									Styles[v3](
										textLabel,
										0,
										currentTransparency,
										currentStrokeTransparency,
										currentColor,
										currentStrokeColor,
										uDim,
										uDim,
										1,
										false
									)
								end
							end
						else
							Styles[instance.CurrentAnimation.Style](
								textLabel,
								0,
								currentTransparency,
								currentStrokeTransparency,
								currentColor,
								currentStrokeColor,
								uDim,
								uDim,
								1,
								false
							)
						end
					end

					textLabel.Parent = instance.WordInstance
					textLabel.TextSize = textSizeInit
					textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					textLabel.TextXAlignment = Enum.TextXAlignment.Left
					textLabel.TextYAlignment = Enum.TextYAlignment.Center
					textLabel.BackgroundTransparency = 1

					if instance.Settings.FontFace == nil and instance.CurrentFontFace == nil then
						textLabel.Font = instance.CurrentFont or instance.Settings.Font or Enum.Font.SourceSans
					else
						textLabel.FontFace = instance.CurrentFontFace or instance.Settings.FontFace
					end

					textLabel.Text = v2
					local v3 = instance.CharWidths and instance.CharWidths[instance.CurrentCharacterPosition]
					local v4 = instance.CharWidths and instance.CharWidths[instance.WordLength]
					local X = textLabel.TextBounds.X
					local X2 = instance.WordInstance.AbsoluteSize.X
					local prevCharX

					if v3 == nil or v4 == nil or not (v4 > 0) then
						prevCharX = instance.PrevCharX + X / X2
					else
						prevCharX = v3 / v4
						X2 = v4
					end

					local v6 = prevCharX - instance.PrevCharX

					if X2 > 0 then
						v6 = math.max(v6, X / X2)
					end

					textLabel.Position = fromScale(instance.PrevCharX + v6 / 2, 0.5)
					instance.PrevCharX = prevCharX
					textLabel.TextScaled = true
					textLabel.TextColor3 = currentColor
					textLabel.TextStrokeColor3 = currentStrokeColor
					textLabel.TextStrokeTransparency = currentStrokeTransparency
					textLabel.Size = fromScale(v6, 1)

					if instance.CurrentAnimation ~= nil then
						instance.CurrentAnimation:AddLetter(textLabel)
					end
				end
			end
		end

		if not (flag2 or flag3 or flag4 or flag5) then
			Terminate(instance)
			return
		end

		if flag2 then
			instance.CurrentIndex = (instance.CurrentIndex or 1) + 1
			local v = instance.Sequence[instance.CurrentIndex]

			if v == nil or v.Params == nil then
				instance.CurrentStrokeColor = nil
				instance.CurrentStrokeTransparency = nil
				instance.CurrentSize = nil
				instance.CurrentFont = nil
				instance.CurrentAmplitude = nil
				instance.Params = nil
				instance.CurrentAmplitude = nil
				instance.CurrentSpeed = nil
				instance.CurrentTransparency = nil
				instance.CurrentColor = nil
				instance.CurrentScale = nil
				instance.Chunks = nil
				instance.CurrentStep = nil
			elseif typeof2(v.Params) == "table" then
				instance.CurrentStep = v.Params.step
				instance.Chunks = v.Params.chunks
				instance.CurrentScale = v.Params.scale
				instance.CurrentColor = v.Params.color
				instance.CurrentTransparency = v.Params.transparency
				instance.CurrentSpeed = v.Params.speed
				instance.CurrentAmplitude = v.Params.amplitude
				instance.CurrentFontFace = v.Params.fontface
				instance.CurrentFont = v.Params.font
				instance.CurrentSize = v.Params.size
				instance.Params = v.Params
				instance.CurrentStrokeColor = v.Params.strokecolor
				instance.CurrentStrokeTransparency = v.Params.stroketransparency
			else
				instance.CurrentStrokeColor = nil
				instance.CurrentStrokeTransparency = nil
				instance.CurrentSize = nil
				instance.CurrentFont = nil
				instance.CurrentAmplitude = nil
				instance.Params = nil
				instance.CurrentAmplitude = nil
				instance.CurrentSpeed = nil
				instance.CurrentTransparency = nil
				instance.CurrentColor = nil
				instance.CurrentScale = nil
				instance.Chunks = nil
				instance.CurrentStep = nil
			end
		elseif flag3 then
			instance.CurrentIndexPosition = (instance.CurrentIndexPosition or 1) + 1
		elseif flag4 then
			local chunks = instance.Chunks or instance.Settings.Chunks or 1
			instance.PrevCharacterPosition = instance.CurrentCharacterPosition

			if instance.CurrentCharacterPosition < instance.WordLength and instance.CurrentCharacterPosition + chunks > instance.WordLength then
				instance.CurrentCharacterPosition = instance.WordLength
			else
				instance.CurrentCharacterPosition += chunks
			end
		end

		instance.Timer = 0
	else
		if instance.Timer then
			timer = instance.Timer + timer or timer
		end

		instance.Timer = timer
	end

	local count = #instance.Animations

	if count > 0 then
		for i = 1, count do
			local animation = instance.Animations[i]

			if animation ~= nil and animation.HasUpdate then
				animation:Update()
			end
		end
	else
		if instance.Settings ~= nil and instance.Settings.OnFinished ~= nil then
			instance.Settings.OnFinished(instance)
		end

		if instance.__DeleteWhenDone then
			instance:Destroy()
		end
	end

	instance.LastRunSuccessful = true
end