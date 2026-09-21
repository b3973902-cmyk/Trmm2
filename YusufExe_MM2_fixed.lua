    local YusufExe = {}
    YusufExe.__index = YusufExe
    YusufExe._VERSION = "1.0.0"
    YusufExe._WINDOWS = {}
    local TweenService     = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService       = game:GetService("RunService")
    local CoreGui          = game:GetService("CoreGui")
    local Players          = game:GetService("Players")
    local HttpService      = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local Mouse       = LocalPlayer and LocalPlayer:GetMouse()
    local Theme = {
        Background = Color3.fromRGB(15, 15, 25),    
        Window     = Color3.fromRGB(20, 20, 35),
        Panel      = Color3.fromRGB(28, 28, 48),
        Header     = Color3.fromRGB(35, 35, 60),
        Elevated   = Color3.fromRGB(42, 42, 72),
        Primary    = Color3.fromRGB(130, 200, 255), 
        Secondary  = Color3.fromRGB(90, 170, 240),
        Glow       = Color3.fromRGB(180, 230, 255),
        Accent     = Color3.fromRGB(160, 210, 255),
        Border     = Color3.fromRGB(50, 70, 120),
        BorderSoft = Color3.fromRGB(35, 50, 90),
        Text       = Color3.fromRGB(240, 240, 255),
        SubText    = Color3.fromRGB(180, 190, 220),
        Muted      = Color3.fromRGB(100, 120, 170),
        Success    = Color3.fromRGB(74, 222, 128),
        Warning    = Color3.fromRGB(250, 204, 21),
        Error      = Color3.fromRGB(248, 113, 113),
        Font       = Enum.Font.GothamMedium,
        FontBold   = Enum.Font.GothamBold,
        FontLight  = Enum.Font.Gotham,
    }
    YusufExe.Theme = Theme
    local Util = {}
    function Util.new(className, props, children)
        local inst = Instance.new(className)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then inst[k] = v end
            end
            if props.Parent then inst.Parent = props.Parent end
        end
        if children then
            for _, c in ipairs(children) do c.Parent = inst end
        end
        return inst
    end
    function Util.corner(parent, radius)
        return Util.new("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
    end
    function Util.stroke(parent, color, thickness, transparency)
        return Util.new("UIStroke", {
            Color = color or Theme.Border,
            Thickness = thickness or 1,
            Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = parent,
        })
    end
    function Util.padding(parent, all)
        return Util.new("UIPadding", {
            PaddingTop    = UDim.new(0, all),
            PaddingBottom = UDim.new(0, all),
            PaddingLeft   = UDim.new(0, all),
            PaddingRight  = UDim.new(0, all),
            Parent = parent,
        })
    end
    function Util.list(parent, padding, dir)
        return Util.new("UIListLayout", {
            Padding = UDim.new(0, padding or 6),
            FillDirection = dir or Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Parent = parent,
        })
    end
    function Util.tween(inst, time, props, style, dir)
        local t = TweenService:Create(inst, TweenInfo.new(
            time or 0.2,
            style or Enum.EasingStyle.Quart,
            dir or Enum.EasingDirection.Out
        ), props)
        t:Play()
        return t
    end
    function Util.gradient(parent, colors, rotation, transparency)
        return Util.new("UIGradient", {
            Color = typeof(colors) == "ColorSequence" and colors or ColorSequence.new(colors),
            Rotation = rotation or 0,
            Transparency = transparency or NumberSequence.new(0),
            Parent = parent,
        })
    end
    function Util.isMobile()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    function Util.protectGui(gui)
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(gui) end
        end)
        local parent = nil
        pcall(function()
            if gethui then
                parent = gethui()
            end
        end)
        if not parent then
            pcall(function() parent = CoreGui end)
        end
        if parent then
            gui.Parent = parent
        end
    end
    function Util.makeDraggable(topBar, frame)
        local dragging, dragStart, startPos, dragInput
        topBar.Active = true
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos  = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        topBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                Util.tween(frame, 0.08, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                })
            end
        end)
    end
    YusufExe.Util = Util
    local NotifyGui
    local function ensureNotifyGui()
        if NotifyGui and NotifyGui.Parent then return NotifyGui end
        NotifyGui = Util.new("ScreenGui", {
            Name = "Yusuf.exeNotify",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
        })
        Util.protectGui(NotifyGui)
        local holder = Util.new("Frame", {
            Name = "Holder",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 320, 1, -32),
            Parent = NotifyGui,
        })
        Util.new("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = holder,
        })
        return NotifyGui
    end
    function YusufExe:Notify(opts)
        opts = opts or {}
        local title    = opts.Title or "Yusuf.exe"
        local content  = opts.Content or ""
        local duration = opts.Duration or 4
        local kind     = opts.Type or "info" 
        local accent = Theme.Primary
        if kind == "success" then accent = Theme.Success
        elseif kind == "warning" then accent = Theme.Warning
        elseif kind == "error" then accent = Theme.Error end
        local gui = ensureNotifyGui()
        local holder = gui:FindFirstChild("Holder")
        local card = Util.new("Frame", {
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(1, 40, 0, 0),
            Parent = holder,
        })
        Util.corner(card, 12)
        Util.stroke(card, Theme.Border, 1, 0.3)
        local bar = Util.new("Frame", {
            BackgroundColor3 = accent,
            Size = UDim2.new(0, 3, 1, -14),
            Position = UDim2.new(0, 8, 0, 7),
            BorderSizePixel = 0,
            Parent = card,
        })
        Util.corner(bar, 4)
        local titleLbl = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 22, 0, 8),
            Size = UDim2.new(1, -32, 0, 20),
            Font = Theme.FontBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })
        local contentLbl = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 22, 0, 30),
            Size = UDim2.new(1, -32, 1, -38),
            Font = Theme.FontLight,
            Text = content,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = card,
        })
        Util.tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
        task.delay(duration, function()
            Util.tween(card, 0.25, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 })
            for _, d in ipairs(card:GetDescendants()) do
                pcall(function()
                    if d:IsA("TextLabel") then Util.tween(d, 0.25, { TextTransparency = 1 })
                    elseif d:IsA("UIStroke") then Util.tween(d, 0.25, { Transparency = 1 })
                    elseif d:IsA("Frame") then Util.tween(d, 0.25, { BackgroundTransparency = 1 }) end
                end)
            end
            task.wait(0.28)
            card:Destroy()
        end)
    end
    local function makeRow(parent, height)
        local row = Util.new("Frame", {
            BackgroundColor3 = Theme.Elevated,
            BackgroundTransparency = 0.15,
            Size = UDim2.new(1, 0, 0, height or 44),
            Parent = parent,
        })
        Util.corner(row, 10)
        Util.stroke(row, Theme.BorderSoft, 1, 0.4)
        return row
    end
    local function rowLabel(row, text)
        return Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -140, 1, 0),
            Font = Theme.Font,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end
    local function CreateButton(parent, opts)
        opts = opts or {}
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Button")
        local chevron = Util.new("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            Image = "rbxassetid://6031091004", 
            Rotation = -90,
            ImageColor3 = Theme.SubText,
            Parent = row,
        })
        local btn = Util.new("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            AutoButtonColor = false,
            Parent = row,
        })
        btn.MouseEnter:Connect(function()
            Util.tween(row, 0.15, { BackgroundTransparency = 0 })
            Util.tween(chevron, 0.15, { ImageColor3 = Theme.Glow, Position = UDim2.new(1, -8, 0.5, 0) })
        end)
        btn.MouseLeave:Connect(function()
            Util.tween(row, 0.15, { BackgroundTransparency = 0.15 })
            Util.tween(chevron, 0.15, { ImageColor3 = Theme.SubText, Position = UDim2.new(1, -12, 0.5, 0) })
        end)
        btn.MouseButton1Click:Connect(function()
            Util.tween(row, 0.08, { BackgroundColor3 = Theme.Primary, BackgroundTransparency = 0.5 })
            task.wait(0.1)
            Util.tween(row, 0.15, { BackgroundColor3 = Theme.Elevated, BackgroundTransparency = 0.15 })
            if opts.Callback then pcall(opts.Callback) end
        end)
        return { Instance = row }
    end
    local function CreateToggle(parent, opts)
        opts = opts or {}
        local state = opts.Default and true or false
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Toggle")
        local track = Util.new("Frame", {
            BackgroundColor3 = Theme.Header,
            Position = UDim2.new(1, -58, 0.5, -12),
            Size = UDim2.new(0, 48, 0, 24),
            Parent = row,
        })
        Util.corner(track, 12)
        Util.stroke(track, Theme.BorderSoft, 1, 0.3)
        local knob = Util.new("Frame", {
            BackgroundColor3 = Theme.SubText,
            Position = UDim2.new(0, 3, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
            Parent = track,
        })
        Util.corner(knob, 10)
        local btn = Util.new("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 1, 0), Parent = row,
        })
        local api = {}
        function api:Set(v)
            state = v and true or false
            if state then
                Util.tween(track, 0.2, { BackgroundColor3 = Theme.Primary })
                Util.tween(knob, 0.2, { Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Theme.Text })
            else
                Util.tween(track, 0.2, { BackgroundColor3 = Theme.Header })
                Util.tween(knob, 0.2, { Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Theme.SubText })
            end
            if opts.Callback then pcall(opts.Callback, state) end
        end
        btn.MouseButton1Click:Connect(function() api:Set(not state) end)
        api:Set(state)
        api.Instance = row
        return api
    end
    local function CreateSlider(parent, opts)
        opts = opts or {}
        local min = opts.Min or 0
        local max = opts.Max or 100
        local default = math.clamp(opts.Default or min, min, max)
        local decimals = opts.Decimals or 0
        local row = makeRow(parent, 62)
        local label = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 8),
            Size = UDim2.new(1, -28, 0, 18),
            Font = Theme.Font,
            Text = opts.Name or "Slider",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        local valueLbl = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -70, 0, 8),
            Size = UDim2.new(0, 60, 0, 18),
            Font = Theme.FontBold,
            Text = tostring(default),
            TextColor3 = Theme.Glow,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = row,
        })
        local bar = Util.new("Frame", {
            BackgroundColor3 = Theme.Header,
            Position = UDim2.new(0, 14, 1, -18),
            Size = UDim2.new(1, -28, 0, 6),
            Parent = row,
        })
        Util.corner(bar, 4)
        local fill = Util.new("Frame", {
            BackgroundColor3 = Theme.Primary,
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
            Parent = bar,
        })
        Util.corner(fill, 4)
        Util.gradient(fill, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Primary),
            ColorSequenceKeypoint.new(1, Theme.Glow),
        }), 0)
        local knob = Util.new("Frame", {
            BackgroundColor3 = Theme.Text,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            Parent = bar,
        })
        Util.corner(knob, 8)
        Util.stroke(knob, Theme.Primary, 2, 0)
        local dragging = false
        local function updateFromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * rel
            local mult = 10 ^ decimals
            local val = math.floor(raw * mult + 0.5) / mult
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valueLbl.Text = tostring(val)
            if opts.Callback then pcall(opts.Callback, val) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(i.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        task.defer(function()
            local rel = (default - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
        end)
        return { Instance = row }
    end
    local function CreateDropdown(parent, opts)
        opts = opts or {}
        local options = opts.Options or {}
        local current = opts.Default or options[1]
        local open = false
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Dropdown")
        local selector = Util.new("TextButton", {
            BackgroundColor3 = Theme.Header,
            Position = UDim2.new(1, -138, 0.5, -14),
            Size = UDim2.new(0, 128, 0, 28),
            Font = Theme.Font,
            Text = "  " .. tostring(current or "—"),
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = row,
        })
        Util.corner(selector, 8)
        Util.stroke(selector, Theme.BorderSoft, 1, 0.3)
        local arrow = Util.new("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            Image = "rbxassetid://6031091004", 
            ImageColor3 = Theme.SubText,
            Parent = selector,
        })
        local overlayGui = selector:FindFirstAncestorOfClass("ScreenGui")
        local catcher = Util.new("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.fromOffset(0, 0),
            Visible = false,
            ZIndex = 49,
            Parent = overlayGui or row,
        })
        local list = Util.new("ScrollingFrame", {
            BackgroundColor3 = Theme.Panel,
            Size = UDim2.new(0, 128, 0, 0),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 50,
            Active = true,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Primary,
            ScrollingEnabled = true,
            Parent = overlayGui or row,
        })
        Util.corner(list, 8)
        Util.stroke(list, Theme.Border, 1, 0.2)
        local listLayout = Util.list(list, 2)
        Util.padding(list, 4)
        local function reposition()
            local ap = selector.AbsolutePosition
            local as = selector.AbsoluteSize
            list.Position = UDim2.fromOffset(ap.X, ap.Y + as.Y + 4)
        end
        local RunService = game:GetService("RunService")
        local followConn
        local function startFollow()
            if followConn then return end
            followConn = RunService.RenderStepped:Connect(function()
                if not list.Visible then return end
                reposition()
            end)
        end
        local function stopFollow()
            if followConn then followConn:Disconnect(); followConn = nil end
        end
        local function closeList()
            if not open then return end
            open = false
            catcher.Visible = false
            Util.tween(list, 0.18, { Size = UDim2.new(0, 128, 0, 0) })
            Util.tween(arrow, 0.15, { Rotation = 0 })
            task.delay(0.2, function() if not open then list.Visible = false; stopFollow() end end)
        end
        catcher.MouseButton1Click:Connect(closeList)
        local function rebuild()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, opt in ipairs(options) do
                local o = Util.new("TextButton", {
                    BackgroundColor3 = Theme.Elevated,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Theme.Font,
                    Text = "  " .. tostring(opt),
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 51,
                    Parent = list,
                })
                Util.corner(o, 6)
                o.MouseEnter:Connect(function() Util.tween(o, 0.12, { BackgroundColor3 = Theme.Primary, BackgroundTransparency = 0.2 }) end)
                o.MouseLeave:Connect(function() Util.tween(o, 0.12, { BackgroundColor3 = Theme.Elevated, BackgroundTransparency = 0.4 }) end)
                o.MouseButton1Click:Connect(function()
                    current = opt
                    selector.Text = "  " .. tostring(opt)
                    closeList()
                    if opts.Callback then pcall(opts.Callback, opt) end
                end)
            end
        end
        rebuild()
        selector.MouseButton1Click:Connect(function()
            open = not open
            if open then
                reposition()
                list.Visible = true
                catcher.Visible = true
                startFollow()
                local h = math.min(#options * 28 + 8, 180)
                list.CanvasPosition = Vector2.new(0, 0)
                Util.tween(list, 0.2, { Size = UDim2.new(0, 128, 0, h) })
                Util.tween(arrow, 0.15, { Rotation = 180 })
            else
                open = true 
                closeList()
            end
        end)
        local api = { Instance = row }
        function api:Refresh(newOpts, keep)
            options = newOpts or {}
            if not keep then current = options[1]; selector.Text = "  " .. tostring(current or "—") end
            rebuild()
        end
        if current ~= nil and opts.Callback then
            task.defer(function() pcall(opts.Callback, current) end)
        end
        return api
    end
    local function CreateTextbox(parent, opts)
        opts = opts or {}
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Textbox")
        local box = Util.new("TextBox", {
            BackgroundColor3 = Theme.Header,
            Position = UDim2.new(1, -168, 0.5, -14),
            Size = UDim2.new(0, 158, 0, 28),
            Font = Theme.Font,
            PlaceholderText = opts.Placeholder or "",
            PlaceholderColor3 = Theme.Muted,
            Text = opts.Default or "",
            TextColor3 = Theme.Text,
            TextSize = 13,
            ClearTextOnFocus = false,
            Parent = row,
        })
        Util.corner(box, 8)
        Util.stroke(box, Theme.BorderSoft, 1, 0.3)
        Util.padding(box, 8)
        box.FocusLost:Connect(function(enter)
            if opts.Callback then pcall(opts.Callback, box.Text, enter) end
        end)
        return { Instance = row }
    end
    local function CreateLabel(parent, text)
        local l = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Font = Theme.Font,
            Text = tostring(text or ""),
            TextColor3 = Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        })
        return { Instance = l, Set = function(_, v) l.Text = tostring(v) end }
    end
    local function CreateParagraph(parent, opts)
        opts = opts or {}
        local box = Util.new("Frame", {
            BackgroundColor3 = Theme.Elevated,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, 0, 0, 60),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = parent,
        })
        Util.corner(box, 10)
        Util.stroke(box, Theme.BorderSoft, 1, 0.4)
        Util.padding(box, 10)
        Util.list(box, 4)
        local titleLbl = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Theme.FontBold,
            Text = opts.Title or "Título",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = box,
        })
        local contentLbl = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Theme.FontLight,
            Text = opts.Content or "",
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = box,
        })
        local api = { Instance = box, Title = titleLbl, Content = contentLbl }
        function api:SetDesc(v) contentLbl.Text = tostring(v or "") end
        function api:SetTitle(v) titleLbl.Text = tostring(v or "") end
        function api:Set(v) contentLbl.Text = tostring(v or "") end
        return api
    end
    local function CreateSection(parent, text)
        local wrap = Util.new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Parent = parent,
        })
        Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.FontBold,
            Text = string.upper(tostring(text or "SECTION")),
            TextColor3 = Theme.Glow,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = wrap,
        })
        return { Instance = wrap }
    end
    local function CreateSeparator(parent)
        local sep = Util.new("Frame", {
            BackgroundColor3 = Theme.BorderSoft,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Parent = parent,
        })
        return { Instance = sep }
    end
    local function CreateColorPicker(parent, opts)
        opts = opts or {}
        local color = opts.Default or Color3.fromRGB(168, 85, 247)
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Color")
        local swatch = Util.new("TextButton", {
            BackgroundColor3 = color,
            Position = UDim2.new(1, -46, 0.5, -14),
            Size = UDim2.new(0, 36, 0, 28),
            Text = "",
            AutoButtonColor = false,
            Parent = row,
        })
        Util.corner(swatch, 8)
        Util.stroke(swatch, Theme.BorderSoft, 1, 0.2)
        local panel = Util.new("Frame", {
            BackgroundColor3 = Theme.Panel,
            Position = UDim2.new(1, -220, 1, 4),
            Size = UDim2.new(0, 210, 0, 0),
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 8,
            Parent = row,
        })
        Util.corner(panel, 10)
        Util.stroke(panel, Theme.Border, 1, 0.2)
        local h, s, v = 0.75, 0.7, 0.9
        local function apply()
            color = Color3.fromHSV(h, s, v)
            swatch.BackgroundColor3 = color
            if opts.Callback then pcall(opts.Callback, color) end
        end
        local sv = Util.new("ImageLabel", {
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 150, 0, 100),
            Image = "",
            ZIndex = 9,
            Parent = panel,
        })
        Util.corner(sv, 6)
        local svGrad = Util.new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
            }),
            Parent = sv,
        })
        local svDark = Util.new("Frame", {
            BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.new(1,0,1,0), BorderSizePixel = 0, ZIndex = 10, Parent = sv,
        })
        Util.corner(svDark, 6)
        Util.new("UIGradient", {
            Color = ColorSequence.new(Color3.new(0,0,0)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
            Parent = svDark,
        })
        local hueBar = Util.new("Frame", {
            Position = UDim2.new(0, 170, 0, 10),
            Size = UDim2.new(0, 20, 0, 100),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            ZIndex = 9,
            Parent = panel,
        })
        Util.corner(hueBar, 6)
        Util.new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0,1,1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50,1,1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1,1,1)),
            }),
            Rotation = 90,
            Parent = hueBar,
        })
        local svCursor = Util.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 8, 0, 8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = sv,
        })
        Util.stroke(svCursor, Color3.new(1,1,1), 2, 0)
        Util.corner(svCursor, 4)
        local hueCursor = Util.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, 4, 0, 4),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = hueBar,
        })
        Util.corner(hueCursor, 2)
        local function updateCursors()
            svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(0.5, 0, h, 0)
            svGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
            })
        end
        updateCursors()
        local svDrag, hueDrag = false, false
        sv.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end
        end)
        hueBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                svDrag, hueDrag = false, false
            end
        end)
        RunService.RenderStepped:Connect(function()
            if svDrag then
                local ap, as = sv.AbsolutePosition, sv.AbsoluteSize
                local mx = UserInputService:GetMouseLocation().X
                local my = UserInputService:GetMouseLocation().Y
                s = math.clamp((mx - ap.X) / as.X, 0, 1)
                v = 1 - math.clamp((my - ap.Y) / as.Y, 0, 1)
                updateCursors(); apply()
            elseif hueDrag then
                local ap, as = hueBar.AbsolutePosition, hueBar.AbsoluteSize
                local my = UserInputService:GetMouseLocation().Y
                h = math.clamp((my - ap.Y) / as.Y, 0, 1)
                updateCursors(); apply()
            end
        end)
        local openPicker = false
        swatch.MouseButton1Click:Connect(function()
            openPicker = not openPicker
            panel.Visible = true
            Util.tween(panel, 0.2, { Size = UDim2.new(0, 210, 0, openPicker and 120 or 0) })
            if not openPicker then task.wait(0.22); panel.Visible = false end
        end)
        apply()
        return { Instance = row }
    end
    local function CreateKeybind(parent, opts)
        opts = opts or {}
        local current = opts.Default or Enum.KeyCode.RightShift
        local row = makeRow(parent, 44)
        rowLabel(row, opts.Name or "Keybind")
        local btn = Util.new("TextButton", {
            BackgroundColor3 = Theme.Header,
            Position = UDim2.new(1, -108, 0.5, -14),
            Size = UDim2.new(0, 98, 0, 28),
            Font = Theme.FontBold,
            Text = current.Name,
            TextColor3 = Theme.Glow,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = row,
        })
        Util.corner(btn, 8)
        Util.stroke(btn, Theme.BorderSoft, 1, 0.3)
        local listening = false
        btn.MouseButton1Click:Connect(function()
            listening = true
            btn.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(i, gp)
            if gp then return end
            if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                current = i.KeyCode
                btn.Text = current.Name
                listening = false
            elseif not listening and i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == current then
                if opts.Callback then pcall(opts.Callback) end
            end
        end)
        return { Instance = row, Get = function() return current end }
    end
    local function CreateCard(parent, opts)
        opts = opts or {}
        local name = opts.Name or "???"
        local rarity = opts.Rarity or "Common"
        local image = opts.Image or "rbxassetid://6031075929"
        local rarityColor = opts.RarityColor or Theme.SubText
        local container = Util.new("Frame", {
            BackgroundColor3 = Theme.Elevated,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 120, 0, 140),
            BorderSizePixel = 0,
            Parent = parent,
        })
        Util.corner(container, 8)
        local imgBtn = Util.new("ImageButton", {
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 0),
            Image = image,
            ScaleType = Enum.ScaleType.Fit,
            AutoButtonColor = false,
            Parent = container,
        })
        Util.corner(imgBtn, 6)
        Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 1, -24),
            Size = UDim2.new(1, 0, 0, 24),
            Font = Theme.FontBold,
            Text = name,
            TextColor3 = Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = container,
        })
        Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 14),
            Font = Theme.Font,
            Text = rarity,
            TextColor3 = rarityColor,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = container,
        })
        imgBtn.MouseEnter:Connect(function()
            Util.tween(container, 0.12, { BackgroundColor3 = Theme.Primary, BackgroundTransparency = 0.1 })
        end)
        imgBtn.MouseLeave:Connect(function()
            Util.tween(container, 0.12, { BackgroundColor3 = Theme.Elevated, BackgroundTransparency = 0.2 })
        end)
        imgBtn.MouseButton1Click:Connect(function()
            if opts.Callback then pcall(opts.Callback) end
            Util.tween(container, 0.1, { BackgroundColor3 = Theme.Success, BackgroundTransparency = 0.3 })
            task.wait(0.12)
            Util.tween(container, 0.15, { BackgroundColor3 = Theme.Elevated, BackgroundTransparency = 0.2 })
        end)
        return { Instance = container }
    end
    local Tab = {}
    Tab.__index = Tab
    function Tab.new(window, opts)
        local self = setmetatable({}, Tab)
        self.Window = window
        self.Name = opts.Name or "Tab"
        self.Button = Util.new("TextButton", {
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, -6, 0, 36),
            Font = Theme.FontBold,
            Text = "",
            TextColor3 = Theme.SubText,
            AutoButtonColor = false,
            Parent = window.TabList,
        })
        Util.corner(self.Button, 10)
        local rawIcon = opts.Icon and tostring(opts.Icon) or ""
        local isImage = rawIcon:match("^rbxassetid://") or rawIcon:match("^rbxthumb://") or rawIcon:match("^http")
        local iconAsset = isImage and rawIcon or "rbxassetid://6031075929"
        local CUSTOM_ICONS = {
            ["rbxassetid://90062701178064"] = true,   
            ["rbxassetid://125506289461098"] = true,  
            ["rbxassetid://79414527368822"] = true,   
            ["rbxassetid://73117522660789"] = true,   
            ["rbxassetid://84351910860448"] = true,   
        }
        local iconImg = Util.new("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
            Image = iconAsset,
            ImageColor3 = CUSTOM_ICONS[iconAsset] and Color3.new(1, 1, 1) or Theme.SubText,
            Parent = self.Button,
        })
        self.TitleLabel = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -34, 1, 0),
            Font = Theme.FontBold,
            Text = self.Name,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = self.Button,
        })
        self.IconImage = iconImg
        self.Container = Util.new("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Primary,
            Visible = false,
            Parent = window.Content,
        })
        Util.padding(self.Container, 12)
        Util.list(self.Container, 8)
        self.Button.MouseButton1Click:Connect(function() window:SelectTab(self) end)
        self.Button.MouseEnter:Connect(function()
            if window.CurrentTab ~= self then
                Util.tween(self.Button, 0.15, { BackgroundTransparency = 0.2 })
                Util.tween(self.TitleLabel, 0.15, { TextColor3 = Theme.Text })
            end
        end)
        self.Button.MouseLeave:Connect(function()
            if window.CurrentTab ~= self then
                Util.tween(self.Button, 0.15, { BackgroundTransparency = 0.5 })
                Util.tween(self.TitleLabel, 0.15, { TextColor3 = Theme.SubText })
            end
        end)
        return self
    end
    function Tab:CreateButton(o)      return CreateButton(self.Container, o) end
    function Tab:CreateToggle(o)      return CreateToggle(self.Container, o) end
    function Tab:CreateSlider(o)      return CreateSlider(self.Container, o) end
    function Tab:CreateDropdown(o)    return CreateDropdown(self.Container, o) end
    function Tab:CreateTextbox(o)     return CreateTextbox(self.Container, o) end
    function Tab:CreateLabel(t)       return CreateLabel(self.Container, t) end
    function Tab:CreateParagraph(o)   return CreateParagraph(self.Container, o) end
    function Tab:CreateSection(t)     return CreateSection(self.Container, t) end
    function Tab:CreateSeparator()    return CreateSeparator(self.Container) end
    function Tab:CreateColorPicker(o) return CreateColorPicker(self.Container, o) end
    function Tab:CreateKeybind(o)     return CreateKeybind(self.Container, o) end
    function Tab:CreateCard(o)        return CreateCard(self.Container, o) end
    local Window = {}
    Window.__index = Window
    function Window.new(opts)
        opts = opts or {}
        local self = setmetatable({}, Window)
        self.Tabs = {}
        self.CurrentTab = nil
        local gui = Util.new("ScreenGui", {
            Name = "Yusuf.exeUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
        })
        Util.protectGui(gui)
        self.Gui = gui
        local isMobile = Util.isMobile()
        local w = isMobile and 520 or 690
        local h = isMobile and 380 or 430
        local main = Util.new("Frame", {
            Name = "Main",
            BackgroundColor3 = Theme.Window,
            Size = UDim2.new(0, w, 0, h),
            Position = UDim2.new(0.5, -w/2, 0.5, -h/2),
            ClipsDescendants = true,
            Parent = gui,
        })
        Util.corner(main, 14)
        Util.stroke(main, Theme.Border, 1, 0.2)
        local bgImage = Util.new("ImageLabel", {
        Name = "Background",
        Image = "rbxassetid://86101703027120",   
        BackgroundTransparency = 1,
        ImageTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = 0,
        Parent = main,
    })
        Util.corner(bgImage, 14)
        self.Main = main
    local rainFrame = Util.new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 0,
        Parent = main,
    })
    local rain = Util.new("ParticleEmitter", {
        Texture = "rbxasset://textures/particles/drop.dds",
        Color = ColorSequence.new(Color3.fromRGB(200, 220, 255)),
        Transparency = NumberSequence.new(0.3, 0.7),
        Size = NumberSequence.new(3, 6),
        Speed = NumberRange.new(10, 20),
        Lifetime = NumberRange.new(2, 3),
        Rate = 40,
        Rotation = NumberRange.new(0, 360),
        RotSpeed = NumberRange.new(0, 0),
        SpreadAngle = Vector2.new(10, 10),
        VelocityInheritance = 0,
        Acceleration = Vector3.new(0, -15, 0),
        EmissionDirection = Enum.NormalId.Top,
        LightEmission = 0.2,
        Parent = rainFrame,
    })
        local glow = Util.new("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084",
            ImageColor3 = Theme.Primary,
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24,24,276,276),
            Position = UDim2.new(0, -30, 0, -30),
            Size = UDim2.new(1, 60, 1, 60),
            Parent = main,
        })
        glow.ZIndex = 0
        local header = Util.new("Frame", {
            BackgroundColor3 = Theme.Header,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = main,
        })
        Util.corner(header, 14)
        Util.new("Frame", {
            BackgroundColor3 = Theme.Header, Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0), BorderSizePixel = 0, Parent = header,
        })
        local title = Util.new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(1, -100, 1, 0),
            Font = Theme.FontBold,
            Text = opts.Title or "Yusuf.exe UI",
            TextColor3 = Theme.Text,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header,
        })
        if opts.SubTitle then
            local sub = Util.new("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16 + title.TextBounds.X + 8, 0, 0),
                Size = UDim2.new(0, 200, 1, 0),
                Font = Theme.FontLight,
                Text = opts.SubTitle,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })
        end
        local closeBtn = Util.new("TextButton", {
            BackgroundColor3 = Theme.Error,
            BackgroundTransparency = 0.7,
            Position = UDim2.new(1, -30, 0.5, -11),
            Size = UDim2.new(0, 22, 0, 22),
            Font = Theme.FontBold,
            Text = "×",
            TextColor3 = Theme.Text,
            TextSize = 16,
            AutoButtonColor = false,
            Parent = header,
        })
        Util.corner(closeBtn, 11)
        closeBtn.MouseEnter:Connect(function() Util.tween(closeBtn, 0.15, { BackgroundTransparency = 0.2 }) end)
        closeBtn.MouseLeave:Connect(function() Util.tween(closeBtn, 0.15, { BackgroundTransparency = 0.7 }) end)
        closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)
        local miniBtn = Util.new("TextButton", {
            BackgroundColor3 = Theme.Elevated,
            BackgroundTransparency = 0.4,
            Position = UDim2.new(1, -58, 0.5, -11),
            Size = UDim2.new(0, 22, 0, 22),
            Font = Theme.FontBold,
            Text = "—",
            TextColor3 = Theme.Text,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = header,
        })
        Util.corner(miniBtn, 11)
        Util.stroke(miniBtn, Theme.BorderSoft, 1, 0.4)
        miniBtn.MouseEnter:Connect(function() Util.tween(miniBtn, 0.15, { BackgroundTransparency = 0.1 }) end)
        miniBtn.MouseLeave:Connect(function() Util.tween(miniBtn, 0.15, { BackgroundTransparency = 0.4 }) end)
        Util.makeDraggable(header, main)
        local body = Util.new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 46),
            Size = UDim2.new(1, 0, 1, -50),
            Parent = main,
        })
    local restoreBubble = Util.new("ImageButton", {   
        Name = "Yusuf.exeRestore",
        BackgroundColor3 = Color3.fromRGB(30, 35, 60), 
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 20, 0.5, -22),
        Size = UDim2.new(0, 44, 0, 44),
        Image = "rbxassetid://127030331216566",       
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        Visible = false,
        Parent = gui,
    })
    Util.corner(restoreBubble, 22)  
    Util.stroke(restoreBubble, Color3.fromRGB(130, 200, 255), 2, 0.3) 
        Util.makeDraggable(restoreBubble, restoreBubble)
        local minimized = false
        local function setMinimized(v)
            minimized = v
            if minimized then
                body.Visible = false
                Util.tween(main, 0.22, { Size = UDim2.new(0, w, 0, 0) })
                task.wait(0.23)
                main.Visible = false
                restoreBubble.Visible = true
            else
                restoreBubble.Visible = false
                main.Visible = true
                Util.tween(main, 0.25, { Size = UDim2.new(0, w, 0, h) })
                body.Visible = true
            end
        end
        miniBtn.MouseButton1Click:Connect(function() setMinimized(not minimized) end)
        restoreBubble.MouseButton1Click:Connect(function()
            if minimized then setMinimized(false) end
        end)
        local sidebar = Util.new("Frame", {
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.15,
            Size = UDim2.new(0, isMobile and 178 or 200, 1, -8),
            Position = UDim2.new(0, 6, 0, 0),
            Parent = body,
        })
        Util.corner(sidebar, 10)
        Util.stroke(sidebar, Theme.BorderSoft, 1, 0.5)
        Util.padding(sidebar, 6)
        self.TabList = Util.new("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            Parent = sidebar,
        })
        Util.list(self.TabList, 4)
        self.Content = Util.new("Frame", {
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.2,
            Position = UDim2.new(0, (isMobile and 178 or 200) + 12, 0, 0),
            Size = UDim2.new(1, -(isMobile and 178 or 200) - 18, 1, -8),
            Parent = body,
        })
        Util.corner(self.Content, 10)
        Util.stroke(self.Content, Theme.BorderSoft, 1, 0.5)
        main.Size = UDim2.new(0, w, 0, 0)
        Util.tween(main, 0.35, { Size = UDim2.new(0, w, 0, h) }, Enum.EasingStyle.Back)
        local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
        UserInputService.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == toggleKey then
                gui.Enabled = not gui.Enabled
            end
        end)
        table.insert(YusufExe._WINDOWS, self)
        return self
    end
    function Window:CreateTab(opts)
        local tab = Tab.new(self, opts or {})
        table.insert(self.Tabs, tab)
        if not self.CurrentTab then self:SelectTab(tab) end
        return tab
    end
    function Window:SelectTab(tab)
        for _, t in ipairs(self.Tabs) do
            t.Container.Visible = false
            Util.tween(t.Button, 0.15, {
                BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Panel
            })
            if t.TitleLabel then Util.tween(t.TitleLabel, 0.15, { TextColor3 = Theme.SubText }) end
            if t.IconImage  then Util.tween(t.IconImage,  0.15, { ImageColor3 = Theme.SubText }) end
        end
        tab.Container.Visible = true
        Util.tween(tab.Button, 0.2, {
            BackgroundTransparency = 0, BackgroundColor3 = Theme.Primary
        })
        if tab.TitleLabel then Util.tween(tab.TitleLabel, 0.2, { TextColor3 = Theme.Text }) end
        if tab.IconImage  then Util.tween(tab.IconImage,  0.2, { ImageColor3 = Theme.Text }) end
        self.CurrentTab = tab
    end
    function Window:Destroy()
        Util.tween(self.Main, 0.2, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 0) })
        task.wait(0.22)
        self.Gui:Destroy()
    end
    function YusufExe:CreateWindow(opts) return Window.new(opts) end
    function YusufExe:SetTheme(overrides)
        for k, v in pairs(overrides or {}) do Theme[k] = v end
    end
    function YusufExe:Destroy()
        for _, w in ipairs(YusufExe._WINDOWS) do pcall(function() w:Destroy() end) end
        YusufExe._WINDOWS = {}
    end
    local function pickCallback(o)
        return o and (o.Callback or o.Callbacks or o.Function) or function() end
    end
    function Tab:AddToggle(o)
        o = o or {}
        local h = self:CreateToggle({
            Name     = o.Name or o.Title or "Toggle",
            Default  = o.Default or o.CurrentValue or false,
            Callback = pickCallback(o),
        })
        h.SetValue = function(_, v) h:Set(v) end
        h.UpdateToggle = function(_, _, v) h:Set(v) end
        return h
    end
    function Tab:AddSlider(o)
        o = o or {}
        local incr = o.Increment or o.Rounding or 1
        local dec = 0
        if incr < 1 then dec = math.ceil(-math.log10(incr)) end
        local h = self:CreateSlider({
            Name      = o.Name or "Slider",
            Min       = o.Min or 0,
            Max       = o.Max or 100,
            Default   = o.Default or o.Min or 0,
            Decimals  = dec,
            Callback  = pickCallback(o),
        })
        h.Set = function(_, _v) end
        h.SetValue = h.Set
        return h
    end
    function Tab:AddDropdown(o)
        o = o or {}
        local h = self:CreateDropdown({
            Name     = o.Name or "Dropdown",
            Options  = o.Options or {},
            Default  = o.Default,
            Callback = pickCallback(o),
        })
        h.SetOptions = function(_, opts, keep) h:Refresh(opts, keep) end
        h.SetValue = function(_, _v) end
        h.Set = h.SetValue
        return h
    end
    function Tab:AddButton(o)
        o = o or {}
        return self:CreateButton({
            Name     = o.Name or o.Title or o.Text or "Button",
            Callback = pickCallback(o),
        })
    end
    function Tab:AddTextBox(o)
        o = o or {}
        return self:CreateTextbox({
            Name         = o.Name or "Textbox",
            Placeholder  = o.Placeholder or o.Default or "",
            Callback     = pickCallback(o),
            ClearOnFocus = o.ClearOnFocus,
        })
    end
    Tab.AddTextbox = Tab.AddTextBox
    function Tab:AddSection(o)
        local name = type(o) == "table" and (o.Name or o.Title or o.Text) or tostring(o)
        return self:CreateSection(name)
    end
    function Tab:AddParagraph(o, content)
        if type(o) == "table" then
            return self:CreateParagraph({
                Title   = o.Title or o.Name or "",
                Content = o.Content or o.Text or content or "",
            })
        end
        return self:CreateParagraph({
            Title   = tostring(o or ""),
            Content = tostring(content or ""),
        })
    end
    function Tab:AddLabel(o)
        local text = type(o) == "table" and (o.Name or o.Text or "") or tostring(o)
        return self:CreateLabel(text)
    end
    function Tab:AddColorpicker(o)
        o = o or {}
        return self:CreateColorPicker({
            Name     = o.Name or "Color",
            Default  = o.Default or Color3.fromRGB(255,255,255),
            Callback = pickCallback(o),
        })
    end
    Tab.AddColorPicker = Tab.AddColorpicker
    function Tab:AddBind(o)
        o = o or {}
        return self:CreateKeybind({
            Name     = o.Name or "Keybind",
            Default  = o.Default or Enum.KeyCode.RightShift,
            Callback = pickCallback(o),
        })
    end
    Tab.AddKeybind = Tab.AddBind
    function Window:MakeTab(o)
        o = o or {}
        return self:CreateTab({
            Name = o.Title or o.Name or "Tab",
            Icon = o.Icon,
        })
    end
    function Window:MakeNotification(o)
        o = o or {}
        YusufExe:Notify({
            Title   = o.Name or o.Title or "Yusuf.exe",
            Content = o.Content or o.Text or "",
            Duration = o.Time or o.Duration or 4,
        })
    end
    function Window:NewMinimizer(mopts)
        mopts = mopts or {}
        local w = self
        local api = {}
        if mopts.KeyCode then
            UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                if i.KeyCode == mopts.KeyCode then
                    w.Gui.Enabled = not w.Gui.Enabled
                end
            end)
        end
        function api:CreateMobileMinimizer(mmo)
        mmo = mmo or {}
        local btn = Util.new("ImageButton", {
            Name = "Yusuf.exeMobileMinimizer",
            Size = UDim2.new(0, 52, 0, 52),
            Position = UDim2.new(0, 20, 0, 120),
            BackgroundColor3 = mmo.BackgroundColor3 or Color3.fromRGB(30, 35, 60), 
            BackgroundTransparency = mmo.BackgroundTransparency or 0.1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Image = mmo.Image or "rbxassetid://127030331216566",  
            ScaleType = Enum.ScaleType.Fit,
            ClipsDescendants = true,
            Active = true,
            ZIndex = 100,
            Parent = w.Gui,
        })
        Util.corner(btn, 26)
        btn.MouseButton1Click:Connect(function()
            w.Main.Visible = not w.Main.Visible
        end)
        return btn
    end
        return api
    end
    YusufExe.MakeWindow = YusufExe.CreateWindow
    if _G.Yusuf.exeLoaded then return end
    _G.Yusuf.exeLoaded = true
    local getgenv = getgenv or function() return {} end
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local HttpService = game:GetService("HttpService")
    local CoreGui = game:GetService("CoreGui")
    local Lighting = game:GetService("Lighting")
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local Sync, ProfileData, ItemPopupService
    local executorStrong = true
    pcall(function()
        if setthreadidentity then
            setthreadidentity(2)
            Sync = require(game.ReplicatedStorage.Database.Sync)
            ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
            ItemPopupService = require(game.ReplicatedStorage.ClientServices.ItemPopupService)
            setthreadidentity(8)
        else
            Sync = require(game.ReplicatedStorage.Database.Sync)
            ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
            ItemPopupService = require(game.ReplicatedStorage.ClientServices.ItemPopupService)
        end
    end)
    if not Sync then
        executorStrong = false
        Notify("Weak Executor", "Some features are disabled (Spawner, Trades)", 5)
    end
    function GiveItem(ItemName, Amount, ItemType)
        Amount = Amount or 1
        ItemType = ItemType or "Weapons"
        pcall(function()
            if ProfileData[ItemType].Owned[ItemName] == nil then
                ProfileData[ItemType].Owned[ItemName] = Amount
            else
                ProfileData[ItemType].Owned[ItemName] = ProfileData[ItemType].Owned[ItemName] + Amount
            end
            if ItemPopupService then
                ItemPopupService.ItemReceived:Fire(ItemName, ItemType)
            end
            game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()
        end)
    end
    function CreateWeaponCard(parent, opts)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 120, 0, 140)
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        container.BackgroundTransparency = 0.2
        container.BorderSizePixel = 0
        container.Parent = parent
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(1, 0, 1, -30)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.BackgroundTransparency = 0.1
        btn.Image = opts.Image or "rbxassetid://6031075929"
        btn.ScaleType = Enum.ScaleType.Fit
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 24)
        nameLabel.Position = UDim2.new(0, 0, 1, -24)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = opts.Name or "???"
        nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = container
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0, 14)
        rarityLabel.Position = UDim2.new(0, 0, 0, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Font = Enum.Font.Gotham
        rarityLabel.Text = opts.Rarity or "Common"
        rarityLabel.TextColor3 = opts.RarityColor or Color3.fromRGB(200, 200, 200)
        rarityLabel.TextSize = 9
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Center
        rarityLabel.Parent = container
        btn.MouseButton1Click:Connect(function()
            if opts.Callback then pcall(opts.Callback) end
            game.TweenService:Create(container, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0,150,100)}):Play()
            task.delay(0.2, function()
                game.TweenService:Create(container, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30,30,50)}):Play()
            end)
        end)
        return container
    end
    function Notify(Name, content, duration)
        YusufExe:Notify({
            Name = Name,
            Content = content,
            Duration = duration or 3,
            Type = "info",  
        })
    end
    _G.AmiSettings = {
        AutoShotEnabled = false,
        AutoShotCooldown = 0.5,
        SpinbotEnabled = false,
        SpinbotSpeed = 180,
        BunnyHopEnabled = false,
        BunnyHopSpeed = 24,
        BulletTracerEnabled = false,
        BulletTracerColor = Color3.fromRGB(255, 220, 100),
        BulletTracerTransparency = 0.15,
        BulletTracerLifetime = 0.25,
          ShowStats = true,
        BombJumpMobile = false,
        ThrowKnifeEnabled = false,
        CoinFarmEnabled = false,
        MaxCoinsPerRound = 40,
        AutoFlingMurderer = false,
        WalkSpeed = 16,
        JumpPower = 50,
        BombJumpCooldown = false,  
        SpeedGlitchEnabled = false,
        GlitchSpeed = 35,
        EspEnabled = false,
        AutoGrabEnabled = false,
        GunEspEnabled = false,
        SayRoleEnabled = false,
        NoclipEnabled = false,
        FlyEnabled = false,
        FlySpeed = 50,
        AntiAfkEnabled = true,
        FOVValue = 70,
        SilentAimEnabled = false,
        SilentAimMobile = false,
        NamesESP = false,
        TrapESP = false,
        XrayEnabled = false,
        AntiFlingEnabled = false,
        KnifeAuraEnabled = false,
        KnifeAuraRange = 20,
        FastThrowEnabled = false,
        KnifeSilentAimEnabled = false,
        ImproveFPS = false,
        CoinFarmSpeed = 25,
        CoinFarmRadius = 200,
        KnifeMobileEnabled = false,
        DropkickEnabled = false,
        RunEnabled = false,
        DropkickPower = 50,
        RunSpeedPercent = 20,
        DropkickHotkey = Enum.KeyCode.K,
        RunHotkey = Enum.KeyCode.J,
        RTXShaders = false,
        RoundTimer = false,
        ExtremeFlingEnabled = false,
        AutoBreakGun = false,
        Invisibility = false,
        BombJumpEnabled = false,
        BombJumpKey = "B",
        BombJumpMobile = false,
        JerkEnabled = false,
        BangEnabled = false,
        SelectedAnimeTheme = "Reze",
        SkyEnabled = false,
        SelectedSky = "Sunset",
        FogEnabled = false,
        FogStart = 0,
        FogEnd = 1000,
        FogColor = Color3.fromRGB(80, 120, 200),
        ColorCorrectionEnabled = false,
        CCBrightness = 0,
        CCContrast = 0,
        CCSaturation = 0,
        AmbientColor = Color3.fromRGB(0,0,0),
        OutdoorAmbient = Color3.fromRGB(80, 120, 200),
        Exposure = 0,
        Brightness = 0,
        ClockTime = 0,
        GlobalShadows = false,
        Technology = "Legacy",
        SnowEnabled = false,
        PredictKnifeType = "Traject",
        PredictGunType = "Vazex",
        HeadPrediction = false,
        HeadHitChance = 50,
        PingBased = false,
        PingType = "Server",
        ResolverAssistant = false,
        SilentAimKnife = false,
        SilentAimGun = false,
        SilentAimThrowSpeed = "Normal",
        SilentAimInstantShoot = false,
        SilentAimWallCheck = false,
        ThrowKnifeKey = Enum.KeyCode.R,
        ShotMurderKey = Enum.KeyCode.E,
        ShotMurderEnabled = false,   
        ShotMurderMobile = false,    
        IndicatorEnabled = false,
        AntiLock = false,
        AntiKick = false,
    }
    _G.Skyboxes = {
        ["Sunset"] = {
            SkyboxBk = "http://www.roblox.com/asset/?id=458016711",
            SkyboxDn = "http://www.roblox.com/asset/?id=458016826",
            SkyboxFt = "http://www.roblox.com/asset/?id=458016532",
            SkyboxLf = "http://www.roblox.com/asset/?id=458016655",
            SkyboxRt = "http://www.roblox.com/asset/?id=458016782",
            SkyboxUp = "http://www.roblox.com/asset/?id=458016792"
        },
        ["Night Sky 1"] = {
            SkyboxBk = "rbxassetid://48020371",
            SkyboxDn = "rbxassetid://48020144",
            SkyboxFt = "rbxassetid://48020234",
            SkyboxLf = "rbxassetid://48020211",
            SkyboxRt = "rbxassetid://48020254",
            SkyboxUp = "rbxassetid://48020383"
        },
        ["Evening"] = {
            SkyboxLf = "http://www.roblox.com/asset/?id=7950573918",
            SkyboxBk = "http://www.roblox.com/asset/?id=7950569153",
            SkyboxDn = "http://www.roblox.com/asset/?id=7950570785",
            SkyboxFt = "http://www.roblox.com/asset/?id=7950572449",
            SkyboxRt = "http://www.roblox.com/asset/?id=7950575055",
            SkyboxUp = "http://www.roblox.com/asset/?id=7950627627"
        },
        ["Purple Nebula"] = {
            SkyboxBk = "rbxassetid://159454299",
            SkyboxDn = "rbxassetid://159454296",
            SkyboxFt = "rbxassetid://159454293",
            SkyboxLf = "rbxassetid://159454286",
            SkyboxRt = "rbxassetid://159454300",
            SkyboxUp = "rbxassetid://159454288"
        },
        ["Night Sky 2"] = {
            SkyboxBk = "rbxassetid://12064107",
            SkyboxDn = "rbxassetid://12064152",
            SkyboxFt = "rbxassetid://12064121",
            SkyboxLf = "rbxassetid://12063984",
            SkyboxRt = "rbxassetid://12064115",
            SkyboxUp = "rbxassetid://12064131"
        },
        ["Pink Daylight"] = {
            SkyboxBk = "rbxassetid://271042516",
            SkyboxDn = "rbxassetid://271077243",
            SkyboxFt = "rbxassetid://271042556",
            SkyboxLf = "rbxassetid://271042310",
            SkyboxRt = "rbxassetid://271042467",
            SkyboxUp = "rbxassetid://271077958"
        },
        ["Morning Glow"] = {
            SkyboxBk = "rbxassetid://1417494030",
            SkyboxDn = "rbxassetid://1417494146",
            SkyboxFt = "rbxassetid://1417494253",
            SkyboxLf = "rbxassetid://1417494402",
            SkyboxRt = "rbxassetid://1417494499",
            SkyboxUp = "rbxassetid://1417494643"
        },
        ["Chill"] = {
            SkyboxBk = "rbxassetid://5084575798",
            SkyboxDn = "rbxassetid://5084575916",
            SkyboxFt = "rbxassetid://5103949679",
            SkyboxLf = "rbxassetid://5103948542",
            SkyboxRt = "rbxassetid://5103948784",
            SkyboxUp = "rbxassetid://5084576400"
        },
        ["Setting Sun"] = {
            SkyboxBk = "rbxassetid://626460377",
            SkyboxDn = "rbxassetid://626460216",
            SkyboxFt = "rbxassetid://626460513",
            SkyboxLf = "rbxassetid://626473032",
            SkyboxRt = "rbxassetid://626458639",
            SkyboxUp = "rbxassetid://626460625"
        },
        ["Fade Blue"] = {
            SkyboxBk = "rbxassetid://153695414",
            SkyboxDn = "rbxassetid://153695352",
            SkyboxFt = "rbxassetid://153695452",
            SkyboxLf = "rbxassetid://153695320",
            SkyboxRt = "rbxassetid://153695383",
            SkyboxUp = "rbxassetid://153695471"
        },
        ["Twilight"] = {
            SkyboxBk = "rbxassetid://264908339",
            SkyboxDn = "rbxassetid://264907909",
            SkyboxFt = "rbxassetid://264909420",
            SkyboxLf = "rbxassetid://264909758",
            SkyboxRt = "rbxassetid://264908886",
            SkyboxUp = "rbxassetid://264907379"
        },
        ["Elegant Morning"] = {
            SkyboxBk = "rbxassetid://153767241",
            SkyboxDn = "rbxassetid://153767216",
            SkyboxFt = "rbxassetid://153767266",
            SkyboxLf = "rbxassetid://153767200",
            SkyboxRt = "rbxassetid://153767231",
            SkyboxUp = "rbxassetid://153767288"
        },
        ["Neptune"] = {
            SkyboxBk = "rbxassetid://218955819",
            SkyboxDn = "rbxassetid://218953419",
            SkyboxFt = "rbxassetid://218954524",
            SkyboxLf = "rbxassetid://218958493",
            SkyboxRt = "rbxassetid://218957134",
            SkyboxUp = "rbxassetid://218950090"
        },
        ["Redshift"] = {
            SkyboxBk = "rbxassetid://401664839",
            SkyboxDn = "rbxassetid://401664862",
            SkyboxFt = "rbxassetid://401664960",
            SkyboxLf = "rbxassetid://401664881",
            SkyboxRt = "rbxassetid://401664901",
            SkyboxUp = "rbxassetid://401664936"
        },
        ["Aesthetic Night"] = {
            SkyboxBk = "rbxassetid://1045964490",
            SkyboxDn = "rbxassetid://1045964368",
            SkyboxFt = "rbxassetid://1045964655",
            SkyboxLf = "rbxassetid://1045964655",
            SkyboxRt = "rbxassetid://1045964655",
            SkyboxUp = "rbxassetid://1045962969"
        }
    }
    local skyboxNames = {}
    for name in pairs(_G.Skyboxes) do table.insert(skyboxNames, name) end
    table.sort(skyboxNames)
    function GetMap()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then return obj end
        end
        return nil
    end
    function teleportToSpawn()
        local spawn = workspace:FindFirstChild("SpawnLocation")
        if spawn and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = spawn.CFrame + Vector3.new(0,3,0) end
        end
    end
    function rejoin()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
    function respawn()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
    function sendRoleNames()
        detectRoles()
        local msg = "Roles:\n"
        for name, role in pairs(currentRoles) do
            msg = msg .. name .. ": " .. role .. "\n"
        end
        if msg == "Roles:\n" then msg = "No roles detected." end
        Notify("Roles", msg, 10)
    end
    function GetMap()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
                return obj
            end
        end
        return nil
    end
    _G.TargetTracking = {}
    local currentRoles = {}
    local savedPlayerData = {}
    local gunDropCache = {}
    local function regGun(obj)
        if obj.Name == "GunDrop" then
            gunDropCache[obj] = true
        end
    end
    for _, v in pairs(workspace:GetDescendants()) do regGun(v) end
    workspace.DescendantAdded:Connect(regGun)
    workspace.DescendantRemoving:Connect(function(obj)
        if gunDropCache[obj] then gunDropCache[obj] = nil end
    end)
    local FlingActive = false
    getgenv().OldPos = nil
    getgenv().FPDH = workspace.FallenPartsDestroyHeight
    local killAllActive = false
    local coinFarmThread = nil
    local spectateEnabled = false
    local ctrlClickTP = false
    local timerLabel = nil
    local timerTask = nil
    local fpsBoostConn = nil
    local flyConnection = nil
    local noclipConnection = nil
    local antiAfkConnection = nil
    local antiFlingDetectConn = nil
    local antiFlingNeutralizeConn = nil
    local antiFlingDetectedPlayers = {}
    local knifeAuraConn = nil
    local mobileShootBtn = nil
    local mobileKnifeBtn = nil
    local pcKeybindConnection = nil
    local knifeSilentKeyConn = nil
    local extremeFlingActive = false
    local extremeFlingThread = nil
    local dropkickEnabled = false
    local runEnabled = false
    local dropkickBusy = false
    local dropkickActive = false
    local runActive = false
    local dropkickTrack = nil
    local runTrack = nil
    local runAnimConnection = nil
    local jerking = false
    local jerkAnimTrack = nil
    local jerkSpeed = 1.8
    local bangFollowConn = nil
    local bangAnimTrack = nil
    local isBanging = false
    local bangSpeed = 1.8
    local bombJumpButton = nil
    local spaceHeld = false
    local lastJumpTime = 0
    local inRound = false
    local isDead = false
    local mobileGui = nil
    local function PredictKnife(Character)
        if not Character then return end
        local Root = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")
        if not Root or not Head then return end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RawVelocity = Root.AssemblyLinearVelocity or Vector3.zero
        local Speed = RawVelocity.Magnitude
        local HorizontalVelocity = Vector3.new(RawVelocity.X, 0, RawVelocity.Z)
        local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
        local TravelTime = math.clamp(Distance / 200, 0.3, 0.5)
        local Ping = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        local PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
        local EffectiveTime = TravelTime
        if _G.AmiSettings.PingBased then
            EffectiveTime = EffectiveTime + PingFactor
        end
        local FuturePos = Root.Position + HorizontalVelocity * EffectiveTime
        if _G.AmiSettings.PredictKnifeType == "Vectora" then
            FuturePos = Root.Position + HorizontalVelocity * EffectiveTime + Root.CFrame.LookVector * EffectiveTime
        elseif _G.AmiSettings.PredictKnifeType == "Dartix" then
            local Direction = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Unit
            FuturePos = Root.Position + Direction * Speed * EffectiveTime + HorizontalVelocity * EffectiveTime + Root.CFrame.LookVector * EffectiveTime
        end
        if _G.AmiSettings.HeadPrediction and math.random(1, 100) <= _G.AmiSettings.HeadHitChance then
            FuturePos = Head.Position
        end
        if _G.AmiSettings.ResolverAssistant then
            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Blacklist
            Params.FilterDescendantsInstances = {LocalPlayer.Character, Character}
            local DownRay = workspace:Raycast(FuturePos, Vector3.new(0, -8, 0), Params)
            if DownRay then
                local HeightDiff = math.abs(FuturePos.Y - DownRay.Position.Y)
                if HeightDiff < 4 then
                    FuturePos = Vector3.new(FuturePos.X, math.max(FuturePos.Y, DownRay.Position.Y), FuturePos.Z)
                end
            end
        end
        return FuturePos
    end
    local function PredictGun(Character)
        if not Character then return end
        local Root = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")
        if not Root or not Head then return end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RawVelocity = Root.AssemblyLinearVelocity or Vector3.zero
        local Speed = RawVelocity.Magnitude
        local HorizontalVelocity = Vector3.new(RawVelocity.X, 0, RawVelocity.Z)
        local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
        local TravelTime = math.clamp(Distance / 900, 0.1, 0.5)
        local Ping = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        local PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
        local EffectiveTime = TravelTime
        if _G.AmiSettings.PingBased then
            EffectiveTime = EffectiveTime + PingFactor
        end
        local FuturePos = Root.Position
        if _G.AmiSettings.PredictGunType == "Phaze" then
            FuturePos = Root.Position + HorizontalVelocity * EffectiveTime + Root.CFrame.LookVector * EffectiveTime * 0.5
        elseif _G.AmiSettings.PredictGunType == "Hexa" then
            local Direction = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Unit
            FuturePos = Root.Position + Direction * Speed * EffectiveTime + HorizontalVelocity * EffectiveTime
        elseif _G.AmiSettings.PredictGunType == "Nova" then
            local Direction = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Unit
            FuturePos = Root.Position + Direction * Speed * EffectiveTime + HorizontalVelocity * EffectiveTime + Root.CFrame.LookVector * EffectiveTime * 0.5
        end
        if _G.AmiSettings.HeadPrediction and math.random(1, 100) <= _G.AmiSettings.HeadHitChance then
            FuturePos = Head.Position
        end
        if _G.AmiSettings.ResolverAssistant then
            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Blacklist
            Params.FilterDescendantsInstances = {LocalPlayer.Character, Character}
            local DownRay = workspace:Raycast(FuturePos, Vector3.new(0, -8, 0), Params)
            if DownRay then
                local HeightDiff = math.abs(FuturePos.Y - DownRay.Position.Y)
                if HeightDiff < 4 then
                    FuturePos = Vector3.new(FuturePos.X, math.max(FuturePos.Y, DownRay.Position.Y), FuturePos.Z)
                end
            end
        end
        return FuturePos
    end
    function ThrowKnife()
        local char = LocalPlayer.Character
        if not char then return end
        local knife = char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
        if not knife then
            return
        end
        local near, dist = nil, math.huge
        local myPos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.zero
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                local d = (myPos - pl.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    near = pl
                end
            end
        end
        if not near or not near.Character or not near.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if knife.Parent == LocalPlayer.Backpack then
            hum:EquipTool(knife)
            task.wait(0.1)
            knife = char:FindFirstChild("Knife")
            if not knife then return end
        end
        local targetHRP = near.Character.HumanoidRootPart
        local myHRP = char.HumanoidRootPart
        local origin = myHRP.Position
        local AimPos = PredictKnife(near.Character)
        if not AimPos then
            AimPos = targetHRP.Position
        end
        local remote = knife:FindFirstChild("Throw") or knife:FindFirstChild("Remote")
        if not remote then
            local events = knife:FindFirstChild("Events")
            if events then
                remote = events:FindFirstChild("KnifeThrown") or events:FindFirstChild("Throw")
            end
        end
        if not remote then
            return
        end
        local args = { CFrame.lookAt(origin, AimPos), CFrame.new(AimPos) }
        pcall(function() remote:FireServer(unpack(args)) end)
    end
    function ShotMurder()
        local char = LocalPlayer.Character
        if not char then
            return
        end
        local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or char:FindFirstChild("Pistol")
        if not gun then
            return
        end
        local murderer = nil
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hasKnife = pl.Character:FindFirstChild("Knife") or (pl.Backpack and pl.Backpack:FindFirstChild("Knife"))
                if hasKnife then
                    murderer = pl
                    break
                end
            end
        end
        if not murderer or not murderer.Character then
            return
        end
        local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            return
        end
        local AimPos = PredictGun(murderer.Character)
        if not AimPos then
            AimPos = targetRoot.Position
        end
        local origin = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun") or char.HumanoidRootPart
        local originPos = origin.Position
        local shoot = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
        if shoot then
            local aimCF = CFrame.lookAt(originPos, AimPos)
            pcall(function()
                shoot:FireServer(aimCF, CFrame.new(AimPos))
            end)
            pcall(function()
                shoot:FireServer(aimCF)
            end)
        else
        end
    end
    local function applySkybox(name)
        local data = _G.Skyboxes[name]
        if not data then return end
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
        sky.Parent = Lighting
        sky.SkyboxBk = data.SkyboxBk
        sky.SkyboxDn = data.SkyboxDn
        sky.SkyboxFt = data.SkyboxFt
        sky.SkyboxLf = data.SkyboxLf
        sky.SkyboxRt = data.SkyboxRt
        sky.SkyboxUp = data.SkyboxUp
    end
    local function clearSkybox()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    end
    local function applyFog()
        if _G.AmiSettings.FogEnabled then
            Lighting.FogStart = _G.AmiSettings.FogStart
            Lighting.FogEnd = _G.AmiSettings.FogEnd
            Lighting.FogColor = _G.AmiSettings.FogColor
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            Lighting.FogColor = Color3.fromRGB(127, 127, 127)
        end
    end
    local function applyColorCorrection()
        if _G.AmiSettings.ColorCorrectionEnabled then
            local cc = Lighting:FindFirstChild("AmiColorCorrection") or Instance.new("ColorCorrectionEffect")
            cc.Name = "AmiColorCorrection"
            cc.Parent = Lighting
            cc.Brightness = _G.AmiSettings.CCBrightness / 100
            cc.Contrast = _G.AmiSettings.CCContrast / 100
            cc.Saturation = _G.AmiSettings.CCSaturation / 100
        else
            local cc = Lighting:FindFirstChild("AmiColorCorrection")
            if cc then cc:Destroy() end
        end
    end
    local function applyLighting()
        Lighting.Ambient = _G.AmiSettings.AmbientColor
        Lighting.OutdoorAmbient = _G.AmiSettings.OutdoorAmbient
        Lighting.ExposureCompensation = _G.AmiSettings.Exposure
        Lighting.Brightness = _G.AmiSettings.Brightness
        Lighting.ClockTime = _G.AmiSettings.ClockTime
        Lighting.GlobalShadows = _G.AmiSettings.GlobalShadows
        local techMap = {
            ["Legacy"] = Enum.Technology.Legacy,
            ["Voxel"] = Enum.Technology.Voxel,
            ["ShadowMap"] = Enum.Technology.ShadowMap,
            ["Future"] = Enum.Technology.Future,
        }
        Lighting.Technology = techMap[_G.AmiSettings.Technology] or Enum.Technology.Legacy
    end
    local function createSnowEffect()
        if snowPart then return end
        snowPart = Instance.new("Part")
        snowPart.Name = "AmiSnowEmitter"
        snowPart.Size = Vector3.new(200, 1, 200)
        snowPart.Anchored = true
        snowPart.CanCollide = false
        snowPart.Transparency = 1
        snowPart.Parent = workspace
        snowEmitter = Instance.new("ParticleEmitter")
        snowEmitter.Name = "Snow"
        snowEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
        snowEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        snowEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        snowEmitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.8, 0.1),
            NumberSequenceKeypoint.new(1, 1)
        })
        snowEmitter.Lifetime = NumberRange.new(20, 25)
        snowEmitter.Rate = 1600
        snowEmitter.Rotation = NumberRange.new(0, 360)
        snowEmitter.RotSpeed = NumberRange.new(-50, 50)
        snowEmitter.Speed = NumberRange.new(1, 3)
        snowEmitter.SpreadAngle = Vector2.new(0, 0)
        snowEmitter.VelocityInheritance = 0
        snowEmitter.Acceleration = Vector3.new(0, -2, 0)
        snowEmitter.EmissionDirection = Enum.NormalId.Bottom
        snowEmitter.LightEmission = 0.7
        snowEmitter.LightInfluence = 0
        snowEmitter.Parent = snowPart
        RunService.RenderStepped:Connect(function()
            if snowPart and _G.AmiSettings.SnowEnabled and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    snowPart.Position = hrp.Position + Vector3.new(0, 50, 0)
                end
            end
        end)
    end
    local function removeSnowEffect()
        if snowPart then
            snowPart:Destroy()
            snowPart = nil
            snowEmitter = nil
        end
    end
    local function applyAllAtmosphere()
        if _G.AmiSettings.SkyEnabled then
            applySkybox(_G.AmiSettings.SelectedSky)
        else
            clearSkybox()
        end
        applyFog()
        applyColorCorrection()
        applyLighting()
        if _G.AmiSettings.SnowEnabled then
            createSnowEffect()
        else
            removeSnowEffect()
        end
    end
    _G.AmiColors = {
        MurdererFill = Color3.fromRGB(255,0,0),
        MurdererFillTrans = 0.4,
        MurdererOutline = Color3.fromRGB(255,255,255),
        MurdererOutlineTrans = 0.1,
        SheriffFill = Color3.fromRGB(0,0,255),
        SheriffFillTrans = 0.4,
        SheriffOutline = Color3.fromRGB(255,255,255),
        SheriffOutlineTrans = 0.1,
        InnocentFill = Color3.fromRGB(0,255,0),
        InnocentFillTrans = 0.4,
        InnocentOutline = Color3.fromRGB(255,255,255),
        InnocentOutlineTrans = 0.1,
        LobbyFill = Color3.fromRGB(255,255,255),
        LobbyFillTrans = 1,
        GunFill = Color3.fromRGB(255,255,0),
        GunFillTrans = 0.3,
    }
    local function detectRoles()
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            if char then
                local bp = p:FindFirstChild("Backpack")
                if char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then
                    currentRoles[p.Name] = "Murderer"
                elseif char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then
                    currentRoles[p.Name] = "Sheriff"
                else
                    currentRoles[p.Name] = nil
                end
            else
                currentRoles[p.Name] = nil
            end
        end
    end
    local function findPlayerByRole(role)
        detectRoles()
        for name, r in pairs(currentRoles) do
            if r == role then
                local pl = Players:FindFirstChild(name)
                if pl and pl ~= LocalPlayer and pl.Character then return pl end
            end
        end
        return nil
    end
    local function getMyRole()
        local r = currentRoles[LocalPlayer.Name]
        if not r and savedPlayerData[LocalPlayer.Name] then
            r = savedPlayerData[LocalPlayer.Name].Role
        end
        return r or "Unknown"
    end
    local function getPlayersNames()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        table.sort(t)
        return t
    end
    local EspFolder = Instance.new("Folder", workspace)
    EspFolder.Name = "AmiESP"
    local function UpdateESP()
        if not _G.AmiSettings.EspEnabled then
            for _, child in ipairs(EspFolder:GetChildren()) do
                child:Destroy()
            end
            return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local hl = EspFolder:FindFirstChild(plr.Name)
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = plr.Name
                hl.Parent = EspFolder
            end
            hl.Adornee = char
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            local hasKnife = plr.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local hasGun = plr.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
            if hasKnife then
                hl.FillColor = _G.AmiColors.MurdererFill or Color3.fromRGB(255, 0, 0)
            elseif hasGun then
                hl.FillColor = _G.AmiColors.SheriffFill or Color3.fromRGB(0, 100, 255)
            else
                hl.FillColor = _G.AmiColors.InnocentFill or Color3.fromRGB(0, 255, 100)
            end
            if _G.AmiSettings.NamesESP then
                local head = char:FindFirstChild("Head")
                if head then
                    local nameTag = EspFolder:FindFirstChild(plr.Name .. "_Name")
                    if not nameTag then
                        nameTag = Instance.new("BillboardGui")
                        nameTag.Name = plr.Name .. "_Name"
                        nameTag.Parent = head
                        nameTag.AlwaysOnTop = true
                        nameTag.Size = UDim2.new(0, 200, 0, 40)
                        nameTag.StudsOffset = Vector3.new(0, 2.5, 0)
                        nameTag.MaxDistance = 500
                        local label = Instance.new("TextLabel")
                        label.Name = "NameLabel"
                        label.Parent = nameTag
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextSize = 14
                        label.Font = Enum.Font.SourceSansBold
                        label.TextStrokeTransparency = 0.5
                        label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                        label.Text = plr.Name
                    else
                        local label = nameTag:FindFirstChild("NameLabel")
                        if label then label.Text = plr.Name end
                    end
                end
            else
                for _, child in ipairs(EspFolder:GetChildren()) do
                    if string.find(child.Name, "_Name") then
                        child:Destroy()
                    end
                end
            end
        end
        for _, child in ipairs(EspFolder:GetChildren()) do
            if not Players:FindFirstChild(child.Name) and not string.find(child.Name, "_Name") then
                child:Destroy()
            end
        end
    end
    task.spawn(function()
        while true do
            pcall(UpdateESP)
            task.wait(0.3)
        end
    end)
    local GunHighlight = nil
    task.spawn(function()
        while true do
            if _G.AmiSettings.GunEspEnabled then
                local gun = workspace:FindFirstChild("GunDrop", true)
                if gun then
                    if not GunHighlight or GunHighlight.Adornee ~= gun then
                        if GunHighlight then GunHighlight:Destroy() end
                        GunHighlight = Instance.new("Highlight", gun)
                        GunHighlight.FillColor = _G.AmiColors.GunFill or Color3.fromRGB(255, 255, 0)
                        GunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                else
                    if GunHighlight then
                        GunHighlight:Destroy()
                        GunHighlight = nil
                    end
                end
            else
                if GunHighlight then
                    GunHighlight:Destroy()
                    GunHighlight = nil
                end
            end
            task.wait(0.5)
        end
    end)
    local function setXray(v)
        _G.AmiSettings.XrayEnabled = v
        local function scan(z, t)
            for _, i in pairs(z:GetChildren()) do
                if i:IsA("BasePart") and not i.Parent:FindFirstChild("Humanoid") and not i.Parent.Parent:FindFirstChild("Humanoid") then
                    i.LocalTransparencyModifier = t
                end
                scan(i, t)
            end
        end
        scan(workspace, v and 0.9 or 0)
    end
    local function setAntiFling(state)
        _G.AmiSettings.AntiFlingEnabled = state
        if state then
            if not antiFlingDetectConn then
                antiFlingDetectConn = RunService.Heartbeat:Connect(function()
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= LocalPlayer and pl.Character and pl.Character.PrimaryPart then
                            local angular = pl.Character.PrimaryPart.AssemblyAngularVelocity.Magnitude
                            local linear = pl.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude
                            if angular > 50 or linear > 100 then
                                if not antiFlingDetectedPlayers[pl.Name] then
                                    antiFlingDetectedPlayers[pl.Name] = true
                                end
                                for _, part in ipairs(pl.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                        part.AssemblyAngularVelocity = Vector3.zero
                                        part.AssemblyLinearVelocity = Vector3.zero
                                        part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)
                                    end
                                end
                            end
                        end
                    end
                    local char = LocalPlayer.Character
                    if char and char.PrimaryPart then
                        local root = char.PrimaryPart
                        if root.AssemblyLinearVelocity.Magnitude > 250 or root.AssemblyAngularVelocity.Magnitude > 250 then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            if getgenv().OldPos then root.CFrame = getgenv().OldPos end
                        else
                            getgenv().OldPos = root.CFrame
                        end
                    end
                end)
            end
        else
            if antiFlingDetectConn then
                antiFlingDetectConn:Disconnect()
                antiFlingDetectConn = nil
            end
            antiFlingDetectedPlayers = {}
        end
    end
    function AntiLock()
        if not _G.AmiSettings.AntiLock then return end
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then
            local root = char.PrimaryPart
            root.Velocity = Vector3.new(root.Velocity.X, -10000, root.Velocity.Z)
            task.wait(0.05)
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
    end
    local oldKick = function() end
    pcall(function()
        if debug and debug.getupvalue then
            oldKick = debug.getupvalue(game.Players.LocalPlayer.Kick, 1) or function() end
        end
    end)
    local function activateGodmode()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Name = "1"
            local clone = hum:Clone()
            clone.Parent = char
            clone.Name = "Humanoid"
            task.wait(0.1)
            char["1"]:Destroy()
            Camera.CameraSubject = clone
            local anim = char:FindFirstChild("Animate")
            if anim then
                anim.Disabled = true
                task.wait(0.1)
                anim.Disabled = false
            end
        end
    end
    local function setKnifeAura(v)
        _G.AmiSettings.KnifeAuraEnabled = v
        if v then
            if knifeAuraConn then knifeAuraConn:Disconnect() end
            knifeAuraConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local knife = char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
                if not knife then return end
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - char.HumanoidRootPart.Position).Magnitude < _G.AmiSettings.KnifeAuraRange then
                            if knife.Parent ~= char then
                                LocalPlayer.Character.Humanoid:EquipTool(knife)
                            end
                            local stab = knife:FindFirstChild("Stab")
                            if stab then
                                stab:FireServer("Down")
                            end
                            firetouchinterest(hrp, knife.Handle, 1)
                            firetouchinterest(hrp, knife.Handle, 0)
                        end
                    end
                end
            end)
        else
            if knifeAuraConn then knifeAuraConn:Disconnect() end
            knifeAuraConn = nil
        end
    end
    local function toggleExtremeFling(state)
        _G.AmiSettings.ExtremeFlingEnabled = state
        if state then
            if extremeFlingThread then
                coroutine.close(extremeFlingThread)
                extremeFlingThread = nil
            end
            extremeFlingThread = coroutine.create(function()
                local lp = LocalPlayer
                local movel = 0.1
                while _G.AmiSettings.ExtremeFlingEnabled do
                    RunService.Heartbeat:Wait()
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.Velocity
                        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        if hrp then
                            hrp.Velocity = vel
                        end
                        RunService.Stepped:Wait()
                        if hrp then
                            hrp.Velocity = vel + Vector3.new(0, movel, 0)
                            movel = -movel
                        end
                    end
                end
            end)
            coroutine.resume(extremeFlingThread)
        else
            if extremeFlingThread then
                coroutine.close(extremeFlingThread)
                extremeFlingThread = nil
            end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                end
            end
        end
    end
    local function killAll()
        if killAllActive then
            killAllActive = false
            return
        end
        local char = LocalPlayer.Character
        local knife = char and (char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife")))
        if not knife then
            return
        end
        killAllActive = true
        task.spawn(function()
            while killAllActive do
                local found = false
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                        local tr = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and tr then
                            found = true
                            local myRoot = char:FindFirstChild("HumanoidRootPart")
                            local myHum = char:FindFirstChildOfClass("Humanoid")
                            if not myRoot or not myHum or myHum.Health <= 0 then
                                killAllActive = false
                                break
                            end
                            knife = char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
                            if knife and knife.Parent ~= char then
                                myHum:EquipTool(knife)
                                task.wait(0.1)
                            end
                            local st = tick()
                            repeat
                                if not killAllActive or not tr.Parent or hum.Health <= 0 then break end
                                myRoot.CFrame = tr.CFrame * CFrame.new(0,0,1.5)
                                if knife and knife.Parent == char then
                                    knife:Activate()
                                end
                                task.wait()
                            until hum.Health <= 0 or tick() - st > 3
                        end
                    end
                end
                if not found then
                    killAllActive = false
                    break
                end
                task.wait(0.1)
            end
            killAllActive = false
        end)
    end
    local function applyMovement()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local inAir = hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping
        hum.WalkSpeed = (_G.AmiSettings.SpeedGlitchEnabled and inAir) and _G.AmiSettings.GlitchSpeed or _G.AmiSettings.WalkSpeed
        hum.JumpPower = _G.AmiSettings.JumpPower
        hum.UseJumpPower = true
    end
    local function setFly(v)
        _G.AmiSettings.FlyEnabled = v
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if v then
            if flyConnection then flyConnection:Disconnect() end
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            bv.Parent = root
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bg.CFrame = Camera.CFrame
            bg.Parent = root
            flyConnection = RunService.RenderStepped:Connect(function()
                if not _G.AmiSettings.FlyEnabled then return end
                local cam = Camera
                bg.CFrame = cam.CFrame
                local vel = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0,1,0) end
                bv.Velocity = vel * _G.AmiSettings.FlySpeed
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
            if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
            flyConnection = nil
        end
    end
    local function setNoclip(v)
        _G.AmiSettings.NoclipEnabled = v
        if v then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = nil
        end
    end
    local function setAntiAfk(v)
        _G.AmiSettings.AntiAfkEnabled = v
        if v then
            if antiAfkConnection then antiAfkConnection:Disconnect() end
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            if antiAfkConnection then antiAfkConnection:Disconnect() end
            antiAfkConnection = nil
        end
    end
    local PlayEmoteEvent
    pcall(function()
        PlayEmoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("PlayEmote")
    end)
    local function playEmote(name)
        if PlayEmoteEvent then
            pcall(function() PlayEmoteEvent:Fire(name) end)
        else
        end
    end
    _G._OctreeModule = _G._OctreeModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
    function findMurdererForFarm()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local success, result = pcall(function()
            return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        end)
        if success and result then
            for name, data in pairs(result) do
                if data.Role == "Murderer" then
                    return game:GetService("Players"):FindFirstChild(name)
                end
            end
        end
        return nil
    end
    do
        local OctreeModule = _G._OctreeModule
        local function getMap()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
                    return obj
                end
            end
            return nil
        end
        local function getNearestCoinAwayFromMurderer(charPosition, radius)
            if not charPosition then return nil end
            local map = getMap()
            if not map or not map:FindFirstChild("CoinContainer") then return nil end
            local octree = OctreeModule.new()
            for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                local v = coin:FindFirstChild("CoinVisual")
                if v and not v:GetAttribute("Collected") then
                    octree:CreateNode(coin.Position, coin)
                end
            end
            local candidates = octree:GetNearest(charPosition, radius, 10)
            if not candidates or #candidates == 0 then return nil end
            local murderer = findMurdererForFarm()
            local murdererPos = nil
            if murderer and murderer.Character then
                local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then murdererPos = hrp.Position end
            end
            if not murdererPos then
                return candidates[1] and candidates[1].Object or nil
            end
            local best = nil
            local bestDist = -1
            for _, node in ipairs(candidates) do
                local coin = node and node.Object
                if coin and coin.Position then
                    local d = (coin.Position - murdererPos).Magnitude
                    if d > bestDist then
                        bestDist = d
                        best = coin
                    end
                end
            end
            return best or (candidates[1] and candidates[1].Object or nil)
        end
        local function moveToPositionSlowly(character, targetPosition, duration)
            if not character or not targetPosition then return end
            local startPosition = character:GetPivot().Position
            local moveStartTime = tick()
            while _G.AmiSettings.CoinFarmEnabled do
                local elapsed = tick() - moveStartTime
                local alpha = math.min(elapsed / duration, 1)
                local lerpedPos = startPosition:Lerp(targetPosition, alpha)
                character:PivotTo(CFrame.new(lerpedPos))
                if alpha >= 1 then
                    task.wait(0.2)
                    break
                end
                task.wait()
            end
        end
        local function waitForCharacterFarm()
            while _G.AmiSettings.CoinFarmEnabled do
                local char = LocalPlayer.Character
                if char and LocalPlayer:GetAttribute("Alive") then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        return char, hrp, hum
                    end
                end
                task.wait(0.5)
            end
            return nil, nil, nil
        end
        local function startCoinFarm()
            if _G._coinFarmThread then return end
            _G.AmiSettings.CoinFarmEnabled = true
            _G._collectedCoins = 0
            _G._farmStartTime = tick()
            _G._roundStartTimeFarm = tick()
            _G._currentRoundFarm = 0
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local RoundStart = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("RoundStart")
            RoundStart.OnClientEvent:Connect(function()
                if _G.AmiSettings.CoinFarmEnabled then
                    _G._currentRoundFarm = _G._currentRoundFarm + 1
                    _G._roundStartTimeFarm = tick()
                end
            end)
            _G._coinFarmThread = task.spawn(function()
                while _G.AmiSettings.CoinFarmEnabled do
                    local char, hrp, hum = waitForCharacterFarm()
                    if not char then break end
                    local map = getMap()
                    while _G.AmiSettings.CoinFarmEnabled and not map do
                        task.wait(1)
                        map = getMap()
                    end
                    if not _G.AmiSettings.CoinFarmEnabled then break end
                    local coinsCollectedThisRound = 0
                    while _G.AmiSettings.CoinFarmEnabled do
                        if not (char and char.Parent and LocalPlayer:GetAttribute("Alive")) then
                            break
                        end
                        if not char:FindFirstChildOfClass("Humanoid") then break end
                        local charPos = char:GetPivot().Position
                        local target = getNearestCoinAwayFromMurderer(charPos, _G.AmiSettings.CoinFarmRadius)
                        if target then
                            local targetPos = target.Position
                            local distance = (charPos - targetPos).Magnitude
                            local duration = math.max(0.5, distance / _G.AmiSettings.CoinFarmSpeed)
                            pcall(function()
                                moveToPositionSlowly(char, targetPos, duration)
                            end)
                            local v = target:FindFirstChild("CoinVisual")
                            local waitTime = 0
                            while _G.AmiSettings.CoinFarmEnabled and v and not v:GetAttribute("Collected") and v.Parent and waitTime < 10 do
                                if not LocalPlayer:GetAttribute("Alive") then break end
                                local newTarget = getNearestCoinAwayFromMurderer(char:GetPivot().Position, _G.AmiSettings.CoinFarmRadius)
                                if newTarget and newTarget ~= target then break end
                                task.wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                            coinsCollectedThisRound = coinsCollectedThisRound + 1
                            _G._collectedCoins = _G._collectedCoins + 1
                            if coinsCollectedThisRound >= _G.AmiSettings.MaxCoinsPerRound then
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                    LocalPlayer.Character.Humanoid.Health = 0
                                end
                                task.wait(3)
                                break
                            end
                        else
                            if (tick() - _G._roundStartTimeFarm) > 30 then
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                    LocalPlayer.Character.Humanoid.Health = 0
                                end
                                task.wait(3)
                                break
                            end
                            task.wait(2)
                        end
                    end
                end
                _G._coinFarmThread = nil
            end)
        end
        local function stopCoinFarm()
            _G.AmiSettings.CoinFarmEnabled = false
            if _G._coinFarmThread then
                task.cancel(_G._coinFarmThread)
                _G._coinFarmThread = nil
            end
        end
        _G.toggleCoinFarm = function(v)
            if v then
                startCoinFarm()
            else
                stopCoinFarm()
            end
        pcall(saveSettings)  
         end
    end
    if _G.AmiSettings.AutoFlingMurderer then
        LocalPlayer.CharacterAdded:Connect(function()
            if _G.AmiSettings.CoinFarmEnabled and _G.AmiSettings.AutoFlingMurderer then
                task.wait(2)
                local murderer = findMurdererForFarm()
                if murderer then
                    FlingActive = true
                    task.spawn(function()
                        SkidFling(murderer)
                        FlingActive = false
                    end)
                end
            end
        end)
    end
    function SkidFling(TargetPlayer)
        if not TargetPlayer or not TargetPlayer.Character then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        if not root then return end
        local tchar = TargetPlayer.Character
        local thum = tchar:FindFirstChildOfClass("Humanoid")
        local troot = thum and thum.RootPart
        local thead = tchar:FindFirstChild("Head")
        if thum and thum.Sit then return end
        local oldSubject = Camera.CameraSubject
        if thead then Camera.CameraSubject = thead
        elseif thum then Camera.CameraSubject = thum end
        if root.Velocity.Magnitude < 50 then getgenv().OldPos = root.CFrame end
        workspace.FallenPartsDestroyHeight = 0/0
        local bv = Instance.new("BodyVelocity")
        bv.Parent = root
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        local ang = 0
        for i = 1, 150 do
            if not root or not thum then break end
            ang = ang + 180
            root.CFrame = CFrame.new(troot.Position) * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(ang), 0, 0)
            root.Velocity = Vector3.new(2e8, 2.5e9, 2e8)
            root.RotVelocity = Vector3.new(2.5e9, 2.5e9, 2.5e9)
            task.wait(0.03)
        end
        bv:Destroy()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Velocity = Vector3.zero; part.RotVelocity = Vector3.zero end
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        if oldSubject and oldSubject.Parent then Camera.CameraSubject = oldSubject else Camera.CameraSubject = hum end
        if getgenv().OldPos then
            local attempts = 0
            repeat
                root.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                char:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                task.wait()
                attempts = attempts + 1
            until (root.Position - getgenv().OldPos.p).Magnitude < 25 or attempts > 50
            workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
        end
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Running)
        task.wait(0.1)
        hum.WalkSpeed = _G.AmiSettings.WalkSpeed or 16
    end
    local function setupDropkickAndRun()
        local BASE_WALKSPEED = 16
        local EMOTE_ID = "rbxassetid://133566007754001"
        local RUN_ANIM_ID = "rbxassetid://70636286183373"
        local function getHumanoid()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            return char:WaitForChild("Humanoid", 5)
        end
        local function playDropkickEmote()
            local hum = getHumanoid()
            if not hum then return end
            local anim = Instance.new("Animation")
            anim.AnimationId = EMOTE_ID
            dropkickTrack = hum:LoadAnimation(anim)
            dropkickTrack.Priority = Enum.AnimationPriority.Action
            dropkickTrack.Looped = false
            dropkickTrack:Play()
        end
        local function startDropkickFling()
            dropkickActive = true
            task.spawn(function()
                while dropkickActive do
                    RunService.Heartbeat:Wait()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.Velocity
                        hrp.Velocity = vel * _G.AmiSettings.DropkickPower + Vector3.new(0, 0, _G.AmiSettings.DropkickPower)
                        RunService.RenderStepped:Wait()
                        if hrp then hrp.Velocity = vel end
                        RunService.Stepped:Wait()
                        if hrp then hrp.Velocity = vel + Vector3.new(0, 0.1, 0) end
                    end
                end
            end)
        end
        local function stopDropkickFling()
            dropkickActive = false
        end
        local function activateDropkick()
            if not dropkickEnabled then
                return
            end
            if dropkickBusy then return end
            dropkickBusy = true
            if runTrack then runTrack:Stop() end
            playDropkickEmote()
            startDropkickFling()
            task.delay(2, function()
                stopDropkickFling()
                if dropkickTrack then
                    dropkickTrack:Stop()
                    dropkickTrack = nil
                end
            end)
            task.spawn(function()
                for i = 3, 1, -1 do
                    task.wait(1)
                end
                dropkickBusy = false
            end)
        end
        local function toggleRun()
            if not runEnabled then
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if runActive then
                runActive = false
                hum.WalkSpeed = BASE_WALKSPEED
                if runAnimConnection then runAnimConnection:Disconnect() end
                if runTrack then runTrack:Stop(); runTrack = nil end
            else
                runActive = true
                hum.WalkSpeed = math.max(0.5, BASE_WALKSPEED * (_G.AmiSettings.RunSpeedPercent / 100))
                local anim = Instance.new("Animation")
                anim.AnimationId = RUN_ANIM_ID
                runTrack = hum:LoadAnimation(anim)
                runTrack.Priority = Enum.AnimationPriority.Action
                runTrack.Looped = true
                runAnimConnection = RunService.RenderStepped:Connect(function()
                    local currentHum = char:FindFirstChildOfClass("Humanoid")
                    if not currentHum or not runTrack then return end
                    local dropkickIsPlaying = (dropkickTrack and dropkickTrack.IsPlaying)
                    if currentHum.MoveDirection.Magnitude > 0 and currentHum.FloorMaterial ~= Enum.Material.Air and not dropkickIsPlaying then
                        if not runTrack.IsPlaying then runTrack:Play() end
                        runTrack:AdjustSpeed(1)
                    else
                        if runTrack.IsPlaying then runTrack:Stop() end
                    end
                end)
            end
        end
        local dropkickHotkeyConn, runHotkeyConn
        if _G.dropkickHotkeyConn then _G.dropkickHotkeyConn:Disconnect() end
        if _G.runHotkeyConn then _G.runHotkeyConn:Disconnect() end
        _G.dropkickHotkeyConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == _G.AmiSettings.DropkickHotkey and dropkickEnabled then
                activateDropkick()
            elseif input.KeyCode == _G.AmiSettings.RunHotkey and runEnabled then
                toggleRun()
            end
        end)
        LocalPlayer.CharacterAdded:Connect(function()
            dropkickBusy = false
            dropkickActive = false
            runActive = false
            if dropkickTrack then dropkickTrack:Stop(); dropkickTrack = nil end
            if runTrack then runTrack:Stop(); runTrack = nil end
            if runAnimConnection then runAnimConnection:Disconnect(); runAnimConnection = nil end
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = BASE_WALKSPEED end
        end)
        return {
            setDropkickEnabled = function(v) dropkickEnabled = v end,
            setRunEnabled = function(v) runEnabled = v end,
            activateDropkick = activateDropkick,
            toggleRun = toggleRun,
            isRunActive = function() return runActive end,
        }
    end
    local DropkickAPI = setupDropkickAndRun()
    local function createStandaloneStats()
        local executorName = "Unknown"
        if getexecutorname then
            executorName = getexecutorname()
        elseif syn then
            executorName = "Synapse X"
        elseif krnl then
            executorName = "Krnl"
        elseif script_context and script_context.executor then
            executorName = script_context.executor
        elseif is_sirhurt_closure then
            executorName = "Sirhurt"
        elseif cheat then
            executorName = "Cheat"
        else
            if syn and syn.request then executorName = "Synapse X"
            elseif krnl and krnl.request then executorName = "Krnl"
            elseif request then executorName = "Script-Ware" 
            end
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "AmiStandaloneStats"
        gui.ResetOnSpawn = false
     pcall(function()
        if gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
    end)
    if not gui.Parent then
        gui.Parent = CoreGui
    end
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = true
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 240, 0, 40)
        frame.Position = UDim2.new(0.5, -120, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(130, 200, 255)
        stroke.Thickness = 0.5
        stroke.Transparency = 0.3
        stroke.Parent = frame
        local leftBlock = Instance.new("Frame")
        leftBlock.Size = UDim2.new(0, 80, 1, 0)
        leftBlock.BackgroundTransparency = 1
        leftBlock.Parent = frame
        local logo = Instance.new("TextLabel")
        logo.Size = UDim2.new(1, 0, 0, 18)
        logo.Position = UDim2.new(0, 4, 0, 1)
        logo.BackgroundTransparency = 1
        logo.Font = Enum.Font.GothamBold
        logo.Text = "Yusuf.exe"
        logo.TextColor3 = Color3.fromRGB(240, 240, 255)
        logo.TextSize = 12
        logo.TextXAlignment = Enum.TextXAlignment.Left
        logo.TextYAlignment = Enum.TextYAlignment.Bottom
        logo.Parent = leftBlock
        local execLabel = Instance.new("TextLabel")
        execLabel.Size = UDim2.new(1, 0, 0, 14)
        execLabel.Position = UDim2.new(0, 4, 0, 19)
        execLabel.BackgroundTransparency = 1
        execLabel.Font = Enum.Font.Gotham
        execLabel.Text = "Executor: " .. executorName
        execLabel.TextColor3 = Color3.fromRGB(180, 190, 220)
        execLabel.TextSize = 8
        execLabel.TextXAlignment = Enum.TextXAlignment.Left
        execLabel.TextYAlignment = Enum.TextYAlignment.Top
        execLabel.Parent = leftBlock
        local statsContainer = Instance.new("Frame")
        statsContainer.Size = UDim2.new(0, 156, 1, 0)
        statsContainer.Position = UDim2.new(0, 80, 0, 0)
        statsContainer.BackgroundTransparency = 1
        statsContainer.Parent = frame
        local statLayout = Instance.new("UIListLayout")
        statLayout.Padding = UDim.new(0, 4)
        statLayout.FillDirection = Enum.FillDirection.Horizontal
        statLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        statLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        statLayout.Parent = statsContainer
        local function createStatBlock(labelText, color)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(0, 48, 0, 28)
            container.BackgroundTransparency = 1
            container.Parent = statsContainer
            local value = Instance.new("TextLabel")
            value.Size = UDim2.new(1, 0, 0.6, 0)
            value.Position = UDim2.new(0, 0, 0, 0)
            value.BackgroundTransparency = 1
            value.Font = Enum.Font.GothamBold
            value.Text = "0"
            value.TextColor3 = color
            value.TextSize = 12
            value.TextXAlignment = Enum.TextXAlignment.Right
            value.TextYAlignment = Enum.TextYAlignment.Bottom
            value.Parent = container
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0.4, 0)
            label.Position = UDim2.new(0, 0, 0.6, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.Text = labelText
            label.TextColor3 = Color3.fromRGB(180, 190, 220)
            label.TextSize = 8
            label.TextXAlignment = Enum.TextXAlignment.Right
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.Parent = container
            return value, label
        end
        local fpsValue, _ = createStatBlock("FPS", Color3.fromRGB(240, 240, 255))
        local pingValue, _ = createStatBlock("Ping", Color3.fromRGB(180, 190, 220))
        local timeValue, _ = createStatBlock("Time", Color3.fromRGB(130, 200, 255))
        local lastTime = tick()
        local frameCount = 0
        local fps = 0
        local ping = 0
        local function getPing()
            local success, result = pcall(function()
                return game:GetService("Stats"):GetService("Network"):GetPing()
            end)
            if success and result then return math.floor(result) end
            return 0
        end
        game:GetService("RunService").Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local currentTime = tick()
            if currentTime - lastTime >= 1 then
                fps = frameCount
                frameCount = 0
                lastTime = currentTime
                ping = getPing()
                fpsValue.Text = tostring(fps)
                pingValue.Text = tostring(ping) .. "ms"
                timeValue.Text = os.date("%H:%M")
            end
        end)
        _G.AmiStandaloneStats = gui
        return gui
    end
    local statsGui = createStandaloneStats()
    _G.AmiStandaloneStats = statsGui
    function toggleStandaloneStats(visible)
        if _G.AmiStandaloneStats then
            _G.AmiStandaloneStats.Enabled = visible
        end
    end
    local function giveJerkTool()
        local bp = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
        if bp:FindFirstChild("Jerk") then
            bp.Jerk:Destroy()
        end
        local tool = Instance.new("Tool")
        tool.Name = "Jerk"
        tool.RequiresHandle = false
        tool.Parent = bp
        tool.Equipped:Connect(function()
            jerking = true
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://698251653"
            jerkAnimTrack = animator:LoadAnimation(anim)
            task.spawn(function()
                while jerking and jerkAnimTrack do
                    jerkAnimTrack:Play()
                    jerkAnimTrack:AdjustSpeed(jerkSpeed)
                    jerkAnimTrack.TimePosition = 0.4
                    task.wait(0.1)
                end
            end)
        end)
        tool.Unequipped:Connect(function()
            jerking = false
            if jerkAnimTrack then
                jerkAnimTrack:Stop()
                jerkAnimTrack = nil
            end
        end)
    end
    local function bangPlayer(targetName)
        if not targetName then
            return
        end
        local target = Players:FindFirstChild(targetName)
        if not target or not target.Character then
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            return
        end
        isBanging = false
        if bangFollowConn then bangFollowConn:Disconnect() end
        if bangAnimTrack then bangAnimTrack:Stop() end
        isBanging = true
        bangFollowConn = RunService.Heartbeat:Connect(function()
            if not isBanging then return end
            local tChar = target.Character
            local mChar = LocalPlayer.Character
            if tChar and mChar and tChar:FindFirstChild("HumanoidRootPart") and mChar:FindFirstChild("HumanoidRootPart") then
                local tRoot = tChar.HumanoidRootPart
                local mRoot = mChar.HumanoidRootPart
                mRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0.2, 1.1)
            end
        end)
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://5918726674"
            bangAnimTrack = animator:LoadAnimation(anim)
            task.spawn(function()
                while isBanging and bangAnimTrack do
                    bangAnimTrack:Play()
                    bangAnimTrack:AdjustSpeed(bangSpeed)
                    task.wait(0.08)
                end
            end)
        end
    end
    local function stopBang()
        isBanging = false
        if bangFollowConn then
            bangFollowConn:Disconnect()
            bangFollowConn = nil
        end
        if bangAnimTrack then
            bangAnimTrack:Stop()
            bangAnimTrack = nil
        end
    end
    local function setImproveFPS(v)
        _G.AmiSettings.ImproveFPS = v
        if v then
            pcall(function()
                local Terrain = workspace:FindFirstChildOfClass('Terrain')
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 0
                end
                game.Lighting.GlobalShadows = false
                game.Lighting.FogEnd = 9e9
                settings().Rendering.QualityLevel = 1
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    elseif v:IsA("Explosion") then
                        v.BlastPressure = 1
                        v.BlastRadius = 1
                    end
                end
                for _, v in ipairs(game.Lighting:GetDescendants()) do
                    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = false
                    end
                end
                if fpsBoostConn then fpsBoostConn:Disconnect() end
                fpsBoostConn = workspace.DescendantAdded:Connect(function(child)
                    if child:IsA('ForceField') or child:IsA('Sparkles') or child:IsA('Smoke') or child:IsA('Fire') then
                        task.wait(0.1)
                        child:Destroy()
                    end
                end)
            end)
        else
            if fpsBoostConn then
                fpsBoostConn:Disconnect()
                fpsBoostConn = nil
            end
        end
    end
    local bulletTracerConn = nil
    local function createTracerBeam(fromPos, toPos, color, transparency, width, lifetime)
        local distance = (toPos - fromPos).Magnitude
        if distance < 0.01 then return end
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.1, 0.1, distance)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Transparency = 1
        beamPart.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2)
        beamPart.Parent = workspace
        local attach0 = Instance.new("Attachment", beamPart)
        attach0.Position = Vector3.new(0, 0, distance / 2)
        local attach1 = Instance.new("Attachment", beamPart)
        attach1.Position = Vector3.new(0, 0, -distance / 2)
        local beam = Instance.new("Beam")
        beam.Attachment0 = attach0
        beam.Attachment1 = attach1
        beam.Color = ColorSequence.new(color)
        beam.Transparency = NumberSequence.new(transparency)
        beam.Width0 = width
        beam.Width1 = width
        beam.FaceCamera = true
        beam.Texture = "rbxasset://textures/particles/beam.dds"
        beam.LightEmission = 0.8
        beam.Parent = beamPart
        Debris:AddItem(beamPart, lifetime)
    end
    local function createMuzzleFlash(pos, color)
        local flash = Instance.new("Part")
        flash.Shape = Enum.PartType.Ball
        flash.Size = Vector3.new(0.3, 0.3, 0.3)
        flash.Anchored = true
        flash.CanCollide = false
        flash.Material = Enum.Material.Neon
        flash.BrickColor = BrickColor.new(color)
        flash.Transparency = 0.3
        flash.Position = pos
        flash.Parent = workspace
        task.delay(0.05, function()
            for _ = 1, 4 do
                if flash and flash.Parent then
                    flash.Transparency = flash.Transparency + 0.15
                    flash.Size = flash.Size - Vector3.new(0.02, 0.02, 0.02)
                    task.wait(0.02)
                end
            end
            if flash and flash.Parent then flash:Destroy() end
        end)
    end
    local function createImpactSpark(pos, color)
        local spark = Instance.new("Part")
        spark.Shape = Enum.PartType.Ball
        spark.Size = Vector3.new(0.25, 0.25, 0.25)
        spark.Anchored = true
        spark.CanCollide = false
        spark.Material = Enum.Material.Neon
        spark.BrickColor = BrickColor.new(color)
        spark.Transparency = 0.1
        spark.Position = pos
        spark.Parent = workspace
        task.spawn(function()
            for _ = 1, 5 do
                if spark and spark.Parent then
                    spark.Size = spark.Size + Vector3.new(0.05, 0.05, 0.05)
                    spark.Transparency = spark.Transparency + 0.12
                    task.wait(0.03)
                end
            end
            if spark and spark.Parent then spark:Destroy() end
        end)
    end
    local function startBulletTracer()
        if bulletTracerConn then return end
        local WeaponService
        pcall(function() WeaponService = require(ReplicatedStorage.ClientServices.WeaponService) end)
        if not WeaponService or not WeaponService.GunFired then
            Notify("Bullet Tracer", "WeaponService not found", 3)
            return
        end
        local function watchAndRemoveShrapnel()
            local partsToRemove = {}
            local conn
            conn = workspace.DescendantAdded:Connect(function(part)
                if part:IsA("BasePart") and part.Name == "Part" then
                    table.insert(partsToRemove, part)
                end
            end)
            task.delay(0.1, function()
                if conn then conn:Disconnect() end
                for _, part in ipairs(partsToRemove) do
                    if part and part.Parent then
                        part:Destroy()
                    end
                end
            end)
        end
        local function onGunFired(...)
            watchAndRemoveShrapnel()
            local args = {...}
            local origin, target = nil, nil
            if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                origin, target = args[1], args[2]
            elseif typeof(args[1]) == "CFrame" and typeof(args[2]) == "CFrame" then
                origin, target = args[1].Position, args[2].Position
            elseif typeof(args[2]) == "Vector3" and typeof(args[3]) == "Vector3" then
                origin, target = args[2], args[3]
            else
                local cam = workspace.CurrentCamera
                origin = cam.CFrame.Position
                local cf = WeaponService.GetTargetPosition(nil, cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                target = cf.Position
            end
            if origin and target then
                local color = _G.AmiSettings.BulletTracerColor
                local trans = _G.AmiSettings.BulletTracerTransparency
                local life = _G.AmiSettings.BulletTracerLifetime
                createTracerBeam(origin, target, color, trans + 0.4, 0.35, life)
                createTracerBeam(origin, target, color, trans, 0.08, life)
                createMuzzleFlash(origin, color)
                createImpactSpark(target, color)
            end
        end
        bulletTracerConn = WeaponService.GunFired.OnClientEvent:Connect(onGunFired)
    end
    local function stopBulletTracer()
        if bulletTracerConn then
            if type(bulletTracerConn) == "table" then
                bulletTracerConn.Conn1:Disconnect()
                bulletTracerConn.Conn2:Disconnect()
            else
                bulletTracerConn:Disconnect()
            end
            bulletTracerConn = nil
        end
    end
    local autoShotConn = nil
    local function startAutoShot()
        if autoShotConn then return end
        local WeaponService
        pcall(function() WeaponService = require(ReplicatedStorage.ClientServices.WeaponService) end)
        autoShotConn = RunService.Heartbeat:Connect(function()
            if tick() - (getgenv()._autoShotLastTime or 0) < _G.AmiSettings.AutoShotCooldown then return end
            local char = LocalPlayer.Character
            if not char then return end
            local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or char:FindFirstChild("Pistol")
            if not gun then return end
            local murderer
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    if pl.Character:FindFirstChild("Knife") or (pl.Backpack and pl.Backpack:FindFirstChild("Knife")) then
                        murderer = pl
                        break
                    end
                end
            end
            if not murderer or not murderer.Character then return end
            local myHead = char:FindFirstChild("Head")
            local origin = myHead and myHead.Position or workspace.CurrentCamera.CFrame.Position
            local targetPart = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
            if not targetPart then return end
            local targetPos = targetPart.Position
            local direction = (targetPos - origin)
            local distance = direction.Magnitude
            if distance < 0.5 then return end 
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {char, murderer.Character}
            local ray = workspace:Raycast(origin, direction.Unit * distance, rayParams)
            if ray then return end 
            local gunOrigin = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun") or char.HumanoidRootPart
            local shoot = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
            if shoot then
                local aimCF = CFrame.lookAt(gunOrigin.Position, targetPos)
                pcall(function() shoot:FireServer(aimCF, CFrame.new(targetPos)) end)
                pcall(function() shoot:FireServer(aimCF) end)
                getgenv()._autoShotLastTime = tick()
            end
        end)
    end
    local function stopAutoShot()
        if autoShotConn then autoShotConn:Disconnect(); autoShotConn = nil end
        getgenv()._autoShotLastTime = nil
    end
    local spinbotConn = nil
    local function startSpinbot()
        if spinbotConn then return end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = false end   
        end
        spinbotConn = RunService.Heartbeat:Connect(function(delta)  
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local speed = _G.AmiSettings.SpinbotSpeed
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed * delta), 0)
        end)
    end
    local function stopSpinbot()
        if spinbotConn then spinbotConn:Disconnect(); spinbotConn = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end    
        end
    end
    local function stopSpinbot()
        if spinbotConn then spinbotConn:Disconnect(); spinbotConn = nil end
    end
    local bhopConn = nil
    local bhopJumping = false
    local function startBunnyHop()
        if bhopConn then return end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = _G.AmiSettings.BunnyHopSpeed end
        bhopConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if humanoid.WalkSpeed ~= _G.AmiSettings.BunnyHopSpeed then
                humanoid.WalkSpeed = _G.AmiSettings.BunnyHopSpeed
            end
            if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air and not bhopJumping then
                bhopJumping = true
                humanoid.Jump = true
                task.delay(0.05, function() bhopJumping = false end)
            end
        end)
    end
    local function stopBunnyHop()
        if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end 
    end
    local function createMobileSilentButton()
        if mobileShootBtn then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "SilentAimMobileBtn"
        gui.Parent = LocalPlayer.PlayerGui
        gui.ResetOnSpawn = false
        local btn = Instance.new("TextButton")
        btn.Name = "ShootButton"
        btn.Size = UDim2.fromOffset(80, 80)
        btn.Position = UDim2.new(1, -100, 0.5, -40)
        btn.BackgroundColor3 = Color3.fromRGB(220,40,40)
        btn.Text = "Shot\nmurder"
        btn.Font = Enum.Font.SourceSansBold
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 14
        btn.TextWrapped = true
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2,0)
        btn.Parent = gui
        btn.MouseButton1Click:Connect(function() ShotMurder() end)
        mobileShootBtn = gui
    end
    local function removeMobileSilentButton()
        if mobileShootBtn then
            mobileShootBtn:Destroy()
            mobileShootBtn = nil
        end
    end
    local mobileShotBtn = nil
    local mobileKnifeBtn = nil
    local function createStyledButton(name, position, color, text, callback)
        local gui = Instance.new("ScreenGui")
        gui.Name = name
        gui.Parent = LocalPlayer.PlayerGui
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local btn = Instance.new("TextButton")
        btn.Name = "Button"
        btn.Size = UDim2.new(0, 70, 0, 70)
        btn.Position = position
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.3
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 14
        btn.TextWrapped = true
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = gui
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 20)
        local gradient = Instance.new("UIGradient", btn)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color:Lerp(Color3.new(1,1,1), 0.3)),
            ColorSequenceKeypoint.new(1, color)
        })
        gradient.Rotation = 45
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = color:Lerp(Color3.new(1,1,1), 0.5)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.2
        local originalSize = btn.Size
        btn.MouseButton1Click:Connect(function()
            callback()
            btn.Size = originalSize - UDim2.new(0,4,0,4)
            task.wait(0.05)
            btn.Size = originalSize
        end)
        return gui
    end
    function createMobileShotButton()
        if mobileShotBtn then return end
        mobileShotBtn = createStyledButton(
            "MobileShotBtn",
            UDim2.new(0, 20, 0.5, -35),   
            Color3.fromRGB(255, 80, 80),
            "🔫\nShot",
            function() ShotMurder() end
        )
    end
    function removeMobileShotButton()
        if mobileShotBtn then mobileShotBtn:Destroy(); mobileShotBtn = nil end
    end
    function createMobileKnifeButton()
        if mobileKnifeBtn then return end
        mobileKnifeBtn = createStyledButton(
            "MobileKnifeBtn",
            UDim2.new(0, 20, 0.5, -130),  
            Color3.fromRGB(80, 180, 255),
            "🔪\nThrow",
            function() ThrowKnife() end
        )
    end
    function removeMobileKnifeButton()
        if mobileKnifeBtn then mobileKnifeBtn:Destroy(); mobileKnifeBtn = nil end
    end
    local function setSpectate(v)
        spectateEnabled = v
        if not v then
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
    local function spectatePlayer(name)
        if not spectateEnabled then
            return
        end
        if not name or name == "" then
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            return
        end
        local pl = Players:FindFirstChild(name)
        if pl and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = pl.Character:FindFirstChildOfClass("Humanoid")
        else
        end
    end
    local function setRoundTimer(v)
        _G.AmiSettings.RoundTimer = v
        if v then
            if timerLabel then timerLabel:Destroy() end
            timerLabel = Instance.new("TextLabel")
            timerLabel.Parent = CoreGui
            timerLabel.BackgroundTransparency = 1
            timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
            timerLabel.TextScaled = true
            timerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            timerLabel.Position = UDim2.fromScale(0.5, 0.15)
            timerLabel.Size = UDim2.fromOffset(200, 50)
            timerLabel.Font = Enum.Font.GothamBold
            timerLabel.Text = "Round Timer: --"
            if timerTask then task.cancel(timerTask) end
            timerTask = task.spawn(function()
                while _G.AmiSettings.RoundTimer do
                    pcall(function()
                        local timerRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Extras") and ReplicatedStorage.Remotes.Extras:FindFirstChild("GetTimer")
                        if timerRemote then
                            local timeLeft = timerRemote:InvokeServer()
                            if timeLeft and timeLeft ~= -1 then
                                local minutes = math.floor(timeLeft / 60)
                                local seconds = timeLeft % 60
                                timerLabel.Text = string.format("Round Timer: %02d:%02d", minutes, seconds)
                            else
                                timerLabel.Text = "Round Timer: --"
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            if timerLabel then timerLabel:Destroy(); timerLabel = nil end
            if timerTask then task.cancel(timerTask); timerTask = nil end
        end
    end
    local Window = YusufExe:CreateWindow({
        Title = "Yusuf.exe",
        SubTitle = "",
        ToggleKey = Enum.KeyCode.LeftControl,
    })
    local SETTINGS_FILE = "Yusuf.exe_Settings.json"
    function saveSettings()
        if not writefile then return end
        local data = {}
        for k,v in pairs(_G.AmiSettings) do
            local t = type(v)
            if t == "string" or t == "number" or t == "boolean" then data[k] = v
            elseif t == "userdata" and typeof(v) == "Color3" then data[k] = {v.R, v.G, v.B} end
        end
        data.SelectedAnimeTheme = _G.AmiSettings.SelectedAnimeTheme or "Reze"
        writefile(SETTINGS_FILE, HttpService:JSONEncode(data))
    end
    function loadSettings()
        if not readfile or not isfile or not isfile(SETTINGS_FILE) then return false end
        local json = readfile(SETTINGS_FILE)
        local data = HttpService:JSONDecode(json)
        for k,v in pairs(data) do
            if type(v) == "table" and #v == 3 then
                _G.AmiSettings[k] = Color3.new(v[1], v[2], v[3])
            else
                _G.AmiSettings[k] = v
            end
        end
        _G.AmiSettings.SelectedAnimeTheme = data.SelectedAnimeTheme or "Reze"
        return true
    end
    local Tabs = {}
    Tabs.Home      = Window:CreateTab({ Name = "Home",      Icon = "rbxassetid://13060262582" })
    Tabs.Visuals   = Window:CreateTab({ Name = "Visuals",   Icon = "rbxassetid://103289157776464" })
    Tabs.Combat    = Window:CreateTab({ Name = "Combat",    Icon = "rbxassetid://14193513201" })
    Tabs.Player    = Window:CreateTab({ Name = "Player",    Icon = "rbxassetid://2795572803" })
    Tabs.Farm      = Window:CreateTab({ Name = "Farm",      Icon = "rbxassetid://104735818831489" })
    Tabs.Emotes    = Window:CreateTab({ Name = "Emotes",    Icon = "rbxassetid://99183002748390" })
    Tabs.Teleport  = Window:CreateTab({ Name = "Teleport",  Icon = "rbxassetid://6723742959" })
    Tabs.Misc      = Window:CreateTab({ Name = "Misc",      Icon = "rbxassetid://76297601380246" })
    Tabs.Spawner   = Window:CreateTab({ Name = "Spawner",   Icon = "rbxassetid://76297601380246" })
    Tabs.Sky       = Window:CreateTab({ Name = "Sky's",     Icon = "rbxassetid://103526434512095" })
    Tabs.Settings  = Window:CreateTab({ Name = "Settings",  Icon = "rbxassetid://16717281585" })
    Tabs.Home:CreateSection("Protection")
    Tabs.Home:CreateToggle({
        Name = "Anti-Fling",
        Default = false,
        Callback = function(v)
            _G.AmiSettings.AntiFlingEnabled = v
            setAntiFling(v)
            pcall(saveSettings)
        end
    })
    Tabs.Home:CreateSection("Dropkick & Run")
    Tabs.Home:CreateToggle({
        Name = "Dropkick Enable",
        Default = false,
        Callback = function(v)
            _G.AmiSettings.DropkickEnabled = v
            DropkickAPI.setDropkickEnabled(v)
            pcall(saveSettings)
        end
    })
    Tabs.Home:CreateToggle({
        Name = "Run Enable",
        Default = false,
        Callback = function(v)
            _G.AmiSettings.RunEnabled = v
            DropkickAPI.setRunEnabled(v)
            pcall(saveSettings)
        end
    })
    Tabs.Home:CreateSlider({
        Name = "Dropkick Power",
        Min = 0, Max = 1000, Default = 50, Rounding = 0,
        Callback = function(v)
            _G.AmiSettings.DropkickPower = v
            pcall(saveSettings)
        end
    })
    Tabs.Home:CreateButton({
        Name = "Activate Dropkick (K)",
        Callback = function() DropkickAPI.activateDropkick() end
    })
    Tabs.Home:CreateSlider({
        Name = "Run Speed %",
        Min = 0, Max = 500, Default = 20, Rounding = 0,
        Callback = function(v)
            _G.AmiSettings.RunSpeedPercent = v
            if DropkickAPI.isRunActive() then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = math.max(0.5, 16 * (v / 100)) end
            end
            pcall(saveSettings)
        end
    })
    Tabs.Home:CreateButton({
        Name = "Toggle Run (J)",
        Callback = function() DropkickAPI.toggleRun() end
    })
    Tabs.Visuals:CreateSection("Esp and etc")
    Tabs.Visuals:CreateToggle({
        Name = "Enable ESP",
        Default = false,
        Callback = function(v) _G.AmiSettings.EspEnabled = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateToggle({
        Name = "Show Guns",
        Default = false,
        Callback = function(v) _G.AmiSettings.GunEspEnabled = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateToggle({
        Name = "Show Names",
        Default = false,
        Callback = function(v) _G.AmiSettings.NamesESP = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateToggle({
        Name = "Show Traps",
        Default = false,
        Callback = function(v) _G.AmiSettings.TrapESP = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateSection("Target Indicator")
    Tabs.Visuals:CreateToggle({
        Name = "Show Indicator",
        Default = false,
        Callback = function(v) _G.AmiSettings.IndicatorEnabled = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateSection("Bullet Tracer")
    Tabs.Visuals:CreateToggle({
        Name = "Enable Bullet Tracer",
        Default = _G.AmiSettings.BulletTracerEnabled or false,
        Callback = function(v)
            _G.AmiSettings.BulletTracerEnabled = v
            if v then
                startBulletTracer()
            else
                stopBulletTracer()
            end
            pcall(saveSettings)
        end
    })
    Tabs.Visuals:CreateColorPicker({
        Name = "Tracer Color",
        Default = _G.AmiSettings.BulletTracerColor or Color3.fromRGB(255, 220, 100),
        Callback = function(color)
            _G.AmiSettings.BulletTracerColor = color
            pcall(saveSettings)
        end
    })
    Tabs.Visuals:CreateSlider({
        Name = "Tracer Transparency",
        Min = 0, Max = 1, Default = _G.AmiSettings.BulletTracerTransparency or 0.15, Decimals = 2,
        Callback = function(v)
            _G.AmiSettings.BulletTracerTransparency = v
            pcall(saveSettings)
        end
    })
    Tabs.Visuals:CreateSlider({
        Name = "Tracer Lifetime",
        Min = 0.05, Max = 3, Default = _G.AmiSettings.BulletTracerLifetime or 0.25, Decimals = 2,
        Callback = function(v)
            _G.AmiSettings.BulletTracerLifetime = v
            pcall(saveSettings)
        end
    })
    Tabs.Visuals:CreateSection("Camera")
    Tabs.Visuals:CreateSlider({
        Name = "FOV",
        Min = 30, Max = 120, Default = 70, Rounding = 0,
        Callback = function(v) _G.AmiSettings.FOVValue = v; Camera.FieldOfView = v; pcall(saveSettings) end
    })
    Tabs.Visuals:CreateToggle({
        Name = "X-Ray",
        Default = false,
        Callback = function(v) setXray(v); pcall(saveSettings) end
    })
    Tabs.Visuals:CreateSection("Visual Mods")
    Tabs.Visuals:CreateToggle({
        Name = "FPS Boost",
        Default = false,
        Callback = function(v) setImproveFPS(v); pcall(saveSettings) end
    })
    Tabs.Combat:CreateSection("Murderer (Knife)")
    Tabs.Combat:CreateButton({ Name = "Kill All", Callback = killAll })
    Tabs.Combat:CreateToggle({
        Name = "Knife Aura",
        Default = false,
        Callback = function(v) setKnifeAura(v); pcall(saveSettings) end
    })
    Tabs.Combat:CreateSlider({
        Name = "Aura Range",
        Min = 5, Max = 100, Default = 20, Rounding = 0,
        Callback = function(v) _G.AmiSettings.KnifeAuraRange = v; pcall(saveSettings) end
    })
    Tabs.Combat:CreateButton({ Name = "Godmode", Callback = activateGodmode })
    Tabs.Combat:CreateSection("Manual Actions")
    Tabs.Combat:CreateButton({ Name = "Throw Knife (with prediction)", Callback = ThrowKnife })
    Tabs.Combat:CreateButton({ Name = "Shot Murder (with prediction)", Callback = ShotMurder })
    Tabs.Combat:CreateSection("Silent Aim (Auto)")
    Tabs.Combat:CreateToggle({
        Name = "Silent Aim (Knife) for high unc exploits",
        Default = _G.AmiSettings.SilentAimKnife or false,
        Callback = function(v)
            if v and not executorStrong then
                Notify("Weak Executor", "Silent Aim requires strong executor", 3)
                _G.AmiSettings.SilentAimKnife = false
                return
            end
            _G.AmiSettings.SilentAimKnife = v
            pcall(saveSettings)
        end
    })
    Tabs.Combat:CreateToggle({
        Name = "Silent Aim (Gun) for high unc exploits",
        Default = _G.AmiSettings.SilentAimGun or false,
        Callback = function(v)
            if v and not executorStrong then
                Notify("Weak Executor", "Silent Aim requires strong executor", 3)
                _G.AmiSettings.SilentAimGun = false
                return
            end
            _G.AmiSettings.SilentAimGun = v
            pcall(saveSettings)
        end
    })
    Tabs.Combat:CreateSection("Manual Actions (Toggle)")
    Tabs.Combat:CreateToggle({
        Name = "Shot Murder (PRESS E)",
        Default = _G.AmiSettings.ShotMurderEnabled or false,
        Callback = function(v) _G.AmiSettings.ShotMurderEnabled = v; pcall(saveSettings) end
    })
    Tabs.Combat:CreateToggle({
        Name = "Shot Murder (Mobile Button)",
        Default = _G.AmiSettings.ShotMurderMobile or false,
        Callback = function(v) _G.AmiSettings.ShotMurderMobile = v; if v then createMobileShotButton() else removeMobileShotButton() end; pcall(saveSettings) end
    })
    Tabs.Combat:CreateToggle({
        Name = "Throw Knife (PRESS R)",
        Default = false,
        Callback = function(v) _G.AmiSettings.ThrowKnifeEnabled = v; pcall(saveSettings) end
    })
    Tabs.Combat:CreateToggle({
        Name = "Throw Knife (Mobile Button)",
        Default = false,
        Callback = function(v) _G.AmiSettings.KnifeMobileEnabled = v; if v then createMobileKnifeButton() else removeMobileKnifeButton() end; pcall(saveSettings) end
    })
    Tabs.Combat:CreateSection("Auto Shot")
    Tabs.Combat:CreateToggle({
        Name = "Enable Auto Shot",
        Default = _G.AmiSettings.AutoShotEnabled or false,
        Callback = function(v)
            _G.AmiSettings.AutoShotEnabled = v
            if v then startAutoShot() else stopAutoShot() end
            pcall(saveSettings)
        end
    })
    Tabs.Combat:CreateSlider({
        Name = "Shot Cooldown",
        Min = 0.1, Max = 2.0, Default = _G.AmiSettings.AutoShotCooldown or 0.5, Decimals = 1,
        Callback = function(v)
            _G.AmiSettings.AutoShotCooldown = v
            pcall(saveSettings)
        end
    })
    Tabs.Combat:CreateSection("Bomb Jump (coming soon)")
    Tabs.Player:CreateSection("Movement")
    Tabs.Player:CreateSlider({
        Name = "Walk Speed",
        Min = 16, Max = 200, Default = 16, Rounding = 0,
        Callback = function(v) _G.AmiSettings.WalkSpeed = v; applyMovement(); pcall(saveSettings) end
    })
    Tabs.Player:CreateSlider({
        Name = "Jump Power",
        Min = 50, Max = 300, Default = 50, Rounding = 0,
        Callback = function(v) _G.AmiSettings.JumpPower = v; applyMovement(); pcall(saveSettings) end
    })
    Tabs.Player:CreateToggle({
        Name = "Speed Glitch",
        Default = false,
        Callback = function(v) _G.AmiSettings.SpeedGlitchEnabled = v; pcall(saveSettings) end
    })
    Tabs.Player:CreateSlider({
        Name = "Glitch Speed",
        Min = 16, Max = 300, Default = 35, Rounding = 0,
        Callback = function(v) _G.AmiSettings.GlitchSpeed = v; pcall(saveSettings) end
    })
    Tabs.Player:CreateSection("Fly & Noclip")
    Tabs.Player:CreateToggle({
        Name = "Fly",
        Default = false,
        Callback = function(v) setFly(v); pcall(saveSettings) end
    })
    Tabs.Player:CreateSlider({
        Name = "Fly Speed",
        Min = 10, Max = 200, Default = 50, Rounding = 0,
        Callback = function(v) _G.AmiSettings.FlySpeed = v; pcall(saveSettings) end
    })
    Tabs.Player:CreateToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(v) setNoclip(v); pcall(saveSettings) end
    })
    Tabs.Player:CreateSection("Spinbot")
    Tabs.Player:CreateToggle({
        Name = "Enable Spinbot",
        Default = _G.AmiSettings.SpinbotEnabled or false,
        Callback = function(v)
            _G.AmiSettings.SpinbotEnabled = v
            if v then startSpinbot() else stopSpinbot() end
            pcall(saveSettings)
        end
    })
    Tabs.Player:CreateSlider({
        Name = "Spin Speed (°/s)",
        Min = 0, Max = 720, Default = _G.AmiSettings.SpinbotSpeed or 180, Rounding = 0,
        Callback = function(v)
            _G.AmiSettings.SpinbotSpeed = v
            pcall(saveSettings)
        end
    })
    Tabs.Player:CreateSection("BunnyHop")
    Tabs.Player:CreateToggle({
        Name = "Enable BunnyHop",
        Default = _G.AmiSettings.BunnyHopEnabled or false,
        Callback = function(v)
            _G.AmiSettings.BunnyHopEnabled = v
            if v then startBunnyHop() else stopBunnyHop() end
            pcall(saveSettings)
        end
    })
    Tabs.Player:CreateSlider({
        Name = "BHop Speed",
        Min = 16, Max = 200, Default = _G.AmiSettings.BunnyHopSpeed or 24, Rounding = 0,
        Callback = function(v)
            _G.AmiSettings.BunnyHopSpeed = v
            pcall(saveSettings)
        end
    })
    Tabs.Player:CreateSection("Fling")
    local flingDropdown = Tabs.Player:CreateDropdown({
        Name = "Target",
        Options = getPlayersNames(),
        Default = "",
        Multi = false
    })
    Tabs.Player:CreateButton({
        Name = "Refresh Players",
        Callback = function()
            local names = getPlayersNames()
            flingDropdown:SetOptions(names)
            flingDropdown:SetValue("")
        end
    })
    Tabs.Player:CreateButton({
        Name = "Fling Selected",
        Callback = function()
            local name = flingDropdown.Value
            if not name or name == "" then return end
            local pl = Players:FindFirstChild(name)
            if pl then SkidFling(pl) end
        end
    })
    Tabs.Player:CreateButton({
        Name = "Fling Murderer",
        Callback = function()
            local murd = findPlayerByRole("Murderer")
            if murd then SkidFling(murd) end
        end
    })
    Tabs.Player:CreateButton({
        Name = "Fling Sheriff",
        Callback = function()
            local sher = findPlayerByRole("Sheriff")
            if sher then SkidFling(sher) end
        end
    })
    Tabs.Player:CreateButton({
        Name = "Stop Fling",
        Callback = function() FlingActive = false end
    })
    Tabs.Player:CreateToggle({
        Name = "Touch Fling",
        Default = false,
        Callback = function(v) _G.AmiSettings.ExtremeFlingEnabled = v; toggleExtremeFling(v); pcall(saveSettings) end
    })
    Tabs.Player:CreateSection("Extra")
    Tabs.Player:CreateToggle({
        Name = "Enable Spectate",
        Default = false,
        Callback = function(v) setSpectate(v); pcall(saveSettings) end
    })
    local spectateDropdown = Tabs.Player:CreateDropdown({
        Name = "Spectate Player",
        Options = getPlayersNames(),
        Default = "",
        Multi = false,
        Callback = function(v) spectatePlayer(v) end
    })
    Tabs.Player:CreateButton({
        Name = "Refresh Spectate List",
        Callback = function()
            local names = getPlayersNames()
            spectateDropdown:SetOptions(names)
            spectateDropdown:SetValue("")
        end
    })
    Tabs.Player:CreateButton({
        Name = "Send Roles to Chat",
        Callback = sendRoleNames
    })
    Tabs.Farm:CreateSection("Coin Farm")
    Tabs.Farm:CreateToggle({
        Name = "Enable Coin Farm",
        Default = false,
        Callback = function(v) _G.toggleCoinFarm(v) end
    })
    Tabs.Farm:CreateSlider({
        Name = "Farm Speed",
        Min = 1, Max = 30, Default = 25, Rounding = 0,
        Callback = function(v) _G.AmiSettings.CoinFarmSpeed = v; pcall(saveSettings) end
    })
    Tabs.Farm:CreateSlider({
        Name = "Search Radius",
        Min = 50, Max = 500, Default = 200, Rounding = 0,
        Callback = function(v) _G.AmiSettings.CoinFarmRadius = v; pcall(saveSettings) end
    })
    Tabs.Farm:CreateSlider({
        Name = "Max Coins Before Reset",
        Min = 10, Max = 100, Default = 40, Rounding = 0,
        Callback = function(v) _G.AmiSettings.MaxCoinsPerRound = v; pcall(saveSettings) end
    })
    Tabs.Farm:CreateToggle({
        Name = "Auto Fling Murderer on Reset",
        Default = false,
        Callback = function(v) _G.AmiSettings.AutoFlingMurderer = v; pcall(saveSettings) end
    })
    Tabs.Farm:CreateButton({
        Name = "Fling Murderer Now",
        Callback = function()
            local murderer = findMurdererForFarm() or findPlayerByRole("Murderer")
            if murderer then
                FlingActive = true
                task.spawn(function() SkidFling(murderer); FlingActive = false end)
            end
        end
    })
    Tabs.Emotes:CreateSection("Emotes")
    Tabs.Emotes:CreateButton({ Name = "Sit", Callback = function() playEmote("sit") end })
    Tabs.Emotes:CreateButton({ Name = "Zen", Callback = function() playEmote("zen") end })
    Tabs.Emotes:CreateButton({ Name = "Dab", Callback = function() playEmote("dab") end })
    Tabs.Emotes:CreateButton({ Name = "Floss", Callback = function() playEmote("floss") end })
    Tabs.Emotes:CreateButton({ Name = "Zombie", Callback = function() playEmote("zombie") end })
    Tabs.Emotes:CreateButton({ Name = "Headless", Callback = function() playEmote("headless") end })
    Tabs.Teleport:CreateSection("Teleports")
    Tabs.Teleport:CreateButton({ Name = "To Spawn", Callback = teleportToSpawn })
    Tabs.Teleport:CreateButton({
        Name = "To Murderer",
        Callback = function()
            local murd = findPlayerByRole("Murderer")
            if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = murd.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
        end
    })
    Tabs.Teleport:CreateButton({
        Name = "To Sheriff",
        Callback = function()
            local sher = findPlayerByRole("Sheriff")
            if sher and sher.Character and sher.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = sher.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
        end
    })
    Tabs.Misc:CreateSection("Grab Gun")
    Tabs.Misc:CreateToggle({
        Name = "Auto Grab Gun",
        Default = false,
        Callback = function(v) _G.AmiSettings.AutoGrabEnabled = v; pcall(saveSettings) end
    })
    Tabs.Misc:CreateKeybind({
        Name = "Manual Grab",
        Default = "G",
        Callback = function()
            local found = false
            for gd,_ in pairs(gunDropCache) do if gd and gd.Parent then found = true; break end end
            if not found then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for gd,_ in pairs(gunDropCache) do
                    if gd and gd.Parent then
                        gd:PivotTo(root.CFrame)
                        local ti = gd:FindFirstChild("TouchInterest", true) or gd:FindFirstChildWhichIsA("TouchTransmitter", true)
                        if ti then
                            firetouchinterest(root, gd, 0)
                            task.wait()
                            firetouchinterest(root, gd, 1)
                        end
                        break
                    end
                end
            end
        end
    })
    Tabs.Misc:CreateSection("Additional Protections")
    Tabs.Misc:CreateToggle({
        Name = "Anti-Lock (prevents camera lock)",
        Default = false,
        Callback = function(v) _G.AmiSettings.AntiLock = v; pcall(saveSettings) end
    })
    Tabs.Misc:CreateToggle({
        Name = "Anti-Kick (client-side)",
        Default = false,
        Callback = function(v) _G.AmiSettings.AntiKick = v; pcall(saveSettings) end
    })
    Tabs.Misc:CreateSection("Notifications")
    Tabs.Misc:CreateToggle({
        Name = "Show Role on Start",
        Default = false,
        Callback = function(v) _G.AmiSettings.SayRoleEnabled = v; pcall(saveSettings) end
    })
    Tabs.Misc:CreateSection("Anti-AFK")
    Tabs.Misc:CreateToggle({
        Name = "Anti AFK",
        Default = true,
        Callback = function(v) setAntiAfk(v); pcall(saveSettings) end
    })
    Tabs.Misc:CreateSection("Utilities")
    Tabs.Misc:CreateButton({ Name = "Rejoin", Callback = rejoin })
    Tabs.Misc:CreateButton({ Name = "Respawn", Callback = respawn })
    local function setupSpawnerTab()
        local container = Tabs.Spawner.Container
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("TextBox") or child:IsA("UIListLayout") then
                child:Destroy()
            end
        end
        if not Sync or not GiveItem then return end
        local weaponsData = Sync.Item
        if not weaponsData then return end
        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 30)
        searchBox.Position = UDim2.new(0, 0, 0, 0)
        searchBox.BackgroundColor3 = Color3.fromRGB(40,40,60)
        searchBox.PlaceholderText = "Search weapon..."
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextColor3 = Color3.fromRGB(255,255,255)
        searchBox.ClearTextOnFocus = false
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,6)
        searchBox.Parent = container
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, -40)
        scroll.Position = UDim2.new(0, 0, 0, 36)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 4
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = container
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0,2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = scroll
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0,4)
        padding.PaddingRight = UDim.new(0,4)
        padding.Parent = scroll
        local weapons = {}
        for key, data in pairs(weaponsData) do
            if type(data) == "table" and (data.ItemType == "Knife" or data.ItemType == "Gun") then
                table.insert(weapons, {
                    key = key,
                    name = data.ItemName or key,
                    rarity = data.Rarity or "Common",
                })
            end
        end
        local rarityOrder = {Chroma=1,Godly=2,Ancient=3,Unique=4,Legendary=5,Classic=6,Vintage=7,Rare=8,Uncommon=9,Common=10}
        table.sort(weapons, function(a,b) return (rarityOrder[a.rarity] or 99) < (rarityOrder[b.rarity] or 99) end)
        local rarityColor = {
            Chroma = Color3.fromRGB(170,70,220), Godly = Color3.fromRGB(255,180,50),
            Ancient = Color3.fromRGB(180,80,200), Unique = Color3.fromRGB(255,100,150),
            Legendary = Color3.fromRGB(255,140,0), Classic = Color3.fromRGB(100,200,255),
            Vintage = Color3.fromRGB(200,180,100), Rare = Color3.fromRGB(60,120,255),
            Uncommon = Color3.fromRGB(60,200,120), Common = Color3.fromRGB(200,200,200),
        }
        local allButtons = {}
        local function filter(searchText)
            local q = string.lower(searchText or "")
            for _, info in ipairs(allButtons) do
                if q == "" then info.button.Visible = true
                else
                    local hay = string.lower(info.name .. " " .. info.rarity)
                    info.button.Visible = string.find(hay, q, 1, true) ~= nil
                end
            end
        end
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            filter(searchBox.Text)
        end)
        for _, w in ipairs(weapons) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
            btn.BackgroundTransparency = 0.2
            btn.Text = "  " .. w.name .. "  (" .. w.rarity .. ")"
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            btn.Parent = scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(50,50,80)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
            end)
            btn.MouseButton1Click:Connect(function()
                GiveItem(w.key, 1, "Weapons")
                btn.BackgroundColor3 = Color3.fromRGB(0,150,100)
                task.wait(0.1)
                btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
            end)
            table.insert(allButtons, {button = btn, name = w.name, rarity = w.rarity})
        end
    end
    setupSpawnerTab()
    Tabs.Sky:CreateSection("Skybox")
    Tabs.Sky:CreateToggle({
        Name = "Enable Skybox",
        Default = false,
        Callback = function(v)
            _G.AmiSettings.SkyEnabled = v
            if v then applySkybox(_G.AmiSettings.SelectedSky) else clearSkybox() end
            pcall(saveSettings)
        end
    })
    Tabs.Sky:CreateDropdown({
        Name = "Select Sky",
        Options = skyboxNames,
        Default = "Sunset",
        Callback = function(v)
            _G.AmiSettings.SelectedSky = v
            if _G.AmiSettings.SkyEnabled then applySkybox(v) end
            pcall(saveSettings)
        end
    })
    Tabs.Sky:CreateSection("Fog")
    Tabs.Sky:CreateToggle({
        Name = "Enable Fog",
        Default = false,
        Callback = function(v) _G.AmiSettings.FogEnabled = v; applyFog(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Fog Start",
        Min = 0, Max = 1000, Default = 0, Rounding = 0,
        Callback = function(v) _G.AmiSettings.FogStart = v; if _G.AmiSettings.FogEnabled then applyFog() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Fog End",
        Min = 0, Max = 10000, Default = 1000, Rounding = 0,
        Callback = function(v) _G.AmiSettings.FogEnd = v; if _G.AmiSettings.FogEnabled then applyFog() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateColorPicker({
        Name = "Fog Color",
        Default = Color3.fromRGB(80, 120, 200),
        Callback = function(color) _G.AmiSettings.FogColor = color; if _G.AmiSettings.FogEnabled then applyFog() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSection("Color Correction")
    Tabs.Sky:CreateToggle({
        Name = "Enable Color Correction",
        Default = false,
        Callback = function(v) _G.AmiSettings.ColorCorrectionEnabled = v; applyColorCorrection(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Brightness",
        Min = -100, Max = 100, Default = 0, Rounding = 0,
        Callback = function(v) _G.AmiSettings.CCBrightness = v; if _G.AmiSettings.ColorCorrectionEnabled then applyColorCorrection() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Contrast",
        Min = -100, Max = 100, Default = 0, Rounding = 0,
        Callback = function(v) _G.AmiSettings.CCContrast = v; if _G.AmiSettings.ColorCorrectionEnabled then applyColorCorrection() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Saturation",
        Min = -100, Max = 100, Default = 0, Rounding = 0,
        Callback = function(v) _G.AmiSettings.CCSaturation = v; if _G.AmiSettings.ColorCorrectionEnabled then applyColorCorrection() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSection("Lighting")
    Tabs.Sky:CreateSlider({
        Name = "Brightness",
        Min = 0, Max = 10, Default = 0, Rounding = 0.1,
        Callback = function(v) _G.AmiSettings.Brightness = v; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Clock Time",
        Min = 0, Max = 24, Default = 0, Rounding = 0.5,
        Callback = function(v) _G.AmiSettings.ClockTime = v; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateColorPicker({
        Name = "Ambient Color",
        Default = Color3.fromRGB(0,0,0),
        Callback = function(color) _G.AmiSettings.AmbientColor = color; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateColorPicker({
        Name = "Outdoor Ambient",
        Default = Color3.fromRGB(80, 120, 200),
        Callback = function(color) _G.AmiSettings.OutdoorAmbient = color; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateSlider({
        Name = "Exposure",
        Min = -5, Max = 5, Default = 0, Rounding = 0.1,
        Callback = function(v) _G.AmiSettings.Exposure = v; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateToggle({
        Name = "Global Shadows",
        Default = false,
        Callback = function(v) _G.AmiSettings.GlobalShadows = v; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateDropdown({
        Name = "Technology",
        Options = {"Legacy", "Voxel", "ShadowMap", "Future"},
        Default = "Legacy",
        Callback = function(v) _G.AmiSettings.Technology = v; applyLighting(); pcall(saveSettings) end
    })
    Tabs.Sky:CreateSection("Snow Effect")
    Tabs.Sky:CreateToggle({
        Name = "Enable Snow",
        Default = false,
        Callback = function(v) _G.AmiSettings.SnowEnabled = v; if v then createSnowEffect() else removeSnowEffect() end; pcall(saveSettings) end
    })
    Tabs.Sky:CreateSection("RTX Shaders")
    Tabs.Sky:CreateToggle({
        Name = "RTX Shaders",
        Default = false,
        Callback = function(v)
            _G.AmiSettings.RTXShaders = v
            if v then
                pcall(function()
                    local bloom = Instance.new("BloomEffect", Lighting)
                    bloom.Name = "RTX_Bloom"
                    bloom.Intensity = 0.1
                    bloom.Size = 100
                    local cc = Instance.new("ColorCorrectionEffect", Lighting)
                    cc.Name = "RTX_CC"
                    cc.Saturation = 0.05
                    cc.TintColor = Color3.fromRGB(255,224,219)
                    local sun = Instance.new("SunRaysEffect", Lighting)
                    sun.Name = "RTX_SunRays"
                    sun.Intensity = 0.05
                    Lighting.Brightness = 2.14
                    Lighting.ColorShift_Bottom = Color3.fromRGB(11,0,20)
                    Lighting.ColorShift_Top = Color3.fromRGB(240,127,14)
                    Lighting.OutdoorAmbient = Color3.fromRGB(34,0,49)
                    Lighting.ClockTime = 6.7
                end)
            else
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child.Name:find("RTX") then child:Destroy() end
                end
                Lighting.Brightness = 2
                Lighting.ColorShift_Bottom = Color3.new(0,0,0)
                Lighting.ColorShift_Top = Color3.new(0,0,0)
                Lighting.OutdoorAmbient = Color3.fromRGB(157,157,157)
                Lighting.ClockTime = 14
            end
            pcall(saveSettings)
        end
    })
    Tabs.Settings:CreateSection("Advanced Silent Aim")
    Tabs.Settings:CreateDropdown({
        Name = "Knife Prediction Type",
        Options = {"Traject", "Vectora", "Dartix"},
        Default = _G.AmiSettings.PredictKnifeType or "Traject",
        Callback = function(v) _G.AmiSettings.PredictKnifeType = v; saveSettings() end
    })
    Tabs.Settings:CreateDropdown({
        Name = "Gun Prediction Type",
        Options = {"Vazex", "Phaze", "Hexa", "Nova"},
        Default = _G.AmiSettings.PredictGunType or "Vazex",
        Callback = function(v) _G.AmiSettings.PredictGunType = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Head Prediction",
        Default = _G.AmiSettings.HeadPrediction or false,
        Callback = function(v) _G.AmiSettings.HeadPrediction = v; saveSettings() end
    })
    Tabs.Settings:CreateSlider({
        Name = "Head Hit Chance (%)",
        Min = 0, Max = 100, Default = _G.AmiSettings.HeadHitChance or 50, Rounding = 0,
        Callback = function(v) _G.AmiSettings.HeadHitChance = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Ping Compensation",
        Default = _G.AmiSettings.PingBased or false,
        Callback = function(v) _G.AmiSettings.PingBased = v; saveSettings() end
    })
    Tabs.Settings:CreateDropdown({
        Name = "Ping Type",
        Options = {"Server", "Client", "Adaptive"},
        Default = _G.AmiSettings.PingType or "Server",
        Callback = function(v) _G.AmiSettings.PingType = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Resolver Assistant",
        Default = _G.AmiSettings.ResolverAssistant or false,
        Callback = function(v) _G.AmiSettings.ResolverAssistant = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Wall Check",
        Default = _G.AmiSettings.SilentAimWallCheck or false,
        Callback = function(v) _G.AmiSettings.SilentAimWallCheck = v; saveSettings() end
    })
    Tabs.Settings:CreateDropdown({
        Name = "Throw Speed",
        Options = {"Normal", "Fast", "Instant"},
        Default = _G.AmiSettings.SilentAimThrowSpeed or "Normal",
        Callback = function(v) _G.AmiSettings.SilentAimThrowSpeed = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Instant Shoot",
        Default = _G.AmiSettings.SilentAimInstantShoot or false,
        Callback = function(v) _G.AmiSettings.SilentAimInstantShoot = v; saveSettings() end
    })
    Tabs.Settings:CreateToggle({
        Name = "Show FPS/Ping/Time",
        Default = true,
        Callback = function(v)
            toggleStandaloneStats(v)
            pcall(saveSettings)
        end
    })
    task.spawn(function()
        while true do
            pcall(function()
                detectRoles()
                applyMovement()
                local mr = getMyRole()
                for gd,_ in pairs(gunDropCache) do
                    if gd and gd.Parent then
                        if _G.AmiSettings.AutoGrabEnabled and mr ~= "Murderer" and mr ~= "Sheriff" then
                            local char = LocalPlayer.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            if root then
                                gd:PivotTo(root.CFrame)
                                local ti = gd:FindFirstChild("TouchInterest", true) or gd:FindFirstChildWhichIsA("TouchTransmitter", true)
                                if ti then
                                    firetouchinterest(root, gd, 0)
                                    task.wait()
                                    firetouchinterest(root, gd, 1)
                                end
                            end
                        end
                        if _G.AmiSettings.GunEspEnabled then
                            local hl = gd:FindFirstChild("GunDropHighlight") or Instance.new("Highlight", gd)
                            hl.Name = "GunDropHighlight"
                            hl.FillColor = _G.AmiColors.GunFill
                            hl.FillTransparency = _G.AmiColors.GunFillTrans
                            hl.OutlineColor = Color3.fromRGB(255,255,255)
                            hl.OutlineTransparency = 0
                        else
                            local hl = gd:FindFirstChild("GunDropHighlight")
                            if hl then hl:Destroy() end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if _G.AmiSettings.ShotMurderEnabled and input.KeyCode == Enum.KeyCode.E then
            ShotMurder()
        end
        if _G.AmiSettings.ThrowKnifeEnabled and input.KeyCode == Enum.KeyCode.R then
            ThrowKnife()
        end
    end)
    if hookmetamethod then
        local NamecallHook
        NamecallHook = hookmetamethod(game, "__namecall", function(self, ...)
            local args = { ... }
            local method = getnamecallmethod()
            if not checkcaller() then
                if self.Name == "KnifeThrown" and method == "FireServer" and _G.AmiSettings.SilentAimKnife then
                    local char = LocalPlayer.Character
                    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local targets = {}
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                                table.insert(targets, pl)
                            end
                        end
                        if #targets > 0 then
                            local nearest, nearestDist = nil, math.huge
                            for _, t in ipairs(targets) do
                                local Root = t.Character.HumanoidRootPart
                                local dist = (rootPart.Position - Root.Position).Magnitude
                                if dist < nearestDist then nearest = t; nearestDist = dist end
                            end
                            if nearest then
                                local AimPos = PredictKnife(nearest.Character)
                                if AimPos then
                                    args[1] = CFrame.new(rootPart.Position)
                                    args[2] = CFrame.new(AimPos)
                                end
                            end
                        end
                    end
                end
                if self.Name == "Shoot" and method == "FireServer" and _G.AmiSettings.SilentAimGun then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Gun") then
                        local targets = {}
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl ~= LocalPlayer and pl.Character and (pl.Backpack:FindFirstChild("Knife") or pl.Character:FindFirstChild("Knife")) then
                                table.insert(targets, pl)
                            end
                        end
                        if #targets > 0 then
                            local nearest, nearestDist = nil, math.huge
                            for _, t in ipairs(targets) do
                                local Root = t.Character.HumanoidRootPart
                                local dist = (char.HumanoidRootPart.Position - Root.Position).Magnitude
                                if dist < nearestDist then nearest = t; nearestDist = dist end
                            end
                            if nearest then
                                local AimPos = PredictGun(nearest.Character)
                                if AimPos then
                                    args[1] = CFrame.new(char.RightHand.Position)
                                    args[2] = CFrame.new(AimPos)
                                end
                            end
                        end
                    end
                end
            end
            return NamecallHook(self, unpack(args))
        end)
    end
    pcall(loadSettings)
    if _G.AmiSettings.FlyEnabled then pcall(setFly, true) end
    if _G.AmiSettings.NoclipEnabled then pcall(setNoclip, true) end
    if _G.AmiSettings.AntiAfkEnabled then pcall(setAntiAfk, true) end
    if _G.AmiSettings.ImproveFPS then pcall(setImproveFPS, true) end
    if _G.AmiSettings.XrayEnabled then pcall(setXray, true) end
    if _G.AmiSettings.AntiFlingEnabled then pcall(setAntiFling, true) end
    if _G.AmiSettings.DropkickEnabled then pcall(DropkickAPI.setDropkickEnabled, true) end
    if _G.AmiSettings.RunEnabled then pcall(DropkickAPI.setRunEnabled, true) end
    if _G.AmiSettings.SpinbotEnabled then pcall(startSpinbot) end
    if _G.AmiSettings.BunnyHopEnabled then pcall(startBunnyHop) end
    pcall(applyAllAtmosphere)
    Notify("Yusuf.exe", "Loaded! Features ready.", 3)
    Window:SelectTab(Tabs.Home)
