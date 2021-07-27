/*
number G=6.67398e-11;
number c=299792458;
number M=1.9891e30;
D=GM/c^2
*/
number D=5908.266870476583499589315379243;

number tau=6.283185307179586476925286766559;

extern vec2 vs;
extern number Ms;
extern Image sky;
extern vec3 pos;
extern vec3 mx;
extern vec3 my;
extern vec3 mz;

vec2 uv(vec3 dir)
{
	return vec2(mod(atan(dir.z,dir.x)/tau,1),0.5+2*asin(dir.y)/tau);
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 ipixel)
{
	vec2 pixel=vec2(ipixel.x,vs.y-ipixel.y);
	vec3 local=normalize(vec3((pixel-vs/2)/vs.y,1));
	vec3 dir=local.x*mx+local.y*my+local.z*mz;

	vec3 par=dot(pos,dir)*dir-pos;
	number ang=Ms*D/length(pos);//Schwarzchild radius 'n' stoof?
	if(ang<tau){
		return Texel(sky,uv(dir*cos(ang)+normalize(par)*sin(ang)));
	}
	return vec4(0,0,0,1);
}
