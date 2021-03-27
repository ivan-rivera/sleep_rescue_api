<template>
  <ul>
    <li class="head-option">
      <font-awesome-icon :icon="['fa', 'paperclip']" />
      Terms of Service
    </li>
    <li class="head-option">
      <font-awesome-icon :icon="['fa', 'file']" />
      Privacy
    </li>
    <li class="head-option">
      <font-awesome-icon :icon="['fa', 'phone-square']" />
      Contact
    </li>
    <li class="head-option">
      <font-awesome-icon :icon="['fa', 'info-circle']" />
      About
    </li>
  </ul>
</template>

<style>
.head-option {
  @apply lg:inline p-5 text-supplementary;
  @apply transition duration-150 hover:bg-white rounded-xl hover:text-dark;
}
</style>
