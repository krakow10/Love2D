//By xXxMoNkEyMaNxXx
extern number Zoom;
extern vec4 Window;

extern vec4 Offset;
extern mat4 Matrix;

extern vec4 CameraOffset;
extern mat4 CameraMatrix;

extern Image Textures;
extern Image Map;
extern Image Vertices;
extern Image Pairs;
extern Image Prisms;

extern number NPrisms;
extern number Row;
extern number Set;

/*************** Lol, it'll be a degree three polynomial. ********************\
R=O+D*r
VAT=AtT(VA0,VA1,R.w)
VBT=AtT(VB0,VB1,R.w)
VCT=AtT(VC0,VC1,R.w)
dot(R,cross(VBT-VAT,VCT-VAT))=0
dot(R,cross(VB0.xyz+(VB1-VB0).xyz*(R.w-VB0.w)/(VB1.w-VB0.w)-VA0.xyz+(VA1-VA0).xyz*(R.w-VA0.w)/(VA1.w-VA0.w),VC0.xyz+(VC1-VC0).xyz*(R.w-VC0.w)/(VC1.w-VC0.w)-VA0.xyz+(VA1-VA0).xyz*(R.w-VA0.w)/(VA1.w-VA0.w)))=0

AtT(V0,V1,T)=V0.xyz+(V1-V0).xyz*(T-V0.w)/(V1.w-V0.w)

VA0.xyz+(VA1-VA0).xyz*(R.w-VA0.w)/(VA1.w-VA0.w)
VB0.xyz+(VB1-VB0).xyz*(R.w-VB0.w)/(VB1.w-VB0.w)
VC0.xyz+(VC1-VC0).xyz*(R.w-VC0.w)/(VC1.w-VC0.w)
\*****************************************************************************/

//*//Ryan Errors
number sinh(number x)
	{return (exp(x)-exp(-x))/2;}
number cosh(number x)
	{return (exp(x)+exp(-x))/2;}
//*//

/**************************/
/* Complex Number Library */
/**************************/

//Why is there no pi defined in OpenGL!?
number pi=3.14159265358979;

//Accuracy for iterative functions
number acc=1e-6;

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

/*********************************/
/* End of Complex Number Library */
/*********************************/

number AtT(number w0,number w1,number T)
{
	return (T-w0)/(w1-w0);
}

vec4 PixelDirection(vec2 upos)
{
	return CameraMatrix*normalize(vec4(upos-vec2(0.5),Zoom,0));
}

number mix2(number Origin,number Target1,number Target2,vec2 Blend)
{
	return Origin+(Target1-Origin)*Blend.x+(Target2-Origin)*Blend.y;
}

vec4 mask(vec4 A,vec4 B)
{
	return vec4(mix(B.rgb,A.rgb,B.a),B.a+A.a*(1-B.a));
}

const int maxI=16;//Why would you want to look through more than 16 objects...
const vec2 e0=vec2(1,-pow(3.0,0.5))/2;
const vec2 e1=vec2(1,pow(3.0,0.5))/2;

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	vec4 Ray=PixelDirection((pixel-Window.xy+vec2(0.5*(Window.w-Window.z),0))/Window.w);
	int items=0;
	number worst=2147483647;
	number ZI[maxI]={2147483647};
	vec4[maxI] colours;

	for(number i=0;i<NPrisms;++i){
		vec4 prism=Texel(Prisms,vec2(i/NPrisms,Set));

		vec4 PA=Texel(Pairs,vec2(prism.r,Row));
		vec4 PB=Texel(Pairs,vec2(prism.g,Row));
		vec4 PC=Texel(Pairs,vec2(prism.b,Row));

		vec4 VA0=Offset+Matrix*Texel(Vertices,PA.rg);
		vec4 VA1=Offset+Matrix*Texel(Vertices,PA.ba);
		vec4 VB0=Offset+Matrix*Texel(Vertices,PB.rg);
		vec4 VB1=Offset+Matrix*Texel(Vertices,PB.ba);
		vec4 VC0=Offset+Matrix*Texel(Vertices,PC.rg);
		vec4 VC1=Offset+Matrix*Texel(Vertices,PC.ba);

		//This. Code. Sucks. And. Was. Hard. To. Make.
		number s1=VA1.w-VA0.w;
		number s8=VB1.w-VB0.w;
		number s9=VC1.w-VC0.w;
		number s2=(CameraOffset.w-VC0.w)/s9;
		number s3=(CameraOffset.w-VB0.w)/s8;
		number s4=(VA1.z-VA0.z)/s1;
		number s5=(VA1.y-VA0.y)/s1;
		number s6=(VA1.x-VA0.x)/s1;
		number s7=CameraOffset.w-VA0.w;
		number s10=VC1.z-VC0.z;
		number s11=VB1.y-VB0.y;
		number s12=VC1.y-VC0.y;
		number s13=VB1.z-VB0.z;
		number s14=VC1.x-VC0.x;
		number s15=VB1.x-VB0.x;
		number q7=Ray.w*(s11/s8-s5);
		number q8=Ray.w*(s10/s9-s4);
		number q9=Ray.w*(s13/s8-s4);
		number q10=Ray.w*(s12/s9-s5);
		number q11=Ray.w*(s14/s9-s6);
		number q12=Ray.w*(s15/s8-s6);
		number s16=q12*q10;
		number s17=s7*s4;
		number q1=s2*s10-s17+VC0.z-VA0.z;
		number s19=s7*s6;
		number s20=q7*q11;
		number s18=s7*s5;
		number q2=s3*s11-s18+VB0.y-VA0.y;
		number q3=s2*s12-s18+VC0.y-VA0.y;
		number q4=s3*s13-s17+VB0.z-VA0.z;
		number q5=s2*s14-s19+VC0.x-VA0.x;
		number q6=s3*s15-s19+VB0.x-VA0.x;
		number p1=s20+q8*q2-q9*q3-q10*q4;
		number p2=q9*q5+q11*q4-s16-q8*q6;
		number p3=q12*q3+q10*q6-q7*q5-q11*q2;
		number p4=q2*q1-q4*q3;
		number p5=q4*q5-q6*q1;
		number p6=q6*q3-q2*q5;
		number p7=q7*q8-q9*q10;
		number p8=q9*q11-q12*q8;
		number p9=s16-s20;
		number s21=p7+Ray.y;
		number s22=p8+Ray.z;
		//Do your eyes hurt yet?
		number a3=Ray.x*s21*s22*p9;
		number a2=Ray.x*p1+CameraOffset.x*s21*p2+CameraOffset.y*s22*p3+CameraOffset.z*p9;
		number a1=Ray.x*p4+CameraOffset.x*p1+Ray.y*p5+CameraOffset.y*p2+Ray.z*p6+CameraOffset.z*p3;
		number a0=CameraOffset.x*p4+CameraOffset.y*p5+CameraOffset.z*p6;

		int nr=1;
		number ans[3];

		if(abs(a3)<=acc){
			if(abs(a2)<=acc){
				ans[0]=-a0/a1;
			}else{
				number v1=-a1/(2*a2);
				number rc=a1*a1-4*a0*a2;
				if(rc>=0){
					number v2=sqrt(rc)/(2*a2);
					if(abs(v2)<=acc){
						ans[0]=v1;
					}else{
						nr=2;
						ans[0]=v1+v2;
						ans[1]=v1-v2;
					}
				}
			}
		}else{
			vec2 v1=vec2(-2*a2*a2*a2+9*a1*a2*a3-27*a0*a3*a3,0);
			vec2 v2=vec2(3*a1*a3-a2*a2,0);
			vec2 v3=Csqrt(4*Cmul(v2,Cmul(v2,v2))+Cmul(v1,v1));
			vec2 v4=Cpow(0.5*(v1+v3),1/3);

			number swag=18*a3*a2*a1*a0-4*a2*a2*a2*a0+a2*a2*a1*a1-4*a3*a1*a1*a1-27*a3*a3*a0*a0;
			ans[0]=((vec2(-a2,0)+v4-Cdiv(v2,v4))/(3*a3)).x;
			if(swag>0){
				nr=3;
				ans[1]=((vec2(-a2,0)-Cmul(e0,v4)+Cmul(e1,Cdiv(v2,v4)))/(3*a3)).x;
				ans[2]=((vec2(-a2,0)-Cmul(e1,v4)+Cmul(e0,Cdiv(v2,v4)))/(3*a3)).x;
			}
		}

		for(int rn=0;rn<nr;++rn){
			number r=ans[rn];
			vec4 hit=CameraOffset+Ray*r;

			if(r>0 && r<worst){//Object is infront of the camera.

				number VAt=AtT(VA0.w,VA1.w,hit.w);
				number VBt=AtT(VB0.w,VB1.w,hit.w);
				number VCt=AtT(VC0.w,VC1.w,hit.w);

				vec4 VAT=mix(VA0,VA1,VAt);
				vec4 VBT=mix(VB0,VB1,VBt);
				vec4 VCT=mix(VC0,VC1,VCt);

				vec3 norm=cross((VBT-VAT).xyz,(VCT-VAT).xyz);

				if(dot(CameraOffset.xyz-hit.xyz,norm)>0){//One sided textures
					vec4 H=hit-VAT;
					vec4 MX=VBT-VAT;
					vec4 MY=VCT-VAT;
					vec2 L=vec2(dot(MX,MX),dot(MY,MY));
					vec2 omg=vec2(dot(H,MX),dot(H,MY))/L;

					//Didn't do this properly for the longest time!
					vec2 tex=omg-(dot(MX,MY)/sqrt(L.x*L.y))*omg.yx;

					if(tex.x>=0 && tex.y>=0 && tex.x+tex.y<=1){//Within triangle
						number w0=mix2(VA0.w,VB0.w,VC0.w,tex);
						number w1=mix2(VA1.w,VB1.w,VC1.w,tex);
						number w=mix2(VAt,VBt,VCt,tex);

						if(w>=0 && w<=1){// && abs(w1+w0-2*hit.w)<=abs(w1-w0)
							vec4 PT=Texel(Pairs,vec2(prism.a,Row));
							vec4 T0=Texel(Map,PT.rg);
							vec4 T1=Texel(Map,PT.ba);

							vec4 colour=mix(Texel(Textures,T0.rg+tex*(2*T0.ba-1)),Texel(Textures,T1.rg+tex*(2*T1.ba-1)),w);

							if(colour.a>0.01){//This object must be noticably visible.
								int index=min(items+1,maxI-1);
								for(int i=0;i<=items;++i){
									if(r<ZI[i]){
										index=i;
										break;
									}
								}
								if(colour.a<0.99){
									for(int i=min(items,maxI-2);i>=index;--i){
										colours[i+1]=colours[i];
										ZI[i+1]=ZI[i];
									}
									items+=1;
								}else{//Nothing will be visible behind this object.
									items=index;
									worst=r;
								}
								colours[index]=colour;
								ZI[index]=r;
							}
						}
					}
				}
			}
		}
	}
	vec4 colour;
	for(int i=items;i>=0;i--){
		colour=mask(colour,colours[i]);
	}
	return colour;
}
