//By xXxMoNkEyMaNxXx

number pi=3.1415926535898;

//Rolloff to black
number pwr=2;

//Max number of iterations (Per pixel!)
extern number maxi;
extern number limit;

//Screen Size
extern vec2 vs;

//Area being rendered on screen
extern vec2 spot;
extern vec2 size;

//Area of fractal being rendered
extern vec2 pos;
extern vec2 view;

//*
vec3 RGB(number hue)
{
	vec3 temp=vec3(cos(hue*pi),cos((hue+1./3.)*pi),cos((hue+2./3.)*pi));
	return temp*temp;
}
vec4 RGBA(number w)
{
	number mA=pow(maxi,pwr);
	return vec4(RGB(pow(w/maxi,1./4.))*((pow(w,pwr)-mA)/(1-mA)),1);
}
/*/
vec4 RGBA(number mag,number hue)
{
	vec3 temp=vec3(cos(hue),cos(hue+pi/3),cos(hue+pi*2/3));
	return vec4(pow(temp*temp,vec3(mag/2)),pow(2,-abs(log(mag/10)/3)));//0.1*mag/(2*sqrt(1+0.01*mag*mag))+0.5);
}
//*/


bool check(vec2 point)
{
	highp number p=(point.x-0.25)*(point.x-0.25)+point.y*point.y;
	return point.x<sqrt(p)-2*p+0.25 || (point.x+1)*(point.x+1)+point.y*point.y<0.0625;

}

//BAM complex numbers
//Modulus
number Cabs(vec2 z)
{
	return sqrt(z.x*z.x+z.y*z.y);
}

//Argument
number Carg(vec2 z)
{
	return atan(z.y,z.x);
}

//rtheta -> xy
vec2 rect(number r,number phi)
{
	return r*vec2(cos(phi),sin(phi));
}

//Multiplication
vec2 Cmul(vec2 a,vec2 b)
{
	return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);
}

//Division
vec2 Cdiv(vec2 a,vec2 b)
{
	return vec2(a.x*b.x+a.y*b.y,b.x*a.y-a.x*b.y)/(b.x*b.x+b.y*b.y);
}

//Exponentiation
vec2 Cpow(vec2 a,vec2 b)
{
	highp number rsq=a.x*a.x+a.y*a.y;
	highp number phi=atan(a.y,a.x);
	return rect(pow(rsq,b.x/2)/exp(b.y*phi),b.y*log(rsq)/2+b.x*phi);
}

//Natural log
vec2 Cln(vec2 z)
{
	return vec2(log(z.x*z.x+z.y*z.y)/2,atan(z.y,z.x));
}
//End of BAM complex

vec2 iterate(vec2 z,vec2 c)
{
	return Cpow(z,vec2(2,0))+c;//Mandelbrot
	//return Cpow(c,z);//RhysRyanbrot
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 ipixel)
{
	//Relative point
	vec2 pixel=vec2(ipixel.x,vs.y-ipixel.y);
	highp vec2 point=pos+view*(pixel-spot)/size;

	int i=0;
	highp vec2 z=point;
	//if(!check(point)){
		while(z.x*z.x+z.y*z.y<limit && i<maxi){
			z=iterate(z,point);
			i++;
		}
		if(i<maxi){
			return RGBA(i);
		}
	//}
	return vec4(0,0,0,1);
}
