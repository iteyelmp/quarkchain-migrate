<template>
  <div>
    <div id="app">
      <el-container>
        <el-header class="header">
          <Header/>
        </el-header>

        <el-main :style="'min-height:'+ (fullHeight-64-82) +'px;'">
          <router-view :key="$route.fullPath" />
        </el-main>

        <Footer/>
      </el-container>
    </div>
  </div>
</template>

<script>
import Header from "@/views/HeaderPage.vue";
import Footer from "@/views/FooterPage.vue";

export default {
  name: 'App',
  components: {
    Header,
    Footer
  },
  data() {
    return {
      fullHeight: document.documentElement.clientHeight,
    }
  },
  watch: {
    fullHeight(val) {
      if (!this.timer) {
        this.fullHeight = val;
        this.timer = true;
        let that = this;
        setTimeout(function () {
          that.timer = false;
        }, 400)
      }

    }
  },
  mounted() {
    this.getBodyHeight()
  },
  methods: {
    getBodyHeight() {
      const that = this
      window.onresize = () => {
        return (() => {
          window.fullHeight = document.documentElement.clientHeight;
          that.fullHeight = window.fullHeight;
        })()
      }
    }
  }
}
</script>

<style>
#app {
  background: #FAFCFF;
  text-align: center;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  margin: 0 auto;
}

.header {
  height: 64px !important;
  padding: 5px 20px !important;
}
</style>
