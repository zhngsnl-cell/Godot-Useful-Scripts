shader_type canvas_item;

// 红色偏移的强度，范围从0.0（无变化）到1.0（完全红色）
uniform float red_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 1. 获取纹理原本的颜色
    vec4 original_color = texture(TEXTURE, UV);
    
    // 2. 计算向红色偏移后的颜色
    // 新的红色通道 = 原红色通道 + (1.0 - 原红色通道) * 偏移强度
    // 这样能确保偏移后红色分量只会增加，不会溢出（值永远 ≤ 1.0）
    float new_r = original_color.r + (1.0 - original_color.r) * red_strength;
    
    // 绿色和蓝色通道根据强度向0靠拢，让图像整体趋向红色
    float new_g = original_color.g * (1.0 - red_strength);
    float new_b = original_color.b * (1.0 - red_strength);
    
    // 3. 输出最终颜色，保留原始透明度
    COLOR = vec4(new_r, new_g, new_b, original_color.a);
}