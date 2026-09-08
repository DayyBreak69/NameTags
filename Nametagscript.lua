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

			Overlay = {
				Enabled = true,
				Type = "ChromeSweep",
				Speed = 1.2,
				Glow = true,
				GlowStrength = 2,
				Rotation = 0,
				Pulse = true,
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

	-- RAINBOW BANNER BORDER
	RainbowBannerEnabled = true,
	RainbowBannerSpeed = 85, -- smooth rotation speed
	RainbowBannerThickness = 4,
	RainbowBannerGlowThickness = 8,
	RainbowBannerOuterGlowThickness = 12,

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
	-- SMOOTH ROTATING RAINBOW BORDER AROUND THE OUTSIDE
	-- Single rounded strokes give the corners a continuous, smooth curve.
	-- UIGradient is attached to each stroke and rotated continuously.
	--==================================================

	local rainbowColors = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.12, Color3.fromRGB(255, 120, 0)),
		ColorSequenceKeypoint.new(0.24, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.36, Color3.fromRGB(0, 255, 80)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 110, 255)),
		ColorSequenceKeypoint.new(0.72, Color3.fromRGB(150, 0, 255)),
		ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 220)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
	})

	local rainbowContainer = Instance.new("Frame")
	rainbowContainer.Name = "RainbowBannerBorder"
	rainbowContainer.BackgroundTransparency = 1
	rainbowContainer.BorderSizePixel = 0
	rainbowContainer.Size = UDim2.new(1, 12, 1, 12)
	rainbowContainer.Position = UDim2.fromOffset(-6, -6)
	rainbowContainer.ClipsDescendants = false
	rainbowContainer.ZIndex = 30
	rainbowContainer.Parent = billboard

	local rainbowLayers = {}

	local function makeRainbowStroke(name, thickness, transparency, zIndex)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Position = UDim2.fromScale(0, 0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ZIndex = zIndex
		frame.Parent = rainbowContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 18)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Name = "RainbowStroke"
		stroke.Thickness = thickness
		stroke.Transparency = transparency
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = frame

		local gradient = Instance.new("UIGradient")
		gradient.Name = "RainbowFlow"
		gradient.Color = rainbowColors
		gradient.Rotation = 0
		gradient.Parent = stroke

		table.insert(rainbowLayers, {frame = frame, stroke = stroke, gradient = gradient})
	end

	-- Thin, bright main line with subtle outer glow.
	makeRainbowStroke("RainbowMain", SETTINGS.RainbowBannerThickness, 0.02, 31)
	makeRainbowStroke("RainbowGlow", SETTINGS.RainbowBannerGlowThickness, 0.52, 30)
	makeRainbowStroke("RainbowOuterGlow", SETTINGS.RainbowBannerOuterGlowThickness, 0.78, 29)

	for _, layer in ipairs(rainbowLayers) do
		layer.frame.Visible = SETTINGS.RainbowBannerEnabled
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
		-- SMOOTH CONTINUOUS RAINBOW BORDER ANIMATION
		-- Rotating the gradient on one rounded stroke keeps the rainbow
		-- perfectly smooth through all four corners.
		--==================================================

		if SETTINGS.RainbowBannerEnabled then
			local rotation = (time * SETTINGS.RainbowBannerSpeed) % 360

			for _, layer in ipairs(rainbowLayers) do
				layer.gradient.Rotation = rotation
				layer.frame.Visible = true
			end
		else
			for _, layer in ipairs(rainbowLayers) do
				layer.frame.Visible = false
			end
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
