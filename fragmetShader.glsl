precision mediump float;
uniform vec4 I;

vec3 Z(vec3 p, float a)
 {
  return vec3(cos(a) * p.y + sin(a) * p.x, cos(a) * p.x - sin(a) * p.y, p.z);
}

float F(vec3 P)
 {
  float R = sin((I.x + P.z * 0.01) * 3.176) * 0.45 + 0.5, S = 3.4312 - sin(I.x * 0.1);
  vec4 p = vec4(P, 1), o = p, s = vec4(S, S, S, abs(S)) / R;
  for(int i = 0; i < 24; i ++ )
  {
    if (i == 3 || i == 7 || i == 11 || i == 15 || i == 19 || i == 23)
    R = sin((I.x + P.z * 0.01 + float(i) * 0.25 * sin(I.x * 0.012211154) * 3.8) * 3.176) * 0.45 + 0.5;
    p.xyz = clamp(p.xyz, - 1.0, 1.0) * 2.0 - p.xyz;
    float r2 = dot(p.xyz, p.xyz);
    if (r2 > 1000.0)break;
    p = p * clamp(max(R / r2, R), 0.0, 1.0) * s + o;
  }
  return ((length(p.xyz) - abs(S - 1.0)) / p.w - pow(abs(S), float(1 - 24)));
}

float D(vec3 p)
 {
  vec3 c = vec3(10.0, 10.0, 8.0);
  p = mod(p, c) - 0.5 * c;
  vec3 q = abs(Z(p, p.z * 3.1415 / 10.0 * 4.0));
  float d2 = max(q.z - 10.0, max((q.x * 0.866025 + q.y * 0.5), q.y) - 0.08);
  p = Z(p, p.z * 3.1415 / 10.0 * (length(p.xy) - 3.0) * sin(I.x * 0.01) * 0.8);
  return max(F(p), - d2);
}

vec3 R(vec3 p, vec3 d)
 {
  float td = 0.0, rd = 0.0;
  for(int i = 0; i < 80; i ++ )
  {
    if ((rd = D(p)) < pow(td, 1.5) * 0.004)break;
    td += rd;
    p += d * rd;
  }

  float md = D(p), e = 0.0025;
  vec3 n = normalize(vec3(D(p + vec3(e, 0, 0)) - D(p - vec3(e, 0, 0)), D(p + vec3(0, e, 0)) - D(p - vec3(0, e, 0)), D(p + vec3(0, 0, e)) - D(p - vec3(0, 0, e))));
  e *= 0.5;
  float occ = 1.0 + (D(p + n * 0.02 + vec3(-e, 0, 0)) + D(p + n * 0.02 + vec3(+e, 0, 0)) + D(p + n * 0.02 + vec3(0, - e, 0)) + D(p + n * 0.02 + vec3(0, e, 0)) + D(p + n * 0.02 + vec3(0, 0, - e)) + D(p + n * 0.02 + vec3(0, 0, e)) - 0.03) * 20.0;
  occ = clamp(occ, 0.0, 1.0);
  float br = (pow(clamp(dot(n, - normalize(d + vec3(0.3, - 0.9, 0.4))) * 0.6 + 0.4, 0.0, 1.0), 2.7) * 0.8 + 0.2) * occ / (td * 0.5 + 1.0);
  float fog = clamp(1.0 / (td * td * 1.8 + 0.4), 0.0, 1.0);
  return mix(vec3(br, br / (td * td * 0.2 + 1.0), br / (td + 1.0)), vec3(0.0, 0.0, 0.0), 1.0 - fog);
}

void main(void)
 {
  vec2 f = gl_FragCoord.xy;
  vec3 d = vec3((f - vec2(213.0, 120.0)) / 120.0, 1.0);
  vec3 c = pow(R(vec3(5.0, 5.0, I.x * 10.0), normalize(d * vec3(1.0, 1.0, 1.0 - (length(d.xy) * 0.9)))), vec3(0.6, 0.6, 0.6));
  gl_FragColor = vec4(pow(floor(c * vec3(8.0, 8.0, 4.0) + fract(f.x / 4.0 + f.y / 2.0) / 2.0) / (vec3(7.0, 7.0, 3.0)), vec3(1.5, 1.5, 1.5)), 1.0);
}