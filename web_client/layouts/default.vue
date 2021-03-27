<template>
  <div class="mt-5 mb-5">
    <Header />
    <div class="min-h-75vh">
      <Nuxt />
    </div>
    <Footer />
  </div>
</template>

<script>
import Header from '~/components/layout/Header'
import Footer from '~/components/layout/Footer'
export default {
  components: { Footer, Header },
}
</script>

<style>
html {
  font-size: 16px;
  word-spacing: 1px;
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
  -moz-osx-font-smoothing: grayscale;
  -webkit-font-smoothing: antialiased;
  box-sizing: border-box;
  @apply bg-dark text-white font-oxygen;
  @apply w-screen h-screen;
  @apply flex flex-col;
  @apply pr-5 pl-5 mb-10 md:pr-10 md:pl-10 lg:pl-24 lg:pr-24 xl:pl-36 xl:pr-36;
}
</style>
