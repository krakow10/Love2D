//Complex numbers yay

extern number maxi;
extern vec2 window;

number pi=3.14159265358979;

/*/_
vec2 C_(vec2 a,vec2 b)
{

}
//*/

vec2 HALF=vec2(0.5);

number Cabs(vec2 z)
{
	return sqrt(z.x*z.x+z.y*z.y);
}

number Carg(vec2 z)
{
	return atan(z.y,z.x);
}

vec2 rect(number r,number phi)
{
	return vec2(r*cos(phi),r*sin(phi));
}

//Multiplication
vec2 Cmul(vec2 a,vec2 b)
{
	return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);
}

//Division
vec2 Cdiv(vec2 a,vec2 b)
{
	number rsq=b.x*b.x+b.y*b.y;
	return vec2((a.x*b.x+a.y*b.y)/rsq,(b.x*a.y-a.x*b.y)/rsq);
}

//Exponentiation
vec2 Cpow(vec2 a,vec2 b)
{
	number rsq=a.x*a.x+a.y*a.y;
	number phi=atan(a.y,a.x);
	return rect(pow(rsq,b.x/2)*exp(-b.y*phi),b.y*log(rsq)/2+b.x*phi);
}

vec2 Cln(vec2 z)
{
	return vec2(log(z.x*z.x+z.y*z.y)/2,atan(z.y,z.x));
}

vec2 Ccos(vec2 z)
{
	return vec2(cos(z.x)*cosh(z.y),sin(z.x)*sinh(z.y));
}

vec2 Cacos(vec2 z)
{
	return Cmul(vec2(0,1),Cln(z+Cpow(Cmul(z,z)-vec2(1,0),vec2(0.5,0))));
}

vec2 zeta(vec2 z)
{
	vec2 sum=vec2(0);
	for(int n=1;n<250;n++){
		sum+=Cpow(vec2(n,0),z);
	}
	return sum;
}

number acc=500.;
vec2 fac(vec2 z)
{
	vec2 sum=vec2(0);
	for(number t=0;t<=1;t+=1./acc){
		sum+=Cpow(vec2(-log(t),0),z);
	}
	return sum/acc;
}
//*/
vec2 eq(vec2 z)
{
	return Cpow(z,vec2(z.y,z.x));
	//return Cpow(z,Cmul(z,vec2(0,1)));
	//return fac(z);
}

vec4 RGBA(number mag,number hue)
{
	vec3 temp=vec3(cos(hue),cos(hue+pi/3),cos(hue+pi*2/3));
	return vec4(pow(temp*temp,vec3(mag/2)),pow(2,-abs(log(mag/10)/3)));//0.1*mag/(2*sqrt(1+0.01*mag*mag))+0.5);
}

vec4 mask(vec4 base,vec4 over)
{
	number t0=over.a;
	number t1=1-over.a;
	return vec4(over.rgb*t0+base.rgb*t1,t0+base.a*t1);
}

vec4 effect(vec4 colour,Image img,vec2 percent,vec2 pixel)
{
	vec2 pos=eq((percent-HALF)*window);
	vec4 wheel=RGBA(Cabs(pos),Carg(pos));
	vec2 final=pos/window+HALF;
	if(final.x>=0&&final.y>=0&&final.x<=1&&final.y<=1){
		return mask(Texel(img,final),wheel);
	}
	return mask(Texel(img,mod(log(final-max(vec2(0),min(vec2(1),final))),vec2(1))),wheel);
}
