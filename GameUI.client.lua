--------------------------------------------------------------------------------
-- SURVIVE EVENTS FOR BRAINROTS — Full UI System
-- HOW TO INSTALL:
--   1. In Roblox Studio, open StarterGui.
--   2. Insert a LocalScript, name it "GameUI".
--   3. Paste this entire file into it. Press Play.
-- Everything is client-side mock data — wire RemoteEvents where marked TODO.
--------------------------------------------------------------------------------
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

---------------------------------------------------------------- theme
local function hex(h) return Color3.fromRGB(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)) end
local C = {
  page=hex("0E1118"), panel=hex("171B26"), inner=hex("1D2230"), card=hex("232938"),
  border=hex("2A3044"), cardBorder=hex("333C55"), hoverBorder=hex("4A5678"),
  txt=Color3.new(1,1,1), dim=hex("9AA3B8"), muted=hex("5E6880"), soft=hex("C6CDDD"),
  greenTxt=hex("B4F470"), blueTxt=hex("7FBAF5"), goldTxt=hex("F5C64A"),
  purpleTxt=hex("C989F7"), redTxt=hex("FF8A78"), tealTxt=hex("5AD6A0"),
}
local P = { -- chunky palettes {L=light,B=base,D=dark}
  green={L=hex("7FD435"),B=hex("63B91F"),D=hex("2E5E10")},
  greenHdr={L=hex("66CE36"),B=hex("4CB322"),D=hex("1D5A0E")},
  blue={L=hex("4E9BEC"),B=hex("2F7BD6"),D=hex("16457E")},
  purple={L=hex("B564F2"),B=hex("8B34D6"),D=hex("45117A")},
  purpleHdr={L=hex("AE58F0"),B=hex("8B34D6"),D=hex("45117A")},
  gold={L=hex("F0B93A"),B=hex("DD9615"),D=hex("7A4E08")},
  red={L=hex("F2543E"),B=hex("D5341F"),D=hex("6E140C")},
  redHdr={L=hex("F2543E"),B=hex("C92C18"),D=hex("6E140C")},
  teal={L=hex("38B889"),B=hex("1F8A5B"),D=hex("0C4A30")},
  orange={L=hex("F2843E"),B=hex("D96420"),D=hex("7A3208")},
  dark={L=hex("2A3142"),B=hex("232938"),D=hex("333C55")},
}
local RARITY = { Legendary=hex("F5C64A"), Epic=hex("C989F7"), Rare=hex("7FBAF5"), Uncommon=hex("8CDC3E"), Common=hex("9AA3B8") }
local FONT = Enum.Font.FredokaOne   -- closest built-in to Lilita One
local FB = Enum.Font.GothamBlack    -- 900 weight
local F8 = Enum.Font.GothamBold     -- 800 weight

---------------------------------------------------------------- tiny builders
local function mk(class, props, parent)
  local o = Instance.new(class)
  for k,v in pairs(props) do o[k] = v end
  o.Parent = parent
  return o
end
local function corner(o,r) mk("UICorner",{CornerRadius=UDim.new(0,r)},o) end
local function stroke(o,c,w) return mk("UIStroke",{Color=c,Thickness=w or 1.5},o) end
local function grad(o,a,b) mk("UIGradient",{Rotation=90,Color=ColorSequence.new(a,b)},o) end
local function padAll(o,t,r,b,l)
  mk("UIPadding",{PaddingTop=UDim.new(0,t),PaddingRight=UDim.new(0,r or t),PaddingBottom=UDim.new(0,b or t),PaddingLeft=UDim.new(0,l or r or t)},o)
end
local function vlist(o,gap,center)
  return mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,
    HorizontalAlignment=center and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left},o)
end
local function hlist(o,gap,vcenter)
  return mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,
    VerticalAlignment=vcenter and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top},o)
end
local function ugrid(o,w,hh,gap)
  return mk("UIGridLayout",{CellSize=UDim2.new(0,w,0,hh),CellPadding=UDim2.new(0,gap,0,gap),SortOrder=Enum.SortOrder.LayoutOrder},o)
end
local function frame(parent,size,pos,color,r,borderC,borderW)
  local f = mk("Frame",{Size=size,Position=pos or UDim2.new(),BackgroundColor3=color or C.card,BorderSizePixel=0},parent)
  if r then corner(f,r) end
  if borderC then stroke(f,borderC,borderW or 1.5) end
  return f
end
local function txt(parent,s,size,color,font,props)
  local t = mk("TextLabel",{Text=s,TextSize=size,TextColor3=color or C.txt,Font=font or FB,
    BackgroundTransparency=1,Size=UDim2.new(0,0,0,size+4),AutomaticSize=Enum.AutomaticSize.X},parent)
  for k,v in pairs(props or {}) do t[k]=v end
  return t
end
local function chip(parent,s,color,bgAlpha)
  local f = mk("Frame",{BackgroundColor3=color,BackgroundTransparency=bgAlpha or .86,AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.new()},parent)
  corner(f,6); local st=stroke(f,color,1); st.Transparency=.45
  local t = txt(f,s,11,color,FB); t.AutomaticSize=Enum.AutomaticSize.XY; t.Size=UDim2.new()
  padAll(f,3,9,3,9)
  return f
end
local function hoverize(btn, target, prop, base, hover)
  btn.MouseEnter:Connect(function() TS:Create(target,TweenInfo.new(.12),{[prop]=hover}):Play() end)
  btn.MouseLeave:Connect(function() TS:Create(target,TweenInfo.new(.12),{[prop]=base}):Play() end)
end

-- chunky 3D button: gradient top + dark lip, press sinks, hover brightens
local function chunky(parent, size, pal, textStr, textSize, onClick)
  local holder = mk("Frame",{Size=size,BackgroundTransparency=1},parent)
  local lip = frame(holder,UDim2.new(1,0,1,-3),UDim2.new(0,0,0,3),pal.D,9)
  local top = mk("TextButton",{Size=UDim2.new(1,0,1,-3),BackgroundColor3=pal.B,Text="",AutoButtonColor=false,BorderSizePixel=0},holder)
  corner(top,9); stroke(top,pal.D,1.5); grad(top,pal.L,pal.B)
  local shine = frame(top,UDim2.new(1,-6,0,2),UDim2.new(0,3,0,2),Color3.new(1,1,1),2)
  shine.BackgroundTransparency = .65
  local lbl = txt(top,textStr,textSize or 14,C.txt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.new(),TextXAlignment=Enum.TextXAlignment.Center})
  local hov = frame(top,UDim2.new(1,0,1,0),nil,Color3.new(1,1,1),9); hov.BackgroundTransparency=1; hov.ZIndex=top.ZIndex+2
  hoverize(top,hov,"BackgroundTransparency",1,.92)
  top.MouseButton1Down:Connect(function() top.Position=UDim2.new(0,0,0,3); lip.Visible=false end)
  local function up() top.Position=UDim2.new(0,0,0,0); lip.Visible=true end
  top.MouseButton1Up:Connect(up); top.MouseLeave:Connect(up)
  if onClick then top.MouseButton1Click:Connect(onClick) end
  return holder, top, lbl
end

-- toggle switch (ON/OFF)
local function toggle(parent, state, onChange)
  local holder = mk("TextButton",{Size=UDim2.new(0,72,0,34),Text="",AutoButtonColor=false,BackgroundColor3=P.dark.B,BorderSizePixel=0},parent)
  corner(holder,9); local st = stroke(holder,hex("3A4152"),1.5)
  local g = mk("UIGradient",{Rotation=90,Color=ColorSequence.new(hex("39415A"),hex("2C3346"))},holder)
  local lbl = txt(holder,"OFF",11,hex("8B94AA"),FB,{Position=UDim2.new(0,34,.5,-8)})
  local knob = frame(holder,UDim2.new(0,25,0,24),UDim2.new(0,4,0,4),Color3.new(1,1,1),6,Color3.new(0,0,0),1.5)
  grad(knob,Color3.new(1,1,1),hex("D9DEE8"))
  local val = state
  local function render(animate)
    local ti = animate and TweenInfo.new(.15) or TweenInfo.new(0)
    TS:Create(knob,ti,{Position=val and UDim2.new(0,43,0,4) or UDim2.new(0,4,0,4)}):Play()
    g.Color = val and ColorSequence.new(P.green.L,P.green.B) or ColorSequence.new(hex("39415A"),hex("2C3346"))
    st.Color = val and P.green.D or hex("3A4152")
    lbl.Text = val and "ON" or "OFF"
    lbl.TextColor3 = val and hex("1D4A0A") or hex("8B94AA")
    lbl.Position = val and UDim2.new(0,10,.5,-8) or UDim2.new(0,36,.5,-8)
  end
  render(false)
  holder.MouseButton1Click:Connect(function()
    val = not val; render(true)
    if onChange then onChange(val) end
  end)
  return holder
end

-- draggable slider (0-100, steps of 5)
local function slider(parent, width, pct, onChange)
  local holder = mk("TextButton",{Size=UDim2.new(width and 0 or 1,width or 0,0,14),Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(8,10,15),BorderSizePixel=0},parent)
  holder.BackgroundTransparency=.35; corner(holder,7); stroke(holder,Color3.new(1,1,1),1).Transparency=.92
  local fill = frame(holder,UDim2.new(pct/100,-4,1,-4),UDim2.new(0,2,0,2),P.green.B,5)
  grad(fill,hex("8CDC3E"),P.green.B)
  local knob = frame(holder,UDim2.new(0,24,0,24),UDim2.new(pct/100,-12,.5,-12),P.green.L,7,P.green.D,1.5)
  grad(knob,hex("A9EC66"),P.green.L); knob.ZIndex=2
  local val, dragging = pct, false
  local function setFromX(x)
    local rel = math.clamp((x-holder.AbsolutePosition.X)/holder.AbsoluteSize.X,0,1)
    val = math.floor(rel*20+.5)*5
    fill.Size = UDim2.new(val/100,-4,1,-4)
    knob.Position = UDim2.new(val/100,-12,.5,-12)
    if onChange then onChange(val) end
  end
  holder.MouseButton1Down:Connect(function() dragging=true; setFromX(UIS:GetMouseLocation().X) end)
  UIS.InputEnded:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  UIS.InputChanged:Connect(function(io)
    if dragging and io.UserInputType==Enum.UserInputType.MouseMovement then setFromX(io.Position.X) end
  end)
  return holder, function() return val end
end

---------------------------------------------------------------- root
local gui = mk("ScreenGui",{Name="GameUI",ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild("PlayerGui"))

-- centered stage that scales down on small screens
local stage = mk("Frame",{Name="Stage",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,40,.5,0),Size=UDim2.new(0,1240,0,760),BackgroundTransparency=1},gui)
local uiscale = mk("UIScale",{},stage)
local cam = workspace.CurrentCamera
local function rescale()
  local vw = cam.ViewportSize.X
  uiscale.Scale = math.clamp((vw-200)/1400,.55,1)
end
rescale(); cam:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)

---------------------------------------------------------------- toasts
local toastHolder = mk("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-118),Size=UDim2.new(0,290,0,300),BackgroundTransparency=1},gui)
local tl = vlist(toastHolder,8); tl.VerticalAlignment=Enum.VerticalAlignment.Bottom
local TOASTC = { reward=hex("8CDC3E"), info=hex("4E9BEC"), warn=hex("F0B93A") }
local function toast(kind, title, sub)
  local tc = TOASTC[kind] or TOASTC.info
  local f = frame(toastHolder,UDim2.new(1,0,0,58),nil,hex("0D1018"),11,C.cardBorder)
  local bar = frame(f,UDim2.new(0,3,1,-8),UDim2.new(0,0,0,4),tc,2)
  local well = frame(f,UDim2.new(0,32,0,32),UDim2.new(0,11,.5,-16),tc,8); well.BackgroundTransparency=.85
  txt(well,"◆",14,tc,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
  txt(f,title,13,C.txt,FB,{Position=UDim2.new(0,52,0,11)})
  txt(f,sub,11,C.dim,F8,{Position=UDim2.new(0,52,0,30)})
  task.delay(4,function() if f.Parent then f:Destroy() end end)
end

---------------------------------------------------------------- panel shell + registry
local Panels = {}          -- name -> frame
local currentPanel = nil
local function openPanel(name)
  if currentPanel and Panels[currentPanel] then Panels[currentPanel].Visible = false end
  currentPanel = (currentPanel == name) and nil or name
  if currentPanel and Panels[currentPanel] then Panels[currentPanel].Visible = true end
  if gui:FindFirstChild("HudBar") then
    for _,b in ipairs(gui.HudBar:GetChildren()) do
      if b:IsA("Frame") and b:FindFirstChild("Sel") then b.Sel.Visible = (b.Name == "hud_"..tostring(currentPanel)) end
    end
  end
end
-- panel: dark rounded shell with colored header, title, chips, X
local function panel(name, w, h, title, hdrPal, hdrChip)
  local root = frame(stage,UDim2.new(0,w,0,h),UDim2.new(.5,-w/2,0,0),C.panel,14,C.border,2)
  root.Visible = false; root.Name = name
  local ring = stroke(root,hex("0A0D14"),3); ring.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  local hdr = frame(root,UDim2.new(1,0,0,64),nil,hdrPal.B,12)
  grad(hdr,hdrPal.L,hdrPal.B)
  local hb = frame(hdr,UDim2.new(1,0,0,3),UDim2.new(0,0,1,-3),Color3.new(0,0,0)); hb.BackgroundTransparency=.65
  local squareBottom = frame(hdr,UDim2.new(1,0,0,14),UDim2.new(0,0,1,-14),hdrPal.B); grad(squareBottom,hdrPal.B,hdrPal.B)
  local t = txt(hdr,title,30,C.txt,FONT,{Position=UDim2.new(0,24,0,14)})
  stroke(t,hdrPal.D,2.5).ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
  if hdrChip then
    local ch = frame(hdr,UDim2.new(0,0,0,26),UDim2.new(0,t.AbsoluteSize.X+220,0,19),Color3.new(0,0,0),8)
    ch.BackgroundTransparency=.65; ch.AutomaticSize=Enum.AutomaticSize.X
    stroke(ch,Color3.new(1,1,1),1).Transparency=.8
    local ct = txt(ch,hdrChip,12,C.txt,FB); ct.AutomaticSize=Enum.AutomaticSize.XY; ct.Size=UDim2.new(); padAll(ch,4,12,4,12)
    ch.Position = UDim2.new(0,24 + t.TextBounds.X + 16,0,19)
  end
  local x = chunky(hdr,UDim2.new(0,40,0,43),P.red,"X",18,function() openPanel(name) end)
  x.AnchorPoint = Vector2.new(1,0); x.Position = UDim2.new(1,-12,0,10)
  local body = mk("Frame",{Size=UDim2.new(1,0,1,-64),Position=UDim2.new(0,0,0,64),BackgroundTransparency=1},root)
  Panels[name] = root
  return root, body, hdr
end

---------------------------------------------------------------- shared bits
local function sectionTitle(parent, s, accentColor)
  local row = mk("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},parent)
  frame(row,UDim2.new(0,5,0,19),UDim2.new(0,0,0,1),accentColor,2)
  txt(row,s,17,C.txt,FB,{Position=UDim2.new(0,15,0,0)})
  return row
end
local function robuxTag(parent, price)
  local f = frame(parent,UDim2.new(0,0,0,20),nil,Color3.new(0,0,0),6); f.BackgroundTransparency=.72; f.AutomaticSize=Enum.AutomaticSize.X
  local t = txt(f,"⬡ "..price,12,C.txt,FB); t.AutomaticSize=Enum.AutomaticSize.XY; t.Size=UDim2.new(); padAll(f,2,8,2,8)
  return f
end
local function goldBuyBtn(parent, size, labelStr, price, purchaseName)
  local h = chunky(parent,size,P.gold,"",13,function()
    _G.ShowPurchase(purchaseName or labelStr, price, true)
  end)
  local top = h:FindFirstChildOfClass("TextButton")
  local row = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},top)
  local rl = hlist(row,7,true); rl.HorizontalAlignment=Enum.HorizontalAlignment.Center
  txt(row,labelStr,12,C.txt,FB)
  robuxTag(row,price)
  return h
end
local function searchBox(parent, w, placeholder)
  local f = frame(parent,UDim2.new(0,w,0,36),nil,Color3.fromRGB(10,12,18),10,Color3.new(1,1,1),1)
  f.BackgroundTransparency=.3; f:FindFirstChildOfClass("UIStroke").Transparency=.9
  local box = mk("TextBox",{Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,
    PlaceholderText=placeholder,PlaceholderColor3=C.muted,Text="",TextColor3=C.txt,Font=F8,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},f)
  return f, box
end
local function itemCard(parent, name, rarityName, sub, price)
  local rc = RARITY[rarityName] or C.dim
  local card = frame(parent,UDim2.new(0,0,0,0),nil,C.card,10,C.cardBorder)
  local topbar = frame(card,UDim2.new(1,0,0,3),nil,rc,2)
  local cl = vlist(card,5,true); padAll(card,10,10,10,10)
  txt(card,name,12,C.txt,FB,{TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,16),AutomaticSize=Enum.AutomaticSize.None,TextXAlignment=Enum.TextXAlignment.Center})
  local well = frame(card,UDim2.new(1,0,0,58),nil,Color3.fromRGB(10,12,18),8); well.BackgroundTransparency=.4
  txt(well,"☻",26,rc,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
  local meta = mk("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1},card)
  txt(meta,rarityName,11,rc,FB)
  if sub then txt(meta,sub,11,C.greenTxt,FB,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0)}) end
  if price then
    local b = chunky(card,UDim2.new(0,86,0,28),P.green,"$ "..price,12,function() _G.ShowPurchase(name, price, false) end)
  end
  local hs = card:FindFirstChildOfClass("UIStroke")
  card.MouseEnter:Connect(function() hs.Color=C.hoverBorder end)
  card.MouseLeave:Connect(function() hs.Color=C.cardBorder end)
  return card
end

---------------------------------------------------------------- HUD bar (left)
local hudDefs = {
  {"shop","Shop",P.green},{"rebirth","Rebirth",P.purple},{"index","Index",P.blue},{"quests","Quests",P.gold},
  {"events","Events",P.orange},{"trade","Trade",P.teal},{"codes","Codes",P.gold},{"map","Map Vote",P.blue},
  {"inventory","Inventory",P.teal},{"rewards","Rewards",P.gold},{"spin","Spin",P.blue},{"pass","Pass",P.teal},
  {"lucky","Lucky Block",P.purple},{"results","Results",P.greenHdr},{"settings","Settings",P.dark},{"admin","Admin",P.redHdr},
}
local hudBar = mk("Frame",{Name="HudBar",Position=UDim2.new(0,16,0,90),Size=UDim2.new(0,160,0,660),BackgroundTransparency=1},gui)
ugrid(hudBar,76,72,8)
for _,d in ipairs(hudDefs) do
  local id, lbl, pal = d[1], d[2], d[3]
  local b = frame(hudBar,UDim2.new(),nil,C.inner,12,C.border)
  b.Name = "hud_"..id
  local sel = frame(b,UDim2.new(1,0,1,0),nil,pal.B,12); sel.Name="Sel"; sel.Visible=false
  grad(sel,pal.L,pal.B); stroke(sel,pal.D,1.5)
  local ic = txt(b,"■",22,C.txt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,12),ZIndex=3,TextXAlignment=Enum.TextXAlignment.Center})
  local tt = txt(b,lbl,10,hex("B8C0D4"),FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,42),ZIndex=3,TextXAlignment=Enum.TextXAlignment.Center})
  local click = mk("TextButton",{Size=UDim2.new(1,0,1,0),Text="",BackgroundTransparency=1,ZIndex=4},b)
  local hs = b:FindFirstChildOfClass("UIStroke")
  click.MouseEnter:Connect(function() hs.Color=C.hoverBorder end)
  click.MouseLeave:Connect(function() hs.Color=C.border end)
  click.MouseButton1Click:Connect(function() openPanel(id) end)
end

---------------------------------------------------------------- HUD: event bar, leaderboard, vitals, currency, starter
-- active event (top center)
local evbar = frame(gui,UDim2.new(0,360,0,62),UDim2.new(.5,-180,0,14),hex("0D1018"),12,C.cardBorder)
local evwell = frame(evbar,UDim2.new(0,38,0,38),UDim2.new(0,12,0,12),hex("F2543E"),9); evwell.BackgroundTransparency=.86
stroke(evwell,hex("F2543E"),1).Transparency=.55
txt(evwell,"⚡",16,C.redTxt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
txt(evbar,"METEOR SHOWER",13,C.txt,FB,{Position=UDim2.new(0,62,0,10)})
local evchip = chip(evbar,"ACTIVE EVENT",C.redTxt); evchip.Position=UDim2.new(0,185,0,8)
local evtrack = frame(evbar,UDim2.new(0,190,0,9),UDim2.new(0,62,0,36),Color3.fromRGB(8,10,15),5)
local evfill = frame(evtrack,UDim2.new(.35,0,1,0),nil,hex("F2543E"),5); grad(evfill,hex("F2543E"),hex("C92C18"))
txt(evbar,"Ends in 0:42",11,C.dim,FB,{Position=UDim2.new(0,262,0,32)})

-- leaderboard (top right)
local lb = frame(gui,UDim2.new(0,252,0,250),UDim2.new(1,-268,0,14),hex("0D1018"),12,C.cardBorder)
local lbh = frame(lb,UDim2.new(1,0,0,36),nil,Color3.new(1,1,1),12); lbh.BackgroundTransparency=.96
txt(lbh,"PLAYERS",12,C.txt,FB,{Position=UDim2.new(0,14,0,10)})
local lbc = chip(lbh,"7 / 12",C.dim,.72); lbc.Position=UDim2.new(0,95,0,7)
local lbList = mk("Frame",{Size=UDim2.new(1,-12,1,-64),Position=UDim2.new(0,6,0,58),BackgroundTransparency=1},lb)
vlist(lbList,2)
txt(lb,"NAME              CASH        RB",10,C.muted,FB,{Position=UDim2.new(0,14,0,40)})
local lbData = {{"TralaleroMain","$2.1M","12",true},{"EventSurvivor99","$890K","8"},{"xX_BrainrotFan_Xx","$540K","6"},{"SigmaGrinder","$310K","5"},{"You","$125K","3",false,true},{"NoobSlayer_2013","$88K","2"},{"casualplayer55","$12K","0"}}
for _,r in ipairs(lbData) do
  local row = mk("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},lbList)
  if r[5] then row.BackgroundTransparency=.9; row.BackgroundColor3=hex("8CDC3E"); corner(row,7); stroke(row,hex("8CDC3E"),1).Transparency=.65 end
  txt(row,(r[4] and "♛ " or "")..r[1],11,r[5] and C.greenTxt or C.soft,FB,{Position=UDim2.new(0,8,0,5),TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(0,130,0,14),AutomaticSize=Enum.AutomaticSize.None})
  txt(row,r[2],11,C.greenTxt,FB,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-40,0,5)})
  txt(row,r[3],11,C.purpleTxt,FB,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,5)})
end

-- vitals (bottom center): health + level/xp with + button
local vit = mk("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-16),Size=UDim2.new(0,660,0,44),BackgroundTransparency=1},gui)
hlist(vit,8,true)
local hp = frame(vit,UDim2.new(0,270,0,42),nil,hex("0D1018"),12,C.cardBorder)
txt(hp,"♥",16,hex("F2543E"),FB,{Position=UDim2.new(0,12,0,11)})
local hpTrack = frame(hp,UDim2.new(0,150,0,16),UDim2.new(0,36,0,13),Color3.fromRGB(8,10,15),8)
local hpFill = frame(hpTrack,UDim2.new(.85,-4,1,-4),UDim2.new(0,2,0,2),P.green.B,5); grad(hpFill,hex("8CDC3E"),P.green.B)
txt(hp,"85/100",13,C.txt,FB,{Position=UDim2.new(0,196,0,12)})
local xp = frame(vit,UDim2.new(0,382,0,42),nil,hex("0D1018"),12,C.cardBorder)
local lvl = frame(xp,UDim2.new(0,54,0,22),UDim2.new(0,10,0,10),P.blue.B,7,P.blue.D,1); grad(lvl,P.blue.L,P.blue.B)
txt(lvl,"LVL 12",11,C.txt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
local xpTrack = frame(xp,UDim2.new(0,130,0,14),UDim2.new(0,72,0,14),Color3.fromRGB(8,10,15),7)
local xpFill = frame(xpTrack,UDim2.new(.45,-4,1,-4),UDim2.new(0,2,0,2),P.blue.B,4); grad(xpFill,P.blue.L,P.blue.B)
txt(xp,"4,500 / 10,000 XP",11,C.dim,FB,{Position=UDim2.new(0,210,0,14)})
local xpPlus = chunky(xp,UDim2.new(0,26,0,28),P.blue,"+",15,function() openPanel("xpshop") end)
xpPlus.AnchorPoint=Vector2.new(1,0); xpPlus.Position=UDim2.new(1,-8,0,7)

-- currency (bottom right): money+players
local cur = mk("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,170,0,86),BackgroundTransparency=1},gui)
local cl2 = vlist(cur,8); cl2.HorizontalAlignment=Enum.HorizontalAlignment.Right
local money = frame(cur,UDim2.new(0,168,0,38),nil,hex("0D1018"),10,C.cardBorder)
txt(money,"$125,430",13,C.greenTxt,FB,{Position=UDim2.new(0,13,0,10)})
local moneyPlus = chunky(money,UDim2.new(0,26,0,28),P.green,"+",15,function() openPanel("cashshop") end)
moneyPlus.AnchorPoint=Vector2.new(1,0); moneyPlus.Position=UDim2.new(1,-5,0,5)
local plc = frame(cur,UDim2.new(0,96,0,38),nil,hex("0D1018"),10,C.cardBorder)
txt(plc,"👤 7/12",13,C.txt,FB,{Position=UDim2.new(0,13,0,10)})

-- starter offer pill (top left)
local sp = mk("TextButton",{Position=UDim2.new(0,16,0,14),Size=UDim2.new(0,196,0,52),Text="",AutoButtonColor=false,BackgroundColor3=hex("0D1018"),BorderSizePixel=0},gui)
corner(sp,12); stroke(sp,hex("EFAF2A"),1.5).Transparency=.35
txt(sp,"🎁",18,C.goldTxt,FB,{Position=UDim2.new(0,12,0,15)})
txt(sp,"STARTER PACK",12,C.goldTxt,FB,{Position=UDim2.new(0,44,0,9)})
txt(sp,"-80% · ENDS IN 23:59:59",10,C.redTxt,FB,{Position=UDim2.new(0,44,0,29)})
sp.MouseButton1Click:Connect(function() _G.OpenStarter() end)

---------------------------------------------------------------- SHOP
do
  local root, body = panel("shop",1240,690,"SHOP",P.greenHdr)
  -- header cash chip with +
  local hc = frame(root,UDim2.new(0,150,0,38),UDim2.new(1,-215,0,13),Color3.new(0,0,0),10)
  hc.BackgroundTransparency=.6; hc.ZIndex=5; stroke(hc,Color3.new(1,1,1),1.5).Transparency=.82
  txt(hc,"$125,430",15,C.greenTxt,FB,{Position=UDim2.new(0,13,0,9),ZIndex=6})
  local hcp = chunky(hc,UDim2.new(0,30,0,30),P.green,"+",16,function() openPanel("cashshop") end)
  hcp.AnchorPoint=Vector2.new(1,0); hcp.Position=UDim2.new(1,-4,0,4); hcp.ZIndex=6

  padAll(body,14,20,20,20)
  local tabsRow = mk("Frame",{Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},body)
  hlist(tabsRow,10)
  local content = mk("Frame",{Size=UDim2.new(1,0,1,-96),Position=UDim2.new(0,0,0,60),BackgroundTransparency=1},body)
  local tabPages, tabBtns = {}, {}
  local tabDefs = {{"featured","Featured",P.green},{"boosts","Boosts",P.blue},{"brainrots","Brainrots",P.purple},{"gamepasses","Gamepasses",P.gold}}
  local function selectTab(id)
    for tid,pg in pairs(tabPages) do pg.Visible = (tid==id) end
    for tid,btn in pairs(tabBtns) do
      local top = btn:FindFirstChildOfClass("TextButton")
      local pal = nil
      for _,td in ipairs(tabDefs) do if td[1]==tid then pal=td[3] end end
      local on = (tid==id)
      top.BackgroundColor3 = on and pal.B or C.inner
      top:FindFirstChildOfClass("UIGradient").Color = on and ColorSequence.new(pal.L,pal.B) or ColorSequence.new(C.inner,C.inner)
      top:FindFirstChildOfClass("UIStroke").Color = on and pal.D or C.border
      top:FindFirstChildOfClass("TextLabel").TextColor3 = on and C.txt or hex("8B94AA")
    end
  end
  for _,td in ipairs(tabDefs) do
    local id,lbl,pal = td[1],td[2],td[3]
    local b = chunky(tabsRow,UDim2.new(0,290,0,48),pal,lbl,15,function() selectTab(id) end)
    tabBtns[id] = b
    local pg = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},content)
    tabPages[id] = pg
  end

  -- FEATURED page
  do
    local pg = tabPages.featured
    local left = mk("Frame",{Size=UDim2.new(1,-346,1,0),BackgroundTransparency=1},pg); vlist(left,14)
    local featured = frame(left,UDim2.new(1,0,0,258),nil,C.inner,12,C.border); padAll(featured,16,18,16,18)
    sectionTitle(featured,"FEATURED ITEMS",hex("8CDC3E")).Position=UDim2.new(0,0,0,0)
    local fRow = mk("Frame",{Size=UDim2.new(1,0,0,190),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},featured)
    hlist(fRow,14)
    for _,it in ipairs({{"Diamond Nyan Cat","LIMITED!","499",C.redTxt},{"Meme Crate","HOT!","199",hex("FFAD7E")},{"Lucky Spin","NEW!","99",C.greenTxt}}) do
      local card = frame(fRow,UDim2.new(0,270,1,0),nil,C.card,10,C.cardBorder); padAll(card,12,12,12,12)
      local bc = chip(card,it[2],it[4]); bc.Position=UDim2.new(0,0,0,0)
      txt(card,it[1],15,C.txt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,28),TextXAlignment=Enum.TextXAlignment.Center})
      local well = frame(card,UDim2.new(1,0,0,76),UDim2.new(0,0,0,52),Color3.fromRGB(10,12,18),8); well.BackgroundTransparency=.4
      txt(well,"◆",30,it[4],FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
      local buy = goldBuyBtn(card,UDim2.new(0,120,0,32),"Buy",it[3],it[1]); buy.AnchorPoint=Vector2.new(.5,1); buy.Position=UDim2.new(.5,0,1,0)
    end
    local best = frame(left,UDim2.new(1,0,0,236),nil,C.inner,12,C.border); padAll(best,16,18,16,18)
    sectionTitle(best,"BEST VALUE",hex("EFAF2A"))
    local bRow = mk("Frame",{Size=UDim2.new(1,0,0,160),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},best)
    hlist(bRow,12)
    for _,pk in ipairs({{"Starter Pack","$50,000","199"},{"Popular Pack","$250,000","799"},{"Pro Pack","$1,000,000","2,499"},{"Mega Pack","$5,000,000","9,999"},{"Ultra Pack","$25,000,000","39,999"}}) do
      local card = frame(bRow,UDim2.new(0,158,1,0),nil,C.card,10,C.cardBorder); padAll(card,10,8,10,8)
      txt(card,pk[1],13,C.txt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,2),TextXAlignment=Enum.TextXAlignment.Center})
      local well = frame(card,UDim2.new(1,0,0,44),UDim2.new(0,0,0,26),Color3.fromRGB(10,12,18),8); well.BackgroundTransparency=.4
      txt(well,"$",20,C.goldTxt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
      txt(card,pk[2],14,C.greenTxt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,78),TextXAlignment=Enum.TextXAlignment.Center})
      local buy = goldBuyBtn(card,UDim2.new(0,116,0,30),"Buy",pk[3],pk[1].." ("..pk[2]..")"); buy.AnchorPoint=Vector2.new(.5,1); buy.Position=UDim2.new(.5,0,1,0)
    end
    -- daily deals column
    local deals = frame(pg,UDim2.new(0,330,0,508),UDim2.new(1,-330,0,0),C.inner,12,C.border); padAll(deals,16,16,16,16)
    sectionTitle(deals,"DAILY DEALS",hex("F2843E"))
    local resets = chip(deals,"⏱ Resets in 4h 32m",C.goldTxt,.72); resets.Position=UDim2.new(0,0,0,32)
    local dcol = mk("Frame",{Size=UDim2.new(1,0,0,240),Position=UDim2.new(0,0,0,66),BackgroundTransparency=1},deals); vlist(dcol,10)
    for _,dd in ipairs({{"Cash Bundle (Small)","$5,000","49"},{"XP Boost (30 Min)","2x XP","29"},{"Lucky Boost (15 Min)","2x Luck","39"}}) do
      local row = frame(dcol,UDim2.new(1,0,0,64),nil,C.card,10,C.cardBorder); padAll(row,10,12,10,12)
      txt(row,dd[1],13,C.txt,FB,{Position=UDim2.new(0,0,0,6)})
      txt(row,dd[2],12,C.greenTxt,F8,{Position=UDim2.new(0,0,0,26)})
      local buy = goldBuyBtn(row,UDim2.new(0,84,0,30),"",dd[3],dd[1]); buy.AnchorPoint=Vector2.new(1,.5); buy.Position=UDim2.new(1,0,.5,0)
    end
    local hint = frame(deals,UDim2.new(1,0,0,58),UDim2.new(0,0,1,-58),C.inner,10)
    stroke(hint,C.cardBorder,1.5)
    txt(hint,"New deals every day!",13,C.dim,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,10),TextXAlignment=Enum.TextXAlignment.Center})
    txt(hint,"Come back after the reset.",11,C.muted,F8,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,32),TextXAlignment=Enum.TextXAlignment.Center})
  end

  -- BOOSTS page
  do
    local pg = tabPages.boosts
    local wrap = frame(pg,UDim2.new(1,0,0,508),nil,C.inner,12,C.border); padAll(wrap,16,18,16,18)
    sectionTitle(wrap,"BOOSTS",hex("3D8DE8"))
    txt(wrap,"Power up your progress with temporary boosts!",12,C.dim,F8,{Position=UDim2.new(0,180,0,3)})
    local bgrid = mk("Frame",{Size=UDim2.new(1,0,0,400),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},wrap)
    ugrid(bgrid,282,190,12)
    for _,dur in ipairs({"15 Min","1 Hour"}) do
      for _,bd in ipairs({{"2x Cash Boost","Earn 2x more cash!"},{"2x XP Boost","Earn 2x more XP!"},{"2x Luck Boost","Earn 2x more luck!"},{"2x Speed Boost","Move 2x faster!"}}) do
        local price = dur=="15 Min" and "29" or "99"
        local card = frame(bgrid,UDim2.new(),nil,C.card,10,C.cardBorder); padAll(card,10,10,10,10)
        txt(card,bd[1],13,C.txt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Center})
        local well = frame(card,UDim2.new(1,0,0,52),UDim2.new(0,0,0,24),Color3.fromRGB(10,12,18),8); well.BackgroundTransparency=.4
        txt(well,"⚡",22,C.blueTxt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
        txt(card,bd[2],11,C.dim,F8,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,84),TextXAlignment=Enum.TextXAlignment.Center})
        local dc = chip(card,dur,C.soft,.72); dc.AnchorPoint=Vector2.new(.5,0); dc.Position=UDim2.new(.5,-24,0,104)
        local buy = goldBuyBtn(card,UDim2.new(0,110,0,30),"",price,bd[1].." ("..dur..")"); buy.AnchorPoint=Vector2.new(.5,1); buy.Position=UDim2.new(.5,0,1,0)
      end
    end
    txt(wrap,"Boosts stack with each other! Activate multiple boosts for even better rewards!",12,C.goldTxt,F8,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Center})
  end

  -- BRAINROTS page
  do
    local pg = tabPages.brainrots
    local wrap = frame(pg,UDim2.new(1,0,0,508),nil,C.inner,12,C.border); padAll(wrap,16,18,16,18)
    sectionTitle(wrap,"BRAINROTS",hex("A44CEC"))
    local sb, box = searchBox(wrap,280,"Search brainrots...")
    sb.AnchorPoint=Vector2.new(1,0); sb.Position=UDim2.new(1,0,0,0)
    local bgrid = mk("Frame",{Size=UDim2.new(1,0,0,420),Position=UDim2.new(0,0,0,44),BackgroundTransparency=1},wrap)
    ugrid(bgrid,224,196,12)
    local cards = {}
    for _,r in ipairs({
      {"Tralalero Tralala","Legendary","$10K/s","4,999"},{"Bombardino Crocodilo","Legendary","$8K/s","4,499"},
      {"Ballerina Cappuccina","Epic","$3K/s","1,999"},{"Tung Tung Tung Sahur","Epic","$2.5K/s","1,499"},
      {"Lirili Larila","Rare","$1.5K/s","999"},{"Cappuccino Assassino","Rare","$1.2K/s","799"},
      {"Brr Brr Patapim","Rare","$900/s","599"},{"Trippi Troppi","Uncommon","$500/s","399"},
      {"Chimpanzini Bananini","Uncommon","$400/s","299"},{"Boneca Ambalabu","Common","$200/s","199"},
    }) do
      local c = itemCard(bgrid,r[1],r[2],r[3],r[4])
      cards[#cards+1] = {c, r[1]:lower()}
    end
    box:GetPropertyChangedSignal("Text"):Connect(function()
      local q = box.Text:lower()
      for _,e in ipairs(cards) do e[1].Visible = (q=="" or e[2]:find(q,1,true)~=nil) end
    end)
  end

  -- GAMEPASSES page
  do
    local pg = tabPages.gamepasses
    local wrap = frame(pg,UDim2.new(1,0,0,508),nil,C.inner,12,C.border); padAll(wrap,16,18,16,18)
    sectionTitle(wrap,"GAMEPASSES",hex("EFAF2A"))
    local gg = mk("Frame",{Size=UDim2.new(1,0,0,400),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},wrap)
    ugrid(gg,576,118,14)
    for _,g in ipairs({
      {"VIP","Unlock VIP chat tag and join VIP servers!","199"},{"2x Cash","Earn double cash from all sources!","299"},
      {"Auto Collect","Automatically collect cash from your spawners!","399"},{"Infinite Inventory","Never run out of inventory space!","499"},
      {"Fast Hatch","Hatch eggs 2x faster!","599"},{"Exclusive Pets","Access exclusive pets found nowhere else!","799"},
    }) do
      local card = frame(gg,UDim2.new(),nil,C.card,10,C.cardBorder); padAll(card,14,16,14,16)
      local well = frame(card,UDim2.new(0,78,0,78),UDim2.new(0,0,.5,-39),Color3.fromRGB(10,12,18),8); well.BackgroundTransparency=.4
      txt(well,"♛",26,C.goldTxt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
      txt(card,g[1],16,C.txt,FB,{Position=UDim2.new(0,94,0,4)})
      txt(card,g[2],11,C.dim,F8,{Position=UDim2.new(0,94,0,30),TextWrapped=true,Size=UDim2.new(1,-200,0,32),AutomaticSize=Enum.AutomaticSize.None,TextXAlignment=Enum.TextXAlignment.Left})
      local buy = goldBuyBtn(card,UDim2.new(0,96,0,30),"",g[3],g[1].." Gamepass"); buy.AnchorPoint=Vector2.new(1,1); buy.Position=UDim2.new(1,0,1,0)
    end
    txt(wrap,"Gamepasses are permanent and save across all servers!",12,C.goldTxt,F8,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Center})
  end
  selectTab("featured")
end

---------------------------------------------------------------- SETTINGS
do
  local root, body = panel("settings",1240,640,"SETTINGS",P.greenHdr)
  padAll(body,18,20,20,20)
  local sideBar = mk("Frame",{Size=UDim2.new(0,240,1,0),BackgroundTransparency=1},body); vlist(sideBar,8)
  local content = mk("ScrollingFrame",{Size=UDim2.new(1,-256,1,-60),Position=UDim2.new(0,256,0,0),BackgroundTransparency=1,
    BorderSizePixel=0,ScrollBarThickness=8,ScrollBarImageColor3=C.cardBorder,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},body)
  vlist(content,9)
  local footer = mk("Frame",{Size=UDim2.new(1,-256,0,48),Position=UDim2.new(0,256,1,-48),BackgroundTransparency=1},body)
  local pages, tabBtns = {}, {}
  local dirty = false
  local saveBtn, saveLbl
  local function setDirty(d)
    dirty = d
    if saveLbl then saveLbl.Text = d and "Save Changes" or "Saved ✓" end
  end
  local function markDirty() setDirty(true) end
  local function selectTab(id)
    for tid,pg in pairs(pages) do pg.Visible = (tid==id) end
    for tid,btn in pairs(tabBtns) do
      local top = btn:FindFirstChildOfClass("TextButton")
      local on = tid==id
      top.BackgroundColor3 = on and P.green.B or C.inner
      top:FindFirstChildOfClass("UIGradient").Color = on and ColorSequence.new(P.green.L,P.green.B) or ColorSequence.new(C.inner,C.inner)
      top:FindFirstChildOfClass("UIStroke").Color = on and P.green.D or C.border
      top:FindFirstChildOfClass("TextLabel").TextColor3 = on and C.txt or hex("8B94AA")
    end
  end
  for _,td in ipairs({{"general","General"},{"graphics","Graphics"},{"audio","Audio"},{"controls","Controls"},{"about","About"}}) do
    local b = chunky(sideBar,UDim2.new(1,0,0,50),P.green,td[2],15,function() selectTab(td[1]) end)
    local lbl = b:FindFirstChildOfClass("TextButton"):FindFirstChildOfClass("TextLabel")
    lbl.AnchorPoint=Vector2.new(0,.5); lbl.Position=UDim2.new(0,18,.5,0)
    tabBtns[td[1]] = b
    pages[td[1]] = mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false},content)
    vlist(pages[td[1]],9)
  end
  local function toggleRow(parent, labelStr, default)
    local row = frame(parent,UDim2.new(1,0,0,54),nil,C.inner,10,C.border)
    txt(row,labelStr,14,C.txt,FB,{Position=UDim2.new(0,18,0,17)})
    local t = toggle(row,default,markDirty); t.AnchorPoint=Vector2.new(1,.5); t.Position=UDim2.new(1,-14,.5,0)
    local hs = row:FindFirstChildOfClass("UIStroke")
    row.MouseEnter:Connect(function() hs.Color=C.hoverBorder end)
    row.MouseLeave:Connect(function() hs.Color=C.border end)
    return row
  end
  -- GENERAL (2-col grid)
  do
    local pg = pages.general
    txt(pg,"GAMEPLAY",13,hex("8CDC3E"),FB)
    local g = mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},pg)
    ugrid(g,470,54,9)
    for _,d in ipairs({{"Show Damage Numbers",true},{"Show Other Players",true},{"Show Player Names",true},{"Show Pets / Brainrots",true},
      {"Hide Other Players' Pets",false},{"Screen Shake",true},{"Camera Effects",true},{"Event Popups",true},
      {"FPS Counter",false},{"Ping Display",false},{"Auto Sprint",false},{"Tips & Hints",true}}) do
      local r = toggleRow(g,d[1],d[2]); r.Size = UDim2.new()
    end
  end
  -- GRAPHICS (toggles + cycle selects)
  do
    local pg = pages.graphics
    txt(pg,"GRAPHICS",13,hex("8CDC3E"),FB)
    local function selectRow(labelStr, options, defaultIdx)
      local row = frame(pg,UDim2.new(1,0,0,54),nil,C.inner,10,C.border)
      txt(row,labelStr,14,C.txt,FB,{Position=UDim2.new(0,18,0,17)})
      local idx = defaultIdx or 1
      local btn = mk("TextButton",{Size=UDim2.new(0,150,0,34),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),
        BackgroundColor3=Color3.fromRGB(10,12,18),Text="",AutoButtonColor=false,BorderSizePixel=0},row)
      btn.BackgroundTransparency=.3; corner(btn,9); stroke(btn,C.cardBorder,1.5)
      local vl = txt(btn,options[idx].."  ▼",13,C.txt,FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
      btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        vl.Text = options[idx].."  ▼"
        markDirty()
      end)
    end
    selectRow("Graphics Preset",{"Low","Medium","High","Ultra"},3)
    toggleRow(pg,"Shadows",true)
    selectRow("Textures",{"Low","Medium","High"},3)
    selectRow("Effect Quality",{"Low","Medium","High"},3)
    toggleRow(pg,"Particle Effects",true)
    selectRow("Render Distance",{"Low","Medium","High"},2)
    toggleRow(pg,"Bloom / Glow",true)
    toggleRow(pg,"Anti-Aliasing",true)
    selectRow("FPS Cap",{"30","60","120","240","Unlimited"},2)
    selectRow("UI Scale",{"80%","90%","100%","110%","120%"},3)
  end
  -- AUDIO
  do
    local pg = pages.audio
    txt(pg,"VOLUME",13,hex("8CDC3E"),FB)
    for _,d in ipairs({{"Master Volume",80},{"Music Volume",75},{"SFX Volume",60},{"UI Volume",70},{"Ambient Volume",50}}) do
      local row = frame(pg,UDim2.new(1,0,0,68),nil,C.inner,10,C.border); padAll(row,12,18,12,18)
      txt(row,d[1],14,C.txt,FB)
      local pctLbl = txt(row,d[2].."%",14,C.greenTxt,FB,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0)})
      local sl = slider(row,nil,d[2],function(v) pctLbl.Text=v.."%"; markDirty() end)
      sl.Position = UDim2.new(0,0,0,30)
    end
    txt(pg,"SOUND EFFECTS",13,hex("8CDC3E"),FB)
    toggleRow(pg,"Hit Sounds",true); toggleRow(pg,"Event Sounds",true)
    toggleRow(pg,"Music in Menus",true); toggleRow(pg,"Mute All",false)
  end
  -- CONTROLS
  do
    local pg = pages.controls
    txt(pg,"CAMERA & MOUSE",13,hex("8CDC3E"),FB)
    for _,d in ipairs({{"Mouse Sensitivity",50},{"Camera Zoom Speed",40}}) do
      local row = frame(pg,UDim2.new(1,0,0,68),nil,C.inner,10,C.border); padAll(row,12,18,12,18)
      txt(row,d[1],14,C.txt,FB)
      local pctLbl = txt(row,d[2].."%",14,C.greenTxt,FB,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0)})
      slider(row,nil,d[2],function(v) pctLbl.Text=v.."%"; markDirty() end).Position=UDim2.new(0,0,0,30)
    end
    toggleRow(pg,"Invert Camera Y",false)
    txt(pg,"KEYBINDS",13,hex("8CDC3E"),FB)
    for _,k in ipairs({{"Sprint","Shift"},{"Toggle Sprint","T"},{"Interact","E"},{"Open Shop","P"},{"Open Index","N"},
      {"Open Rebirth","R"},{"Open Inventory","B"},{"Open Quests","Q"},{"Open Map","M"},{"Emote","G"},{"Open Settings","Esc"}}) do
      local row = frame(pg,UDim2.new(1,0,0,52),nil,C.inner,10,C.border)
      txt(row,k[1],14,C.txt,FB,{Position=UDim2.new(0,18,0,16)})
      local kb = frame(row,UDim2.new(0,64,0,34),UDim2.new(1,-80,.5,-17),Color3.fromRGB(10,12,18),8,C.cardBorder)
      kb.BackgroundTransparency=.3
      txt(kb,k[2],12,hex("8CDC3E"),FB,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0)})
    end
  end
  -- ABOUT
  do
    local pg = pages.about
    local card = frame(pg,UDim2.new(1,0,0,460),nil,C.inner,12,C.border); padAll(card,32,28,24,28)
    local at = txt(card,"SURVIVE EVENTS FOR BRAINROTS!",26,hex("8CDC3E"),FONT,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Center})
    stroke(at,hex("17300B"),2).ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual
    local vc = chip(card,"Version 1.0.0",C.greenTxt,.72); vc.AnchorPoint=Vector2.new(.5,0); vc.Position=UDim2.new(.5,-46,0,44)
    txt(card,"Survive chaotic events, grind, rebirth, and collect brainrots to become the strongest.",13,C.soft,F8,
      {AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,96),TextWrapped=true,Size=UDim2.new(0,520,0,44),AutomaticSize=Enum.AutomaticSize.None,TextXAlignment=Enum.TextXAlignment.Center})
    local links = mk("Frame",{Size=UDim2.new(0,620,0,84),AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,170),BackgroundTransparency=1},card)
    ugrid(links,146,84,12)
    for _,l in ipairs({"Update Logs","Discord","Credits","Report a Bug"}) do
      local b = frame(links,UDim2.new(),nil,C.card,10,C.cardBorder)
      txt(b,l,12,C.txt,FB,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),TextXAlignment=Enum.TextXAlignment.Center})
      txt(b,"◆",18,C.blueTxt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,14)})
      local click = mk("TextButton",{Size=UDim2.new(1,0,1,0),Text="",BackgroundTransparency=1},b)
      click.MouseButton1Click:Connect(function() toast("info",l,"TODO: open link") end)
    end
    txt(card,"© 2026 Survive Events For Brainrots! · All rights reserved.",11,C.muted,F8,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),TextXAlignment=Enum.TextXAlignment.Center})
  end
  -- footer
  local resetB = chunky(footer,UDim2.new(0,160,0,40),P.dark,"↺ Reset to Default",12,function() setDirty(false); toast("info","Settings reset","This tab is back to defaults") end)
  resetB.Position = UDim2.new(0,0,0,6)
  saveBtn = chunky(footer,UDim2.new(0,150,0,40),P.green,"Saved ✓",13,function() setDirty(false); toast("reward","Settings saved!","Your changes were applied") end)
  saveBtn.AnchorPoint = Vector2.new(1,0); saveBtn.Position = UDim2.new(1,0,0,6)
  saveLbl = saveBtn:FindFirstChildOfClass("TextButton"):FindFirstChildOfClass("TextLabel")
  selectTab("general")
end

---------------------------------------------------------------- REBIRTH
do
  local root, body = panel("rebirth",1240,560,"REBIRTH",P.purpleHdr)
  root.BackgroundColor3 = hex("1A1224")
  padAll(body,18,26,26,26)
  local mascot = frame(body,UDim2.new(0,220,0,220),UDim2.new(0,40,0,10),hex("241934"),22,hex("37264E"))
  txt(mascot,"Drop mascot render here",12,C.muted,F8,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),TextWrapped=true})
  txt(body,"Rebirth to earn permanent boosts and become stronger!",18,C.txt,FB,{Position=UDim2.new(0,320,0,14),TextWrapped=true,Size=UDim2.new(0,420,0,50),AutomaticSize=Enum.AutomaticSize.None})
  local cr = frame(body,UDim2.new(0,560,0,110),UDim2.new(0,320,0,78),hex("241934"),12,hex("37264E")); padAll(cr,14,20,14,20)
  txt(cr,"CURRENT REBIRTHS",13,C.purpleTxt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Center})
  txt(cr,"⟳  3",34,C.txt,FONT,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,-50,0,26),TextXAlignment=Enum.TextXAlignment.Center})
  local rank = chip(cr,"RANK: ASCENDANT",hex("DFC2FF"),.8); rank.AnchorPoint=Vector2.new(.5,0); rank.Position=UDim2.new(.5,10,0,40)
  local rw = frame(body,UDim2.new(1,0,0,96),UDim2.new(0,0,0,252),hex("241934"),12,hex("37264E")); padAll(rw,12,22,12,22)
  txt(rw,"NEXT REBIRTH REWARDS",13,C.purpleTxt,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),TextXAlignment=Enum.TextXAlignment.Center})
  local rrow = mk("Frame",{Size=UDim2.new(1,0,0,48),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1},rw)
  ugrid(rrow,370,48,14)
  for _,r in ipairs({{"+25%","XP Boost",C.blueTxt},{"+25%","Luck Boost",hex("8CDC3E")},{"+10%","Cash Boost",C.goldTxt}}) do
    local cell = frame(rrow,UDim2.new(),nil,Color3.fromRGB(10,12,18),10); cell.BackgroundTransparency=.5
    txt(cell,r[1],16,r[3],FB,{Position=UDim2.new(0,110,0,6)})
    txt(cell,r[2],12,C.txt,FB,{Position=UDim2.new(0,110,0,26)})
    txt(cell,"◆",20,r[3],FB,{Position=UDim2.new(0,72,0,12)})
  end
  local ms = frame(body,UDim2.new(1,0,0,70),UDim2.new(0,0,0,360),hex("241934"),12,hex("37264E")); padAll(ms,12,22,12,22)
  txt(ms,"MILESTONES",12,C.purpleTxt,FB,{Position=UDim2.new(0,0,0,14)})
  local mrow = mk("Frame",{Size=UDim2.new(1,-120,0,46),Position=UDim2.new(0,120,0,0),BackgroundTransparency=1},ms)
  ugrid(mrow,330,46,10)
  for _,m in ipairs({{"REBIRTH 5","+100% All Boosts"},{"REBIRTH 10","Exclusive Brainrot"},{"REBIRTH 25","Golden Mascot Skin"}}) do
    local cell = frame(mrow,UDim2.new(),nil,Color3.fromRGB(10,12,18),10); cell.BackgroundTransparency=.5; padAll(cell,7,12,7,12)
    txt(cell,m[1],10,C.purpleTxt,FB)
    txt(cell,m[2],11,C.txt,FB,{Position=UDim2.new(0,0,0,16)})
  end
  local big = chunky(body,UDim2.new(0,720,0,54),P.purple,"REBIRTH   ⟳ 100",22,function()
    toast("reward","Rebirth complete!","You are now Rebirth 4 — +80% all boosts")
  end)
  big.AnchorPoint = Vector2.new(.5,0); big.Position = UDim2.new(.5,0,0,442)
  big:FindFirstChildOfClass("TextButton"):FindFirstChildOfClass("TextLabel").Font = FONT
  txt(body,"Rebirthing will reset your progress but grant you permanent boosts.",12,hex("9C86B8"),F8,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,1,-24),TextXAlignment=Enum.TextXAlignment.Center})
end

---------------------------------------------------------------- INDEX
do
  local root, body = panel("index",1240,600,"INDEX",P.blue)
  padAll(body,18,20,20,20)
  local top = frame(body,UDim2.new(1,0,0,56),nil,C.inner,12,C.border); padAll(top,10,20,10,20)
  txt(top,"Discovered:  8 / 12",14,C.txt,FB,{Position=UDim2.new(0,0,0,9)})
  local track = frame(top,UDim2.new(0,240,0,12),UDim2.new(0,180,0,13),Color3.fromRGB(8,10,15),6)
  local fl = frame(track,UDim2.new(.66,0,1,0),nil,P.blue.B,5); grad(fl,P.blue.L,P.blue.B)
  local sb, box = searchBox(top,260,"Search index..."); sb.AnchorPoint=Vector2.new(1,.5); sb.Position=UDim2.new(1,0,.5,0)
  local wrap = frame(body,UDim2.new(1,0,1,-70),UDim2.new(0,0,0,70),C.inner,12,C.border); padAll(wrap,16,18,16,18)
  local igrid = mk("Frame",{Size=UDim2.new(1,0,0,340),BackgroundTransparency=1},wrap)
  ugrid(igrid,186,158,12)
  local entries = {}
  local discovered = {[1]=true,[2]=true,[3]=true,[4]=true,[6]=true,[7]=true,[9]=true,[10]=true}
  local names = {"Tralalero Tralala","Bombardino Crocodilo","Ballerina Cappuccina","Tung Tung Tung Sahur","Lirili Larila","Cappuccino Assassino","Brr Brr Patapim","Trippi Troppi","Chimpanzini Bananini","Boneca Ambalabu","Bombini Gusini","Frigo Camelo"}
  local rar = {"Legendary","Legendary","Epic","Epic","Rare","Rare","Rare","Uncommon","Uncommon","Common","Epic","Legendary"}
  for i,n in ipairs(names) do
    if discovered[i] then
      entries[#entries+1] = {itemCard(igrid,n,rar[i],nil,nil), n:lower()}
    else
      local card = frame(igrid,UDim2.new(),nil,hex("1B202D"),10,C.cardBorder)
      card.BackgroundTransparency=.25
      txt(card,"?",30,hex("3E4661"),FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,26)})
      txt(card,"???",12,C.muted,FB,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,86),TextXAlignment=Enum.TextXAlignment.Center})
      local uc = chip(card,"UNDISCOVERED",C.muted,.8); uc.AnchorPoint=Vector2.new(.5,0); uc.Position=UDim2.new(.5,-44,0,110)
      entries[#entries+1] = {card, "???"}
    end
  end
  box:GetPropertyChangedSignal("Text"):Connect(function()
    local q = box.Text:lower()
    for _,e in ipairs(entries) do e[1].Visible = (q=="" or e[2]:find(q,1,true)~=nil) end
  end)
  local foot = mk("Frame",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,1,-36),BackgroundTransparency=1},wrap)
  txt(foot,"Discover new brainrots by surviving events and opening crates!",12,C.dim,F8,{Position=UDim2.new(0,0,0,8)})
  local reveal = chunky(foot,UDim2.new(0,270,0,34),P.purple,"",12,function() _G.ShowPurchase("Reveal Mystery Brainrot","99",true) end)
  reveal.AnchorPoint=Vector2.new(1,0); reveal.Position=UDim2.new(1,0,0,0)
  local rl = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},reveal:FindFirstChildOfClass("TextButton"))
  local rll = hlist(rl,7,true); rll.HorizontalAlignment=Enum.HorizontalAlignment.Center
  txt(rl,"? Reveal Mystery Brainrot",12,C.txt,FB); robuxTag(rl,"99")
end
