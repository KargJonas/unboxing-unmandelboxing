const cnv = document.querySelector("canvas");
const gl = cnv.getContext("webgl") || cnv.getContext("experimental-webgl");
const shaderProgram = gl.createProgram();

function generateShader(type, shaderText) {
  const shader = gl.createShader(type);

  gl.shaderSource(shader, shaderText);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error(gl.getShaderInfoLog(shader));
  }

  gl.attachShader(shaderProgram, shader);
}

function update(time) {
  const width = 426;
  const height = 240;

  cnv.width = width;
  cnv.height = height;

  gl.viewport(0, 0, width, height);

  gl.uniform4f(
    gl.getUniformLocation(shaderProgram, "I"),
    time * .00002, 0, 0, 0
  );

  gl.drawArrays(5, 0, 4);

  time += 50;
  requestAnimationFrame(() => update(time));
}

async function run() {
  const vertexShaderText = await fetch("vertexShader.glsl")
    .then((response) => (response.text()));

  const fragmentShaderText = await fetch("fragmetShader.glsl")
    .then((response) => (response.text()));

  generateShader(gl.VERTEX_SHADER, vertexShaderText);
  generateShader(gl.FRAGMENT_SHADER, fragmentShaderText);

  gl.linkProgram(shaderProgram);
  gl.useProgram(shaderProgram);
  gl.bindBuffer(34962, gl.createBuffer());
  gl.bufferData(34962, new Float32Array([i = -1, i, i, 1, 1, i, 1, 1]), 35044);
  gl.vertexAttribPointer(0, 2, 5126, 0, 0, 0);
  gl.enableVertexAttribArray(0);

  update(0);
}

run();