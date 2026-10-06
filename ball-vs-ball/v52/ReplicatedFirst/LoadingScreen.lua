print((`[{script}] 加载页运行中`))
local TweenService = game:GetService("TweenService")
local playerGui = game.Players.LocalPlayer.PlayerGui
local v = script["加载界面"]
v.Parent = playerGui
local v2 = v["背景"]
v2.Active = true
v2.InputSink = Enum.InputSink.All
local v3 = v["背景"]["进度数值"]
v3.Visible = false

local function fadeOut(folder)
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, descendant in ipairs(folder:GetDescendants()) do
		local v4

		if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			v4 = {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			v4 = {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		elseif descendant:IsA("GuiObject") then
			v4 = {
				BackgroundTransparency = 1
			}
		elseif descendant:IsA("UIStroke") then
			v4 = {
				Transparency = 1
			}
		else
			v4 = nil
		end

		if v4 then
			TweenService:Create(descendant, tweenInfo, v4):Play()
		end
	end

	task.wait(tweenInfo.Time)
end

local LoadingBattleAnimation = require(script.LoadingBattleAnimation)
local v4 = LoadingBattleAnimation.start(v2["对战区域"])
local LoadingAnimation = require(script.LoadingAnimation)
LoadingAnimation.start(v["背景"]["加载中文本"], v3, v["背景"]["进度条"].UIGradient)
local v5 = {
	Sound = "SoundId",
	ParticleEmitter = "Texture",
	Animation = "AnimationId",
	ImageLabel = "Image",
	Decal = "Texture",
	Beam = "Texture",
	Trail = "Texture"
}
local v6 = {
	["音效素材"] = true
}
local v7 = {
	ImageLabel = true,
	Decal = true
}

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local v8 = {}
local v9 = {}

local function normalizeContentId(value: string)
	local v10 = value:match("^%s*(.-)%s*$") or ""

	if v10 == "" or v10 == "x" then
		return nil
	end

	if v10:match("^%d+$") then
		return "rbxassetid://" .. v10
	end

	return v10
end

local function addContent(list, value, callback)
	if typeof(value) ~= "string" then
		return false
	end

	local v10 = value:match("^%s*(.-)%s*$") or ""

	if v10 == "" or v10 == "x" then
		v10 = nil
	elseif v10:match("^%d+$") then
		v10 = "rbxassetid://" .. v10
	end

	if not v10 or v8[v10] then
		return false
	end

	v8[v10] = true

	if typeof(callback) == "function" then
		callback = callback()
	end

	if not v9[callback] then
		v9[callback] = true
		table.insert(list, callback)
	end

	return true
end

local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local v10 = {}
local v11 = {}
local count = 0
local count2 = 0
local v12 = {}
local count3 = 0

for _, v13 in pairs(Config) do
	if not (type(v13) == "table" and type(v13.list) == "table") then
		continue
	end

	for _, v14 in ipairs(v13.list) do
		local image

		if type(v14) == "table" then
			image = v14.image
		else
			image = nil
		end

		local function v16()
			local imageLabel = Instance.new("ImageLabel")
			local image2 = image:match("^%s*(.-)%s*$") or ""

			if image2 == "" or image2 == "x" then
				image2 = nil
			elseif image2:match("^%d+$") then
				image2 = "rbxassetid://" .. image2
			end

			imageLabel.Image = image2
			table.insert(v10, imageLabel)
			return imageLabel
		end

		local flag

		if typeof(image) == "string" then
			local v17 = image:match("^%s*(.-)%s*$") or ""

			if v17 == "" or v17 == "x" then
				v17 = nil
			elseif v17:match("^%d+$") then
				v17 = "rbxassetid://" .. v17
			end

			if v17 and not v8[v17] then
				v8[v17] = true

				if typeof(v16) == "function" then
					v16 = Instance.new("ImageLabel")
					local image2 = image:match("^%s*(.-)%s*$") or ""

					if image2 == "" or image2 == "x" then
						image2 = nil
					elseif image2:match("^%d+$") then
						image2 = "rbxassetid://" .. image2
					end

					v16.Image = image2
					table.insert(v10, v16)
				end

				if not v9[v16] then
					v9[v16] = true
					table.insert(v11, v16)
				end

				flag = true
			else
				flag = false
			end
		else
			flag = false
		end

		if flag then
			count += 1
		end
	end
end

local StarterGui = game:GetService("StarterGui")
local v13 = count

for _, guiObject in ipairs(StarterGui:GetDescendants()) do
	if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		continue
	end

	count2 += 1
	local image = guiObject.Image
	local flag

	if typeof(image) == "string" then
		local v14 = image:match("^%s*(.-)%s*$") or ""

		if v14 == "" or v14 == "x" then
			v14 = nil
		elseif v14:match("^%d+$") then
			v14 = "rbxassetid://" .. v14
		end

		if v14 and not v8[v14] then
			v8[v14] = true
			local v15

			if typeof(guiObject) == "function" then
				v15 = guiObject()
			else
				v15 = guiObject
			end

			if not v9[v15] then
				v9[v15] = true
				table.insert(v11, v15)
			end

			flag = true
		else
			flag = false
		end
	else
		flag = false
	end

	if flag then
		count += 1
	end

	if not guiObject:IsA("ImageButton") then
		continue
	end

	local hoverImage = guiObject.HoverImage
	local flag2

	if typeof(hoverImage) == "string" then
		local v14 = hoverImage:match("^%s*(.-)%s*$") or ""

		if v14 == "" or v14 == "x" then
			v14 = nil
		elseif v14:match("^%d+$") then
			v14 = "rbxassetid://" .. v14
		end

		if v14 and not v8[v14] then
			v8[v14] = true
			local v15

			if typeof(guiObject) == "function" then
				v15 = guiObject()
			else
				v15 = guiObject
			end

			if not v9[v15] then
				v9[v15] = true
				table.insert(v11, v15)
			end

			flag2 = true
		else
			flag2 = false
		end
	else
		flag2 = false
	end

	if flag2 then
		count += 1
	end

	local pressedImage = guiObject.PressedImage
	local flag3

	if typeof(pressedImage) == "string" then
		local v14 = pressedImage:match("^%s*(.-)%s*$") or ""

		if v14 == "" or v14 == "x" then
			v14 = nil
		elseif v14:match("^%d+$") then
			v14 = "rbxassetid://" .. v14
		end

		if v14 and not v8[v14] then
			v8[v14] = true

			if typeof(guiObject) == "function" then
				guiObject = guiObject()
			end

			if not v9[guiObject] then
				v9[guiObject] = true
				table.insert(v11, guiObject)
			end

			flag3 = true
		else
			flag3 = false
		end
	else
		flag3 = false
	end

	if flag3 then
		count += 1
	end
end

local descendants = {}

for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
	local v14 = v5[descendant.ClassName]

	if not v14 then
		continue
	end

	count2 += 1
	local match = descendant:GetFullName():match("^ReplicatedStorage%.([^%.]+)")

	if v7[descendant.ClassName] or match and v6[match] then
		local v15 = descendant[v14]
		local flag

		if typeof(v15) == "string" then
			local v16 = v15:match("^%s*(.-)%s*$") or ""

			if v16 == "" or v16 == "x" then
				v16 = nil
			elseif v16:match("^%d+$") then
				v16 = "rbxassetid://" .. v16
			end

			if v16 and not v8[v16] then
				v8[v16] = true

				if typeof(descendant) == "function" then
					descendant = descendant()
				end

				if not v9[descendant] then
					v9[descendant] = true
					table.insert(v11, descendant)
				end

				flag = true
			else
				flag = false
			end
		else
			flag = false
		end

		if flag then
			count += 1
		end
	else
		table.insert(descendants, descendant)
	end
end

for _, v14 in ipairs(descendants) do
	local v15 = v14[v5[v14.ClassName]]
	local flag

	if typeof(v15) == "string" then
		local v16 = v15:match("^%s*(.-)%s*$") or ""

		if v16 == "" or v16 == "x" then
			v16 = nil
		elseif v16:match("^%d+$") then
			v16 = "rbxassetid://" .. v16
		end

		if v16 and not v8[v16] then
			v8[v16] = true

			if typeof(v14) == "function" then
				v14 = v14()
			end

			if not v9[v14] then
				v9[v14] = true
				table.insert(v12, v14)
			end

			flag = true
		else
			flag = false
		end
	else
		flag = false
	end

	if flag then
		count3 += 1
	end
end

local count4 = #v11
local count5 = 0
local count6 = 0
local v14 = false
local v15 = nil
local flag = false
local now = 0
local thread = nil

local function closeLoadingScreen(p)
	if flag then
		return
	end

	flag = true
	local v16 = p and "超时（10 秒上限）" or v15 and "预加载调用异常" or "加载完成"
	print(string.format(
		"[LoadingScreen] 加载页退出：原因=%s，预加载已耗时=%.2f 秒，首屏资源=%d，资源回调=%d，预加载已结束=%s",
		v16,
		os.clock() - now,
		count4,
		count5,
		(tostring(v14))
	))

	if thread and thread ~= coroutine.running() then
		task.cancel(thread)
	end

	thread = nil

	if p then
		LoadingAnimation.completeImmediately()
	else
		LoadingAnimation.stop()
	end

	v4:stop()
	fadeOut(v)
	v:Destroy()
end

print(string.format(
	"[LoadingScreen] 扫描资源实例 %d 个，去重后首屏资源 %d 个（含配置图片 %d，代表实例 %d 个），后台资源 %d 个",
	count2,
	count,
	v13,
	count4,
	count3
))
v3.Visible = true
LoadingAnimation.setStage(nil)
LoadingAnimation.update(0, count4)
now = os.clock()
thread = task.delay(10, function()
	closeLoadingScreen(true)
end)
task.spawn(function()
	local success, result = pcall(function()
		ContentProvider:PreloadAsync(v11, function(p, p2)
			count5 += 1

			if p2 ~= Enum.AssetFetchStatus.Success then
				count6 += 1
				warn((`[LoadingScreen] 资源加载异常 {p}：{p2.Name}`))
			end

			if not flag then
				LoadingAnimation.update(math.min(count5, count4 * 0.99), count4)
			end
		end)
	end)
	v14 = true

	if not success then
		v15 = tostring(result)
	end

	for _, v16 in ipairs(v10) do
		v16:Destroy()
	end

	local v16 = flag and "后台" or "前台"

	if success then
		print(string.format(
			"[LoadingScreen] 资源预加载完成：%s，首屏资源=%d，资源回调=%d，失败回调=%d，总耗时=%.2f 秒",
			v16,
			count4,
			count5,
			count6,
			os.clock() - now
		))
	else
		warn(string.format("[LoadingScreen] 资源预加载调用异常：%s，总耗时=%.2f 秒，错误=%s", v16, os.clock() - now, v15))
	end

	if not flag then
		LoadingAnimation.update(count4, count4)
		task.spawn(function()
			LoadingAnimation.finish()
			closeLoadingScreen(false)
		end)
	end

	local success2, afterLoaded = pcall(require, script.AfterLoaded)

	if not success2 then
		warn((`[LoadingScreen] AfterLoaded 执行失败：{afterLoaded}`))
	end

	local lastTime = os.clock()
	local count7 = 0

	for i = 1, #v12, 20 do
		local v18 = table.move(v12, i, math.min(i + 20 - 1, #v12), 1, {})
		local success3, result2 = pcall(function()
			ContentProvider:PreloadAsync(v18, function(p, p2)
				if p2 ~= Enum.AssetFetchStatus.Success then
					count7 += 1
				end
			end)
		end)

		if not success3 then
			warn((`[LoadingScreen] 后台预加载批次异常：{result2}`))
		end

		task.wait(0.25)
	end

	print(string.format("[LoadingScreen] 后台资源预加载完成：%d 个，失败 %d 个，耗时 %.2f 秒", count3, count7, os.clock() - lastTime))
end)