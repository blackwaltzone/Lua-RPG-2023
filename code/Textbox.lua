--[[
--
--Textbox.lua
--
--Panel that contains text, representing speech.
--May include options for player, images, and/or title
--Flexible depending on text amount
--contains outer rectangle (border)
--inner rectangle (text), with padding
--
--
--Dustin Heyden
--
--22 April 2023
--
--]]--

Textbox = {}
Textbox.__index = Textbox

function Textbox:Create(params)

    params = params or {}

    -- turn string into a table
    if type(params.text) == "string" then
        params.text = {params.text}
    end

    local this = 
    {
        Stack = params.stack,
        DoClickCallback = false,
        Chunks = params.text,
        ChunkIndex = 1,
        ContinueMark = Sprite.Create(),
        Time = 0,
        TextScale = params.textScale or 1,
        Panel = Panel:Create(params.panelArgs),
        Size = params.size,
        Bounds = params.textbounds,
        -- tween goes from 0 to 1 for in-transition
        AppearTween = Tween:Create(0, 1, 0.4, Tween.EaseOutCirc),
        Wrap = params.wrap or -1,
        Children = params.children or {},
        SelectionMenu = params.selectionMenu,
    }

    this.ContinueMark:SetTexture(Texture.Find("continue_caret.png"))

    -- calculate center point from size
    -- we can use this to scale
    this.X = (this.Size.right + this.Size.left) / 2
    this.Y = (this.Size.top + this.Size.bottom) / 2
    this.Width = this.Size.right - this.Size.left
    this.Height = this.Size.top - this.Size.bottom

    setmetatable(this, self)
    return this
end


-- handle textbox input
function Textbox:HandleInput()
    if self.SelectionMenu then
        self.SelectionMenu:HandleInput()
    end

    if Keyboard:JustPressed(KEY_SPACE) then
        self:OnClick()
    end
end


-- render the textbox
function Textbox:Render(renderer)
    local scale = self.AppearTween:Value()

    renderer:ScaleText(self.TextScale * scale)
    renderer:AlignText("left", "top")

    -- draw the scale panel
    self.Panel:CenterPosition(
        self.X,
        self.Y,
        self.Width * scale,
        self.Height * scale)

        self.Panel:Render(renderer)

        local left = self.X - (self.Width / 2 * scale)
        local textLeft = left + (self.Bounds.left * scale)

        local top = self.Y + (self.Height / 2 * scale)
        local textTop = top + (self.Bounds.top * scale)

        local bottom = self.Y - (self.Height / 2 * scale)

    -- draw text
    renderer:DrawText2d(
        textLeft,
        textTop,
        self.Chunks[self.ChunkIndex],
        Vector.Create(1, 1, 1, 1),
        self.Wrap * scale)

    -- render the selection menu
    if self.SelectionMenu then
        renderer:AlignText("left", "center")
        local menuX = textLeft
        local menuY = bottom + self.SelectionMenu:GetHeight()
        menuY = menuY + self.Bounds.bottom
        self.SelectionMenu.X = menuX
        self.SelectionMenu.Y = menuY
        self.SelectionMenu.Scale = scale
        self.SelectionMenu:Render(renderer)
    end

    -- draw caret if more text to render
    if self.ChunkIndex < #self.Chunks then
        -- there are more chunks to come
        -- bounce caret using sin function
        local offset = 12 + math.floor(math.sin(self.Time * 10)) * scale
        self.ContinueMark:SetScale(scale, scale)
        self.ContinueMark:SetPosition(self.X, bottom + offset)
        renderer:DrawSprite(self.ContinueMark)
    end

    for k, v in iapairs(self.Children) do
        if v.type == "text" then
            renderer:DrawText2d(
                textLeft + (v.x * scale),
                textTop + (v.y * scale),
                v.text,
                Vector.Create(1, 1, 1, 1))
        elseif v.type == "sprite" then
            v.sprite:SetPosition(
                left + (v.x * scale),
                top + (v.y * scale))
            v.sprite:SetScale(scale, scale)
            renderer:DrawSprite(v.sprite)
        end
    end
end


-- update the textbox's appear tween/transition effect
function Textbox:Update(dt)
    self.Time = self.Time + dt
    self.AppearTween:Update(dt)

    if self:IsDead() then
        self.Stack:Pop()
    end

    -- states below can be rendered and updated
    return true
end


-- represents an interaction with the textbox
-- dismisses the textbox, reverses appear tween
function Textbox:OnClick()

    if self.SelectionMenu then
        self.DoClickCallback = true
    end

    if self.ChunkIndex >= #self.Chunks then
        -- if the dialong is appearing or disappearing
        -- ignore interaction
        if not(self.AppearTween:IsFinished()
            and self.AppearTween:Value() == 1) then
            return
        end 

        -- tween goes from 1 to 0 on out-transition
        self.AppearTween = Tween:Create(1, 0, 0.2, Tween.EaseInCirc)
    else
        self.ChunkIndex = self.ChunkIndex + 1
    end
end


-- tween has finished
function Textbox:IsDead()
    return self.AppearTween:IsFinished()
        and self.AppearTween:Value() == 0
end


-- enter
function Textbox:Enter() end


-- exit
function Textbox:Exit()
    if self.DoClickCallback then
        self.SelectionMenu:OnClick()
    end
end