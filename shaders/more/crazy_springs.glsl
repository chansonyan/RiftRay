// @var title Crazy Springs
// @var author eiffie
// @var url https://www.shadertoy.com/view/ld23DG

// @var eyePos 0.5 0.5 0.5

// Crazy Springs by eiffie
// Don't know why there is a seam on the springs.
// Well looking at my code I know why. I just don't know exactly why. :)

#define time iGlobalTime
#define size iResolution

//#define SHADOWS
float f1=0.,f2=0.,f3=0.;
float DE(vec3 p)
{
	vec3 g=floor(p+0.5);
	vec3 g1=g+sin(g.yzx*f1+g.zxy*f2+g*f3)*0.25;
	vec4 dlt=vec4(sign(p-g1),0.0);
	vec3 g2=g+dlt.xww;
	vec3 g3=g+dlt.wyw;
	vec3 g4=g+dlt.wwz;
	g1-=p;
	g2+=sin(g2.yzx*f1+g2.zxy*f2+g2*f3)*0.25-p;
	g3+=sin(g3.yzx*f1+g3.zxy*f2+g3*f3)*0.25-p;
	g4+=sin(g4.yzx*f1+g4.zxy*f2+g4*f3)*0.25-p;
	vec3 gD=g2-g1,gDs=gD;
	float t1=clamp(dot(-g1,gD)/dot(gD,gD),0.0,1.0);
	vec3 p1=mix(g1,g2,t1);
	float m1=dot(p1,p1);
	gD=g3-g1;
	float t2=clamp(dot(-g1,gD)/dot(gD,gD),0.0,1.0);
	vec3 p2=mix(g1,g3,t2);
	float m2=dot(p2,p2);
	if(m2<m1){m1=m2;t1=t2;p1=p2;gDs=gD;}
	gD=g4-g1;
	t2=clamp(dot(-g1,gD)/dot(gD,gD),0.0,1.0);
	vec3 p3=mix(g1,g4,t2);
	m2=dot(p3,p3);
	if(m2<m1){m1=m2;t1=t2;p1=p3;gDs=gD;}
	float d1=sqrt(min(dot(g1,g1),min(dot(g2,g2),min(dot(g3,g3),dot(g4,g4)))))-0.15;
	float len=length(gDs);
	float d2=sqrt(m1)-0.07+len*sqrt(d1)*0.02;
	float d=0.25;
	if(d2<d && d2<d1){
		if(d2<0.015){
			gDs/=len;
			gD=normalize(cross(gDs,vec3(1.0,0.0,0.0)));
			float b=dot(p1,gD),c=dot(p1,cross(gDs,gD));
			vec2 v=vec2(d2,(fract( (t1*16.0+atan(b,c)*0.795775))-0.5)*0.05*len);
			d2=length(v)-0.01;
		}
		d=d2;
	}
	if(d1<d){
		d=d1;
	}
	return d;
}
vec3 getColor(vec3 p){
	vec3 g=floor(p+0.5);
	vec3 g1=g+sin(g.yzx*f1+g.zxy*f2+g*f3)*0.25;
	vec4 dlt=vec4(sign(p-g1),0.0);
	vec3 g2=g+dlt.xww;
	vec3 g3=g+dlt.wyw;
	vec3 g4=g+dlt.wwz;
	g1-=p;
	g2+=sin(g2.yzx*f1+g2.zxy*f2+g2*f3)*0.25-p;
	g3+=sin(g3.yzx*f1+g3.zxy*f2+g3*f3)*0.25-p;
	g4+=sin(g4.yzx*f1+g4.zxy*f2+g4*f3)*0.25-p;
	float d1=sqrt(min(dot(g1,g1),min(dot(g2,g2),dot(g3,g3))))-0.15;
	if(d1<0.005)return vec3(0.6,0.2,0.0)+sin(g*2.0)*0.2;
	return vec3(0.5,0.4,0.2)+sin(p*100.0)*0.1;
}
#ifdef SHADOWS
float linstep(float a, float b, float t){return clamp((t-a)/(b-a),0.,1.);}//from knighty
//random seed and generator
float randSeed,GoldenAngle;
float randStep(){//crappy random number generator
	randSeed=fract(randSeed+GoldenAngle);
	return  (0.8+0.2*randSeed);
}
float FuzzyShadow(vec3 ro, vec3 rd, float coneGrad){
	float t=0.01,d,s=1.0,r;
	ro+=rd*t;
	for(int i=0;i<8;i++){
		r=t*coneGrad;
		d=DE(ro+rd*t)+r*0.5;
		s*=linstep(-r,r,d);
		t+=d*randStep();
	}
	return clamp(s,0.3,1.0);
}
#endif
mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}

vec3 getSceneColor( vec3 ro, vec3 rd )
{
#ifdef SHADOWS
	GoldenAngle=2.0-0.5*(1.0+sqrt(5.0));
	randSeed=fract(sin(dot(gl_FragCoord.xy,vec2(13.434,77.2378))+time*0.1)*41323.34526);
#endif
	f1=fract(time*0.01)*6.2832;f2=6.2832*(1.0-fract(time*0.013));f3=6.2832*(fract(time*0.017));
    
    float t=0.0,d=1.0,dm=100.0,tm;
	for(int i=0;i<32;i++){
		t+=d=DE(ro+rd*t);
		if(d<dm){dm=d;tm=t;}
	}
	vec3 L=normalize(vec3(0.3,0.7,-0.4));
	vec3 col=vec3(0.5,0.6,0.7)*pow(0.75+0.25*dot(rd,L),2.0)+rd*0.1;
	if(dm<0.01){
		vec3 p=ro+rd*tm;
		vec2 v=vec2(0.001,0.0);
		vec3 N=normalize(vec3(DE(p+v.xyy)-DE(p-v.xyy),DE(p+v.yxy)-DE(p-v.yxy),DE(p+v.yyx)-DE(p-v.yyx)));
		vec3 scol=getColor(p)*(1.0+dot(N,L));
		scol+=vec3(0.5,0.2,0.75)*pow(max(0.0,dot(reflect(rd,N),L)),8.0);
#ifdef SHADOWS
		scol*=FuzzyShadow(p,L,0.5);
#else 
		scol*=clamp((DE(p+N*0.75)+DE(p+N*0.25))*4.0,0.25,1.0);//cheat from mu6k
#endif

		scol=mix(col,scol,exp(-t*0.4));
		col=mix(scol,col,smoothstep(0.0,0.01,dm));
	}
    
    col = clamp(col*1.5,0.0,1.0);
    return col;
}

#ifndef RIFTRAY
void main() {
#ifdef SHADOWS
	GoldenAngle=2.0-0.5*(1.0+sqrt(5.0));
	randSeed=fract(sin(dot(gl_FragCoord.xy,vec2(13.434,77.2378))+time*0.1)*41323.34526);
#endif
	f1=fract(time*0.01)*6.2832;f2=6.2832*(1.0-fract(time*0.013));f3=6.2832*(fract(time*0.017));
	vec3 ro = vec3(0.5,0.5,time);
	mat3 rotCam=lookat(vec3(sin(time*0.9)*0.5,sin(time*1.4)*0.3,1.0),vec3(sin(time*0.3),cos(time*0.3)*vec2(cos(time*0.5),sin(time*0.5))));
	vec3 rd = rotCam*normalize(vec3((size.xy-2.0*gl_FragCoord.xy)/size.y,1.75));

    vec3 col = getSceneColor(ro, rd);
	gl_FragColor = vec4(col,1.0);
	
}
#endif
