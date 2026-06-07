shader_type canvas_item;
// 像素块的大小，值越大像素感越强。可以保留此选项方便在编辑器中调节。
uniform int pixel_size : hint_range(1, 64) = 4;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // 1. 根据像素块大小，计算出当前像素所属“块”的坐标
    vec2 pixel_coords = floor(FRAGCOORD.xy / float(pixel_size)) * float(pixel_size);
    
    // 2. 将这个“块”的坐标转换为屏幕UV坐标
    vec2 uv = pixel_coords / (1.0 / SCREEN_PIXEL_SIZE);
    
    // 3. 采样屏幕上对应“块”的颜色
    vec4 pixelated_color = textureLod(SCREEN_TEXTURE, uv, 0.0);
    
    // 4. 输出最终颜色
    COLOR = pixelated_color;
}