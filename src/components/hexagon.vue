<template>
  <g class="title" :transform="transformG" @click="select">
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
      #caught:
      #  type: Boolean
      #  default: false
      #neighbor:
      #  type: Array
      #  default: -> []
    data: ->
      sqrt3: Math.sqrt(3)

    computed:
      #blocked: -> @cell.blocked || false

      caught: -> @cell.caught || false

      path: -> @cell.path || false

      selected: -> @cell.selected || false

      x: -> @cell.x

      y: -> @cell.y

      transformG: ->
        x = ((@y&1) + @x * 2) * (@radius + @interval)
        y = (@radius + @interval) * @y * @sqrt3
        "translate(#{x}, #{y})"

      status: ->
        if @caught
          if @$parent.win || @$parent.lose
            'finished'
          else
            'caught'
        else if @path
          'path'
        else if @selected
          'selected'
        else
          ''

    created: ->
      #console.log @$parent.col, @$parent.row

    methods:
      hello: ->
        console.log('hello')

      select: ->
        if @selected || @caught then return
        @$parent.pick(@x, @y)


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

.finished {
  fill: red;
}

</style>