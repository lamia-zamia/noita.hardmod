

---@class image_utils
local utils = {}

---Split abgr
---@param abgr_int integer
---@return number red, number green, number blue, number alpha
function utils.abgr_split(abgr_int)
	local r = bit.band(abgr_int, 0xFF)
	local g = bit.band(bit.rshift(abgr_int, 8), 0xFF)
	local b = bit.band(bit.rshift(abgr_int, 16), 0xFF)
	local a = bit.band(bit.rshift(abgr_int, 24), 0xFF)

	return r, g, b, a
end

---Merge rgb
---@param r number
---@param g number
---@param b number
---@param a number
---@return integer color
function utils.abgr_merge(r, g, b, a)
	return bit.bor(bit.band(r, 0xFF), bit.lshift(bit.band(g, 0xFF), 8), bit.lshift(bit.band(b, 0xFF), 16), bit.lshift(bit.band(a, 0xFF), 24))
end



---Replaces the image at `destination` with `image`
---@param destination string
---@param image string
function ImageReplace(destination, image)
	if not ModDoesFileExist(image) then print("image was not valid for image replacement:") print(image) return end

	local dest_data = {}
	local img_data = {}
	img_data.id,img_data.w,img_data.h = ModImageMakeEditable(image, 0, 0)
	dest_data.id,dest_data.w,dest_data.h = ModImageMakeEditable(destination, img_data.w, img_data.h)

	local w = math.max(img_data.w, dest_data.w)
	local h = math.max(img_data.h, dest_data.h)

	for y = 0, h - 1 do
		for x = 0, w - 1 do
			ModImageSetPixel(dest_data.id, x, y, ModImageGetPixel(img_data.id, x, y))
		end
	end
end

---Overlays a target `image` over a target `destination`, accounting for alpha and the such
---@param destination string
---@param image string
---@param offset_x int? `0` - x offset for the overlay's location on the destination image
---@param offset_y int? `0` - y offset for the overlay's location on the destination image
---@param alpha_multiplier number? `1` - multiplier for the alpha value of the overlay image
function utils.ImageOverlay(destination, image, offset_x, offset_y, alpha_multiplier)
	if not ModDoesFileExist(destination) then print("destination was not valid for image overlay") return end
	if not ModDoesFileExist(image) then print("image was not valid for image overlay") return end

	offset_x = offset_x or 0
	offset_y = offset_y or 0
	alpha_multiplier = alpha_multiplier or 1

	local dest_data = {}
	local img_data = {}
	img_data.id,img_data.w,img_data.h = ModImageMakeEditable(image, 0, 0)
	dest_data.id,dest_data.w,dest_data.h = ModImageMakeEditable(destination, 0, 0)

	local w = img_data.w
	local h = img_data.h

	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local dest_pixel = {utils.abgr_split(ModImageGetPixel(dest_data.id, x + offset_x, y + offset_y))}
			local img_pixel = {utils.abgr_split(ModImageGetPixel(img_data.id, x, y))}
			if img_pixel[4] == 0 then goto continue end

			for i = 1, 3 do
				local difference = (img_pixel[i] - dest_pixel[i]) * (img_pixel[4]/255) * alpha_multiplier
				dest_pixel[i] = math.min(math.max(0, dest_pixel[i] + difference), 255)
			end

			ModImageSetPixel(dest_data.id, x + offset_x, y + offset_y, utils.abgr_merge(unpack(dest_pixel)))
			::continue::
		end
	end
end

return utils
