BuffOverlayBorderTemplateMixin = {}

function BuffOverlayBorderTemplateMixin:OnLoad()
    BuffOverlayBorderTemplateMixin.UpdateSizes(self)
end

function BuffOverlayBorderTemplateMixin:SetVertexColor(r, g, b, a)
    for _, texture in ipairs(self.Textures) do
        texture:SetVertexColor(r, g, b, a)
    end
end

function BuffOverlayBorderTemplateMixin:SetBorderSizes(
    borderSize,
    upwardExtendHeightPixels,
)
    self.borderSize = borderSize
    self.upwardExtendHeightPixels = upwardExtendHeightPixels
end

function BuffOverlayBorderTemplateMixin:UpdateSizes()
    local borderSize = self.borderSize or 1
    local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize

    -- Left
    self.Left:SetWidth(borderSize)

    self.Left:ClearAllPoints()
    self.Left:SetPoint(
        "TOPRIGHT",
        self,
        "TOPLEFT",
        0,
        upwardExtendHeightPixels
    )

    self.Left:SetPoint(
        "BOTTOMRIGHT",
        self,
        "BOTTOMLEFT",
        0,
        -borderSize
    )

    -- Right
    self.Right:SetWidth(borderSize)

    self.Right:ClearAllPoints()
    self.Right:SetPoint(
        "TOPLEFT",
        self,
        "TOPRIGHT",
        0,
        upwardExtendHeightPixels
    )

    self.Right:SetPoint(
        "BOTTOMLEFT",
        self,
        "BOTTOMRIGHT",
        0,
        -borderSize
    )

    -- Bottom
    self.Bottom:SetHeight(borderSize)

    self.Bottom:ClearAllPoints()
    self.Bottom:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0)
    self.Bottom:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)

    -- Top
    if self.Top then
        self.Top:SetHeight(borderSize)

        self.Top:ClearAllPoints()
        self.Top:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
        self.Top:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
    end
end