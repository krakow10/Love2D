//By xXxMoNkEyMaNxXx

extern vec2 vs;
extern mat2 View;

extern Image Sky;
extern Image Tile;//Texture for the bottom of the pool

extern number depth;//Distance to pool

//Get a colour from either the pool or the sky
vec4 getColour(vec3 Origin,vec3 Direction){
	vec2 Du=(Origin.xy-Origin.z/Direction.z*Direction.xy)/View[1];
	if(Direction.z>=0.0||Du.x<0.0||Du.x>1.0||Du.y<0.0||Du.y>1.0)
		return Texel(Sky,0.5*Direction.xy/(Direction.z-1)*vec2(vs.y/vs.x,1)+vec2(0.5));
	else
		return Texel(Tile,Du);
}

//Position, Incident, Normal, nt/ni
vec4 fresnel(vec3 P,vec3 I,vec3 N,number eta)
{
	number dNI=dot(N,I);//Compute once, use 5x
	vec3 R=I-2.0*dNI*N;//Reflected direction
	vec3 T=vec3(0.0);//Transmitted direction
	number k=1.0-eta*eta*(1.0-dNI*dNI);//Yolo
	if(k>=0.0)
		T=eta*I-(eta*dNI+sqrt(k))*N;//Swag

	number mag=dot(N,T)/dNI;//Magnification
	vec2 cd=vec2(1+mag*eta,mag+eta);//Common divisor
	vec2 r=vec2(1-mag*eta,mag-eta)/cd;//Reflected (S,P)
	vec2 t=vec2(2)/cd;//Transmitted (S,P)

	vec4 Colour_R=(r.x*r.x+r.y*r.y)*getColour(P,R);
	if(k<0.0)
		return Colour_R;
	else
		return Colour_R+mag*eta*(t.x*t.x+t.y*t.y)*getColour(P,T);//Colour_T
	//Look maa, no trig! (Trig is a lie BTW.)
}

number height(vec4 data)
{
	return 255.0*data.r+data.g;
}

vec4 effect(vec4 _0,Image hMap,vec2 percent,vec2 ipixel)
{
	vec2 pixel=vec2(ipixel.x,vs.y-ipixel.y)-View[0];
	//This part is violently incorrect for simplicity.
	vec3 Eye=vec3(View[1]/2,depth);
	vec3 Point=vec3(pixel,height(Texel(hMap,percent)));
	vec3 dx=vec3(2,0,height(Texel(hMap,percent+vec2(1,0)/vs))-height(Texel(hMap,percent-vec2(1,0)/vs)));
	vec3 dy=vec3(0,2,height(Texel(hMap,percent+vec2(0,1)/vs))-height(Texel(hMap,percent-vec2(0,1)/vs)));
	return fresnel(Point,normalize(Point-Eye),normalize(cross(dx,dy)),1.333/1.000277);
}
