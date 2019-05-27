const cnv = document.querySelector("canvas");
const gl = cnv.getContext("webgl") || cnv.getContext("experimental-webgl");
const shaderProgram = gl.createProgram();

// const width = 426;
// const height = 240;
// const width = 852;
// const height = 480;
const width = 1704;
const height = 960;
const start = Date.now();

const mouse = {
  x: 0,
  y: 0
}

window.addEventListener("mousemove", (e) => {
  mouse.x = e.clientX;
  mouse.y = e.clientY;
})

function generateShader(type, shaderText) {
  const shader = gl.createShader(type);

  gl.shaderSource(shader, shaderText);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error(gl.getShaderInfoLog(shader));
  }

  gl.attachShader(shaderProgram, shader);
}

function update() {
  requestAnimationFrame(() => update());

  cnv.width = width;
  cnv.height = height;

  gl.viewport(0, 0, width, height);

  gl.uniform1f(
    gl.getUniformLocation(shaderProgram, "time"),
    // time * .00002
    (Date.now() - start) * .00002
  );

  gl.drawArrays(5, 0, 4);
  // time += 50;
  // time -= 50;
  // time = mouse.x * 100;
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

  const vertices = [
    -1, -1,
    -1, +1,
    +1, -1,
    +1, +1
  ];

  gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
  gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(0);

  // update(0);
  update();
}

run();