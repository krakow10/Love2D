//By Quaternions and AxisAngle
uniform mat2 View;
uniform vec3 pos;
uniform mat3 rot;
uniform vec3 color;
uniform int GraphicsMode=1;

uniform int nedge = 0;
uniform vec3 olist[128];
uniform vec3 dlist[128];

float[3] distls(vec3 a, vec3 b, vec3 c, vec3 d) {
	vec3 r = c - a;
	float bb = dot(b, b);
	float bd = dot(b, d);
	float br = dot(b, r);
	float dd = dot(d, d);
	float dr = dot(d, r);
	float div = bb*dd - bd*bd;
	float s = (dd*br - bd*dr)/div;
	float t = (bd*br - bb*dr)/div;
if (t < 0) {
		float s = br/bb;
		return float[3](length(r - s*b),s,0);
	} else if (t < 1) {
		return float[3](length(r - s*b + t*d),s,t);
	} else {
		float s = (bd + br)/bb;
		return float[3](length(r + d - s*b),s,1);
	}
}

float f(float x){
	return 1/(x*x);
}
float f1(float x){
	return inversesqrt(x);
}

float suminv(vec3 a, vec3 b) {
	float sum = 0;
	for (int i = 0; i < nedge; i++){
		float[3] info=distls(a, b, olist[i], dlist[i]);
		if(info[1]>0)
			sum += f(info[0]);
	}
	return f1(sum);
}

float boring(vec3 a, vec3 b) {
	float dis = 1.0/0.0;
	for (int i = 0; i < nedge; i++){
		float[3] info=distls(a, b, olist[i], dlist[i]);
		if(info[0]<dis&&0<info[1])
			dis=info[0];
	}
	return dis;
}

vec3 transform(vec2 dir) {
	float c = 2/(1 + dot(dir,dir));
	return vec3(c*dir, c - 1);
}

vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	vec3 dir;
	if(GraphicsMode==1)
		dir=rot*normalize(vec3(pixel.x-View[0].x,View[1].y-View[0].y-pixel.y,View[1].y)-vec3(View[1]/2,0));//Direction of pixel
	else if(GraphicsMode==2)
		dir=rot*transform((vec2(pixel.x-View[0].x,View[1].y-View[0].y-pixel.y)-View[1]/2)/View[1].y);
	//*
	float edgesum = boring(pos, dir);
	if (edgesum < 0.03f)
		return vec4(color, 1);
	return vec4(0,0,0,0);
	//*/
	//return vec4(color,max(0,1-10*suminv(pos,dir)));
}