###
Cauchy-Riemann Equations -- Geometric Interpretation.
###

# --------------------------------------------------------------------------
# MISC NOTES
# --------------------------------------------------------------------------
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

# TODO: framework to get a state (associated to an object type), apply
#       a diff (animation) and restore the original (with smart diff ?)
  
  
# TODO: mathbox seems to sequence (not intertwin) the animations with a 
#       same target, both otherwise animations are run in parallel ...
#       That raises "interesting" synchronisation issue (if there is no
#       "join"). Rk: Director is probably solving this problem, have a
#       look at the source.



# TODO: toggle im/re animation with a key-stroke.
# TODO: overlay info (HTML or even Mathjax): create the viewport elt (div) first,
#       and tell mathjax to go there. Have a look at the slide deck sources
#       to see how Wittens is doing the trick in his slides.
# TODO: buttons to toggle re / im display.

π = Math.PI
τ = 2 * π

# f(z) = 0.5 * z^2
f = 
  re: (x, y) -> 0.5 * (x * x - y *y)
  im: (x, y) -> x * y

f.re.dx = (x, y) ->  x
f.re.dy = (x, y) -> -y
f.im.dx = (x, y) ->  y
f.im.dy = (x, y) ->  x
  
normalize = (vect, scale=1.0) -> 
  [u, v, w] = vect
  a = scale / (Math.sqrt (u*u + v*v + w*w))
  [a * u, a * v, a * w]

normal = (f, x, y, scale=1.0) -> 
  normalize [-f.dx(x, y), -f.dy(x, y), 1], scale
  
# --------------------------------------------------------------------------
# MAIN 
# --------------------------------------------------------------------------
  
main = () ->
  mathbox = mathBox $(".canvas")[0], cameraControls: true
  window.mathbox = mathbox
  mathbox.start()

  mathbox.viewport {
    type: "cartesian",
    range: [[-1, 1], [-1, 1], [-1, 1]]
  }

  mathbox.camera {
    orbit: 6
    phi: 3 * τ / 8
    theta: τ / 16
    lookAt: [0, 0, 0]
  }

  # ------------------------------------------------------------------------
  # COLORS
  # ------------------------------------------------------------------------
  # Generated offline with husl.js
  grey      = 0xa0a0a0 # HUSL: (0, 0, 65)
  darkGrey = 0x848484 # HUSL: (0, 0, 55)
  
  turquoise       = 0x44dbd8 # HUSL: (190, 90, 80)
  darkTurquoise   = 0x28bebb # HUSL: (190, 95, 70)
  darkerTurquoise = 0x00a19f # HUSL: (190, 100, 60)

  coral         = 0xff8c62 # HUSL: (25, 100, 70)
  darkCoral     = 0xef6700 # HUSL: (25, 100, 60)
  darkerCoral   = 0xc65400 # HUSL: (25, 100, 50)

  display_re = () ->

    duration = 3000
    
    mathbox.animate "#surf",
      color: turquoise,
      expression: (y, x) -> f.re(x, y), 
    ,  
      duration: duration,
  
    mathbox.animate "#mesh", 
      color: darkTurquoise, 
      expression: (y, x) -> f.re(x, y), 
    ,
      duration: duration,
  
  
  display_im = () ->

    duration = 3000
    
    mathbox.animate "#surf",
      color: coral,
      expression: (y, x) -> f.im(x, y),
    , 
      duration: duration,
  
    mathbox.animate "#mesh", 
      color: darkCoral, 
      expression: (y, x) -> f.im(x, y), 
    ,  
      duration: duration,
    
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
    v = [y, f.re(x, y), x]
    if not end
      return v
    else
      [nx, ny, nz] = normal f.re, x, y, 0.5 * _dx
      return [v[0] + ny, v[1] + nz, v[2] + nx]
 
  flat_normal_field = (i, end) ->
    _i = i
    j = i % (n - 1)
    i = i // (n - 1)
    x = _x + (0.5 + i) * _dx
    y = _y + (0.5 + j) * _dy
    v = [y, -1, x]
    if not end
      return v
    else
      [nx, ny, nz] = normal f.re, x, y, 0.5 * _dx
      return [v[0] + ny, v[1] + nz, v[2] + nx]    
    
  # I say live off, but the thing stills seems to be called
  # repeatedly ... BUG ?

  handle_normals = () ->
    if jQuery.isEmptyObject(mathbox.get("#re-normals"))
      console.log "b1"
      mathbox.vector {
          id: "re-normals",
          n: (n - 1) * (n - 1),
          live: off,
          expression: normal_field,
          color: darkerTurquoise,
          size: 0.00,
          arrow: true,
        }
    else
      console.log "b2"
      mathbox.remove "#re-normals"
  
  transition_normals = ->
    mathbox.animate "#re-normals",
      expression: flat_normal_field,
    ,
      duration: 3000
  
  
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
 
  isArray = (object) -> 
    Object.prototype.toString.call(object) is "[object Array]"    

  class Scenario
    constructor: (actions...) ->
      if (actions.length is 1) and isArray(actions[0]) 
        actions = actions[0]
      @actions = actions
      @done = []

    next: ->
      action = @actions.shift()
      if action?
        @done.push action
        action()
        
    previous: ->
      action = @done.pop()
      if action?
        @actions.unshift action
        if action.undo?
          action.undo()
  
  ###
  Scenario = (args...) -> 
    if (args.length is 1) and isArray(args[0]) 
      Scenario args[0]...
    else
      {next: -> args.shift()()}
  ###  

  domain = [[-1,1], [-1,1], [-1,1]]
  n = 16
  dx_ = dy_ = 2 / n
    
  show_axes = (anim = {}) ->
    mathbox.spawn "vector", 
      id: "re-x",
      n: 1,
      data: [[0, 0, 0], [0, 0, 1]],
      color: grey,
      lineWidth: 3,
      opacity: 0
    
    mathbox.spawn "vector",
      id: "re-y",
      n: 1,
      data: [[0, 0, 0], [1, 0, 0]],
      color: grey,
      lineWidth: 3,
      opacity: 0
    
    mathbox.spawn "vector",
      id: "re-z",
      n: 1,
      data: [[0, 0, 0], [0, 1, 0]],
      color: grey,
      lineWidth: 3,
      opacity: 0
      
    mathbox.spawn "surface",
      id: "re-shadow",
      domain: domain,
      n: [n+1, n+1],
      live: false,
      expression: (y, x) -> 0,
      color: grey,
      mesh: true,
      line: true,
      opacity: 0.0,
      shaded: false,

    mathbox.spawn "platonic",
      id: "cube",
      type: "cube",
      line: true,
      mesh: false,
      color: grey,
      shaded: false,
      opacity: 0.0,

    mathbox.animate "#re-x, #re-y, #re-z", opacity: 1.0, anim  
    mathbox.animate "#re-shadow", opacity: 0.25, anim  
    mathbox.animate "#cube", opacity: 0.5, anim  


  show_axes.undo = ->
    mathbox.remove "#re-x" 
    mathbox.remove "#re-y" 
    mathbox.remove "#re-z"
    mathbox.remove "#re-shadow"
    mathbox.remove "platonic"
    
  shrink_axes = ->
    mathbox.animate "#re-x, #re-y, #re-z",
      lineWidth: 2,
      size: 0.07 / 2,
      mathScale: [2/n, 2/n, 2/n],
      mathPosition: [0, -1, 0]
    ,
      duration: 1200
    mathbox.animate "#re-shadow",
      mathPosition: [0, -1, 0],
    ,
      duration: 1200
    mathbox.remove "platonic", duration: 1200
      
  shrink_axes.undo = ->
    mathbox.animate "#re-x, #re-y, #re-z",
      lineWidth: 3,
      size: 0.07,
      mathScale: [1, 1, 1],
      mathPosition: [0, 0, 0]
    ,
      duration: 1200
    mathbox.animate "#re-shadow",
      mathPosition: [0, 0, 0],
    ,
      duration: 1200
    mathbox.spawn "platonic",
      type: "cube",
      line: true,
      mesh: false,
      color: grey,
      shaded: false,
      opacity: 0.5,
    , 
      duration: 1200
      
  display_re = ->
    mathbox.spawn "surface",
      id: "re-surf",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      color: turquoise, 
      expression: (y, x) -> f.re(x, y),
      mesh: true,
      line: false,
      shaded: true,
      opacity: 1.0,
    , 
      duration: 1200

    mathbox.spawn "surface",
      id: "re-mesh",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      expression: (y, x) -> f.re(x, y),
      color: darkTurquoise,
      mesh: false,
      line: true,
      opacity: 1.0,
      zIndex: 10,
      shaded: true,
    , 
      duration: 1200
      
  display_re.undo = ->
    mathbox.remove "#re-surf", duration: 1200
    mathbox.remove "#re-mesh", duration: 1200
    
  display_im = ->
    mathbox.clone "#re-surf", id: "im-surf"
    mathbox.clone "#re-mesh", id: "im-mesh"
    mathbox.clone "#re-x", id: "im-x"
    mathbox.clone "#re-y", id: "im-y"
    mathbox.clone "#re-z", id: "im-z"
    mathbox.clone "#re-shadow", id: "im-shadow"

    mathbox.animate "#re-surf",
      mathPosition: [0, 0, -4],
      color: grey,
    ,
      duration: 1200
    mathbox.animate "#re-mesh",
      mathPosition: [0, 0, -4],
      color: darkGrey,
    ,
      duration: 1200
    mathbox.animate "#re-x, #re-y, #re-z, #re-shadow",
      mathPosition: [0, -1, -4],
    ,
      duration: 1200    
  
    mathbox.animate "#im-surf",
      color: coral,
      expression: (y, x) -> f.im(x, y),
    ,
      delay: 0,
      duration: 1200
    mathbox.animate "#im-mesh",
      color: darkCoral,
      expression: (y, x) -> f.im(x, y),
    ,
      delay: 0,
      duration: 1200
      
  display_im.undo = ->
    mathbox.animate "#im-surf",
      color: turquoise,
      expression: (y, x) -> f.re(x, y),
    ,
      duration: 1200
    mathbox.animate "#im-mesh",
      color: darkTurquoise,
      expression: (y, x) -> f.re(x, y),
    ,
      duration: 1200
    ###  
    mathbox.animate "#re-x, #re-y, #re-z, #re-shadow",
      mathPosition: [0, -1, 0],
    ,
      delay: 1200,
      duration: 1200 
      
    mathbox.animate "#re-surf",
      mathPosition: [0, 0, 0],
      color: turquoise,
    ,
      duration: 1200,
      delay: 1200,
    mathbox.animate "#re-mesh",
      mathPosition: [0, 0, 0],
      color: darkTurquoise,
    ,
      delay: 1200,
      duration: 1200
    ###

    mathbox.remove "#re-surf", delay: 0, duration: 1200
    mathbox.remove "#re-mesh", delay: 0, duration: 1200
    mathbox.remove "#re-x", delay: 0, duration: 1200
    mathbox.remove "#re-y", delay: 0, duration: 1200
    mathbox.remove "#re-z", delay: 0, duration: 1200
    mathbox.remove "#re-shadow", delay: 0, duration: 1200

    mathbox.set "#im-surf", {id: "re-surf"}, {delay: 1201}
    mathbox.set "#im-mesh", {id: "re-mesh"}, {delay: 1201}
    mathbox.set "#im-x", {id: "re-x"}, {delay: 1201}
    mathbox.set "#im-y", {id: "re-y"}, {delay: 1201}
    mathbox.set "#im-z", {id: "re-z"}, {delay: 1201}
    mathbox.set "#im-shadow", {id: "re-shadow"}, {delay: 1201}
    
  display_both = ->
    mathbox.animate "#im-surf, #im-mesh",
      mathPosition: [1, 0, 1]
    ,
      duration: 1200
    mathbox.animate "#im-x, #im-y, #im-z, #im-shadow",
      mathPosition: [1, -1, 1]
    ,
      duration: 1200
    mathbox.animate "#re-surf",
      mathPosition: [-1, 0, -1],
      color: turquoise,
    ,
      duration: 1200
      
    mathbox.animate "#re-mesh",
      mathPosition: [-1, 0, -1],
      color: darkTurquoise,
    ,
      duration: 1200
    mathbox.animate "#re-x, #re-y, #re-z, #re-shadow",
      mathPosition: [-1, -1, -1]
    ,
      duration: 1200

  display_both.undo = ->
    mathbox.animate "#im-surf, #im-mesh",
      mathPosition: [0, 0, 0]
    ,
      duration: 1200
    mathbox.animate "#im-x, #im-y, #im-z, #im-shadow",
      mathPosition: [0, -1, 0]
    ,
      duration: 1200
    mathbox.animate "#re-surf",
      mathPosition: [0, 0, -4],
      color: grey,
    ,
      duration: 1200
      
    mathbox.animate "#re-mesh",
      mathPosition: [0, 0, -4],
      color: darkGrey,
    ,
      duration: 1200
    mathbox.animate "#re-x, #re-y, #re-z, #re-shadow",
      mathPosition: [0, -1, -4]
    ,
      duration: 1200
      
  [x0, y0] = [-0.5, -0.5]
  
  # hardcoded for speed
  f_re_0 = (y, x) -> -0.5 * (x - x0) + 0.5 * (y - y0)
  f_im_0 = (y, x) -> 0.25 - 0.5 * (x - x0) - 0.5 * (y - y0)

  
  domain_from_xy = (x, y) ->
    delta = 2 / n
    i = Math.round(x/delta - 0.5)
    j = Math.round(y/delta - 0.5)
    console.log [[j*delta, (j+1)*delta], [i*delta, (i+1)*delta],[-1, 1]]  
    [[j*delta, (j+1)*delta], [i*delta, (i+1)*delta],[-1, 1]]  
      
  zoom_on_cell = ->
      mathbox.clone "#re-surf", id: "re-cell-surf"
      mathbox.animate "#re-cell-surf",
        domain: domain_from_xy(x0, y0),
        zIndex: 20,
      ,
        duration: 1200
      mathbox.animate "#re-surf",
        color: grey
      ,
        duration: 1200
      mathbox.animate "#re-mesh",
        color: darkGrey,
      ,
        duration: 1200
        
      mathbox.clone "#im-surf", id: "im-cell-surf"
      mathbox.animate "#im-cell-surf",
        domain: domain_from_xy(x0, y0),
        zIndex: 20,
      ,
        duration: 1200
      mathbox.animate "#im-surf",
        color: grey
      ,
        duration: 1200
      mathbox.animate "#im-mesh",
        color: darkGrey,
      ,
        duration: 1200
    
  zoom_on_cell.undo = ->
    mathbox.animate "#re-surf",
      color: turquoise,
    ,
      duration: 1200
    mathbox.animate "#re-mesh",
      color: darkTurquoise,
    ,
      duration: 1200
    mathbox.remove "#re-cell-surf",
      duration: 1200
    mathbox.animate "#im-surf",
      color: coral,
    ,
      duration: 1200
    mathbox.animate "#im-mesh",
      color: darkCoral,
    ,
      duration: 1200
    mathbox.remove "#im-cell-surf",
      duration: 1200    
    
  # here the (perceptive) color before & after the expansion
  # are not the same (darker after expansion), BUT, this is 
  # probably the fault of the envt before being darker.
  tangent_plane_ = -> 
    mathbox.remove "#re-cell-surf", duration: 2400
    mathbox.animate "#re-surf", 
      expression: f_re_0,
      color: turquoise,
    ,
      duration: 2400
    mathbox.animate "#re-mesh",
      expression: f_re_0,
      color: darkTurquoise,
    ,
      duration: 2400
      
  # alternate, don't know which one is better.
  tangent_plane = ->  

    mathbox.set "#re-cell-surf",
      expression: f_re_0
    mathbox.animate "#re-cell-surf",
      domain: [[-1, 1], [-1, 1], [-1, 1]],
    ,
      duration: 2400
    mathbox.spawn "surface",
      id: "re-cell-mesh",
      n: [n+1, n+1],
      line: true,
      mesh: false,
      expression: f_re_0,
      domain: [[-1,1],[-1,1],[-1,1]],
      zIndex: 30,
      mathPosition: [-1, 0, -1],
      color: darkTurquoise,
    ,
      delay: 2400
    mathbox.remove "#re-surf, #re-mesh",
      duration: 1200
    
    mathbox.set "#im-cell-surf",
      expression: f_im_0
    mathbox.animate "#im-cell-surf",
      domain: [[-1, 1], [-1, 1], [-1, 1]],
    ,
      duration: 2400
    mathbox.spawn "surface",
      id: "im-cell-mesh",
      n: [n+1, n+1],
      line: true,
      mesh: false,
      expression: f_im_0,
      domain: [[-1,1],[-1,1],[-1,1]],
      zIndex: 30,
      mathPosition: [1, 0, 1],
      color: darkCoral,
    ,
      delay: 2400
    mathbox.remove "#im-surf, #im-mesh",
      duration: 1200
    
  tangent_plane.undo = ->  
    mathbox.animate "#re-cell-surf",
      domain: domain_from_xy(x0, y0),
    ,
      duration: 1200
    mathbox.animate "#im-cell-surf",
      domain: domain_from_xy(x0, y0),
    ,
      duration: 1200
    mathbox.remove "#re-cell-mesh, #im-cell-mesh"
  
    mathbox.spawn "surface",
      id: "re-surf",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      color: grey, 
      expression: (y, x) -> f.re(x, y),
      mesh: true,
      line: false,
      shaded: true,
      opacity: 1.0,
      mathPosition: [-1, 0, -1],

    , 
      duration: 1200

    mathbox.spawn "surface",
      id: "re-mesh",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      expression: (y, x) -> f.re(x, y),
      color: darkGrey,
      mesh: false,
      line: true,
      opacity: 1.0,
      zIndex: 10,
      shaded: true,
      mathPosition: [-1, 0, -1],
    , 
      duration: 1200
      
    mathbox.spawn "surface",
      id: "im-surf",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      color: grey, 
      expression: (y, x) -> f.im(x, y),
      mesh: true,
      line: false,
      shaded: true,
      opacity: 1.0,
      mathPosition: [1, 0, 1],

    , 
      duration: 1200

    mathbox.spawn "surface",
      id: "im-mesh",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: on,
      expression: (y, x) -> f.im(x, y),
      color: darkGrey,
      mesh: false,
      line: true,
      opacity: 1.0,
      zIndex: 10,
      shaded: true,
      mathPosition: [1, 0, 1],
    , 
      duration: 1200
  
  display_normals = ->
    mathbox.spawn "vector",
      id: "re-normal",
      n: 1,
      data: [[0,0,0],[y0,1,-x0]],
      color: 0x000000,
      mathPosition: [-1,0, -1],
      color: darkerTurquoise,
      lineWidth: 4,
      size: 0.07 * 2
    ,
      duration: 1200
    
    mathbox.spawn "vector",
      id: "im-normal",
      n: 1,
      data: [[0,0,0],[-x0,1,-y0]],
      color: 0x000000,
      mathPosition: [1,-0.25, 1],
      color: darkerCoral
      lineWidth: 4,
      size: 0.07 * 2  
    ,
      duration: 1200
    
  display_normals.undo = ->
    mathbox.remove "#re-normal, #im-normal", duration: 1200
    
  
  gather_normals = -> 
    mathbox.remove "#re-cell-surf, #re-cell-mesh, #im-cell-surf, #im-cell-mesh", 
      duration: 1200  
    mathbox.remove "#re-x, #re-y, #re-z, #re-shadow", duration: 1200
    mathbox.remove "#im-x, #im-y, #im-z, #im-shadow,", duration: 1200
    mathbox.animate "#re-normal, #im-normal",
      mathPosition: [0, 0, 0]
    ,
      duration: 1200,
      delay: 1200
    show_axes(duration: 1200, delay: 2400)
    
  gather_normals.undo = ->
    mathbox.remove "platonic", duration: 1200
    mathbox.remove "#re-x, #re-y, #re-z, #re-shadow", duration: 1200
    mathbox.animate "#re-normal",
      mathPosition: [-1,0, -1],
    ,
      delay: 1200,
      duration: 1200
    mathbox.animate "#im-normal",
      mathPosition: [1,-0.25, 1],
    ,
      delay: 1200,
      duration: 1200

    mathbox.spawn "vector", 
      id: "re-x",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [0, 0, 1]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [-1, -1, -1]
    ,
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "vector",
      id: "re-y",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [1, 0, 0]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [-1, -1, -1]
    ,
      duration: 1200,
      delay: 2400
    
    mathbox.spawn "vector",
      id: "re-z",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [0, 1, 0]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [-1, -1, -1]
    ,
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "surface",
      id: "re-shadow",
      domain: domain,
      n: [n+1, n+1],
      live: false,
      expression: (y, x) -> 0,
      color: grey,
      mesh: true,
      line: true,
      opacity: 0.25,
      shaded: false,
      mathPosition: [-1, -1, -1],
    ,
      duration: 1200,
      delay: 2400

    mathbox.spawn "vector", 
      id: "im-x",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [0, 0, 1]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [1, -1, 1]
    ,
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "vector",
      id: "im-y",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [1, 0, 0]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [1, -1, 1]
    ,
      duration: 1200,
      delay: 2400
    
    mathbox.spawn "vector",
      id: "im-z",
      n: 1,
      mathScale: [2/n, 2/n, 2/n],
      size: 0.07 / 2,
      data: [[0, 0, 0], [0, 1, 0]],
      color: grey,
      lineWidth: 2,
      opacity: 1,
      mathPosition: [1, -1, 1]
    ,
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "surface",
      id: "im-shadow",
      domain: domain,
      n: [n+1, n+1],
      live: false,
      expression: (y, x) -> 0,
      color: grey,
      mesh: true,
      line: true,
      opacity: 0.25,
      shaded: false,
      mathPosition: [1, -1, 1],
    , 
      duration: 1200,
      delay: 2400

  
    mathbox.spawn "surface",
      id: "re-cell-surf",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: false,
      shaded: true,
      color: turquoise,
      mesh: true,
      line: false,
      expression: f_re_0,
      mathPosition: [-1, 0, -1],
    , 
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "surface",
      id: "re-cell-mesh",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: false,
      shaded: true,
      color: darkTurquoise,
      mesh: false,
      line: true,
      expression: f_re_0,
      mathPosition: [-1, 0, -1],
    , 
      duration: 1200,
      delay: 2400    

    mathbox.spawn "surface",
      id: "im-cell-surf",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: false,
      shaded: true,
      color: coral,
      mesh: true,
      line: false,
      expression: f_im_0,
      mathPosition: [1, 0, 1],
    , 
      duration: 1200,
      delay: 2400
      
    mathbox.spawn "surface",
      id: "im-cell-mesh",
      domain: [[-1, 1], [-1, 1]],
      n: [n+1, n+1],
      live: false,
      shaded: true,
      color: darkCoral,
      mesh: false,
      line: true,
      expression: f_im_0,
      mathPosition: [1, 0, 1],
    , 
      duration: 1200,
      delay: 2400        
      
  top_pov = ->
    mathbox.animate "camera",
      orbit: 6
      phi:  τ / 2
      theta: τ / 2
      lookAt: [0, 0, 0]
    , 
      duration: 1200
      
  top_pov.undo = ->
    mathbox.animate "camera",
      orbit: 6
      phi: 3 * τ / 8
      theta: τ / 16
      lookAt: [0, 0, 0]
    , 
      duration: 1200
      
  display_angle = ->
    mathbox.spawn "surface", 
      id: "angle",
      color: darkGrey,
      zIndex: 50,
      domain: [[0.5, 1.0],[-π/4, -π/4]],
      expression: (r, theta) -> [r*Math.sin(theta), 0, r*Math.cos(theta)],
      shaded: true,
      opacity: 0.5,
    ,
      duration: 0
    mathbox.animate "#angle",
      domain: [[0.5, 1.0],[-π/4, +π/4]],
    ,
      duration: 1200
      
  display_angle.undo = ->
      mathbox.remove "#angle", duration: 1200
      
  scenario = new Scenario [
    show_axes, 
    shrink_axes, 
    display_re, 
    #shift_re,
    display_im,
    display_both,
    zoom_on_cell,
    tangent_plane,
    display_normals,
    gather_normals,
    top_pov,
    display_angle
  ]

  scenario.next()

  $(document).on "keypress", (event) ->
    switch event.key
      when "ArrowRight"
        scenario.next()
      when "ArrowLeft"
        scenario.previous()

jQuery -> ThreeBox.preload "../html/MathBox.html", main
