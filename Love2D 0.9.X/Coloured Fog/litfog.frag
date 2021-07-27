//By xXxMoNkEyMaNxXx
extern mat2 View;
extern vec3 pos;
extern mat3 rot;

extern Image ground;

extern number maxd;
extern number dx;

const number sensitivity=1;//"Exposure"
const number t=0.75;//Percent of light that gets through fog per metre
const int numLights=4;
const vec3 Lr[numLights]=vec3[](vec3(0,1,10),vec3(10,3,0),vec3(0,10,0),vec3(-5,2,-5));//Location of lights
const vec3 Li[numLights]=vec3[](vec3(1,1,1),vec3(1,0,0),vec3(0,1,0),vec3(0,0,1));//Intensity of lights

vec4 lambda_R(vec3 x){
	return Texel(ground,mod(x.xz,1));
}

number Gamma_T(vec3 a,vec3 b){//definite product integral of lambda_T(p) from p=a to p=b.
	return pow(t,distance(a,b));//woo
}
number Gamma_T(number d){//Same thing, but d is distance(a,b).
	return pow(t,d);
}

vec3 IL(vec3 p){//Intensity of light at p from all lights
	vec3 I=vec3(0);
	for(int l=0;l<numLights;++l)
		I+=Li[l]*Gamma_T(Lr[l],p);//*sqrt(1-dot(dir,p-Lr[l])*dot(dir,p-Lr[l])/(dot(dir,dir)*dot(p-Lr[l],p-Lr[l])))*1.570796326794896
	return I;
}

vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	vec3 dir=rot*normalize(vec3(pixel.x-View[0].x,pixel.y-View[0].y,View[1].y)-vec3(View[1]/2,0));//Direction of pixel
	number sPlane=-pos.y/dir.y;//distance to the surface
	vec3 I=vec3(0);//Total Intensity of red, green, blue.
	number s=0;
	while(true){
		vec3 p=pos+s*dir;
		I+=Gamma_T(s)*IL(p)*dx;
		if(s>sPlane&&(pos.y>0&&dir.y<0||pos.y<0&&dir.y>0)){
			vec3 x=pos+dir*sPlane;
			number x_T=Gamma_T(sPlane);
			vec4 tColour=lambda_R(x);
			return vec4(sensitivity*(-log(t)*I+x_T*tColour.rgb*IL(x)*tColour.a),1+x_T*(tColour.a-1));
		}else if(s>maxd)
			return vec4(sensitivity*-log(t)*I,1-Gamma_T(s));
		else
			s+=dx;
	}
}
