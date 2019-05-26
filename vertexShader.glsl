attribute vec2 P;
void main(void)
{
  gl_Position = vec4(P, 0., 1.);
}