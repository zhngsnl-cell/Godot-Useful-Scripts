shader_type canvas_item;

#define PI 3.1415926

mat4 buildTranslate(float tx,float ty,float tz){
	return mat4(
		vec4(1.0,0.0,0.0,0.0),
		vec4(0.0,1.0,0.0,0.0),
		vec4(0.0,0.0,1.0,0.0),
		vec4(tx,ty,tz,1.0)
	);
}

mat4 buildRotateX(float angle){
	return mat4(
		vec4(1.0,0.0,0.0,0.0),
		vec4(0.0,cos(angle),sin(angle),0.0),
		vec4(0.0,-sin(angle),cos(angle),0.0),
		vec4(0.0,0.0,0.0,1.0)
	);
}

mat4 buildRotateY(float angle){
	return mat4(
		vec4(cos(angle),0.0,sin(angle),0.0),
		vec4(0.0,1.0,0.0,0.0),
		vec4(-sin(angle),0.0,cos(angle),0.0),
		vec4(0.0,0.0,0.0,1.0)
	);
}

mat4 buildRotateZ(float angle){
	return mat4(
		vec4(cos(angle),sin(angle),0.0,0.0),
		vec4(-sin(angle),cos(angle),0.0,0.0),
		vec4(0.0,0.0,0.0,1.0),
		vec4(0.0,0.0,0.0,1.0)
	);
}

mat4 buildScale(float x,float y,float z){
	return mat4(
		vec4(x,0.0,0.0,0.0),
		vec4(0.0,y,0.0,0.0),
		vec4(0.0,0.0,z,0.0),
		vec4(0.0,0.0,0.0,1.0)
	);
}

float Band(float v,float start, float end){
	float up = step(start, v);
	float down =1.0 - step(end, v);
	return up*down;
}

float Rect(vec2 uv, float x1, float x2, float y1, float y2){
	float x = Band(uv.x, x1, x2);
	float y = Band(uv.y, y1, y2);
	return x*y;
}

float Circle(vec2 uv, vec2 o, float r,float blur){
	return smoothstep(r,r-blur,distance(uv,o));
}

float Circle2(vec2 uv, vec2 o, float r){
	float rdistance = length(uv - o);
	return 1.0 - step(r,rdistance);
}

float Circle3(vec2 uv, vec2 o, float r){
	vec2 rdistance = uv - o;
	return 1.0-step(r,dot(rdistance,rdistance)*4.0);
}

float SawCircle(vec2 uv,vec2 o,float r){
	return step(r,distance(uv,o));
}

float ETface(vec2 uv, vec2 o_main,vec2 o_1,vec2 o_2){
	float main = Circle(uv,o_main,0.4,0.01);
	main -= Circle(uv,o_1,0.2,0.01);
	main -= Circle(uv,o_2,0.2,0.01);
	return main;
}

float Remap01(float a,float b,float t){
	return (t-a)/(b-a);
}
float Remap(float a,float b,float c,float d,float t){
	return Remap01(a,b,t)*(d-c) + c;
}//将ab线性映射到cd，其中t是某个ab中的值，结果将输出为cd中的某个值

mat2 Rotate2D(float angle){
	return mat2(
		vec2(cos(angle),sin(angle)),
		vec2(-sin(angle),cos(angle))
	);
}

mat2 Scale(float scale){
	return mat2(vec2(scale,0.0),vec2(0.0,scale));
}

float Noise(vec2 p){
	return fract(sin(dot(p,vec2(12.1564,78.1356))*50.5));
}

float Box(vec2 st,vec2 size){
	size = vec2(0.5) - size*0.5;
	vec2 uv = smoothstep(size,size + vec2(0.001),st);
	uv *= smoothstep(size,size + vec2(0.001),vec2(1.0) - st);
	return uv.x * uv.y;
}
float Cross(vec2 st,float size){
	return Box(st,vec2(size,size/4.0)) + Box(st,vec2(size/4.0,size));
}

vec2 SelfRotate(vec2 uv,float angle){
	uv -= vec2(0.5);
	uv = Rotate2D(angle) * uv;
	uv += vec2(0.5);
	return uv;
}

vec2 Tile(vec2 uv,float zoom){
	uv = uv * zoom;
	uv = fract(uv);
	return uv;
}

vec2 BrickTile(vec2 uv, float zoom){
	uv *= zoom;
	uv.x += step(1.0,mod(uv.y,2.0)) * 0.5;
	uv = fract(uv);
	return uv;
}

vec2 RotateBrickTile(vec2 uv){
	uv *= 2.0;
	float index = 0.0;
	index += step(1.0,mod(uv.x,2.0));
	index += step(1.0,mod(uv.y,2.0))*2.0;
	uv = fract(uv);
	if (index == 1.0){
		uv = SelfRotate(uv,PI*0.5);
	}
	else if (index == 2.0){
		uv = SelfRotate(uv,PI);
	}
	else if (index == 3.0){
		uv = SelfRotate(uv,PI*1.5);
	}
	return uv;
}

float Random(vec2 uv){
	return fract(sin(dot(uv,vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 Truchet(vec2 uv,float index){
	index = fract((index - 0.5) * 2.0);
	if (index > 0.75){
		uv = vec2(1.0) - uv;
	}
	if (index> 0.5){
		uv = vec2(1.0 - uv.x,uv.y);
	}
	if (index > 0.25){
		uv = vec2(1.0) - vec2(1.0 - uv.x,uv.y);
	}
	return uv;
}

float Random2(float x){
	return fract(sin(x * 12.9898) * 43758.5453123);
}
float Noise2(float x){
	float i = floor(x);
	float f = fract(x);
	//float u = f*f*(3.0 - 2.0*f);
	float y = mix(Random2(i),Random2(i + 1.0),smoothstep(0.0,1.0,f));
	return y;
}
float Noise3(vec2 uv){
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	float a = Random(i);
	float b = Random(i + vec2(1.0,0.0));
	float c = Random(i + vec2(0.0,1.0));
	float d = Random(i + vec2(1.0,1.0));
	vec2 u = f*f*(3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;

	vec3 color = vec3(0.0);

	vec2 pos = vec2(uv * 100.0);

	if(uv.y < 0.5){
		color = vec3(0.0,1.0,1.0);
	}

	//float n = Noise3(pos);
	//color = vec3(n);

	//雪花屏效果
	//color = vec3(Circle(uv,vec2(Random(uv * TIME),Random(uv * TIME)),Random2(uv.x * TIME),0.001));
	//color = vec3(Rect(uv,Noise2(uv.x * TIME),Noise2(uv.x*2.0),Noise2(uv.y * TIME),0.9));

	//uv = uv * 10.0;
	//vec2 ipos = floor(uv);
	//vec2 fpos = fract(uv);
	//vec2 tile = Truchet(fpos,Random(ipos));
	//float color = 0.0;
	//color = smoothstep(tile.x - 0.3,tile.x,tile.y) - smoothstep(tile.x,tile.x + 0.3,tile.y);

	//uv = uv *10.0;
	//vec2 ipos = floor(uv);
	//vec2 fpos = fract(uv);
	//color = vec3(Random(ipos));
	//color = vec3(Random(uv));

	//uv = Tile(uv,10.0);
	//uv = RotateBrickTile(uv);
	//color = vec3(step(uv.x,uv.y));

	COLOR = vec4(vec3(color),1.0);

	//uv *= vec2(0.5,1.0)/0.5;//砖块效果
	//uv = BrickTile(uv, 5.0);
	//color = vec3(Rect(uv,0.1,0.9,0.1,0.9));
	//color = vec3(uv,0.0);

	//uv = Tile(uv,4.0);
	//uv = SelfRotate(uv,PI/4.0);
	//color = vec3(Rect(uv,0.2,0.8,0.2,0.8));

	//uv = uv * 3.0;
	//uv = fract(uv);
	//color = vec3(uv,0.0);
	//color = vec3(Circle(uv,vec2(0.5,0.5),0.45,0.001));


	//uv -= vec2(0.5);
	//uv = Rotate2D(sin(TIME) * PI * 0.5) * uv;
	//uv *= Scale(sin(TIME)*2.0);
	//uv += vec2(cos(TIME),sin(TIME)) * 0.5;
	//uv += vec2(0.5);
	//color = vec3(uv.x,uv.y,0.0);
	//color = vec3(Cross(uv,0.4));


	//vec2 rotate = vec2(-sin(TIME),cos(TIME));
	//uv += rotate * 0.35;
	//color += vec3(Cross(uv,0.25));
	//COLOR = vec4(color,1.0);

	//极坐标生成正多边形
	//int N = 3;
	//uv = uv * 2.0 - 1.0;
	//float d = 0.0;
	//float angle = atan(uv.x,uv.y) + PI;
	//float r = PI * 2.0 / float(N);
	//d = cos(floor(0.5 + angle/r) * r - angle) * length(uv);
	//color = vec3(1.0 - smoothstep(0.4,0.41,d));

	//极坐标
	//vec2 pos = uv - vec2(0.5,0.5);
	//float angle = atan(pos.y,pos.x) + TIME;
	//float f = cos(angle * 3.0);
	//float r = length(pos) * 2.0;
	//color = 1.0 - smoothstep(f, f+0.02, r);

	//float d = 0.0;
	//d = length(abs(uv) - 0.3);
	//COLOR = vec4(vec3(fract(d * 10.0)),1.0);

	//COLOR = vec4(vec3(Circle(uv,vec2(0.5,0.5),0.3,0.01)),1.0);

	//COLOR.a = 1.0 - COLOR.a;

	//COLOR = vec4(vec3(Circle3(uv,vec2(0.5,0.5),0.5)),1.0);

	//COLOR = vec4(vec3(Circle2(uv,vec2(0.5,0.5),0.3)),1.0);

	//COLOR = vec4(vec3(floor(uv.x*2.0)),1.0);

	//uv = fract(uv * 5.0);//网格化

	//COLOR = vec4(vec3(Noise(vec2(1.0561,1.1631))),1.0);

	//uv = uv*2.0 - 1.0;//将原点移动到中心，注意uv的取值范围也会变化

	//float angle = atan(uv.y,uv.x);

	//uv = Rotate2D(PI/6.0) * uv;
	//COLOR = vec4(vec3(Rect(uv,-0.5,0.5,-0.5,0.5)),1.0);

	//angle = Remap(-PI,PI,0.0,1.0,angle);
	//COLOR = vec4(vec3(angle),1.0);

	//COLOR = vec4(vec3(ETface(uv,vec2(0.5,0.5),vec2(0.2,0.6),vec2(0.8,0.6))),1.0);
	//COLOR = vec4(vec3(Band(uv.x,0.1,0.9)),1.0);
	//COLOR = vec4(vec3(Rect(uv,0.1,0.9,0.1,0.9)),1.0);
	//COLOR = vec4(vec3(Circle(uv,vec2(0.5,0.5),0.2,0.01)),1.0);
	//COLOR = vec4(vec3(SawCircle(uv,vec2(0.5,0.5),0.3)),1.0);
}
