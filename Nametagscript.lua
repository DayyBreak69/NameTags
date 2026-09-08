--==================================================
-- DAYBREAK MULTIPLAYER NAMETAG
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local SETTINGS = {
		LogoEffectsEnabled = true,
		LogoEffectsSpeed = 1,
		LogoEffects = {
			"Pulse",
			"GlowPulse",
			"Rotation",
			"CounterRotation",
			"ShineSweep",
			"ChromeSweep",
			"ColorCycling",
			"BrightnessPulse",
			"OutlineGlow",
			"OuterRing",
			"RingRotation",
			"OrbitingParticles",
			"SparkleFlashes",
			"EnergyAura",
			"Ripple",
			"BreathingEffect",
			"Floating",
			"Tilt",
			"Glitch",
			"ChromaticSplit",
			"Scanline",
			"ParticleBurst",
			"Trail",
			"ElectricArcs",
			"Halo",
			"Shockwave",
		},

	-- Display
	Font = Enum.Font.GothamBold,
	DefaultRole = "MEMBER",

	-- Roles
	-- Change usernames here
	Roles = {
		["DayyBreak66"] = "OWNER",
	},

	-- Player-specific tags
	-- Banners are hosted in the GitHub /banners folder.
	-- Use Roblox UserIds when possible so tags stay tied to the correct person.
	-- Banner is ONLY the filename, for example: "DayyBreak66.png"
	-- DisplayName is optional. If omitted, the player's normal Roblox DisplayName is used.
	PlayerTags = {
		-- Recommended: use UserId
		-- [123456789] = {
		--	Role = "FRIEND",
		--	Banner = "Friend1.png",
		--	BackgroundTransparency = 0.05,
		-- },

		["DayyBreak66"] = {
			Role = "OWNER",
			DisplayName = "DayBreak",
			Banner = "Daybreak.png",

			Logo = "Catlogo.png",


			-- Overlay system: change ONLY Type to select an effect.
			-- Available: ChromeSweep, GlassSweep, Holographic, Iridescent,
			-- DiamondShine, Gloss, MetallicFlow, RainbowFlow, RainbowPulse,
			-- NeonRainbow, Aurora, Prism, ColorShift, Fire, Ice, Electric,
			-- Lava, Toxic, ShadowFlame, EnergyPulse, Scanline, Glitch, Cyber,
			-- Static, SpeedLines, LaserSweep, Galaxy, Cosmic, Void, Starlight,
			-- Sunset, Ocean.
			Overlay = {
				Enabled = true,
				Type = "ChromeSweep",
				Speed = 1.2,
				Opacity = 0.55,
				Glow = true,
			},

			BackgroundTransparency = 0.05,
		},
		["xOmqhayleealt"] = {
			Role = "Admin",
			DisplayName = "Haylee",
			Banner = "Haylee.png",
			BackgroundTransparency = 0.05,
		},

		["Chloeeafm"] = {
			Role = "Admin",
			DisplayName = "Owned By Nigger",
			Banner = "Chloe123.png",
			BackgroundTransparency = 0.05,
		},
		["Gummaes"] = {
			Role = "Admin",
			DisplayName = "Nigger",
			Banner = "Gummies1.png",
			BackgroundTransparency = 0.05,
		},

		-- ["FriendUsername"] = {
		--	Role = "FRIEND",
		--	DisplayName = "Custom Name",
		--	Banner = "Friend1.png",
		--	BackgroundTransparency = 0.05,
		-- },
	},

	-- Colors
	Orange = Color3.fromRGB(255, 140, 30),
	OrangeBright = Color3.fromRGB(255, 190, 70),

	Chrome = Color3.fromRGB(210, 210, 220),
	Dark = Color3.fromRGB(10, 9, 7),
	DarkInner = Color3.fromRGB(20, 16, 11),

	White = Color3.fromRGB(255, 255, 255),

	-- Main tag
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
	StarRotateSpeed = 20,
	LogoRotateEnabled = true,
	LogoRotateSpeed = 20,

	-- OWNER SPECIAL EFFECT
	OwnerPulseEnabled = true,
	OwnerPulseSpeed = 2.5,
	OwnerPulseAmount = 0.035,
	OwnerRingEnabled = true,
	OwnerRingRotateSpeed = 45,

	-- OWNER RAINBOW NAME
	OwnerRainbowNameEnabled = true,
	OwnerRainbowNameSpeed = 45,

	-- CLICKABLE FRIEND TAGS
	ClickableFriendTagsEnabled = true,

	-- RAINBOW BANNER BORDER
	RainbowBannerEnabled = true,
	RainbowBannerSpeed = 70, -- smooth continuous movement
	RainbowBannerThickness = 3,
	RainbowBannerGlowThickness = 6,
	RainbowBannerOuterGlowThickness = 10,

	-- Floating
	FloatingEnabled = true,
	FloatSpeed = 1.5,
	FloatAmount = 0.04,

	-- Maximum distance
	MaxDistance = 500,
}

--==================================================
-- SHARED REGISTRY
--==================================================

local REGISTRY_URL = "https://daybreak-nametag-registry.terranjones870.workers.dev"
local REGISTRY_POLL_SECONDS = 5

local ActivePlayers = {}
local registryOnline = false

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

	warn("[DayBreak] Could not load local asset:", path)
	return nil
end

local function downloadBanner(filename)
	if not filename or filename == "" then
		return nil
	end

	if not getAsset then
		warn("[DayBreak] Executor does not support getcustomasset/getsynasset.")
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")

	-- Fresh local filename prevents the executor from reusing an older banner.
	local localPath =
		BANNER_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. BANNER_SESSION .. ".png"

	if not writefile then
		warn("[DayBreak] Executor does not support writefile.")
		return nil
	end

	if makefolder then
		pcall(makefolder, "DayBreak")
		pcall(makefolder, BANNER_FOLDER)
	end

	local url = BANNER_BASE_URL .. safeName
	local body = nil

	-- First try game:HttpGet. Do not inspect the binary contents here;
	-- valid PNG binary data can be represented differently by executors.
	local okHttp, httpBody = pcall(function()
		return game:HttpGet(url)
	end)

	if okHttp and type(httpBody) == "string" and #httpBody > 0 then
		body = httpBody
	end

	-- Fallback to executor HTTP request.
	if not body then
		local result = httpRequest({
			Url = url,
			Method = "GET",
		})

		if result and tonumber(result.StatusCode) == 200 and type(result.Body) == "string" then
			body = result.Body
		end
	end

	if not body then
		warn("[DayBreak] Failed to download banner:", safeName)
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		warn("[DayBreak] Failed to save banner:", localPath)
		return nil
	end

	AssetCache[localPath] = nil

	local asset = loadLocalAsset(localPath)

	if not asset then
		warn("[DayBreak] Downloaded banner but could not load asset:", safeName)
		return nil
	end

	return asset
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
		warn("[DayBreak] Executor does not support getcustomasset/getsynasset.")
		return nil
	end

	local safeName = tostring(filename):gsub("[^%w%._%-]", "_")
	local localPath =
		LOGO_FOLDER .. "/" ..
		safeName:gsub("%.[Pp][Nn][Gg]$", "") .. "_" .. LOGO_SESSION .. ".png"

	if not writefile then
		warn("[DayBreak] Executor does not support writefile.")
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
		warn("[DayBreak] Failed to download logo:", safeName)
		warn("[DayBreak] Tried CDN and GitHub Raw:", safeName)
		return nil
	end

	local okWrite = pcall(function()
		writefile(localPath, body)
	end)

	if not okWrite then
		warn("[DayBreak] Failed to save logo:", localPath)
		return nil
	end

	AssetCache[localPath] = nil
	local asset = loadLocalAsset(localPath)

	if not asset then
		warn("[DayBreak] Downloaded logo but could not load asset:", safeName)
		warn("[DayBreak] Source:", successfulUrl or "unknown")
		return nil
	end

	return asset
end

local function getTagConfig(player)
	return SETTINGS.PlayerTags[player.UserId]
		or SETTINGS.PlayerTags[player.Name]
		or {}
end

local function isClickableFriend(player)
	-- Only configured non-local players are treated as clickable friends.
	-- Your own nametag is never clickable.
	if player == localPlayer then
		return false
	end

	return SETTINGS.ClickableFriendTagsEnabled
		and (SETTINGS.PlayerTags[player.UserId] ~= nil
			or SETTINGS.PlayerTags[player.Name] ~= nil)
end

local function teleportToPlayerInstantly(targetPlayer)
	if not targetPlayer or targetPlayer == localPlayer then
		return
	end

	local myCharacter = localPlayer.Character
	local targetCharacter = targetPlayer.Character

	if not myCharacter or not targetCharacter then
		return
	end

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end

	-- Option A: instant teleport directly to their exact position.
	myCharacter:PivotTo(targetRoot.CFrame)
end

--==================================================
-- CUSTOM DISPLAY NAME
--==================================================

local function getNametagName(player)
	local config = getTagConfig(player)
	return config.DisplayName or player.DisplayName
end

--==================================================
-- ROLE
--==================================================

local function getRole(player)
	local config = getTagConfig(player)
	return config.Role or SETTINGS.Roles[player.Name] or SETTINGS.DefaultRole
end

--==================================================
-- REMOVE OLD TAG
--==================================================

local function removeNametag(character)

	if not character then
		return
	end

	local oldTag = character:FindFirstChild("CustomDayBreakNametag")
	if oldTag then
		oldTag:Destroy()
	end

	local oldLogo = character:FindFirstChild("DayBreakCircleLogo")
	if oldLogo then
		oldLogo:Destroy()
	end
end

--==================================================
-- CREATE NAMETAG
--==================================================

local function createNametag(player, character)

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		head = character:WaitForChild("Head", 5)
	end

	if not head then
		return
	end

	removeNametag(character)

	--==================================================
	-- MAIN BILLBOARD
	--==================================================

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomDayBreakNametag"
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
	billboard.Parent = character

	--==================================================
	-- OUTER CHROME
	--==================================================

	local outer = Instance.new("Frame")
	outer.Size = UDim2.fromScale(1, 1)
	outer.BackgroundColor3 = SETTINGS.Chrome
	outer.BorderSizePixel = 0
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

	local tagConfig = getTagConfig(player)
	local backgroundImage

	local bannerFile = tagConfig.Banner
	local asset = nil

	if bannerFile then
		asset = downloadBanner(bannerFile)
	elseif tagConfig.BackgroundFile then
		-- Backwards-compatible local asset support.
		asset = loadLocalAsset(tagConfig.BackgroundFile)
	end

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

			local backgroundCorner = Instance.new("UICorner")
			backgroundCorner.CornerRadius = UDim.new(0, 18)
			backgroundCorner.Parent = backgroundImage
	else
		warn("[DayBreak] No banner asset loaded for", player.Name, "filename:", tostring(bannerFile))
	end

	--==================================================
	-- PANEL GLOW
	--==================================================

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Thickness = 2
	panelStroke.Color = SETTINGS.OrangeBright
	panelStroke.Transparency = 0.15
	panelStroke.Parent = panel

	--==================================================
	-- PROCEDURAL RAINBOW BORDER AROUND THE OUTSIDE
	-- Uses small rounded segments instead of UIGradient-on-UIStroke.
	-- This is intentionally more compatible with clients/executors that
	-- do not render gradient strokes correctly.
	--==================================================

	local rainbowContainer = Instance.new("Frame")
	rainbowContainer.Name = "RainbowBannerBorder"
	rainbowContainer.BackgroundTransparency = 1
	rainbowContainer.BorderSizePixel = 0
	rainbowContainer.Size = UDim2.fromScale(1, 1)
	rainbowContainer.Position = UDim2.fromScale(0, 0)
	rainbowContainer.ClipsDescendants = false
	rainbowContainer.ZIndex = 50
	rainbowContainer.Parent = billboard

	local rainbowSegments = {}
	local RAINBOW_SEGMENT_COUNT = 61
	local RAINBOW_THICKNESS = SETTINGS.RainbowBannerThickness
	local RAINBOW_RADIUS = 20

	for i = 1, RAINBOW_SEGMENT_COUNT do
		local segment = Instance.new("Frame")
		segment.Name = "RainbowSegment" .. i
		segment.BackgroundColor3 = Color3.fromHSV((i - 1) / RAINBOW_SEGMENT_COUNT, 1, 1)
		segment.BorderSizePixel = 0
		segment.AnchorPoint = Vector2.new(0.5, 0.5)
		segment.ZIndex = 50
		segment.Parent = rainbowContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = segment

		local glow = Instance.new("UIStroke")
		glow.Name = "SoftGlow"
		glow.Thickness = 2
		glow.Transparency = 0.70
		glow.Color = segment.BackgroundColor3
		glow.ZIndex = 49
		glow.Parent = segment

		table.insert(rainbowSegments, {frame = segment, glow = glow})
	end

	local rainbowLastWidth = 0
	local rainbowLastHeight = 0

	local function buildRainbowBorder()
		local size = rainbowContainer.AbsoluteSize
		local w, h = size.X, size.Y
		if w <= 1 or h <= 1 then
			return
		end

		if math.abs(w - rainbowLastWidth) < 0.5 and math.abs(h - rainbowLastHeight) < 0.5 then
			return
		end
		rainbowLastWidth = w
		rainbowLastHeight = h

		local radius = math.min(RAINBOW_RADIUS, (h * 0.5) - 1, (w * 0.5) - 1)
		local points = {}

		local function addPoint(x, y)
			table.insert(points, Vector2.new(x, y))
		end

		-- Top edge
		for i = 0, 7 do
			local t = i / 7
			addPoint(radius + (w - 2 * radius) * t, 0)
		end
		-- Top-right corner
		for i = 1, 8 do
			local a = -math.pi / 2 + (math.pi / 2) * (i / 8)
			addPoint(w - radius + math.cos(a) * radius, radius + math.sin(a) * radius)
		end
		-- Right edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(w, radius + (h - 2 * radius) * t)
		end
		-- Bottom-right corner
		for i = 1, 8 do
			local a = 0 + (math.pi / 2) * (i / 8)
			addPoint(w - radius + math.cos(a) * radius, h - radius + math.sin(a) * radius)
		end
		-- Bottom edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(w - radius - (w - 2 * radius) * t, h)
		end
		-- Bottom-left corner
		for i = 1, 8 do
			local a = math.pi / 2 + (math.pi / 2) * (i / 8)
			addPoint(radius + math.cos(a) * radius, h - radius + math.sin(a) * radius)
		end
		-- Left edge
		for i = 1, 7 do
			local t = i / 7
			addPoint(0, h - radius - (h - 2 * radius) * t)
		end
		-- Top-left corner
		for i = 1, 8 do
			local a = math.pi + (math.pi / 2) * (i / 8)
			addPoint(radius + math.cos(a) * radius, radius + math.sin(a) * radius)
		end

		for i, data in ipairs(rainbowSegments) do
			local p1 = points[i]
			local p2 = points[(i % #points) + 1]
			if p1 and p2 then
				local delta = p2 - p1
				local length = delta.Magnitude + 2
				local midpoint = (p1 + p2) * 0.5
				data.frame.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
				data.frame.Size = UDim2.fromOffset(length, RAINBOW_THICKNESS)
				data.frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			end
		end
	end

	buildRainbowBorder()

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
	if customLogoAsset and customLogoAsset ~= "" then
		customLogo = Instance.new("ImageLabel")
		customLogo.Name = "customLogo"
		customLogo.BackgroundTransparency = 1
		customLogo.BorderSizePixel = 0
		customLogo.Size = UDim2.new(1, -8, 1, -8)
		customLogo.Position = UDim2.new(0, 4, 0, 4)
		customLogo.AnchorPoint = Vector2.new(0, 0)
		customLogo.Image = customLogoAsset
		customLogo.ScaleType = Enum.ScaleType.Fit
		customLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogo.ZIndex = 3
		customLogo.Visible = true
		customLogo.ClipsDescendants = true

		local customLogoCorner = Instance.new("UICorner")
		customLogoCorner.CornerRadius = UDim.new(1, 0)
		customLogoCorner.Parent = customLogo

		local customLogoAspect = Instance.new("UIAspectRatioConstraint")
		customLogoAspect.AspectRatio = 1
		customLogoAspect.Parent = customLogo

		customLogo.Parent = starCircle
	end

	--==================================================
	-- OWNER RING
	--==================================================

	local ownerRing = Instance.new("Frame")
	ownerRing.Name = "OwnerRing"
	ownerRing.BackgroundTransparency = 1
	ownerRing.BorderSizePixel = 0
	ownerRing.Size = UDim2.new(1, -2, 1, -2)
	ownerRing.Position = UDim2.new(0, 1, 0, 1)
	ownerRing.ZIndex = 4
	ownerRing.Parent = starCircle

	local ownerRingCorner = Instance.new("UICorner")
	ownerRingCorner.CornerRadius = UDim.new(1, 0)
	ownerRingCorner.Parent = ownerRing

	local ownerRingStroke = Instance.new("UIStroke")
	ownerRingStroke.Thickness = 2
	ownerRingStroke.Color = SETTINGS.OrangeBright
	ownerRingStroke.Transparency = 0.15
	ownerRingStroke.Parent = ownerRing

	local ownerBadge = Instance.new("TextLabel")
	ownerBadge.Name = "OwnerBadge"
	ownerBadge.BackgroundTransparency = 0
	ownerBadge.BackgroundColor3 = SETTINGS.OrangeBright
	ownerBadge.BorderSizePixel = 0
	ownerBadge.Size = UDim2.new(0, 52, 0, 16)
	ownerBadge.Position = UDim2.new(0.5, -26, 1, -3)
	ownerBadge.ZIndex = 6
	ownerBadge.Font = Enum.Font.GothamBold
	ownerBadge.Text = "OWNER"
	ownerBadge.TextColor3 = Color3.fromRGB(20, 12, 5)
	ownerBadge.TextSize = 10
	ownerBadge.Parent = starCircle

	local ownerBadgeCorner = Instance.new("UICorner")
	ownerBadgeCorner.CornerRadius = UDim.new(0, 8)
	ownerBadgeCorner.Parent = ownerBadge



	--==================================================
	-- FULL BANNER OVERLAY SYSTEM
	-- 32 selectable effects. Change ONLY Overlay.Type.
	--==================================================

	local overlayConfig = tagConfig.Overlay or {
		Enabled = true,
		Type = "ChromeSweep",
		Speed = 1.2,
		Opacity = 0.55,
		Glow = true,
	}

	local overlayFolder = Instance.new("Frame")
	overlayFolder.Name = "BannerOverlay"
	overlayFolder.BackgroundTransparency = 1
	overlayFolder.BorderSizePixel = 0
	overlayFolder.Size = UDim2.fromScale(1, 1)
	overlayFolder.ClipsDescendants = true
	overlayFolder.ZIndex = 4
	overlayFolder.Parent = panel

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 18)
	overlayCorner.Parent = overlayFolder

	local overlayObjects = {}
	local function newOverlayFrame(name)
		local f = Instance.new("Frame")
		f.Name = name
		f.BorderSizePixel = 0
		f.BackgroundTransparency = 1
		f.Parent = overlayFolder
		table.insert(overlayObjects, f)
		return f
	end

	local function gradient(obj, sequence, rotation)
		local g = Instance.new("UIGradient")
		g.Color = sequence
		g.Rotation = rotation or 0
		g.Parent = obj
		return g
	end

	local rainbow = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255,120,0)),
		ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.42, Color3.fromRGB(0,255,80)),
		ColorSequenceKeypoint.new(0.57, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.71, Color3.fromRGB(50,100,255)),
		ColorSequenceKeypoint.new(0.86, Color3.fromRGB(190,0,255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,170)),
	})

	local typeName = tostring(overlayConfig.Type or "ChromeSweep")
	local speed = tonumber(overlayConfig.Speed) or 1.2
	local alpha = math.clamp(tonumber(overlayConfig.Opacity) or 0.55, 0, 1)

	-- Base overlay layer.
	local baseOverlay = newOverlayFrame("Base")
	baseOverlay.Size = UDim2.fromScale(1,1)
	baseOverlay.BackgroundTransparency = 1 - alpha

	-- Create a moving horizontal strip helper.
	local function addSweep(name, width, height, colorSeq, z)
		local f = newOverlayFrame(name)
		f.Size = UDim2.fromOffset(width, height)
		f.Position = UDim2.fromScale(-0.4, 0)
		f.BackgroundTransparency = 0.25
		f.ZIndex = z or 5
		gradient(f, colorSeq, 0)
		return f
	end

	local seqWhite = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
	})

	local seqChrome = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,80)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130,130,145)),
		ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50,50,60)),
	})

	-- Each branch creates only the primitives needed for that effect.
	if typeName == "ChromeSweep" then
		local f = addSweep("Chrome", 90, 110, seqChrome, 5)
		f.Rotation = 12
	elseif typeName == "GlassSweep" then
		local f = addSweep("Glass", 65, 110, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(180,220,255)),
			ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170,200,255)),
		}), 5)
		f.BackgroundTransparency = 0.65
		f.Rotation = 10
	elseif typeName == "Holographic" then
		local f = newOverlayFrame("Hologram")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.45
		f.ZIndex = 5
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,80,220)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(80,180,255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(180,80,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,80,220)),
		}), 0)
	elseif typeName == "Iridescent" then
		local f = newOverlayFrame("Iridescent")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.55
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,190,230)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180,230,255)),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220,190,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,240,190)),
		}), 0)
	elseif typeName == "DiamondShine" then
		local f = addSweep("Diamond", 25, 110, seqWhite, 6)
		f.Rotation = 15
	elseif typeName == "Gloss" then
		local f = addSweep("Gloss", 38, 110, seqWhite, 5)
		f.BackgroundTransparency = 0.5
	elseif typeName == "MetallicFlow" then
		local f = newOverlayFrame("Metallic")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.35
		gradient(f, seqChrome, 0)
	elseif typeName == "RainbowFlow" or typeName == "NeonRainbow" or typeName == "RainbowPulse" then
		local f = newOverlayFrame("Rainbow")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 1 - alpha
		gradient(f, rainbow, 0)
		if typeName == "NeonRainbow" then
			f.BackgroundTransparency = 0.35
		end
	elseif typeName == "Aurora" then
		local f = newOverlayFrame("Aurora")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.4
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20,255,150)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40,150,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(190,60,255)),
		}), 0)
	elseif typeName == "Prism" then
		for i = 1, 4 do
			local f = addSweep("Prism"..i, 10, 110, rainbow, 5+i)
			f.Position = UDim2.fromScale(-0.2 - i*0.18, 0)
			f.Rotation = 12
		end
	elseif typeName == "ColorShift" then
		local f = newOverlayFrame("ColorShift")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.5
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,70,100)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70,150,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170,70,255)),
		}), 0)
	elseif typeName == "Fire" or typeName == "Lava" then
		local f = newOverlayFrame(typeName)
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = typeName == "Fire" and 0.4 or 0.5
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120,0,0)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255,40,0)),
			ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255,180,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120,0,0)),
		}), 90)
	elseif typeName == "Ice" then
		local f = newOverlayFrame("Ice")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.48
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(50,130,255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220,255,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40,190,255)),
		}), 0)
	elseif typeName == "Electric" then
		for i = 1, 3 do
			local f = addSweep("Electric"..i, 8, 110, ColorSequence.new(Color3.fromRGB(80,120,255), Color3.fromRGB(220,100,255)), 6)
			f.Rotation = 20 + i*7
		end
	elseif typeName == "Toxic" then
		local f = newOverlayFrame("Toxic")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.48
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20,80,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,255,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30,160,20)),
		}), 0)
	elseif typeName == "ShadowFlame" then
		local f = newOverlayFrame("ShadowFlame")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.42
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20,0,30)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(100,0,100)),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180,30,80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15,0,25)),
		}), 90)
	elseif typeName == "EnergyPulse" then
		local f = addSweep("Energy", 70, 110, seqWhite, 6)
		f.BackgroundTransparency = 0.45
	elseif typeName == "Scanline" then
		local f = newOverlayFrame("Scanline")
		f.Size = UDim2.fromOffset(4,110)
		f.BackgroundColor3 = Color3.fromRGB(0,220,255)
		f.BackgroundTransparency = 0.15
		f.ZIndex = 7
	elseif typeName == "Glitch" then
		for i = 1, 3 do
			local f = newOverlayFrame("Glitch"..i)
			f.Size = UDim2.fromScale(1,0.12)
			f.Position = UDim2.fromScale(0,0.15*i)
			f.BackgroundColor3 = ({Color3.fromRGB(255,0,80),Color3.fromRGB(0,255,255),Color3.fromRGB(160,0,255)})[i]
			f.BackgroundTransparency = 0.55
			f.ZIndex = 7
		end
	elseif typeName == "Cyber" then
		local f = newOverlayFrame("Cyber")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.55
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,60,160)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220,0,255)),
		}), 0)
	elseif typeName == "Static" then
		for i = 1, 9 do
			local f = newOverlayFrame("Static"..i)
			f.Size = UDim2.fromScale(1,0.02)
			f.Position = UDim2.fromScale(0, i/10)
			f.BackgroundColor3 = Color3.new(1,1,1)
			f.BackgroundTransparency = 0.88
		end
	elseif typeName == "SpeedLines" then
		for i = 1, 7 do
			local f = addSweep("Speed"..i, 5, 110, seqWhite, 6)
			f.Position = UDim2.fromScale(-0.3 - i*0.2,0)
			f.Rotation = 10
			f.BackgroundTransparency = 0.65
		end
	elseif typeName == "LaserSweep" then
		local f = addSweep("Laser", 5, 110, ColorSequence.new(Color3.fromRGB(255,50,50),Color3.new(1,1,1),Color3.fromRGB(255,50,50)), 8)
		f.BackgroundTransparency = 0.1
	elseif typeName == "Galaxy" or typeName == "Cosmic" then
		local f = newOverlayFrame(typeName)
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.45
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20,0,70)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(80,20,180)),
			ColorSequenceKeypoint.new(0.65, Color3.fromRGB(30,70,180)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10,0,50)),
		}), 0)
		-- Cosmic gets extra star particles below.
	elseif typeName == "Void" then
		local f = newOverlayFrame("Void")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.3
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45,0,70)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
		}), 0)
	elseif typeName == "Starlight" then
		for i = 1, 7 do
			local f = newOverlayFrame("Star"..i)
			f.Size = UDim2.fromOffset(3,3)
			f.Position = UDim2.fromScale((i*0.137)%1, (i*0.271)%1)
			f.BackgroundColor3 = Color3.new(1,1,1)
			f.BackgroundTransparency = 0.25
			f.ZIndex = 7
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(1,0)
			c.Parent = f
		end
	elseif typeName == "Sunset" then
		local f = newOverlayFrame("Sunset")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.45
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,100,30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,70,150)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120,40,180)),
		}), 0)
	elseif typeName == "Ocean" then
		local f = newOverlayFrame("Ocean")
		f.Size = UDim2.fromScale(1,1)
		f.BackgroundTransparency = 0.45
		gradient(f, ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,70,160)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0,220,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,80,190)),
		}), 0)
	end

	if not overlayConfig.Enabled then
		overlayFolder.Visible = false
	end

	-- Overlay animation controller. This MUST live inside createNametag
	-- because overlayFolder/overlayObjects belong to this nametag.
	local overlayTime = math.random() * 100
	local overlayConnections
	overlayConnections = RunService.RenderStepped:Connect(function(dt)
		if not overlayFolder or not overlayFolder.Parent then
			overlayConnections:Disconnect()
			return
		end
		if not overlayConfig.Enabled then return end

		overlayTime += dt * speed
		local t = overlayTime

		for _, obj in ipairs(overlayObjects) do
			if obj and obj.Parent then
				local g = obj:FindFirstChildOfClass("UIGradient")
				if g then
					g.Rotation = (g.Rotation + dt * speed * 45) % 360
				end
			end
		end

		if typeName == "RainbowPulse" then
			overlayFolder.BackgroundTransparency = 0.55 + math.sin(t * 2) * 0.18
		elseif typeName == "EnergyPulse" then
			local f = overlayFolder:FindFirstChild("Energy")
			if f then f.Position = UDim2.fromScale(-0.4 + ((t * 0.55) % 1.4), 0) end
		elseif typeName == "Scanline" then
			local f = overlayFolder:FindFirstChild("Scanline")
			if f then f.Position = UDim2.fromScale(-0.02 + ((t * 0.65) % 1.04), 0) end
		elseif typeName == "LaserSweep" then
			local f = overlayFolder:FindFirstChild("Laser")
			if f then f.Position = UDim2.fromScale(-0.08 + ((t * 0.75) % 1.16), 0) end
		elseif typeName == "ChromeSweep" or typeName == "GlassSweep" or typeName == "DiamondShine" or typeName == "Gloss" then
			local name = typeName == "ChromeSweep" and "Chrome" or typeName == "GlassSweep" and "Glass" or typeName == "DiamondShine" and "Diamond" or "Gloss"
			local f = overlayFolder:FindFirstChild(name)
			if f then f.Position = UDim2.fromScale(-0.4 + ((t * 0.35) % 1.4), 0) end
		elseif typeName == "Prism" or typeName == "SpeedLines" then
			local prefix = typeName == "Prism" and "Prism" or "Speed"
			for i = 1, 7 do
				local f = overlayFolder:FindFirstChild(prefix..i)
				if f then f.Position = UDim2.fromScale(-0.5 + ((t * (0.25 + i*0.035)) % 1.8), 0) end
			end
		elseif typeName == "Electric" then
			for i = 1, 3 do
				local f = overlayFolder:FindFirstChild("Electric"..i)
				if f then f.Visible = math.sin(t * 12 + i * 2.1) > 0.15 end
			end
		elseif typeName == "Glitch" then
			for i = 1, 3 do
				local f = overlayFolder:FindFirstChild("Glitch"..i)
				if f then
					f.Position = UDim2.fromScale(math.sin(t*17+i)*0.03, 0.15*i + math.sin(t*23+i)*0.025)
					f.Visible = math.sin(t * 19 + i) > 0.55
				end
			end
		elseif typeName == "Static" then
			for i = 1, 9 do
				local f = overlayFolder:FindFirstChild("Static"..i)
				if f then f.Visible = math.random() > 0.18 end
			end
		elseif typeName == "Starlight" then
			for i = 1, 7 do
				local f = overlayFolder:FindFirstChild("Star"..i)
				if f then f.BackgroundTransparency = 0.15 + math.abs(math.sin(t * 2.5 + i)) * 0.75 end
			end
		end
	end)

	--==================================================
	-- FULL LOGO OVERLAY / FX SYSTEM
	-- 26 selectable logo effects.
	-- Effects are additive: enable/disable individual effects
	-- in SETTINGS.LogoEffects.
	--==================================================

	local logoEffectsEnabled = SETTINGS.LogoEffectsEnabled ~= false
	local logoFxSpeed = tonumber(SETTINGS.LogoEffectsSpeed) or 1
	local logoEffectNames = {}
	for _, effectName in ipairs(SETTINGS.LogoEffects or {}) do
		logoEffectNames[effectName] = true
	end

	local function logoFxOn(name)
		return logoEffectsEnabled and logoEffectNames[name] == true
	end

	local logoFxFolder = Instance.new("Folder")
	logoFxFolder.Name = "LogoEffects"
	logoFxFolder.Parent = starCircle

	local function makeFxFrame(name, z)
		local f = Instance.new("Frame")
		f.Name = name
		f.BackgroundTransparency = 1
		f.BorderSizePixel = 0
		f.Size = UDim2.fromScale(1,1)
		f.Position = UDim2.fromScale(0,0)
		f.ZIndex = z or 8
		f.Parent = logoFxFolder
		return f
	end

	local function addRound(f, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = f
		return c
	end

	local function addStroke(parent, thickness, transparency)
		local s = Instance.new("UIStroke")
		s.Thickness = thickness
		s.Transparency = transparency
		s.Parent = parent
		return s
	end

	local function addGradient(parent, seq, rotation)
		local g = Instance.new("UIGradient")
		g.Color = seq
		g.Rotation = rotation or 0
		g.Parent = parent
		return g
	end

	local logoFxObjects = {}
	local function track(obj)
		table.insert(logoFxObjects, obj)
		return obj
	end

	-- Main FX target is the custom logo when present, otherwise the normal
	-- logo image used by the nametag.
	local logoFxTarget = customLogo or logoStar or logoGlow

	-- Pulse / breathing / rotation / floating / tilt are applied directly.
	local logoBaseSize = logoFxTarget and logoFxTarget.Size
	local logoBasePosition = logoFxTarget and logoFxTarget.Position

	-- Glow pulse + outline glow.
	local logoGlowFx
	if logoFxTarget and (logoFxOn("GlowPulse") or logoFxOn("OutlineGlow")) then
		logoGlowFx = makeFxFrame("Glow", 7)
		logoGlowFx.Size = UDim2.new(1,10,1,10)
		logoGlowFx.Position = UDim2.new(0,-5,0,-5)
		logoGlowFx.BackgroundTransparency = 1
		logoGlowFx.BackgroundColor3 = Color3.fromRGB(255,150,45)
		local stroke = addStroke(logoGlowFx, logoFxOn("OutlineGlow") and 3 or 6, 0.25)
		stroke.Color = Color3.fromRGB(255,165,60)
		if logoFxOn("GlowPulse") then
			stroke.Transparency = 0.45
		end
		track(stroke)
	end

	-- Outer ring + independently rotating ring.
	local outerRing
	if logoFxTarget and (logoFxOn("OuterRing") or logoFxOn("RingRotation") or logoFxOn("CounterRotation")) then
		outerRing = makeFxFrame("OuterRing", 6)
		outerRing.Size = UDim2.new(1,16,1,16)
		outerRing.Position = UDim2.new(0,-8,0,-8)
		outerRing.BackgroundTransparency = 1
		local s = addStroke(outerRing, 2, 0.12)
		s.Color = Color3.fromRGB(255,145,40)
		track(s)
	end

	-- Halo: soft circular light.
	local halo
	if logoFxTarget and logoFxOn("Halo") then
		halo = makeFxFrame("Halo", 4)
		halo.Size = UDim2.new(1,22,1,22)
		halo.Position = UDim2.new(0,-11,0,-11)
		halo.BackgroundColor3 = Color3.fromRGB(255,170,70)
		halo.BackgroundTransparency = 0.88
		addRound(halo)
		local s = addStroke(halo, 5, 0.55)
		s.Color = Color3.fromRGB(255,180,80)
		track(s)
	end

	-- Shine / chrome sweep.
	local sweep
	if logoFxTarget and (logoFxOn("ShineSweep") or logoFxOn("ChromeSweep")) then
		sweep = makeFxFrame("ShineSweep", 10)
		sweep.Size = UDim2.fromScale(0.20,1.5)
		sweep.Position = UDim2.fromScale(-0.25,-0.25)
		sweep.Rotation = 12
		sweep.BackgroundTransparency = logoFxOn("ChromeSweep") and 0.15 or 0.30
		local seq = logoFxOn("ChromeSweep")
			and ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(80,80,90)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,135,45)),
			})
			or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
				ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
			})
		addGradient(sweep, seq, 0)
		track(sweep)
	end

	-- Scanline.
	local scanline
	if logoFxTarget and logoFxOn("Scanline") then
		scanline = makeFxFrame("Scanline", 11)
		scanline.Size = UDim2.new(1,0,0,2)
		scanline.Position = UDim2.fromScale(0,-0.1)
		scanline.BackgroundColor3 = Color3.new(1,1,1)
		scanline.BackgroundTransparency = 0.18
		track(scanline)
	end

	-- Energy aura / ripple / shockwave.
	local aura
	if logoFxTarget and logoFxOn("EnergyAura") then
		aura = makeFxFrame("EnergyAura", 3)
		aura.Size = UDim2.new(1,8,1,8)
		aura.Position = UDim2.new(0,-4,0,-4)
		aura.BackgroundColor3 = Color3.fromRGB(255,145,40)
		aura.BackgroundTransparency = 0.86
		addRound(aura)
	end

	local ripple
	if logoFxTarget and logoFxOn("Ripple") then
		ripple = makeFxFrame("Ripple", 5)
		ripple.Size = UDim2.new(0,4,0,4)
		ripple.Position = UDim2.fromScale(0.5,0.5)
		ripple.BackgroundTransparency = 1
		local s = addStroke(ripple, 2, 0.1)
		s.Color = Color3.fromRGB(255,165,60)
	end

	local shockwave
	if logoFxTarget and logoFxOn("Shockwave") then
		shockwave = makeFxFrame("Shockwave", 5)
		shockwave.Size = UDim2.new(0,3,0,3)
		shockwave.Position = UDim2.fromScale(0.5,0.5)
		shockwave.BackgroundTransparency = 1
		local s = addStroke(shockwave, 2, 0.0)
		s.Color = Color3.fromRGB(255,190,90)
	end

	-- Tiny orbiting particles.
	local orbitParticles = {}
	if logoFxTarget and logoFxOn("OrbitingParticles") then
		for i = 1, 8 do
			local p = makeFxFrame("OrbitParticle"..i, 9)
			p.Size = UDim2.fromOffset(3,3)
			p.BackgroundColor3 = Color3.fromRGB(255,170,60)
			p.BackgroundTransparency = 0.05
			addRound(p)
			orbitParticles[i] = p
		end
	end

	-- Sparkle flashes.
	local sparkles = {}
	if logoFxTarget and logoFxOn("SparkleFlashes") then
		for i = 1, 5 do
			local s = makeFxFrame("Sparkle"..i, 12)
			s.Size = UDim2.fromOffset(5,5)
			s.Position = UDim2.fromScale(0.15 + i*0.16, 0.15 + ((i*0.37)%0.7))
			s.BackgroundColor3 = Color3.new(1,1,1)
			s.BackgroundTransparency = 1
			s.Rotation = 45
			sparkles[i] = s
		end
	end

	-- Particle burst pool.
	local burstParticles = {}
	if logoFxTarget and logoFxOn("ParticleBurst") then
		for i = 1, 12 do
			local p = makeFxFrame("Burst"..i, 10)
			p.Size = UDim2.fromOffset(3,3)
			p.Position = UDim2.fromScale(0.5,0.5)
			p.BackgroundColor3 = Color3.fromRGB(255,170,60)
			p.BackgroundTransparency = 1
			addRound(p)
			burstParticles[i] = p
		end
	end

	-- Trail afterimages.
	local trailImages = {}
	if logoFxTarget and logoFxOn("Trail") and logoFxTarget:IsA("ImageLabel") then
		for i = 1, 3 do
			local tr = logoFxTarget:Clone()
			tr.Name = "Trail"..i
			tr.BackgroundTransparency = 1
			tr.ImageTransparency = 1
			tr.ZIndex = 5
			tr.Parent = logoFxFolder
			trailImages[i] = tr
		end
	end

	-- Electric arcs: short animated bars around the logo.
	local arcs = {}
	if logoFxTarget and logoFxOn("ElectricArcs") then
		for i = 1, 6 do
			local a = makeFxFrame("Arc"..i, 11)
			a.Size = UDim2.fromOffset(12,2)
			a.Position = UDim2.fromScale(0.5,0.5)
			a.BackgroundColor3 = Color3.fromRGB(255,190,80)
			a.BackgroundTransparency = 0.1
			a.Rotation = i * 60
			arcs[i] = a
		end
	end

	local rng = Random.new()
	local logoFxTime = rng:NextNumber(0,100)
	local lastBurst = -10
	local lastShock = -10
	local lastSpark = -10

	local function setLogoScale(scale)
		if not logoFxTarget or not logoBaseSize or not logoBasePosition then return end
		local xOffset = logoBaseSize.X.Offset * scale
		local yOffset = logoBaseSize.Y.Offset * scale
		local xCenter = logoBasePosition.X.Offset + logoBaseSize.X.Offset * 0.5
		local yCenter = logoBasePosition.Y.Offset + logoBaseSize.Y.Offset * 0.5
		logoFxTarget.Size = UDim2.new(
			logoBaseSize.X.Scale * scale,
			math.floor(xOffset),
			logoBaseSize.Y.Scale * scale,
			math.floor(yOffset)
		)
		logoFxTarget.Position = UDim2.new(
			logoBasePosition.X.Scale,
			math.floor(xCenter - xOffset * 0.5),
			logoBasePosition.Y.Scale,
			math.floor(yCenter - yOffset * 0.5)
		)
	end

	local logoFxConnection
	if logoFxTarget and logoFxTarget.Parent then
		logoFxConnection = RunService.RenderStepped:Connect(function(dt)
			if not logoFxTarget.Parent then
				logoFxConnection:Disconnect()
				return
			end

			logoFxTime += dt * logoFxSpeed
			local t = logoFxTime

			-- Pulse: smooth scale.
			local scale = 1
			if logoFxOn("Pulse") then
				scale *= 1 + math.sin(t * 2.0) * (SETTINGS.LogoPulseAmount or 0.035)
			end
			if logoFxOn("BreathingEffect") then
				scale *= 1 + math.sin(t * 1.15) * 0.018
			end
			setLogoScale(scale)

			-- Brightness / transparency pulse.
			if logoFxOn("BrightnessPulse") and logoFxTarget:IsA("ImageLabel") then
				logoFxTarget.ImageTransparency = 0.05 + (math.sin(t*2)+1)*0.075
			end
			if logoFxOn("BreathingEffect") and logoFxTarget:IsA("ImageLabel") then
				logoFxTarget.ImageTransparency = 0.04 + (math.sin(t*1.15)+1)*0.045
			end

			-- Rotation.
			if logoFxOn("Rotation") then
				logoFxTarget.Rotation = (t * (SETTINGS.LogoRotationSpeed or 18)) % 360
			elseif logoFxOn("Tilt") then
				logoFxTarget.Rotation = math.sin(t * 1.5) * (SETTINGS.LogoTiltAmount or 4)
			end

			-- Floating.
			if logoFxOn("Floating") and logoBasePosition then
				logoFxTarget.Position = UDim2.new(
					logoBasePosition.X.Scale,
					logoBasePosition.X.Offset,
					logoBasePosition.Y.Scale,
					logoBasePosition.Y.Offset + math.sin(t*1.3) * (SETTINGS.LogoFloatingAmount or 2)
				)
			elseif logoBasePosition then
				logoFxTarget.Position = logoBasePosition
			end

			-- Color cycling.
			if logoFxOn("ColorCycling") and logoFxTarget:IsA("ImageLabel") then
				local h = (t * 0.055) % 1
				logoFxTarget.ImageColor3 = Color3.fromHSV(0.07 + h*0.12, 0.25 + math.sin(t)*0.12, 1)
			end

			-- Glow pulse.
			if logoGlowFx then
				local stroke = logoGlowFx:FindFirstChildOfClass("UIStroke")
				if stroke then
					local pulse = logoFxOn("GlowPulse") and (0.2 + (math.sin(t*2)+1)*0.25) or 0.35
					stroke.Transparency = math.clamp(pulse,0.05,0.9)
				end
			end

			-- Counter/independent ring rotation.
			if outerRing then
				if logoFxOn("RingRotation") or logoFxOn("CounterRotation") then
					outerRing.Rotation = (t * 45) % 360
				end
			end

			-- Sweep.
			if sweep then
				sweep.Position = UDim2.fromScale(-0.3 + ((t*0.45)%1.6), -0.25)
			end

			-- Scanline.
			if scanline then
				scanline.Position = UDim2.fromScale(0, -0.1 + ((t*0.55)%1.2))
			end

			-- Aura.
			if aura then
				local a = 1 + (math.sin(t*2)+1)*0.10
				aura.Size = UDim2.new(1,a*8,1,a*8)
				aura.Position = UDim2.new(0,-a*4,0,-a*4)
				aura.BackgroundTransparency = 0.80 + (math.sin(t*2)+1)*0.07
			end

			-- Ripple and shockwave periodically expand.
			if ripple then
				local phase = t % 2.4
				local p = phase / 2.4
				ripple.Size = UDim2.new(0,4+p*70,0,4+p*70)
				ripple.Position = UDim2.new(0.5,-2-p*35,0.5,-2-p*35)
				local st = ripple:FindFirstChildOfClass("UIStroke")
				if st then st.Transparency = p end
			end
			if shockwave then
				local phase = (t + 1.2) % 3.0
				local p = phase / 3.0
				shockwave.Size = UDim2.new(0,3+p*85,0,3+p*85)
				shockwave.Position = UDim2.new(0.5,-1.5-p*42.5,0.5,-1.5-p*42.5)
				local st = shockwave:FindFirstChildOfClass("UIStroke")
				if st then st.Transparency = p end
			end

			-- Orbiting particles.
			for i,p in ipairs(orbitParticles) do
				local a = t*1.5 + (i/#orbitParticles)*math.pi*2
				local r = 0.5 + 0.08*math.sin(t*2+i)
				p.Position = UDim2.new(0.5 + math.cos(a)*r, -1.5, 0.5 + math.sin(a)*r, -1.5)
			end

			-- Sparkle flashes.
			if #sparkles > 0 and t - lastSpark > 0.28 then
				lastSpark = t
				for i,s in ipairs(sparkles) do
					s.BackgroundTransparency = rng:NextNumber(0.15,0.75)
				end
			end
			for i,s in ipairs(sparkles) do
				s.BackgroundTransparency = math.min(1, s.BackgroundTransparency + dt*2.2)
			end

			-- Particle burst.
			if #burstParticles > 0 and t - lastBurst > 2.5 then
				lastBurst = t
				for i,p in ipairs(burstParticles) do
					local a = (i/#burstParticles)*math.pi*2
					local r = rng:NextNumber(0.05,0.18)
					p:SetAttribute("BurstX", math.cos(a)*r)
					p:SetAttribute("BurstY", math.sin(a)*r)
					p:SetAttribute("BurstStart", t)
					p.BackgroundTransparency = 0.05
				end
			end
			for i,p in ipairs(burstParticles) do
				local start = p:GetAttribute("BurstStart")
				if start then
					local q = math.clamp((t-start)/0.8,0,1)
					local bx = p:GetAttribute("BurstX") or 0
					local by = p:GetAttribute("BurstY") or 0
					p.Position = UDim2.fromScale(0.5+bx*q,0.5+by*q)
					p.BackgroundTransparency = q
				end
			end

			-- Trail afterimages.
			for i,tr in ipairs(trailImages) do
				tr.ImageTransparency = 0.78 + i*0.06
				tr.Position = UDim2.new(
					logoFxTarget.Position.X.Scale,
					logoFxTarget.Position.X.Offset - i*2,
					logoFxTarget.Position.Y.Scale,
					logoFxTarget.Position.Y.Offset
				)
				tr.Rotation = logoFxTarget.Rotation - i*3
			end

			-- Electric arcs flicker.
			for i,a in ipairs(arcs) do
				a.Visible = math.sin(t*14+i*2.3) > 0.25
				a.Rotation = i*60 + math.sin(t*8+i)*12
				a.Position = UDim2.new(0.5 + math.cos(i)*0.35,-6,0.5 + math.sin(i)*0.35,-1)
			end

			-- Glitch + chromatic split: brief visual distortion.
			if logoFxOn("Glitch") and math.random() < dt*3.5 then
				logoFxTarget.Position = UDim2.new(
					logoBasePosition.X.Scale,
					logoBasePosition.X.Offset + rng:NextInteger(-2,2),
					logoBasePosition.Y.Scale,
					logoBasePosition.Y.Offset + rng:NextInteger(-2,2)
				)
			end

			if logoFxOn("ChromaticSplit") and logoFxTarget:IsA("ImageLabel") then
				logoFxTarget.ImageColor3 = Color3.fromRGB(
					255,
					200 + math.floor(math.sin(t*16)*30),
					150 + math.floor(math.sin(t*13)*40)
				)
			end
		end)
	end


	--==================================================
	-- PLAYER NAME
	--==================================================

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromOffset(185, 30)
	nameLabel.Position = UDim2.fromOffset(78, 10)
	nameLabel.BackgroundTransparency = 1

	-- Custom name from PlayerTags, or Roblox DisplayName if none is set
	nameLabel.Text = getNametagName(player)

	nameLabel.TextColor3 = SETTINGS.White
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
	ownerNameGradient.Name = "OwnerRainbowName"
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
	-- Keep the gradient on the actual text. Rotation is used instead of
	-- Offset so the full rainbow remains visible while it continuously moves.
	ownerNameGradient.Rotation = 0
	ownerNameGradient.Offset = Vector2.new(0, 0)
	ownerNameGradient.Enabled = (getRole(player) == "OWNER") and SETTINGS.OwnerRainbowNameEnabled
	ownerNameGradient.Parent = nameLabel

	nameLabel.ZIndex = 3
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

	subtitle.ZIndex = 2
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
	-- CLICKABLE FRIEND TAG
	--==================================================
	-- Invisible button over the full nametag.
	-- Your own tag is excluded by isClickableFriend().
	if isClickableFriend(player) then
		local friendClickButton = Instance.new("TextButton")
		friendClickButton.Name = "FriendTeleportButton"
		friendClickButton.Size = UDim2.fromScale(1, 1)
		friendClickButton.Position = UDim2.fromScale(0, 0)
		friendClickButton.BackgroundTransparency = 1
		friendClickButton.BorderSizePixel = 0
		friendClickButton.Text = ""
		friendClickButton.AutoButtonColor = false
		friendClickButton.Active = true
		friendClickButton.Selectable = false
		friendClickButton.ZIndex = 100
		friendClickButton.Parent = billboard

		friendClickButton.MouseButton1Click:Connect(function()
			teleportToPlayerInstantly(player)
		end)
	end

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
	logoBillboard.Parent = character

	-- Make the distant circular tag clickable too.
	if isClickableFriend(player) then
		local distantClickButton = Instance.new("TextButton")
		distantClickButton.Name = "FriendTeleportButton"
		distantClickButton.Size = UDim2.fromScale(1, 1)
		distantClickButton.Position = UDim2.fromScale(0, 0)
		distantClickButton.BackgroundTransparency = 1
		distantClickButton.BorderSizePixel = 0
		distantClickButton.Text = ""
		distantClickButton.AutoButtonColor = false
		distantClickButton.Active = true
		distantClickButton.Selectable = false
		distantClickButton.ZIndex = 100
		distantClickButton.Parent = logoBillboard

		distantClickButton.MouseButton1Click:Connect(function()
			teleportToPlayerInstantly(player)
		end)
	end

	--==================================================
	-- LOGO CIRCLE
	--==================================================

	local logoCircle = Instance.new("Frame")
	logoCircle.Size = UDim2.fromScale(1, 1)
	logoCircle.BackgroundColor3 = SETTINGS.DarkInner
	logoCircle.BorderSizePixel = 0
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
	if customLogoAsset and customLogoAsset ~= "" then
		customLogoDistant = Instance.new("ImageLabel")
		customLogoDistant.Name = "customLogoDistant"
		customLogoDistant.BackgroundTransparency = 1
		customLogoDistant.BorderSizePixel = 0
		customLogoDistant.Size = UDim2.new(1, -8, 1, -8)
		customLogoDistant.Position = UDim2.new(0, 4, 0, 4)
		customLogoDistant.AnchorPoint = Vector2.new(0, 0)
		customLogoDistant.Image = customLogoAsset
		customLogoDistant.ScaleType = Enum.ScaleType.Fit
		customLogoDistant.ImageColor3 = Color3.fromRGB(255, 255, 255)
		customLogoDistant.ZIndex = 3
		customLogoDistant.Visible = true
		customLogoDistant.ClipsDescendants = true

		local customLogoDistantCorner = Instance.new("UICorner")
		customLogoDistantCorner.CornerRadius = UDim.new(1, 0)
		customLogoDistantCorner.Parent = customLogoDistant

		local customLogoDistantAspect = Instance.new("UIAspectRatioConstraint")
		customLogoDistantAspect.AspectRatio = 1
		customLogoDistantAspect.Parent = customLogoDistant

		customLogoDistant.Parent = logoCircle
	end

	--==================================================
	-- OWNER DISTANT RING
	--==================================================

	local ownerRingDistant = Instance.new("Frame")
	ownerRingDistant.Name = "OwnerRingDistant"
	ownerRingDistant.BackgroundTransparency = 1
	ownerRingDistant.BorderSizePixel = 0
	ownerRingDistant.Size = UDim2.new(1, -2, 1, -2)
	ownerRingDistant.Position = UDim2.new(0, 1, 0, 1)
	ownerRingDistant.ZIndex = 4
	ownerRingDistant.Parent = logoCircle

	local ownerRingDistantCorner = Instance.new("UICorner")
	ownerRingDistantCorner.CornerRadius = UDim.new(1, 0)
	ownerRingDistantCorner.Parent = ownerRingDistant

	local ownerRingDistantStroke = Instance.new("UIStroke")
	ownerRingDistantStroke.Thickness = 2
	ownerRingDistantStroke.Color = SETTINGS.OrangeBright
	ownerRingDistantStroke.Transparency = 0.15
	ownerRingDistantStroke.Parent = ownerRingDistant


	--==================================================
	-- ANIMATION
	--==================================================

	local startTime = tick()

	local connection

	connection = RunService.RenderStepped:Connect(function()

		if not character.Parent or not head.Parent then
			connection:Disconnect()
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

		buildRainbowBorder()

		if SETTINGS.RainbowBannerEnabled then
			rainbowContainer.Visible = true
			local hueOffset = (time * SETTINGS.RainbowBannerSpeed / 360) % 1
			for i, data in ipairs(rainbowSegments) do
				local hue = ((i - 1) / RAINBOW_SEGMENT_COUNT + hueOffset) % 1
				local color = Color3.fromHSV(hue, 1, 1)
				data.frame.BackgroundColor3 = color
				data.glow.Color = color
			end
		else
			rainbowContainer.Visible = false
		end

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
		-- OWNER RAINBOW NAME
		--==================================================

		if ownerNameGradient then
			if getRole(player) == "OWNER" and SETTINGS.OwnerRainbowNameEnabled then
				ownerNameGradient.Enabled = true
				-- Rotate the rainbow through the letters continuously.
				ownerNameGradient.Rotation = (time * SETTINGS.OwnerRainbowNameSpeed) % 360
			else
				ownerNameGradient.Enabled = false
			end
		end

		--==================================================
		-- STAR ROTATION
		--==================================================

		if SETTINGS.StarEnabled then

			local rotation =
				(time * SETTINGS.StarRotateSpeed) % 360

			star.Rotation = rotation
			starGlow.Rotation = rotation
			if customLogo then
				customLogo.Rotation = rotation
			end

			logoStar.Rotation = rotation
			logoGlow.Rotation = rotation
			if customLogoDistant then
				customLogoDistant.Rotation = rotation
			end

		end

		--==================================================
		-- CATLOGO ROTATION
		--==================================================

		if SETTINGS.LogoRotateEnabled then
			local logoRotation = (time * SETTINGS.LogoRotateSpeed) % 360
			if customLogo then
				customLogo.Rotation = logoRotation
			end
			if customLogoDistant then
				customLogoDistant.Rotation = logoRotation
			end
		end

		--==================================================
		-- OWNER EFFECT
		--==================================================

		if SETTINGS.OwnerPulseEnabled then
			local pulse = (math.sin(time * SETTINGS.OwnerPulseSpeed) + 1) * 0.5
			local scale = 1 + (pulse * SETTINGS.OwnerPulseAmount)

			ownerRing.Size = UDim2.new(
				scale, -2,
				scale, -2
			)
			ownerRing.Position = UDim2.new(
				0.5, -(scale * starCircle.AbsoluteSize.X - 2) / 2,
				0.5, -(scale * starCircle.AbsoluteSize.Y - 2) / 2
			)

			ownerRingStroke.Transparency = 0.05 + (pulse * 0.35)
			ownerRingDistantStroke.Transparency = 0.05 + (pulse * 0.35)
		end

		if SETTINGS.OwnerRingEnabled then
			local ownerRotation = (time * SETTINGS.OwnerRingRotateSpeed) % 360
			ownerRing.Rotation = ownerRotation
			ownerRingDistant.Rotation = ownerRotation
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

-- Configured players always get a tag, even if they have never executed the script.
-- This lets you assign custom banners/roles to specific friends.
local function shouldShowNametag(player)
	return isActivePlayer(player)
		or SETTINGS.PlayerTags[player.UserId] ~= nil
		or SETTINGS.PlayerTags[player.Name] ~= nil
end

local function syncNametags()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character

		if character then
			if shouldShowNametag(player) then
				if not character:FindFirstChild("CustomDayBreakNametag") then
					task.spawn(function()
						createNametag(player, character)
					end)
				end
			else
				removeNametag(character)
			end
		end
	end
end

-- Start the local player in the registry before creating tags.
task.spawn(function()
	-- If no registry is configured, keep the script usable locally.
	if REGISTRY_URL == "" or REGISTRY_URL == "PASTE_YOUR_REGISTRY_URL_HERE" then
		ActivePlayers[localPlayer.UserId] = true
		syncNametags()
		return
	end

	while true do
		heartbeat()
		refreshActivePlayers()
		syncNametags()
		task.wait(REGISTRY_POLL_SECONDS)
	end
end)

--==================================================
-- PLAYER SETUP
--==================================================

local function setupPlayer(player)

	local function setupCharacter(character)

		task.wait(0.5)

		if character and character.Parent then
			if shouldShowNametag(player) then
				createNametag(player, character)
			end
		end
	end

	-- Already spawned
	if player.Character then
		task.spawn(function()
			setupCharacter(player.Character)
		end)
	end

	-- Respawn
	player.CharacterAdded:Connect(setupCharacter)
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

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
end)
