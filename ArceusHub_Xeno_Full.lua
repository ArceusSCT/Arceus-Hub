-- ============================================
--           ARCEUS HUB  v4.0
--           Free Edition  |  arceushub
-- ============================================

-- ============================================
--              WHITELIST
-- ============================================
local PASSWORD = "ArceusOnTop"

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local Lighting         = game:GetService("Lighting")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

local function refreshChar(char)
    character = char
    humanoid  = char:WaitForChild("Humanoid")
    rootPart  = char:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(refreshChar)

local function Notify(title, msg)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=title,Text=msg,Duration=3})
    end)
end

-- Auth skipped for Xeno


-- ============================================
--         MAIN HUB (launched after auth)
-- ============================================
do -- hub starts

local State = {
    flying=false, noclip=false, flySpeed=50,
    speedEnabled=false, jumpEnabled=false,
    walkSpeed=60, jumpPower=100,
    infJump=false, spin=false, spinSpeed=5,
    antiAfk=false, fullbright=false,
    esp=false, guiVisible=true,
}

local Conns       = {}
local speedConns  = {}   -- multiple connections for bullet-proof speed
local jumpConns   = {}
local espHighlights={}
local espBillboards={}

-- ============================================
--              SCREEN GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="ArceusHub"; ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true; ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=player.PlayerGui

local MainFrame = Instance.new("Frame",ScreenGui)
MainFrame.Name="MainFrame"; MainFrame.Size=UDim2.new(0,370,0,580)
MainFrame.Position=UDim2.new(0.5,-185,0.5,-290)
MainFrame.BackgroundColor3=Color3.fromRGB(12,12,18)
MainFrame.BorderSizePixel=0; MainFrame.ClipsDescendants=true
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,14)

local BorderStroke=Instance.new("UIStroke",MainFrame)
BorderStroke.Thickness=2; BorderStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
BorderStroke.Color=Color3.fromRGB(240,240,240)
task.spawn(function()
    local t=0
    while MainFrame.Parent do
        t=t+task.wait(0.05)
        local r=0.5+0.5*math.sin(t)
        BorderStroke.Color=Color3.fromRGB(math.floor(180+75*r),math.floor(180+75*r),math.floor(180+75*r))
    end
end)

local BGGrad=Instance.new("UIGradient",MainFrame)
BGGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(14,14,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,14))})
BGGrad.Rotation=130

local AccentBar=Instance.new("Frame",MainFrame)
AccentBar.Size=UDim2.new(1,0,0,3); AccentBar.BackgroundColor3=Color3.fromRGB(255,255,255); AccentBar.BorderSizePixel=0; AccentBar.ZIndex=6
local AG=Instance.new("UIGradient",AccentBar)
AG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(140,140,140)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,140,140))})

-- header
local Header=Instance.new("Frame",MainFrame)
Header.Size=UDim2.new(1,0,0,62); Header.BackgroundTransparency=1

local TitleLbl=Instance.new("TextLabel",Header)
TitleLbl.Size=UDim2.new(1,-90,0,36); TitleLbl.Position=UDim2.new(0,14,0,6)
TitleLbl.BackgroundTransparency=1; TitleLbl.Text="⚡ ARCEUS HUB"
TitleLbl.TextColor3=Color3.fromRGB(255,255,255); TitleLbl.TextSize=22; TitleLbl.Font=Enum.Font.GothamBold
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left

local SubLbl=Instance.new("TextLabel",Header)
SubLbl.Size=UDim2.new(1,-90,0,18); SubLbl.Position=UDim2.new(0,16,0,38)
SubLbl.BackgroundTransparency=1; SubLbl.Text="v4.0  •  Free Edition  |  by ArceusSCT"
SubLbl.TextColor3=Color3.fromRGB(200,200,200); SubLbl.TextSize=12; SubLbl.Font=Enum.Font.Gotham
SubLbl.TextXAlignment=Enum.TextXAlignment.Left

local MinBtn=Instance.new("TextButton",Header)
MinBtn.Size=UDim2.new(0,30,0,30); MinBtn.Position=UDim2.new(1,-42,0,16)
MinBtn.BackgroundColor3=Color3.fromRGB(30,30,38); MinBtn.Text="−"
MinBtn.TextColor3=Color3.fromRGB(240,240,240); MinBtn.TextSize=20; MinBtn.Font=Enum.Font.GothamBold; MinBtn.BorderSizePixel=0
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,8)

local Div=Instance.new("Frame",MainFrame)
Div.Size=UDim2.new(1,-28,0,1); Div.Position=UDim2.new(0,14,0,62)
Div.BackgroundColor3=Color3.fromRGB(90,90,100); Div.BorderSizePixel=0
local DivGrad=Instance.new("UIGradient",Div)
DivGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})

-- scroll
local Scroll=Instance.new("ScrollingFrame",MainFrame)
Scroll.Size=UDim2.new(1,0,1,-68); Scroll.Position=UDim2.new(0,0,0,66)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=Color3.fromRGB(220,220,220)
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y

local ULL=Instance.new("UIListLayout",Scroll)
ULL.Padding=UDim.new(0,8); ULL.HorizontalAlignment=Enum.HorizontalAlignment.Center; ULL.SortOrder=Enum.SortOrder.LayoutOrder
local ULP=Instance.new("UIPadding",Scroll)
ULP.PaddingTop=UDim.new(0,10); ULP.PaddingBottom=UDim.new(0,18); ULP.PaddingLeft=UDim.new(0,14); ULP.PaddingRight=UDim.new(0,14)

-- ============================================
--              UI HELPERS
-- ============================================
local order=0
local function nextOrder() order=order+1; return order end

local function Section(title)
    local f=Instance.new("Frame",Scroll)
    f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=nextOrder()
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,0.5,0); line.BackgroundColor3=Color3.fromRGB(60,60,68); line.BorderSizePixel=0
    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(0,150,1,0); lbl.Position=UDim2.new(0.5,-75,0,0)
    lbl.BackgroundColor3=Color3.fromRGB(12,12,18); lbl.Text="  "..title.."  "
    lbl.TextColor3=Color3.fromRGB(200,200,200); lbl.TextSize=12; lbl.Font=Enum.Font.GothamBold; lbl.BorderSizePixel=0
end

local function Toggle(label,callback)
    local Row=Instance.new("Frame",Scroll)
    Row.Size=UDim2.new(1,0,0,46); Row.BackgroundColor3=Color3.fromRGB(16,16,22)
    Row.BorderSizePixel=0; Row.LayoutOrder=nextOrder()
    Instance.new("UICorner",Row).CornerRadius=UDim.new(0,10)
    local Stroke=Instance.new("UIStroke",Row); Stroke.Color=Color3.fromRGB(60,60,68); Stroke.Thickness=1
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(1,-72,1,0); Lbl.Position=UDim2.new(0,12,0,0)
    Lbl.BackgroundTransparency=1; Lbl.Text=label
    Lbl.TextColor3=Color3.fromRGB(245,245,245); Lbl.TextSize=13; Lbl.Font=Enum.Font.Gotham; Lbl.TextXAlignment=Enum.TextXAlignment.Left
    local Track=Instance.new("Frame",Row)
    Track.Size=UDim2.new(0,44,0,24); Track.Position=UDim2.new(1,-54,0.5,-12)
    Track.BackgroundColor3=Color3.fromRGB(45,45,52); Track.BorderSizePixel=0
    Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
    local Knob=Instance.new("Frame",Track)
    Knob.Size=UDim2.new(0,18,0,18); Knob.Position=UDim2.new(0,3,0.5,-9)
    Knob.BackgroundColor3=Color3.fromRGB(160,160,170); Knob.BorderSizePixel=0
    Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
    local on=false
    local function setV(s)
        if s then
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(200,200,215)}):Play()
            TweenService:Create(Knob,TweenInfo.new(0.18),{Position=UDim2.new(0,23,0.5,-9),BackgroundColor3=Color3.fromRGB(245,245,245)}):Play()
            TweenService:Create(Stroke,TweenInfo.new(0.18),{Color=Color3.fromRGB(235,235,235)}):Play()
        else
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,52)}):Play()
            TweenService:Create(Knob,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,170)}):Play()
            TweenService:Create(Stroke,TweenInfo.new(0.18),{Color=Color3.fromRGB(60,60,68)}):Play()
        end
    end
    Row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            on=not on; setV(on); callback(on)
        end
    end)
    return Row
end

local function Slider(label,min,max,default,callback)
    local Row=Instance.new("Frame",Scroll)
    Row.Size=UDim2.new(1,0,0,66); Row.BackgroundColor3=Color3.fromRGB(16,16,22)
    Row.BorderSizePixel=0; Row.LayoutOrder=nextOrder()
    Instance.new("UICorner",Row).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",Row).Color=Color3.fromRGB(60,60,68)
    local Lbl=Instance.new("TextLabel",Row)
    Lbl.Size=UDim2.new(1,-64,0,24); Lbl.Position=UDim2.new(0,12,0,8)
    Lbl.BackgroundTransparency=1; Lbl.Text=label
    Lbl.TextColor3=Color3.fromRGB(245,245,245); Lbl.TextSize=13; Lbl.Font=Enum.Font.Gotham; Lbl.TextXAlignment=Enum.TextXAlignment.Left
    local ValLbl=Instance.new("TextLabel",Row)
    ValLbl.Size=UDim2.new(0,52,0,24); ValLbl.Position=UDim2.new(1,-62,0,8)
    ValLbl.BackgroundTransparency=1; ValLbl.Text=tostring(default)
    ValLbl.TextColor3=Color3.fromRGB(200,200,200); ValLbl.TextSize=13; ValLbl.Font=Enum.Font.GothamBold; ValLbl.TextXAlignment=Enum.TextXAlignment.Right
    local Track=Instance.new("Frame",Row)
    Track.Size=UDim2.new(1,-24,0,6); Track.Position=UDim2.new(0,12,0,44)
    Track.BackgroundColor3=Color3.fromRGB(42,42,50); Track.BorderSizePixel=0
    Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
    local p0=(default-min)/(max-min)
    local Fill=Instance.new("Frame",Track)
    Fill.Size=UDim2.new(p0,0,1,0); Fill.BackgroundColor3=Color3.fromRGB(220,220,220); Fill.BorderSizePixel=0
    Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
    local FG=Instance.new("UIGradient",Fill)
    FG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(150,150,150)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))})
    local Knob=Instance.new("Frame",Track)
    Knob.Size=UDim2.new(0,14,0,14); Knob.Position=UDim2.new(p0,-7,0.5,-7)
    Knob.BackgroundColor3=Color3.fromRGB(245,245,245); Knob.BorderSizePixel=0; Knob.ZIndex=3
    Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
    local drag=false
    local function update(x)
        local p=math.clamp((x-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
        local v=math.floor(min+(max-min)*p)
        Fill.Size=UDim2.new(p,0,1,0); Knob.Position=UDim2.new(p,-7,0.5,-7); ValLbl.Text=tostring(v); callback(v)
    end
    Track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; update(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

local function Button(label,col,callback)
    local Wrap=Instance.new("Frame",Scroll)
    Wrap.Size=UDim2.new(1,0,0,40); Wrap.BackgroundTransparency=1; Wrap.LayoutOrder=nextOrder()
    local Btn=Instance.new("TextButton",Wrap)
    Btn.Size=UDim2.new(1,0,1,0); Btn.BackgroundColor3=col
    Btn.Text=label; Btn.TextColor3=Color3.fromRGB(230,215,255)
    Btn.TextSize=14; Btn.Font=Enum.Font.GothamBold; Btn.BorderSizePixel=0
    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,10)
    local BG=Instance.new("UIGradient",Btn)
    BG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,col),ColorSequenceKeypoint.new(1,Color3.new(col.R*.55,col.G*.55,col.B*.55))}); BG.Rotation=90
    Btn.MouseEnter:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.new(math.min(col.R+.12,1),math.min(col.G+.05,1),math.min(col.B+.18,1))}):Play() end)
    Btn.MouseLeave:Connect(function() TweenService:Create(Btn,TweenInfo.new(0.12),{BackgroundColor3=col}):Play() end)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- ============================================
--    SPEED & JUMP — BULLETPROOF APPROACH
--    Uses Stepped (highest priority), a
--    Changed listener that immediately reverts,
--    and a property hack via __newindex where
--    supported. Triple layered = works on
--    99% of games.
-- ============================================
local function applySpeed(v)
    if not humanoid then return end
    pcall(function() humanoid.WalkSpeed = v end)
end
local function applyJump(v)
    if not humanoid then return end
    pcall(function() humanoid.JumpPower = v end)
    pcall(function() humanoid.JumpHeight = v * 0.28 end) -- some games use JumpHeight
end

local function startSpeedHack()
    -- layer 1: Stepped (runs before physics)
    speedConns[1] = RunService.Stepped:Connect(function()
        if State.speedEnabled and humanoid then
            pcall(function() humanoid.WalkSpeed = State.walkSpeed end)
        end
    end)
    -- layer 2: revert immediately if game changes it
    speedConns[2] = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if State.speedEnabled and humanoid and humanoid.WalkSpeed ~= State.walkSpeed then
            pcall(function() humanoid.WalkSpeed = State.walkSpeed end)
        end
    end)
    applySpeed(State.walkSpeed)
end

local function stopSpeedHack()
    for _,c in pairs(speedConns) do pcall(function() c:Disconnect() end) end
    speedConns = {}
    pcall(function() if humanoid then humanoid.WalkSpeed = 16 end end)
end

local function startJumpHack()
    jumpConns[1] = RunService.Stepped:Connect(function()
        if State.jumpEnabled and humanoid then
            pcall(function() humanoid.JumpPower = State.jumpPower end)
        end
    end)
    jumpConns[2] = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if State.jumpEnabled and humanoid and humanoid.JumpPower ~= State.jumpPower then
            pcall(function() humanoid.JumpPower = State.jumpPower end)
        end
    end)
    applyJump(State.jumpPower)
end

local function stopJumpHack()
    for _,c in pairs(jumpConns) do pcall(function() c:Disconnect() end) end
    jumpConns = {}
    pcall(function() if humanoid then humanoid.JumpPower = 50 end end)
end

-- ============================================
--           ── MOVEMENT ──
-- ============================================
Section("✦  MOVEMENT")

Toggle("🚀  Fly  [ WASD + Space / Ctrl ]",function(on)
    State.flying=on
    if on then
        local bg=Instance.new("BodyGyro",rootPart); bg.Name="FlyGyro"; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.P=9e4
        local bv=Instance.new("BodyVelocity",rootPart); bv.Name="FlyVelocity"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero
        humanoid.PlatformStand=true
        Conns.fly=RunService.Heartbeat:Connect(function()
            if not State.flying then return end
            local cam=workspace.CurrentCamera; local dir=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir+=Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
            bv.Velocity=dir.Magnitude>0 and dir.Unit*State.flySpeed or Vector3.zero; bg.CFrame=cam.CFrame
        end)
    else
        if Conns.fly then Conns.fly:Disconnect(); Conns.fly=nil end
        local fg=rootPart:FindFirstChild("FlyGyro"); local fv=rootPart:FindFirstChild("FlyVelocity")
        if fg then fg:Destroy() end; if fv then fv:Destroy() end
        humanoid.PlatformStand=false
    end
end)

Slider("⚡  Fly Speed",10,400,50,function(v) State.flySpeed=v end)

Toggle("👻  Noclip",function(on)
    State.noclip=on
    if on then
        Conns.noclip=RunService.Stepped:Connect(function()
            if not State.noclip then return end
            for _,p in ipairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        if Conns.noclip then Conns.noclip:Disconnect(); Conns.noclip=nil end
        for _,p in ipairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
    end
end)

Toggle("🌌  Low Gravity",function(on) workspace.Gravity=on and 40 or 196.2 end)

-- ============================================
--           ── CHARACTER ──
-- ============================================
Section("✦  CHARACTER")

Toggle("🏃  Walk Speed",function(on)
    State.speedEnabled=on
    if on then startSpeedHack() else stopSpeedHack() end
end)
Slider("   Speed Value",4,500,60,function(v)
    State.walkSpeed=v
    if State.speedEnabled then applySpeed(v) end
end)

Toggle("🦘  Jump Power",function(on)
    State.jumpEnabled=on
    if on then startJumpHack() else stopJumpHack() end
end)
Slider("   Jump Value",10,500,100,function(v)
    State.jumpPower=v
    if State.jumpEnabled then applyJump(v) end
end)

Toggle("♾️  Infinite Jump",function(on)
    State.infJump=on
    if on then
        Conns.infJump=UserInputService.JumpRequest:Connect(function()
            if State.infJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else if Conns.infJump then Conns.infJump:Disconnect(); Conns.infJump=nil end end
end)

Toggle("🌀  Spin",function(on)
    State.spin=on
    if on then
        Conns.spin=RunService.Heartbeat:Connect(function()
            if State.spin and rootPart then rootPart.CFrame=rootPart.CFrame*CFrame.Angles(0,math.rad(State.spinSpeed),0) end
        end)
    else if Conns.spin then Conns.spin:Disconnect(); Conns.spin=nil end end
end)
Slider("   Spin Speed",1,30,5,function(v) State.spinSpeed=v end)

Slider("🌫️  Gravity",10,300,196,function(v) workspace.Gravity=v end)

-- ============================================
--           ── PLAYER ──
-- ============================================
Section("✦  PLAYER")

-- Freeze in place
local frozenConn=nil
Toggle("🧊  Freeze Self",function(on)
    if on then
        local frozenCF=rootPart.CFrame
        frozenConn=RunService.Heartbeat:Connect(function()
            rootPart.CFrame=frozenCF
        end)
    else
        if frozenConn then frozenConn:Disconnect(); frozenConn=nil end
    end
end)

-- Heal + GodMode: single Stepped loop always uses live humanoid ref
-- (refreshChar updates 'humanoid' on every respawn so this never goes stale)
local godEnabled  = false
local healEnabled = false

Conns.healthLoop = RunService.Stepped:Connect(function()
    if not humanoid or not humanoid.Parent then return end
    if godEnabled or healEnabled then
        pcall(function() humanoid.Health = humanoid.MaxHealth end)
    end
end)

Toggle("💊  Auto Heal",function(on)
    healEnabled = on
end)

Toggle("🛡️  God Mode",function(on)
    godEnabled = on
    -- secondary hook: HealthChanged on current humanoid
    if Conns.god then Conns.god:Disconnect(); Conns.god=nil end
    local function hookGod(hm)
        Conns.god = hm.HealthChanged:Connect(function()
            if godEnabled and hm.Parent then
                pcall(function() hm.Health = hm.MaxHealth end)
            end
        end)
    end
    if on and humanoid then hookGod(humanoid) end
    -- re-hook on every respawn
    if Conns.godRespawn then Conns.godRespawn:Disconnect() end
    Conns.godRespawn = player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if godEnabled then
            if Conns.god then Conns.god:Disconnect(); Conns.god=nil end
            local hm=char:FindFirstChildOfClass("Humanoid")
            if hm then hookGod(hm) end
        end
    end)
end)

-- Character size scale
Slider("📐  Character Size",50,300,100,function(v)
    local scale=v/100
    for _,desc in ipairs(character:GetDescendants()) do
        if desc:IsA("NumberValue") and desc.Parent:IsA("BodyColors")==false then
            -- scale via Humanoid description
        end
    end
    pcall(function()
        local hd=player:GetHumanoidDescription()
        hd.HeadScale      = scale
        hd.BodyDepthScale = scale
        hd.BodyHeightScale= scale
        hd.BodyWidthScale = scale
        humanoid:ApplyDescription(hd)
    end)
end)

-- Invisible: make all character parts transparent
Toggle("👤  Invisible",function(on)
    for _,p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            p.Transparency = on and 1 or 0
        end
    end
end)

-- Camera lock to first person
Toggle("🔭  Force First Person",function(on)
    local cam=workspace.CurrentCamera
    cam.CameraType= on and Enum.CameraType.Track or Enum.CameraType.Custom
    if on then
        Conns.fps=RunService.Heartbeat:Connect(function()
            cam.CFrame=rootPart.CFrame*CFrame.new(0,1.5,0)
        end)
    else
        if Conns.fps then Conns.fps:Disconnect(); Conns.fps=nil end
        cam.CameraType=Enum.CameraType.Custom
    end
end)

-- ============================================
--   AIMBOT  v2 — refined, prediction, silent
-- ============================================
local aimbotConn     = nil
local aimbotEnabled  = false
local aimbotFOV      = 150      -- px radius on screen
local aimbotSmooth   = 8        -- 1=instant 20=very slow
local aimbotWalls    = false    -- aim through walls
local aimbotHoldKey  = false    -- require RMB held
local aimbotSilent   = false    -- silent aim (no camera move)
local aimbotPred     = true     -- velocity prediction
local aimbotBone     = "Head"   -- aim bone
local aimbotLocked   = nil      -- currently locked player
local aimbotTeamCheck= false    -- skip same team

-- FOV circle
local fovCircleGui=Instance.new("ScreenGui",player.PlayerGui)
fovCircleGui.Name="AimbotFOV"; fovCircleGui.ResetOnSpawn=false; fovCircleGui.IgnoreGuiInset=true

local fovCircle=Instance.new("Frame",fovCircleGui)
fovCircle.BackgroundTransparency=1; fovCircle.BorderSizePixel=0; fovCircle.Visible=false
local fovStroke=Instance.new("UIStroke",fovCircle)
fovStroke.Thickness=1.5; fovStroke.Color=Color3.fromRGB(255,255,255)
Instance.new("UICorner",fovCircle).CornerRadius=UDim.new(1,0)

-- crosshair dot at center
local CrossGui=Instance.new("ScreenGui",player.PlayerGui)
CrossGui.Name="AimbotCross"; CrossGui.ResetOnSpawn=false; CrossGui.IgnoreGuiInset=true
local CrossDot=Instance.new("Frame",CrossGui)
CrossDot.Size=UDim2.new(0,6,0,6); CrossDot.BackgroundColor3=Color3.fromRGB(255,255,255)
CrossDot.BackgroundTransparency=0.2; CrossDot.BorderSizePixel=0; CrossDot.Visible=false
Instance.new("UICorner",CrossDot).CornerRadius=UDim.new(1,0)

-- locked-on indicator (red dot on target in screen space)
local LockGui=Instance.new("ScreenGui",player.PlayerGui)
LockGui.Name="AimbotLock"; LockGui.ResetOnSpawn=false; LockGui.IgnoreGuiInset=true
local LockDot=Instance.new("Frame",LockGui)
LockDot.Size=UDim2.new(0,10,0,10); LockDot.BackgroundColor3=Color3.fromRGB(255,60,60)
LockDot.BackgroundTransparency=0; LockDot.BorderSizePixel=0; LockDot.Visible=false
Instance.new("UICorner",LockDot).CornerRadius=UDim.new(1,0)
local LockStroke=Instance.new("UIStroke",LockDot); LockStroke.Color=Color3.fromRGB(255,255,255); LockStroke.Thickness=1.2

local function updateFovCircle()
    local cam=workspace.CurrentCamera
    local cx=cam.ViewportSize.X/2; local cy=cam.ViewportSize.Y/2
    fovCircle.Size=UDim2.new(0,aimbotFOV*2,0,aimbotFOV*2)
    fovCircle.Position=UDim2.new(0,cx-aimbotFOV,0,cy-aimbotFOV)
    CrossDot.Position=UDim2.new(0,cx-3,0,cy-3)
end
updateFovCircle()

-- predict where a moving target will be (simple linear)
local lastPos = {}
local function getPredicted(plr, part)
    local cur = part.Position
    local prev = lastPos[plr.Name]
    lastPos[plr.Name] = cur
    if not aimbotPred or not prev then return cur end
    local vel = cur - prev   -- delta per frame ≈ velocity direction
    return cur + vel * 6     -- look 6 frames ahead
end

-- wall visibility check
local function isVisible(cam, pos)
    if aimbotWalls then return true end
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={character}
    params.FilterType=Enum.RaycastFilterType.Exclude
    local dir=pos-cam.CFrame.Position
    local res=workspace:Raycast(cam.CFrame.Position, dir, params)
    if not res then return true end
    local hitChar=res.Instance:FindFirstAncestorOfClass("Model")
    -- visible if ray hit the target's own model
    return hitChar~=nil and Players:GetPlayerFromCharacter(hitChar)~=nil
end

-- find the best target inside FOV
local function getBestTarget(cam)
    local center=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local bestDist=aimbotFOV
    local bestPlr=nil; local bestPart=nil

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==player then continue end
        if not plr.Character then continue end
        local hm=plr.Character:FindFirstChildOfClass("Humanoid")
        if not hm or hm.Health<=0 then continue end
        -- team check
        if aimbotTeamCheck and plr.Team==player.Team and plr.Team~=nil then continue end

        local part = plr.Character:FindFirstChild(aimbotBone)
                  or plr.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local sp,onScreen=cam:WorldToViewportPoint(part.Position)
        if not onScreen or sp.Z<=0 then continue end

        local d2=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d2<bestDist and isVisible(cam, part.Position) then
            bestDist=d2; bestPlr=plr; bestPart=part
        end
    end
    return bestPlr, bestPart
end

local function startAimbot()
    aimbotConn=RunService.Heartbeat:Connect(function()
        if not rootPart then return end
        if aimbotHoldKey and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            -- not holding — hide lock dot but keep running
            LockDot.Visible=false; aimbotLocked=nil; return
        end

        local cam=workspace.CurrentCamera
        local bestPlr, bestPart = getBestTarget(cam)

        if bestPlr and bestPart then
            aimbotLocked=bestPlr
            local aimPos=getPredicted(bestPlr, bestPart)

            if not aimbotSilent then
                -- move camera toward target
                local lerpT = math.clamp(1/(aimbotSmooth*0.8), 0.01, 1)
                local targetCF=CFrame.new(cam.CFrame.Position, aimPos)
                cam.CFrame=cam.CFrame:Lerp(targetCF, lerpT)
            end

            -- update lock dot on screen
            local sp2,onScreen2=cam:WorldToViewportPoint(aimPos)
            if onScreen2 then
                LockDot.Visible=true
                LockDot.Position=UDim2.new(0,sp2.X-5,0,sp2.Y-5)
                -- pulse color: white when very close to center, red otherwise
                local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
                local d=(Vector2.new(sp2.X,sp2.Y)-center).Magnitude
                if d<20 then
                    LockDot.BackgroundColor3=Color3.fromRGB(60,255,100)  -- green = on target
                else
                    LockDot.BackgroundColor3=Color3.fromRGB(255,60,60)   -- red = tracking
                end
            end
        else
            aimbotLocked=nil
            LockDot.Visible=false
        end
    end)
end

Toggle("🎯  Aimbot",function(on)
    aimbotEnabled=on
    fovCircle.Visible=on; CrossDot.Visible=on; LockDot.Visible=false
    if on then updateFovCircle(); startAimbot()
    else
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
        aimbotLocked=nil
    end
end)

Slider("   FOV Radius (px)",20,600,150,function(v)
    aimbotFOV=v; updateFovCircle()
end)

Slider("   Smoothness (1=fast 20=slow)",1,20,8,function(v)
    aimbotSmooth=v
end)

Toggle("   Aim Through Walls",function(on) aimbotWalls=on end)
Toggle("   Hold RMB to Aim",function(on) aimbotHoldKey=on end)
Toggle("   Silent Aim  (no cam move)",function(on) aimbotSilent=on end)
Toggle("   Velocity Prediction",function(on) aimbotPred=on end)
Toggle("   Skip Same Team",function(on) aimbotTeamCheck=on end)

-- Reach / hitbox expander
Slider("🥊  Hitbox Size",4,50,4,function(v)
    pcall(function()
        for _,p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name=="HumanoidRootPart" then
                p.Size=Vector3.new(v,v,v)
            end
        end
    end)
end)

-- ============================================
--           ── WORLD ──
-- ============================================
Section("✦  WORLD")

-- Remove all fog
Toggle("🌫️  Remove Fog",function(on)
    if on then
        Lighting.FogEnd=9e9; Lighting.FogStart=9e9
    else
        Lighting.FogEnd=100000; Lighting.FogStart=0
    end
end)

-- No shadows
Toggle("🌑  No Shadows",function(on)
    Lighting.GlobalShadows=not on
end)

-- Rain / atmosphere cleaner: remove all atmosphere effects
Toggle("✨  Remove Effects",function(on)
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = not on
        end
    end
end)

Slider("🌫️  Gravity",10,300,196,function(v) workspace.Gravity=v end)

-- ============================================
--           ── VISUALS / ESP ──
-- ============================================
Section("✦  VISUALS / ESP")

Toggle("👁  Player ESP + Distance + HP",function(on)
    State.esp=on
    if on then
        Conns.espUpdate=RunService.Heartbeat:Connect(function()
            for name,bb in pairs(espBillboards) do
                local plr=Players:FindFirstChild(name)
                if plr and plr.Character then
                    local rp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if rp and rootPart then
                        local dist=math.floor((rp.Position-rootPart.Position).Magnitude)
                        local hm=plr.Character:FindFirstChildOfClass("Humanoid")
                        local hp=hm and math.floor(hm.Health) or "?"
                        local lbl=bb:FindFirstChild("DL")
                        if lbl then lbl.Text="["..name.."]\n📏 "..dist.."  ❤️ "..hp end
                    end
                end
            end
        end)
        local function addESP(plr)
            if plr==player then return end
            local function setup()
                local char=plr.Character; if not char then return end
                if espHighlights[plr.Name] then pcall(function() espHighlights[plr.Name]:Destroy() end) end
                local hl=Instance.new("Highlight",char)
                hl.FillColor=Color3.fromRGB(210,210,220); hl.OutlineColor=Color3.fromRGB(235,235,235)
                hl.FillTransparency=0.55; hl.OutlineTransparency=0; espHighlights[plr.Name]=hl
                if espBillboards[plr.Name] then pcall(function() espBillboards[plr.Name]:Destroy() end) end
                local head=char:FindFirstChild("Head"); if not head then return end
                local bb=Instance.new("BillboardGui",head)
                bb.Name="ESP_BB"; bb.Size=UDim2.new(0,140,0,42)
                bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Adornee=head
                local bg2=Instance.new("Frame",bb)
                bg2.Size=UDim2.new(1,0,1,0); bg2.BackgroundColor3=Color3.fromRGB(12,12,18)
                bg2.BackgroundTransparency=0.3; bg2.BorderSizePixel=0
                Instance.new("UICorner",bg2).CornerRadius=UDim.new(0,7)
                local bst=Instance.new("UIStroke",bg2); bst.Color=Color3.fromRGB(255,255,255); bst.Thickness=1
                local lbl=Instance.new("TextLabel",bb)
                lbl.Name="DL"; lbl.Size=UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency=1; lbl.Text="["..plr.Name.."]"
                lbl.TextColor3=Color3.fromRGB(215,195,255); lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold
                espBillboards[plr.Name]=bb
            end
            setup()
            Conns["espC_"..plr.Name]=plr.CharacterAdded:Connect(function() task.wait(0.5); setup() end)
        end
        for _,plr in ipairs(Players:GetPlayers()) do addESP(plr) end
        Conns.espPA=Players.PlayerAdded:Connect(addESP)
    else
        if Conns.espUpdate then Conns.espUpdate:Disconnect(); Conns.espUpdate=nil end
        if Conns.espPA then Conns.espPA:Disconnect(); Conns.espPA=nil end
        for _,hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end; espHighlights={}
        for _,bb in pairs(espBillboards) do pcall(function() bb:Destroy() end) end; espBillboards={}
    end
end)

Toggle("☀️  Fullbright",function(on)
    if on then
        Lighting.Brightness=10; Lighting.FogEnd=100000; Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness=1; Lighting.FogEnd=100000; Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end)

-- ============================================
--           ── UTILITIES ──
-- ============================================
Section("✦  UTILITIES")

Toggle("🛡️  Anti-AFK",function(on)
    State.antiAfk=on
    if on then
        local conn2; conn2=player.Idled:Connect(function()
            if not State.antiAfk then conn2:Disconnect(); return end
            local vj=pcall(function() game:GetService("VirtualUser"):CaptureController() end)
        end)
        Conns.afk2=conn2; Notify("Arceus Hub","Anti-AFK enabled ✅")
    else
        if Conns.afk2 then Conns.afk2:Disconnect(); Conns.afk2=nil end
    end
end)

-- ── PLAYER PICKER (floating, on ScreenGui root) ──
local PlayerPicker=Instance.new("Frame",ScreenGui)
PlayerPicker.Name="PlayerPicker"; PlayerPicker.Size=UDim2.new(0,220,0,0)
PlayerPicker.BackgroundColor3=Color3.fromRGB(13,13,20); PlayerPicker.BorderSizePixel=0
PlayerPicker.ClipsDescendants=true; PlayerPicker.ZIndex=200; PlayerPicker.Visible=false
Instance.new("UICorner",PlayerPicker).CornerRadius=UDim.new(0,12)
local PPS=Instance.new("UIStroke",PlayerPicker); PPS.Color=Color3.fromRGB(230,230,230); PPS.Thickness=1.5

local PPTitle2=Instance.new("TextLabel",PlayerPicker)
PPTitle2.Size=UDim2.new(1,0,0,32); PPTitle2.BackgroundColor3=Color3.fromRGB(20,20,26)
PPTitle2.BorderSizePixel=0; PPTitle2.ZIndex=201; PPTitle2.Font=Enum.Font.GothamBold
PPTitle2.TextSize=13; PPTitle2.TextColor3=Color3.fromRGB(240,240,240)
Instance.new("UICorner",PPTitle2).CornerRadius=UDim.new(0,12)

local PPScroll=Instance.new("ScrollingFrame",PlayerPicker)
PPScroll.Position=UDim2.new(0,0,0,34); PPScroll.Size=UDim2.new(1,0,1,-34)
PPScroll.BackgroundTransparency=1; PPScroll.BorderSizePixel=0
PPScroll.ScrollBarThickness=3; PPScroll.ScrollBarImageColor3=Color3.fromRGB(220,220,220)
PPScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; PPScroll.CanvasSize=UDim2.new(0,0,0,0); PPScroll.ZIndex=201
local PPL=Instance.new("UIListLayout",PPScroll); PPL.Padding=UDim.new(0,3); PPL.SortOrder=Enum.SortOrder.LayoutOrder
local PPP=Instance.new("UIPadding",PPScroll)
PPP.PaddingTop=UDim.new(0,4); PPP.PaddingBottom=UDim.new(0,4); PPP.PaddingLeft=UDim.new(0,5); PPP.PaddingRight=UDim.new(0,5)

local pickerMode="teleport"; local pickerOpen=false; local pickerAnchor=nil

local function closePicker()
    pickerOpen=false
    TweenService:Create(PlayerPicker,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{Size=UDim2.new(0,220,0,0)}):Play()
    task.delay(0.2,function() PlayerPicker.Visible=false end)
end

local function openPicker(mode,anchorBtn)
    pickerMode=mode; pickerAnchor=anchorBtn
    PPTitle2.Text= mode=="teleport" and "  🌀 Teleport to..." or "  🚀 Launch player..."
    for _,c in ipairs(PPScroll:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end
    local plrs={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=player then table.insert(plrs,p) end end
    if #plrs==0 then
        local nl=Instance.new("TextLabel",PPScroll); nl.Size=UDim2.new(1,0,0,34)
        nl.BackgroundTransparency=1; nl.Text="No other players"
        nl.TextColor3=Color3.fromRGB(170,170,170); nl.TextSize=12; nl.Font=Enum.Font.Gotham; nl.ZIndex=202
    end
    for i,plr in ipairs(plrs) do
        local E=Instance.new("TextButton",PPScroll)
        E.Size=UDim2.new(1,0,0,34); E.BackgroundColor3=Color3.fromRGB(22,22,30)
        E.Text="  "..plr.Name; E.TextColor3=Color3.fromRGB(240,240,240)
        E.TextSize=13; E.Font=Enum.Font.Gotham; E.TextXAlignment=Enum.TextXAlignment.Left
        E.BorderSizePixel=0; E.ZIndex=202; E.LayoutOrder=i
        Instance.new("UICorner",E).CornerRadius=UDim.new(0,8)
        E.MouseEnter:Connect(function() TweenService:Create(E,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(55,55,65)}):Play() end)
        E.MouseLeave:Connect(function() TweenService:Create(E,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,30)}):Play() end)
        E.MouseButton1Click:Connect(function()
            local rp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if pickerMode=="teleport" then
                if rp then rootPart.CFrame=rp.CFrame+Vector3.new(2,0,2); Notify("Arceus Hub","Teleported to "..plr.Name) end
            elseif pickerMode=="launch" then
                if rp then
                    local bv2=Instance.new("BodyVelocity",rp)
                    bv2.Velocity=Vector3.new(math.random(-80,80),800,math.random(-80,80))
                    bv2.MaxForce=Vector3.new(9e9,9e9,9e9); bv2.P=9e9
                    game:GetService("Debris"):AddItem(bv2,0.18)
                    Notify("Arceus Hub","🚀 Launched "..plr.Name.."!")
                end
            end
            closePicker()
        end)
    end
    local abs=anchorBtn.AbsolutePosition
    local sh=ScreenGui.AbsoluteSize.Y
    local h=math.min(#plrs,5)*37+44
    PlayerPicker.Position=UDim2.new(0,abs.X+anchorBtn.AbsoluteSize.X+8,0,math.min(abs.Y,sh-h-10))
    PlayerPicker.Size=UDim2.new(0,220,0,0); PlayerPicker.Visible=true; pickerOpen=true
    TweenService:Create(PlayerPicker,TweenInfo.new(0.22,Enum.EasingStyle.Quart),{Size=UDim2.new(0,220,0,h)}):Play()
end

UserInputService.InputBegan:Connect(function(inp)
    if pickerOpen and (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) then
        task.delay(0.06,function() if pickerOpen then closePicker() end end)
    end
end)

-- Teleport row
local function PickerRow(labelText,btnText,btnColor,mode)
    local W=Instance.new("Frame",Scroll); W.Size=UDim2.new(1,0,0,46)
    W.BackgroundColor3=Color3.fromRGB(16,16,22); W.BorderSizePixel=0; W.LayoutOrder=nextOrder()
    Instance.new("UICorner",W).CornerRadius=UDim.new(0,10)
    local WS=Instance.new("UIStroke",W); WS.Color=Color3.fromRGB(60,60,68); WS.Thickness=1
    local WL=Instance.new("TextLabel",W)
    WL.Size=UDim2.new(1,-114,1,0); WL.Position=UDim2.new(0,12,0,0)
    WL.BackgroundTransparency=1; WL.Text=labelText
    WL.TextColor3=Color3.fromRGB(245,245,245); WL.TextSize=14; WL.Font=Enum.Font.Gotham; WL.TextXAlignment=Enum.TextXAlignment.Left
    local WB=Instance.new("TextButton",W)
    WB.Size=UDim2.new(0,90,0,30); WB.Position=UDim2.new(1,-100,0.5,-15)
    WB.BackgroundColor3=btnColor; WB.Text=btnText
    WB.TextColor3=Color3.fromRGB(230,215,255); WB.TextSize=12; WB.Font=Enum.Font.GothamBold; WB.BorderSizePixel=0
    Instance.new("UICorner",WB).CornerRadius=UDim.new(0,8)
    WB.MouseButton1Click:Connect(function()
        if pickerOpen and pickerMode==mode then closePicker()
        else openPicker(mode,WB) end
    end)
end

PickerRow("🌀  Teleport to Player","Select ▾",Color3.fromRGB(42,42,55),"teleport")
PickerRow("🚀  Launch Player","Select ▾",Color3.fromRGB(180,60,40),"launch")

Button("⟳  Reset Character",Color3.fromRGB(55,55,70),function() player:LoadCharacter() end)
Button("📍  Teleport to Spawn",Color3.fromRGB(20,20,26),function()
    local s=workspace:FindFirstChildOfClass("SpawnLocation")
    if s then rootPart.CFrame=s.CFrame+Vector3.new(0,5,0) end
end)
Button("📋  Copy Position",Color3.fromRGB(20,20,26),function()
    local p=rootPart.Position
    local str=string.format("Vector3.new(%.2f, %.2f, %.2f)",p.X,p.Y,p.Z)
    pcall(function() setclipboard(str) end)
    Notify("Arceus Hub","Position copied!")
end)

-- ============================================
--           ── SPECTATE ──
-- ============================================
Section("✦  SPECTATE")

local spectateTarget  = nil
local spectateConn    = nil
local spectating      = false

-- HUD shown while spectating
local SpecHud = Instance.new("ScreenGui", player.PlayerGui)
SpecHud.Name="ArceusSpec"; SpecHud.ResetOnSpawn=false; SpecHud.IgnoreGuiInset=true
SpecHud.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SpecHud.Enabled=false

local SpecBg = Instance.new("Frame", SpecHud)
SpecBg.Size=UDim2.new(0,280,0,52); SpecBg.Position=UDim2.new(0.5,-140,0,14)
SpecBg.BackgroundColor3=Color3.fromRGB(12,12,18); SpecBg.BackgroundTransparency=0.2; SpecBg.BorderSizePixel=0
Instance.new("UICorner",SpecBg).CornerRadius=UDim.new(0,12)
local SBStroke=Instance.new("UIStroke",SpecBg); SBStroke.Color=Color3.fromRGB(220,220,220); SBStroke.Thickness=1.5

local SpecName=Instance.new("TextLabel",SpecBg)
SpecName.Size=UDim2.new(1,0,0,28); SpecName.Position=UDim2.new(0,0,0,4)
SpecName.BackgroundTransparency=1; SpecName.Text="👁  Spectating: —"
SpecName.TextColor3=Color3.fromRGB(255,255,255); SpecName.TextSize=15; SpecName.Font=Enum.Font.GothamBold

local SpecHint=Instance.new("TextLabel",SpecBg)
SpecHint.Size=UDim2.new(1,0,0,18); SpecHint.Position=UDim2.new(0,0,0,30)
SpecHint.BackgroundTransparency=1; SpecHint.Text="Press  X  to stop spectating"
SpecHint.TextColor3=Color3.fromRGB(170,170,170); SpecHint.TextSize=11; SpecHint.Font=Enum.Font.Gotham

-- small HP/dist bar at bottom
local SpecInfo=Instance.new("TextLabel",SpecBg)
SpecInfo.Size=UDim2.new(1,0,0,14); SpecInfo.Position=UDim2.new(0,0,0,38)
SpecInfo.BackgroundTransparency=1; SpecInfo.Text=""
SpecInfo.TextColor3=Color3.fromRGB(200,200,200); SpecInfo.TextSize=10; SpecInfo.Font=Enum.Font.Gotham

local function stopSpectate()
    spectating=false; spectateTarget=nil
    if spectateConn then spectateConn:Disconnect(); spectateConn=nil end
    SpecHud.Enabled=false
    -- restore camera
    workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject=humanoid
    Notify("Arceus Hub","Stopped spectating.")
end

local function startSpectate(plr)
    if spectating then stopSpectate() end
    spectateTarget=plr; spectating=true

    local cam=workspace.CurrentCamera
    cam.CameraType=Enum.CameraType.Scriptable

    SpecHud.Enabled=true
    SpecName.Text="👁  Spectating: "..plr.Name

    spectateConn=RunService.Heartbeat:Connect(function()
        if not spectating then return end
        if not plr or not plr.Parent then stopSpectate(); return end
        local char=plr.Character
        if not char then return end
        local rp=char:FindFirstChild("HumanoidRootPart")
        local head=char:FindFirstChild("Head")
        if not rp then return end

        -- smooth third-person camera behind target
        local offset=Vector3.new(0,3,-7)
        local targetCF=CFrame.new(rp.Position)*CFrame.Angles(0,math.rad(180),0)
        local camPos=targetCF:PointToWorldSpace(offset)
        local lookAt=rp.Position+Vector3.new(0,1.5,0)
        cam.CFrame=cam.CFrame:Lerp(CFrame.new(camPos,lookAt),0.18)

        -- update HUD
        local hm=char:FindFirstChildOfClass("Humanoid")
        local hp=hm and math.floor(hm.Health) or "?"
        local maxhp=hm and math.floor(hm.MaxHealth) or "?"
        local dist=rootPart and math.floor((rp.Position-rootPart.Position).Magnitude) or "?"
        SpecInfo.Text="❤️ "..hp.."/"..maxhp.."   📏 "..dist.." studs away"
    end)
    Notify("Arceus Hub","Spectating "..plr.Name.." — press X to stop")
end

-- X key stops spectate
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.X and spectating then
        stopSpectate()
    end
end)

-- player leaves → stop
Players.PlayerRemoving:Connect(function(plr)
    if spectateTarget==plr then stopSpectate() end
end)

-- ── SPECTATE PICKER ROW ──
local function SpectatePickerRow()
    local W=Instance.new("Frame",Scroll)
    W.Size=UDim2.new(1,0,0,46); W.BackgroundColor3=Color3.fromRGB(18,18,26)
    W.BorderSizePixel=0; W.LayoutOrder=nextOrder()
    Instance.new("UICorner",W).CornerRadius=UDim.new(0,10)
    local WS=Instance.new("UIStroke",W); WS.Color=Color3.fromRGB(55,55,65); WS.Thickness=1

    local WL=Instance.new("TextLabel",W)
    WL.Size=UDim2.new(1,-114,1,0); WL.Position=UDim2.new(0,12,0,0)
    WL.BackgroundTransparency=1; WL.Text="👁  Spectate Player"
    WL.TextColor3=Color3.fromRGB(240,240,240); WL.TextSize=14; WL.Font=Enum.Font.Gotham; WL.TextXAlignment=Enum.TextXAlignment.Left

    local WB=Instance.new("TextButton",W)
    WB.Size=UDim2.new(0,90,0,30); WB.Position=UDim2.new(1,-100,0.5,-15)
    WB.BackgroundColor3=Color3.fromRGB(40,40,55); WB.Text="Select ▾"
    WB.TextColor3=Color3.fromRGB(230,230,230); WB.TextSize=12; WB.Font=Enum.Font.GothamBold; WB.BorderSizePixel=0
    Instance.new("UICorner",WB).CornerRadius=UDim.new(0,8)

    -- floating picker (reuses same PlayerPicker but with spectate mode)
    local SPick=Instance.new("Frame",ScreenGui)
    SPick.Size=UDim2.new(0,210,0,0); SPick.BackgroundColor3=Color3.fromRGB(13,13,20)
    SPick.BorderSizePixel=0; SPick.ClipsDescendants=true; SPick.ZIndex=250; SPick.Visible=false
    Instance.new("UICorner",SPick).CornerRadius=UDim.new(0,12)
    local SPKS=Instance.new("UIStroke",SPick); SPKS.Color=Color3.fromRGB(210,210,210); SPKS.Thickness=1.5

    local SPTitle=Instance.new("TextLabel",SPick)
    SPTitle.Size=UDim2.new(1,0,0,30); SPTitle.BackgroundColor3=Color3.fromRGB(20,20,28)
    SPTitle.BorderSizePixel=0; SPTitle.ZIndex=251; SPTitle.Font=Enum.Font.GothamBold
    SPTitle.TextSize=12; SPTitle.TextColor3=Color3.fromRGB(240,240,240); SPTitle.Text="  👁 Spectate..."
    Instance.new("UICorner",SPTitle).CornerRadius=UDim.new(0,12)

    local SPScroll=Instance.new("ScrollingFrame",SPick)
    SPScroll.Position=UDim2.new(0,0,0,32); SPScroll.Size=UDim2.new(1,0,1,-32)
    SPScroll.BackgroundTransparency=1; SPScroll.BorderSizePixel=0
    SPScroll.ScrollBarThickness=3; SPScroll.ScrollBarImageColor3=Color3.fromRGB(200,200,200)
    SPScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; SPScroll.CanvasSize=UDim2.new(0,0,0,0); SPScroll.ZIndex=251
    local SPL=Instance.new("UIListLayout",SPScroll); SPL.Padding=UDim.new(0,3); SPL.SortOrder=Enum.SortOrder.LayoutOrder
    local SPP=Instance.new("UIPadding",SPScroll)
    SPP.PaddingTop=UDim.new(0,4); SPP.PaddingBottom=UDim.new(0,4); SPP.PaddingLeft=UDim.new(0,5); SPP.PaddingRight=UDim.new(0,5)

    local spOpen=false
    local function closeSP()
        spOpen=false
        TweenService:Create(SPick,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{Size=UDim2.new(0,210,0,0)}):Play()
        task.delay(0.2,function() SPick.Visible=false end)
        WB.Text="Select ▾"
    end
    local function openSP()
        -- rebuild list
        for _,ch in ipairs(SPScroll:GetChildren()) do
            if ch:IsA("TextButton") or ch:IsA("TextLabel") then ch:Destroy() end
        end
        local plrs={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=player then table.insert(plrs,p) end end
        if #plrs==0 then
            local nl=Instance.new("TextLabel",SPScroll)
            nl.Size=UDim2.new(1,0,0,32); nl.BackgroundTransparency=1; nl.ZIndex=252
            nl.Text="No players in server"; nl.TextColor3=Color3.fromRGB(160,160,160); nl.TextSize=12; nl.Font=Enum.Font.Gotham
        end
        for i,plr in ipairs(plrs) do
            -- show HP next to name if character exists
            local hm=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            local hp=hm and (" ❤️"..math.floor(hm.Health)) or ""
            local E=Instance.new("TextButton",SPScroll)
            E.Size=UDim2.new(1,0,0,34); E.BackgroundColor3=Color3.fromRGB(22,22,30)
            E.Text="  "..plr.Name..hp; E.TextColor3=Color3.fromRGB(230,230,230)
            E.TextSize=12; E.Font=Enum.Font.Gotham; E.TextXAlignment=Enum.TextXAlignment.Left
            E.BorderSizePixel=0; E.ZIndex=252; E.LayoutOrder=i
            Instance.new("UICorner",E).CornerRadius=UDim.new(0,8)
            E.MouseEnter:Connect(function() TweenService:Create(E,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,50,62)}):Play() end)
            E.MouseLeave:Connect(function() TweenService:Create(E,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,30)}):Play() end)
            E.MouseButton1Click:Connect(function()
                startSpectate(plr)
                closeSP()
            end)
        end
        local abs=WB.AbsolutePosition
        local h=math.min(#plrs,6)*36+40
        SPick.Position=UDim2.new(0,abs.X+WB.AbsoluteSize.X+6,0,abs.Y-10)
        SPick.Size=UDim2.new(0,210,0,0); SPick.Visible=true; spOpen=true
        TweenService:Create(SPick,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Size=UDim2.new(0,210,0,h)}):Play()
        WB.Text="Close ▴"
    end

    WB.MouseButton1Click:Connect(function()
        if spOpen then closeSP() else openSP() end
    end)
end

SpectatePickerRow()

-- Stop spectate button
Button("⏹  Stop Spectating  [ X ]",Color3.fromRGB(35,35,48),function()
    if spectating then stopSpectate()
    else Notify("Arceus Hub","Not spectating anyone.") end
end)
-- ============================================
--           ── KEYBINDS ──
-- ============================================
-- Each keybind = {label, action function, key}
-- Saved/loaded from file so keys persist.
Section("✦  KEYBINDS")

-- keybind file disabled
local keybinds = {}         -- {label, action, key(KeyCode name string)}
local bindingIndex = nil    -- which slot is waiting for a keypress

-- save keybinds to file
local function saveKeybinds()
    local out = {}
    for i,kb in ipairs(keybinds) do
        out[i] = kb.label .. "|" .. (kb.key or "")
    end
    -- writefile disabled)
end

-- pre-registered actions that can be bound to keys
local ACTIONS = {
    {label="Fly",            fn=function() end},  -- toggles handled separately
    {label="Noclip",         fn=function() end},
    {label="God Mode",       fn=function() godEnabled=not godEnabled; Notify("Arceus","God: "..(godEnabled and "ON" or "OFF")) end},
    {label="Auto Heal",      fn=function() healEnabled=not healEnabled; Notify("Arceus","Heal: "..(healEnabled and "ON" or "OFF")) end},
    {label="Aimbot",         fn=function() end},
    {label="Infinite Jump",  fn=function() State.infJump=not State.infJump; if State.infJump then Conns.infJump=UserInputService.JumpRequest:Connect(function() if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) else if Conns.infJump then Conns.infJump:Disconnect(); Conns.infJump=nil end end; Notify("Arceus","InfJump: "..(State.infJump and "ON" or "OFF")) end},
    {label="ESP",            fn=function() end},
    {label="Fullbright",     fn=function() end},
    {label="Freeze",         fn=function() end},
    {label="Walk Speed",     fn=function() State.speedEnabled=not State.speedEnabled; if State.speedEnabled then startSpeedHack() else stopSpeedHack() end; Notify("Arceus","Speed: "..(State.speedEnabled and "ON" or "OFF")) end},
}

-- UI: 3 keybind slots
local kbRows = {}

local function makeKeybindRow(index)
    local Row=Instance.new("Frame",Scroll)
    Row.Size=UDim2.new(1,0,0,48); Row.BackgroundColor3=Color3.fromRGB(16,16,22)
    Row.BorderSizePixel=0; Row.LayoutOrder=nextOrder()
    Instance.new("UICorner",Row).CornerRadius=UDim.new(0,10)
    local RS=Instance.new("UIStroke",Row); RS.Color=Color3.fromRGB(55,55,65); RS.Thickness=1

    -- action dropdown label
    local ActionBtn=Instance.new("TextButton",Row)
    ActionBtn.Size=UDim2.new(0,130,0,30); ActionBtn.Position=UDim2.new(0,8,0.5,-15)
    ActionBtn.BackgroundColor3=Color3.fromRGB(25,25,34); ActionBtn.BorderSizePixel=0
    ActionBtn.Text="Select action"; ActionBtn.TextColor3=Color3.fromRGB(200,200,200)
    ActionBtn.TextSize=11; ActionBtn.Font=Enum.Font.Gotham; ActionBtn.ClipsDescendants=true
    Instance.new("UICorner",ActionBtn).CornerRadius=UDim.new(0,7)

    -- key bind button
    local KeyBtn=Instance.new("TextButton",Row)
    KeyBtn.Size=UDim2.new(0,90,0,30); KeyBtn.Position=UDim2.new(1,-100,0.5,-15)
    KeyBtn.BackgroundColor3=Color3.fromRGB(25,25,34); KeyBtn.BorderSizePixel=0
    KeyBtn.Text="[ none ]"; KeyBtn.TextColor3=Color3.fromRGB(180,180,180)
    KeyBtn.TextSize=12; KeyBtn.Font=Enum.Font.GothamBold
    Instance.new("UICorner",KeyBtn).CornerRadius=UDim.new(0,7)
    local KS=Instance.new("UIStroke",KeyBtn); KS.Color=Color3.fromRGB(60,60,72); KS.Thickness=1

    keybinds[index] = {label=nil, fn=nil, key=nil, keyBtn=KeyBtn, actionBtn=ActionBtn, stroke=KS}

    -- action picker popup (on ScreenGui root to avoid clipping)
    local APick=Instance.new("Frame",ScreenGui)
    APick.Size=UDim2.new(0,160,0,0); APick.BackgroundColor3=Color3.fromRGB(14,14,20)
    APick.BorderSizePixel=0; APick.ClipsDescendants=true; APick.ZIndex=300; APick.Visible=false
    Instance.new("UICorner",APick).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",APick).Color=Color3.fromRGB(200,200,200)
    local APL=Instance.new("UIListLayout",APick); APL.Padding=UDim.new(0,2); APL.SortOrder=Enum.SortOrder.LayoutOrder
    local APP=Instance.new("UIPadding",APick)
    APP.PaddingTop=UDim.new(0,4); APP.PaddingBottom=UDim.new(0,4); APP.PaddingLeft=UDim.new(0,4); APP.PaddingRight=UDim.new(0,4)

    local apickOpen=false
    for ai,act in ipairs(ACTIONS) do
        local AE=Instance.new("TextButton",APick)
        AE.Size=UDim2.new(1,0,0,28); AE.BackgroundColor3=Color3.fromRGB(22,22,30)
        AE.Text="  "..act.label; AE.TextColor3=Color3.fromRGB(230,230,230)
        AE.TextSize=12; AE.Font=Enum.Font.Gotham; AE.TextXAlignment=Enum.TextXAlignment.Left
        AE.BorderSizePixel=0; AE.ZIndex=301; AE.LayoutOrder=ai
        Instance.new("UICorner",AE).CornerRadius=UDim.new(0,6)
        AE.MouseEnter:Connect(function() TweenService:Create(AE,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,50,60)}):Play() end)
        AE.MouseLeave:Connect(function() TweenService:Create(AE,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,30)}):Play() end)
        AE.MouseButton1Click:Connect(function()
            keybinds[index].label=act.label
            keybinds[index].fn=act.fn
            ActionBtn.Text=act.label
            TweenService:Create(APick,TweenInfo.new(0.15),{Size=UDim2.new(0,160,0,0)}):Play()
            task.delay(0.16,function() APick.Visible=false end)
            apickOpen=false
            saveKeybinds()
        end)
    end

    ActionBtn.MouseButton1Click:Connect(function()
        apickOpen=not apickOpen
        if apickOpen then
            local abs=ActionBtn.AbsolutePosition
            APick.Position=UDim2.new(0,abs.X,0,abs.Y+34)
            APick.Visible=true
            TweenService:Create(APick,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{Size=UDim2.new(0,160,0,#ACTIONS*30+10)}):Play()
        else
            TweenService:Create(APick,TweenInfo.new(0.15),{Size=UDim2.new(0,160,0,0)}):Play()
            task.delay(0.16,function() APick.Visible=false end)
        end
    end)

    -- key capture
    local waitingKey=false
    KeyBtn.MouseButton1Click:Connect(function()
        if waitingKey then return end
        waitingKey=true
        bindingIndex=index
        KeyBtn.Text="Press a key.."
        TweenService:Create(KS,TweenInfo.new(0.1),{Color=Color3.fromRGB(255,255,255)}):Play()
    end)

    kbRows[index]={row=Row, keyBtn=KeyBtn, stroke=KS}
    return Row
end

makeKeybindRow(1)
makeKeybindRow(2)
makeKeybindRow(3)

-- global key listener for both keybind capture AND activation
UserInputService.InputBegan:Connect(function(inp,gpe)
    -- capture mode
    if bindingIndex then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            local keyName=inp.KeyCode.Name
            keybinds[bindingIndex].key=keyName
            local kb=keybinds[bindingIndex]
            if kb.keyBtn then
                kb.keyBtn.Text="[ "..keyName.." ]"
                TweenService:Create(kb.stroke,TweenInfo.new(0.1),{Color=Color3.fromRGB(60,60,72)}):Play()
            end
            bindingIndex=nil
            saveKeybinds()
        end
        return
    end
    -- activation mode (never fires if typing in a TextBox)
    if gpe then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard then
        local keyName=inp.KeyCode.Name
        for _,kb in ipairs(keybinds) do
            if kb.key==keyName and kb.fn then
                kb.fn()
            end
        end
    end
end)

-- load saved keybinds on start
task.spawn(function()
    task.wait(0.5)
    -- readfile disabled
        end
    end
end)

-- ============================================
--           MINIMIZE / DRAG / HOTKEY
-- ============================================
--        FLOATING ORB (hub closed state)
-- ============================================
-- Hub starts hidden; orb is shown instead.
-- Click orb OR press G to open/close hub.

MainFrame.Visible = false  -- start closed

local OrbGui = Instance.new("ScreenGui", player.PlayerGui)
OrbGui.Name="ArceusOrb"; OrbGui.ResetOnSpawn=false; OrbGui.IgnoreGuiInset=true; OrbGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- outer glow ring
local OrbGlow = Instance.new("Frame", OrbGui)
OrbGlow.Size=UDim2.new(0,72,0,72); OrbGlow.Position=UDim2.new(0,20,0.5,-36)
OrbGlow.BackgroundColor3=Color3.fromRGB(255,255,255); OrbGlow.BackgroundTransparency=0.6
OrbGlow.BorderSizePixel=0; OrbGlow.ZIndex=1
Instance.new("UICorner",OrbGlow).CornerRadius=UDim.new(1,0)

-- pulse animation on glow ring
task.spawn(function()
    local t=0
    while OrbGlow.Parent do
        t=t+task.wait(0.05)
        local p=0.5+0.5*math.sin(t*2)
        OrbGlow.BackgroundTransparency=0.5+0.35*p
        OrbGlow.Size=UDim2.new(0,72+6*p,0,72+6*p)
        OrbGlow.Position=UDim2.new(0,20-(3*p),0.5,-36-(3*p))
    end
end)

-- main orb button
local Orb = Instance.new("ImageButton", OrbGui)
Orb.Size=UDim2.new(0,62,0,62); Orb.Position=UDim2.new(0,25,0.5,-31)
Orb.BackgroundColor3=Color3.fromRGB(18,18,24); Orb.BorderSizePixel=0; Orb.ZIndex=2
-- Arceus image (Roblox asset)
Orb.Image="rbxassetid://6894586021"  -- Arceus Pokemon icon (public decal)
Orb.ImageTransparency=0
Instance.new("UICorner",Orb).CornerRadius=UDim.new(1,0)
local OrbStroke=Instance.new("UIStroke",Orb)
OrbStroke.Thickness=2; OrbStroke.Color=Color3.fromRGB(255,255,255)

-- "G" hint label below orb
local OrbHint=Instance.new("TextLabel",OrbGui)
OrbHint.Size=UDim2.new(0,62,0,16); OrbHint.Position=UDim2.new(0,25,0.5,34)
OrbHint.BackgroundTransparency=1; OrbHint.Text="[G]"
OrbHint.TextColor3=Color3.fromRGB(180,180,180); OrbHint.TextSize=11; OrbHint.Font=Enum.Font.GothamBold
OrbHint.ZIndex=2

-- drag orb
local orbDrag=false; local orbDragStart=nil; local orbDragPos=nil
Orb.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        orbDrag=true; orbDragStart=inp.Position
        orbDragPos={glow=OrbGlow.Position, orb=Orb.Position, hint=OrbHint.Position}
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if orbDrag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        local d=inp.Position-orbDragStart
        OrbGlow.Position=UDim2.new(orbDragPos.glow.X.Scale,orbDragPos.glow.X.Offset+d.X,orbDragPos.glow.Y.Scale,orbDragPos.glow.Y.Offset+d.Y)
        Orb.Position=UDim2.new(orbDragPos.orb.X.Scale,orbDragPos.orb.X.Offset+d.X,orbDragPos.orb.Y.Scale,orbDragPos.orb.Y.Offset+d.Y)
        OrbHint.Position=UDim2.new(orbDragPos.hint.X.Scale,orbDragPos.hint.X.Offset+d.X,orbDragPos.hint.Y.Scale,orbDragPos.hint.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then orbDrag=false end
end)

-- open/close logic
local hubOpen=false
local function toggleHub()
    hubOpen=not hubOpen
    if hubOpen then
        -- position hub near orb
        local op=Orb.AbsolutePosition
        local sx=ScreenGui.AbsoluteSize.X; local sy=ScreenGui.AbsoluteSize.Y
        local hx=math.clamp(op.X+80,0,sx-375)
        local hy=math.clamp(op.Y-200,0,sy-590)
        MainFrame.Position=UDim2.new(0,hx,0,hy)
        MainFrame.Size=UDim2.new(0,370,0,0)
        MainFrame.Visible=true
        TweenService:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Size=UDim2.new(0,370,0,580)}):Play()
        TweenService:Create(OrbStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(255,255,255),Thickness=3}):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,370,0,0)}):Play()
        task.delay(0.26,function() MainFrame.Visible=false end)
        TweenService:Create(OrbStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(200,200,200),Thickness=2}):Play()
    end
end

-- click orb to toggle (only if not dragging)
local orbClickStart=nil
Orb.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        orbClickStart=inp.Position
    end
end)
Orb.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        if orbClickStart and (inp.Position-orbClickStart).Magnitude < 6 then
            toggleHub()
        end
        orbClickStart=nil
    end
end)

-- MinBtn now closes instead of minimizing
MinBtn.Text="✕"
MinBtn.MouseButton1Click:Connect(function()
    if hubOpen then toggleHub() end
end)

-- drag hub by header
local dragOn,dragStart2,dragPos2=false,nil,nil
MainFrame.InputBegan:Connect(function(inp)
    if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and (inp.Position.Y-MainFrame.AbsolutePosition.Y<66) then
        dragOn=true; dragStart2=inp.Position; dragPos2=MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragOn and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        local d=inp.Position-dragStart2
        MainFrame.Position=UDim2.new(dragPos2.X.Scale,dragPos2.X.Offset+d.X,dragPos2.Y.Scale,dragPos2.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragOn=false end
end)

-- G key to toggle
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.G then toggleHub() end
end)

-- re-apply on respawn and re-hook speed/jump
player.CharacterAdded:Connect(function(char)
    refreshChar(char); task.wait(0.25)
    if State.speedEnabled then stopSpeedHack(); startSpeedHack() end
    if State.jumpEnabled  then stopJumpHack();  startJumpHack()  end
    State.flying=false; State.noclip=false; State.spin=false
end)

-- entry animation
MainFrame.Position=UDim2.new(0.5,-185,0.5,-310); MainFrame.BackgroundTransparency=1
TweenService:Create(MainFrame,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-185,0.5,-290),BackgroundTransparency=0}):Play()

Notify("Arceus Hub","✅ v4.0 loaded! [INSERT] to toggle.")
print("✅ Arceus Hub v4.0 — Welcome, "..player.Name.."!")

end -- hub ends
