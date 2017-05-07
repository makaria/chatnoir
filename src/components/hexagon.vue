<template>
  <g @mouseenter="enter"
     @mouseout="out"
     class="title"
     :transform="transformG"
     @dblclick="unselect"
     @click="select">
    <ellipse :rx="radius"
             :ry="radius*0.95"
             :class="status">
    </ellipse>
    <text v-show="showCoord" y="0.4em">
      <tspan class="q" v-text="x"></tspan>
      <tspan>,</tspan>
      <tspan class="r" v-text="y"></tspan>
    </text>
  </g>
</template>

<script lang="coffee">
  export default m =
    name: 'hexagon'
    props:
      radius: Number
      cell: Object
      interval: Number
      showCoord: Boolean
    data: ->
      sqrt3: Math.sqrt(3)

    computed:
      caught: -> @cell.caught || false

      path: -> @cell.path || false

      selected: -> @cell.selected || false

      insight: -> @cell.insight || false

      x: -> @cell.x

      y: -> @cell.y

      transformG: ->
        x = ((@y&1) + @x * 2) * (@radius + @interval)
        y = (@radius + @interval) * @y * @sqrt3
        "translate(#{x}, #{y})"

      status: ->
        if @caught
          if @$parent.finish
            'finished'
          else
            'caught'
        else if @selected
          'selected'
        else if @insight
          'insight'
        else if @path
          'path'
        else
          ''

    methods:
      hello: ->
        console.log('hello')

      select: ->
        if @selected || @caught then return
        @$parent.pick @x, @y

      unselect: ->
        if !@selected || @caught then return
        @$parent.unpick @x, @y

      #Throttle
      enter: ->
        if @selected || @caught then return
        @$parent.next_path @x, @y, @path

      #Throttle
      out: ->
        if @selected || @caught then return
        @$parent.reset_path @path

</script>

<style scoped>

text {
  text-anchor: middle;
  cursor: pointer;
}

ellipse {
  fill: #c6ff00;
  stroke: grey;
  cursor: pointer;
}

.selected {
  fill: #757575;
}

.caught {
  fill: black;
}

.path {
  fill: white;
}

.insight {
  fill: darkorange;
}

.finished {
  fill: red;
}

</style>