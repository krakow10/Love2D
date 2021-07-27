//By xXxMoNkEyMaNxXx
extern mat2 View;
extern vec3 pos;
extern mat3 rot;

extern Image ground;

extern number maxd;

const number sensitivity=0.5;//"Exposure"
const number t=0.75;//Percent of light that gets through fog per metre
const int numLights=4;
vec3 Lr[numLights]=vec3[](vec3(0,1,10),vec3(10,3,0),vec3(0,10,0),vec3(-5,2,-5));//Location of lights
vec3 Li[numLights]=vec3[](vec3(1,1,1),vec3(1,0,0),vec3(0,1,0),vec3(0,0,1));//Intensity of lights

vec4 lambda_R(vec3 x){
	return Texel(ground,mod(x.xz,1));
}

number Gamma_T(vec3 a,vec3 b){//definite product integral of lambda_T(p) from p=a to p=b.
	return pow(t,distance(a,b));//woo
}
number Gamma_T(number d){//Same thing, but d is distance(a,b).
	return pow(t,d);
}

number Ei(number x){
	/*
	if(x>-3.76739)//Gets gross back there
		return 0.57721566490153286060651209+log(abs(x))+x*(1+x*(1/4.+x*(1/18.+x*(1/96.+x*(1/600.+x*(1/4320.+x*(1/35280.+x*(1/322560.+x*(1/3265920.+x*(1/36288000.+x/439084800.))))))))));
	else
		return exp(x)/x;
	/*/
	//Oh yes. Much better. Thanks Ramanujan!!
	number t=1-0.25*x,p=1,s=1,n=0,x2=0.5*x,xx=x*x;
	number lt=t;
	while(n<32&&(lt!=t||x2!=n+2)){
		n+=2;
		s+=1/(n+1);
		p*=xx/(4*n*(n+1));
		lt=t;
		t+=p*s*(1-x2/(n+2));
	}
	return 0.57721566490153286060651209+0.5*log(xx)+x*exp(x2)*t;
	//*/
}

number Intensity(number a,number b,number s0,number s1){
	number lt=log(t),b2=b*b,s0a=s0-a,s1a=s1-a;
	number s0a2=s0a*s0a,s1a2=s1a*s1a;
	number s0l=sqrt(s0a2+b2),s1l=sqrt(s1a2+b2);
	return 0.5*(b2*lt*exp(lt*a)*(Ei(lt*(s1a+s1l))-Ei(lt*(s0a+s0l)))+exp(lt*(s1+s1l))*(1/lt+s1a-s1l)-exp(lt*(s0+s0l))*(1/lt+s0a-s0l));
}
number Intensity(number a,number b,number s){
	number lt=log(t),b2=b*b,sa=s-a;
	number sa2=sa*sa;
	number sl=sqrt(sa2+b2);
	return -0.5*(b2*lt*exp(lt*a)*Ei(lt*(sa+sl))+exp(lt*(s+sl))*(1/lt+sa-sl));
}

vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	vec3 dir=rot*normalize(vec3(pixel.x-View[0].x,View[1].y-View[0].y-pixel.y,View[1].y)-vec3(View[1]/2,0));//Direction of pixel
	number sPlane=-pos.y/dir.y;//distance to the surface

	//Go integrals!
	if(dir.y<0&&sPlane<maxd){
		vec3 If=vec3(0),Is=vec3(0),hit=pos+dir*sPlane;//Intensity from fog, Intensity from sPlane
		for(int l=0;l<numLights;++l){
			number a=dot(dir,Lr[l]-pos);
			number b=distance(pos+dir*a,Lr[l]);//length(cross(dir,Lr[l]-pos));
			If+=Li[l]*Intensity(a,b,0,sPlane);
			Is+=Li[l]*Gamma_T(hit,Lr[l]);
		}
		vec4 c=lambda_R(hit);//Colour of object hit (ground in this case)
		number x_T=Gamma_T(sPlane);
		return vec4(sensitivity*(If+x_T*Is*c.rgb),1+x_T*(c.a-1));
	}else{
		vec3 If=vec3(0);
		for(int l=0;l<numLights;++l)
			If+=Li[l]*Intensity(dot(dir,Lr[l]-pos),length(cross(dir,Lr[l]-pos)),0);
		return vec4(sensitivity*If,1);
	}
}
