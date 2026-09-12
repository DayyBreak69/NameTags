--==================================================
-- V27 FULL AUDIT BUILD
-- Based on the tested V15 respawn-safe renderer with the later bot/config,
-- color, live-update, and logo-rotation features retained.
-- This build removes the known conflicting/duplicated paths found in V26.
--==================================================

--==================================================
-- DAYBREAK MULTIPLAYER NAMETAG
-- V27: FULL AUDIT / CONFLICT CLEANUP
--==================================================

-- Single-instance guard: every execution invalidates the previous instance.
-- This prevents repeated executor runs from stacking controllers and GUI updates.
_G.__DayBreakNametagGeneration = (_G.__DayBreakNametagGeneration or 0) + 1
local __DAYBREAK_GENERATION = _G.__DayBreakNametagGeneration

-- Disconnect connections owned by the previous execution when this script
-- supports the shared cleanup registry. This keeps repeated executor runs clean.
_G.__DayBreakNametagConnections = _G.__DayBreakNametagConnections or {}
for _, oldConnection in pairs(_G.__DayBreakNametagConnections) do
	pcall(function()
		if oldConnection and oldConnection.Disconnect then
			oldConnection:Disconnect()
		end
	end)
end
_G.__DayBreakNametagConnections = {}

-- Shared player-lifecycle cleanup registry.
-- CharacterAdded/CharacterRemoving connections must also be disconnected when
-- this script is executed again, otherwise old handlers can recreate tags.
_G.__DayBreakNametagPlayerConnections = _G.__DayBreakNametagPlayerConnections or {}
for _, oldPlayerConnection in pairs(_G.__DayBreakNametagPlayerConnections) do
	pcall(function()
		if oldPlayerConnection and oldPlayerConnection.Disconnect then
			oldPlayerConnection:Disconnect()
		elseif type(oldPlayerConnection) == "table" then
			for _, connection in pairs(oldPlayerConnection) do
				if connection and connection.Disconnect then
					connection:Disconnect()
				end
			end
		end
	end)
end
_G.__DayBreakNametagPlayerConnections = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

--==================================================
-- GLOBAL NAMETAG PURGE
--==================================================
-- BillboardGuis are parented to PlayerGui, not the character. On repeated
-- executor runs an older GUI can therefore survive even after its animation
-- connection is disconnected. Purge every DayBreak nametag GUI once at
-- startup so this execution always begins with a clean slate.
local function purgeAllDayBreakNametags()
	for _, child in ipairs(PlayerGui:GetChildren()) do
		if child:IsA("BillboardGui") then
			local name = tostring(child.Name)
			local isDayBreak = child:GetAttribute("DayBreakTargetUserId") ~= nil
				and (child:GetAttribute("DayBreakNametagVersion") ~= nil
					or name:find("DayBreak", 1, true)
					or name:find("Nametag", 1, true)
					or name:find("NameTag", 1, true)
					or name:find("CircleLogo", 1, true))

			if isDayBreak
				or name == "CustomDayBreakNametag"
				or name == "DayBreakNametag"
				or name == "DayBreakNameTag"
				or name == "DayBreakCircleLogo"
				or name == "DayBreakLogo" then
				child:Destroy()
			end
		end
	end
end

-- Run before any nametags are created.
purgeAllDayBreakNametags()

--==================================================
-- V19 BOT-ONLY DESIGN: no automatic OWNER border/name styling
--==================================================
-- SETTINGS
--==================================================

--==================================================
-- PRELOADED NAMETAG COLORS
--==================================================
-- This palette MUST live at script scope because both the nametag
-- renderer and its nested color helpers need access to it.
local NAMED_COLORS = {
    Red = Color3.fromRGB(255, 60, 60),
    Crimson = Color3.fromRGB(220, 35, 55),
    Orange = Color3.fromRGB(255, 145, 40),
    Amber = Color3.fromRGB(255, 175, 35),
    Yellow = Color3.fromRGB(255, 225, 55),
    Lime = Color3.fromRGB(150, 255, 45),
    Green = Color3.fromRGB(60, 255, 110),
    Emerald = Color3.fromRGB(35, 210, 125),
    Cyan = Color3.fromRGB(40, 235, 255),
    SkyBlue = Color3.fromRGB(70, 190, 255),
    Blue = Color3.fromRGB(70, 130, 255),
    RoyalBlue = Color3.fromRGB(55, 85, 235),
    Purple = Color3.fromRGB(170, 80, 255),
    Violet = Color3.fromRGB(125, 70, 255),
    Magenta = Color3.fromRGB(235, 55, 255),
    Pink = Color3.fromRGB(255, 70, 210),
    Rose = Color3.fromRGB(255, 80, 135),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Gold = Color3.fromRGB(255, 195, 45),
}


--==================================================
-- SAFE PRELOADED COLOR RESOLVER
--==================================================
-- This function intentionally owns its palette. It does not depend on a
-- local variable declared inside createNametag(), preventing executor
-- scope/order issues from ever making the palette nil.
local function getPreloadedColor(value)
	local requested = tostring(value or "")
	local lower = requested:lower()

	local colors = {
		red = Color3.fromRGB(255, 60, 60),
		crimson = Color3.fromRGB(220, 35, 55),
		orange = Color3.fromRGB(255, 145, 40),
		amber = Color3.fromRGB(255, 175, 35),
		yellow = Color3.fromRGB(255, 225, 55),
		lime = Color3.fromRGB(150, 255, 45),
		green = Color3.fromRGB(60, 255, 110),
		emerald = Color3.fromRGB(35, 210, 125),
		cyan = Color3.fromRGB(40, 235, 255),
		skyblue = Color3.fromRGB(70, 190, 255),
		blue = Color3.fromRGB(70, 130, 255),
		royalblue = Color3.fromRGB(55, 85, 235),
		purple = Color3.fromRGB(170, 80, 255),
		violet = Color3.fromRGB(125, 70, 255),
		magenta = Color3.fromRGB(235, 55, 255),
		pink = Color3.fromRGB(255, 70, 210),
		rose = Color3.fromRGB(255, 80, 135),
		white = Color3.fromRGB(255, 255, 255),
		black = Color3.fromRGB(0, 0, 0),
		gold = Color3.fromRGB(255, 195, 45),
	}

	return colors[lower]
end

local SETTINGS = {

	-- Display
	Font = Enum.Font.GothamBold,
	DefaultRole = "MEMBER",

	-- Roles
	-- Change usernames here
	Roles = {},

	-- Global default tag. Every shown player starts with these values,
	-- then their remote/player-specific values override them.
	DefaultTag = {
		Banner = "DefaultBW.png",
		Border = "WhiteGlow",
		BackgroundTransparency = 0.05,
	},

	-- Player-specific tags are supplied exclusively by the Discord/GitHub config.
	PlayerTags = {
		-- Player-specific tags are now managed by the Discord bot / GitHub config.
		-- Add entries here only if you intentionally want a local fallback.
	},

	-- Colors
	-- Default palette: monochrome black + white.
	Orange = Color3.fromRGB(255, 255, 255),
	OrangeBright = Color3.fromRGB(255, 255, 255),

	Chrome = Color3.fromRGB(235, 235, 235),
	Dark = Color3.fromRGB(0, 0, 0),
	DarkInner = Color3.fromRGB(8, 8, 8),

	White = Color3.fromRGB(255, 255, 255),

	-- Main tag
	-- Overall visual scale: 0.88 = about 12% smaller while preserving the layout.
	OverallTagScale = 0.88,
	Width = 280,
	Height = 75,
	HeightOffset = 3.3,

	-- Distance scaling
	DistanceScaling = true,
	NormalDistance = 25,
	MinScale = 0.20,
	MaxScale = 1,

	-- At this distance the full tag becomes the logo
	CircleOnlyDistance = 30,

	-- Circle logo
	CircleDistanceScaling = true,
	CircleSize = 58,
	CircleMinScale = 0.50,
	CircleShrinkStart = 30,

	-- Glow
	GlowEnabled = true,
	GlowSpeed = 2,
	GlowAmount = 0.35,

	-- Name pulse
	NamePulseEnabled = true,
	NamePulseSpeed = 2.5,
	NamePulseAmount = 0.25,

	-- Star
	StarEnabled = true,
	-- Dedicated logo rotation system
	LogoRotationEnabled = true,
	LogoRotationSpeed = 20,

	-- CLICKABLE FRIEND TAGS
	-- LOGO EFFECT SYSTEM
	-- All 26 effects are available. Enable only the ones you want.
	LogoEffectsEnabled = true,
	LogoEffectsSpeed = 1,
	LogoEffects = {
		"Pulse",
		-- "GlowPulse",
		-- "ShineSweep",
		-- "ChromeSweep",
		-- "ColorCycling",
		-- "BrightnessPulse",
		-- "OutlineGlow",
		-- "OuterRing",
		-- "OrbitingParticles",
		-- "SparkleFlashes",
		-- "EnergyAura",
		-- "Ripple",
		-- "BreathingEffect",
		-- "Floating",
		-- "Glitch",
		-- "ChromaticSplit",
		-- "Scanline",
		-- "ParticleBurst",
		-- "Trail",
		-- "ElectricArcs",
		-- "Halo",
		-- "Shockwave",
	},
	LogoPulseAmount = 0.035,
	LogoGlowPulseAmount = 0.25,
	LogoFloatingAmount = 2,


	-- PER-PLAYER BORDER SYSTEM
	RainbowBannerEnabled = true,
	RainbowBannerSpeed = 18, -- smooth continuous movement
	RainbowBannerThickness = 3,
	RainbowBannerGlowThickness = 6,
	RainbowBannerOuterGlowThickness = 10,

	-- Per-player border styles:
	-- "Rainbow" (default for the existing rainbow setup)
	-- "NeonPink" (clean pink glow)
	-- "WhiteGlow" (clean white glow)
	-- "None" (no procedural border)
	NeonPink = Color3.fromRGB(255, 0, 190),
	NeonPinkGlow = Color3.fromRGB(255, 40, 220),
	WhiteGlow = Color3.fromRGB(255, 255, 255),
	BorderColor = nil, -- Optional custom border color: #RRGGBB or named color

	-- Floating
	FloatingEnabled = true,
	FloatSpeed = 1.5,
	FloatAmount = 0.04,

	-- Maximum distance
	MaxDistance = 500,
}

--==================================================
-- REMOTE NAMETAG CONFIGURATION
--==================================================
-- The Discord bot will edit this JSON file in your GitHub repository.
-- Roblox only reads it; no GitHub write token is ever placed in this script.
local REMOTE_CONFIG_URL =
	"https://raw.githubusercontent.com/DayyBreak69/NameTags/main/config/nametags.json"

-- Fast remote updates: check GitHub every 5 seconds.
-- Each request gets a unique cache-buster so stale CDN responses are less likely.
local REMOTE_CONFIG_POLL_SECONDS = 5
local remoteConfigRequestCounter = 0
local remoteConfigBody = nil
local remoteConfigOnline = false

local function getRemoteConfigUrl()
	remoteConfigRequestCounter += 1
	return REMOTE_CONFIG_URL
		.. "?cb="
		.. tostring(os.time())
		.. "_"
		.. tostring(remoteConfigRequestCounter)
end

--==================================================
-- SHARED REGISTRY
--==================================================

local REGISTRY_URL = "https://daybreak-nametag-registry.terranjones870.workers.dev"
local REGISTRY_POLL_SECONDS = 5

local ActivePlayers = {}
local registryOnline = false
local NametagConnections = {}
local CreatingNametags = setmetatable({}, {__mode = "k"})

local function httpRequest(options)
	local requestFunction =
		(syn and syn.request)
		or (http and http.request)
		or http_request
		or request
		or (fluxus and fluxus.request)

	if not requestFunction then
		return nil
	end

	local ok, result = pcall(requestFunction, options)
	if not ok then
		return nil
	end

	return result
end

local function registryRequest(method, path, body)
	if REGISTRY_URL == "" or REGISTRY_URL == "PASTE_YOUR_REGISTRY_URL_HERE" then
		return nil
	end

	local options = {
		Url = REGISTRY_URL:gsub("/+$", "") .. path,
		Method = method,
		Headers = {
			["Content-Type"] = "application/json"
		}
	}

	if body then
		options.Body = game:GetService("HttpService"):JSONEncode(body)
	end

	local ok, result = pcall(httpRequest, options)
	if not ok then
		return nil
	end

	return result
end

--==================================================
-- LOCAL CUSTOM ASSETS
--==================================================

local HttpService = game:GetService("HttpService")
local getAsset = getcustomasset or getsynasset
local AssetCache = {}

--==================================================
-- GITHUB BANNERS
--==================================================
-- Put banner PNGs in: GitHub repo -> banners/
-- Example raw file:
-- https://raw.githubusercontent.com/DayyBreak69/NameTags/main/banners/DayyBreak66.png
local BANNER_BASE_URL =
	"https://raw.githubusercontent.com/DayyBreak69/NameTags/main/banners/"

local BANNER_FOLDER = "DayBreak/Banners"
-- Fresh cache key for each script execution; prevents stale banner images.
local BANNER_SESSION = tostring(math.floor(os.clock() * 1000000))

local function loadLocalAsset(path)
	if not getAsset or not path or path == "" then
		return nil
	end

	if AssetCache[path] then
		return AssetCache[path]
	end

	local ok, asset = pcall(function()
		return getAsset(path)
	end)

	if ok and asset then
		AssetCache[path] = asset
		return asset
	end

	return nil
end

local function downloadBanner(filename)
	if not filename or filename == "" then
		return nil
	end

	if not getAsset then
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")

	-- Use a fresh file for this execution so an old local asset can never
	-- overwrite a newer GitHub banner. This is deliberately separate from
	-- the remote-config polling cache.
	local localPath =
		BANNER_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. BANNER_SESSION .. ".png"

	-- Reuse the already-downloaded banner during this script execution.
	if isfile then
		local exists = false
		pcall(function() exists = isfile(localPath) end)
		if exists then
			local cachedAsset = loadLocalAsset(localPath)
			if cachedAsset then
				return cachedAsset
			end
		end
	end

	if not writefile then
		return nil
	end

	if makefolder then
		pcall(makefolder, "DayBreak")
		pcall(makefolder, BANNER_FOLDER)
	end

	local url = BANNER_BASE_URL .. safeName
	local body = nil

	-- V15's tested order: Roblox HttpGet first, executor request second.
	-- Do not inspect or transform the binary PNG body before writefile().
	local okHttp, httpBody = pcall(function()
		return game:HttpGet(url)
	end)

	if okHttp and type(httpBody) == "string" and #httpBody > 0 then
		body = httpBody
	end

	if not body then
		local result = httpRequest({
			Url = url,
			Method = "GET",
		})

		if result and tonumber(result.StatusCode) == 200
			and type(result.Body) == "string"
			and #result.Body > 0 then
			body = result.Body
		end
	end

	if not body then
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		return nil
	end

	AssetCache[localPath] = nil
	return loadLocalAsset(localPath)
end

--==================================================
-- GITHUB CUSTOM LOGOS
--==================================================
local LOGO_BASE_URL =
	"https://raw.githubusercontent.com/DayyBreak69/NameTags/main/Logos/"

-- CDN fallback. This avoids some executors/network setups that have trouble
-- fetching binary files directly from raw.githubusercontent.com.
local LOGO_CDN_URL =
	"https://cdn.jsdelivr.net/gh/DayyBreak69/NameTags@main/Logos/"

local LOGO_FOLDER = "DayBreak/Logos"
local LOGO_SESSION = tostring(math.floor(os.clock() * 1000000))

local function downloadLogo(filename)
	if not filename or filename == "" then
		return nil
	end

	if not getAsset then
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")
	local localPath =
		LOGO_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. LOGO_SESSION .. ".png"

	if not writefile then
		return nil
	end

	if makefolder then
		pcall(makefolder, "DayBreak")
		pcall(makefolder, LOGO_FOLDER)
	end

	-- Try the CDN first, then GitHub Raw.
	local urls = {
		LOGO_CDN_URL .. safeName,
		LOGO_BASE_URL .. safeName,
	}

	local body = nil
	local successfulUrl = nil

	for _, url in ipairs(urls) do
		-- Executor HTTP request first so we can verify the HTTP status.
		local result = httpRequest({
			Url = url,
			Method = "GET",
		})

		if result and tonumber(result.StatusCode) == 200
			and type(result.Body) == "string"
			and #result.Body > 0 then
			body = result.Body
			successfulUrl = url
			break
		end

		-- Fallback to Roblox HttpGet.
		local okHttp, httpBody = pcall(function()
			return game:HttpGet(url)
		end)

		if okHttp and type(httpBody) == "string" and #httpBody > 0 then
			body = httpBody
			successfulUrl = url
			break
		end
	end

	if not body then
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		return nil
	end

	AssetCache[localPath] = nil
	local asset = loadLocalAsset(localPath)

	if not asset then
		return nil
	end

	return asset
end

local function httpGetText(url)
	if not url or url == "" then
		return nil
	end

	-- Executor request first so HTTP status can be checked.
	local result = httpRequest({
		Url = url,
		Method = "GET",
	})

	if result and tonumber(result.StatusCode) == 200
		and type(result.Body) == "string"
		and #result.Body > 0 then
		return result.Body
	end

	-- Fallback to Roblox HttpGet.
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)

	if ok and type(body) == "string" and #body > 0 then
		return body
	end

	return nil
end

local function copyTable(source)
	local result = {}
	if type(source) ~= "table" then
		return result
	end
	for key, value in pairs(source) do
		result[key] = value
	end
	return result
end

local function applyRemoteConfig(body)
	if type(body) ~= "string" or body == "" then
		return false
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(body)
	end)

	if not ok or type(decoded) ~= "table" then
		return false
	end

	if type(decoded.defaults) == "table" then
		local newDefaults = copyTable(SETTINGS.DefaultTag)
		for key, value in pairs(decoded.defaults) do
			if key == "Banner" or key == "Logo" or key == "Border"
				or key == "BackgroundTransparency" or key == "DisplayName"
				or key == "Role" or key == "NameColor" or key == "LogoRotationEnabled" then
				newDefaults[key] = value
			end
		end
		SETTINGS.DefaultTag = newDefaults
	end

	if type(decoded.players) == "table" then
		-- Remote players are an authoritative snapshot. Do NOT merge with the
		-- previous snapshot: a Discord /nametag reset removes an entry from
		-- GitHub, and the client must remove it from memory on the next poll.
		local newPlayers = {}
		for playerKey, playerConfig in pairs(decoded.players) do
			if type(playerConfig) == "table" then
				local key = tostring(playerKey)
				newPlayers[key] = copyTable(playerConfig)
			end
		end
		SETTINGS.PlayerTags = newPlayers
	end

	-- Optional role lookup retained for compatibility with the existing engine.
	if type(decoded.roles) == "table" then
		local newRoles = {}
		for playerKey, role in pairs(decoded.roles) do
			if type(role) == "string" then
				newRoles[tostring(playerKey)] = role
			end
		end
		SETTINGS.Roles = newRoles
	end

	remoteConfigOnline = true
	return true
end

local function fetchRemoteConfig()
	if REMOTE_CONFIG_URL == "" or REMOTE_CONFIG_URL == "PASTE_YOUR_CONFIG_URL_HERE" then
		return false, false
	end

	local body = httpGetText(getRemoteConfigUrl())
	if not body then
		remoteConfigOnline = false
		return false, false
	end

	local changed = body ~= remoteConfigBody
	if changed then
		if not applyRemoteConfig(body) then
			return false, false
		end
		remoteConfigBody = body
	end

	return true, changed
end

local function getTagConfig(player)
	local config = copyTable(SETTINGS.DefaultTag)
	local playerConfig = SETTINGS.PlayerTags[player.UserId]
		or SETTINGS.PlayerTags[player.Name]
		or {}

	for key, value in pairs(playerConfig) do
		config[key] = value
	end

	return config
end

local function getNametagName(player)
	local config = getTagConfig(player)
	local customName = config.DisplayName

	-- Treat an empty/whitespace custom name as "use the real display name".
	if customName ~= nil then
		customName = tostring(customName)
		if customName:match("%S") then
			return customName
		end
	end

	return player.DisplayName
end

--==================================================
-- ROLE
--==================================================

local function getRole(player)
	local config = getTagConfig(player)
	return config.Role
		or SETTINGS.Roles[player.UserId]
		or SETTINGS.Roles[tostring(player.UserId)]
		or SETTINGS.Roles[player.Name]
		or SETTINGS.DefaultRole
end

--==================================================
-- REMOVE OLD TAG
--==================================================

local function isDayBreakNametagGui(child)
	if not child or not child:IsA("BillboardGui") then
		return false
	end

	local name = tostring(child.Name)
	return name == "CustomDayBreakNametag"
		or name == "DayBreakCircleLogo"
		or name == "DayBreakNametag"
		or name == "DayBreakNameTag"
		or name == "DayBreakLogo"
		or name:find("DayBreak", 1, true) ~= nil
		or name:find("Nametag", 1, true) ~= nil
		or name:find("NameTag", 1, true) ~= nil
		or name:find("CircleLogo", 1, true) ~= nil
end

-- BillboardGuis are parented to PlayerGui, so a dead character can disappear
-- while its old BillboardGui remains alive. Cleanup therefore uses the
-- DayBreakTargetUserId attribute, not only the current character/head.
local function removeAllPlayerGuiNametags(player)
	if not player then
		return
	end

	local userId = tonumber(player.UserId)
	for _, child in ipairs(PlayerGui:GetChildren()) do
		if isDayBreakNametagGui(child) then
			local targetUserId = tonumber(child:GetAttribute("DayBreakTargetUserId"))
			if targetUserId == userId then
				child:Destroy()
			end
		end
	end
end

local function removePlayerGuiNametagsForCharacter(character)
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	for _, child in ipairs(PlayerGui:GetChildren()) do
		if isDayBreakNametagGui(child) then
			-- Prefer exact Adornee matching, but also remove tags whose Adornee
			-- points at any descendant of this character (legacy safety).
			local matchesHead = head and child.Adornee == head
			local adornee = child.Adornee
			local matchesCharacter = false
			if adornee and adornee:IsDescendantOf(character) then
				matchesCharacter = true
			end

			if matchesHead or matchesCharacter then
				child:Destroy()
			end
		end
	end
end

local function removeNametag(character)
	if not character then
		return
	end

	-- First remove anything attached to this exact character.
	removePlayerGuiNametagsForCharacter(character)

	-- Then remove ALL PlayerGui tags belonging to the same player. This is the
	-- important respawn fix: the old tag is still in PlayerGui after death, and
	-- its old Head may no longer be the current character.
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		removeAllPlayerGuiNametags(player)
	end

	local oldConnection = NametagConnections[character]
	if oldConnection then
		pcall(function() oldConnection:Disconnect() end)
		NametagConnections[character] = nil
		_G.__DayBreakNametagConnections[character] = nil
	end

	-- Clean up tags left behind by previous versions of this script.
	-- Earlier builds used several different BillboardGui names, so removing
	-- only "CustomDayBreakNametag" could leave an old overlay/sweep alive.
	local staleNames = {
		CustomDayBreakNametag = true,
		DayBreakNametag = true,
		DayBreakNameTag = true,
		DayBreakCircleLogo = true,
		DayBreakLogo = true,
	}

	-- Search the entire character hierarchy, not just direct children.
	-- This catches legacy tags/overlays that were parented under Head or
	-- another attachment and could otherwise survive the cleanup.
	for _, child in ipairs(character:GetDescendants()) do
		if child:IsA("Frame") and child.Name == "BannerOverlay" then
			child:Destroy()
		elseif child:IsA("BillboardGui") then
			local name = tostring(child.Name)
			if staleNames[name]
				or name:find("DayBreak", 1, true)
				or name:find("Nametag", 1, true)
				or name:find("NameTag", 1, true)
				or name:find("CircleLogo", 1, true)
				or name:find("ChromeSweep", 1, true)
				or name:find("ShineSweep", 1, true) then
				child:Destroy()
			end
		end
	end

	local oldLogo = character:FindFirstChild("DayBreakCircleLogo")
	if oldLogo then
		oldLogo:Destroy()
	end
end

--==================================================
-- STAFF-UPLOADED ANIMATION FRAMES
-- Discord stores animated banners as individual PNG frames.
-- Roblox swaps the ImageLabel.Image one frame at a time. This avoids
-- ImageRectOffset/ImageRectSize sprite-sheet scaling/cropping issues.
--==================================================
local function setupIndividualFrameAnimation(imageObject, animationConfig)
	if not imageObject or type(animationConfig) ~= "table" then
		return nil
	end

	local frames = animationConfig.Frames
	local frameCount = type(frames) == "table" and #frames or 0
	local fps = tonumber(animationConfig.FPS)

	if frameCount <= 0 or not fps or fps <= 0 then
		return nil
	end

	local controller = {
		image = imageObject,
		frames = frames,
		frameCount = frameCount,
		fps = fps,
		frame = 1,
		assets = {},
	}

	-- Load every frame once. Each frame is a normal 560x150 PNG, so Roblox
	-- never has to interpret a large grid/sprite sheet.
	for i, filename in ipairs(frames) do
		if controller.image and controller.image.Parent then
			local asset = downloadBanner(filename)
			if asset then
				controller.assets[i] = asset
			end
		end
	end

	if not controller.assets[1] then
		return nil
	end

	imageObject.Image = controller.assets[1]
	imageObject.ScaleType = Enum.ScaleType.Stretch

	task.spawn(function()
		while controller.image and controller.image.Parent do
			task.wait(1 / controller.fps)

			if not controller.image or not controller.image.Parent then
				break
			end

			controller.frame = (controller.frame % controller.frameCount) + 1
			local nextAsset = controller.assets[controller.frame]
			if nextAsset then
				controller.image.Image = nextAsset
			end
		end
	end)

	return controller
end

-- Backwards-compatible sprite-sheet animation for old configs (including
-- existing logo animations). New animated banners use Frames instead.
local function setupSpriteAnimation(imageObject, animationConfig)
	if not imageObject or type(animationConfig) ~= "table" then
		return nil
	end

	local frameWidth = tonumber(animationConfig.FrameWidth)
	local frameHeight = tonumber(animationConfig.FrameHeight)
	local columns = tonumber(animationConfig.Columns)
	local frameCount = tonumber(animationConfig.FrameCount)
	local fps = tonumber(animationConfig.FPS)

	if not frameWidth or not frameHeight or not columns or not frameCount or not fps then
		return nil
	end
	if frameWidth <= 0 or frameHeight <= 0 or columns <= 0 or frameCount <= 0 or fps <= 0 then
		return nil
	end

	imageObject.ScaleType = Enum.ScaleType.Stretch
	imageObject.ImageRectSize = Vector2.new(frameWidth, frameHeight)
	imageObject.ImageRectOffset = Vector2.new(0, 0)

	local controller = {
		image = imageObject,
		frameWidth = frameWidth,
		frameHeight = frameHeight,
		columns = columns,
		frameCount = frameCount,
		fps = fps,
		frame = 0,
	}

	task.spawn(function()
		while controller.image and controller.image.Parent do
			task.wait(1 / controller.fps)
			if not controller.image or not controller.image.Parent then
				break
			end
			controller.frame = (controller.frame + 1) % controller.frameCount
			local column = controller.frame % controller.columns
			local row = math.floor(controller.frame / controller.columns)
			controller.image.ImageRectOffset = Vector2.new(
				column * controller.frameWidth,
				row * controller.frameHeight
			)
		end
	end)

	return controller
end

local function advanceSpriteAnimation(animation, dt)
	-- Kept for compatibility with any existing references. New animations
	-- run independently and do not use this function.
	return
end

--==================================================
-- CREATE NAMETAG
--==================================================

local function createNametag(player, character)

	if not player or not character then
		return
	end

	-- Never build a tag for a character that is no longer the player's current
	-- character. This blocks delayed registry/remote-config tasks from
	-- resurrecting a nametag on a dead character.
	if player.Character ~= character or not character.Parent then
		return
	end

	-- Prevent overlapping task.spawn calls from creating two tags/connections
	-- for the same character during registry/respawn races.
	if CreatingNametags[character] then
		return
	end
	CreatingNametags[character] = true

	-- Remove any leftover tag from a previous character for this same player
	-- before creating the new one.
	removeAllPlayerGuiNametags(player)

	local head = character:FindFirstChild("Head")

	if not head then
		head = character:WaitForChild("Head", 5)
	end

	if not head then
		CreatingNametags[character] = nil
		return
	end

	removeNametag(character)

	--==================================================
	-- MAIN BILLBOARD
	--==================================================

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomDayBreakNametag"
	billboard:SetAttribute("DayBreakNametagVersion", "GifLogoFixV30")
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(
		SETTINGS.Width,
		SETTINGS.Height
	)
	billboard.StudsOffset = Vector3.new(
		0,
		SETTINGS.HeightOffset,
		0
	)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = SETTINGS.MaxDistance
	billboard.ResetOnSpawn = false
	billboard:SetAttribute("DayBreakTargetUserId", player.UserId)
	billboard:SetAttribute("DayBreakOwnerGeneration", __DAYBREAK_GENERATION)
	billboard.Parent = PlayerGui

	--==================================================
	-- OUTER CHROME
	--==================================================

	local tagConfig = getTagConfig(player)
	local borderStyle = tostring(tagConfig.Border or "WhiteGlow")

	local outer = Instance.new("Frame")
	outer.Size = UDim2.fromScale(1, 1)
	outer.Position = UDim2.fromScale(0.5, 0.5)
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	outer.BackgroundColor3 = SETTINGS.Chrome
	outer.BorderSizePixel = 0

	local outerScale = Instance.new("UIScale")
	outerScale.Scale = tonumber(SETTINGS.OverallTagScale) or 0.88
	outerScale.Parent = outer
	outer.Parent = billboard

	local outerCorner = Instance.new("UICorner")
	outerCorner.CornerRadius = UDim.new(0, 22)
	outerCorner.Parent = outer

	--==================================================
	-- ORANGE FRAME
	--==================================================

	local orangeFrame = Instance.new("Frame")
	orangeFrame.Size = UDim2.new(1, -6, 1, -6)
	orangeFrame.Position = UDim2.fromOffset(3, 3)
	orangeFrame.BackgroundColor3 = SETTINGS.Orange
	orangeFrame.BorderSizePixel = 0
	orangeFrame.Parent = outer

	local orangeCorner = Instance.new("UICorner")
	orangeCorner.CornerRadius = UDim.new(0, 20)
	orangeCorner.Parent = orangeFrame

	--==================================================
	-- INNER PANEL
	--==================================================

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(1, -6, 1, -6)
	panel.Position = UDim2.fromOffset(3, 3)
	panel.BackgroundColor3 = SETTINGS.Dark
	panel.BorderSizePixel = 0

	-- Prevents highlight from escaping
	panel.ClipsDescendants = true
	panel.Parent = orangeFrame

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 18)
	panelCorner.Parent = panel

	--==================================================
	-- PLAYER-SPECIFIC BACKGROUND
	--==================================================

	local backgroundImage
	local bannerAnimationController = nil

	local bannerFile = tagConfig.Banner
	local bannerAnimation = tagConfig.BannerAnimation
	local asset = nil

	if bannerFile then
		asset = downloadBanner(bannerFile)
	elseif tagConfig.BackgroundFile then
		-- Backwards-compatible local asset support.
		asset = loadLocalAsset(tagConfig.BackgroundFile)
	end

	panel:SetAttribute("DayBreakBannerLoaded", asset ~= nil)
	panel:SetAttribute("DayBreakBannerFile", tostring(bannerFile or ""))

	if asset then
			backgroundImage = Instance.new("ImageLabel")
			backgroundImage.Name = "CustomBackground"
			backgroundImage.Size = UDim2.fromScale(1, 1)
			backgroundImage.Position = UDim2.fromScale(0, 0)
			backgroundImage.BackgroundTransparency = 1
			backgroundImage.Image = asset
			backgroundImage.ImageTransparency = tagConfig.BackgroundTransparency or 0
			backgroundImage.ScaleType = Enum.ScaleType.Stretch
			backgroundImage.ImageColor3 = Color3.new(1, 1, 1)
			backgroundImage.Visible = true
			backgroundImage.ZIndex = 1
			backgroundImage.Parent = panel
			if bannerAnimation then
				if type(bannerAnimation.Frames) == "table" then
					bannerAnimationController = setupIndividualFrameAnimation(backgroundImage, bannerAnimation)
				else
					bannerAnimationController = setupSpriteAnimation(backgroundImage, bannerAnimation)
				end
			end

			local backgroundCorner = Instance.new("UICorner")
			backgroundCorner.CornerRadius = UDim.new(0, 18)
			backgroundCorner.Parent = backgroundImage
	end

	--==================================================
	-- PANEL GLOW
	--==================================================

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Name = "PanelChromeStroke"
	panelStroke.Thickness = 2
	panelStroke.Color = SETTINGS.OrangeBright
	panelStroke.Transparency = 0.15
	panelStroke.Parent = panel

	--==================================================
	-- NORMAL PLAYER BORDER
	--==================================================
	-- One normal UIStroke on the same panel used by the default border.
	-- Rainbow is simply a color gradient on this SAME stroke, so every
	-- border style shares the exact same size, position and corner shape.

	local borderGlow = Instance.new("UIStroke")
	borderGlow.Name = "PlayerBorderGlow"
	borderGlow.Thickness = 8
	borderGlow.Transparency = 0.72
	borderGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderGlow.ZIndex = 1
	borderGlow.Parent = panel

	local borderStroke = Instance.new("UIStroke")
	borderStroke.Name = "PlayerBorder"
	borderStroke.Thickness = 3
	borderStroke.Transparency = 0.02
	borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderStroke.ZIndex = 2
	borderStroke.Parent = panel

	local borderGradient = nil
	local borderGlowGradient = nil

	local function parseBorderColor(value)
		if typeof(value) == "Color3" then
			return value
		end
		if type(value) ~= "string" then
			return nil
		end
		local hex = value:gsub("#", "")
		if #hex == 6 and hex:match("^%x%x%x%x%x%x$") then
			local r = tonumber(hex:sub(1, 2), 16)
			local g = tonumber(hex:sub(3, 4), 16)
			local b = tonumber(hex:sub(5, 6), 16)
			return Color3.fromRGB(r, g, b)
		end
		return nil
	end

	local rainbowColors = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 127, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(127, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
	})

	local function configurePlayerBorder()
		local style = tostring(borderStyle or "WhiteGlow")
		local isRainbow = style:lower() == "rainbow"
		local isNone = style:lower() == "none"

		borderStroke.Enabled = not isNone
		borderGlow.Enabled = not isNone

		if isNone then
			panelStroke.Enabled = false
			return
		end

		if isRainbow then
			-- Rainbow is the SAME normal UIStroke geometry as every other border.
			-- Hide the decorative chrome stroke so it cannot cover the gradient.
			panelStroke.Enabled = false
			borderStroke.Color = Color3.new(1, 1, 1)
			borderGlow.Color = Color3.new(1, 1, 1)

			borderGradient = Instance.new("UIGradient")
			borderGradient.Name = "RainbowBorderGradient"
			borderGradient.Color = rainbowColors
			borderGradient.Rotation = 0
			borderGradient.TileMode = Enum.GradientTileMode.Repeat
			borderGradient.Parent = borderStroke

			borderGlowGradient = Instance.new("UIGradient")
			borderGlowGradient.Name = "RainbowBorderGlowGradient"
			borderGlowGradient.Color = rainbowColors
			borderGlowGradient.Rotation = 0
			borderGlowGradient.TileMode = Enum.GradientTileMode.Repeat
			borderGlowGradient.Parent = borderGlow
			return
		end

		panelStroke.Enabled = true

		local color = getPreloadedColor(style)
			or parseBorderColor(style)
			or parseBorderColor(tagConfig.BorderColor)
			or (style:lower() == "whiteglow" and SETTINGS.WhiteGlow)
			or (style:lower() == "neonpink" and SETTINGS.NeonPink)
			or SETTINGS.WhiteGlow

		borderStroke.Color = color
		borderGlow.Color = color
	end

	configurePlayerBorder()

	local function setRainbowBorderOffset(offset)
		if borderGradient then
			borderGradient.Offset = Vector2.new(offset, 0)
		end
		if borderGlowGradient then
			borderGlowGradient.Offset = Vector2.new(offset, 0)
		end
	end

	--==================================================
	-- STAR CIRCLE
	--==================================================

	local starCircle = Instance.new("Frame")
	starCircle.Size = UDim2.fromOffset(58, 58)
	starCircle.Position = UDim2.new(0, 8, 0.5, -29)
	starCircle.BackgroundColor3 = SETTINGS.DarkInner
	starCircle.BorderSizePixel = 0
	starCircle.ClipsDescendants = true
	starCircle.ZIndex = 2
	starCircle.Parent = panel

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = starCircle

	local circleStroke = Instance.new("UIStroke")
	circleStroke.Thickness = 2
	circleStroke.Color = SETTINGS.Orange
	circleStroke.Transparency = 0.1
	circleStroke.Parent = starCircle

	--==================================================
	-- CUSTOM LOGO / STAR FALLBACK
	--==================================================

	local customLogoAsset = nil
	local logoAnimationController = nil
	local logoAnimation = tagConfig.LogoAnimation
	if tagConfig.Logo then
		customLogoAsset = downloadLogo(tagConfig.Logo)
	end

	local starGlow = Instance.new("TextLabel")
	starGlow.BackgroundTransparency = 1
	starGlow.Size = UDim2.new(1, 20, 1, 20)
	starGlow.Position = UDim2.fromOffset(-10, -10)
	starGlow.Text = "★"
	starGlow.TextColor3 = SETTINGS.OrangeBright
	starGlow.TextTransparency = 0.65
	starGlow.TextScaled = true
	starGlow.Font = Enum.Font.GothamBlack
	starGlow.ZIndex = 2
	starGlow.Visible = customLogoAsset == nil
	starGlow.Parent = starCircle

	local star = Instance.new("TextLabel")
	star.BackgroundTransparency = 1
	star.Size = UDim2.fromScale(1, 1)
	star.Text = "★"
	star.TextColor3 = SETTINGS.White
	star.TextScaled = true
	star.Font = Enum.Font.GothamBlack
	star.TextStrokeColor3 = SETTINGS.Orange
	star.TextStrokeTransparency = 0.2
	star.ZIndex = 3
	star.Visible = customLogoAsset == nil
	star.Parent = starCircle

	local customLogo = nil
	local logoVisual = Instance.new("Frame")
	logoVisual.Name = "LogoVisual"
	logoVisual.Size = UDim2.new(1, -8, 1, -8)
	logoVisual.Position = UDim2.fromScale(0.5, 0.5)
	logoVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	logoVisual.BackgroundTransparency = 1
	logoVisual.BorderSizePixel = 0
	logoVisual.ZIndex = 3
	logoVisual.ClipsDescendants = false
	logoVisual.Parent = starCircle

	local logoVisualScale = Instance.new("UIScale")
	logoVisualScale.Scale = 1
	logoVisualScale.Parent = logoVisual

	--==================================================
	-- DEDICATED LOGO ROTATION ROOT
	--==================================================
	-- The old system rotated LogoVisual directly while other effects also
	-- touched that same object.  This root is the ONLY object used by the
	-- new logo rotation system.  All logo artwork lives underneath it.
	local logoRotationRoot = Instance.new("Frame")
	logoRotationRoot.Name = "LogoRotationRoot"
	logoRotationRoot.Size = UDim2.new(1, -4, 1, -4)
	logoRotationRoot.Position = UDim2.fromScale(0.5, 0.5)
	logoRotationRoot.AnchorPoint = Vector2.new(0.5, 0.5)
	logoRotationRoot.BackgroundTransparency = 1
	logoRotationRoot.BorderSizePixel = 0
	logoRotationRoot.ClipsDescendants = false
	logoRotationRoot.ZIndex = 3
	logoRotationRoot.Parent = starCircle

	logoVisual.Parent = logoRotationRoot

	if customLogoAsset and customLogoAsset ~= "" then
		customLogo = Instance.new("ImageLabel")
		customLogo.Name = "customLogo"
		customLogo.BackgroundTransparency = 1
		customLogo.BorderSizePixel = 0
		-- Keep uploaded logos comfortably inside the circular logo area.
		-- The logo itself is centered; the parent rotation root handles all rotation.
		-- Fill the circular logo area. The starCircle itself clips the
		-- artwork to a perfect circle, while ScaleType.Fit preserves the
		-- uploaded image's aspect ratio.
		customLogo.Size = UDim2.fromScale(1.06, 1.06)
		customLogo.Position = UDim2.fromScale(0.5, 0.5)
		customLogo.AnchorPoint = Vector2.new(0.5, 0.5)
		customLogo.Image = customLogoAsset
		customLogo.ScaleType = Enum.ScaleType.Fit
		customLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogo.ZIndex = 3
		customLogo.Visible = true
		customLogo.ClipsDescendants = true
		customLogo.Parent = logoVisual
		if logoAnimation then
			logoAnimationController = setupSpriteAnimation(customLogo, logoAnimation)
		end

		local customLogoCorner = Instance.new("UICorner")
		customLogoCorner.CornerRadius = UDim.new(1, 0)
		customLogoCorner.Parent = customLogo

	else
		starGlow.Parent = logoVisual
		star.Parent = logoVisual
	end


	--==================================================
	-- BANNER OVERLAYS REMOVED
	--==================================================
	-- No moving banner overlay is created. The banner uses only the
	-- procedural rainbow border below.


	--==================================================
	-- PLAYER NAME
	--==================================================

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromOffset(185, 30)
	nameLabel.Position = UDim2.fromOffset(78, 10)
	nameLabel.BackgroundTransparency = 1

	-- Custom name from PlayerTags, or Roblox DisplayName if none is set
	nameLabel.Text = getNametagName(player)

	-- NameColor supports Rainbow, named colors, and #RRGGBB values.
	-- Rainbow remains handled by the existing UIGradient below.
	local requestedNameColor = tostring(tagConfig.NameColor or "White")
	local requestedNameColorLower = requestedNameColor:lower()
	if requestedNameColorLower ~= "rainbow" then
		local customNameColor = getPreloadedColor(requestedNameColor)
			or parseBorderColor(requestedNameColor)
		nameLabel.TextColor3 = customNameColor or SETTINGS.White
	else
		nameLabel.TextColor3 = SETTINGS.White
	end
	nameLabel.TextSize = 19
	nameLabel.Font = SETTINGS.Font

	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center

	nameLabel.TextStrokeColor3 = SETTINGS.Orange
	nameLabel.TextStrokeTransparency = 0.15

	-- OWNER ONLY: moving rainbow across the player's name.
	-- UIGradient is applied directly to the TextLabel so the colors
	-- follow the letters instead of affecting the banner border.
	local ownerNameGradient = Instance.new("UIGradient")
	ownerNameGradient.Name = "RainbowNameGradient"
	ownerNameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 120, 0)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 255, 70)),
		ColorSequenceKeypoint.new(0.64, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(70, 100, 255)),
		ColorSequenceKeypoint.new(0.92, Color3.fromRGB(180, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 180)),
	})
	-- Keep the gradient on the actual text. Offset animates it without using
	-- the Rotation property.
	ownerNameGradient.Rotation = 0
	ownerNameGradient.Offset = Vector2.new(0, 0)
	ownerNameGradient.Enabled = tostring(tagConfig.NameColor or ""):lower() == "rainbow"
	ownerNameGradient.Parent = nameLabel

	nameLabel.ZIndex = 10
	nameLabel.Parent = panel

	--==================================================
	-- ROLE
	--==================================================

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.fromOffset(185, 20)
	subtitle.Position = UDim2.fromOffset(79, 39)
	subtitle.BackgroundTransparency = 1

	subtitle.Text = "★ " .. getRole(player)

	subtitle.TextColor3 = SETTINGS.OrangeBright
	subtitle.TextSize = 11
	subtitle.Font = Enum.Font.GothamBold

	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Center

	subtitle.TextStrokeColor3 = SETTINGS.Dark
	subtitle.TextStrokeTransparency = 0.4

	subtitle.ZIndex = 10
	subtitle.Parent = panel

	--==================================================
	-- MOVING HIGHLIGHT
	--==================================================

	local highlight = Instance.new("Frame")
	highlight.Size = UDim2.fromOffset(55, 2)
	highlight.Position = UDim2.fromOffset(-55, 7)
	highlight.BackgroundColor3 = SETTINGS.White
	highlight.BackgroundTransparency = 0.15
	highlight.BorderSizePixel = 0
	highlight.ZIndex = 5
	highlight.Parent = panel

	local highlightCorner = Instance.new("UICorner")
	highlightCorner.CornerRadius = UDim.new(1, 0)
	highlightCorner.Parent = highlight


	--==================================================
	-- CIRCLE-ONLY BILLBOARD
	--==================================================

	local logoBillboard = Instance.new("BillboardGui")
	logoBillboard.Name = "DayBreakCircleLogo"
	logoBillboard.Adornee = head
	logoBillboard.Size = UDim2.fromOffset(
		SETTINGS.CircleSize,
		SETTINGS.CircleSize
	)
	logoBillboard.StudsOffset = Vector3.new(
		0,
		SETTINGS.HeightOffset,
		0
	)
	logoBillboard.AlwaysOnTop = true
	logoBillboard.MaxDistance = SETTINGS.MaxDistance
	logoBillboard.ResetOnSpawn = false
	logoBillboard.Enabled = false
	logoBillboard:SetAttribute("DayBreakTargetUserId", player.UserId)
	logoBillboard:SetAttribute("DayBreakOwnerGeneration", __DAYBREAK_GENERATION)
	logoBillboard.Parent = PlayerGui

	--==================================================
	-- LOGO CIRCLE
	--==================================================

	local logoCircle = Instance.new("Frame")
	logoCircle.Size = UDim2.fromScale(1, 1)
	logoCircle.Position = UDim2.fromScale(0.5, 0.5)
	logoCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	logoCircle.BackgroundColor3 = SETTINGS.DarkInner
	logoCircle.BorderSizePixel = 0

	local logoCircleScale = Instance.new("UIScale")
	logoCircleScale.Scale = tonumber(SETTINGS.OverallTagScale) or 0.88
	logoCircleScale.Parent = logoCircle
	logoCircle.ClipsDescendants = true
	logoCircle.Parent = logoBillboard

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(1, 0)
	logoCorner.Parent = logoCircle

	local logoStroke = Instance.new("UIStroke")
	logoStroke.Thickness = 2
	logoStroke.Color = SETTINGS.Orange
	logoStroke.Transparency = 0.1
	logoStroke.Parent = logoCircle

	--==================================================
	-- CUSTOM LOGO / STAR FALLBACK
	--==================================================

	local logoGlow = Instance.new("TextLabel")
	logoGlow.BackgroundTransparency = 1
	logoGlow.Size = UDim2.new(1, 20, 1, 20)
	logoGlow.Position = UDim2.fromOffset(-10, -10)
	logoGlow.Text = "★"
	logoGlow.TextColor3 = SETTINGS.OrangeBright
	logoGlow.TextTransparency = 0.65
	logoGlow.TextScaled = true
	logoGlow.Font = Enum.Font.GothamBlack
	logoGlow.ZIndex = 1
	logoGlow.Visible = customLogoAsset == nil
	logoGlow.Parent = logoCircle

	local logoStar = Instance.new("TextLabel")
	logoStar.BackgroundTransparency = 1
	logoStar.Size = UDim2.fromScale(1, 1)
	logoStar.Text = "★"
	logoStar.TextColor3 = SETTINGS.White
	logoStar.TextScaled = true
	logoStar.Font = Enum.Font.GothamBlack
	logoStar.TextStrokeColor3 = SETTINGS.Orange
	logoStar.TextStrokeTransparency = 0.2
	logoStar.ZIndex = 2
	logoStar.Visible = customLogoAsset == nil
	logoStar.Parent = logoCircle

	local customLogoDistant = nil
	local logoAnimationDistantController = nil
	local distantLogoVisual = Instance.new("Frame")
	distantLogoVisual.Name = "LogoVisual"
	distantLogoVisual.Size = UDim2.new(1, -8, 1, -8)
	distantLogoVisual.Position = UDim2.fromScale(0.5, 0.5)
	distantLogoVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	distantLogoVisual.BackgroundTransparency = 1
	distantLogoVisual.BorderSizePixel = 0
	distantLogoVisual.ZIndex = 3
	distantLogoVisual.ClipsDescendants = false
	distantLogoVisual.Parent = logoCircle

	local distantLogoVisualScale = Instance.new("UIScale")
	distantLogoVisualScale.Scale = 1
	distantLogoVisualScale.Parent = distantLogoVisual

	local distantLogoRotationRoot = Instance.new("Frame")
	distantLogoRotationRoot.Name = "LogoRotationRoot"
	distantLogoRotationRoot.Size = UDim2.new(1, -4, 1, -4)
	distantLogoRotationRoot.Position = UDim2.fromScale(0.5, 0.5)
	distantLogoRotationRoot.AnchorPoint = Vector2.new(0.5, 0.5)
	distantLogoRotationRoot.BackgroundTransparency = 1
	distantLogoRotationRoot.BorderSizePixel = 0
	distantLogoRotationRoot.ClipsDescendants = false
	distantLogoRotationRoot.ZIndex = 3
	distantLogoRotationRoot.Parent = logoCircle

	distantLogoVisual.Parent = distantLogoRotationRoot

	if customLogoAsset and customLogoAsset ~= "" then
		customLogoDistant = Instance.new("ImageLabel")
		customLogoDistant.Name = "customLogoDistant"
		customLogoDistant.BackgroundTransparency = 1
		customLogoDistant.BorderSizePixel = 0
		customLogoDistant.Size = UDim2.fromScale(1.06, 1.06)
		customLogoDistant.Position = UDim2.fromScale(0.5, 0.5)
		customLogoDistant.AnchorPoint = Vector2.new(0.5, 0.5)
		customLogoDistant.Image = customLogoAsset
		customLogoDistant.ScaleType = Enum.ScaleType.Fit
		customLogoDistant.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogoDistant.ZIndex = 3
		customLogoDistant.Visible = true
		customLogoDistant.ClipsDescendants = true
		customLogoDistant.Parent = distantLogoVisual
		if logoAnimation then
			logoAnimationDistantController = setupSpriteAnimation(customLogoDistant, logoAnimation)
		end

		local customLogoDistantCorner = Instance.new("UICorner")
		customLogoDistantCorner.CornerRadius = UDim.new(1, 0)
		customLogoDistantCorner.Parent = customLogoDistant

	else
		logoGlow.Parent = distantLogoVisual
		logoStar.Parent = distantLogoVisual
	end


	--==================================================
	-- LOGO EFFECTS
	-- These effects never change the logo's base Position/Size.
	-- UIScale + a centered wrapper prevent the previous "off" behavior.
	--==================================================

	local logoEffectNames = {}
	for _, effectName in ipairs(SETTINGS.LogoEffects or {}) do
		logoEffectNames[effectName] = true
	end

	local function logoFxOn(name)
		-- HARD BLOCK legacy sweep and rotation effects. Logo rotation is now
		-- controlled exclusively by LogoRotationRoot.
		if name == "ChromeSweep" or name == "ShineSweep" or name == "Scanline"
			or name == "Rotation" or name == "CounterRotation"
			or name == "RingRotation" or name == "Tilt" then
			return false
		end
		return SETTINGS.LogoEffectsEnabled ~= false and logoEffectNames[name] == true
	end

	local logoFxSpeed = tonumber(SETTINGS.LogoEffectsSpeed) or 1

	-- Effect containers stay outside the logo image itself.
	local logoFx = Instance.new("Frame")
	logoFx.Name = "LogoEffects"
	logoFx.Size = UDim2.fromScale(1,1)
	logoFx.Position = UDim2.fromScale(0,0)
	logoFx.BackgroundTransparency = 1
	logoFx.BorderSizePixel = 0
	logoFx.ClipsDescendants = false
	logoFx.ZIndex = 5
	logoFx.Parent = starCircle

	local function fxFrame(name, z)
		local f=Instance.new("Frame")
		f.Name=name
		f.Size=UDim2.fromScale(1,1)
		f.Position=UDim2.fromScale(0,0)
		f.BackgroundTransparency=1
		f.BorderSizePixel=0
		f.ZIndex=z or 5
		f.Parent=logoFx
		return f
	end

	local fxGlow, fxRing, fxHalo, fxSweep, fxScan, fxRipple, fxShock
	local orbit, sparkles, bursts, arcs = {}, {}, {}, {}
	local trail = {}

	if logoFxOn("GlowPulse") or logoFxOn("OutlineGlow") then
		fxGlow=fxFrame("Glow",4)
		fxGlow.Size=UDim2.new(1,8,1,8)
		fxGlow.Position=UDim2.new(0,-4,0,-4)
		local s=Instance.new("UIStroke")
		s.Thickness=logoFxOn("OutlineGlow") and 2 or 5
		s.Transparency=0.35
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxGlow
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxGlow
	end

	if logoFxOn("OuterRing") or logoFxOn("RingRotation") or logoFxOn("CounterRotation") then
		fxRing=fxFrame("OuterRing",6)
		fxRing.Size=UDim2.new(1,10,1,10)
		fxRing.Position=UDim2.new(0,-5,0,-5)
		local s=Instance.new("UIStroke")
		s.Thickness=2
		s.Transparency=0.12
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxRing
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxRing
	end

	if logoFxOn("Halo") then
		fxHalo=fxFrame("Halo",3)
		fxHalo.Size=UDim2.new(1,22,1,22)
		fxHalo.Position=UDim2.new(0,-11,0,-11)
		local s=Instance.new("UIStroke")
		s.Thickness=6
		s.Transparency=0.65
		s.Color=SETTINGS.OrangeBright
		s.Parent=fxHalo
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(1,0)
		c.Parent=fxHalo
	end

	if false and logoFxOn("ShineSweep") then
		fxSweep=fxFrame("Sweep",8)
		fxSweep.Size=UDim2.new(0,6,1,0)
		fxSweep.Position=UDim2.fromScale(-0.15,0)
		fxSweep.Rotation=0
		fxSweep.BackgroundTransparency=0.82
		fxSweep.ClipsDescendants=true
		local g=Instance.new("UIGradient")
		g.Color=ColorSequence.new(
			ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1,Color3.new(1,1,1))
		)
		g.Parent=fxSweep
	end

	if false and logoFxOn("Scanline") then
		fxScan=fxFrame("Scanline",9)
		fxScan.Size=UDim2.new(1,0,0,2)
		fxScan.BackgroundColor3=Color3.new(1,1,1)
		fxScan.BackgroundTransparency=0.15
	end

	if logoFxOn("EnergyAura") then
		fxHalo=fxHalo or fxFrame("EnergyAura",3)
		fxHalo.Size=UDim2.new(1,10,1,10)
		fxHalo.Position=UDim2.new(0,-5,0,-5)
		fxHalo.BackgroundColor3=SETTINGS.OrangeBright
		fxHalo.BackgroundTransparency=0.92
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxHalo
	end

	if logoFxOn("Ripple") then
		fxRipple=fxFrame("Ripple",7)
		fxRipple.Size=UDim2.fromOffset(4,4)
		fxRipple.Position=UDim2.fromScale(0.5,0.5)
		local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=0.1; s.Color=SETTINGS.OrangeBright; s.Parent=fxRipple
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxRipple
	end

	if logoFxOn("Shockwave") then
		fxShock=fxFrame("Shockwave",7)
		fxShock.Size=UDim2.fromOffset(4,4)
		fxShock.Position=UDim2.fromScale(0.5,0.5)
		local s=Instance.new("UIStroke"); s.Thickness=2; s.Transparency=0.1; s.Color=SETTINGS.OrangeBright; s.Parent=fxShock
		local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=fxShock
	end

	if logoFxOn("OrbitingParticles") then
		for i=1,8 do
			local p=fxFrame("Orbit"..i,8)
			p.Size=UDim2.fromOffset(3,3)
			p.BackgroundColor3=SETTINGS.OrangeBright
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=p
			orbit[i]=p
		end
	end

	if logoFxOn("SparkleFlashes") then
		for i=1,5 do
			local s=fxFrame("Spark"..i,10)
			s.Size=UDim2.fromOffset(5,5)
			s.BackgroundColor3=Color3.new(1,1,1)
			s.BackgroundTransparency=1
			s.Rotation=45
			s.Position=UDim2.fromScale(0.1+i*0.17,0.15+((i*0.29)%0.65))
			sparkles[i]=s
		end
	end

	if logoFxOn("ParticleBurst") then
		for i=1,10 do
			local p=fxFrame("Burst"..i,9)
			p.Size=UDim2.fromOffset(3,3)
			p.BackgroundColor3=SETTINGS.OrangeBright
			p.BackgroundTransparency=1
			local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=p
			bursts[i]=p
		end
	end

	if logoFxOn("Trail") and customLogo then
		for i=1,3 do
			local t=Instance.new("ImageLabel")
			t.Name="Trail"..i
			t.BackgroundTransparency=1
			t.Size=UDim2.fromScale(0.92,0.92)
			t.Position=UDim2.fromScale(0.04,0.04)
			t.Image=customLogoAsset
			t.ScaleType=Enum.ScaleType.Fit
			t.ImageTransparency=1
			t.ImageColor3=SETTINGS.OrangeBright
			t.ZIndex=2
			t.Parent=logoFx
			trail[i]=t
		end
	end

	if logoFxOn("ElectricArcs") then
		for i=1,6 do
			local a=fxFrame("Arc"..i,10)
			a.Size=UDim2.fromOffset(12,2)
			a.BackgroundColor3=Color3.fromRGB(255,210,120)
			arcs[i]=a
		end
	end

	local logoFxTime=0
	local burstClock=0
	local sparkleClock=0

	--==================================================
	-- NEW LOGO ROTATION STATE
	--==================================================
	-- One controller, two isolated roots. No other logo effect writes to
	-- either Rotation property.
	local logoRotationAngle = 0


	--==================================================
	-- ANIMATION
	--==================================================

	local startTime = tick()

	local connection

	connection = RunService.RenderStepped:Connect(function(dt)

		if __DAYBREAK_GENERATION ~= _G.__DayBreakNametagGeneration then
			if connection then connection:Disconnect() end
			if NametagConnections[character] == connection then
				NametagConnections[character] = nil
				_G.__DayBreakNametagConnections[character] = nil
			end
			return
		end

		if not character or not character.Parent or not head or not head.Parent then
			if connection then connection:Disconnect() end
			if NametagConnections[character] == connection then
				NametagConnections[character] = nil
				_G.__DayBreakNametagConnections[character] = nil
			end
			return
		end

		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		local distance = (
			camera.CFrame.Position - head.Position
		).Magnitude

		local time = tick() - startTime

		--==================================================
		-- FULL TAG / LOGO SWITCH
		--==================================================

		if distance >= SETTINGS.CircleOnlyDistance then
			billboard.Enabled = false
			logoBillboard.Enabled = true
		else
			billboard.Enabled = true
			logoBillboard.Enabled = false
		end

		--==================================================
		-- FULL TAG SCALE
		--==================================================

		if SETTINGS.DistanceScaling then

			local scale =
				SETTINGS.NormalDistance /
				math.max(distance, 1)

			scale = math.clamp(
				scale,
				SETTINGS.MinScale,
				SETTINGS.MaxScale
			)

			billboard.Size = UDim2.fromOffset(
				SETTINGS.Width * scale,
				SETTINGS.Height * scale
			)

		end

		--==================================================
		-- CIRCLE SCALE
		--==================================================

		if SETTINGS.CircleDistanceScaling then

			local circleDistance = math.max(
				distance,
				SETTINGS.CircleShrinkStart
			)

			local shrinkRange =
				SETTINGS.MaxDistance -
				SETTINGS.CircleShrinkStart

			local progress =
				(circleDistance - SETTINGS.CircleShrinkStart)
				/ shrinkRange

			progress = math.clamp(progress, 0, 1)

			-- Smooth easing
			local smooth =
				progress *
				progress *
				(3 - 2 * progress)

			local circleScale =
				1 -
				(
					(1 - SETTINGS.CircleMinScale)
					* smooth
				)

			local size =
				SETTINGS.CircleSize *
				circleScale

			logoBillboard.Size =
				UDim2.fromOffset(size, size)

		end

		--==================================================
		-- CONTINUOUS RAINBOW BORDER ANIMATION
		-- Each segment gets a smoothly moving HSV hue.
		--==================================================

		if SETTINGS.RainbowBannerEnabled and tostring(borderStyle):lower() == "rainbow" then
			-- Smooth back-and-forth rainbow sweep.
			-- The phase travels left -> right, then right -> left,
			-- continuously repeating without jumping or rotating the border.
			local phase = (time * SETTINGS.RainbowBannerSpeed * 0.0009) % 2
		if phase > 1 then
			phase = 2 - phase
		end
		local offsetX = -0.25 + (phase * 0.50)
		if borderGradient then
			borderGradient.Offset = Vector2.new(offsetX, 0)
		end
		if borderGlowGradient then
			borderGlowGradient.Offset = Vector2.new(offsetX, 0)
		end
		end

		--==================================================
		-- UPLOADED GIF ANIMATION
		--==================================================
		-- Uploaded GIF sprite sheets are advanced by their own controllers.

		--==================================================
		-- GLOW
		--==================================================

		if SETTINGS.GlowEnabled then

			local glow =
				(math.sin(time * SETTINGS.GlowSpeed) + 1) / 2

			local transparency =
				0.15 +
				glow * SETTINGS.GlowAmount

			panelStroke.Transparency = transparency
			circleStroke.Transparency = transparency
			logoStroke.Transparency = transparency

			orangeFrame.BackgroundColor3 =
				SETTINGS.Orange:Lerp(
					SETTINGS.OrangeBright,
					glow * 0.25
				)

			starGlow.TextTransparency =
				0.55 + glow * 0.25

			logoGlow.TextTransparency =
				0.55 + glow * 0.25

		end

		--==================================================
		-- NAME PULSE
		--==================================================

		if SETTINGS.NamePulseEnabled then

			local pulse =
				(math.sin(time * SETTINGS.NamePulseSpeed) + 1) / 2

			nameLabel.TextTransparency =
				pulse * SETTINGS.NamePulseAmount

			nameLabel.TextStrokeTransparency =
				0.1 +
				pulse * SETTINGS.NamePulseAmount

		end

		--==================================================
		-- BOT-CONFIGURED RAINBOW NAME
		--==================================================

		if ownerNameGradient then
			if tostring(tagConfig.NameColor or ""):lower() == "rainbow" then
				ownerNameGradient.Enabled = true
				ownerNameGradient.Offset = Vector2.new(math.sin(time * SETTINGS.RainbowBannerSpeed * 0.01) * 0.35, 0)
			else
				ownerNameGradient.Enabled = false
				-- Keep the selected static color visible when Rainbow is disabled.
				local staticNameColor = getPreloadedColor(tagConfig.NameColor)
					or parseBorderColor(tagConfig.NameColor)
				nameLabel.TextColor3 = staticNameColor or SETTINGS.White
			end
		end

		--==================================================
		-- NEW DEDICATED LOGO ROTATION
		--==================================================
		-- Only the two rotation roots are rotated. The artwork and all other
		-- logo effects never receive a Rotation assignment.
		if SETTINGS.LogoRotationEnabled == true then
			--==================================================
			-- TRUE CONTINUOUS ROTATION
			--==================================================
			-- RenderStepped supplies the real frame delta. There is no timer
			-- multiplication, no modulo, no halfway reset, and no second
			-- animation source. The angle simply advances every rendered frame.
			local speed = tonumber(SETTINGS.LogoRotationSpeed) or 20
			logoRotationAngle = logoRotationAngle + (dt * speed)

			-- Intentionally DO NOT wrap the angle at 180 or 360 degrees.
			-- Roblox can display Rotation values beyond 360, so the animation
			-- remains one continuous increasing rotation.
			logoRotationRoot.Rotation = logoRotationAngle
			distantLogoRotationRoot.Rotation = logoRotationAngle
		end


		--==================================================
		-- FLOATING
		--==================================================

		if SETTINGS.FloatingEnabled then

			local float =
				math.sin(time * SETTINGS.FloatSpeed)
				* SETTINGS.FloatAmount

			billboard.StudsOffset =
				Vector3.new(
					0,
					SETTINGS.HeightOffset + float,
					0
				)

			logoBillboard.StudsOffset =
				Vector3.new(
					0,
					SETTINGS.HeightOffset + float,
					0
				)

		end


		--==================================================
		-- LOGO EFFECT ANIMATION
		--==================================================

		logoFxTime += (1/60) * logoFxSpeed
		local lt = logoFxTime

		-- Never alter base logo geometry. UIScale keeps the center fixed.
		local logoScale = 1
		if logoFxOn("Pulse") then
			logoScale *= 1 + math.sin(lt*2) * (SETTINGS.LogoPulseAmount or 0.035)
		end
		if logoFxOn("BreathingEffect") then
			logoScale *= 1 + math.sin(lt*1.15) * 0.018
		end
		logoVisualScale.Scale = logoScale
		distantLogoVisualScale.Scale = logoScale

		if logoFxOn("Floating") then
			local fy = math.sin(lt*1.3) * (SETTINGS.LogoFloatingAmount or 2)
			logoVisual.Position = UDim2.new(0.5,0,0.5,fy)
			distantLogoVisual.Position = UDim2.new(0.5,0,0.5,fy)
		else
			logoVisual.Position = UDim2.fromScale(0.5,0.5)
			distantLogoVisual.Position = UDim2.fromScale(0.5,0.5)
		end

		if logoFxOn("BrightnessPulse") and customLogo then
			customLogo.ImageTransparency = 0.05 + ((math.sin(lt*2)+1)*0.075)
		end
		if logoFxOn("BreathingEffect") and customLogo then
			customLogo.ImageTransparency = 0.04 + ((math.sin(lt*1.15)+1)*0.045)
		end

		if logoFxOn("ColorCycling") and customLogo then
			local h = (lt*0.055)%1
			customLogo.ImageColor3 = Color3.fromHSV(0.07+h*0.12,0.22,1)
			if customLogoDistant then
				customLogoDistant.ImageColor3 = customLogo.ImageColor3
			end
		elseif customLogo then
			customLogo.ImageColor3 = Color3.new(1,1,1)
			if customLogoDistant then customLogoDistant.ImageColor3 = Color3.new(1,1,1) end
		end

		if fxGlow then
			local s=fxGlow:FindFirstChildOfClass("UIStroke")
			if s then
				s.Transparency = logoFxOn("GlowPulse") and (0.15+((math.sin(lt*2)+1)*0.3)) or 0.35
			end
		end

		if fxSweep then
			fxSweep.Position = UDim2.fromScale(-0.3+((lt*0.4)%1.6),-0.15)
		end
		if fxScan then
			fxScan.Position = UDim2.fromScale(0,-0.1+((lt*0.55)%1.2))
		end
		if fxHalo and logoFxOn("EnergyAura") then
			local aura=1+(math.sin(lt*2)+1)*0.08
			fxHalo.Size=UDim2.new(1,aura*10,1,aura*10)
			fxHalo.Position=UDim2.new(0,-aura*5,0,-aura*5)
		end

		if fxRipple then
			local p=(lt%2.4)/2.4
			local d=4+p*65
			fxRipple.Size=UDim2.fromOffset(d,d)
			fxRipple.Position=UDim2.new(0.5,-d/2,0.5,-d/2)
			local s=fxRipple:FindFirstChildOfClass("UIStroke")
			if s then s.Transparency=p end
		end
		if fxShock then
			local p=((lt+1.2)%3)/3
			local d=4+p*80
			fxShock.Size=UDim2.fromOffset(d,d)
			fxShock.Position=UDim2.new(0.5,-d/2,0.5,-d/2)
			local s=fxShock:FindFirstChildOfClass("UIStroke")
			if s then s.Transparency=p end
		end

		for i,p in ipairs(orbit) do
			local a=lt*1.5+(i/#orbit)*math.pi*2
			local r=0.53
			p.Position=UDim2.new(0.5+math.cos(a)*r,-1.5,0.5+math.sin(a)*r,-1.5)
		end

		sparkleClock += 1/60
		if #sparkles>0 and sparkleClock>0.35 then
			sparkleClock=0
			for _,s in ipairs(sparkles) do s.BackgroundTransparency=1 end
			local pick=sparkles[math.random(1,#sparkles)]
			pick.BackgroundTransparency=0.1
		end

		burstClock += 1/60
		if #bursts>0 and burstClock>2.2 then
			burstClock=0
			for i,p in ipairs(bursts) do
				local a=(i/#bursts)*math.pi*2
				p:SetAttribute("BX",math.cos(a)*0.22)
				p:SetAttribute("BY",math.sin(a)*0.22)
				p:SetAttribute("BT",lt)
				p.BackgroundTransparency=0.1
			end
		end
		for _,p in ipairs(bursts) do
			local st=p:GetAttribute("BT")
			if st then
				local q=math.clamp((lt-st)/0.7,0,1)
				p.Position=UDim2.new(0.5+(p:GetAttribute("BX") or 0)*q,-1.5,0.5+(p:GetAttribute("BY") or 0)*q,-1.5)
				p.BackgroundTransparency=q
			end
		end

		for i,tr in ipairs(trail) do
			tr.ImageTransparency=0.82+i*0.04
		end

		for i,a in ipairs(arcs) do
			a.Visible=math.sin(lt*14+i*1.9)>0.35
		end

		if logoFxOn("Glitch") and math.random()<0.04 then
			logoVisual.Position=UDim2.new(0.5,math.random(-2,2),0.5,math.random(-2,2))
			distantLogoVisual.Position=logoVisual.Position
		end
	
		--==================================================
		-- MOVING HIGHLIGHT
		--==================================================

		local highlightProgress =
			(time * 0.4) % 1.5

		highlight.Position =
			UDim2.new(
				highlightProgress - 0.4,
				0,
				0,
				7
			)
	end)

	NametagConnections[character] = connection
	_G.__DayBreakNametagConnections[character] = connection
	CreatingNametags[character] = nil
end

--==================================================
-- SHARED REGISTRY FUNCTIONS
--==================================================

local function heartbeat()
	local result = registryRequest("POST", "/heartbeat", {
		userId = localPlayer.UserId,
		username = localPlayer.Name,
		displayName = localPlayer.DisplayName
	})

	if not result then
		registryOnline = false
		return false
	end

	local status = tonumber(result.StatusCode) or 0
	registryOnline = status >= 200 and status < 300
	return registryOnline
end

local function refreshActivePlayers()
	local result = registryRequest("GET", "/players")

	if not result then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local status = tonumber(result.StatusCode) or 0
	if status < 200 or status >= 300 then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(result.Body or "")
	end)

	if not ok or type(decoded) ~= "table" or type(decoded.players) ~= "table" then
		ActivePlayers = {
			[localPlayer.UserId] = true
		}
		registryOnline = false
		return false
	end

	local newActive = {}

	for _, entry in ipairs(decoded.players) do
		local userId = tonumber(entry.userId)
		if userId then
			newActive[userId] = true
		end
	end

	-- Always keep the local executor visible.
	newActive[localPlayer.UserId] = true

	ActivePlayers = newActive
	registryOnline = true

	return true
end

local function isActivePlayer(player)
	return player == localPlayer or ActivePlayers[player.UserId] == true
end

-- Visibility rules:
-- 1. Players who have executed the script get their normal/default tag.
-- 2. A player with a GitHub custom tag is also visible, even if the shared
--    registry is temporarily slow or missed that player's heartbeat.
-- 3. Players who have neither executed nor have a custom GitHub entry stay hidden.
-- This makes custom tags reliable across clients without making every player visible.
local function hasCustomTagConfig(player)
	if not player then
		return false
	end

	local userIdKey = tostring(player.UserId)
	local usernameKey = tostring(player.Name)

	return type(SETTINGS.PlayerTags[userIdKey]) == "table"
		or type(SETTINGS.PlayerTags[player.UserId]) == "table"
		or type(SETTINGS.PlayerTags[usernameKey]) == "table"
end

local function shouldShowNametag(player)
	return isActivePlayer(player) or hasCustomTagConfig(player)
end

local function hasNametagForCharacter(character)
	if not character then
		return false
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return false
	end

	-- Nametag BillboardGuis live in PlayerGui, so checking
	-- character:FindFirstChild() cannot detect an existing tag.
	for _, child in ipairs(PlayerGui:GetChildren()) do
		if child:IsA("BillboardGui") and child.Adornee == head then
			local name = tostring(child.Name)
			if name == "CustomDayBreakNametag"
				or name == "DayBreakNametag"
				or name == "DayBreakNameTag"
				or name == "DayBreakCircleLogo"
				or name == "DayBreakLogo" then
				return true
			end
		end
	end

	return false
end

local function syncNametags()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character

		if character then
			-- The local player's tag is permanent for this script run.
			-- Registry polling must never remove or rebuild it every few seconds.
			if player == localPlayer then
				if not hasNametagForCharacter(character) then
					task.spawn(function()
						if __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration then
							createNametag(player, character)
						end
					end)
				end
			elseif shouldShowNametag(player) then
				if not hasNametagForCharacter(character) then
					task.spawn(function()
						if __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration then
							createNametag(player, character)
						end
					end)
				end
			else
				removeNametag(character)
			end
		end
	end
end

--==================================================
-- REMOTE CONFIG REFRESH
--==================================================
local function refreshNametagsFromRemoteConfig()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			removeNametag(character)
			if shouldShowNametag(player) then
				task.spawn(function()
					if __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration then
						createNametag(player, character)
					end
				end)
			end
		end
	end
end

-- Load once immediately. If it fails, the hardcoded fallback above still works.
fetchRemoteConfig()

-- Keep the running nametags synchronized with the Discord/GitHub config.
task.spawn(function()
	while __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration do
		task.wait(REMOTE_CONFIG_POLL_SECONDS)
		if __DAYBREAK_GENERATION ~= _G.__DayBreakNametagGeneration then
			break
		end

		local ok, changed = fetchRemoteConfig()
		if ok and changed then
			refreshNametagsFromRemoteConfig()
		end
	end
end)

-- Start the local player in the registry before creating tags.
task.spawn(function()
	-- If no registry is configured, keep the script usable locally.
	if REGISTRY_URL == "" or REGISTRY_URL == "PASTE_YOUR_REGISTRY_URL_HERE" then
		ActivePlayers[localPlayer.UserId] = true
		syncNametags()
		return
	end

	while __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration do
		heartbeat()
		-- Give the registry a moment to persist this heartbeat before reading
		-- the shared player list. This reduces one-cycle visibility delays.
		task.wait(0.15)
		refreshActivePlayers()
		syncNametags()
		task.wait(REGISTRY_POLL_SECONDS)
	end
end)

--==================================================
-- PLAYER SETUP
--==================================================

local function setupPlayer(player)

	if not player then
		return
	end

	-- If this player was already initialized by an older setup call in this
	-- execution, disconnect those handlers before replacing them.
	local oldCharacterAdded = _G.__DayBreakNametagPlayerConnections[player]
	if oldCharacterAdded then
		pcall(function()
			if oldCharacterAdded.CharacterAdded then
				oldCharacterAdded.CharacterAdded:Disconnect()
			end
			if oldCharacterAdded.CharacterRemoving then
				oldCharacterAdded.CharacterRemoving:Disconnect()
			end
		end)
		_G.__DayBreakNametagPlayerConnections[player] = nil
	end

	local function setupCharacter(character)
		if __DAYBREAK_GENERATION ~= _G.__DayBreakNametagGeneration then
			return
		end

		-- Small delay lets the new Head exist before the tag is built.
		task.wait(0.5)

		if __DAYBREAK_GENERATION ~= _G.__DayBreakNametagGeneration then
			return
		end

		-- A newer respawn may have happened during the wait.
		if character ~= player.Character or not character or not character.Parent then
			return
		end

		if shouldShowNametag(player) then
			createNametag(player, character)
		end
	end

	local characterAddedConnection = player.CharacterAdded:Connect(setupCharacter)

	local characterRemovingConnection = player.CharacterRemoving:Connect(function(character)
		-- Destroy both the current tag and any orphaned tag from this player's
		-- previous character immediately when Roblox starts removing the old one.
		removeNametag(character)
		removeAllPlayerGuiNametags(player)
	end)

	_G.__DayBreakNametagPlayerConnections[player] = {
		CharacterAdded = characterAddedConnection,
		CharacterRemoving = characterRemovingConnection,
	}

	-- Already spawned
	if player.Character then
		task.spawn(function()
			setupCharacter(player.Character)
		end)
	end
end

--==================================================
-- EXISTING PLAYERS
--==================================================

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		setupPlayer(player)
	end)
end

--==================================================
-- NEW PLAYERS
--==================================================

local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
	if __DAYBREAK_GENERATION == _G.__DayBreakNametagGeneration then
		setupPlayer(player)
	end
end)
_G.__DayBreakNametagPlayerConnections.__PlayerAdded = playerAddedConnection
