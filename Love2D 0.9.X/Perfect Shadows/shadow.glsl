//By xXxMoNkEyMaNxXx
float pi=3.1415926535897932384626433832795,tau=6.283185307179586476925286766559;
float crossZ(vec2 a,vec2 b)
{
	return a.x*b.y-a.y*b.x;
}

//Returns how much of the circle is not blocked by the triangle [0-1]
float CircleSubtractTriangle(vec2 v1,vec2 v2 vec2 v3) //Circle is assumed to be at 0,0 with radius 1, triangle vertices are assumed to be clockwise
{
	float m1=dot(v1,v1),m2=dot(v2,v2),m3=dot(v3,v3);
	//Cases 1-4: One or more vertices are in the circle.
	if(m1<1||m2<1||m3<1){
		//Case 1: The whole triangle is within the circle.
		if(m1<1&&m2<1&&m3<1)
			return 1-crossZ(v1-v2,v3-v2)/tau;
		//Case 2: Two vertices are in the circle.
		if(m1<1&&m2<1){
			vec2 v31=v1-v3,v32=v2-v3;
			float m31=dot(v31,v31),m32=dot(v32,v32);
			float h1=crossZ(v2,v32),h2=crossZ(v3,v31);
			vec2 i1=v1-v31*((sqrt(m31-h2*h2)+dot(v1,v31))/sqrt(m31)),i2=v2-v32*((sqrt(m32-h1*h1)+dot(v2,v32))/sqrt(m32));
			float H3=crossZ(i1,i2-i1)/distance(i1,i2);
			return 0.5+(crossZ(i1-i2,v3-i2)-crossZ(v1-v2,v3-v2))/tau+(H3*sqrt(1-H3*H3)+asin(H3))/pi;
		}
		if(m2<1&&m3<1){
			vec2 v12=v2-v1,v13=v3-v1;
			float m12=dot(v12,v12),m13=dot(v13,v13);
			float h2=crossZ(v3,v13),h3=crossZ(v1,v12);
			vec2 i2=v2-v12*((sqrt(m12-h3*h3)+dot(v2,v12))/sqrt(m12)),i3=v3-v13*((sqrt(m13-h2*h2)+dot(v3,v13))/sqrt(m13));
			float H1=crossZ(i2,i3-i2)/distance(i2,i3);
			return 0.5+(crossZ(i2-i3,v1-i3)-crossZ(v2-v3,v1-v3))/tau+(H1*sqrt(1-H1*H1)+asin(H1))/pi;
		}
		if(m3<1&&m1<1){
			vec2 v23=v3-v2,v21=v1-v2;
			float m23=dot(v23,v23),m21=dot(v21,v21);
			float h3=crossZ(v1,v21),h1=crossZ(v2,v23);
			vec2 i3=v3-v23*((sqrt(m23-h1*h1)+dot(v3,v23))/sqrt(m23)),i1=v1-v21*((sqrt(m21-h3*h3)+dot(v1,v21))/sqrt(m21));
			float H2=crossZ(i3,i1-i3)/distance(i3,i1);
			return 0.5+(crossZ(i3-i1,v2-i1)-crossZ(v3-v1,v2-v1))/tau+(H2*sqrt(1-H2*H2)+asin(H2))/pi;
		}
		//Cases 3 and 4: One vertex is in the circle.  The edge opposite the vertex inside the circle cuts through the circle for case 4, but not for case 3.
		if(m1<1){
			vec2 v12=v2-v1,v13=v3-v1;
			float m12=dot(v12,v12),m13=dot(v13,v13);
			float h2=crossZ(v3,v13),h3=crossZ(v1,v12);
			vec2 i2=v2-v12*((sqrt(m12-h3*h3)+dot(v2,v12))/sqrt(m12)),i3=v3-v13*((sqrt(m13-h2*h2)+dot(v3,v13))/sqrt(m13));
			vec2 v23=v3-v2;
			float m23=dot(v23,v23);
			float h1=crossZ(v2,v23);
			if(h1/sqrt(m23)<1){
				float d1a=dot(v2,v23),d1b=sqrt(m23-h1*h1);
				vec2 I2=v2+v23*((d1a-d1b)/sqrt(m23)),I3=v2+v23*((d1a+d1b)/sqrt(m23));
				float H2=crossZ(i2,I2-i2)/distance(i2,I2),H3=crossZ(i3,I3-i3)/distance(i3,I3);
				return (crossZ(i2-v2,I2-v2)+crossZ(i3-v3,I3-v3)-crossZ(v1-v2,v3-v2))/tau+(H2*sqrt(1-H2*H2)+asin(H2)+H3*sqrt(1-H3*H3)+asin(H3))/pi;
			}
			float H1=crossZ(i2,i3-i2)/distance(i2,i3);
			return 0.5-crossZ(i2-i3,v1-i3)/tau+(H1*sqrt(1-H1*H1)+asin(H1))/pi;
		}
		if(m2<1){
			vec2 v23=v3-v2,v21=v1-v2;
			float m23=dot(v23,v23),m21=dot(v21,v21);
			float h3=crossZ(v1,v21),h1=crossZ(v2,v23);
			vec2 i3=v3-v23*((sqrt(m23-h1*h1)+dot(v3,v23))/sqrt(m23)),i1=v1-v21*((sqrt(m21-h3*h3)+dot(v1,v21))/sqrt(m21));
			vec2 v31=v1-v3;
			float m31=dot(v31,v31);
			float h2=crossZ(v3,v31);
			if(h2/sqrt(m31)<1){
				float d2a=dot(v3,v31),d2b=sqrt(m31-h2*h2);
				vec2 I3=v3+v31*((d2a-d2b)/sqrt(m31)),I1=v3+v31*((d2a+d2b)/sqrt(m31));
				float H3=crossZ(i3,I3-i3)/distance(i3,I3),H1=crossZ(i1,I1-i1)/distance(i1,I1);
				return (crossZ(i3-v3,I3-v3)+crossZ(i1-v1,I1-v1)-crossZ(v2-v3,v1-v3))/tau+(H3*sqrt(1-H3*H3)+asin(H3)+H1*sqrt(1-H1*H1)+asin(H1))/pi;
			}
			float H2=crossZ(i3,i1-i3)/distance(i3,i1);
			return 0.5-crossZ(i3-i1,v2-i1)/tau+(H2*sqrt(1-H2*H2)+asin(H2))/pi;
		}
		if(m3<1){
			vec2 v31=v1-v3,v32=v2-v3;
			float m31=dot(v31,v31),m32=dot(v32,v32);
			float h1=crossZ(v2,v32),h2=crossZ(v3,v31);
			vec2 i1=v1-v31*((sqrt(m31-h2*h2)+dot(v1,v31))/sqrt(m31)),i2=v2-v32*((sqrt(m32-h1*h1)+dot(v2,v32))/sqrt(m32));
			vec2 v12=v2-v1;
			float m12=dot(v12,v12);
			float h3=crossZ(v1,v12);
			if(h3/sqrt(m12)<1){
				float d3a=dot(v1,v12),d3b=sqrt(m12-h3*h3);
				vec2 I1=v1+v12*((d3a-d3b)/sqrt(m12)),I2=v1+v12*((d3a+d3b)/sqrt(m12));
				float H1=crossZ(i1,I1-i1)/distance(i1,I1),H2=crossZ(i2,I2-i2)/distance(i2,I2);
				return (crossZ(i1-v1,I1-v1)+crossZ(i2-v2,I2-v2)-crossZ(v3-v1,v2-v1))/tau+(H1*sqrt(1-H1*H1)+asin(H1)+H2*sqrt(1-H2*H2)+asin(H2))/pi;
			}
			float H3=crossZ(i1,i2-i1)/distance(i1,i2);
			return 0.5-crossZ(i1-i2,v3-i2)/tau+(H3*sqrt(1-H3*H3)+asin(H3))/pi;
		}
	}
	//Cases 5 through 8: No vertices are in the circle.  0, 1, 2, or 3 edges cut through the circle.
	float p=0;//Percent of circle visible
	float h1=crossZ(v2,v3-v2)/distance(v2,v3);
	if(-1<h1&&h1<1)
		p+=0.5-(h1*sqrt(1-h1*h1)+asin(h1))/pi;
	float h2=crossZ(v3,v1-v3)/distance(v3,v1);
	if(-1<h2&&h2<1)
		p+=0.5-(h2*sqrt(1-h2*h2)+asin(h2))/pi;
	float h3=crossZ(v1,v2-v1)/distance(v1,v2);
	if(-1<h3&&h3<1)
		p+=0.5-(h3*sqrt(1-h3*h3)+asin(h3))/pi;
	return p;
}

