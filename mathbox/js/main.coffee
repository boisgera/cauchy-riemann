###
Cauchy-Riemann Equations -- Geometric Interpretation.
###

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

π = Math.PI
τ = 2 * π

_t0 = undefined
time = -> 
    _t0 ?= new Date()
    0.001 * (new Date() - _t0)

surface = (f) ->
  re: (x, y) -> 
    fz = math.eval f, z: math.complex(x, y) 
    [y, fz.re, x]
  im: (x, y) ->    
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
    
f = 
  re: (x, y) -> 0.5 * (x * x - y *y)
  im: (x, y) -> x * y

f.re._dx = (x, y) ->  x
f.re._dy = (x, y) -> -y
f.im._dx = (x, y) ->  y
f.im._dy = (x, y) ->  x
  
dx = (f) -> f._dx
dy = (f) -> f._dy
  


normalize = (vect, scale=1.0) -> 
  [u, v, w] = vect
  a = scale / (Math.sqrt (u*u + v*v + w*w))
  [a * u, a * v, a * w]

normal = (f, x, y, scale=1.0) -> 
  normalize [-dx(f)(x, y), -dy(f)(x, y), 1], scale
  
setup = () ->
  mathbox = mathBox $(".canvas")[0], cameraControls: true
  window.mathbox = mathbox
  mathbox.start()

  mathbox.viewport {
    range: [[-1, 1], [-1, 1], [-1, 1]]
  }

  pov =
    orbit: 6
    phi: τ / 8
    theta: τ / 16
    lookAt: [0, 0, 0]

  mathbox.camera pov
  
  #mathbox.grid(axis:[0,2])
  # TODO: translate the axis to the shadow ? But then, how do we
  # know what the 0-level is ?
  #mathbox.axis(axis: 2, color: 0xa0a0a0, ticks: 0)
  #mathbox.axis(axis: 0, color: 0xa0a0a0, ticks: 0)
  #mathbox.axis(axis: 1, color: 0x0000ff)
  
  if false
    mathbox.surface {
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
    }

    mathbox.surface {
      id: "im",
      domain: [[-1, 1], [-1, 1]],
      n: [16, 16],
      live: false,
      expression: (x, y) -> [y, x * y, x],
      color: 0xff0000,
      line: true, 
      opacity: 1.0,
      shaded: true
    }
  
  # OK:
  #   - 2x draw trick: mesh first, lines after that, with zIndex higher.
  #   - need to find the default color for surf: that's 0x20c050. NOPE !
  # TODO:
  #  - study the relathionship between the two blues and make the same
  #    kind of variant for a new color (with husl.js).
  # blue: 0x3280f0, dark-blue: 0x2060E0
  
  ###  
      husl = (H, S=100, L=50) ->
      string = "0x" + $.husl.toHex(H, S, L)[1..]
      parseInt(string)
  ###
  int = (HSL) -> 
    [H, S, L] = HSL
    parseInt("0x" + $.husl.toHex(H, S, L)[1..])
  
  dark = (HSL) -> 
    [H, S, L] = HSL
    [H, Math.min(S + 5, 100), Math.max(L - 10, 0)]
    
  blue = [255.2172523246686, 90.06925396893368, 54.45567976090578]  
  turquoise = [190, 90, 80]
  coral = [25, 100, 70]
  
  # TODO: have a look at <http://www.buzzfeed.com/peggy/unexpected-color-combinations-that-look-amazing-together#.yxAYmPEvx> and select the best
  # color pair

  color = turquoise
  expr =  f.re
  
  n = 16
  
  # TODO: try to "shift" the real & imaginary part on the right & left.
  # TODO: plot the real part, animate to the imaginary part.
  
  # Rk: animation won't work unless the graph data is live ALL THE TIME.
  #     would it work to "set" the surface to live just before the animation ?
  #     NO. maybe (probably) if we remove the object to recreate it,
  #     but then it's a mess at the end to turn the live back off, because
  #     there is no event (right ?) when the animation stops.
  
  
  mathbox.surface {
    id: "surf"
    domain: [[-1, 1], [-1, 1]]
    n: [n, n]
    live: on
    color: int(color) 
    expression: expr
    mesh: true
    line: false 
    shaded: true
  }
    
  mathbox.surface {
    id: "mesh"
    domain: [[-1, 1], [-1, 1]]
    n: [n, n]
    live: on
    expression: expr
    color: int(dark(color))
    mesh: false
    line: true 
    opacity: 1.0
    zIndex: 10
    shaded: true
  }

  # TODO: mathbox seems to sequence (not intertwin) the animations with a 
  #       same target, both otherwise animations are run in parallel ...
  #       That raises "interesting" synchronisation issue (if there is no
  #       "join"). Rk: Director is probably solving this problem, have a
  #       look at the source.
    
  mathbox.surface {
    id: "shadow"
    domain: [[-1, 1], [-1, 1]]
    n: [32, 32]
    live: false
    expression: (x, y) -> -1
    color: 0x000000
    line: true
    opacity: 0.05
    shaded: false
  }
  
  # TODO: toggle im/re animation with a key-stroke.
  # TODO: overlay info (HTML or even Mathjax): create the viewport elt (div) first,
  #       and tell mathjax to go there. Have a look at the slide deck sources
  #       to see how Wittens is doing the trick in his slides.
  # TODO: buttons to toggle re / im display.

  display_re = () ->
    color = turquoise
    expr = f.re

    duration = 3000
    
    mathbox.animate "#surf",
      {color: int(color), expression: expr}, 
      {duration: duration}
  
    mathbox.animate "#mesh", 
      {color: int(dark(color)), expression: expr}, 
      {duration: duration} 
  
  
  display_im = () ->
    color = coral
    expr = f.im

    duration = 3000
    
    mathbox.animate "#surf",
      {color: int(color), expression: expr}, 
      {duration: duration}
  
    mathbox.animate "#mesh", 
      {color: int(dark(color)), expression: expr}, 
      {duration: duration} 
  
  
  re_to_im = () ->      
    color = coral
    expr = f.im

    duration = 3000
    
    mathbox.animate "#surf",
      {color: int(color), expression: expr}, 
      {duration: duration}
  
    mathbox.animate "#mesh", 
      {color: int(dark(color)), expression: expr}, 
      {duration: duration} 

    color = turquoise
    expr = f.re

    mathbox.animate "#surf", 
      {color: int(color), expression: expr}, 
      {duration: duration, delay: 0}
    
    mathbox.animate "#mesh", 
      {color: int(dark(color)), expression: expr},
      {duration: duration, delay: 0}
  
 # re_to_im()
    
  domain = [[-1, 1], [-1, 1]]
  _x = domain[0][0]
  _y = domain[1][0]
  _dx = (domain[0][1] - domain[0][0]) / (n - 1)
  _dy = (domain[1][1] - domain[1][0]) / (n - 1)

  if false
    mathbox.animate "camera",
      {orbit: 0.5, lookAt: [0, 0, 0]},
      {duration: 3000, delay: 5000}

    mathbox.animate "camera",
      {orbit: 6, lookAt: [0, 0, 0]},
      {duration: 3000, delay: 2000}

  normal_field = (i, end) ->
    _i = i
    j = i % (n - 1)
    i = i // (n - 1)
    x = _x + (0.5 + i) * _dx
    y = _y + (0.5 + j) * _dy
    v = [x, f.re(x, y), y]
    if not end
      return v
    else
      [nx, ny, nz] = normal f.re, x, y, 0.5 * _dx
      return [v[0] + nx, v[1] + nz, v[2] + ny]

  # I say live off, but the thing stills seems to be called
  # repeatedly ... BUG ?
  if false
    mathbox.vector {
        n: (n - 1) * (n - 1),
        live: off,
        expression: normal_field,
        color: int(dark(dark(turquoise))),
        size: 0.01,
        arrow: true,
      }
  
  # Make a list of possible states:
  #
  #  - function: re / im
  #  - zoom: on / off
  #  - normal: on / off
  #  - graph / "flat" (to see the normals only.)
  #
  # and every such state bit can be triggered independently,
  # any trigger generate the appropriate animation.
  
  # ----------------------------------------------------------------------
  # ----------------------------------------------------------------------  
  # ----------------------------------------------------------------------
  # TODO: 
  #   - point on the shadow, corresponding tangent plane
  #   - move point on a circle (shadow), move the tangent plane
  #   - easier to deal with normal ? Probably, yes. Use vectors.
  #   - plot curve determined by the normal when we go through
  #     the circle with the normal vector set to a constant origin ?
  [x, y] = [0.5, 0.5]
  [nx, ny, nz] = normal f.re, x, y, 0.2

  vs = [[x,  f.re(x, y), y], [x + nx, f.re(x, y) + nz, y + ny]]
  console.log vs
 
  path = (t) -> # lemniscate de Bernoulli
    scale = 0.80
    c = Math.cos(2 * Math.PI * t) 
    s = Math.sin(2 * Math.PI * t)
    x = scale * c / ((s * s) + 1)
    hack = 2
    y = hack * x * s
    [x, y]
    
  path_shadow = (t) ->
    [x, y] = path(t)
    [x, -0.99, y]
  
  path_point_shadow = () ->
    [x, y] = path(time() / 10)
    [x, -0.99, y]
  
  path_normal = (i, end) ->
    t = time()
    #console.log "t:", t
    [x, y] = path(t / 10) # cycle in 10 sec
    #console.log "x, y:", x, y
    scale = 0.2
    [nx, ny, nz] = normal f.re, x, y, scale
    if not end
      [x,  f.re(x, y), y]
    else
      [x + nx, f.re(x, y) + nz, y + ny]
    
  if false
    mathbox.vector
      n: 1,
      live: true,
      expression: path_normal,
      color: 0x000000

    mathbox.curve
      live: true,
      n: 1,
      domain: [0,0],
      expression: path_point_shadow,
      points: true,
      pointSize: 5,
      color: 0x000000

    mathbox.curve
      n: n*10,
      domain: [0, 1],
      expression: path_shadow
      color: 0xb0b0b0,
      opacity: 1.0,
      lineWidth: 2, # issue here, does increase erratically when higher values
      # are used
 
  $(document).on "keypress", (event) ->
    switch event.key
      when "r", "u" then display_re()
      when "i", "v" then display_im()

jQuery ->
  ThreeBox.preload ["../html/MathBox.html"], setup
