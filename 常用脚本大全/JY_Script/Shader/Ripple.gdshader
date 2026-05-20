shader_type canvas_item;

//波纹
uniform float strength : hint_range(0.0, 0.1) = 0.02;    // 波纹偏移强度
uniform float speed : hint_range(0.0, 10.0) = 2.0;       // 扩散速度
uniform float frequency : hint_range(0.0, 50.0) = 12.0;  // 波纹密度（频率）
uniform vec2 center = vec2(0.5);  // 扩散中心点（UV空间）  : hint_range(0.0, 1.0)
uniform float decay : hint_range(0.0, 2.0) = 0.5;        // 振幅随距离衰减系数（0 = 无衰减）
uniform bool add_secondary_ripple = true;         // 叠加次级波纹增强细节  : hint

// ===== 发光圆圈参数 =====
uniform vec4 circle_color : source_color = vec4(1.0, 0.5, 0.2, 1.0); // 颜色 (RGBA)
uniform float circle_radius : hint_range(0.0, 0.5) = 0.2;            // 圆环半径（从圆心到圆环中心）
uniform float circle_width : hint_range(0.0, 0.3) = 0.08;            // 光晕宽度（半径外扩范围）
uniform float circle_intensity : hint_range(0.0, 1.0) = 0.6;         // 发光强度

void fragment() {
    // 原始 UV（用于圆圈和扭曲计算）
    vec2 orig_uv = UV;

    // 获取当前 UV 坐标
    vec2 uv = UV;
    
    // 计算相对于中心的方向和距离
    vec2 dir = uv - center;
    float dist = length(dir);
    
    // 避免除零，距离为 0 时不产生偏移
    if (dist > 0.001) {
        // 归一化方向向量
        vec2 norm_dir = dir / dist;
        
        // 主波纹相位：距离 * 频率 - 时间 * 速度
        float phase = dist * frequency - TIME * speed;
        // 正弦值作为基础偏移量
        float offset_magnitude = sin(phase);
        
        // 可选：振幅随距离衰减（使边缘平滑）
        offset_magnitude *= (1.0 - decay * dist);
        
        // 次级波纹：不同频率和速度，增强细节
        if (add_secondary_ripple) {
            float phase2 = dist * (frequency * 2.5) - TIME * (speed * 1.3);
            float offset2 = sin(phase2) * 0.4;   // 振幅比例
            offset_magnitude += offset2;
        }
        
        // 最终偏移量（沿径向）
        vec2 offset = norm_dir * offset_magnitude * strength;
        
        // 应用偏移到 UV 坐标
        uv += offset;
        
        // 可选：防止采样超出边缘导致黑边，使用 clamp 或 repeat
        // 这里使用 clamp，保持边缘纹理拉伸
        uv = clamp(uv, 0.0, 1.0);
    }
    // 采样原纹理（受水纹扭曲影响）
    vec4 tex_color = texture(TEXTURE, uv);
    
    // ----- 发光圆圈计算（基于原始 UV，不受波纹偏移）-----
    vec2 to_center = orig_uv - vec2(0.5);
    float d = length(to_center);
    
    // 圆环光晕强度：使用两个平滑阶梯，形成内实外虚的发光环
    float inner = smoothstep(circle_radius - circle_width * 0.2, circle_radius, d);
    float outer = 1.0 - smoothstep(circle_radius, circle_radius + circle_width, d);
    float glow = inner * outer;
    
    // 可选：增加一点外发光衰减（让边缘更柔和）
    glow = pow(glow, 0.8);   // 伽马校正般增强亮度
    vec3 glow_color = circle_color.rgb * glow * circle_intensity;
    
    // 叠加发光到原图（加法，保持 Alpha 不变）
    vec3 final_rgb = tex_color.rgb + glow_color;
    COLOR = vec4(final_rgb, tex_color.a);
}