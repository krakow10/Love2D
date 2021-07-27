/*
local function fresnel(n1,n2,i)
	if n1>n2 and si>n2/n1 then
		return 1
	else
		local sq2=sqrt(1+(i^2-1)*(n1/n2)^2)
		local n1s,n2s=n1*sq2,n2*sq2
		local n1c,n2c=n1*i,n2*i
		return ((n1c-n2s)/(n1c+n2s))^2,((n1s-n2c)/(n1s+n2c))^2
	end
end
*/
//extern Image ZIndex;

extern Image img;
extern vec3 n;
extern vec3 p0;
extern vec3 pp1;
extern vec3 pp2;

extern vec3 sun;
extern vec3 ambient;

extern vec4 q;
extern vec3 p;
extern vec2 vs;
extern number fov;
number pi=3.14159265359;
vec3 qmul(vec4 q,vec3 v)//Quaternion rotated vector
{
	return v+cross(2*q.xyz,cross(q.xyz,v)+q.w*v);
}
number inner=1;
number outer=20;
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
float plane(vec3 norm,vec3 rel,vec3 dir)
{
	return dot(rel,norm)/dot(dir,norm);
}
/*
float fromZI(vec2 p)
{
	vec4
}
*/
vec4 effect(vec4 colour,Image i_,vec2 _,vec2 s)
{
	//Pixel direction
	vec3 d=qmul(q,normalize(vec3(2*fov*(s-vs/2)/vs.y,-1)));

	number Z=plane(n,p-p0,d);
	//if(Z< ZIndexing :U
	//Point hit
	vec3 h=p-d*Z;

	//Be efficient
	vec3 diff=h-p0;

	//Convert to 2d coordinates on image, and mask the part's colour with the texture's colour
	vec4 tex=mask(colour,Texel(img,vec2(dot(pp1,diff)/pow(length(pp1),2)+1,dot(pp2,diff)/pow(length(pp2),2)+1)/2));

	//Be awesome
	vec3 rfl=reflect(d,n);
	//vec3 rfr=refract(d,n,1.4); Not yet c:

	//Percent of sunlight
	number light=max(dot(n,sun),0);

	//GET THE SUN
	vec4 suncolour=get_sun(rfl);

	//vec3(pow(1-acos(dot(rfl,sun))/pi,20))
	return vec4(tex.rgb*light+tex.rgb*ambient+suncolour.rgb*suncolour.a,tex.a);
}



//(1-pow(acos(dot(rfl,sun))/pi,2))
//sqrt(1-pow(dot(d,n),2))
//vec4((1-acos(dot(rfl,sun))/pi)*sqrt(1-pow(dot(d,n),2)))
//sky.skybox(rfl)
