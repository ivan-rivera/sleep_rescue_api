<template>
  <header class="header">
    <div class="logo">
      <NuxtLink to="/">
        <img src="images/logo.svg" alt="logo" />
      </NuxtLink>
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

<style scoped>
.header {
  @apply relative flex flex-row items-center justify-between;
  @apply pt-2.5 pb-2.5;
}

.logo {
  @apply transform scale-75 origin-left;
}
</style>
