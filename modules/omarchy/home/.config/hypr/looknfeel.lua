-- -> ~/.config/hypr/looknfeel.lua, loaded after Omarchy's defaults. Gaps already
-- match AeroSpace (10px between and around windows), only the overrides live here.
hl.config({
  general = {
    -- drag a window border to resize it
    resize_on_border = true,
  },
  decoration = {
    rounding = 8,
    -- tell the focused window apart
    dim_inactive = true,
    dim_strength = 0.15,
    -- frosted look behind Ghostty's background-opacity, like on macOS
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
    },
  },
})
