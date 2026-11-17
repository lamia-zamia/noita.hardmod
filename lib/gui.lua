---Converts entity dimensions to gui dimensions
---@param world_w number
---@param world_h number
---@return number width, number height
function WorldGuiDimensions(world_w, world_h)
    local gui_x = world_w * self.dim_x / self.virtual_res_x
    local gui_y = world_h * self.dim_y / self.virtual_res_y
    return gui_x, gui_y
end

---Converts entity position to gui position
---@param world_x number
---@param world_y number
---@return number x, number y
function WorldGuiPosition(world_x, world_y)
    local vx = world_x - self.cam_x + self.virtual_res_x / 2
    local vy = world_y - self.cam_y + self.virtual_res_y / 2
    local gui_x = vx * self.dim_x / self.virtual_res_x
    local gui_y = vy * self.dim_y / self.virtual_res_y
    return gui_x, gui_y
end
