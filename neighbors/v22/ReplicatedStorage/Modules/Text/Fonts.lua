local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Fonts = {}

for _, moduleScript in CollectionService:GetTagged("Fonts") do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local fullName = moduleScript:GetFullName()
	local module = require(moduleScript)

	if type(module) == "table" then
		if next(module) then
			local localPlayer = Players.LocalPlayer
			local fn

			if localPlayer then
				local screenGui = Instance.new("ScreenGui")
				screenGui.Parent = localPlayer.PlayerGui
				local v = 0

				fn = function(p)
					v += 1
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Size = UDim2.fromOffset(1, 1)
					imageLabel.BackgroundTransparency = 1
					imageLabel.ImageTransparency = 0.999
					imageLabel.ResampleMode = Enum.ResamplerMode.Pixelated
					imageLabel.Image = "rbxassetid://" .. tostring(p)
					imageLabel.Parent = screenGui
					coroutine.resume(coroutine.create(function()
						repeat
							task.wait()
						until imageLabel.IsLoaded

						if v == 1 then
							screenGui:Destroy()
						else
							v -= 1
						end
					end))
				end
			else
				fn = nil
			end

			local function handleCharacters(items, p)
				local v = 1 / p

				for k, item in items do
					if not (type(k) == "string" and type(item) == "table" and type(item[1]) == "number") then
						return
					end

					if not (type(item[2]) == "number" and typeof(item[3]) == "Vector2" and type(item[4]) == "number") then
						return
					end

					if not (type(item[5]) == "number" and type(item[6]) == "number") then
						return
					end

					item[4] *= v
					item[5] *= v
					item[6] *= v
				end

				return true
			end

			local v = {}
			local v2 = {}
			local fn2
			local handleCharacters2 = handleCharacters

			local function handleTable(p, module2, fullName2)
				if module2.Image or module2.Size or module2.Characters then
					if type(module2.Image) == "number" then
						if type(module2.Size) == "number" then
							if type(module2.Characters) == "table" then
								if handleCharacters2(module2.Characters, module2.Size) then
									table.insert(v2, p)
									Fonts[module2] = true

									if localPlayer then
										fn(module2.Image)
									end
								else
									warn("Invalid characters in '" .. fullName2 .. "'")
									table.insert(v, p)
								end
							else
								warn("Missing characters in '" .. fullName2 .. "'")
								table.insert(v, p)
							end
						else
							warn("Missing a size in '" .. fullName2 .. "'")
							table.insert(v, p)
						end
					else
						warn("Missing an image ID in '" .. fullName2 .. "'")
						table.insert(v, p)
					end
				else
					fn2(module2, fullName2)
					table.freeze(module2)
				end
			end

			local v6 = v
			local handleTable2 = handleTable
			local v7 = v2

			fn2 = function(list, p)
				for k, item in list do
					if type(item) == "table" then
						handleTable2(k, item, p .. "." .. k)
					else
						table.insert(v6, k)
					end
				end

				for k, v8 in v6 do
					list[v8] = nil
					v6[k] = nil
				end

				for k, v8 in v7 do
					table.freeze(list[v8])
					v7[k] = nil
				end
			end

			handleTable("", module, fullName)

			if #v2 > 0 then
				table.freeze(module)
			end
		else
			warn("'" .. fullName .. "' font data table is empty.")
		end
	else
		warn("'" .. fullName .. "' font data is not a table.")
	end
end

return Fonts