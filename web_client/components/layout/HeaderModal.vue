<template>
  <div class="head-modal">
    <HeaderNavigation />
  </div>
</template>

<script>
import HeaderNavigation from '@/components/layout/HeaderNavigation'
export default {
  components: { HeaderNavigation },
}
</script>

<style>
.head-modal {
  @apply lg:hidden absolute inline;
  @apply border-2 border-white rounded-2xl;
  @apply right-0 top-24 w-48 z-10 bg-dark;
}
</style>
