//By Quaternions and AxisAngle
uniform mat2 View;
uniform vec3 pos;
uniform mat3 rot;
uniform vec3 color;
uniform int GraphicsMode=1;

uniform int nmesh=0;
uniform vec3 nlist[128];
uniform float llist[128];

vec2 cpmcast(vec3 o,vec3 d){
	float t0=-1.0/0.0;
	float t1=1.0/0.0;
	for(int i=0;i<nmesh;i++){
		float nd=dot(nlist[i],d);
		float no=dot(nlist[i],o);
		float t=(llist[i]-no)/nd;
		if(nd<-1e-6){
			t0=max(t0,t);
		}else if(nd<1e-8){
			if(llist[i]<no)
				return vec2(1.0/0.0,-1.0/0.0);
		}else{
			t1=min(t1,t);
		}
	}
	return vec2(t0,t1);
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
	vec2 t=cpmcast(pos,dir);
	if(max(t.x, 0)<t.y){
		return vec4(color,1-pow(0.5,t.y-max(0,t.x)));
	}
	return vec4(0,0,0,0);
}