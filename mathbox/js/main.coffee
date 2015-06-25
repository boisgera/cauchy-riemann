
# TODO: find a graph / axes map such that:
#
#  - shadow "works" (light is on the top: that's the 2nd axis direction)
#  - the camera "works" (far from lock)
#  - direct axes
#  - adapt the default pow accordingly
#
#  ... cause the default doesn't work ?
#
#  OK. Axis 2 for x, 0 for y and 1 for the data seems to work.
#  Check the orientation with z -> z. SHIT, DOES NOT WORK.
# 
# Check with the convention used when only a single value is returned.
# How does Mathbox create the result ? I think that it's z -> [x, z, y]

# TODO: surfaces colors & lines themes similar to the Bezier example.
# TODO: shadow, as in Bezier (maybe display a "floor" & get rid of the z-axis

# TODO: "shift" im/re on the left/right.

# TODO: live stuff: morph from z -> z to z -> z*z
#       Tried the naive way, and it's UGLY (like 4fps with 16x16 pts):
#       we pay the cost of clock calls, eval, in loops.

τ = 2 * Math.PI

_t0 = undefined
time = () -> 
    _t0 ?= new Date()
    0.001 * (new Date() - _t0)

surface = (f) ->
    re: (x, y) -> 
      #theta = 0.5 * (Math.cos(time()) + 1)
      fz = math.eval f, z: math.complex(x, y) 
      [y, fz.re, x]
    ,
    im: (x, y) -> 
      #theta = 0.5 * (Math.cos(time()) + 1)    
      fz = math.eval f, z: math.complex(x, y)
      [y, fz.im, x]

clip_z = (f, min, max) ->
  () ->
    f_ = f.apply(null, arguments)
    f_[2] = Math.min(Math.max(f_[2], min), max)
    f_

surf = surface "0.5 * z * z"

# Rk: 0.5 * z * z -> 0.5(x*x - y*y) + ixy

# ------------------------------------------------------------------------------
    
setup = () ->
  mathbox = mathBox(cameraControls: true);
  window.mathbox = mathbox
  mathbox.start()

  mathbox.viewport 
    range: [[-1, 1], [-1, 1], [-1, 1]]
        
  pov =
    orbit: 5,
    phi: τ / 8,
    theta: τ / 16,
    lookAt: [0, 0, 0]
    
  mathbox.camera pov
  
  #mathbox.grid(axis:[0,2])
  # TODO: translate the axis to the shadow ? But then, how do we
  # know what the 0-level is ?
  mathbox.axis(axis: 2, color: 0xa0a0a0, ticks: 0)
  mathbox.axis(axis: 0, color: 0xa0a0a0, ticks: 0)
  #mathbox.axis(axis: 1, color: 0x0000ff)
  
  if false
    mathbox.surface
      id: "re",
      n: [16, 16],
      live: false,
      domain: [[-1, 1], [-1, 1]],
      expression: (x, y) -> [x, 0.5 * (x*x - y*y), y],
      # this is weird, when I swap x and y, the lines are swapped
      # below/above, BUT THEIR COLOR CHANGES TO (from black on top
      # to a better, darker color related to the surf color below ...) 
      # that's even weirder with shading off, the lines disappear.
      # Unless we get rid of mesh ?
      color: 0x0000ff,
      line: true,
      opacity: 1.0,
      shaded: true

    mathbox.surface
      id: "im",
      domain: [[-1, 1], [-1, 1]],
      n: [16, 16],
      live: false,
      expression: (x, y) -> [y, x * y, x],
      color: 0xff0000,
      line: true, 
      opacity: 1.0,
      shaded: true
  
  # OK:
  #   - 2x draw trick: mesh first, lines after that, with zIndex higher.
  #   - need to find the default color for surf: that's 0x20c050. NOPE !
  # TODO:
  #  - study the relathionship between the two blues and make the same
  #    kind of variant for a new color (with husl.js).
  
  mathbox.surface
    id: "ZURFACE",
    domain: [[-1, 1], [-1, 1]],
    n: [32, 32],
    live: false,
    color: 0x3280f0,
    expression: (x, y) -> 0.5 * (x*x - y*y),
    mesh: true,
    line: false, 
    shaded: true,
    
  mathbox.surface
    id: "test2",
    domain: [[-1, 1], [-1, 1]],
    n: [32, 32],
    live: false,
    expression: (x, y) -> 0.5 * (x*x - y*y),
    color: 0x2060E0,
    mesh: false,
    line: true, 
    opacity: 1.0,
    zIndex: 10,
    shaded: true,
    
    
  mathbox.surface
    id: "shadow",
    domain: [[-1, 1], [-1, 1]],
    n: [32, 32],
    live: false,
    expression: (x, y) -> -1,
    color: 0x000000,
    line: true, 
    opacity: 0.05,
    shaded: false

###
TODO: Cauchy-Riemann conditions graphically, with some animation.
###


jQuery () ->
  ThreeBox.preload(["../html/MathBox.html"], setup)
