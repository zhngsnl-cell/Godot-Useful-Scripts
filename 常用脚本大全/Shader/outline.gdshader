shader_type canvas_item;

uniform vec4 OutlineColor:source_color = vec4(0.0,0.0,0.0,1.0);
uniform float OutlineWidth = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;

	vec2 uvUp = uv + vec2(0,TEXTURE_PIXEL_SIZE.y) * OutlineWidth;
	vec2 uvDown = uv + vec2(0,-TEXTURE_PIXEL_SIZE.y) * OutlineWidth;
	vec2 uvLeft = uv + vec2(-TEXTURE_PIXEL_SIZE.x,0) * OutlineWidth;
	vec2 uvRight = uv + vec2(TEXTURE_PIXEL_SIZE.x,0) * OutlineWidth;

	vec4 ColorUp = texture(TEXTURE,uvUp);
	vec4 ColorDown = texture(TEXTURE,uvDown);
	vec4 ColorLeft = texture(TEXTURE,uvLeft);
	vec4 ColorRight = texture(TEXTURE,uvRight);

	vec4 outline = ColorUp + ColorDown + ColorLeft + ColorRight;
	outline.rgb = OutlineColor.rgb;
	outline.a = min(outline.a,1);
	vec4 OriginalColor = texture(TEXTURE,UV);
	COLOR = mix(outline,OriginalColor,OriginalColor.a);
}