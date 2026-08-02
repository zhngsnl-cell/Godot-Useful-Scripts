shader_type canvas_item;

// ========== 1. 调色板替换参数 ==========
// 启用/禁用调色板替换
uniform bool enable_palette_swap = false;

// 源颜色 (需要被替换的颜色)
uniform vec3 the_source_color = vec3(1.0, 0.0, 0.0);

// 目标颜色 (替换成的颜色)
uniform vec3 target_color : source_color = vec3(0.0, 1.0, 1.0);

// 颜色匹配的容差范围 (0.0 = 精确匹配, 0.5 = 宽松匹配)
uniform float color_tolerance : hint_range(0.0, 0.5) = 0.1;

// ========== 2. 色差分离参数 (Chromatic Aberration) ==========
// 启用/禁用色差
uniform bool enable_chromatic = true;

// 色差偏移强度
uniform float chromatic_strength : hint_range(0.0, 0.05) = 0.01;

// 色差方向 (角度, 弧度)
uniform float chromatic_angle : hint_range(0.0, 6.2832) = 0.0;

// ========== 3. 像素化参数 ==========
// 启用/禁用像素化
uniform bool enable_pixelate = false;

// 像素大小 (数值越大像素块越明显)
uniform float pixel_size : hint_range(1.0, 32.0) = 4.0;

// ========== 4. 扫描线参数 ==========
// 启用/禁用扫描线
uniform bool enable_scanline = false;

// 扫描线密度
uniform float scanline_density : hint_range(0.0, 1.0) = 0.5;

// 扫描线亮度 (0.0 = 全黑, 1.0 = 无影响)
uniform float scanline_brightness : hint_range(0.0, 1.0) = 0.6;

// ========== 5. 故障效果参数 (Glitch) ==========
// 启用/禁用故障
uniform bool enable_glitch = false;

// 故障强度
uniform float glitch_strength : hint_range(0.0, 0.1) = 0.02;

// 故障频率
uniform float glitch_frequency : hint_range(0.0, 20.0) = 5.0;

// ========== 6. 整体色调调整 ==========
// 色调偏移 (RGB偏移)
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);

// 对比度
uniform float contrast : hint_range(0.0, 2.0) = 1.0;

// 饱和度
uniform float saturation : hint_range(0.0, 2.0) = 1.2;

// 暗角强度
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;

// ============================================================
// 工具函数: 颜色替换 (调色板)
// ============================================================
vec3 palette_swap(vec3 color, vec3 source, vec3 target, float tolerance) {
    // 计算颜色距离
    float dist = distance(color, source);
    
    // 如果颜色在容差范围内, 替换成目标颜色
    if (dist < tolerance) {
        // 平滑过渡, 避免边缘锯齿
        float blend = 1.0 - smoothstep(0.0, tolerance, dist);
        return mix(color, target, blend);
    }
    return color;
}

// ============================================================
// 工具函数: 色差分离
// ============================================================
vec3 chromatic_aberration(vec2 uv, sampler2D tex, float strength, float angle) {
    vec2 direction = vec2(cos(angle), sin(angle));
    
    // 分别采样RGB通道, 每个通道偏移不同方向
    float r_offset = strength;
    float g_offset = 0.0;
    float b_offset = -strength;
    
    vec2 uv_r = uv + direction * r_offset;
    vec2 uv_g = uv + direction * g_offset;
    vec2 uv_b = uv + direction * b_offset;
    
    float r = texture(tex, uv_r).r;
    float g = texture(tex, uv_g).g;
    float b = texture(tex, uv_b).b;
    
    return vec3(r, g, b);
}

// ============================================================
// 工具函数: 像素化
// ============================================================
vec2 pixelate_uv(vec2 uv, float size) {
    vec2 pixel_uv = floor(uv * size) / size;
    return pixel_uv;
}

// ============================================================
// 工具函数: 扫描线
// ============================================================
float scanline_pattern(vec2 uv, float density, float brightness) {
    // 基于Y轴生成扫描线
    float pattern = sin(uv.y * density * 3.14159 * 2.0);
    // 将pattern映射到 [brightness, 1.0] 范围
    return mix(brightness, 1.0, abs(pattern));
}

// ============================================================
// 工具函数: 故障效果 (Glitch)
// ============================================================
float glitch_offset(vec2 uv, float time, float strength, float frequency) {
    // 使用多个正弦波叠加产生随机感
    float hash1 = sin(uv.y * 100.0 + time * frequency) * 0.5 + 0.5;
    float hash2 = sin(uv.y * 200.0 + time * frequency * 1.3) * 0.5 + 0.5;
    
    // 只在某些行触发故障 (阈值控制故障密度)
    float threshold = 0.95;
    float glitch_active = step(threshold, hash1 * hash2);
    
    // 故障偏移量 (随机方向)
    float offset = (sin(uv.y * 300.0 + time * frequency * 2.0) * 0.5 + 0.5) * strength;
    offset *= glitch_active;
    
    return offset;
}

// ============================================================
// 主函数
// ============================================================
void fragment() {
    vec2 uv = UV;
    float time = TIME;
    
    // ---- 1. 像素化 (先做, 降低分辨率) ----
    if (enable_pixelate) {
        uv = pixelate_uv(uv, pixel_size);
    }
    
    // ---- 2. 故障效果 (UV偏移) ----
    vec2 glitch_uv = uv;
    if (enable_glitch) {
        float offset_x = glitch_offset(uv, time, glitch_strength, glitch_frequency);
        // 有时也偏移Y轴, 产生更丰富的故障效果
        float offset_y = glitch_offset(uv + vec2(0.5, 0.0), time * 0.7, glitch_strength * 0.5, glitch_frequency * 0.8);
        glitch_uv.x += offset_x;
        glitch_uv.y += offset_y * 0.3;
        
        // 钳制UV防止边缘采样问题
        glitch_uv = clamp(glitch_uv, 0.0, 1.0);
    }
    
    // ---- 3. 色差分离 ----
    vec3 color;
    if (enable_chromatic) {
        color = chromatic_aberration(glitch_uv, TEXTURE, chromatic_strength, chromatic_angle);
    } else {
        color = texture(TEXTURE, glitch_uv).rgb;
    }
    
    // ---- 4. 调色板替换 ----
    if (enable_palette_swap) {
        color = palette_swap(color, the_source_color, target_color, color_tolerance);
    }
    
    // ---- 5. 扫描线 ----
    if (enable_scanline) {
        float scan = scanline_pattern(uv, scanline_density, scanline_brightness);
        color *= scan;
    }
    
    // ---- 6. 色调调整 (Tint) ----
    color *= tint_color;
    
    // ---- 7. 饱和度调整 ----
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(gray), color, saturation);
    
    // ---- 8. 对比度调整 ----
    color = (color - 0.5) * contrast + 0.5;
    color = clamp(color, 0.0, 1.0);
    
    // ---- 9. 暗角效果 (Vignette) ----
    if (vignette_strength > 0.0) {
        vec2 center_uv = uv - 0.5;
        float dist = length(center_uv);
        float vignette = 1.0 - dist * vignette_strength * 1.5;
        vignette = clamp(vignette, 0.0, 1.0);
        color *= vignette;
    }
    
    // ---- 输出 ----
    COLOR = vec4(color, texture(TEXTURE, uv).a);
}