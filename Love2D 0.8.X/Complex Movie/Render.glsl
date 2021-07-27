//Complex numbers yay

extern number time;

extern vec2 window;
extern vec2 relsize;
extern vec2 outsize;

extern Image img;

/*//Ryan Errors
number sinh(number x)
	{return (exp(x)-exp(-x))/2;}
number cosh(number x)
	{return (exp(x)+exp(-x))/2;}
//*/

/**************************/
/* Complex Number Library */
/**************************/

//Why is there no pi defined in OpenGL!?
number pi=3.14159265358979;

//Accuracy for iterative functions
number acc=10000;

vec2 i=vec2(0,1);//Imaginary unit
vec2 one=vec2(1,0);//Real unit

//Absolute value of z
number Cabs(vec2 z)
{return length(z);}

//Argument of z
number Carg(vec2 z)
{return atan(z.y,z.x);}

//Polar to Cartesian coordinates (r*e^(i*phi))
vec2 rect(number r,number phi)
{return vec2(r*cos(phi),r*sin(phi));}
vec2 rect(vec2 z)
{return vec2(z.x*cos(z.y),z.x*sin(z.y));}

//Cartesian to polar coordinates
vec2 polar(number x,number y)
{return vec2(sqrt(x*x+y*y),atan(y,x));}
vec2 polar(vec2 z)
{return vec2(length(z),atan(z.y,z.x));}

//Multiplication
vec2 Cmul(vec2 a,vec2 b)
{return vec2(a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x);}

//Division
vec2 Cdiv(vec2 a,vec2 b)
{return vec2(a.x*b.x+a.y*b.y,b.x*a.y-a.x*b.y)/(b.x*b.x+b.y*b.y);}
vec2 Cdiv(number a,vec2 b)
{return a*vec2(b.x,-b.y)/(b.x*b.x+b.y*b.y);}

//Exponentiation
vec2 Cpow(vec2 a,vec2 b)
{
	vec2 r=polar(a);
	return rect(pow(r.x,b.x)*exp(-b.y*r.y),b.y*log(r.x)+b.x*r.y);
}
vec2 Cpow(number a,vec2 b)
{
	number rsq=a*a;
	number phi=step(0,-a)*pi;
	return rect(pow(rsq,b.x/2)*exp(-b.y*phi),b.y*log(rsq)/2+b.x*phi);
}
vec2 Cpow(vec2 a,number b)
{return rect(pow(a.x*a.x+a.y*a.y,b/2),b*atan(a.y,a.x));}
vec2 Csqrt(vec2 z)
{return rect(pow(z.x*z.x+z.y*z.y,0.25),atan(z.y,z.x)/2);}

//Natural logarithm
vec2 Cln(vec2 z)
{return vec2(log(z.x*z.x+z.y*z.y)/2,atan(z.y,z.x));}

//sin
vec2 Csin(vec2 z)
{return vec2(sin(z.x)*cosh(z.y),cos(z.x)*sinh(z.y));}
//asin
vec2 Casin(vec2 z)
{return vec2(pi/2,0)+Cmul(i,Cln(z+Cpow(Cmul(z,z)-one,vec2(0.5,0))));}
//sinh
vec2 Csinh(vec2 z)
{return vec2(cos(z.y)*sinh(z.x),sin(z.x)*cosh(z.y));}
//asinh
vec2 Casinh(vec2 z)
{return Cln(z+Csqrt(one+Cmul(z,z)));}

//cos
vec2 Ccos(vec2 z)
{return vec2(cos(z.x)*cosh(z.y),sin(z.x)*sinh(z.y));}
//acos
vec2 Cacos(vec2 z)
{return Cmul(-i,Cln(z+Csqrt(Cmul(z,z)-one)));}
//cosh
vec2 Ccosh(vec2 z)
{return vec2(cos(z.y)*cosh(z.x),sin(z.x)*sinh(z.y));}
//acosh
vec2 Cacosh(vec2 z)
{return 2*Cln(Csqrt(z-one)+Csqrt(z+one))-vec2(log(2.),0);}

//tan
vec2 Ctan(vec2 z)
{return vec2(sin(2*z.x),sinh(2*z.y))/(cos(2*z.x)+cosh(2*z.y));}
//atan
vec2 Catan(vec2 z)
{return vec2(atan(z.x,1-z.y)-atan(-z.x,1+z.y),(log(z.x*z.x+(z.y+1)*(z.y+1))-log(z.x*z.x+(z.y-1)*(z.y-1)))/2)/2;}
//atan2
vec2 Catan(vec2 y,vec2 x)
{
	if(y.x==0&&x.x==0&&y.y==0&&x.y==0){
		return vec2(0);
	}
	vec2 c3=vec2(y.x-x.y,y.y+x.x);
	vec2 c4=vec2(y.x*y.x-y.y*y.y+x.x*x.x-x.y*x.y,2*(y.x*y.y+x.x*x.y));
	return vec2(Carg(Cdiv(c3,Csqrt(c4))),log(Cabs(Cdiv(c3,Csqrt(c4)))));
}
//tanh
vec2 Ctanh(vec2 z)
{return vec2(sinh(2*z.x),sin(2*z.y))/(cos(2*z.x)+cosh(2*z.y));}
//atanh
vec2 Catanh(vec2 z)
{return (Cln(one+z)-Cln(one-z))/2;}

//Riemann zeta function
vec2 zeta(vec2 z)
{
	vec2 sum=vec2(0);
	for(int n=1;n<acc;n++){
		sum+=Cpow(n,z);
	}
	return sum;
}

//Factorial
vec2 fac(vec2 z)
{
	vec2 prod=one;
	for(number k=1;k<acc;k++){
		prod=Cmul(prod,Cdiv(Cpow(1+1/k,z),one+z/k));
	}
	return prod;
}
/*********************************/
/* End of Complex Number Library */
/*********************************/

//Use this function to try different transformations!
vec2 eq(vec2 z,number t){&EQ&}//swiftly replaced by the 'eq' variable on the Lua side


//Overlay a with b (looks like you put b infront of a)
vec4 mask(vec4 a,vec4 b)
{
	return fma(vec4(1-b.a),a,b);
	//return b+a*(1-b.a);
}
vec2 HALF=vec2(0.5);
vec4 effect(vec4 colour,Image _0,vec2 _1,vec2 pixel)
{
	vec2 pos=eq((pixel/outsize-HALF)*window,time)/(window*relsize)+HALF;
	vec2 pix=pos*outsize;
	vec4 idk=mask(colour,Texel(img,vec2(pos.x,1-pos.y)));
	if(pix.x<0||pix.y<0||pix.x>outsize.x||pix.y>outsize.y){
		return vec4(idk.rgb,idk.a*max(0,1-length(pix-clamp(pix,vec2(0),outsize))));
	}
	return idk;
}
