<template>
  <div id="app">
    <h2 v-text="status"></h2>
    <h3 v-text="'Step: '+step"></h3>
    <div class="action">
      <button v-text="playText" @click="init"></button>
      <button @click="togglePath" v-text="pathText">Show Path</button>
      <button @click="toggleCoord" v-text="coordText">Show Coord</button>
    </div>
    <div class="board">
      <svg :width="width" :height="height">
        <g :transform="transform">
          <chatnoir-hexagon v-for="(cell, key) in pixels"
                            :key="key"
                            :cell="cell"
                            :showCoord="showCoord"
                            :radius="radius"
                            :interval="interval">
          </chatnoir-hexagon>
        </g>
      </svg>
    </div>
  </div>
</template>

<script lang="coffee">
#import Hex from "./utils/hex.coffee"
export default m =
  name: 'app'
  data: ->
    radius: 25 #cell半径
    col: 11 #cell列数
    row: 11 #cell行数
    interval: 2 #cell间距, 没必要写在这
    cells: {} #所有的cell集合
    block_num: 10 #起始block数目
    #blocked: {} #blocked的cell集合
    selected: {} #selected的cell集合
    cat: {} #cat所在cell
    path: [] #cat的行动路线
    even: [
      [1, -1], [1, 0], [1, 1], [0, 1], [-1, 0], [0, -1]
    ]
    odd: [
      [0, -1], [1, 0], [0, 1], [-1, 1], [-1, 0], [-1, -1]
    ]
    #play: 'Play'
    showPath: true
    showCoord: false
    step: 0
    win: false
    lose: false
    bfs: {}

  computed:
    width: ->
      (@radius+@interval)*(@col+1)*2

    height: ->
      (@radius+@interval)*(@row+1)*2

    transform: -> "translate(#{@radius}, #{@radius})"

    pixels: ->
      pixels = {}
      for key, cell of @cells
        pixels[key] = {}
        pixels[key].x = cell.x
        pixels[key].y = cell.y
        if cell.selected
          pixels[key].selected = true
        else
          pixels[key].selected = false
        if key == @hex2key(@cat)
          pixels[key].caught = true
        else
          pixels[key].caught = false
        if @showPath && cell.path
          pixels[key].path = true
        else
          pixels[key].path = false
      pixels

    playText: ->
      if @win || @lose
        'Replay'
      else
        'Play'

    status: ->
      if @win
        'YOU WIN'
      else if @lose
        'YOU LOSE'
      else
        'Chat Noir'

    pathText: ->
      if @showPath
        'Hide Path'
      else
        'Show Path'

    coordText: ->
      if @showCoord
        'Hide Coord'
      else
        'Show Coord'

  created: ->
    @init()

  methods:
    init: ->
      @cat = @point 5, 5
      @selected = {}
      @createCell()
      @createBlock()
      @win = false
      @lose = false
      @step = 0
      @get_path()
      @drawPath()

    createCell: ->
      cells = {}
      for x in [0...@col]
        for y in [0...@row]
          key = @hex_key x, y
          cells[key] = @point x, y
          cells[key].selected = false
          cells[key].caught = false
          cells[key].path = false
      @cells = cells

    createBlock: ->
      blocked = {}
      for i in [0...@block_num]
        x = Math.trunc Math.random()*@col
        y = Math.trunc Math.random()*@row
        key = @hex_key x, y
        if key != @hex2key @cat
          blocked[key] = @point x, y
          @cells[key].selected = true
      @selected = blocked

    togglePath: ->
      @showPath = !@showPath

    toggleCoord: ->
      @showCoord = !@showCoord

    hex_key: (x, y) ->
      x + '-' + y

    hex2key: (a) ->
      @hex_key a.x, a.y

    neighbor: (x, y) ->
      array = []
      if (y&1)
        @even.forEach (a) =>
          #if (@col >= (a[0] + x) >= 0) && (@row >= (a[1] + y) >= 0)
          array.push @point a[0]+x, a[1]+y
      else
        @odd.forEach (a) =>
          #if (@col >= (a[0] + x) >= 0) && (@row >= (a[1] + y) >= 0)
          array.push @point a[0]+x, a[1]+y
      array

    point: (x, y) ->
      x: x, y: y

    hex: (x, y, z) ->
      x: x, y: y, z: z

    point2hex: (x, y) ->
      @hex x, y, 1-x-y

    pick: (x, y) ->
      if @win || @lose then return
      console.log x, y
      key = @hex_key x, y
      @selected[key] = @point x, y
      @cells[key].selected = true
      #@blocked[key] = @point x, y
      @step += 1
      @next()

    hex_border: (cell) ->
      cell.x == 0 || cell.y == 0 || cell.x == @col-1 || cell.y == @row-1

    out_of_hex: (cell) ->
      cell.x < 0 || cell.y < 0 || cell.x > @col-1 || cell.y > @row-1

    get_goals: (cost_so_far) ->
      array = []
      for key, value of cost_so_far
        do (key) =>
          x = ~~key.split('-')[0]
          y = ~~key.split('-')[1]
          cell = @point x, y
          if @hex_border cell
            cell.distance = value
            array.push cell
      array.sort (a, b) -> a.distance - b.distance
      array[0]

    get_next: (came_from, p) ->
      came_from[@hex2key(p)]

    get_path: () ->
      maxMovement = (@col + 1) * (@row + 1)
      radius = Math.max(@col, @row)
      bfs = @breadthFirstSearch @cat, maxMovement, radius, @selected
      @bfs = bfs
      path = [] #maybe many paths
      goal = @get_goals(bfs.cost_so_far)
      p = goal
      while p && @hex2key(p) != @hex2key(@cat)
        path.push p
        p = @get_next(bfs.came_from, p)
      path.reverse()
      @path = path

    next: ->
      @get_path()
      @drawPath()
      @finish()

    drawPath: ->
      for key, cell of @cells
        index = @path.findIndex (p) -> p.x == cell.x && p.y == cell.y
        if index != -1
          cell.path = true
        else
          cell.path = false

    finish: ->
      if @path.length > 0
        @cells[@hex2key(@cat)].caught = false
        @cat = @point @path[0].x, @path[0].y
        @cells[@hex2key(@cat)].caught = true
        if @hex_border @cat
          console.info "YOU LOSE"
          @win = false
          @lose = true
        else
          @get_path()
          @drawPath()
      else
        @win = true
        @lose = false
        console.info "YOU WIN"

    breadthFirstSearch: (start, maxMovement, radius, blocked) ->
      start_key = @hex2key start
      cost_so_far = {}
      cost_so_far[start_key] = 0
      came_from = {}
      came_from[start_key] = null
      fringes = [ [ start ] ]
      k = 0
      while k < maxMovement && fringes[k].length > 0
        fringes[k + 1] = []
        for cell in fringes[k]
          #break if @hex_border cell
          neighbors = @neighbor cell.x, cell.y
          for neighbor in neighbors
            key = @hex2key neighbor
            if !cost_so_far[key] and !blocked[key] and !@out_of_hex neighbor
              cost_so_far[key] = k + 1
              came_from[key] = cell
              fringes[k + 1].push neighbor
        k++
      {
        cost_so_far: cost_so_far
        came_from: came_from
      }




</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

div.board {
  margin: 25px -27px 25px 27px;
}

div.action {
  display: flex;
  flex: auto;
  align-items: center;
  justify-content: center;
}

button {
  min-width: 10rem;
  height: 2.5rem;
  border: none;
  cursor: pointer;
  background: #c6ff00;
  margin: 0 1.5rem;
}

span {
  min-width: 10rem;
}
</style>
