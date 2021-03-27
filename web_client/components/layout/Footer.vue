<template>
  <footer class="font-normal text-xs flex flex-col justify-center items-center">
    <p>SleepRescue.org © {{ year }}</p>
    <div>
      <p class="inline-block">Build with Phoenix + Nuxt</p>
      <img class="inline-block" src="images/phoenix.svg" alt="phoenix" />
      <img class="inline-block" src="images/nuxt-white-small.svg" alt="nuxt" />
    </div>
  </footer>
</template>

<script>
export default {
  computed: {
    year() {
      return new Date().getFullYear()
    },
  },
}
</script>
