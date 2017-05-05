import Vue from 'vue'
import App from './App.vue'

Vue::$prefix = 'chatnoir-'
[
  'hexagon'
].forEach (name) -> Vue.component Vue::$prefix + name, require './components/' + name

new Vue
  el: '#app',
  render: (h) -> h App
