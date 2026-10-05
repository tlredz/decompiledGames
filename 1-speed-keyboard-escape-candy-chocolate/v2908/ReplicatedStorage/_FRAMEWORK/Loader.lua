local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local NoYield = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.NoYield)
local FeatureManager = require(script.Parent.Libraries.FeatureManager)
local PlayerReady = require(script.Parent.Features.PlayerReady)

local function secureWrap(name: string, callback, flag: boolean?)
	local function fn()
		if flag then
			return callback()
		end

		NoYield(callback)
	end

	if not Common.IsStudio() then
		xpcall(fn, function(p)
			warn((`Error in {name}: {p}\n{debug.traceback()}`))
		end)
	elseif flag then
		callback()
	else
		NoYield(callback)
	end
end

return function()
	if RunService:IsClient() then
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		while ReplicatedStorage:GetAttribute("ServerLoaded") ~= true do
			task.wait()
		end
	end

	FeatureManager.SetFeatureStage("PreInit")
	local allFeatures = FeatureManager.RetrieveAllFeatures()
	FeatureManager.SetFeatureStage("PreInit")

	for _, allFeature in allFeatures do
		if allFeature.OnPreInit == nil then
			continue
		end

		print("[LOADER] Pre-Init: " .. allFeature.Name)
		secureWrap(allFeature.Name, allFeature.OnPreInit, true)
	end

	FeatureManager.SetFeatureStage("Init")

	for _, allFeature in allFeatures do
		if allFeature.OnInit == nil then
			continue
		end

		print("[LOADER] Init: " .. allFeature.Name)
		secureWrap(allFeature.Name, allFeature.OnInit, true)
	end

	if Common.IsClient() then
		FeatureManager.SetFeatureStage("UIInit")

		for _, allFeature in allFeatures do
			if allFeature.OnUIInit == nil then
				continue
			end

			print("[LOADER] UIInit: " .. allFeature.Name)
			secureWrap(allFeature.Name, allFeature.OnUIInit, true)
		end
	end

	FeatureManager.SetFeatureStage("Start")

	for _, allFeature in allFeatures do
		if allFeature.OnStart == nil then
			continue
		end

		print("[LOADER] Starting: " .. allFeature.Name)
		local v = allFeature
		secureWrap(allFeature.Name, function()
			task.spawn(v.OnStart)
		end, true)
	end

	FeatureManager.SetFeatureStage("Running")
	local count = 0
	RunService.PreSimulation:Connect(function(dt: number)
		Common._NewFrameBegin(dt)
		count += 1

		for _, allFeature in allFeatures do
			local onUpdate = allFeature.OnUpdate

			if onUpdate == nil then
				continue
			end

			local v = allFeature
			local onUpdate2 = onUpdate
			secureWrap(allFeature.Name, function()
				debug.profilebegin("OnUpdate " .. v.Name)
				onUpdate2()
				debug.profileend()
			end)
		end
	end)

	if RunService:IsClient() then
		local count2 = 0
		RunService.RenderStepped:Connect(function()
			count2 += 1

			for _, allFeature in allFeatures do
				local v = allFeature

				local function runFeature(p: string, callback)
					if callback == nil then
						return
					end

					secureWrap(v.Name, function()
						debug.profilebegin(p .. " " .. v.Name)
						callback()
						debug.profileend()
					end)
				end

				local onRender = allFeature.OnRender

				if onRender == nil then
					continue
				end

				local v3 = "OnRender"
				local v4 = allFeature
				local onRender2 = onRender
				secureWrap(allFeature.Name, function()
					debug.profilebegin(v3 .. " " .. v4.Name)
					onRender2()
					debug.profileend()
				end)
			end
		end)
	end

	if Common.IsServer() then
		ReplicatedStorage:SetAttribute("ServerLoaded", true)
	else
		while ReplicatedStorage:GetAttribute("ServerLoaded") ~= true do
			task.wait()
		end

		PlayerReady.remotes.PlayerReady:fire()
	end

	print((`{Common.IsClient() and "Client" or "Server"} has loaded!`))
end