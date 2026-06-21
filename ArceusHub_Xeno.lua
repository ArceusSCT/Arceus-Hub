-- ============================================
--         ARCEUS HUB v4.0 — XENO EDITION
--         Compatible with Xeno Executor
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local function refreshChar(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(refreshChar)

local function Notify(title, msg)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=title,Text=msg,Duration=3})
    end)
end

-- ============================================
--                STATE
-- ============================================
local State = {
    flying = false,
    noclip = false,
    flySpeed = 50,
    speedEnabled = false,
    jumpEnabled = false,
    walkSpeed = 60,
    jumpPower = 100,
    infJump = false,
    spin = false,
    spinSpeed = 5,
    antiAfk = false,
    fullbright = false,
    esp = false,
    guiVisible = true,
}

local Conns = {}
local speedConns = {}
local jumpConns = {}
local espHighlights = {}
local espBillboards = {}

-- ============================================
--              SCREEN GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArceusHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 370, 0, 580)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local BorderStroke = Instance.new("UIStroke", MainFrame)
BorderStroke.Thickness = 2
BorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BorderStroke.Color = Color3.fromRGB(255, 255, 255)

task.spawn(function()
    local t = 0
    while MainFrame.Parent do
        t = t + task.wait(0.05)
        local r = 0.5 + 0.5 * math.sin(t)
        BorderStroke.Color = Color3.fromRGB(math.floor(180 + 75 * r), math.floor(180 + 75 * r), math.floor(180 + 75 * r))
    end
end)

local BGGrad = Instance.new("UIGradient", MainFrame)
BGGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 10, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 6, 18)),
})
BGGrad.Rotation = 130

local AccentBar = Instance.new("Frame", MainFrame)
AccentBar.Size = UDim2.new(1, 0, 0, 3)
AccentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex = 6

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundTransparency = 1

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size = UDim2.new(1, -90, 0, 36)
TitleLbl.Position = UDim2.new(0, 14, 0, 6)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚡ ARCEUS HUB"
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize = 22
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local SubLbl = Instance.new("TextLabel", Header)
SubLbl.Size = UDim2.new(1, -90, 0, 18)
SubLbl.Position = UDim2.new(0, 16, 0, 38)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "v4.0  •  Free Edition  |  by ArceusSCT"
SubLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
SubLbl.TextSize = 12
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -42, 0, 16)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
MinBtn.Text = "✕"
MinBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local Div = Instance.new("Frame", MainFrame)
Div.Size = UDim2.new(1, -28, 0, 1)
Div.Position = UDim2.new(0, 14, 0, 62)
Div.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Div.BorderSizePixel = 0

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -68)
Scroll.Position = UDim2.new(0, 0, 0, 66)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(220, 220, 220)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ULL = Instance.new("UIListLayout", Scroll)
ULL.Padding = UDim.new(0, 8)
ULL.HorizontalAlignment = Enum.HorizontalAlignment.Center
ULL.SortOrder = Enum.SortOrder.LayoutOrder

local ULP = Instance.new("UIPadding", Scroll)
ULP.PaddingTop = UDim.new(0, 10)
ULP.PaddingBottom = UDim.new(0, 18)
ULP.PaddingLeft = UDim.new(0, 14)
ULP.PaddingRight = UDim.new(0, 14)

-- ============================================
--              UI HELPERS
-- ============================================
local order = 0
local function nextOrder()
    order = order + 1
    return order
end

local function Section(title)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder()
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    line.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0, 150, 1, 0)
    lbl.Position = UDim2.new(0.5, -75, 0, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(10, 8, 22)
    lbl.Text = "  " .. title .. "  "
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.BorderSizePixel = 0
end

local function Toggle(label, callback)
    local Row = Instance.new("Frame", Scroll)
    Row.Size = UDim2.new(1, 0, 0, 46)
    Row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = nextOrder()
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Row)
    Stroke.Color = Color3.fromRGB(70, 70, 80)
    Stroke.Thickness = 1

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -72, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(0, 44, 0, 24)
    Track.Position = UDim2.new(1, -54, 0.5, -12)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local on = false
    local function setV(s)
        if s then
            TweenService:Create(Track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(200, 200, 220)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.18), {Position = UDim2.new(0, 23, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.18), {Color = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.18), {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(150, 150, 160)}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.18), {Color = Color3.fromRGB(70, 70, 80)}):Play()
        end
    end

    Row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            on = not on
            setV(on)
            callback(on)
        end
    end)
    return Row
end

local function Slider(label, min, max, default, callback)
    local Row = Instance.new("Frame", Scroll)
    Row.Size = UDim2.new(1, 0, 0, 66)
    Row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = nextOrder()
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Row).Color = Color3.fromRGB(70, 70, 80)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -64, 0, 24)
    Lbl.Position = UDim2.new(0, 12, 0, 8)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", Row)
    ValLbl.Size = UDim2.new(0, 52, 0, 24)
    ValLbl.Position = UDim2.new(1, -62, 0, 8)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = tostring(default)
    ValLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    ValLbl.TextSize = 13
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(1, -24, 0, 6)
    Track.Position = UDim2.new(0, 12, 0, 44)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local p0 = (default - min) / (max - min)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(p0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(p0, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 3
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function update(x)
        local p = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * p)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        Knob.Position = UDim2.new(p, -7, 0.5, -7)
        ValLbl.Text = tostring(v)
        callback(v)
    end

    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function Button(label, col, callback)
    local Wrap = Instance.new("Frame", Scroll)
    Wrap.Size = UDim2.new(1, 0, 0, 40)
    Wrap.BackgroundTransparency = 1
    Wrap.LayoutOrder = nextOrder()

    local Btn = Instance.new("TextButton", Wrap)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = col
    Btn.Text = label
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.new(math.min(col.R + 0.1, 1), math.min(col.G + 0.1, 1), math.min(col.B + 0.1, 1))}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = col}):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- ============================================
--           ── MOVEMENT ──
-- ============================================
Section("✦  MOVEMENT")

Toggle("🚀  Fly  [ WASD + Space / Ctrl ]", function(on)
    State.flying = on
    if on then
        local bg = Instance.new("BodyGyro", rootPart)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4

        local bv = Instance.new("BodyVelocity", rootPart)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero

        humanoid.PlatformStand = true

        Conns.fly = RunService.Heartbeat:Connect(function()
            if not State.flying then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * State.flySpeed or Vector3.zero
            bg.CFrame = cam.CFrame
        end)
    else
        if Conns.fly then Conns.fly:Disconnect()
            Conns.fly = nil end
        local fg = rootPart:FindFirstChild("FlyGyro")
        local fv = rootPart:FindFirstChild("FlyVelocity")
        if fg then fg:Destroy() end
        if fv then fv:Destroy() end
        humanoid.PlatformStand = false
    end
end)

Slider("⚡  Fly Speed", 10, 400, 50, function(v)
    State.flySpeed = v
end)

Toggle("👻  Noclip", function(on)
    State.noclip = on
    if on then
        Conns.noclip = RunService.Stepped:Connect(function()
            if not State.noclip then return end
            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if Conns.noclip then Conns.noclip:Disconnect()
            Conns.noclip = nil end
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

Toggle("🌌  Low Gravity", function(on)
    workspace.Gravity = on and 40 or 196.2
end)

-- ============================================
--           ── CHARACTER ──
-- ============================================
Section("✦  CHARACTER")

local speedConn = nil
Toggle("🏃  Walk Speed", function(on)
    State.speedEnabled = on
    if on then
        humanoid.WalkSpeed = State.walkSpeed
        speedConn = RunService.Heartbeat:Connect(function()
            if humanoid and State.speedEnabled then
                humanoid.WalkSpeed = State.walkSpeed
            end
        end)
    else
        if speedConn then speedConn:Disconnect()
            speedConn = nil end
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)

Slider("   Speed Value", 4, 500, 60, function(v)
    State.walkSpeed = v
    if State.speedEnabled and humanoid then humanoid.WalkSpeed = v end
end)

local jumpConn = nil
Toggle("🦘  Jump Power", function(on)
    State.jumpEnabled = on
    if on then
        humanoid.JumpPower = State.jumpPower
        jumpConn = RunService.Heartbeat:Connect(function()
            if humanoid and State.jumpEnabled then
                humanoid.JumpPower = State.jumpPower
            end
        end)
    else
        if jumpConn then jumpConn:Disconnect()
            jumpConn = nil end
        if humanoid then humanoid.JumpPower = 50 end
    end
end)

Slider("   Jump Value", 10, 500, 100, function(v)
    State.jumpPower = v
    if State.jumpEnabled and humanoid then humanoid.JumpPower = v end
end)

Toggle("♾️  Infinite Jump", function(on)
    State.infJump = on
    if on then
        Conns.infJump = UserInputService.JumpRequest:Connect(function()
            if State.infJump and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Conns.infJump then Conns.infJump:Disconnect()
            Conns.infJump = nil end
    end
end)

-- ============================================
--           ── WORLD ──
-- ============================================
Section("✦  WORLD")

Toggle("☀️  Fullbright", function(on)
    if on then
        Lighting.Brightness = 10
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 1
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end)

Slider("🌫️  Gravity", 10, 300, 196, function(v)
    workspace.Gravity = v
end)

-- ============================================
--           ── UTILITIES ──
-- ============================================
Section("✦  UTILITIES")

Button("⟳  Reset Character", Color3.fromRGB(70, 70, 85), function()
    player:LoadCharacter()
end)

Button("📍  Teleport to Spawn", Color3.fromRGB(30, 30, 40), function()
    local s = workspace:FindFirstChildOfClass("SpawnLocation")
    if s then rootPart.CFrame = s.CFrame + Vector3.new(0, 5, 0) end
end)

-- ============================================
--        FLOATING ORB & HUB TOGGLE
-- ============================================
MainFrame.Visible = false

local OrbGui = Instance.new("ScreenGui", player.PlayerGui)
OrbGui.Name = "ArceusOrb"
OrbGui.ResetOnSpawn = false
OrbGui.IgnoreGuiInset = true
OrbGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local OrbGlow = Instance.new("Frame", OrbGui)
OrbGlow.Size = UDim2.new(0, 72, 0, 72)
OrbGlow.Position = UDim2.new(0, 20, 0.5, -36)
OrbGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OrbGlow.BackgroundTransparency = 0.6
OrbGlow.BorderSizePixel = 0
OrbGlow.ZIndex = 1
Instance.new("UICorner", OrbGlow).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local t = 0
    while OrbGlow.Parent do
        t = t + task.wait(0.05)
        local p = 0.5 + 0.5 * math.sin(t * 2)
        OrbGlow.BackgroundTransparency = 0.5 + 0.35 * p
        OrbGlow.Size = UDim2.new(0, 72 + 6 * p, 0, 72 + 6 * p)
        OrbGlow.Position = UDim2.new(0, 20 - (3 * p), 0.5, -36 - (3 * p))
    end
end)

local Orb = Instance.new("TextButton", OrbGui)
Orb.Size = UDim2.new(0, 62, 0, 62)
Orb.Position = UDim2.new(0, 25, 0.5, -31)
Orb.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Orb.Text = "⚡"
Orb.TextColor3 = Color3.fromRGB(255, 255, 255)
Orb.TextSize = 32
Orb.Font = Enum.Font.GothamBold
Orb.BorderSizePixel = 0
Orb.ZIndex = 2
Instance.new("UICorner", Orb).CornerRadius = UDim.new(1, 0)
local OrbStroke = Instance.new("UIStroke", Orb)
OrbStroke.Thickness = 2
OrbStroke.Color = Color3.fromRGB(255, 255, 255)

local hubOpen = false
local function toggleHub()
    hubOpen = not hubOpen
    if hubOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 370, 0, 580)}):Play()
        TweenService:Create(OrbStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(200, 200, 255), Thickness = 3}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 370, 0, 0)}):Play()
        task.delay(0.26, function()
            MainFrame.Visible = false
        end)
        TweenService:Create(OrbStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(200, 200, 200), Thickness = 2}):Play()
    end
end

local orbClickStart = nil
Orb.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        orbClickStart = inp.Position
    end
end)
Orb.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if orbClickStart and (inp.Position - orbClickStart).Magnitude < 6 then
            toggleHub()
        end
        orbClickStart = nil
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    if hubOpen then toggleHub() end
end)

local dragOn, dragStart2, dragPos2 = false, nil, nil
MainFrame.InputBegan:Connect(function(inp)
    if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and (inp.Position.Y - MainFrame.AbsolutePosition.Y < 66) then
        dragOn = true
        dragStart2 = inp.Position
        dragPos2 = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragOn and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart2
        MainFrame.Position = UDim2.new(dragPos2.X.Scale, dragPos2.X.Offset + d.X, dragPos2.Y.Scale, dragPos2.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragOn = false
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.G then
        toggleHub()
    end
end)

player.CharacterAdded:Connect(function(char)
    refreshChar(char)
    task.wait(0.25)
    if State.speedEnabled then humanoid.WalkSpeed = State.walkSpeed end
    if State.jumpEnabled then humanoid.JumpPower = State.jumpPower end
    State.flying = false
    State.noclip = false
end)

MainFrame.Position = UDim2.new(0.5, -185, 0.5, -310)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -185, 0.5, -290),
    BackgroundTransparency = 0,
}):Play()

Notify("Arceus Hub", "✅ v4.0 Loaded! Press G to open")
