extern Image img;
extern vec3 n;
extern vec3 p0;
extern vec3 pp1;
extern vec3 pp2;
extern vec2 rep;

extern vec4 q;
extern vec3 p;
extern vec2 vs;
extern number fov;

vec3 qmul(vec4 q,vec3 v)//Quaternion rotated vector (q*v)
{
	return v-cross(2*q.xyz,q.w*v-cross(q.xyz,v));
}

vec4 mask(vec4 base,vec4 over)
{
	return vec4(over.rgb*over.a+base.rgb*(1-over.a),over.a+base.a*(1-over.a));
}

float plane(vec3 norm,vec3 rel,vec3 dir)
{
	return dot(rel,norm)/dot(dir,norm);
}

vec2 uv=vec2(1,1);
vec2 uv2=uv/2;
vec4 effect(vec4 colour,Image i_,vec2 _,vec2 s)
{
	//Pixel direction
	vec3 d=qmul(q,normalize(vec3(2*fov*(s-vs/2)/vs.y,-1)));

	//Point hit
	vec3 h=p-d*plane(n,p-p0,d);

	//Be efficient
	vec3 diff=h-p0;

	//Convert to 2d coordinates on image, and mask the colour with the texture's colour (Transparent textures will reveal the colour below)
	return mask(colour,Texel(img,mod(vec2(dot(pp1,diff),dot(pp2,diff))/rep+uv2,uv)));
}
