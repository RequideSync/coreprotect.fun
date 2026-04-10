local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		},
		Bliz_T = {
			Main = Color3.fromRGB(0, 0, 0),
			Second = Color3.fromRGB(20, 20, 20),
			Stroke = Color3.fromRGB(100, 150, 255),
			Divider = Color3.fromRGB(80, 120, 200),
			Text = Color3.fromRGB(180, 220, 255),
			TextDark = Color3.fromRGB(150, 180, 230)
		},
		Chili = {
			Main = Color3.fromRGB(0, 0, 0),
			Second = Color3.fromRGB(20, 20, 20),
			Stroke = Color3.fromRGB(255, 100, 100),
			Divider = Color3.fromRGB(200, 80, 80),
			Text = Color3.fromRGB(255, 180, 180),
			TextDark = Color3.fromRGB(230, 150, 150)
		},
		Forest = {
			Main = Color3.fromRGB(10, 40, 10),
			Second = Color3.fromRGB(20, 60, 20),
			Stroke = Color3.fromRGB(50, 200, 50),
			Divider = Color3.fromRGB(40, 160, 40),
			Text = Color3.fromRGB(180, 255, 180),
			TextDark = Color3.fromRGB(120, 200, 120)
		},
		Sunset = {
			Main = Color3.fromRGB(50, 20, 0),
			Second = Color3.fromRGB(80, 40, 10),
			Stroke = Color3.fromRGB(255, 100, 50),
			Divider = Color3.fromRGB(200, 80, 40),
			Text = Color3.fromRGB(255, 180, 150),
			TextDark = Color3.fromRGB(230, 140, 110)
		},
		Ocean = {
			Main = Color3.fromRGB(0, 20, 50),
			Second = Color3.fromRGB(0, 40, 80),
			Stroke = Color3.fromRGB(50, 150, 255),
			Divider = Color3.fromRGB(40, 120, 200),
			Text = Color3.fromRGB(180, 220, 255),
			TextDark = Color3.fromRGB(120, 160, 200)
		},
		Candy = {
			Main = Color3.fromRGB(50, 0, 50),
			Second = Color3.fromRGB(80, 20, 80),
			Stroke = Color3.fromRGB(255, 100, 255),
			Divider = Color3.fromRGB(200, 80, 200),
			Text = Color3.fromRGB(255, 180, 255),
			TextDark = Color3.fromRGB(220, 150, 220)
		},
		Retro = {
			Main = Color3.fromRGB(30, 30, 60),
			Second = Color3.fromRGB(50, 50, 100),
			Stroke = Color3.fromRGB(255, 200, 50),
			Divider = Color3.fromRGB(200, 160, 40),
			Text = Color3.fromRGB(255, 240, 180),
			TextDark = Color3.fromRGB(200, 180, 120)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end

local useStudio = RunService:IsStudio() or false

local Orion = Instance.new("ScreenGui")
local Modal = Instance.new("TextButton")

local FocusDrag = nil
Orion.Name = "Orion_" .. tostring(math.random(10000, 99999))

getgenv().gethui = function() return game.CoreGui end

if gethui then
	Orion.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(Orion)
	Orion.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Orion.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Orion.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do wait() end
	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do Object[i] = v end
	for i, v in next, Children or {} do v.Parent = Object end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...) return ElementFunction(...) end
end

local function MakeElement(ElementName, ...)
	return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value) Element[Property] = Value end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child) Child.Parent = Element end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
	if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if Object:IsA("UIStroke") then return "Color" end
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then OrionLib.ThemeObjects[Type] = {} end
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		end
	end
end

function OrionLib.SetTheme(themeName)
	if OrionLib.Themes[themeName] then
		OrionLib.SelectedTheme = themeName
		SetTheme()
	else
		warn("[OrionLib] Theme '" .. tostring(themeName) .. "' does not exist.")
	end
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a, b)
		if OrionLib.Flags[a] then
			spawn(function()
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end
			end)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i, v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then Data[i] = PackColor(v.Value)
			else Data[i] = v.Value end
		end
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local freeMouse = Create("TextButton", {Name = "FMouse", Size = UDim2.new(), BackgroundTransparency = 1, Text = "", Position = UDim2.new(), Modal = true, Parent = Orion, Visible = false})
local mouselock = false

local function UnlockMouse(Value)
	if Value then
		mouselock = true
		task.spawn(function()
			while mouselock do
				UserInputService.MouseIconEnabled = Value
				freeMouse.Visible = Value
				task.wait()
			end
			UserInputService.MouseIconEnabled = false
			freeMouse.Visible = false
		end)
	else
		mouselock = false
	end
end

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then return true end
	end
end

CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)
CreateElement("AspectRatio", function()
	return Create("UIAspectRatioConstraint")
end)
CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {Color = Color or Color3.fromRGB(255,255,255), Thickness = Thickness or 1})
end)
CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)})
end)
CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
end)
CreateElement("TFrame", function()
	return Create("Frame", {BackgroundTransparency = 1})
end)
CreateElement("Frame", function(Color)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0})
end)
CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {
		Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})
	})
end)
CreateElement("Button", function()
	return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0})
end)
CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0,0,0,0)
	})
end)
CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {Image = ImageID, BackgroundTransparency = 1})
	if GetIcon(ImageID) ~= nil then ImageNew.Image = GetIcon(ImageID) end
	return ImageNew
end)
CreateElement("ImageButton", function(ImageID)
	return Create("ImageButton", {Image = ImageID, BackgroundTransparency = 1})
end)
CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240,240,240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

-- ============================================================
-- SPACE EFFECT SYSTEM
-- Creates animated stars + shooting stars behind the main window
-- Does NOT overlap any UI elements (ZIndex is below everything)
-- ============================================================
local function CreateSpaceEffect(ParentFrame)
	-- Star container (lowest ZIndex, behind all UI)
	local StarCanvas = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Name = "StarCanvas",
		ClipsDescendants = true
	})
	StarCanvas.Parent = ParentFrame

	-- Make sure all other children are above ZIndex=1
	for _, child in pairs(ParentFrame:GetChildren()) do
		if child ~= StarCanvas and child:IsA("GuiObject") then
			child.ZIndex = math.max(child.ZIndex, 2)
		end
	end

	-- Star parameters
	local STAR_COUNT = 55
	local stars = {}

	-- Create static stars
	for i = 1, STAR_COUNT do
		local size = math.random(1, 3)
		local brightness = math.random(60, 200)
		local star = Create("Frame", {
			Size = UDim2.new(0, size, 0, size),
			Position = UDim2.new(math.random(), 0, math.random(), 0),
			BackgroundColor3 = Color3.fromRGB(brightness, brightness, math.min(brightness + 40, 255)),
			BorderSizePixel = 0,
			ZIndex = 1,
			Name = "Star" .. i
		})
		Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = star
		star.Parent = StarCanvas

		stars[i] = {
			frame = star,
			twinkleSpeed = math.random(8, 25) * 0.1,
			twinkleOffset = math.random() * math.pi * 2,
			baseAlpha = math.random(30, 90) * 0.01
		}
	end

	-- Shooting star pool (max 3 at once)
	local shootingStars = {}
	local SHOOTING_STAR_MAX = 3

	local function SpawnShootingStar()
		if #shootingStars >= SHOOTING_STAR_MAX then return end

		-- Pick a random start position along top/left edges
		local startX = math.random(0, 85) * 0.01
		local startY = math.random(0, 20) * 0.01

		local length = math.random(60, 140)
		local angle = math.random(25, 55) -- degrees (going down-right)
		local angleRad = math.rad(angle)

		-- Head of shooting star
		local head = Create("Frame", {
			Size = UDim2.new(0, 3, 0, 3),
			Position = UDim2.new(startX, 0, startY, 0),
			BackgroundColor3 = Color3.fromRGB(240, 240, 255),
			BorderSizePixel = 0,
			ZIndex = 1,
			Name = "ShootingStarHead"
		})
		Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = head
		head.Parent = StarCanvas

		-- Tail segments (fading)
		local tailSegments = {}
		local TAIL_SEGS = 6
		for s = 1, TAIL_SEGS do
			local alpha = 1 - (s / TAIL_SEGS)
			local seg = Create("Frame", {
				Size = UDim2.new(0, math.max(1, 3 - s), 0, math.max(1, 3 - s)),
				Position = head.Position,
				BackgroundColor3 = Color3.fromRGB(180, 180, 255),
				BackgroundTransparency = 1 - alpha * 0.8,
				BorderSizePixel = 0,
				ZIndex = 1
			})
			Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = seg
			seg.Parent = StarCanvas
			tailSegments[s] = seg
		end

		local entry = {
			head = head,
			tail = tailSegments,
			px = startX,
			py = startY,
			vx = math.cos(angleRad) * 0.006,
			vy = math.sin(angleRad) * 0.006,
			life = 1,
			tailPositions = {}
		}
		-- Initialize tail positions
		for s = 1, TAIL_SEGS do
			entry.tailPositions[s] = {x = startX, y = startY}
		end
		table.insert(shootingStars, entry)
	end

	-- Twinkle and movement loop
	local elapsed = 0
	local shootingTimer = 0
	local SHOOTING_INTERVAL = math.random(3, 8) -- seconds between meteors

	local spaceConnection = RunService.RenderStepped:Connect(function(dt)
		if not StarCanvas.Parent then return end
		elapsed = elapsed + dt
		shootingTimer = shootingTimer + dt

		-- Twinkle stars
		for _, s in ipairs(stars) do
			if s.frame and s.frame.Parent then
				local twinkle = s.baseAlpha + math.sin(elapsed * s.twinkleSpeed + s.twinkleOffset) * 0.25
				twinkle = math.clamp(twinkle, 0.05, 0.85)
				s.frame.BackgroundTransparency = 1 - twinkle
			end
		end

		-- Spawn shooting stars
		if shootingTimer >= SHOOTING_INTERVAL then
			shootingTimer = 0
			SHOOTING_INTERVAL = math.random(3, 8)
			SpawnShootingStar()
		end

		-- Update shooting stars
		for i = #shootingStars, 1, -1 do
			local ss = shootingStars[i]
			if not ss.head.Parent then
				table.remove(shootingStars, i)
				continue
			end

			-- Shift tail positions
			for t = #ss.tailPositions, 2, -1 do
				ss.tailPositions[t] = ss.tailPositions[t-1]
			end
			ss.tailPositions[1] = {x = ss.px, y = ss.py}

			ss.px = ss.px + ss.vx
			ss.py = ss.py + ss.vy
			ss.life = ss.life - dt * 0.6

			local headAlpha = math.clamp(ss.life, 0, 1)
			ss.head.Position = UDim2.new(ss.px, 0, ss.py, 0)
			ss.head.BackgroundTransparency = 1 - headAlpha

			for t, seg in ipairs(ss.tail) do
				local tp = ss.tailPositions[math.min(t + 1, #ss.tailPositions)]
				seg.Position = UDim2.new(tp.x, 0, tp.y, 0)
				local segAlpha = headAlpha * (1 - t / (#ss.tail + 1)) * 0.8
				seg.BackgroundTransparency = 1 - segAlpha
			end

			-- Destroy when out of bounds or faded
			if ss.life <= 0 or ss.px > 1.1 or ss.py > 1.1 then
				ss.head:Destroy()
				for _, seg in ipairs(ss.tail) do seg:Destroy() end
				table.remove(shootingStars, i)
			end
		end
	end)

	table.insert(OrionLib.Connections, spaceConnection)
	return StarCanvas
end

-- ============================================================
-- MONITOR TICKER SYSTEM
-- Scrolling text in TopBar (between title and minimize/close)
-- ============================================================
local function CreateMonitor(ParentTopBar, Config)
	if not Config or not Config.Enabled then return nil end

	local speed = Config.Speed or 3
	local text = Config.Text or ""

	-- Container clipped frame
	local MonitorContainer = Create("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 3,
		Name = "MonitorContainer"
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = MonitorContainer

	-- Subtle background
	local MonBg = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 3
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = MonBg
	MonBg.Parent = MonitorContainer

	-- Scrolling label (wider than container, will be moved)
	local MonLabel = Create("TextLabel", {
		Text = text .. "   ◆   " .. text .. "   ◆   " .. text,
		TextColor3 = Color3.fromRGB(180, 180, 255),
		TextTransparency = 0,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(3, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 4,
		Name = "MonitorLabel"
	})
	MonLabel.Parent = MonitorContainer
	MonitorContainer.Parent = ParentTopBar

	-- Scroll animation
	local scrollPos = 0
	local monConnection = RunService.RenderStepped:Connect(function(dt)
		if not MonLabel.Parent then return end
		local containerWidth = MonitorContainer.AbsoluteSize.X
		local labelWidth = MonLabel.AbsoluteSize.X / 3  -- one "copy" width approx

		scrollPos = scrollPos + speed * dt * 30
		if scrollPos >= labelWidth + 8 then
			scrollPos = 0
		end
		MonLabel.Position = UDim2.new(0, -scrollPos, 0, 0)
	end)
	table.insert(OrionLib.Connections, monConnection)

	-- Exposed API
	local MonitorAPI = {}
	function MonitorAPI:SetText(newText)
		text = newText
		MonLabel.Text = newText .. "   ◆   " .. newText .. "   ◆   " .. newText
	end

	return MonitorContainer, MonitorAPI
end

-- ============================================================
-- Notification system
-- ============================================================
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		wait(0.05)
		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
		wait(1.35)
		NotificationFrame:Destroy()
	end)
end

function OrionLib:Init()
	if OrionLib.SaveCfg then
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)
	end
end

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false
	local MonitorAPI = nil  -- will be set if Monitor enabled

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
	WindowConfig.FreeMouse = WindowConfig.FreeMouse or false
	WindowConfig.KeyToOpenWindow = WindowConfig.KeyToOpenWindow or "K"
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.Monitor = WindowConfig.Monitor or {Enabled = false}
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end
	end

	if WindowConfig.FreeMouse then UnlockMouse(true) end

	local MobileOpenButton = SetChildren(SetProps(MakeElement("Button"), {
		BackgroundTransparency = 0,
		Parent = Orion,
		Text = "Open",
		TextScaled = true,
		TextSize = 14,
		TextColor3 = Color3.new(0,0,0),
		BackgroundColor = BrickColor.new(0,0,0),
		TextStrokeColor3 = Color3.new(255,255,255),
		TextStrokeTransparency = 0,
		Size = UDim2.new(0.035, 0, 0.035, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Visible = false,
		Font = Enum.Font.GothamBold
	}), {MakeElement("Corner", 0.25), SetProps(MakeElement("AspectRatio"), {DominantAxis = 0, AspectRatio = 0.986, AspectType = 1})})

	MakeDraggable(MobileOpenButton, MobileOpenButton)

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0)}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1)}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(1, 0, 1, 0)}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1, 0, 1, 0)}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(0, 0, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20,
		AutomaticSize = Enum.AutomaticSize.X
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	-- ============================================================
	-- TOP BAR: structured layout for Monitor
	-- Title (left) | MonitorContainer (center, fills remaining) | Controls (right)
	-- ============================================================
	local TopBarControls = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 7), {
		Size = UDim2.new(0, 70, 0, 30),
		Position = UDim2.new(1, -90, 0, 10),
		ZIndex = 5
	}), {
		AddThemeObject(MakeElement("Stroke"), "Stroke"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0)
		}), "Stroke"),
		CloseBtn,
		MinimizeBtn
	}), "Second")

	-- Monitor container placeholder (will be filled if Monitor enabled)
	local MonitorContainerFrame = Create("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 4,
		Name = "MonitorFrame"
	})

	local TopBarFrame = SetChildren(SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50),
		Name = "TopBar",
		ZIndex = 3
	}), {
		WindowName,
		WindowTopBarLine,
		TopBarControls,
		MonitorContainerFrame
	})

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
		Parent = Orion,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		TopBarFrame,
		DragPoint,
		WindowStuff
	}), "Main")

	-- ============================================================
	-- SPACE EFFECT: attach to MainWindow (behind all UI, ZIndex=1)
	-- ============================================================
	CreateSpaceEffect(MainWindow)

	-- Ensure UI elements are above stars
	TopBarFrame.ZIndex = 3
	DragPoint.ZIndex = 3
	WindowStuff.ZIndex = 2

	-- ============================================================
	-- MONITOR: position in top bar between title and controls
	-- ============================================================
	if WindowConfig.Monitor and WindowConfig.Monitor.Enabled then
		-- We size the monitor to fill the gap between title text and controls
		-- Title ends around x=25+TextBounds, controls start at x=615-90=525
		-- So monitor goes from roughly title_end+10 to 525-10

		local monitorConfig = WindowConfig.Monitor
		local monContainer, monAPI = CreateMonitor(MainWindow, monitorConfig)
		MonitorAPI = monAPI

		-- Position the monitor label properly in the TopBar area
		if monContainer then
			monContainer.Parent = MainWindow
			monContainer.ZIndex = 4

			-- Dynamically size/position once title width is known
			task.spawn(function()
				task.wait(0.1) -- wait for TextBounds to update
				local titleEnd = 25 + WindowName.TextBounds.X + 15
				local controlsStart = 615 - 95
				local monWidth = controlsStart - titleEnd - 10

				if monWidth > 60 then
					monContainer.Position = UDim2.new(0, titleEnd, 0, 10)
					monContainer.Size = UDim2.new(0, monWidth, 0, 30)
				end
			end)
		end
	end

	-- Expose SetMonitorText globally
	function OrionLib:SetMonitorText(text)
		if MonitorAPI then
			MonitorAPI:SetText(text)
		end
	end

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15),
			ZIndex = 4
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	MakeDraggable(DragPoint, MainWindow)

	AddConnection(MobileOpenButton.MouseButton1Click, function()
		MobileOpenButton.Visible = false
		MainWindow.Visible = true
		UIHidden = false
	end)

	local function showMobileOpenButton()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			MobileOpenButton.Visible = UIHidden
		end
	end

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		if WindowConfig.FreeMouse then UnlockMouse(false) end
		OrionLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap " .. WindowConfig.KeyToOpenWindow .. " to reopen the interface",
			Time = 3
		})
		showMobileOpenButton()
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input, Focus)
		if not Focus then
			if Input.KeyCode == Enum.KeyCode[WindowConfig.KeyToOpenWindow] and UIHidden then
				MainWindow.Visible = true
				UIHidden = false
				if WindowConfig.FreeMouse then UnlockMouse(true) end
				showMobileOpenButton()
			elseif Input.KeyCode == Enum.KeyCode[WindowConfig.KeyToOpenWindow] and not UIHidden then
				MainWindow.Visible = false
				UIHidden = true
				if WindowConfig.FreeMouse then UnlockMouse(false) end
				OrionLib:MakeNotification({
					Name = "Interface Hidden",
					Content = "Tap " .. WindowConfig.KeyToOpenWindow .. " to reopen the interface",
					Time = 3
				})
				showMobileOpenButton()
			end
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255,255,255),
			ImageTransparency = 1
		})
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end

	if WindowConfig.IntroEnabled then LoadSequence() end

	if WindowConfig.FreeMouse then
		OrionLib:MakeNotification({
			Name = "Free Mouse mode is on",
			Content = "if you want it to go back to normal, just press M or close the GUI",
			Time = 10
		})
	end

	function OrionLib.SetTitle(Title)
		WindowName.Text = Title
	end

	-- ============================================================
	-- TAB SYSTEM (unchanged from original + AddGroupSection added)
	-- ============================================================
	local TabFunction = {}

	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				end
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then ItemContainer.Visible = false end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end)

		-- ============================================================
		-- ELEMENT FACTORY (same as original, wrapped for reuse)
		-- ============================================================
		local function GetElements(ItemParent)
			local ElementFunction = {}

			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange) LabelFrame.Content.Text = ToChange end
				return LabelFunction
			end

			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)
				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange) ParagraphFrame.Content.Text = ToChange end
				return ParagraphFunction
			end

			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

				local Button = {}
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7)
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
					spawn(function() ButtonConfig.Callback() end)
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play()
				end)
				function Button:Set(ButtonText) ButtonFrame.Content.Text = ButtonText end
				return Button
			end

			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255,255,255),
						Name = "Ico"
					})
				})
				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						RichText = true,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end
				function Toggle:SetName(Name) ToggleFrame.Content.Text = Name end
				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.Activated, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play()
				end)
				if ToggleConfig.Flag then OrionLib.Flags[ToggleConfig.Flag] = Toggle end
				return Toggle
			end

			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})
				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})
				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

				local Dragging, DragInput, MousePos, FramePos = false
				AddConnection(SliderBar.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						MousePos = Input.Position
						FramePos = SliderBar.Position
						AddConnection(Input.Changed, function()
							if Input.UserInputState == Enum.UserInputState.End then
								Dragging = false
								FocusDrag = nil
							end
						end)
					end
				end)
				AddConnection(SliderBar.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not FocusDrag then
						DragInput = Input
						FocusDrag = DragInput
					end
				end)
				AddConnection(UserInputService.InputChanged, function(Input)
					if Input == DragInput and Input == FocusDrag and Dragging then
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
						SaveCfg(game.GameId)
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end
				Slider:Set(Slider.Value)
				if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
				return Slider
			end

			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5
				if not table.find(Dropdown.Options, Dropdown.Value) then Dropdown.Value = "..." end

				local DropdownList = MakeElement("List")
				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40,40,40), 4), {DropdownList}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240,240,240),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
						Click
					}), {Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Name = "F"}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40,40,40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")
						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)
						Dropdown.Buttons[Option] = OptionBtn
					end
				end

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
						end
						return
					end
					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value
					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
					end
					TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
					if #Dropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then OrionLib.Flags[DropdownConfig.Flag] = Dropdown end
				return Dropdown
			end

			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {Value = nil, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")
				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)
				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)
				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function() if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end end)
						pcall(function() if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)
				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)
				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end
				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then OrionLib.Flags[BindConfig.Flag] = Bind end
				return Bind
			end

			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255,255,255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = "Input",
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), "Text")
				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")
				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")

				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)
				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then TextboxActual.Text = "" end
				end)
				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+3)}):Play()
					TextboxActual:CaptureFocus()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6)}):Play()
				end)
			end

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local ColorH, ColorS, ColorV = 1, 1, 1
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local Color = Create("ImageLabel", {Size = UDim2.new(1, -25, 1, 0), Visible = false, Image = "rbxassetid://4155801252"}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					ColorSelection
				})
				local Hue = Create("Frame", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), Visible = false}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,4)),
						ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234,255,0)),
						ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21,255,0)),
						ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,255)),
						ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,17,255)),
						ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255,0,251)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,4))
					}}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					HueSelection
				})
				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {Hue, Color, Create("UIPadding", {PaddingLeft = UDim.new(0,35), PaddingRight = UDim.new(0,35), PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,17)})})
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke")
					}), {Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Name = "F"}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)

				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
				ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
				ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

				local Dragging, DragInput, MousePos, FramePos = false
				AddConnection(Color.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						AddConnection(Input.Changed, function()
							if Input.UserInputState == Enum.UserInputState.End then Dragging = false; FocusDrag = nil end
						end)
					end
				end)
				AddConnection(Color.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not FocusDrag then
						DragInput = Input; FocusDrag = DragInput
					end
				end)
				AddConnection(UserInputService.InputChanged, function(Input)
					if Input == DragInput and Dragging and Input == FocusDrag then
						local ColorX = (math.clamp(DragInput.Position.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
						local ColorY = (math.clamp(Input.Position.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
						ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
						ColorS = ColorX; ColorV = 1 - ColorY
						UpdateColorPicker()
					end
				end)

				local Dragging_1, DragInput_1, MousePos_1, FramePos_1 = false
				AddConnection(Hue.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging_1 = true
						AddConnection(Input.Changed, function()
							if Input.UserInputState == Enum.UserInputState.End then Dragging_1 = false; FocusDrag = nil end
						end)
					end
				end)
				AddConnection(Hue.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not FocusDrag then
						DragInput_1 = Input; FocusDrag = DragInput_1
					end
				end)
				AddConnection(UserInputService.InputChanged, function(Input)
					if Input == DragInput_1 and Dragging_1 and DragInput_1 == FocusDrag then
						local HueY = (math.clamp(Input.Position.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
						HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
						ColorH = 1 - HueY
						UpdateColorPicker()
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end
				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end

			return ElementFunction
		end

		-- ============================================================
		-- PUBLIC ELEMENT FUNCTION TABLE (exposed to user)
		-- ============================================================
		local ElementFunction = {}

		-- Classic AddSection (unchanged)
		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"
			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {MakeElement("List", 0, 6)})
			})
			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)
			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do SectionFunction[i] = v end
			return SectionFunction
		end

		-- ============================================================
		-- NEW: AddGroupSection
		-- Collapsible/lockable section with icon, dropdown-style toggle
		-- GSection:SetOpen(bool)
		-- GSection:SetLocked(bool)
		-- GSection:SetIcon(string)
		-- GSection:SetText(string)
		-- ============================================================
		function ElementFunction:AddGroupSection(SectionConfig)
			SectionConfig = SectionConfig or {}
			SectionConfig.Text = SectionConfig.Text or "Section"
			SectionConfig.Icon = SectionConfig.Icon or ""
			SectionConfig.Opened = SectionConfig.Opened ~= false  -- default true
			SectionConfig.Locked = SectionConfig.Locked or false

			local GSection = {}
			local IsOpen = SectionConfig.Opened
			local IsLocked = SectionConfig.Locked

			-- ---- Header ----
			local HeaderClick = SetProps(MakeElement("Button"), {
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 5
			})

			-- Arrow indicator (rotates on open/close)
			local ArrowIcon = AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -22, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = IsOpen and 180 or 0,
				Name = "Arrow",
				ZIndex = 5
			}), "TextDark")

			-- Section icon (optional)
			local SectionIcon = SetProps(MakeElement("Image", SectionConfig.Icon), {
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 8, 0.5, 0),
				ImageTransparency = SectionConfig.Icon == "" and 1 or 0,
				Name = "SectionIco",
				ZIndex = 5
			})
			AddThemeObject(SectionIcon, "Text")

			if GetIcon(SectionConfig.Icon) ~= nil then
				SectionIcon.Image = GetIcon(SectionConfig.Icon)
			end

			-- Lock icon (shown when locked)
			local LockIcon = AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
				Size = UDim2.new(0, 13, 0, 13),
				Position = UDim2.new(1, -38, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageTransparency = IsLocked and 0 or 1,
				Name = "LockIco",
				ZIndex = 5
			}), "TextDark")

			local SectionTitle = AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Text, 13), {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, SectionConfig.Icon == "" and 10 or 30, 0, 0),
				Font = Enum.Font.GothamSemibold,
				ZIndex = 5,
				Name = "SectionTitle"
			}), "TextDark")

			local HeaderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 0.85,
				Parent = Container,
				Name = "GSectionHeader"
			}), {
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 2, 1, -8),
					Position = UDim2.new(0, 0, 0, 4),
					BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Stroke
				}), "Stroke"),
				SectionIcon,
				SectionTitle,
				LockIcon,
				ArrowIcon,
				HeaderClick
			}), "Second")

			-- ---- Body (holder for elements) ----
			local BodyHolder = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 0),
				Parent = Container,
				Name = "GSectionBody",
				ClipsDescendants = true
			}), {
				MakeElement("List", 0, 5),
				MakeElement("Padding", 4, 2, 2, 2)
			})

			-- Compute body height based on content
			local function UpdateBodySize()
				local contentH = BodyHolder.UIListLayout.AbsoluteContentSize.Y + 10
				if IsOpen and not IsLocked then
					TweenService:Create(BodyHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, contentH)}):Play()
				else
					TweenService:Create(BodyHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				end
			end

			AddConnection(BodyHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if IsOpen and not IsLocked then
					BodyHolder.Size = UDim2.new(1, 0, 0, BodyHolder.UIListLayout.AbsoluteContentSize.Y + 10)
				end
			end)

			-- Initial state
			if not IsOpen or IsLocked then
				BodyHolder.Size = UDim2.new(1, 0, 0, 0)
			end

			-- Toggle on header click
			AddConnection(HeaderClick.MouseButton1Click, function()
				if IsLocked then return end
				IsOpen = not IsOpen
				TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = IsOpen and 180 or 0}):Play()
				UpdateBodySize()
			end)

			-- Hover effect on header
			AddConnection(HeaderClick.MouseEnter, function()
				TweenService:Create(HeaderFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.75}):Play()
			end)
			AddConnection(HeaderClick.MouseLeave, function()
				TweenService:Create(HeaderFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}):Play()
			end)

			-- ---- GSection API ----
			function GSection:SetOpen(value)
				if IsLocked then return end
				IsOpen = value
				TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = IsOpen and 180 or 0}):Play()
				UpdateBodySize()
			end

			function GSection:SetLocked(value)
				IsLocked = value
				TweenService:Create(LockIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = IsLocked and 0 or 1}):Play()
				if IsLocked then
					-- Close if locking
					IsOpen = false
					TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 0}):Play()
					TweenService:Create(BodyHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				end
			end

			function GSection:SetIcon(iconString)
				SectionConfig.Icon = iconString
				if GetIcon(iconString) ~= nil then
					SectionIcon.Image = GetIcon(iconString)
				else
					SectionIcon.Image = iconString
				end
				SectionIcon.ImageTransparency = iconString == "" and 1 or 0
			end

			function GSection:SetText(text)
				SectionTitle.Text = text
			end

			-- Attach all standard elements to BodyHolder
			local SectionElements = GetElements(BodyHolder)
			for k, v in pairs(SectionElements) do
				GSection[k] = v
			end

			return GSection
		end

		-- Copy remaining elements from GetElements
		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do ElementFunction[i] = function() end end
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 1, 0), Parent = Container}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,15,0,15), ImageTransparency = 0.4}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {Size = UDim2.new(1,-38,0,14), Position = UDim2.new(0,38,0,18), TextTransparency = 0.4}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {Size = UDim2.new(0,56,0,56), Position = UDim2.new(0,84,0,110)}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {Size = UDim2.new(1,-150,0,14), Position = UDim2.new(0,150,0,112), Font = Enum.Font.GothamBold}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {Size = UDim2.new(1,-200,0,14), Position = UDim2.new(0,150,0,138), TextWrapped = true, TextTransparency = 0.4}), "Text")
			})
		end
		return ElementFunction
	end

	return TabFunction
end

function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib
