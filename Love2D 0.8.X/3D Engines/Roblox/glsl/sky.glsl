extern Image U;
extern Image R;
extern Image F;
extern Image L;
extern Image B;
extern Image D;

extern vec3 sun;
extern number fov;
extern vec2 vs;
extern vec4 q;

number pi=3.14159265359;
vec2 oxo=vec2(0.5,0.5);
vec3 qmul(vec4 q,vec3 v)//Quaternion rotated vector
{
	return v+cross(2*q.xyz,cross(q.xyz,v)+q.w*v);
}
vec3 s2w(vec2 s)//Screen to world
{
	return qmul(q,normalize(vec3(2*fov*(s-vs/2)/vs.y,-1)));
}
number inner=3;
number outer=9;
vec4 get_sun(vec3 d)
{
	number theta=180*acos(dot(d,sun))/pi;
	if(theta<=inner){
		return vec4(1);
	}
	if(theta<outer){
		return vec4(1,1,1,pow(1-(theta-inner)/(outer-inner),2));
	}
	return vec4(1,1,1,0);
}
vec4 mask(vec4 base,vec4 over)
{
	number t0=over.a;
	number t1=1-over.a;
	return vec4(over.rgb*t0+base.rgb*t1,t0+base.a*t1);
}
vec4 skybox(vec3 d)
{
	vec4 c;
	vec2 ux=d.yz/abs(d.x);
	if(abs(ux.x)<=1 && abs(ux.y)<=1){
		if(d.x>0){
			c=Texel(R,vec2(1+ux.y,1-ux.x)/2);
		}else{
			c=Texel(L,vec2(1-ux.y,1-ux.x)/2);
		}
	}
	vec2 uy=d.xz/abs(d.y);
	if(abs(uy.x)<=1 && abs(uy.y)<=1){
		if(d.y>0){
			c=Texel(U,vec2(1+uy.y,1+uy.x)/2);
		}else{
			c=Texel(D,vec2(1+uy.y,1-uy.x)/2);
		}
	}
	vec2 uz=d.xy/abs(d.z);
	if(abs(uz.x)<=1 && abs(uz.y)<=1){
		if(d.z>0){
			c=Texel(F,vec2(1-uz.x,1-uz.y)/2);
		}else{
			c=Texel(B,vec2(1+uz.x,1-uz.y)/2);
		}
	}
	return mask(c,get_sun(d));
}
vec4 effect(vec4 colour,Image UNUSED1,vec2 UNUSED2,vec2 s)
{
	//Helped me test what was going wrong GREATLY.
	return skybox(s2w(s));
}
