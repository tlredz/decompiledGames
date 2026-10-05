return {
	Name = "currentTreadmillMedia",
	Aliases = { "curVid", "curVideo" },
	Description = "Print the media key and asset IDs of the treadmill or phone media currently playing for you",
	Group = "Moderator",
	Args = {},
	ClientRun = function(_)
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local TreadmillVideoController = require(ReplicatedStorage.Shared.TreadmillVideoController)
		local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)

		local function findPhoneVideoAssetId()
			local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
			local phoneVideoUI

			if playerGui ~= nil then
				phoneVideoUI = playerGui:FindFirstChild("PhoneVideoUI")
			end

			if phoneVideoUI == nil or not (phoneVideoUI:IsA("ScreenGui") and phoneVideoUI.Enabled) then
				return nil
			end

			local phone = phoneVideoUI:FindFirstChild("Phone")
			local mainVideo

			if phone ~= nil then
				mainVideo = phone:FindFirstChild("MainVideo", true)
			end

			if mainVideo == nil or not mainVideo:IsA("VideoFrame") or mainVideo.Video == "" then
				return nil
			end

			return string.match(mainVideo.Video, "%d+")
		end

		local v = "Treadmill"
		local activeMediaEntry = TreadmillVideoController.GetActiveMediaEntry()

		if activeMediaEntry == nil then
			local phoneVideoAssetId = findPhoneVideoAssetId()

			if phoneVideoAssetId ~= nil then
				activeMediaEntry = TreadmillVideoController.GetMediaEntryByKey((`Video:{phoneVideoAssetId}`))

				if activeMediaEntry == nil then
					local formatted = `Video: {phoneVideoAssetId} (Phone, no matching media entry)`
					print((`[currentTreadmillMedia] {formatted}`))
					return formatted
				else
					v = "Phone"
				end
			end
		end

		if activeMediaEntry == nil then
			return "No media is currently playing (run on a treadmill or open the phone first)"
		end

		local v2 = {
			`Key: {TreadmillMediaIdentity.GetMediaKey(activeMediaEntry)} ({v})`,
			(`Kind: {activeMediaEntry.Kind} | Bucket: {activeMediaEntry.BucketType} | Release: {activeMediaEntry.ReleaseVersion}`)
		}

		if activeMediaEntry.Kind == "Video" then
			table.insert(v2, (`Video: {activeMediaEntry.Video}`))
			table.insert(v2, (`Cover: {activeMediaEntry.CoverImage or "(none)"}`))
			local music = activeMediaEntry.Music

			if music ~= nil then
				table.insert(v2, (`Music: {music.SoundId}`))
			end
		else
			table.insert(v2, (`Image: {activeMediaEntry.Image}`))
			table.insert(v2, (`Sound: {activeMediaEntry.SoundId}`))
		end

		local joined = table.concat(v2, "\n")
		print((`[currentTreadmillMedia]\n{joined}`))
		return joined
	end
}