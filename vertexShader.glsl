attribute vec2 position;

void main(void)
{
  // Just providing the vertex's position to WebGL.
  gl_Position = vec4(position, 0, 1);
}