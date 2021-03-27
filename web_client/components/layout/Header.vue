<template>
  <header class="header">
    <div class="transform scale-75 origin-left">
      <img src="images/logo.svg" alt="logo" />
    </div>
    <HeaderNavigation class="hidden lg:block" />
    <HeaderButton @click.native="showModal = !showModal" />
    <HeaderModal v-if="showModal" />
  </header>
</template>

<script>
import HeaderNavigation from '~/components/layout/HeaderNavigation'
import HeaderButton from '~/components/layout/HeaderButton'
import HeaderModal from '~/components/layout/HeaderModal'
export default {
  components: {
    HeaderModal,
    HeaderNavigation,
    HeaderButton,
  },
  data() {
    return {
      showModal: false,
    }
  },
}
</script>

<style>
.header {
  @apply relative flex flex-row items-center justify-between;
  @apply pt-2.5 pb-2.5;
}
</style>
